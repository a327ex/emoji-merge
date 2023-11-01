-- A box2d physics world.
-- Initially this was inside the container mixin but being able to have multiple containers whose objects refer to the same physics world is too useful, so it's now separated.
-- world = physics_world(192, 0, 400) -> a common platformer setup with vertical downward gravity
-- world = physics_world(192) -> a common setup for most non-platformer games
-- If your game takes place in smaller world coordinates (i.e. you set game.w and game.h to 320x240 or something) then you'll want smaller meter values, like 32 instead of 192
-- Read more on meter values for box2d worlds here: https://love2d.org/wiki/love.physics.setMeter
local physics_world = class:class_new()
function physics_world:physics_world_init(meter, xg, yg)
  love.physics.setMeter(meter or 64)
  self.world = love.physics.newWorld(xg or 0, yg or 0)
  self.collision_enter = {}
  self.collision_active = {}
  self.collision_exit = {}
  self.trigger_enter = {}
  self.trigger_active = {}
  self.trigger_exit = {}
  return self
end

function physics_world:physics_world_update(dt)
  self.world:update(dt)
end

function physics_world:physics_world_post_update(dt)
  self.collision_enter = {}
  self.collision_exit = {}
  self.trigger_enter = {}
  self.trigger_exit = {}
end

-- Sets physics world callbacks. These can be set in two ways:
-- 1. 'collider' - the callbacks will populate each collider's .collision_enter/active/exit and .trigger_enter/active/exit tables every frame.
-- 2. 'world' - the callbacks will set the physics_world's .collision_enter/active/exit and .trigger_enter/active/exit tables every frame.
-- For the 'collider' way, these events can then be read on the object's update function as such: "for other, contact in pairs(self.collision_enter['other_type']) do".
-- For the 'world' way, they can then be read with :physics_world_get_collision_enter('type_1', 'type_2'), which returns a list of collisions for these types in this frame, each collision being a table of type {object_1, object_2, ...}
--
-- This should be called manually by the user at the start of the game once, as it is the case with :physics_world_set_collision_tags.
-- callback_type can be either 'collider' or 'world', if it is nil then 'world' will be used
-- tag_or_type can be either 'tag' or 'type', if it is 'tag' then physics tags (set with :physics_world_set_collision_tags) will be used for collision events, if it is 'type' then object's anchor types will be used instead
function physics_world:physics_world_set_callbacks(callback_type, tag_or_type)
  self.tag_or_type = tag_or_type or 'tag'
  local collider, world = callback_type == 'collider', callback_type == 'world'
  if not callback_type then collider, world = true, true end

  self.world:setCallbacks(
    function(fa, fb, c)
      local a, b = fa:getUserData(), fb:getUserData()
      if not a or not b then return end
      local a_type = self.tag_or_type == 'tag' and a.physics_tag or a.type
      local b_type = self.tag_or_type == 'tag' and b.physics_tag or b.type
      if fa:isSensor() and fb:isSensor() then
        if collider then
          if fa:isSensor() then self:physics_world_collider_add_trigger_enter(a, b, a_type, b_type) end
          if fb:isSensor() then self:physics_world_collider_add_trigger_enter(b, a, b_type, a_type) end
        end
        if world then
          if fa:isSensor() then self:physics_world_add_trigger_enter(a, b, a_type, b_type) end
          if fb:isSensor() then self:physics_world_add_trigger_enter(b, a, b_type, a_type) end
        end
      elseif not fa:isSensor() and not fb:isSensor() then
        local x1, y1, x2, y2 = c:getPositions()
        local nx, ny = c:getNormal() 
        if collider then
          self:physics_world_collider_add_collision_enter(a, b, a_type, b_type, x1, y1, x2, y2, nx, ny)
          self:physics_world_collider_add_collision_enter(b, a, b_type, a_type, x1, y1, x2, y2, nx, ny)
        end
        if world then
          self:physics_world_add_collision_enter(a, b, a_type, b_type, x1, y1, x2, y2, nx, ny)
          self:physics_world_add_collision_enter(b, a, b_type, a_type, x1, y1, x2, y2, nx, ny)
        end
      end
    end,
    function(fa, fb, c)
      local a, b = fa:getUserData(), fb:getUserData()
      if not a or not b then return end
      local a_type = self.tag_or_type == 'tag' and a.physics_tag or a.type
      local b_type = self.tag_or_type == 'tag' and b.physics_tag or b.type
      if fa:isSensor() and fb:isSensor() then
        if collider then
          if fa:isSensor() then self:physics_world_collider_add_trigger_exit(a, b, a_type, b_type) end
          if fb:isSensor() then self:physics_world_collider_add_trigger_exit(b, a, b_type, a_type) end
        end
        if world then
          if fa:isSensor() then self:physics_world_add_trigger_exit(a, b, a_type, b_type) end
          if fb:isSensor() then self:physics_world_add_trigger_exit(b, a, b_type, a_type) end
        end
      elseif not fa:isSensor() and not fb:isSensor() then
        local x1, y1, x2, y2 = c:getPositions()
        local nx, ny = c:getNormal() 
        if collider then
          self:physics_world_collider_add_collision_exit(a, b, a_type, b_type, x1, y1, x2, y2, nx, ny)
          self:physics_world_collider_add_collision_exit(b, a, b_type, a_type, x1, y1, x2, y2, nx, ny)
        end
        if world then
          self:physics_world_add_collision_exit(a, b, a_type, b_type, x1, y1, x2, y2, nx, ny)
          self:physics_world_add_collision_exit(b, a, b_type, a_type, x1, y1, x2, y2, nx, ny)
        end
      end
    end,
    function(fa, fb, c)
      local a, b = fa:getUserData(), fb:getUserData()
      if not a or not b then return end
      if collider then
        if a.pre_solve then a:pre_solve(b, c) end
        if b.pre_solve then b:pre_solve(a, c) end
      end
      if world then
        if self.pre_solve then self:pre_solve(a, b, c) end
      end
    end,
    function(fa, fb, c, ni1, ti1, ni2, ti2)
      local a, b = fa:getUserData(), fb:getUserData()
      if not a or not b then return end
      if collider then
        if a.post_solve then a:post_solve(b, c, ni1, ti1, ni2, ti2) end
        if b.post_solve then b:post_solve(a, c, ni1, ti1, ni2, ti2) end
      end
      if world then
        if self.post_solve then self:post_solve(a, b, c, ni1, ti1, ni2, ti2) end
      end
    end
  )
end

-- Tags is a list of strings corresponding to collision tags that will be assigned to different objects.
-- This should be called manually by the user at the start of the game once, otherwise colliders will error out since their tags aren't defined.
-- :physics_world_set_collision_tags{'player', 'enemy', 'projectile', 'ghost'}
function physics_world:physics_world_set_collision_tags(tags)
  self.physics_tags = tags
  self.collision_tags = {}
  self.trigger_tags = {}
  for i, tag in ipairs(self.physics_tags) do
    self.collision_tags[tag] = {category = i, masks = {}}
    self.trigger_tags[tag] = {category = i, triggers = {}}
  end
end

-- Enables physical collision between the first and the other tags.
-- By default, every object physically collides with every other object.
-- :physics_world_enable_collision_between('player', {'enemy', 'enemy_projectile'}) -> 'player' now physically collides with 'enemy' and 'enemy_projectile'
function physics_world:physics_world_enable_collision_between(tag1, tags)
  for _, tag2 in ipairs(tags) do
    table.delete(self.collision_tags[tag1].masks, self.collision_tags[tag2].category)
  end
end

-- Disables physical collision between the first and the other tags.
-- :physics_world_disable_collision_between('ghost', {'player', 'solid'}) -> 'ghost' now doesn't physically collide with 'player' and 'solid'
function physics_world:physics_world_disable_collision_between(tag1, tags) 
  for _, tag2 in ipairs(tags) do
    table.insert(self.collision_tags[tag1].masks, self.collision_tags[tag2].category)
  end
end

-- Enables trigger collision between the first and the other tags.
-- When objects have physical collision disabled between one another, you might still want to have the engine generate enter and exit events when they start/stop overlapping, this does that.
-- :physics_world_disable_collision_between('ghost', 'player')
-- :physics_world_enable_trigger_between('ghost', {'player'}) -> now when a ghost passes through a player, the ghost's enter/exit collision callback functions will be called.
function physics_world:physics_world_enable_trigger_between(tag1, tags)
  for _, tag2 in ipairs(tags) do
    table.insert(self.trigger_tags[tag1].triggers, self.trigger_tags[tag2].category)
  end
end

-- Disables trigger collision between the first and the other tags.
-- This will only work if enable_trigger_between has been called for a pair of tags.
-- In general you shouldn't use this, as trigger collisions are disabled by default for all objects.
function physics_world:physics_world_disable_trigger_between(tag1, tags) 
  for _, tag2 in ipairs(tags) do
    table.delete(self.trigger_tags[tag1].triggers, self.trigger_tags[tag2].category)
  end
end

-- Adds collision_enter and collision_active events to the target collider.
-- These events can be read by doing: "self.collision_enter['other_type']" on the target collider.
-- Every collision event lasts 1 frame only, except for collision_active ones which last however many frames there are between collision_enter and collision_exit events.
function physics_world:physics_world_collider_add_collision_enter(target, other, other_type, x1, y1, x2, y2, xn, yn)
  if not target.collision_enter[other_type] then target.collision_enter[other_type] = {} end
  if not target.collision_active[other_type] then target.collision_active[other_type] = {} end
  local t = {other, x1, y1, x2, y2, xn, yn}
  target.collision_enter[other] = t
  target.collision_active[other] = t
  table.insert(target.collision_enter[other_type], t)
  table.insert(target.collision_active[other_type], t)
end

-- Adds collision_exit and removes collision_active events from the target collider.
-- These events can be read by doing: "self.collision_exit['other_type']" on the target collider.
-- Every collision event lasts 1 frame only, except for collision_active ones which last however many frames there are between collision_enter and collision_exit events.
function physics_world:physics_world_collider_add_collision_exit(target, other, other_type, x1, y1, x2, y2, xn, yn)
  if not target.collision_exit[other_type] then target.collision_exit[other_type] = {} end
  if not target.collision_active[other_type] then target.collision_active[other_type] = {} end
  local t = {other, x1, y1, x2, y2, xn, yn}
  target.collision_exit[other] = t
  table.insert(target.collision_exit[other_type], t)
  for i = #target.collision_active[other_type], 1, -1 do
    local c = target.collision_active[other_type][i]
    if c[1].id == other.id then
      table.remove(target.collision_active[other_type], i)
    end
  end
  target.collision_active[other] = nil
end

-- Adds collision_enter and collision_active events to this object.
-- These events can be read by doing: "self.collision_enter['type_1']['type_2']"
-- Every collision event lasts 1 frame only, except for collision_active ones which last however many frames there are between collision_enter and collision_exit events.
function physics_world:physics_world_add_collision_enter(a, b, a_type, b_type, x1, y1, x2, y2, xn, yn)
  if not self.collision_enter[a_type] then self.collision_enter[a_type] = {} end
  if not self.collision_enter[a_type][b_type] then self.collision_enter[a_type][b_type] = {} end
  if not self.collision_active[a_type] then self.collision_active[a_type] = {} end
  if not self.collision_active[a_type][b_type] then self.collision_active[a_type][b_type] = {} end
  table.insert(self.collision_enter[a_type][b_type], {a, b, x1, y1, x2, y2, xn, yn})
  table.insert(self.collision_active[a_type][b_type], {a, b, x1, y1, x2, y2, xn, yn})
end

-- Adds collision_exit and removes collision_active events from this object.
-- These events can be read by doing: "self.collision_exit['type_1']['type_2']"
-- Every collision event lasts 1 frame only, except for collision_active ones which last however many frames there are between collision_enter and collision_exit events.
function physics_world:physics_world_add_collision_exit(a, b, a_type, b_type, x1, y1, x2, y2, xn, yn)
  if not self.collision_exit[a_type] then self.collision_exit[a_type] = {} end
  if not self.collision_exit[a_type][b_type] then self.collision_exit[a_type][b_type] = {} end
  if not self.collision_active[a_type] then self.collision_active[a_type] = {} end
  if not self.collision_active[a_type][b_type] then self.collision_active[a_type][b_type] = {} end
  table.insert(self.collision_exit[a_type][b_type], {a, b, x1, y1, x2, y2, xn, yn})
  for i = #self.collision_active[a_type][b_type], 1, -1 do
    local c = self.collision_active[a_type][b_type][i]
    if c[1].id == a.id and c[2].id == b.id then
      table.remove(self.collision_active[a_type][b_type], i)
    end
  end
end

-- Adds trigger_enter and trigger_active events to the target collider.
-- These events can be read by doing: "for other, contact in pairs(self.trigger_enter['other_type']) do"
-- Every trigger event lasts 1 frame only, except for trigger_active ones which last however many frames there are between trigger_enter and trigger_exit events.
function physics_world:physics_world_collider_add_trigger_enter(target, other, other_type)
  if not target.trigger_enter[other_type] then target.trigger_enter[other_type] = {} end
  if not target.trigger_active[other_type] then target.trigger_active[other_type] = {} end
  target.trigger_enter[other] = true
  target.trigger_active[other] = true
  table.insert(target.trigger_enter[other_type], other)
  target.trigger_enter[other_type][other] = true
  target.trigger_active[other_type][other] = true
end

-- Adds trigger_exit and removes trigger_active events from the target collider.
-- These events can be read by doing: "for other, contact in pairs(self.trigger_exit['other_type']) do"
-- Every trigger event lasts 1 frame only, except for trigger_active ones which last however many frames there are between trigger_enter and trigger_exit events.
function physics_world:physics_world_collider_add_trigger_exit(target, other, other_type)
  if not target.trigger_exit[other_type] then target.trigger_exit[other_type] = {} end
  if not target.trigger_active[other_type] then target.trigger_active[other_type] = {} end
  target.trigger_exit[other] = true
  target.trigger_active[other] = nil
  table.insert(target.trigger_exit[other_type], other)
  target.trigger_exit[other_type][other] = true
  target.trigger_active[other_type][other] = nil
end

-- Adds trigger_enter and trigger_active events to this object.
-- These events can be read by doing: "self.trigger_enter['type_1']['type_2']"
-- Every trigger event lasts 1 frame only, except for trigger_active ones which last however many frames there are between trigger_enter and trigger_exit events.
function physics_world:physics_world_add_trigger_enter(a, b, a_type, b_type)
  if not self.trigger_enter[a_type] then self.trigger_enter[a_type] = {} end
  if not self.trigger_enter[a_type][b_type] then self.trigger_enter[a_type][b_type] = {} end
  if not self.trigger_active[a_type] then self.trigger_active[a_type] = {} end
    if not self.trigger_active[a_type][b_type] then self.trigger_active[a_type][b_type] = {} end
  table.insert(self.trigger_enter[a_type][b_type], {a, b})
  table.insert(self.trigger_active[a_type][b_type], {a, b})
end

-- Adds trigger_exit and removes trigger_active events from this object.
-- These events can be read by doing: "self.trigger_exit['type_1']['type_2']"
-- Every trigger event lasts 1 frame only, except for trigger_active ones which last however many frames there are between trigger_enter and trigger_exit events.
function physics_world:physics_world_add_trigger_exit(a, b, a_type, b_type)
  if not self.trigger_exit[a_type] then self.trigger_exit[a_type] = {} end
  if not self.trigger_exit[a_type][b_type] then self.trigger_exit[a_type][b_type] = {} end
  if not self.trigger_active[a_type] then self.trigger_active[a_type] = {} end
  if not self.trigger_active[a_type][b_type] then self.trigger_active[a_type][b_type] = {} end
  table.insert(self.trigger_exit[a_type][b_type], {a, b})
  for i = #self.trigger_active[a_type][b_type], 1, -1 do
    local c = self.trigger_active[a_type][b_type][i]
    if c[1].id == a.id and c[2].id == b.id then
      table.remove(self.trigger_active[a_type][b_type], i)
    end
  end
end

-- Returns a table of collision_enter events for the two given types this frame.
-- Each event is of the type: {object_1, object_2, contact}
-- If no collision_enter events for these types happened this frame then it returns an empty list.
function physics_world:physics_world_get_collision_enter(type_1, type_2)
  local collisions = {}
  if self.collision_enter[type_1] and self.collision_enter[type_1][type_2] then
    collisions = self.collision_enter[type_1][type_2]
  end
  return collisions
end

-- Returns a table of collision_exit events for the two given types this frame.
-- Each event is of the type: {object_1, object_2, contact}
-- If no collision_exit events for these types happened this frame then it returns an empty list.
function physics_world:physics_world_get_collision_exit(type_1, type_2)
  local collisions = {}
  if self.collision_exit[type_1] and self.collision_exit[type_1][type_2] then
    collisions = self.collision_exit[type_1][type_2]
  end
  return collisions
end

-- Returns a table of collision_active events for the two given types this frame.
-- Each event is of the type: {object_1, object_2, contact}
-- If no collision_active events for these types exist this frame then it returns an empty list.
function physics_world:physics_world_get_collision_active(type_1, type_2)
  local collisions = {}
  if self.collision_active[type_1] and self.collision_active[type_1][type_2] then
    collisions = self.collision_active[type_1][type_2]
  end
  return collisions
end

-- Returns a table of trigger_enter events for the two given types this frame.
-- Each event is of the type: {object_1, object_2}
-- If no trigger_enter events for these types happened this frame then it returns an empty list.
function physics_world:physics_world_get_trigger_enter(type_1, type_2)
  local triggers = {}
  if self.trigger_enter[type_1] and self.trigger_enter[type_1][type_2] then
    triggers = self.trigger_enter[type_1][type_2]
  end
  return triggers
end

-- Returns a table of trigger_exit events for the two given types this frame.
-- Each event is of the type: {object_1, object_2}
-- If no trigger_exit events for these types happened this frame then it returns an empty list.
function physics_world:physics_world_get_trigger_exit(type_1, type_2)
  local triggers = {}
  if self.trigger_exit[type_1] and self.trigger_exit[type_1][type_2] then
    triggers = self.trigger_exit[type_1][type_2]
  end
  return triggers
end

-- Returns a table of trigger_active events for the two given types this frame.
-- Each event is of the type: {object_1, object_2}
-- If no trigger_active events for these types exist this frame then it returns an empty list.
function physics_world:physics_world_get_trigger_active(type_1, type_2)
  local triggers = {}
  if self.trigger_active[type_1] and self.trigger_active[type_1][type_2] then
    triggers = self.trigger_active[type_1][type_2]
  end
  return triggers
end

function physics_world:physics_world_set_meter(meter)
  love.physics.setMeter(meter)
end

function physics_world:physics_world_set_gravity(x, y)
  self.world:setGravity(x, y)
end

function physics_world:physics_world_get_body_count()
  return self.world:getBodyCount()
end

function physics_world:physics_world_get_contacts()
  return self.world:getContacts()
end

function physics_world:physics_world_are_all_bodies_sleeping()
  local bodies = self.world:getBodies()
  for _, body in ipairs(bodies) do
    if body:isAwake() then
      return false
    end
  end
  return true
end

-- Casts a ray through the world and returns a table of hits. Each hit has .fixture, .x, .y, .xn, .yn and .fraction attributes according to https://love2d.org/wiki/World:rayCast.
function physics_world:physics_world_raycast(x1, y1, x2, y2)
  local hits = {}
  self.world:rayCast(x1, y1, x2, y2, function(fixture, x, y, xn, yn, fraction)
    table.insert(hits, {fixture = fixture, x = x, y = y, xn = xn, yn = yn, fraction = fraction})
    return 1
  end)
  return hits
end

-- Returns all objects whose AABBs are colliding with the rectangle formed by x1, y1, x2, y2.
function physics_world:get_objects_in_area(x1, y1, x2, y2)
  local fixtures = self.world:getFixturesInArea(x1, y1, x2, y2)
  local objects = {}
  for _, f in ipairs(fixtures) do table.insert(objects, f:getUserData()) end
  return objects
end

return physics_world
