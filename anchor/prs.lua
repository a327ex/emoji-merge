local prs = class:class_new()
function prs:prs_init(x, y, r, sx, sy)
  self.x, self.y = x or self.x or 0, y or self.y or 0
  self.r = r or self.r or 0
  self.sx, self.sy = sx or self.sx or 1, sy or self.sy or sx or self.sx or 1
  return self
end

return prs
