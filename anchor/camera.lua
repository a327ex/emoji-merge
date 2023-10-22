-- This mixins handles drawing of the game world through a viewport and the functions needed to make that happen.
-- The arguments passed in are:
-- x, y - the camera's position in world coordinates, the camera is always centered around its x, y coordinates
-- w, h - the camera's size, generally this should be main.w, main.h
local camera = class:class_new()
function camera:camera_init(x, y, w, h)
  self.x, self.y = x or 0, y or 0
  self.r, self.sx, self.sy = 0, 1, 1
  self.w, self.h = w or main.w, h or main.h
  self.parallax_base_pos = vec2(0, 0)
  self.mouse = vec2(0, 0)
  self.last_mouse = vec2(0, 0)
  self.mouse_dt = vec2(0, 0)
  self.impulse = vec2(0, 0)
  self.impulse_damping = 0.9
  return self
end

-- Attaches the camera, meaning all further draw operations will be affected by its transform.
-- Accepts two values that go from 0 to 1 that represent how much parallaxing there should be for the next operations.
-- A value of 1 means no parallaxing, meaning the elements drawn will move at the same rate as all other elements, while a value of 0 means maximum parallaxing, which means the elements won't move at all.
function camera:camera_attach(parallax_x, parallax_y)
  self.parallax_base_pos:vec2_set(self.x, self.y)
  self.x = self.parallax_base_pos.x*(parallax_x or 1)
  self.y = self.parallax_base_pos.y*(parallax_y or parallax_x or 1)
  local shake_x, shake_y = 0, 0
  if self.shake_amount then shake_x, shake_y = self.shake_amount.x, self.shake_amount.y end
  self.x, self.y = self.x + shake_x, self.y + shake_y
  love.graphics.push()
  love.graphics.translate(self.w/2, self.h/2)
  love.graphics.scale(self.sx, self.sy)
  love.graphics.rotate(self.r)
  love.graphics.translate(-self.x, -self.y)
end

-- Detaches the camera, meaning all further draw operations won't be affected by its transform.
function camera:camera_detach()
  love.graphics.pop()
  self.x, self.y = self.parallax_base_pos.x, self.parallax_base_pos.y
end

-- Returns the values passed in in world coordinates. This is useful when transforming things from screen space to world space, like when the mouse clicks on something.
-- If you look at camera:get_mouse_position you'll see that it uses this function on the values returned by love.mouse.getPosition (which return values in screen coordinates).
-- :camera_get_world_coords(love.mouse.getPosition())
function camera:camera_get_world_coords(x, y)
  x, y = x/main.sx, y/main.sy
  x, y = x - self.x, y - self.y
  x, y = x*math.cos(-self.r) - y*math.sin(-self.r), x*math.sin(-self.r) + y*math.cos(-self.r)
  x, y = x/self.sx, y/self.sy
  x, y = x + self.x, y + self.y
  x, y = x + (self.x - self.w/2)/self.sx, y + (self.y - self.h/2)/self.sy
  return x, y
end

-- Returns the values passed in in local coordinates. This is useful when transforming things from world space to screen space, like when displaying UI according to the position of game objects.
-- x, y = :camera_get_local_coords(player.x, player.y)
function camera:camera_get_local_coords(x, y)
  x, y = x - self.x, y - self.y
  x, y = x*math.cos(self.r) - y*math.sin(self.r), x*math.sin(self.r) + y*math.cos(self.r)
  return x*self.sx + self.w/2, y*self.sy + self.h/2
end

-- Returns the mouse's position in world coordinates
-- x, y = :camera_get_mouse_position()
function camera:camera_get_mouse_position()
  return self:camera_get_world_coords(love.mouse.getPosition())
end

function camera:camera_update(dt)
  self.mouse.x, self.mouse.y = self:camera_get_mouse_position()
  self.mouse_dt.x, self.mouse_dt.y = self.mouse.x - self.last_mouse.x, self.mouse.y - self.last_mouse.y

  self.x, self.y = math.position_damping(self.x, self.y, self.impulse.x, self.impulse.x, self.impulse_damping, dt)
  self.impulse:vec2_set(math.velocity_damping(self.impulse.x, self.impulse.y, self.impulse_damping, dt))
  self.last_mouse.x, self.last_mouse.y = self.mouse.x, self.mouse.y
  self:camera_rotate_to(self.r)
end

-- Returns the angle from a point to the mouse
-- x, y = :camera_angle_to_mouse(point.x, point.y)
function camera:camera_angle_to_mouse(x, y)
  local mx, my = self:camera_get_mouse_position()
  return math.angle_to(x, y, mx, my)
end

-- Moves the camera by the given amount
-- :camera_move(10, 10)
function camera:camera_move(dx, dy)
  self.x, self.y = self.x + dx, self.y + dy
end

-- Moves the camera to the given position
-- :camera_move_to(10, 10)
function camera:camera_move_to(x, y)
  self.x, self.y = x, y
end

-- Rotates the camera by the given amount
-- :camera_rotate(math.pi/2) -> rotates by math.pi/2 from the current angle
function camera:camera_rotate(r)
  self.r = self.r + r
end

-- Rotates the camera to the given angle
-- :camera_rotate_to(math.pi/2) -> rotates to math.pi/2 regardless of current angle
function camera:camera_rotate_to(r)
  self.r = r
end

-- Zooms the camera by the given amount
-- :camera_zoom(2) -> zooms the camera in by 2x from the current zoom level
function camera:camera_zoom(sx, sy)
  self.sx, self.sy = self.sx*(sx or 1), self.sy*(sy or sx or 1)
end

-- Zooms the camera to the given scale
-- :camera_zoom(2) -> zooms the camera to 2x zoom regardless of current zoom level
function camera:camera_zoom_to(sx, sy)
  self.sx, self.sy = (sx or 1), (sy or sx or 1)
end

-- Applies an impulse to the camera with force f and towards angle r
-- This movement stops over time according to the damping value, which is 0.9 by default; the closer to 0 the faster it stops
-- Because this is an impulse, you should only call it once, if you call this every frame the camera will just fly off into infinity
-- :camera_apply_impulse(100, math.pi/2) -> impulses the camera downwards force 100
function camera:camera_apply_impulse(f, r, damping)
  self.impulse_damping = damping or 0.9
  self.impulse:vec2_add(f*math.cos(r), f*math.sin(r))
end

return camera
