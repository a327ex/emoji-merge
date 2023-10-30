local image = class:class_new()
function image:image_init(filename)
  self.object = love.graphics.newImage(filename)
  self.w, self.h = self.object:getWidth(), self.object:getHeight()
  return self
end

-- Loads a texture atlas into the returned table as quads of size w, h.
-- image_names should contain the names of each quad as they will be referred to in gameplay code, and in the order they appear in the texture, starting from the top-left and moving right-down.
-- padding (default 0) is the amount of empty space between each quad (on both x and y) on the texture; this should be higher than 0 to avoid artifacts when the quads are drawn
function image:image_load_texture_atlas(w, h, image_names, padding)
  local quads = {}
  local k = 1
  for j = 1, math.floor((self.h-(self.h%h))/h) do
    for i = 1, math.floor((self.w-(self.w%w))/w) do
      if image_names[k] then
        quads[image_names[k]] = quad(self, padding + (i-1)*(w + padding), padding + (j-1)*(h + padding), w, h)
      end
      k = k + 1
    end
  end
  return quads
end

return image
