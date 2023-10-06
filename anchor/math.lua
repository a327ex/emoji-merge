-- Checks if a point is colliding with a line.
-- math.point_line(0, 0, 0, 0, 2, 2) -> true
-- math.point_line(1, 1, 4, 5, 6, 6) -> false
function math.point_line(px, py, x1, y1, x2, y2)
  return mlib.segment.checkPoint(px, py, x1, y1, x2, y2)
end

-- Checks if a point is colliding with a circle.
-- math.point_circle(0, 0, 0, 0, 2) -> true
-- math.point_circle(-2, 0, 0, 0, 2) -> true
-- math.point_circle(10, 10, 0, 0, 2) -> false
function math.point_circle(px, py, cx, cy, rs)
  return mlib.circle.checkPoint(px, py, cx, cy, rs)
end

-- Checks if a point is colliding with a polygon.
-- math.point_polygon(0, 0, -1, -1, 1, -1, 0, 2) -> true
-- math.point_polygon(10, 10, -1, -1, 1, -1, 0, 2) -> false
-- math.point_polygon(-1, -1, -1, -1, 1, -1, 0, 2) -> true
function math.point_polygon(px, py, ...)
  if mlib.polygon.checkPoint(px, py, ...) then return true end
  local vertices = {...}
  for i = 1, #vertices, 2 do
    local x1, y1 = vertices[i], vertices[i+1]
    local x2, y2 = vertices[i+2], vertices[i+3]
    if not x2 and not y2 then x2, y2 = vertices[1], vertices[2] end
    if math.point_line(px, py, x1, y1, x2, y2) then
      return true
    end
  end
  return false
end

-- Checks if two lines are colliding.
-- math.line_line(0, 0, 2, 2, 0, 2, 2, 0) -> true
-- math.line_line(0, 0, 2, 2, 0, 0, 2, 2) -> true
-- math.line_line(0, 0, 2, 2, 10, 10, 12, 12) -> false
function math.line_line(x1, y1, x2, y2, x3, y3, x4, y4)
  local a, b, c, d = mlib.segment.getIntersection(x1, y1, x2, y2, x3, y3, x4, y4)
  if a and b then return a, b end
  return false
end

-- Checks if a line is colliding with a circle.
-- math.line_circle(0, 0, 2, 0, 2, 0, 1) -> true
-- math.line_circle(0, 0, 2, 0, 4, 0, 2) -> true
-- math.line_circle(0, 0, 2, 0, 8, 0, 2) -> false
function math.line_circle(x1, y1, x2, y2, px, py, rs)
  local a = mlib.circle.getSegmentIntersection(px, py, rs, x1, y1, x2, y2)
  if a then return true end
  return false
end

-- Checks if a line is colliding with a polygon.
-- math.line_polygon(-10, 0, -4, 0, -4, -4, 4, -4, 4, 4, -4, 4)
-- math.line_polygon(-10, 0, 10, 0, -4, -4, 4, -4, 4, 4, -4, 4)
-- math.line_polygon(0, 0, 2, 0, -4, -4, 4, -4, 4, 4, -4, 4)
-- math.line_polygon(10, 0, 20, 0, -4, -4, 4, -4, 4, 4, -4, 4)
function math.line_polygon(x1, y1, x2, y2, ...)
  return mlib.polygon.isSegmentInside(x1, y1, x2, y2, ...)
end

-- Checks if two circles are colliding.
-- math.circle_circle(0, 0, 2, 1, 0, 2) -> true
-- math.circle_circle(0, 0, 2, 0, 0, 1) -> true
-- math.circle_circle(0, 0, 2, 4, 0, 2) -> true
-- math.circle_circle(0, 0, 2, 8, 0, 2) -> false
function math.circle_circle(x1, y1, rs1, x2, y2, rs2)
  local intersections = mlib.circle.getCircleIntersection(x1, y1, rs1, x2, y2, rs2) 
  if intersections then return true end
  if mlib.circle.isCircleCompletelyInside(x1, y1, rs1, x2, y2, rs2) then return true end
  if mlib.circle.isCircleCompletelyInside(x2, y2, rs2, x1, y1, rs1) then return true end
  return false
end

-- Checks if a circle is colliding with a polygon.
-- math.circle_polygon(2, 2, 1, -4, -4, 4, -4, 4, 4, -4, 4) -> true
-- math.circle_polygon(2, 2, 10, -4, -4, 4, -4, 4, 4, -4, 4) -> true
-- math.circle_polygon(0, 0, 2, 2, 0, 3, -1, 3, 1) -> true
-- math.circle_polygon(0, 0, 1, 2, 0, 3, -1, 3, 1) -> false
function math.circle_polygon(px, py, rs, ...)
  local intersections = mlib.polygon.getCircleIntersection(px, py, rs, ...)
  if type(intersections) == 'table' then return true end
  if mlib.polygon.isCircleInside(px, py, rs, ...) then return true end
  if mlib.circle.isPolygonCompletelyInside(px, py, rs, ...) then return true end
  return false
end

-- Checks if two polygons are colliding.
-- math.polygon_polygon({0, 0, 1, -1, 1, 0}, {1, 0, 4, -1, 4, 0})) -> true
-- math.polygon_polygon({0, 0, 1, -1, 1, 0}, {4, 0, 4, -1, 5, 0})) -> false
-- math.polygon_polygon({-4, -4, 4, -4, 4, 4, -4, 4}, {-2, -2, 2, -2, 2, 2, -2, 2})) -> true
function math.polygon_polygon(p1, p2)
  local intersections = mlib.polygon.getPolygonIntersection(p1, p2)
  if type(intersections) == 'table' then return true end
  if mlib.polygon.isPolygonInside(p1, p2) then return true end
  if mlib.polygon.isPolygonInside(p2, p1) then return true end
  return false
end

-- Generates points in the area centered around x, y with size w, h, with each point having a minimum distance of rs from each other.
-- Based on https://www.youtube.com/watch?v=7WcmyxyFO7o
-- math.generate_poisson_disc_sampled_points(10, gw/2, gh/2, 100, 100) -> generates however many points fit into a 100, 100 area centered on gw/2, gh/2 that are separated by 10 units between each other
function math.generate_poisson_disc_sampled_points(rs, x, y, w, h)
  local cell_size = rs/math.sqrt(2)
  local grid = grid(math.floor(w/cell_size), math.floor(h/cell_size), 0)
  local points = {}
  local spawn_points = {}

  local is_valid = function(x, y)
    if x >= 0 and x <= w and y >= 0 and y <= h then
      local cx, cy = math.floor(x/cell_size), math.floor(y/cell_size)
      local sx1, sx2 = math.max(1, cx - 2), math.min(cx + 2, grid.w)
      local sy1, sy2 = math.max(1, cy - 2), math.min(cy + 2, grid.h) 
      for i = sx1, sx2 do
        for j = sy1, sy2 do
          local point_index = grid:grid_get(i, j)
          if point_index ~= 0 then
            local d = math.distance(x, y, points[point_index].x, points[point_index].y) 
            if d < rs then
              return false
            end
          end
        end
      end
      return true
    end
    return false
  end

  table.insert(spawn_points, {main:random_float(0, w), main:random_float(0, h)})
  while #spawn_points > 0 do
    local spawn_index = main:random_int(1, #spawn_points)
    local spawn_center = spawn_points[spawn_index]
    local accepted = false
    for i = 1, 30 do
      local r = main:random_angle()
      local d = main:random_float(rs, 2*rs)
      local cx, cy = spawn_center[1] + d*math.cos(r), spawn_center[2] + d*math.sin(r)
      if is_valid(cx, cy) and grid:grid_get(math.floor(cx/cell_size), math.floor(cy/cell_size)) == 0 then
        table.insert(points, vec2(cx, cy))
        table.insert(spawn_points, {cx, cy})
        grid:grid_set(math.floor(cx/cell_size), math.floor(cy/cell_size), #points)
        accepted = true
        break
      end
    end
    if not accepted then
      table.remove(spawn_points, spawn_index)
    end
  end

  for _, point in ipairs(points) do
    point.x = point.x + (x - w/2) - rs/3
    point.y = point.y + (y - h/2) - rs/3
  end
  return points
end

-- Generates bezier curves that pass through the provided points.
-- Based on https://love2d.org/forums/viewtopic.php?p=228432#p228432. Tension, continuity and bias are explained in the wiki page for Kochanek Bartels, default vaules are 0, 0, 0.
-- math.generate_curves({0, 0, 10, 10, 5, 5, 20, 15}) -> returns 3 bezier curves in a table, one for each segment between two points
function math.generate_curves(points, tension, continuity, bias)
  local function kochanek_bartels(x1, y1, x2, y2, x3, y3, x4, y4, t, c, b)
    local t, c, b = t or 0, c or 0, b or 0
    local _x1 = x2
    local _y1 = y2
    local _x2 = x2 + ((1-t)*(1+b)*(1+c)*(x2-x1) + (1-t)*(1-b)*(1-c)*(x3-x2))/6
    local _y2 = y2 + ((1-t)*(1+b)*(1+c)*(y2-y1) + (1-t)*(1-b)*(1-c)*(y3-y2))/6
    local _x3 = x3 - ((1-t)*(1+b)*(1-c)*(x3-x2) + (1-t)*(1-b)*(1+c)*(x4-x3))/6
    local _y3 = y3 - ((1-t)*(1+b)*(1-c)*(y3-y2) + (1-t)*(1-b)*(1+c)*(y4-y3))/6
    local _x4 = x3
    local _y4 = y3

    local curve = love.math.newBezierCurve(0, 0, 0, 0, 0, 0, 0, 0)
    curve:setControlPoint(1, _x1, _y1)
    curve:setControlPoint(2, _x2, _y2)
    curve:setControlPoint(3, _x3, _y3)
    curve:setControlPoint(4, _x4, _y4)
    return curve
  end

  if #points/2 >= 3 then
    local curves = {}
    table.insert(curves, kochanek_bartels(points[1], points[2], points[1], points[2], points[3], points[4], points[5], points[6], tension, continuity, bias))
    for i = 2, #points/2-2 do
      local j = i*2-1
      table.insert(curves, kochanek_bartels(points[j-2], points[j-1], points[j], points[j+1], points[j+2], points[j+3], points[j+4], points[j+5], tension, continuity, bias))
    end
    local n = #points
    table.insert(curves, kochanek_bartels(points[n-5], points[n-4], points[n-3], points[n-2], points[n-1], points[n], points[n-1], points[n], tension, continuity, bias))
    return curves
  elseif #points/2 <= 2 then
    error('math.generate_curves needs at least 3 points, if you have two points you can use a simple line instead.')
  end
end

-- Returns the polygon's width and height.
-- math.get_polygon_size(...) -> the width and height of the polygon (its bounding box)
function math.get_polygon_size(...)
  local min_x, min_y, max_x, max_y = 1000000, 1000000, -1000000, -1000000
  local vertices = {...}
  for i = 1, #vertices, 2 do
    if vertices[i] < min_x then min_x = vertices[i] end
    if vertices[i] > max_x then max_x = vertices[i] end
    if vertices[i+1] < min_y then min_y = vertices[i+1] end
    if vertices[i+1] > max_y then max_y = vertices[i+1] end
  end
  local x1, y1, x2, y2 = min_x, min_y, max_x, max_y
  return max_x - min_x, max_y - min_y
end

-- Returns the 2D coordinates of a given index with a grid of a given width
-- math.index_to_coordinates(11, 10) -> 1, 2
-- math.index_to_coordinates(2, 4) -> 2, 1
-- math.index_to_coordinates(17, 7) -> 3, 3
-- math.index_to_coordinates(17, 4) -> 1, 5
-- math.index_to_coordinates(4, 4) -> 4, 1
function math.index_to_coordinates(n, w)
  local i, j = n % w, math.ceil(n/w)
  if i == 0 then i = w end
  return i, j
end

-- Returns the 1D index of the given 2D coordinates with a grid of a given width
-- math.coordinates_to_index(1, 2, 10) -> 11
-- math.coordinates_to_index(2, 1, 4) -> 2
-- math.coordinates_to_index(3, 3, 7) -> 17
-- math.coordinates_to_index(1, 5, 4) -> 17
-- math.coordinates_to_index(4, 1, 4) -> 4
function math.coordinates_to_index(i, j, w)
  return i + (j-1)*w
end

-- Returns rectangle vertices based on top-left and bottom-right coordinates
-- math.to_rectangle_vertices(0, 0, 40, 40) -> vertices for a rectangle centered on 20, 20
function math.to_rectangle_vertices(x1, y1, x2, y2)
  return {x1, y1, x2, y1, x2, y2, x1, y2}
end

-- Rotates the point by r radians with ox, oy as pivot.
-- x, y = math.rotate_point(player.x, player.y, math.pi/4)
function math.rotate_point(x, y, r, ox, oy)
  return x*math.cos(r) - y*math.sin(r) + ox - ox*math.cos(r) + oy*math.sin(r), x*math.sin(r) + y*math.cos(r) + oy - oy*math.cos(r) - ox*math.sin(r)
end

-- Scales the point by sx, sy with ox, oy as pivot.
-- x, y = math.scale_point(player.x, player.y, 2, 2, player.x - player.w/2, player.y - player.h/2)
function math.scale_point(x, y, sx, sy, ox, oy)
  return x*sx + ox - ox*sx, y*sy + oy - oy*sy
end

-- Rotates and scales the point by r radians and sx, sy with ox, oy as pivot.
-- x, y = math.rotate_scale_point(player.x, player.y, math.pi/4, 2, 2, player.x - player.w/2, player.y - player.h/2)
function math.rotate_scale_point(x, y, r, sx, sy, ox, oy)
  local rx, ry = math.rotate_point(x, y, r, ox, oy)
  return math.scale_point(rx, ry, sx, sy, ox, oy)
end

-- Returns -1 if the angle is on either left quadrants and 1 if its on either right quadrants.
-- h = math.angle_to_horizontal(math.pi/4) -> 1
-- h = math.angle_to_horizontal(-math.pi/4) -> 1
-- h = math.angle_to_horizontal(-3*math.pi/4) -> -1
-- h = math.angle_to_horizontal(3*math.pi/4) -> -1
function math.angle_to_horizontal(r)
  r = math.loop(r, 2*math.pi)
  if r > math.pi/2 and r < 3*math.pi/2 then return -1
  elseif r >= 3*math.pi/2 or r <= math.pi/2 then return 1 end
end

-- Returns -1 if the angle is on either bottom quadrants and 1 if its on either top quadrants.
-- h = math.angle_to_horizontal(math.pi/4) -> -1
-- h = math.angle_to_horizontal(-math.pi/4) -> 1
-- h = math.angle_to_horizontal(-3*math.pi/4) -> 1
-- h = math.angle_to_horizontal(3*math.pi/4) -> -1
function math.angle_to_vertical(r)
  r = math.loop(r, 2*math.pi)
  if r > 0 and r < math.pi then return -1
  elseif r >= math.pi and r <= 2*math.pi then return 1 end
end

-- Converts a direction as a string ('left', 'right', 'up', 'down') to its corresponding angle.
-- r = math.direction_to_angle('left') -> math.pi
-- r = math.direction_to_angle('up') -> -math.pi/2
-- r = math.direction_to_angle('right') -> 0
function math.direction_to_angle(dir)
  if dir == 'left' then return math.pi end
  if dir == 'right' then return 0 end
  if dir == 'up' then return -math.pi/2 end
  if dir == 'down' then return math.pi/2 end
end

-- Snaps the value v to the closest number divisible by x and then centers it. This is useful when doing calculations for grids where each cell would be of size x, for instance.
-- v = math.snap_center(12, 16) -> 8
-- v = math.snap_center(17, 16) -> 24
-- v = math.snap_center(12, 12) -> 6
-- v = math.snap_center(13, 12) -> 18
function math.snap_center(v, x)
  return math.ceil(v/x)*x - x/2
end

-- Returns the squared distance between both points.
-- d = math.distance(player.x, player.y, enemy.x, enemy)
function math.distance(x1, y1, x2, y2)
  return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1))
end

-- Clamps the value to between 0 and 1.
-- v = math.clamp01(-0.1) -> 0
-- v = math.clamp01(1.1) -> 1
function math.clamp01(v)
  if v < 0 then return 0
  elseif v > 1 then return 1
  else return v end
end

-- Rounds the number n to p digits of precision.
-- n = math.round(10.94, 1) -> 10.9
-- n = math.round(45.321, 0) -> 45
-- n = math.round(101.9157289403, 5) -> 101.91572
function math.round(n, p)
  local m = 10^(p or 0)
  return math.floor(n*m+0.5)/m
end

-- Floors value v to the closest number divisible by x.
-- v = math.snap(15, 16) -> 0
-- v = math.snap(17, 16) -> 16
-- v = math.snap(13, 4) -> 12
function math.snap(v, x)
  return math.round(v/x, 0)*x
end

-- Wraps value v such that it is never below 1 or above x.
-- v = math.wrap(1, 3) -> 1
-- v = math.wrap(5, 3) -> 2
-- v = math.wrap(12, 3) -> 3
function math.wrap(v, x)
  return (v - x - 1) % x + 1
end

-- Clamps value v between min and max.
-- v = math.clamp(-4, 0, 10) -> 0
-- v = math.clamp(83, 0, 10) -> 10
-- v = math.clamp(0, -10, -4) -> -4
function math.clamp(v, min, max)
  return math.min(math.max(v, min), max)
end

-- Returns the squared length of x, y.
-- l = math.length(x, y)
function math.length(x, y)
  return math.sqrt(x*x + y*y)
end

-- Returns the squared length of x, y.
-- l = math.length_squared(x, y)
function math.length_squared(x, y)
  return x*x + y*y
end


-- Returns the normalized values of x, y.
-- nx, ny = math.normalize(x, y)
function math.normalize(x, y)
  if math.abs(x) < 0.0001 and math.abs(y) < 0.0001 then return x, y end
  local l = math.length(x, y)
  return x/l, y/l
end

-- Returns the x, y values truncated by max.
-- x, y = math.limit(x, y, 100)
function math.limit(x, y, max)
  local s = max*max/math.length_squared(x, y)
  s = (s > 1 and 1) or math.sqrt(s)
  return x*s, y*s
end

-- Returns the sign of value v.
-- s = math.sign(10) -> 1
-- s = math.sign(-10) -> -1
-- s = math.sign(0) -> 0 
function math.sign(v)
  if v > 0 then return 1
  elseif v < 0 then return -1
  else return 0 end
end

-- Returns the angle of point x, y.
-- r = math.angle(player.v.x, player.v.y)
function math.angle(x, y)
  return math.atan2(y, x)
end

-- Returns the angle from point x, y to point px, py.
-- r = math.angle_to_point(player.x, player.y, enemy.x, enemy)
function math.angle_to_point(x, y, px, py)
  return math.atan2(py - y, px - x)
end

-- Returns the angle from point x, y to the mouse.
-- r = math.angle_to_mouse(player.x, player.y)
function math.angle_to_mouse(x, y)
  local mx, my = main.camera:camera_get_mouse_position()
  return math.atan2(my - y, mx - x)
end

-- Returns the angle from the mouse to this point x, y.
-- r = math.angle_from_mouse(player.x, player.y)
function math.angle_from_mouse(x, y)
  local mx, my = main.camera:camera_get_mouse_position()
  return math.atan2(y - my, x - mx)
end

-- Returns the distance from point x, y to the mouse
-- d = math.distance_to_mouse(player.x, player.y)
function math.distance_to_mouse(x, y)
  local mx, my = main.camera:camera_get_mouse_position()
  return math.distance(x, y, mx, my)
end

-- Remaps value v using its previous range of old_min, old_max into the new range new_min, new_max.
-- v = math.remap(10, 0, 20, 0, 1) -> 0.5 because 10 is 50% of 0, 20 and thus 0.5 is 50% of 0, 1
-- v = math.remap(3, 0, 3, 0, 100) -> 100
-- v = math.remap(2.5, -5, 5, -100, 100) -> 50
function math.remap(v, old_min, old_max, new_min, new_max)
  return ((v - old_min)/(old_max - old_min))*(new_max - new_min) + new_min
end

-- Lerps src to dst with lerp value.
-- v = math.lerp(0.2, self.x, self.x + 100)
function math.lerp(value, src, dst)
  return src*(1 - value) + dst*value
end

-- Correct framerate independent lerping according to https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/
-- f is a value between 0 and infinity that corresponds to how much of the distance between src and dst will be covered per second, regardless of frame rate.
-- math.lerp_dt(1, dt, self.x, self.x + 100) -> will cover 50% of the distance between self.x and self.x + 100 per second
-- With an f of 0.5 instead it will cover half as much ground, while with an f of 2 it will cover double the amount
function math.lerp_dt(f, dt, src, dst)
  return math.lerp(1 - math.exp(-f*dt), src, dst)
end

-- Lerps the src angle towards dst using value as the lerp amount.
-- enemy.r = math.lerp_angle(0.2, enemy.r, enemy:angle_to_object(player))
function math.lerp_angle(value, src, dst)
  local dt = math.loop((dst-src), 2*math.pi)
  if dt > math.pi then dt = dt - 2*math.pi end
  return src + dt*math.clamp01(value)
end

-- Same as math.lerp_angle except correted for usage with delta time.
-- math.lerp_angle_dt(1, dt, enemy.r, enemy:angle_to_object(player)) -> will cover 50% of the distance between enemy.r and and the enemy's angle to the player per second
-- With an f of 0.5 instead it will cover half as much ground, while with an f of 2 it will cover double the amount
function math.lerp_angle_dt(f, dt, src, dst)
  return math.lerp_angle(1 - math.exp(-f*dt), src, dst)
end

-- Loops value t such that is never higher than length and never lower than 0.
-- v = math.loop(3, 2.5) -> 0.5
-- v = math.loop(3*math.pi, 2*math.pi) -> math.pi
function math.loop(t, length)
  return math.clamp(t-math.floor(t/length)*length, 0, length)
end

-- Returns the smallest difference between both angles.
-- v = math.angle_delta(math.pi, math.pi/4) -> 3*math.pi/4
-- v = math.angle_delta(-math.pi/2, math.pi/4) -> 3*math.pi/4
function math.angle_delta(a, b)
  local d = math.loop(a-b, 2*math.pi)
  if d > math.pi then d = d - 2*math.pi end
  return d
end

-- Calculates correct dampened position values given the old position, velocity vx, vy, damping r and delta dt
-- x, y = math.position_damping(self.x, self.y, self.vx, self.vy, self.damping, dt)
function math.position_damping(x, y, vx, vy, r, dt)
  return x + vx*(math.pow(r, dt) - 1)/math.log(r), y + vy*(math.pow(r, dt) - 1)/math.log(r)
end

-- Calculates correct dampened velocity values given the old velocity, damping r and delta dt
-- vx, vy = math.velocity_damping(self.vx, self.vy, self.damping, dt)
function math.velocity_damping(vx, vy, r, dt)
  return (vx or 0)*r^dt, (vy or 0)*r^dt
end

-- Calculates correct dampened values for the given variable, with damping r and delta dt
-- self.r = math.damping(self.r, self.damping, dt)
function math.damping(v, r, dt)
  return (v or 0)*r^dt
end

-- https://github.com/HaxeFlixel/flixel/blob/dev/flixel/math/FlxVelocity.hx#L223
-- Calculates a new velocity based the previous velocity, acceleration, drag (damping when acceleration is not used), max_v and dt
function math.compute_velocity(v, a, drag, max_v, dt)
  if a ~= 0 then
    v = v + a*dt
  elseif d ~= 0 then
    drag = drag*dt
    if v - drag > 0 then v = v - drag
    elseif v + drag < 0 then v = v + drag
    else v = 0 end
  end
  if v ~= 0 and max_v ~= 0 then
    if v > max_v then v = max_v
    elseif v < -max_v then v = -max_v end
  end
  return v
end

-- TODO: make this work for the general case
-- Given angle r and normal values nx, ny (for now only works with normals that are 0, -1 or 1), calculate the bounce angle
-- r = math.bounce(self.r, nx, ny)
function math.bounce(r, nx, ny)
  if nx == 0 then return 2*math.pi - r end
  if ny == 0 then return math.pi - r end
  return r
end

-- Given angles r1 and r2, returns the middle angle between them.
function math.angle_mid(r1, r2)
  return math.atan2(math.cos(r1) + math.cos(r2), math.sin(r1) + math.sin(r2))
end


local PI = math.pi
local PI2 = math.pi/2
local LN2 = math.log(2)
local LN210 = 10*math.log(2)
function math.linear(t)
  return t
end

function math.sine_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return 1 - math.cos(t*PI2) end
end

function math.sine_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return math.sin(t*PI2) end
end

function math.sine_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return -0.5*(math.cos(t*PI) - 1) end
end

function math.sine_out_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  elseif t < 0.5 then return 0.5*math.sin((t*2)*PI2)
  else return -0.5*math.cos((t*2-1)*PI2) + 1 end
end

function math.quad_in(t)
  return t*t
end

function math.quad_out(t)
  return -t*(t-2)
end

function math.quad_in_out(t)
  if t < 0.5 then
    return 2*t*t
  else
    t = t - 1
    return -2*t*t + 1
  end
end

function math.quad_out_in(t)
  if t < 0.5 then
    t = t*2
    return -0.5*t*(t-2)
  else
    t = t*2 - 1
    return 0.5*t*t + 0.5
  end
end

function math.cubic_in(t)
  return t*t*t
end

function math.cubic_out(t)
  t = t - 1
  return t*t*t + 1
end

function math.cubic_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t
  else
    t = t - 2
    return 0.5*(t*t*t + 2)
  end
end

function math.cubic_out_in(t)
  t = t*2 - 1
  return 0.5*(t*t*t + 1)
end

function math.quart_in(t)
  return t*t*t*t
end

function math.quart_out(t)
  t = t - 1
  t = t*t
  return 1 - t*t
end

function math.quart_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t*t
  else
    t = t - 2
    t = t*t
    return -0.5*(t*t - 2)
  end
end

function math.quart_out_in(t)
  if t < 0.5 then
    t = t*2 - 1
    t = t*t
    return -0.5*t*t + 0.5
  else
    t = t*2 - 1
    t = t*t
    return 0.5*t*t + 0.5
  end
end

function math.quint_in(t)
  return t*t*t*t*t
end

function math.quint_out(t)
  t = t - 1
  return t*t*t*t*t + 1
end

function math.quint_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t*t*t
  else
    t = t - 2
    return 0.5*t*t*t*t*t + 1
  end
end

function math.quint_out_in(t)
  t = t*2 - 1
  return 0.5*(t*t*t*t*t + 1)
end

function math.expo_in(t)
  if t == 0 then return 0
  else return math.exp(LN210*(t - 1)) end
end

function math.expo_out(t)
  if t == 1 then return 1
  else return 1 - math.exp(-LN210*t) end
end

function math.expo_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1 end
  t = t*2
  if t < 1 then return 0.5*math.exp(LN210*(t - 1))
  else return 0.5*(2 - math.exp(-LN210*(t - 1))) end
end

function math.expo_out_in(t)
  if t < 0.5 then return 0.5*(1 - math.exp(-20*LN2*t))
  elseif t == 0.5 then return 0.5
  else return 0.5*(math.exp(20*LN2*(t - 1)) + 1) end
end

function math.circ_in(t)
  if t < -1 or t > 1 then return 0
  else return 1 - math.sqrt(1 - t*t) end
end

function math.circ_out(t)
  if t < 0 or t > 2 then return 0
  else return math.sqrt(t*(2 - t)) end
end

function math.circ_in_out(t)
  if t < -0.5 or t > 1.5 then return 0.5
  else
    t = t*2
    if t < 1 then return -0.5*(math.sqrt(1 - t*t) - 1)
    else
      t = t - 2
      return 0.5*(math.sqrt(1 - t*t) + 1)
    end
  end
end

function math.circ_out_in(t)
  if t < 0 then return 0
  elseif t > 1 then return 1
  elseif t < 0.5 then
    t = t*2 - 1
    return 0.5*math.sqrt(1 - t*t)
  else
    t = t*2 - 1
    return -0.5*((math.sqrt(1 - t*t) - 1) - 1)
  end
end

function math.bounce_in(t)
  t = 1 - t
  if t < 1/2.75 then return 1 - (7.5625*t*t)
  elseif t < 2/2.75 then
    t = t - 1.5/2.75
    return 1 - (7.5625*t*t + 0.75)
  elseif t < 2.5/2.75 then
    t = t - 2.25/2.75
    return 1 - (7.5625*t*t + 0.9375)
  else
    t = t - 2.625/2.75
    return 1 - (7.5625*t*t + 0.984375)
  end
end

function math.bounce_out(t)
  if t < 1/2.75 then return 7.5625*t*t
  elseif t < 2/2.75 then
    t = t - 1.5/2.75
    return 7.5625*t*t + 0.75
  elseif t < 2.5/2.75 then
    t = t - 2.25/2.75
    return 7.5625*t*t + 0.9375
  else
    t = t - 2.625/2.75
    return 7.5625*t*t + 0.984375
  end
end

function math.bounce_in_out(t)
  if t < 0.5 then
    t = 1 - t*2
    if t < 1/2.75 then return (1 - (7.5625*t*t))*0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (1 - (7.5625*t*t + 0.75))*0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (1 - (7.5625*t*t + 0.9375))*0.5
    else
      t = t - 2.625/2.75
      return (1 - (7.5625*t*t + 0.984375))*0.5
    end
  else
    t = t*2 - 1
    if t < 1/2.75 then return (7.5625*t*t)*0.5 + 0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (7.5625*t*t + 0.75)*0.5 + 0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (7.5625*t*t + 0.9375)*0.5 + 0.5
    else
      t = t - 2.625/2.75
      return (7.5625*t*t + 0.984375)*0.5 + 0.5
    end
  end
end

function math.bounce_out_in(t)
  if t < 0.5 then
    t = t*2
    if t < 1/2.75 then return (7.5625*t*t)*0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (7.5625*t*t + 0.75)*0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (7.5625*t*t + 0.9375)*0.5
    else
      t = t - 2.625/2.75
      return (7.5625*t*t + 0.984375)*0.5
    end
  else
    t = 1 - (t*2 - 1)
    if t < 1/2.75 then return 0.5 - (7.5625*t*t)*0.5 + 0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return 0.5 - (7.5625*t*t + 0.75)*0.5 + 0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return 0.5 - (7.5625*t*t + 0.9375)*0.5 + 0.5
    else
      t = t - 2.625/2.75
      return 0.5 - (7.5625*t*t + 0.984375)*0.5 + 0.5
    end
  end
end

local overshoot = 1.70158
function math.back_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return t*t*((overshoot + 1)*t - overshoot) end
end

function math.back_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t - 1
    return t*t*((overshoot + 1)*t + overshoot) + 1
  end
end

function math.back_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t*2
    if t < 1 then return 0.5*(t*t*(((overshoot*1.525) + 1)*t - overshoot*1.525))
    else
      t = t - 2
      return 0.5*(t*t*(((overshoot*1.525) + 1)*t + overshoot*1.525) + 2)
    end
  end
end

function math.back_out_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  elseif t < 0.5 then
    t = t*2 - 1
    return 0.5*(t*t*((overshoot + 1)*t + overshoot) + 1)
  else
    t = t*2 - 1
    return 0.5*t*t*((overshoot + 1)*t - overshoot) + 0.5
  end
end

local amplitude = 1
local period = 0.0003
function math.elastic_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t - 1
    return -(amplitude*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period))
  end
end

function math.elastic_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period) + 1 end
end

function math.elastic_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t*2
    if t < 1 then
      t = t - 1
      return -0.5*(amplitude*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period))
    else
      t = t - 1
      return amplitude*math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period)*0.5 + 1
    end
  end
end

function math.elastic_out_in(t)
  if t < 0.5 then
    t = t*2
    if t == 0 then return 0
    else return (amplitude/2)*math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period) + 0.5 end
  else
    if t == 0.5 then return 0.5
    elseif t == 1 then return 1
    else
      t = t*2 - 1
      t = t - 1
      return -((amplitude/2)*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period)) + 0.5
    end
  end
end
