-- This logically updates an animation.
-- This being separated from the visual part of an animation is useful whenever you need animation-like behavior unrelated to graphics, like making your own animations with code only. For instance:
--[[
self.animation = animation_logic(0.04, 6, 'loop', {
  [1] = function()
    for i = 1, main:random_int(1, 3) do floor:container_add(dust_particle(self.x, self.y)) end
    self.z = 9
  end,
  [2] = function() self:timer_tween(0.025, self, {z = 6}, math.linear, nil, 'move_2') end,
  [3] = function() self:timer_tween(0.025, self, {z = 3}, math.linear, nil, 'move_3') end,
  [4] = function()
    self:timer_tween(0.025, self, {z = 0}, math.linear, nil, 'move_4')
    self.sx = 0.1
    self:timer_tween(0.05, self, {sx = 0}, math.linear, nil, 'move_5')
  end,
})
]]--
--
-- That was an example of a code-only movement animation for a prototype I made in the past.
-- The arguments that this takes are the delay between each frame, how many frames there are, the loop mode ('loop', 'once' or 'bounce') and a table of actions.
-- The delay argument can either be a number or a table, if it's a table then the delay for each frame can be set individually:
-- animation = animation_logic({0.02, 0.04, 0.06, 0.04}, ...)
-- Here it would take 0.02s to go from frame 1 to 2, 0.04s from 2 to 3, 0.06s from 3 to 4 and 0.04s from 4 to 5 (or 1 if there are only 4 frames).
-- Loop can be either: 'loop', the animation will start over from frame 1 when it reaches the end; 'once', it will stop once it reaches the end; 'bounce', it will reverse once it reaches the end or start
-- Finally, the actions table can contain a list of functions, as shown in the code-only animation example above, and each function will be performed when that frame is reached.
-- The index 0 can be used to perform an action once the animation reaches its end:
-- self.death_animation = animation_logic(0.04, self.player_dead_frames.size, 'once', {[0] = function() self.dead = true end})
local animation_logic = class:class_new()
function animation_logic:animation_logic_init(delay, size, loop_mode, actions)
  self.delay = delay
  self.size = size 
  self.loop_mode = loop_mode or "once"
  self.actions = actions
  self.timer = 0
  self.frame = 1
  self.direction = 1
  return self
end

function animation_logic:animation_logic_update(dt)
  if self.dead then return end

  self.timer = self.timer + dt
  local delay = self.delay
  if type(self.delay) == "table" then delay = self.delay[self.frame] end

  if self.timer > delay then
    self.timer = 0
    self.frame = self.frame + self.direction
    if self.frame > self.size or self.frame < 1 then
      if self.loop_mode == "once" then
        self.frame = self.size
        self.dead = true
      elseif self.loop_mode == "loop" then
        self.frame = 1
      elseif self.loop_mode == "bounce" then
        self.direction = -self.direction
        self.frame = self.frame + 2*self.direction
      end
      if self.actions and self.actions[0] then self.actions[0]() end
    end
    if self.actions and self.actions[self.frame] then self.actions[self.frame]() end
  end
end

return animation_logic
