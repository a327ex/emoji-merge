-- Trying this idea out, if this comment is here and the game shipped it means the idea works and I didn't have time to come back and document it properly.
local level = class:class_new()
function level:level_init()
  self.levels = {}
  self.current_level = nil
  return self
end

-- Updates the current level.
function level:level_update(dt)
  if self.current_level then
    self.current_level:update(dt)
  end
end

function level:level_add(name, object)
  if self.levels[name] then error("There's already a level named '" .. name .. "' in this level object. Level names must be unique.") end
  object.level = self
  object.name = name
  self.levels[name] = object
  return object
end

function level:level_goto(name, ...)
  if self.current_level and self.current_level.exit then self.current_level:exit(...) end
  self.current_level = self.levels[name]
  if self.current_level.enter then self.current_level:enter(...) end
end

return level
