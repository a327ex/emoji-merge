-- A color ramp mixin, all it does is create a color object that goes from -10 to 10 around the central color using color.lighten by a certain step.
-- For instance, gray = color_ramp(color(0.5, 0.5, 0.5, 1), 0.05) will create a color gray that goes from 0.5 to 0 or 1 and can be accessed as gray[-10] (black) through gray[10] (white).
local color_ramp = class:class_new()
function color_ramp:color_ramp_init(color, step)
  self.color = color
  self.step = step
  for i = -10, 10 do
    if i < 0 then
      self[i] = self.color:color_clone():color_lighten(i*self.step)
    elseif i > 0 then
      self[i] = self.color:color_clone():color_lighten(i*self.step)
    else
      self[i] = self.color:color_clone()
    end
  end
  return self
end

return color_ramp
