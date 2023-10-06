local gradient_image = class:class_new()
function gradient_image:gradient_image_init(direction, ...)
  local colors = {...}
  local mesh_data = {}
  if direction == "horizontal" then
    for i = 1, #colors do
      local color = colors[i]
      local x = (i-1)/(#colors-1)
      table.insert(mesh_data, {x, 1, x, 1, color.r, color.g, color.b, color.a or 1})
      table.insert(mesh_data, {x, 0, x, 0, color.r, color.g, color.b, color.a or 1})
    end
  elseif direction == "vertical" then
    for i = 1, #colors do
      local color = colors[i]
      local y = (i-1)/(#colors-1)
      table.insert(mesh_data, {1, y, 1, y, color.r, color.g, color.b, color.a or 1})
      table.insert(mesh_data, {0, y, 0, y, color.r, color.g, color.b, color.a or 1})
    end
  end
  self.mesh = love.graphics.newMesh(mesh_data, 'strip', 'static')
  return self
end

function gradient_image:gradient_image_draw(layer, x, y, w, h, r, sx, sy, ox, oy)
  layer:push(x, y, r)
  layer:draw(self.mesh, x - (sx or 1)*(w + (ox or 0))*0.5, y - (sy or 1)*(h + (oy or 0))*0.5, 0, w*(sx or 1), h*(sy or sx or 1))
  layer:pop()
end

return gradient_image
