-- The collider mixin is an extension of a box2d body + fixture + shape. It works in conjunction with the physics_world mixin.
-- This should be used whenever there's a need for collision detection AND resolution, as well as more complex movement patterns (like steering behaviors).
--
-- In the past, there used to be a motion mixin, which separated movement functions from the collider's box2d functions, but now that's been merged here.
-- The idea there was something similar to the "arcade" module that exists in other engines like Phaser and HaxeFlixel, where it provides some basic collision and movement for simpler games that don't the full physics engine.
-- I didn't manage to get the API of that down properly + it was too slow for any heavier use case (see area mixin notes) so I scrapped it.
-- In the future when I do the swap that code should be done in C/C++ and should expose a similar API to what exists here in the collider mixin: collision/trigger events, set velocity/damping, apply forces/impulses, etc.
-- It should work such that the area mixin isn't needed anymore, and such that gameplay code can largely be the same whether it uses colliders with box2d or the arcade module alone.
-- For now, for objects that need simple movement then do that manually, for objects that need more complex movement but no collision make them ghost colliders, otherwise make them normal colliders.
-- UI objects should use the area mixin still because it makes no sense to have them as colliders, and for UI at least there will be no real performance issues.

-- physics_tag can be any of the tags used with :physics_world_set_collision_tags.
-- body_type can be either 'static', 'dynamic' or 'kinematic'.
-- shape_type and following attributes can be:
--   'rectangle', width, height
--   'line', x1, y1, x2, y2
--   'chain', loop, vertices
--   'polygon', vertices
--   'circle', radius
--   'triangle', width, height
local collider = class:class_new()
function collider:collider_init(physics_tag, body_type, shape_type, a, b, c, d)
  self.physics_tag = physics_tag
  self.body_type = body_type or 'dynamic'
  self.shape_type = shape_type

  if self.shape_type == 'rectangle' then
    self.w, self.h = a, b
    self.body = love.physics.newBody(main.world, self.x, self.y, self.body_type)
    self.shape = love.physics.newRectangleShape(self.w, self.h)
  elseif self.shape_type == 'line' then
    self.x1, self.y1, self.x2, self.y2 = a, b, c, d
    self.body = love.physics.newBody(main.world, 0, 0, self.body_type)
    self.shape = love.physics.newEdgeShape(self.x1, self.y1, self.x2, self.y2)
    self.body:setPosition(self.x or 0, self.y or 0)
  elseif self.shape_type == 'chain' then
    self.loop, self.vertices = a, b
    self.w, self.h = math.get_polygon_size(unpack(self.vertices))
    self.body = love.physics.newBody(main.world, 0, 0, self.body_type)
    self.shape = love.physics.newChainShape(self.loop, self.vertices)
    self.body:setPosition(self.x or 0, self.y or 0)
  elseif self.shape_type == 'polygon' then
    self.vertices = a
    self.w, self.h = math.get_polygon_size(unpack(self.vertices))
    self.body = love.physics.newBody(main.world, 0, 0, self.body_type)
    self.body:setPosition(self.x or 0, self.y or 0)
    self.shape = love.physics.newPolygonShape(self.vertices)
    self.body:setPosition(self.x or 0, self.y or 0)
  elseif self.shape_type == 'circle' then
    self.rs = a
    self.w, self.h = 2*self.rs, 2*self.rs
    self.body = love.physics.newBody(main.world, self.x, self.y, self.body_type)
    self.shape = love.physics.newCircleShape(self.rs)
  elseif self.shape_type == 'triangle' then
    self.w, self.h = a, b
    self.body = love.physics.newBody(main.world, 0, 0, self.body_type)
    local x1, y1 = self.h/2, 0
    local x2, y2 = -self.h/2, -self.w/2
    local x3, y3 = -self.h/2, self.w/2
    self.vertices = {x1, y1, x2, y2, x3, y3}
    self.shape = love.physics.newPolygonShape(self.vertices)
    self.body:setPosition(self.x, self.y)
  end

  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setUserData(self)
  self.fixture:setCategory(main.collision_tags[self.physics_tag].category)
  self.fixture:setMask(unpack(main.collision_tags[self.physics_tag].masks))
  self.sensor = love.physics.newFixture(self.body, self.shape)
  self.sensor:setUserData(self)
  self.sensor:setSensor(true)

  self.collision_enter = {}
  self.collision_active = {}
  self.collision_exit = {}
  self.trigger_enter = {}
  self.trigger_active = {}
  self.trigger_exit = {}
  table.insert(main.collider_objects, self)
  return self
end

function collider:collider_post_update(dt)
  self.collision_enter = {}
  self.collision_exit = {}
  self.trigger_enter = {}
  self.trigger_exit = {}
end

function collider:collider_draw(layer, color, line_width, z)
  if self.shape_type == 'rectangle' or self.shape_type == 'polygon' or self.shape_type == 'triangle' then
    layer:polygon({self.body:getWorldPoints(self.fixture:getShape():getPoints())}, color or colors.fg[0], line_width, z)
  elseif self.shape_type == 'edge' then
    layer:line(self.x + self.x1, self.y + self.y1, self.x + self.x2, self.y + self.y2, color or colors.fg[0], line_width, z)
  elseif self.shape_type == 'chain' then
    if self.loop then
      layer:polygon(self.vertices, color or colors.fg[0], line_width, z)
    else
      local points = {self.body:getWorldPoints(self.fixture:getShape():getPoints())}
      for i = 1, #points-2, 2 do
        layer:line(points[i], points[i+1], points[i+2], points[i+3], color or colors.fg[0], line_width, z)
        if self.loop and i == #points-2 then
          layer:line(points[i], points[i+1], points[1], points[2], color or colors.fg[0], line_width, z)
        end
      end
    end
  elseif self.shape_type == 'circle' then
    layer:circle(self.x, self.y, self.rs, color or colors.fg[0], line_width, z)
  end
end

-- Changes the collider's collision tag.
-- The target tag must be previously defined with :physics_world_set_collision_tags.
function collider:collider_set_collision_tag(tag)
  self.physics_tag = tag
  self.fixture:setCategory(main.collision_tags[self.physics_tag].category)
  self.fixture:setMask(unpack(main.collision_tags[self.physics_tag].masks))
end

-- Changes the collider's body type.
-- Possible values are: 'static', 'dynamic' and 'kinematic'.
function collider:collider_set_body_type(body_type)
  self.body:setType(body_type)
  if body_type == 'dynamic' then self.body:setAwake(true) end
end

-- This is called automatically whenever a .dead object is removed from its container.
-- If you're not using containers then you must call this manually whenever the object is killed, otherwise you'll leak memory.
function collider:collider_destroy()
  if self.body then
    if self.sensor then self.sensor:setUserData(nil) end
    if self.sensor and (self.sensor.type and self.sensor:type() == 'Fixture') then self.sensor:destroy() end
    self.fixture:setUserData(nil)
    self.fixture:destroy()
    self.body:destroy()
    self.body, self.shape, self.fixture, self.sensor = nil, nil, nil, nil
  end
  self.collision_enter = {}
  self.collision_active = {}
  self.collision_exit = {}
  self.trigger_enter = {}
  self.trigger_active = {}
  self.trigger_exit = {}
end

-- Returns the object's vertices as a table.
-- This is useful when you need to get the object's shape's exact positions in the world, like when you're drawing it.
function collider:collider_get_vertices()
  return {self.body:getWorldPoints(self.fixture:getShape():getPoints())}
end

-- Updates the .x, .y, .r attributes of this collider to match the physics body's.
-- Should generally be called at the start of an object's update function to update the object's position and rotation based on the results from the physics engine's update.
-- However, another common way to use colliders is to "lead" the physics engine body with your own object's variables for certain tasks and not for others, in which case you know better when to call this or not.
function collider:collider_update_position_and_angle()
  self.x, self.y = self.body:getPosition()
  self.r = self.body:getAngle()
end

-- Updates the .x, .y attributes of this collider to match the physics body's.
function collider:collider_update_position()
  self.x, self.y = self.body:getPosition()
end

-- Sets the collider's position directly, avoid using if you need velocity/acceleration calculations to make sense and be accurate, as teleporting the collider around messes up its physics.
-- self:collider_set_position(100, 100)
function collider:collider_set_position(x, y)
  self.body:setPosition(x, y)
end

-- Returns the object's position as two values.
-- x, y = self:collider_get_position()
function collider:collider_get_position()
  return self.body:getPosition()
end

-- Sets the collider as a bullet.
-- Bullets will collide and generate proper collision responses regardless of their velocity, despite being more expensive to calculate.
-- self:collider_set_bullet(true)
function collider:collider_set_bullet(v)
  self.body:setBullet(v)
end

-- Sets the collider to have fixed rotation.
-- When box2d objects don't have fixed rotation, whenever they collide with other objects they will rotate around depending on where the collision happened.
-- Setting this to true prevents that from happening, which is useful for every type of game where you don't need accurate physics responses in terms of the collider's rotation.
-- self:collider_set_fixed_rotation(true)
function collider:collider_set_fixed_rotation(v)
  self.body:setFixedRotation(v)
end

-- Sets the collider's velocity.
-- self:collider_set_velocity(100, 100)
function collider:collider_set_velocity(vx, vy)
  self.body:setLinearVelocity(vx, vy)
end

-- Gets the collider's velocity.
-- self:collider_get_velocity()
function collider:collider_get_velocity()
  return self.body:getLinearVelocity()
end

-- Sets the collider's damping.
-- The higher this value, the more the collider will resist movement and the faster it will stop moving after forces are applied to it.
-- self:collider_set_damping(10)
function collider:collider_set_damping(v)
  self.body:setLinearDamping(v)
end

-- Sets the collider's angular velocity.
-- If :collider_set_fixed_rotation is set to true then this will do nothing.
-- self:collider_set_angular_velocity(math.pi/4)
function collider:collider_set_angular_velocity(v)
  self.body:setAngularVelocity(v)
end

-- Sets the collider's angular damping.
-- The higher this value, the more the collider will resist rotation and the faster it will stop rotating after angular forces are applied to it.
-- self:collider_set_angular_damping(10)
function collider:collider_set_angular_damping(v)
  self.body:setAngularDamping(v) 
end

-- Returns the collider's angle.
-- r = self:collider_get_angle()
function collider:collider_get_angle()
  return self.body:getAngle()
end

-- Sets the collider's angle.
-- If :collider_set_fixed_rotation is set to true then this will do nothing.
-- self:collider_set_angle(math.pi/8)
function collider:collider_set_angle(v)
  self.body:setAngle(v)
end

-- Sets the collider's restitution.
-- This is a value from 0 to 1 and the higher it is the more energy the collider will conserve when bouncing off other objects.
-- At 1, it will bounce perfectly and not lose any velocity.
-- At 0, it will not bounce at all.
-- self:collider_set_restitution(0.75)
function collider:collider_set_restitution(v)
  self.fixture:setRestitution(v)
end

-- Sets the collider's friction.
-- This is a value from 0 to infinity, but generally between 0 and 1, the higher it is the more friction there will be when this collider slides with another.
-- At 0 friction is turned off and the object will slide with no resistance.
-- The friction calculation takes into account the friction of both colliders sliding on one another, so if one object has friction set to 0 then it will treat the interaction as if there's no friction.
-- self:collider_set_friction(1)
function collider:collider_set_friction(v)
  self.fixture:setFriction(v)
end

-- Applies a continuous amount of force to the collider.
-- self:collider_apply_force(100*math.cos(angle), 100*math.sin(angle))
function collider:collider_apply_force(fx, fy, x, y)
  self.body:applyForce(fx, fy, x or self.x, y or self.y)
end

-- Applies an instantaneous amount of force to the collider.
-- self:apply_impulse(100*math.cos(angle), 100*math.sin(angle))
function collider:collider_apply_impulse(fx, fy, x, y)
  if x and y then
    self.body:applyLinearImpulse(fx, fy, x, y)
  else
    self.body:applyLinearImpulse(fx, fy)
  end
end

-- Applies an instantaneous amount of angular force to the collider.
-- self:apply_angular_impulse(8*math.pi)
function collider:collider_apply_angular_impulse(f)
  self.body:applyAngularImpulse(f)
end

-- Applies torque to the collider.
-- self:collider_apply_torque(math.pi)
function collider:collider_apply_torque(t)
  self.body:applyTorque(t)
end

-- Returns the collider's mass.
-- self:collider_get_mass()
function collider:collider_get_mass()
  return self.body:getMass(mass)
end

-- Sets the collider's mass.
-- self:collider_set_mass(2)
function collider:collider_set_mass(mass)
  self.body:setMass(mass)
end

-- Sets the collider's gravity scale.
-- This is a simple multiplier on the world's gravity, but applied only to this collider
function collider:collider_set_gravity_scale(v)
  self.body:setGravityScale(v)
end

-- Sets if the collider is allowed to sleep or not.
-- self:collider_set_sleeping_allowed(false)
function collider:collider_set_sleeping_allowed(v)
  self.body:setSleepingAllowed(v)
end

-- Sets the collider to sleep or not.
-- self:collider_set_awake(false)
function collider:collider_set_awake(v)
  self.body:setAwake(v)
end

-- Locks the collider horizontally, meaning it can never move up or down.
-- Call this after calling other movement functions.
-- self:collider_lock_horizontally()
function collider:collider_lock_horizontally()
  local vx, vy = self.body:getLinearVelocity()
  self.body:setLinearVelocity(vx, 0)
end

-- Locks the collider vertically, meaning it can never move left or right.
-- Call this after calling other movement functions.
-- self:collider_lock_vertically()
function collider:collider_lock_vertically()
  local vx, vy = self.body:getLinearVelocity()
  self.body:setLinearVelocity(0, vy)
end

-- Moves this object towards another point.
-- You can either do this by using the speed argument directly, or by using the max_time argument.
-- max_time will override speed since it will make it so that the object reaches the target in a given time.
-- self:collider_move_towards_point(player.x, player.y, 40) -> moves towards the player with 40 speed
-- self:collider_move_towards_point(player.x, player.y, nil, 2) -> moves towards the player with speed such that it would reach him in 2 seconds if he never moved
function collider:collider_move_towards_point(x, y, speed, max_time)
  if max_time then speed = math.distance(self.x, self.y, x, y)/max_time end
  local r = math.angle_to_point(self.x, self.y, x, y)
  self:collider_set_velocity(speed*math.cos(r), speed*math.sin(r))
end

-- Same as :collider_move_towards_object and :collider_move_towards_point except towards the mouse.
-- self:collider_move_towards_mouse(nil, 1)
function collider:collider_move_towards_mouse(speed, max_time)
  if max_time then speed = math.distance_to_mouse(self.x, self.y)/max_time end
  local r = math.angle_to_mouse(self.x, self.y)
  self:collider_set_velocity(speed*math.cos(r), speed*math.sin(r))
end

-- Same as :collider_move_towards_point but does so only on the x axis.
-- self:collider_move_towards_point_horizontally(player.x, player.y, 40)
function collider:collider_move_towards_point_horizontally(x, y, speed, max_time)
  if max_time then speed = math.distance(self.x, self.y, x, y)/max_time end
  local r = math.angle_to_point(self.x, self.y, x, y)
  local vx, vy = self:collider_get_velocity()
  self:collider_set_velocity(speed*math.cos(r), vy)
end

-- Same as :collider_move_towards_point but does so only on the y axis.
-- self:collider_move_towards_point_vertically(player.x, player.y, 40)
function collider:collider_move_towards_point_vertically(x, y, speed, max_time)
  if max_time then speed = math.distance(self.x, self.y, x, y)/max_time end
  local r = math.angle_to_point(self.x, self.y, x, y)
  local vx, vy = self:collider_get_velocity()
  self:collider_set_velocity(vx, speed*math.sin(r))
end

-- Same as :collider_move_towards_mouse but does so only on the x axis.
-- self:collider_move_towards_mouse_horizontally(nil, 1)
function collider:collider_move_towards_mouse_horizontally(speed, max_time)
  if max_time then speed = math.distance_to_mouse(self.x, self.y)/max_time end
  local r = math.angle_to_mouse(self.x, self.y)
  local vx, vy = self:collider_get_velocity()
  self:collider_set_velocity(speed*math.cos(r), vy)
end

-- Same as :collider_move_towards_mouse but does so only on the y axis.
-- self:collider_move_towards_mouse_vertically(nil, 1)
function collider:collider_move_towards_mouse_vertically(speed, max_time)
  if max_time then speed = math.distance_to_mouse(self.x, self.y)/max_time end
  local r = math.angle_to_mouse(self.x, self.y)
  local vx, vy = self:collider_get_velocity()
  self:collider_set_velocity(vx, speed*math.sin(r))
end

-- Moves the object along an angle, most useful for simple projectiles that don't need any complex movement.
-- self:collider_move_along_angle(math.pi/4, 100)
function collider:collider_move_towards_angle(r, speed)
  self:collider_set_velocity(speed*math.cos(r), speed*math.sin(r))
end

-- Rotates the object towards another object using rotational lerp, which is a value from 0 to infinity.
-- Higher values will rotate the object faster, values of 1 will perform the rotation over 1 second, lower values will make the turn have a significant delay to it.
-- self:collider_rotate_towards_object(player, 0.2)
function collider:collider_rotate_towards_object(object, lerp_value)
  self:collider_set_angle(math.lerp_angle_dt(lerp_value, main.rate, self.r, math.angle_to_point(self.x, self.y, object.x, object.y)))
end

-- Rotates the object towards another point using rotational lerp, which is a value from 0 to infinity.
-- Higher values will rotate the object faster, values of 1 will perform the rotation over 1 second, lower values will make the turn have a significant delay to it.
-- self:collider_rotate_towards_point(player.x, player.y, 0.2)
function collider:collider_rotate_towards_point(x, y, lerp_value)
  self:collider_set_angle(math.lerp_angle_dt(lerp_value, main.rate, self.r, math.angle_to_point(self.x, self.y, x, y)))
end

-- Same as :collider_rotate_towards_point except towards the mouse.
-- self:collider_rotate_towards_mouse(0.2)
function collider:collider_rotate_towards_mouse(lerp_value)
  self:collider_set_angle(math.lerp_angle_dt(lerp_value, main.rate, self.r, math.angle_to_mouse(self.x, self.y)))
end

-- Rotates the object towards its own velocity vector using a rotational lerp, which is a value from 0 to infinity.
-- Higher values will rotate the object faster, values of 1 will perform the rotation over 1 second, lower values will make the turn have a significant delay to it.
-- self:collider_rotate_towards_velocity(0.2)
function collider:collider_rotate_towards_velocity(lerp_value)
  local vx, vy = self:collider_get_velocity()
  self:collider_set_angle(math.lerp_angle_dt(lerp_value, main.rate, self.r, math.angle_to_point(self.x, self.y, self.x + vx, self.y + vy)))
end

-- Accelerates the object towards the given angle at the given maximum speed.
-- self:collider_accelerate_towards_angle(math.pi/4, 1000, 250) -> accelerates towards math.pi/4 with acceleration of 1000 units/s and max speed of 250 units/s
function collider:collider_accelerate_towards_angle(r, a, max_speed)
  self:collider_apply_force(a*math.cos(r), a*math.sin(r))
  local vx, vy = self:collider_get_velocity()
  self:collider_set_velocity(math.clamp(vx, -max_speed, max_speed), math.clamp(vy, -max_speed, max_speed))
end

-- Accelerates the object towards the point at the given maximum speed.
-- self:accelerate_towards_point(player.x, player.y, 1000, 250)
function collider:collider_accelerate_towards_point(x, y, a, max_speed)
  local r = math.angle_to_point(self.x, self.y, x, y)
  self:collider_accelerate_towards_angle(r, a, max_speed)
end

-- Same as :collider_accelerate_towards_point except towards the mouse.
-- self:accelerate_towards_mouse(1000, 250)
function collider:collider_accelerate_towards_mouse(a, max_speed)
  local r = math.angle_to_mouse(self.x, self.y)
  self:collider_accelerate_towards_angle(r, a, max_speed)
end

-- Same as :collider_accelerate_towards_point except towards an object.
-- self:accelerate_towards_mouse(player, 1000, 250)
function collider:collider_accelerate_towards_object(object, a, max_speed)
  local r = math.angle_to_point(self.x, self.y, object.x, object.y)
  self:collider_accelerate_towards_angle(r, a, max_speed)
end

-- Seeking steering behavior.
-- Returns the force/acceleration to be applied to the object.
-- sx, sy = self:collider_seek(player.x, player.y, 200, 1000)
function collider:collider_seek(x, y, max_speed, max_force)
  local dx, dy = x - self.x, y - self.y
  dx, dy = math.normalize(dx, dy)
  dx, dy = dx*max_speed, dy*max_speed
  local vx, vy = self:collider_get_velocity()
  dx, dy = dx - vx, dy - vy
  dx, dy = math.limit(dx, dy, max_force or 1000)
  return dx, dy
end

-- Arrive steering behavior, stops accelerating when within radius rs.
-- Returns the force/acceleration to be applied to the object.
-- ax, ay = self:collider_arrive(player.x, player.y, 50, 200, 1000)
function collider:collider_arrive(x, y, rs, max_speed, max_force)
  local dx, dy = x - self.x, y - self.y
  local d = math.length(dx, dy)
  dx, dy = math.normalize(dx, dy)
  if d < rs then
    dx, dy = dx*math.remap(d, 0, rs, 0, max_speed), dy*math.remap(d, 0, rs, 0, max_speed)
  else
    dx, dy = dx*max_speed, dy*max_speed
  end
  local vx, vy = self:collider_get_velocity()
  dx, dy = dx - vx, dy - vy
  dx, dy = math.limit(dx, dy, max_force or 1000)
  return dx, dy
end

-- Wander steering behavior.
-- Returns the force/acceleration to be applied to the object.
-- wx, wy = self:collider_wander(50, 50, 20, 200, 1000)
function collider:collider_wander(d, rs, jitter, max_speed, max_force)
  local cx, cy = self:collider_get_velocity()
  cx, cy = math.normalize(cx, cy)
  cx, cy = self.x + cx*d, self.y + cy*d
  if not self.wander_r then self.wander_r = 0 end
  self.wander_r = self.wander_r + main:random_float(-jitter, jitter)
  return self:collider_seek(cx + rs*math.cos(self.wander_r), cy + rs*math.sin(self.wander_r), max_speed, max_force or 1000)
end

-- Separates this object from others if they're inside the circle of radius rs.
-- Returns the force/acceleration to be applied to the object.
-- sx, sy = self:collider_separate(50, enemies)
function collider:collider_separate(rs, others, max_speed, max_force)
  local dx, dy, number_of_separators = 0, 0, 0
  for _, object in ipairs(others) do
    if object.id ~= self.id and math.distance(object.x, object.y, self.x, self.y) < rs then
      local tx, ty = self.x - object.x, self.y - object.y
      local nx, ny = math.normalize(tx, ty)
      local l = math.length(nx, ny)
      dx = dx + rs*(nx/l)
      dy = dy + rs*(ny/l)
      number_of_separators = number_of_separators + 1
    end
  end
  if number_of_separators > 0 then dx, dy = dx/number_of_separators, dy/number_of_separators end
  if math.length(dx, dy) > 0 then
    dx, dy = math.normalize(dx, dy)
    dx, dy = dx*max_speed, dy*max_speed
    vx, vy = self:collider_get_velocity()
    dx, dy = dx - vx, dy - vy
    dx, dy = math.limit(dx, dy, max_force or 1000)
  end
  return dx, dy
end

-- Aligns this object with others if they're inside the circle of radius rs.
-- Returns the force/acceleration to be applied to the object.
-- ax, ay = self:collider_align(50, enemies)
function collider:collider_align(rs, others, max_speed, max_force)
  local dx, dy, number_of_aligners = 0, 0, 0
  for _, object in ipairs(others) do
    if object.id ~= self.id and math.distance(object.x, object.y, self.x, self.y) < rs then
      local vx, vy = self:collider_get_velocity()
      dx, dy = dx + vx, dy + vy
      number_of_aligners = number_of_aligners + 1
    end
  end
  if number_of_aligners > 0 then dx, dy = dx/number_of_aligners, dy/number_of_aligners end
  if math.length(dx, dy) > 0 then
    dx, dy = math.normalize(dx, dy)
    dx, dy = dx*max_speed, dy*max_speed
    vx, vy = self:collider_get_velocity()
    dx, dy = dx - vx, dy - vy
    dx, dy = math.limit(dx, dy, max_force or 1000)
    return dx, dy
  else
    return 0, 0
  end
end

-- Makes this object stick with others if they're inside the circle of radius rs.
-- Returns the force/acceleration to be applied to the object.
-- cx, cy = self:collider_cohesion(50, enemies)
function collider:collider_cohesion(rs, others, max_speed, max_force)
  local dx, dy, number_of_objects = 0, 0, 0
  for _, object in ipairs(others) do
    if object.id ~= self.id and math.distance(object.x, object.y, self.x, self.y) < rs then
      dx, dy = dx + object.x, dy + object.y
      number_of_objects = number_of_objects + 1
    end
  end
  if number_of_objects > 0 then
    dx, dy = dx/number_of_objects, dy/number_of_objects
    return self:collider_seek(dx, dy, max_speed, max_force)
  else
    return 0, 0
  end
end

-- Prevents the object from going below position y, it will be pushed out of it.
-- Returns the force/acceleration to be applied to the object.
-- dx, dy = self:collider_do_not_go_below(game.h/2)
function collider:collider_do_not_go_below(y)
  local dx, dy = 0, 0
  if self.y > y then
    local ty = self.y - y
    local nx, ny = math.normalize(0, ty)
    local l = math.length(nx, ny)
    dx, dy = 0, -ty*(ny/l)
  end
  return dx, dy
end

return collider
