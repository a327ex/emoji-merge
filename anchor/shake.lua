local __shake = class:class_new()
function __shake:new(amplitude, duration, frequency)
  self.amplitude = amplitude or 0
  self.duration = duration or 0
  self.frequency = frequency or 60
  self.samples = {}
  for i = 1, (self.duration/1000)*self.frequency do self.samples[i] = 2*math.random()-1 end
  self.ti = main.time*1000
  self.t = 0
  self.shaking = true
end

function __shake:get_noise(s)
  return self.samples[s] or 0
end

function __shake:get_decay(t)
  if t > self.duration then return end
  return (self.duration - t)/self.duration
end

function __shake:get_amplitude(t)
  if not t then
    if not self.shaking then return 0 end
    t = self.t
  end
  local s = (t/1000)*self.frequency
  local s0 = math.floor(s)
  local s1 = s0 + 1
  local k = self:get_decay(t)
  return self.amplitude*(self:get_noise(s0) + (s-s0)*(self:get_noise(s1) - self:get_noise(s0)))*k
end


local shake = class:class_new()
function shake:shake_init()
  self.shakes = {x = {}, y = {}}
  self.spring_shake_amount = vec2(0, 0)
  self.shake_shake_amount = vec2(0, 0)
  self.shake_amount = vec2(0, 0)
  self.last_shake_amount = vec2(0, 0)
  self.shake_springs = {x = spring(), y = spring()}
  table.insert(main.shake_objects, self)
  return self
end

-- Shakes the object with a certain intensity towards angle r using a spring mechanism
-- k and d are stiffness and damping spring values
-- self:spring_shake(10, math.pi/4) -> shakes the object with 10 intensity diagonally
function shake:shake_spring(intensity, r, k, d)
  self.shake_springs.x:spring_pull(-intensity*math.cos(r or 0), k, d)
  self.shake_springs.y:spring_pull(-intensity*math.sin(r or 0), k, d)
end

-- Shakes the object with a certain intensity for duration seconds and with the specified frequency
-- Higher frequency means jerkier movement, lower frequency means smoother movement
-- self:shake(10, 1, 120) -> shakes the object with 10 intensity for 1 second and 120 frequency
function shake:shake_shake(intensity, duration, frequency)
  table.insert(self.shakes.x, __shake(intensity, 1000*(duration or 0), frequency or 60))
  table.insert(self.shakes.y, __shake(intensity, 1000*(duration or 0), frequency or 60))
end

-- Call this and then use self.shake_amount.x/.y when drawing the object to apply the shake.
local xy = {'x', 'y'}
function shake:shake_update(dt)
  self.spring_shake_amount:vec2_set(0, 0)
  self.shake_shake_amount:vec2_set(0, 0)
  for _, z in ipairs(xy) do
    for i = #self.shakes[z], 1, -1 do
      local shake = self.shakes[z][i]
      shake.t = main.time*1000 - shake.ti
      if shake.t > shake.duration then
        shake.shaking = false
      end
      self.shake_shake_amount[z] = self.shake_shake_amount[z] + shake:get_amplitude()
      if not shake.shaking then
        table.remove(self.shakes[z], i)
      end
    end

    local spring = self.shake_springs[z]
    spring:spring_update(dt)
  end
  
  self.spring_shake_amount:vec2_add(self.shake_springs.x.x, self.shake_springs.y.x)
  self.shake_amount:vec2_sub(self.last_shake_amount)
  self.shake_amount:vec2_add(self.spring_shake_amount)
  self.shake_amount:vec2_add(self.shake_shake_amount)
  self.last_shake_amount:vec2_set(self.spring_shake_amount:vec2_add(self.shake_shake_amount))
end

return shake
