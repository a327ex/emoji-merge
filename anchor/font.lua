local font = class:class_new()
function font:font_init(filename, font_size, hinting)
  self.object = love.graphics.newFont(filename, font_size, hinting or 'mono')
  self.h = self.object:getHeight()
  return self
end

function font:font_get_width(text)
  return self.object:getWidth(text)
end

return font
