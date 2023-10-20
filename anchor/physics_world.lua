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
-- For the 'world' way, these events can then be read on the relevant table, say self.collision_enter, in the following way:
--   self.collision_enter['type_1']['type_2'] - will be true if objects of these two types entered collision this frame, and this value will be a list where each collision is a table of the type {object_1, object_2, ...}
--
-- This should be called manually by the user at the start of the game once, as it is the case with :physics_world_set_collision_tags.
-- callback_type can be either 'collider' or 'main', if it is nil then both modes will be used.
function physics_world:physics_world_set_callbacks(callback_type)
  local collider, world = callback_type == 'collider', callback_type == 'world'
  if not callback_type then collider, world = true, true end
  self.world:setCallbacks(
    function(fa, fb, c)
      local oa, ob = fa:getUserData(), fb:getUserData()
      if not oa or not ob then return end
      if fa:isSensor() and fb:isSensor() then
        if collider then
          if fa:isSensor() then self:physics_world_collider_add_trigger_enter(oa, ob, c) end
          if fb:isSensor() then self:physics_world_collider_add_trigger_enter(ob, oa, c) end
        end
        if world then
          if fa:isSensor() then self:physics_world_add_trigger_enter(oa, ob, c) end
          if fb:isSensor() then self:physics_world_add_trigger_enter(ob, oa, c) end
        end
      elseif not fa:isSensor() and not fb:isSensor() then
        if collider then
          self:physics_world_collider_add_collision_enter(oa, ob, c)
          self:physics_world_collider_add_collision_enter(ob, oa, c)
        end
        if world then
          self:physics_world_add_collision_enter(oa, ob, c)
          self:physics_world_add_collision_enter(ob, oa, c)
        end
      end
    end,
    function(fa, fb, c)
      local oa, ob = fa:getUserData(), fb:getUserData()
      if not oa or not ob then return end
      if fa:isSensor() and fb:isSensor() then
        if collider then
          if fa:isSensor() then self:physics_world_collider_add_trigger_exit(oa, ob, c) end
          if fb:isSensor() then self:physics_world_collider_add_trigger_exit(ob, oa, c) end
        end
        if world then
          if fa:isSensor() then self:physics_world_add_trigger_exit(oa, ob, c) end
          if fb:isSensor() then self:physics_world_add_trigger_exit(ob, oa, c) end
        end
      elseif not fa:isSensor() and not fb:isSensor() then
        if collider then
          self:physics_world_collider_add_collision_exit(oa, ob, c)
          self:physics_world_collider_add_collision_exit(ob, oa, c)
        end
        if world then
          self:physics_world_add_collision_exit(oa, ob, c)
          self:physics_world_add_collision_exit(ob, oa, c)
        end
      end
    end,
    function(fa, fb, c)
      local oa, ob = fa:getUserData(), fb:getUserData()
      if not oa or not ob then return end
      if collider then
        if oa.pre_solve then oa:pre_solve(ob, c) end
        if ob.pre_solve then ob:pre_solve(oa, c) end
      end
      if world then
        if self.pre_solve then self:pre_solve(oa, ob, c) end
      end
    end,
    function(fa, fb, c, ni1, ti1, ni2, ti2)
      local oa, ob = fa:getUserData(), fb:getUserData()
      if not oa or not ob then return end
      if collider then
        if oa.post_solve then oa:post_solve(ob, c, ni1, ti1, ni2, ti2) end
        if ob.post_solve then ob:post_solve(oa, c, ni1, ti1, ni2, ti2) end
      end
      if world then
        if self.post_solve then self:post_solve(oa, ob, c, ni1, ti1, ni2, ti2) end
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
-- These events can be read by doing: "for other, contact in pairs(self.collision_enter['other_type']) do"
-- Every collision event lasts 1 frame only, except for collision_active ones which last however many frames there are between collision_enter and collision_exit events.
function physics_world:physics_world_collider_add_collision_enter(target, other, contact)
  if not target.collision_enter[other.type] then target.collision_enter[other.type] = {} end
  if not target.collision_active[other.type] then target.collision_active[other.type] = {} end
  table.insert(target.collision_enter[other.type], {other, contact})
  target.collision_enter[other.type][other] = contact
  target.collision_active[other.type][other] = target.id
end

-- Adds collision_exit and removes collision_active events from the target collider.
-- These events can be read by doing: "for other, contact in pairs(self.collision_exit['other_type']) do"
-- Every collision event lasts 1 frame only, except for collision_active ones which last however many frames there are between collision_enter and collision_exit events.
function physics_world:physics_world_collider_add_collision_exit(target, other, contact)
  if not target.collision_exit[other.type] then target.collision_exit[other.type] = {} end
  if not target.collision_active[other.type] then target.collision_active[other.type] = {} end
  table.insert(target.collision_exit[other.type], {other, contact})
  target.collision_exit[other.type][other] = contact
  target.collision_active[other.type][other] = false
end

-- Adds collision_enter and collision_active events to this object.
-- These events can be read by doing: "self.collision_enter['type_1']['type_2']"
-- Every collision event lasts 1 frame only, except for collision_active ones which last however many frames there are between collision_enter and collision_exit events.
function physics_world:physics_world_add_collision_enter(a, b, contact)
  if not self.collision_enter[a.type] then self.collision_enter[a.type] = {} end
  if not self.collision_enter[a.type][b.type] then self.collision_enter[a.type][b.type] = {} end
  if not self.collision_active[a.type] then self.collision_active[a.type] = {} end
  if not self.collision_active[a.type][b.type] then self.collision_active[a.type][b.type] = {} end
  table.insert(self.collision_enter[a.type][b.type], {a, b, contact})
  table.insert(self.collision_active[a.type][b.type], {a, b, contact})
end

-- Adds collision_exit and removes collision_active events from this object.
-- These events can be read by doing: "self.collision_exit['type_1']['type_2']"
-- Every collision event lasts 1 frame only, except for collision_active ones which last however many frames there are between collision_enter and collision_exit events.
function physics_world:physics_world_add_collision_exit(a, b, contact)
  if not self.collision_exit[a.type] then self.collision_exit[a.type] = {} end
  if not self.collision_exit[a.type][b.type] then self.collision_exit[a.type][b.type] = {} end
  if not self.collision_active[a.type] then self.collision_active[a.type] = {} end
  if not self.collision_active[a.type][b.type] then self.collision_active[a.type][b.type] = {} end
  table.insert(self.collision_exit[a.type][b.type], {a, b, contact})
  for i = #self.collision_active[a.type][b.type], 1, -1 do
    local c = self.collision_active[a.type][b.type][i]
    if c[1].id == a.id and c[2].id == b.id then
      table.remove(self.collision_active[a.type][b.type], i)
    end
  end
end

-- Adds trigger_enter and trigger_active events to the target collider.
-- These events can be read by doing: "for other, contact in pairs(self.trigger_enter['other_type']) do"
-- Every trigger event lasts 1 frame only, except for trigger_active ones which last however many frames there are between trigger_enter and trigger_exit events.
function physics_world:physics_world_collider_add_trigger_enter(target, other)
  if not target.trigger_enter[other.type] then target.trigger_enter[other.type] = {} end
  if not target.trigger_active[other.type] then target.trigger_active[other.type] = {} end
  table.insert(target.trigger_enter[other.type], other)
  target.trigger_enter[other.type][other] = target.id
  target.trigger_active[other.type][other] = target.id
end

-- Adds trigger_exit and removes trigger_active events from the target collider.
-- These events can be read by doing: "for other, contact in pairs(self.trigger_exit['other_type']) do"
-- Every trigger event lasts 1 frame only, except for trigger_active ones which last however many frames there are between trigger_enter and trigger_exit events.
function physics_world:physics_world_collider_add_trigger_exit(target, other)
  if not target.trigger_exit[other.type] then target.trigger_exit[other.type] = {} end
  if not target.trigger_active[other.type] then target.trigger_active[other.type] = {} end
  table.insert(target.trigger_exit[other.type], other)
  target.trigger_exit[other.type][other] = target.id
  target.trigger_active[other.type][other] = false
end

-- Adds trigger_enter and trigger_active events to this object.
-- These events can be read by doing: "self.trigger_enter['type_1']['type_2']"
-- Every trigger event lasts 1 frame only, except for trigger_active ones which last however many frames there are between trigger_enter and trigger_exit events.
function physics_world:physics_world_add_trigger_enter(a, b, contact)
  if not self.trigger_enter[a.type] then self.trigger_enter[a.type] = {} end
  if not self.trigger_enter[a.type][b.type] then self.trigger_enter[a.type][b.type] = {} end
  if not self.trigger_active[a.type] then self.trigger_active[a.type] = {} end
    if not self.trigger_active[a.type][b.type] then self.trigger_active[a.type][b.type] = {} end
  table.insert(self.trigger_enter[a.type][b.type], {a, b, contact})
  table.insert(self.trigger_active[a.type][b.type], {a, b, contact})
end

-- Adds trigger_exit and removes trigger_active events from this object.
-- These events can be read by doing: "self.trigger_exit['type_1']['type_2']"
-- Every trigger event lasts 1 frame only, except for trigger_active ones which last however many frames there are between trigger_enter and trigger_exit events.
function physics_world:physics_world_add_trigger_exit(a, b, contact)
  if not self.trigger_exit[a.type] then self.trigger_exit[a.type] = {} end
  if not self.trigger_exit[a.type][b.type] then self.trigger_exit[a.type][b.type] = {} end
  if not self.trigger_active[a.type] then self.trigger_active[a.type] = {} end
  if not self.trigger_active[a.type][b.type] then self.trigger_active[a.type][b.type] = {} end
  table.insert(self.trigger_exit[a.type][b.type], {a, b, contact})
  for i = #self.trigger_active[a.type][b.type], 1, -1 do
    local c = self.trigger_active[a.type][b.type][i]
    if c[1].id == a.id and c[2].id == b.id then
      table.remove(self.trigger_active[a.type][b.type], i)
    end
  end
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
