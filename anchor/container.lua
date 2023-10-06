-- This is responsible for holding game objects and performing operations on them.
-- You should create one container object for each type of object that's relevant for your game according to access patterns.
-- If you always need to run checks on player and enemy game objects, then each should have its own container, or maybe they should share the same one if it makes sense.
-- Create a new container as a new object: "self.players = container()"
local container = class:class_new()
function container:container_init()
  self.objects = {}
  self.by_id = {}
  return self
end

-- Updates all objects.
function container:container_update(dt)
  for _, object in ipairs(self.objects) do
    object:update(dt)
  end
end

-- Runs the action for each game object in the container.
function container:container_for_each(action)
  for _, object in ipairs(self.objects) do
    if not object.dead then 
      action(object)
    end
  end
end

-- Adds a new object to the container.
-- players = container()
-- p = players:add(player{name = 'player_1', x = g.w/2, y = g.h/2, v = 200})
-- print(players.by_name.player_1.v, p.v) -> 200, 200
function container:container_add(object)
  object.container = self
  table.insert(self.objects, object)
  self.by_id[object.id] = object
  main:container_add_without_changing_attributes(object)
  return object
end

-- Adds a new object to the container without changing any of its attributes.
-- This is used primarily to add objects to the main container, which is a container that contains all objects that are added to any container in it so we can perform global .by_id searches.
function container:container_add_without_changing_attributes(object)
  table.insert(self.objects, object)
  self.by_id[object.id] = object
  return object
end

-- Runs the action for each object in the container and removes the ones for which it returns true.
-- enemies = container()
-- enemies:remove(function(object) return object.x > 400 end) -> removes all objects where its x position is bigger than 400
function container:container_remove(action)
  for i = #self.objects, 1, -1 do
    local object = self.objects[i]
    if action(object) then
      if object.collider_destroy then object:collider_destroy() end
      table.remove(self.objects, i)
      self.by_id[object.id] = nil
    end
  end
end

-- Removes all objects which have the .dead attribute set to true.
function container:container_remove_dead()
  for i = #self.objects, 1, -1 do
    local object = self.objects[i]
    if object.dead then
      if object.collider_destroy then object:collider_destroy() end
      table.remove(self.objects, i)
      self.by_id[object.id] = nil
    end
  end
end


-- Removes all objects which have the .dead attribute set to true without destroying them if they can be destroyed.
-- This is primarily used to remove objects from the main container, which contains all objects in the game.
-- Those objects are already destroyed in any other containers they're in, so destroying them again isn't needed.
-- I could make the main container work equivalently to a weak table so that all of its objects are automatically removed when the only reference left is there, but for now this will do.
function container:container_remove_dead_without_destroying()
  for i = #self.objects, 1, -1 do
    local object = self.objects[i]
    if object.dead then
      table.remove(self.objects, i)
      self.by_id[object.id] = nil
    end
  end
end

-- Returns the closest object to the given point.
-- enemies:get_closest_object(player.x, player.y) -> gets the closest enemy to the player.
-- "condition" is an optional function that receives an object and returns true if it should be considered for the calculation.
function container:container_get_closest_object(x, y, condition)
  local min_d, min_i = 1000000, -1
  for i, object in ipairs(self.objects) do
    local d = math.distance(x, y, object.x, object.y)
    if d < min_d and (not condition or (condition and condition(x, y, object))) then
      min_d = d
      min_i = i
    end
  end
  return self.objects[min_i]
end

-- Returns all objects inside the circle of radius rs centered on x, y.
-- enemies:get_objects_in_radius(0, 0, 20) -> returns all objects in the 0, 0 circle with radius 20.
function container:container_get_objects_in_radius(x, y, rs)
  local objects = {}
  for _, object in ipairs(self.objects) do
    if math.distance(x, y, object.x, object.y) <= rs then
      table.insert(objects, object)
    end
  end
  return objects
end

-- Destroys all objects and resets the container.
function container:container_destroy()
  for _, object in ipairs(self.objects) do
    if object.collider_destroy then object:collider_destroy() end
    object.dead = true
  end
  self.objects = {}
  self.by_id = {}
end

return container
