-- The argument passed in is the duration of the flash.
local flash = class:class_new()
function flash:flash_init(duration)
  self.duration = duration or 0.15
  self.timer = 0
  self.x = false
  return self
end

function flash:flash_update(dt)
  self.timer = self.timer + dt
  if self.timer > self.duration then
    self.x = false
    self.timer = 0
  end
end

-- Activates the flash, this sets this object's .f attribute to true for the given duration.
function flash:flash_flash(duration)
  self.x = true
  self.timer = 0
  self.duration = duration
end

return flash
