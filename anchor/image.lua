local image = class:class_new()
function image:image_init(filename)
  self.object = love.graphics.newImage(filename)
  self.w, self.h = self.object:getWidth(), self.object:getHeight()
  return self
end

return image
