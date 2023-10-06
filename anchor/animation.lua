-- This is a combination of animation_frames and animation_logic mixins to create a standard animation.
-- Even though this is a mixin, it should be mostly used in gameplay code as an object, although in some cases mixin usage might make sense.
--[[
player_walk = image('assets/player_walk.png')
walk_frames = animation_frames(player_walk)
animation = animation(0.04, walk_frames, 'loop', {
  [2] = function() sounds[main:random_table{'step_1', 'step_2', step_3'}]:sound_play(0.5, main:random_float(0.95, 1.05)) end,
  [4] = function() sounds[main:random_table{'step_1', 'step_2', step_3'}]:sound_play(0.5, main:random_float(0.95, 1.05)) end,
})
]]--
--
-- The example above shows a walking animation being created for the player, and on the 2nd and 4th frames it plays a step sound.
-- :animation_update must be manually called somewhere in an update function to actually update and draw the animation.
local animation = class:class_new()
function animation:animation_init(delay, animation_frames, loop_mode, actions)
  self.animation_frames = animation_frames
  self:animation_logic_init(delay, self.animation_frames.size, loop_mode, actions)
  self.w, self.h = self.animation_frames.frame_w, self.animation_frames.frame_h
  return self
end

function animation:animation_update(dt, layer, x, y, r, sx, sy, ox, oy, color, shader, z)
  self:animation_logic_update(dt)
  self.animation_frames:animation_frames_draw(layer, self.frame, x, y, r, sx, sy, ox, oy, color, shader, z)
end

return animation
