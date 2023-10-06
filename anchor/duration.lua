local duration = class:class_new()
function duration:duration_init(duration)
  self:timer_init()
  self.duration = duration
  self:timer_after(self.duration, function() self.dead = true end, 'duration')
  return self
end

return duration
