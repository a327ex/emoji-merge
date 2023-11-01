-- Mixin responsible for everything drawing related. This mixin is the only way you can draw something to the screen.
-- Draw commands are sent to the layer's queue of commands and then drawn to a canvas at the end of the frame.
-- Create a new layer like so:
--   game = layer()
-- And then in an update function somewhere:
--   game:circle(50, 50, 10, colors.white[0])
-- This sends a draw command to the game layer telling it to draw a circle at 50, 50 with radius 10 and white color.
-- At the end of the frame the circle is drawn and all draw commands cleared so they can be added anew next frame. Layers are drawn in the order they were created.
-- A layer can also be created with a table that specifies different behaviors:
--   game = layer({attribute = value, ...})
-- Possible attributes are:
--   * fixed - by default layers are drawn modified by main.camera's transform; fixed being true disables this, which is useful for things like UIs which don't need to be affected by any camera
local graphics = {}
local layer = class:class_new()
function layer:layer_init()
  self.canvas = {}
  self:layer_add_canvas('main')
  self.draw_commands = {}
  table.insert(main.layer_objects, self)
  return self
end

-- Adds a new canvas to the layer.
-- Can be later referred to as self.canvas[name].
function layer:layer_add_canvas(name)
  self.canvas[name] = love.graphics.newCanvas(main.w, main.h)
end

-- Draws stored commands to the canvas identified by the given name.
-- In general you want to call this once per frame, since you can then use the results elsewhere by simply accessing the canvas that was just drawn to (self.canvas[name]).
local z_sort = function(a, b) return (a.z or 0) < (b.z or 0) end
function layer:layer_draw_commands(name)
  self:layer_draw_to_canvas(name or 'main', function()
    -- table.stable_sort(self.draw_commands, z_sort) -- PERFORMANCE: I never actually ended up using .z for sorting within layers in reality and this showed up as a significant cost on the profiler, so it's out for now
    if not self.fixed then main.camera:camera_attach() end
    for _, command in ipairs(self.draw_commands) do
      if graphics[command.type] then
        graphics[command.type](unpack(command.args))
      else
        error('undefined layer graphics function for ' .. command.type)
      end
    end
    if not self.fixed then main.camera:camera_detach() end
  end)
end

-- Draw the layer's canvas identified by the given name.
-- color, shader and flat are optional arguments that change how the canvas is drawn.
function layer:layer_draw(name, x, y, r, sx, sy, color, shader, flat)
  local color = color or colors.white[0]
  if shader then love.graphics.setShader(shader.object) end
  if flat then
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.draw(self.canvas[name or 'main'], x or self.x or 0, y or self.y or 0, r or 0, sx or main.sx or 1, sy or main.sy or sx or 1)
  else
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.canvas[name or 'main'], x or self.x or 0, y or self.y or 0, r or 0, sx or main.sx or 1, sy or main.sy or sx or 1)
    love.graphics.setBlendMode('alpha')
  end
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setShader()
end

-- Draws what's inside the action function to the layer's canvas identified by the given name.
-- The draw actions inside must be DIRECT, meaning they can't be draw functions defined below the "INDIRECT FUNCTIONS BELOW" line in this file.
-- If you want to draw things to a specific canvas, first call indirect functions, then draw to the canvas using :layer_draw_commands, and then draw that canvas to the main canvas (see example in main:draw_layers in anchor/init.lua).
function layer:layer_draw_to_canvas(name, action)
  love.graphics.setCanvas{self.canvas[name or 'main'], stencil=true}
  love.graphics.clear()
  action()
  love.graphics.setCanvas()
end




-- INDIRECT FUNCTIONS BELOW --

-- Draws a circle of radius r centered on x, y.
-- If color is passed in then the circle will be filled with that color (color is Color object)
-- If line_width is passed in then the circle will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.circle(x, y, r, color, line_width)
  graphics.shape("circle", color, line_width, x, y, r)
end

function layer:circle(x, y, r, color, line_width, z)
  table.insert(self.draw_commands, {type = 'circle', args = {x, y, r, color, line_width}, z = z or 0})
end

-- Draws a dashed line with the given points.
-- dash_size and gap_size correspond to the dimensions of the dashing behavior.
-- If color is passed in then the lines will be filled with that color (color is Color object)
-- If line_width is passed in then the lines will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.dashed_line(x1, y1, x2, y2, dash_size, gap_size, color, line_width)
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  local dx, dy = x2-x1, y2-y1
  local an, st = math.atan2(dy, dx), dash_size + gap_size
  local len = math.sqrt(dx*dx + dy*dy)
  local nm = (len-dash_size)/st
  love.graphics.push()
    love.graphics.translate(x1, y1)
    love.graphics.rotate(an)
    for i = 0, nm do love.graphics.line(i*st, 0, i*st + dash_size, 0) end
    love.graphics.line(nm*st, 0, nm*st + dash_size, 0)
  love.graphics.pop()
end

function layer:dashed_line(x1, y1, x2, y2, dash_size, gap_size, color, line_width, z)
  table.insert(self.draw_commands, {type = 'dashed_line', args = {x1, y1, x2, y2, dash_size, gap_size, color, line_width}, z = z or 0})
end

function graphics.draw(drawable, x, y, r, sx, sy, ox, oy)
  love.graphics.draw(drawable.object and drawable.object or drawable, x, y, r, sx, sy, ox, oy)
end

function layer:draw(drawable, x, y, r, sx, sy, ox, oy, z)
  table.insert(self.draw_commands, {type = 'draw', args = {drawable, x, y, r, sx, sy, ox, oy}, z = z or 0})
end

function graphics.draw_image(drawable, x, y, r, sx, sy, ox, oy, color, shader)
  local _r, g, b, a
  if color then
    _r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(color.r, color.g, color.b, color.a)
  end
  if shader then love.graphics.setShader(shader.object) end
  love.graphics.draw(drawable.object, x, y, r or 0, sx or 1, sy or sx or 1, drawable.w*0.5 + (ox or 0), drawable.h*0.5 + (oy or 0))
  if shader then love.graphics.setShader() end
  if color then love.graphics.setColor(_r, g, b, a) end
end

function layer:draw_image(drawable, x, y, r, sx, sy, ox, oy, color, shader, z)
  table.insert(self.draw_commands, {type = 'draw_image', args = {drawable, x, y, r, sx, sy, ox, oy, color, shader}, z = z or 0})
end

function graphics.draw_quad(drawable, x, y, r, sx, sy, ox, oy, color, shader)
  local _r, g, b, a
  if color then
    _r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(color.r, color.g, color.b, color.a)
  end
  if shader then love.graphics.setShader(shader.object) end
  love.graphics.draw(drawable.source, drawable.object, x, y, r or 0, sx or 1, sy or sx or 1, drawable.w*0.5 + (ox or 0), drawable.h*0.5 + (oy or 0))
  if shader then love.graphics.setShader() end
  if color then love.graphics.setColor(_r, g, b, a) end
end

function layer:draw_quad(drawable, x, y, r, sx, sy, ox, oy, color, shader, z)
  table.insert(self.draw_commands, {type = 'draw_quad', args = {drawable, x, y, r, sx, sy, ox, oy, color, shader}, z = z or 0})
end

function graphics.draw_image_or_quad(drawable, x, y, r, sx, sy, ox, oy, color, shader)
  local _r, g, b, a
  if color then
    _r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(color.r, color.g, color.b, color.a)
  end
  if shader then love.graphics.setShader(shader.object) end
  if drawable:is('image') then
    love.graphics.draw(drawable.object, x, y, r or 0, sx or 1, sy or sx or 1, drawable.w*0.5 + (ox or 0), drawable.h*0.5 + (oy or 0))
  elseif drawable:is('quad') then
    love.graphics.draw(drawable.source, drawable.object, x, y, r or 0, sx or 1, sy or sx or 1, drawable.w*0.5 + (ox or 0), drawable.h*0.5 + (oy or 0))
  end
  if shader then love.graphics.setShader() end
  if color then love.graphics.setColor(_r, g, b, a) end
end

function layer:draw_image_or_quad(drawable, x, y, r, sx, sy, ox, oy, color, shader, z)
  table.insert(self.draw_commands, {type = 'draw_image_or_quad', args = {drawable, x, y, r, sx, sy, ox, oy, color, shader}, z = z or 0})
end

-- Prints text to the screen, alternative to using an object with a text mixin.
function graphics.draw_text(text, font, x, y, r, sx, sy, ox, oy, color)
  local _r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  love.graphics.print(text, font.object, x, y, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
  if color then love.graphics.setColor(_r, g, b, a) end
end

function layer:draw_text(text, font, x, y, r, sx, sy, ox, oy, color, z)
  table.insert(self.draw_commands, {type = 'draw_text', args = {text, font, x, y, r, sx, sy, ox, oy, color}, z = z or 0})
end

-- Prints text to the screen centered on x, y, alternative to using an object with a text mixin.
function graphics.draw_text_centered(text, font, x, y, r, sx, sy, ox, oy, color)
  local _r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  love.graphics.print(text, font.object, x, y, r or 0, sx or 1, sy or 1, (ox or 0) + font:font_get_width(text)/2, (oy or 0) + font.h/2)
  if color then love.graphics.setColor(_r, g, b, a) end
end

function layer:draw_text_centered(text, font, x, y, r, sx, sy, ox, oy, color, z)
  table.insert(self.draw_commands, {type = 'draw_text_centered', args = {text, font, x, y, r, sx, sy, ox, oy, color}, z = z or 0})
end

function graphics.ex(x, y, w, color, line_width)
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  love.graphics.line(x - w/2, y - w/2, x + w/2, y + w/2)
  love.graphics.line(x - w/2, y + w/2, x + w/2, y - w/2)
  love.graphics.setColor(r, g, b, a)
  love.graphics.setLineWidth(1)
end

function layer:ex(x, y, w, color, line_width, z)
  table.insert(self.draw_commands, {type = 'ex', args = {x, y, w, color, line_width}, z = z or 0})
end

-- Draws a line with the given points.
function graphics.line(x1, y1, x2, y2, color, line_width)
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  love.graphics.line(x1, y1, x2, y2)
  love.graphics.setColor(r, g, b, a)
  love.graphics.setLineWidth(1)
end

function layer:line(x1, y1, x2, y2, color, line_width, z)
  table.insert(self.draw_commands, {type = 'line', args = {x1, y1, x2, y2, color, line_width}, z = z or 0})
end

-- Draws a polygon with the given points.
-- If color is passed in then the polygon will be filled with that color (color is Color object)
-- If line_width is passed in then the polygon will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.polygon(vertices, color, line_width)
  graphics.shape("polygon", color, line_width, vertices)
end

function layer:polygon(vertices, color, line_width, z)
  table.insert(self.draw_commands, {type = 'polygon', args = {vertices, color, line_width}, z = z or 0})
end

-- Draws a series of connected lines with the given points.
function graphics.polyline(vertices, color, line_width) 
  local r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  if line_width then love.graphics.setLineWidth(line_width) end
  love.graphics.line(unpack(vertices))
  love.graphics.setColor(r, g, b, a)
  love.graphics.setLineWidth(1)
end

function layer:polyline(vertices, color, line_width, z)
  table.insert(self.draw_commands, {type = 'polyline', args = {vertices, color, line_width}, z = z or 0})
end

function graphics.pop()
  love.graphics.pop()
end

function layer:pop(z)
  table.insert(self.draw_commands, {type = 'pop', args = {}, z = z or 0})
end

function graphics.push(x, y, r, sx, sy)
  love.graphics.push()
  love.graphics.translate(x or 0, y or 0)
  love.graphics.scale(sx or 1, sy or sx or 1)
  love.graphics.rotate(r or 0)
  love.graphics.translate(-x or 0, -y or 0)
end

function layer:push(x, y, r, sx, sy, z)
  table.insert(self.draw_commands, {type = 'push', args = {x or 0, y or 0, r or 0, sx or 1, sy or sx or 1}, z = z or 0})
end

-- Draws a rectangle of size w, h centered on x, y.
-- If rx, ry are passed in, then the rectangle will have rounded corners with radius of that size.
-- If color is passed in then the rectangle will be filled with that color (color is Color object)
-- If line_width is passed in then the rectangle will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.rectangle(x, y, w, h, rx, ry, color, line_width)
  graphics.shape("rectangle", color, line_width, x - w/2, y - h/2, w, h, rx, ry)
end

function layer:rectangle(x, y, w, h, rx, ry, color, line_width, z)
  table.insert(self.draw_commands, {type = 'rectangle', args = {x, y, w, h, rx, ry, color, line_width}, z = z or 0})
end

-- Draws a rectangle of size w, h centered on x - w/2, y - h/2.
-- If rx, ry are passed in, then the rectangle will have rounded corners with radius of that size.
-- If color is passed in then the rectangle will be filled with that color (color is Color object)
-- If line_width is passed in then the rectangle will not be filled and will instead be drawn as a set of lines of the given width.
function graphics.rectangle_lt(x, y, w, h, rx, ry, color, line_width)
  graphics.shape("rectangle", color, line_width, x, y, w, h, rx, ry)
end

function layer:rectangle_lt(x, y, w, h, rx, ry, color, line_width, z)
  table.insert(self.draw_commands, {type = 'rectangle_lt', args = {x, y, w, h, rx, ry, color, line_width}, z = z or 0})
end

function graphics.rotate(r)
  love.graphics.rotate(r)
end

function layer:rotate(r, z)
  table.insert(self.draw_commands, {type = 'rotate', args = {r or 0}, z = z or 0})
end

function graphics.scale(sx, sy)
  love.graphics.scale(sx, sy)
end

function layer:scale(sx, sy, z)
  table.insert(self.draw_commands, {type = 'scale', args = {sx or 1, sy or sx or 1}, z = z or 0})
end

function graphics.set_blend_mode(mode, alpha_mode)
  love.graphics.setBlendMode(mode, alpha_mode)
end

function layer:set_blend_mode(mode, alpha_mode, z)
  table.insert(self.draw_commands, {type = 'set_blend_mode', args = {mode or 'alpha', alpha_mode or 'alphamultiply'}, z = z or 0})
end

function graphics.set_color(color)
  love.graphics.setColor(color.r, color.g, color.b, color.a)
end

function layer:set_color(color, z)
  table.insert(self.draw_commands, {type = 'set_color', args = {color}, z = z or 0})
end

function graphics.set_color_rgba(r, g, b, a)
  love.graphics.setColor(r, g, b, a)
end

function layer:set_color_rgba(r, g, b, a, z)
  table.insert(self.draw_commands, {type = 'set_color_rgba', args = {r, g, b, a}, z = z or 0})
end

function graphics.set_shader(shader)
  if not shader then love.graphics.setShader()
  else love.graphics.setShader(shader.object) end
end

function layer:set_shader(shader, z)
  table.insert(self.draw_commands, {type = 'set_shader', args = {shader}, z = z or 0})
end

function graphics.send(shader, name, value)
  shader:shader_send(name, value)
end

function layer:send(shader, name, value, z) 
  table.insert(self.draw_commands, {type = 'send', args = {shader, name, value}, z = z or 0})
end

function graphics.shape(shape, color, line_width, ...)
  local r, g, b, a = love.graphics.getColor()
  if not color and not line_width then love.graphics[shape]("line", ...)
  elseif color and not line_width then
    love.graphics.setColor(color.r, color.g, color.b, color.a)
    love.graphics[shape]("fill", ...)
  else
    if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
    love.graphics.setLineWidth(line_width)
    love.graphics[shape]("line", ...)
    love.graphics.setLineWidth(1)
  end
  love.graphics.setColor(r, g, b, a)
end

function graphics.translate(x, y)
  love.graphics.translate(x, y)
end

function layer:translate(x, y, z)
  table.insert(self.draw_commands, {type = 'translate', args = {x or 0, y or 0}, z = z or 0})
end

function graphics.triangle(x, y, w, color, line_width)
  local h = math.sqrt(math.pow(w, 2) - math.pow(w/2, 2))
  local x1, y1 = x + h/2, y
  local x2, y2 = x - h/2, y - w/2
  local x3, y3 = x - h/2, y + w/2
  graphics.shape("polygon", color, line_width, {x1, y1, x2, y2, x3, y3})
end

function layer:triangle(x, y, w, color, line_width, z)
  table.insert(self.draw_commands, {type = 'triangle', args = {x, y, w, color, line_width}, z = z or 0})
end

return layer
