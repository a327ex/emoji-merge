-- Trying this idea out, if this comment is here and the game shipped it means the idea works and I didn't have time to come back and document it properly.
local level = class:class_new()
function level:level_init()
  self.levels = {}
  self.level = nil
  return self
end

-- Updates the current level.
function level:level_update(dt)
  if self.level then
    self.level:update(dt)
  end
end

-- Adds an object that was already created to the level mixin.
-- The level's name must be unique, if it isn't then an error will occur.
function level:level_add(name, object)
  if self.levels[name] then error("There's already a level named '" .. name .. "' in this level object. Level names must be unique.") end
  object.level = self
  object.name = name
  self.levels[name] = object
  return object
end

-- Changes to the target level. The current level (.level) has :exit called on it, and the new level has :enter called on it.
-- This reuses the level object that was already in memory and doesn't create it anew.
function level:level_goto(name, ...)
  if self.level and self.level.exit then self.level:exit(...) end
  collectgarbage("collect")
  -- print(collectgarbage("count")/1024, #main.objects, #main.world:getBodies(), #main.world:getJoints())
  self.level = self.levels[name]
  if self.level.enter then self.level:enter(...) end
end

return level
