local quad = class:class_new()
function quad:quad_init(source, x, y, w, h)
  self.object = love.graphics.newQuad(x, y, w, h, source.w, source.h)
  self.source = source.object
  self.w, self.h = w, h
  return self
end

return quad
