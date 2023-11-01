-- Whenever an object is interacted with it's a good idea to either pull on a spring attached to its scale, or to flash it to signal that the interaction went through.
-- This is a combination of both springs and flashes put together to create that effect.
local hitfx = class:class_new()
function hitfx:hitfx_init()
  self.springs = {}
  self.flashes = {}
  self:hitfx_add('main', 1, nil, nil, 0.15)
  table.insert(main.hitfx_objects, self)
  return self
end

function hitfx:hitfx_update(dt)
  if not self.hitfx_recently then return end
  if main.time - self.hitfx_recently > self.hitfx_duration then self.hitfx_recently = nil end
  for _, spring in pairs(self.springs) do spring:spring_update(dt) end
  for _, flash in pairs(self.flashes) do flash:flash_update(dt) end
end

-- Sets a new hit effect with the given name and with the given variables.
-- x, k and d correspond to spring struct variables, while flash_duration corresponds to how long the flash should last for in seconds.
-- self:hitfx_add('hit', 1, nil, nil, 0.15)
-- To get the spring's or flashes' value you would access it through self.hitfx.springs.hit.x or self.hitfx.flashes.hit.f. 
-- .x is the spring value, while .f is a boolean that says if it's currently flashing or not.
function hitfx:hitfx_add(name, x, k, d, flash_duration)
  self.springs[name] = spring(x, k, d)
  self.flashes[name] = flash(flash_duration)
end

-- Uses both the spring and flash effect, or either one of them alone depending on the arguments passed.
-- self:hitfx_add must have been called first with the given effect name.
-- self:hitfx_use('hit', 2, nil, nil, 0.3)
function hitfx:hitfx_use(name, x, k, d, flash_duration)
  self.hitfx_recently = main.time
  self.hitfx_duration = 4
  if x or k or d then self.springs[name]:spring_pull(x, k, d) end
  if flash_duration then self.flashes[name]:flash_flash(flash_duration) end
end

-- Returns the elapsed time of a given flash as a number between 0 and 1.
-- Useful if you need to know where you currently are in the duration of a flash call.
function hitfx:hitfx_get_flash_elapsed_time(name)
  if not self.flashes[name] then return end
  if self.flashes[name].x then return self.flashes[name].timer/self.flashes[name].duration
  else return 0 end
end

return hitfx
