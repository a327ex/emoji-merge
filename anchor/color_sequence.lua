-- Mixin responsible for changing the .color attribute of the object in sequence.
-- For instance, self:color_sequence_init(colors.fg[0], 0.5, colors.blue[0], 1, colors.red[0]) will set .color to colors.fg[0] immediately,
-- then after 0.5 seconds will change it to colors.blue[0], then 1 second after that will change it to colors.red[0].
-- Supports a maximum of 3 colors for now, will add more in the future if the need ever comes.
local color_sequence = class:class_new()
function color_sequence:color_sequence_init(color_1, interval_1, color_2, interval_2, color_3)
  self.color = color_1
  if interval_1 then
    self:timer_after(interval_1, function()
      if color_2 then
        self.color = color_2
        if interval_2 then
          self:timer_after(interval_2, function()
            if color_3 then
              self.color = color_3
            end
          end, 'colors_2')
        end
      end
    end, 'colors_1')
  end
  return self
end

-- Same as above except intervals are relative to the "self.duration" attribute. 
-- If "self.duration" is 2, then an interval of 0.5 means it will take 1 second.
-- If "self.duration" is 3, then an interval of 0.5 means it will take 1.5 seconds.
function color_sequence:color_sequence_relative_init(color_1, interval_1, color_2, interval_2, color_3)
  self.color = color_1
  if interval_1 then
    self:timer_after(interval_1*self.duration, function()
      if color_2 then
        self.color = color_2
        if interval_2 then
          self:timer_after(interval_2*self.duration, function()
            if color_3 then
              self.color = color_3
            end
          end, 'colors_2')
        end
      end
    end, 'colors_1')
  end
  return self
end

return color_sequence
