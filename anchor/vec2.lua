local EPSILON = 1e-6
local EPSILON_SQUARED = EPSILON*EPSILON
local vec2 = class:class_new()
function vec2:vec2_init(x, y)
  self.x, self.y = x or 0, y or 0
  return self
end

function vec2:vec2_clone()
  return anchor('vec2'):vec2_init(self.x, self.y)
end

function vec2:__tostring()
  return ("(%.2f, %.2f)"):format(self.x, self.y)
end

function vec2:vec2_equals(v)
  return math.abs(self.x - v.x) <= EPSILON and math.abs(self.y - v.y) <= EPSILON
end

function vec2:vec2_not_equals(v)
  return math.abs(self.x - v.x) > EPSILON or math.abs(a.y - v.y) > EPSILON
end

function vec2:vec2_set(x, y)
  if not y then
    self.x = x.x
    self.y = x.y
  else
    self.x = x
    self.y = y
  end
  return self
end

function vec2:vec2_add(x, y)
  if not y then
    self.x = self.x + x.x
    self.y = self.y + x.y
  else
    self.x = self.x + x
    self.y = self.y + y
  end
  return self
end

function vec2:vec2_sub(x, y)
  if not y then
    self.x = self.x - x.x
    self.y = self.y - x.y
  else
    self.x = self.x - x
    self.y = self.y - y
  end
  return self
end

function vec2:vec2_mul(s)
  if type(s) == "table" then
    self.x = self.x*s.x
    self.y = self.y*s.y
  else
    self.x = self.x*s
    self.y = self.y*s
  end
  return self
end

function vec2:vec2_div(s)
  if type(s) == "table" then
    self.x = self.x*s.x
    self.y = self.y*s.y
  else
    self.x = self.x/s
    self.y = self.y/s
  end
  return self
end

function vec2:vec2_scale(k)
  self.x = self.x*k
  self.y = self.y*k
  return self
end

function vec2:vec2_rotate(r)
  local cos = math.cos(r)
  local sin = math.sin(r)
  local ox = self.x
  local oy = self.y
  self.x = cos*ox - sin*oy
  self.y = sin*ox + cos*oy
  return self
end

function vec2:vec2_rotate_around(r, p)
  self:vec2_sub(p)
  self:vec2_rotate(r)
  self:vec2_add(p)
  return self
end

function vec2:vec2_floor()
  self.x = math.floor(self.x)
  self.y = math.floor(self.y)
  return self
end

function vec2:vec2_ceil()
  self.x = math.ceil(self.x)
  self.y = math.ceil(self.y)
  return self
end

function vec2:vec2_round(p)
  self.x = math.round(self.x, p)
  self.y = math.round(self.y, p)
  return self
end

function vec2:vec2_dot(v)
  return self.x*v.x + self.y*v.y
end

function vec2:vec2_is_perpendicular(v)
  return math.abs(self:vec2_dot(v)) < EPSILON_SQUARED
end

function vec2:vec2_cross(v)
  return self.x*v.y - self.y*v.x
end

function vec2:vec2_is_parallel(v)
  return math.abs(self:vec2_cross(v)) < EPSILON_SQUARED
end

function vec2:vec2_is_zero()
  return math.abs(self.x) < EPSILON and math.abs(self.y) < EPSILON
end

function vec2:vec2_zero()
  self.x = 0
  self.y = 0
  return self
end

function vec2:vec2_length()
  return math.sqrt(self.x*self.x + self.y*self.y)
end

function vec2:vec2_length_squared()
  return self.x*self.x + self.y*self.y
end

function vec2:vec2_normalize()
  if self:vec2_is_zero() then return self end
  return self:vec2_scale(1/self:vec2_length())
end

function vec2:vec2_invert()
  self.x = self.x*-1
  self.y = self.y*-1
  return self
end

function vec2:vec2_limit(max)
  local s = max*max/self:vec2_length_squared()
  s = (s > 1 and 1) or math.sqrt(s)
  self.x = self.x*s
  self.y = self.y*s
  return self
end

function vec2:vec2_angle_to(v)
  return math.atan2(v.y - self.y, v.x - self.x)
end

function vec2:vec2_angle_difference(v)
  return an:math_angle_difference(self:vec2_angle(), v:vec2_angle())
end

function vec2:vec2_angle()
  return math.atan2(self.y, self.x)
end

function vec2:vec2_distance_squared(v)
  local dx = v.x - self.x
  local dy = v.y - self.y
  return dx*dx + dy*dy
end

function vec2:vec2_distance(v)
  return math.sqrt(self:vec2_distance_squared(v))
end

function vec2:vec2_bounce(normal, bounce_coefficient)
  local d = (1 + (bounce_coefficient or 1))*self:vec2_dot(normal)
  self.x = self.x - d*normal.x
  self.y = self.y - d*normal.y
  return self
end

return vec2
