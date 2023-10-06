local slow = class:class_new()
function slow:slow_init()
  self:timer_init()
  self.slow_amount = 1
  return self
end

function slow:slow_slow(amount, duration, tween_method)
  amount = amount or 0.5
  duration = duration or 0.5
  tween_method = tween_method or math.cubic_in_out
  self.slow_amount = amount
  self:timer_tween(duration, self, {slow_amount = 1}, tween_method, function() self.slow_amount = 1 end, 'slow')
end

return slow
