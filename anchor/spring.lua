-- See this article https://github.com/a327ex/blog/issues/60 for more details.
-- The arguments passed in are: the initial value of the spring, its stiffness and damping.
local spring = class:class_new()
function spring:spring_init(x, k, d)
  self.x = x or 0
  self.k = k or 100
  self.d = d or 10
  self.target_x = x or 0
  self.v = 0
  return self
end

function spring:spring_update(dt)
  local a = -self.k*(self.x - self.target_x) - self.d*self.v
  self.v = self.v + a*dt
  self.x = self.x + self.v*dt
end

-- Pull the spring with a certain amount of force. This force should be related to the initial value you set to the spring.
function spring:spring_pull(f, k, d)
  if k then self.k = k end
  if d then self.d = d end
  self.x = self.x + f
end

-- Animates the spring such that it reaches the target value in a smoothy springy motion.
-- Unlike pull, which tugs on the spring so that it bounces around the anchor, this changes that anchor itself.
function spring:spring_animate(x, k, d)
  if k then self.k = k end
  if d then self.d = d end
  self.target_x = x
end

return spring
