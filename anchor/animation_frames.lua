-- Takes in an already loaded image, the width and height of each frame, and a list of frames in terms of its indexed position on the image.
-- player_spritesheet = image('assets/player_spritesheet.png')
-- player_idle_frames = animation_frames(player_spritesheet, 32, 32, {{1, 1}, {2, 1}})
-- player_run_frames = animation_frames(player_spritesheet, 32, 32, {{1, 2}, {2, 2}, {3, 2}})
-- player_attack_frames = animation_frames(player_spritesheet, 32, 32, {{1, 3}, {2, 3}, {3, 3}, {4, 3}})
--
-- In the example above we first load an image, and then load 3 player animations.
-- Each animation comes from different rows in the same spritesheet, and that's reflected by the last argument in each call.
-- If your animation comes from a single spritesheet that doesn't have multiple animations, then you can omit the last argument and it will automatically go through it.
-- TODO: make this use the quad object
local animation_frames = class:class_new()
function animation_frames:animation_frames_init(filename, frame_w, frame_h, frames_list)
  self.source = image(filename)
  self.frame_w, self.frame_h = frame_w, frame_h
  self.frames_list = frames_list

  if type(self.frames_list) == 'number' then -- the source is a single row spritesheet and number of frames are specified
    local frames_list = {}
    for i = 1, self.frames_list do table.insert(frames_list, {i, 1}) end
    self.frames_list = frames_list
  elseif not self.frames_list then
    local frames_list = {}
    for i = 1, math.floor(self.source.w/self.frame_w) do table.insert(frames_list, {i, 1}) end
    self.frames_list = frames_list
  end

  self.frames = {}
  for i, frame in ipairs(self.frames_list) do
    self.frames[i] = {quad = love.graphics.newQuad((frame[1]-1)*self.frame_w, (frame[2]-1)*self.frame_h, self.frame_w, self.frame_h, self.source.w, self.source.h), w = self.frame_w, h = self.frame_h}
  end
  self.size = #self.frames
  return self
end

function animation_frames:animation_frames_draw(layer, frame, x, y, r, sx, sy, ox, oy, z)
  layer:draw_quad(self.source, self.frames[frame].quad, x, y, r or 0, sx or 1, sy or sx or 1, self.frames[frame].w/2 + (ox or 0), self.frames[frame].h/2 + (oy or 0), z)
end

return animation_frames
