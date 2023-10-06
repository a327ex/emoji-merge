local timer = class:class_new()
local empty_function = function() end
function timer:timer_init()
  self.timer_timers = {}
  table.insert(main.timer_objects, self)
  return self
end

-- Calls the action every frame until it's cancelled via :cancel.
-- The tag must be passed in otherwise there will be no way to stop this from running.
-- If after is passed in then it is called after the run is cancelled.
function timer:timer_run(action, after, tag)
  local tag = tag or main:random_uid()
  self.timer_timers[tag] = {type = "run", timer = 0, after = after or empty_function, action = action}
end

-- Calls the action after delay seconds.
-- If tag is passed in then any other timer actions with the same tag are automatically cancelled.
-- :timer_after(2, function() print(1) end) -> prints 1 after 2 seconds
function timer:timer_after(delay, action, tag)
  local tag = tag or main:random_uid()
  self.timer_timers[tag] = {type = "after", timer = 0, unresolved_delay = delay, delay = self:timer_resolve_delay(delay), action = action}
end

-- Calls the action every delay seconds if the condition is true.
-- If the condition isn't true when delay seconds are up then it waits and only performs the action and resets the timer when that happens.
-- If times is passed in then it only calls action for that amount of times.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other timer actions with the same tag are automatically cancelled.
-- :timer_cooldown(2, function() return #self:get_objects_in_shape(self.attack_sensor, enemies) > 0 end, function() self:attack() end) -> only attacks when 2 seconds have passed and there are more than 0 enemies around
function timer:timer_cooldown(delay, condition, action, times, after, tag)
  local tag = tag or main:random_uid()
  self.timer_timers[tag] = {type = "cooldown", timer = 0, unresolved_delay = delay, delay = self:timer_resolve_delay(delay), condition = condition, action = action, times = times or 0, max_times = times or 0,
    after = after or empty_function, multiplier = 1}
end

-- Calls the action every delay seconds.
-- If times is passed in then it only calls action for that amount of times.
-- If immediate is passed in then it calls the action immediately once the timer starts.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other timer actions with the same tag are automatically cancelled.
-- :timer_every(2, function() print(1) end) -> prints 1 every 2 seconds
-- :timer_every(2, function() print(1) end, 5, function() print(2) end) -> prints 1 every 2 seconds 5 times, and then prints 2
function timer:timer_every(delay, action, times, immediate, after, tag)
  local tag = tag or main:random_uid()
  self.timer_timers[tag] = {type = "every", timer = 0, index = 1, unresolved_delay = delay, delay = self:timer_resolve_delay(delay), action = action, times = times or 0, max_times = times or 0,
    after = after or empty_function, multiplier = 1}
  if immediate then action() end
end

-- Calls the action every start_delay to end_delay seconds times times.
-- If start_delay = 1, end_delay = 5 and times = 3, then we want 3 numbers between 1 and 5, including 1 and 5. Which means our delays will be 1, 3, 5:
-- :timer_every_step(1, 5, 3, function() print(1) end) -> prints 1 after 1 second, prints 1 after 3 seconds, prints 1 after 5 seconds
-- This is useful whenever you want to call a function multiple times with a delay that varies in a predictable manner. For instance:
-- :timer_every_step(0.05, 0.5, 20, function() player:spawn_particle() end) -> this will spawn 20 particles, but will start spawning them really fast and get slower over time as it gets closer to the end
-- If immediate is passed in then it calls the action immediately once the timer starts.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other timer actions with the same tag are automatically cancelled.
-- If step_method is passed in then it is used to modify the step curve, by default it is math.linear but it can be any of the easing functions.
function timer:timer_every_step(start_delay, end_delay, times, action, immediate, step_method, after, tag)
  if times < 2 then error(":timer_every_step's times must be >=2") end
  local tag = tag or main:random_uid()
  local step = (end_delay - start_delay)/(times - 1)
  local delays = {}
  for i = 1, times do delays[i] = start_delay + (i-1)*step end
  if step_method then
    local steps = {}
    for i = 1, times-2 do table.insert(steps, i/(times-1)) end
    for i, step in ipairs(steps) do steps[i] = step_method(step) end
    local j = 1
    for i = 2, #delays-1 do delays[i] = math.remap(steps[j], 0, 1, start_delay, end_delay); j = j + 1 end
  end
  self.timer_timers[tag] = {type = "every_step", timer = 0, index = 1, delays = delays, action = action, times = times or 0, max_times = times or 0, after = after or empty_function, multiplier = 1}
  if immediate then action() end
end

-- Calls the action every frame for delay seconds.
-- If after is passed in then it is called after the duration ends or after the condition becomes false.
-- If tag is passed in then any other timer actions with the same tag are automatically cancelled.
-- :timer_during(5, function() print(main:random_float(0, 100)) end)
function timer:timer_during(delay, action, after, tag)
  local tag = tag or main:random_uid()
  self.timer_timers[tag] = {type = "during", timer = 0, unresolved_delay = delay, delay = self:timer_resolve_delay(delay), action = action, after = after or empty_function}
end

-- Tweens the target's values specified by the source table for delay seconds using the given tweening method.
-- All tween methods can be found in the math/math file.
-- If after is passed in then it is called after the duration ends.
-- If tag is passed in then any other timer actions with the same tag are automatically cancelled.
-- :timer_tween(0.2, self, {sx = 0, sy = 0}, math.linear) -> tweens this object's scale variables to 0 linearly over 0.2 seconds
-- :timer_tween(0.2, self, {sx = 0, sy = 0}, math.linear, function() self.dead = true end) -> tweens this object's scale variables to 0 linearly over 0.2 seconds and then kills it
function timer:timer_tween(delay, target, source, method, after, tag)
  local tag = tag or main:random_uid()
  local initial_values = {}
  for k, _ in pairs(source) do initial_values[k] = target[k] end
  self.timer_timers[tag] = {type = "tween", timer = 0, unresolved_delay = delay, delay = self:timer_resolve_delay(delay), target = target, initial_values = initial_values, source = source, method = method or math.linear,
    after = after or empty_function}
end

-- Cancels a timer action based on its tag.
-- This is automatically called if repeated tags are given to timer actions.
function timer:timer_cancel(tag)
  if self.timer_timers[tag] and self.timer_timers[tag].type == "run" then
    self.timer_timers[tag].after()
  end
  self.timer_timers[tag] = nil
end

-- Resets the timer for a tag.
-- Useful when you need to start counting that tag from 0 after an event happens.
function timer:timer_reset(tag)
  self.timer_timers[tag].timer = 0
end

-- Returns the delay of a given tag.
-- This is useful when delays are set randomly (every(timer, {2, 4}, ...) would set the delay at a random number between 2 and 4) and you need to know what the value chosen was.
function timer:timer_get_delay(tag)
  return self.timer_timers[tag].delay
end

-- Returns the current iteration of an every timer action with the given tag.
-- Useful if you need to know that its the nth time an every action has been called.
function timer:timer_get_every_index(tag)
  return self.timer_timers[tag].index
end

-- Sets a multiplier for a given tag.
-- This is useful when you need the event to happen in a varying interval, like based on the player's attack speed, which might change every frame based on buffs.
-- Call this on the update function with the appropriate multiplier.
function timer:timer_set_multiplier(tag, multiplier)
  if not self.timer_timers[tag] then return end
  self.timer_timers[tag].multiplier = multiplier or 1
end

function timer:timer_get_multiplier(tag)
  if not self.timer_timers[tag] then return end
  return self.timer_timers[tag].multiplier
end

-- Returns the elapsed time of a given timer as a number between 0 and 1.
-- Useful if you need to know where you currently are in the duration of a during call.
function timer:timer_get_during_elapsed_time(tag)
  if not self.timer_timers[tag] then return end
  return self.timer_timers[tag].timer/self.timer_timers[tag].delay
end

-- Returns the elapsed time of a given timer as well as its delay.
-- Useful if you need to know where you currently are in the duration of an every call.
function timer:timer_get_timer_and_delay(tag)
  if not self.timer_timers[tag] then return end
  return self.timer_timers[tag].timer, self.timer_timers[tag].delay
end

function timer:timer_resolve_delay(delay)
  if type(delay) == "table" then
    return main:random_float(delay[1], delay[2])
  else
    return delay
  end
end

function timer:timer_update(dt)
  for tag, t in pairs(self.timer_timers) do
    if t.timer then t.timer = t.timer + dt end
    if t.type == "run" then
      t.action()
    elseif t.type == "cooldown" then
      if t.timer > t.delay*t.multiplier and t.condition() then
        t.action()
        t.timer = 0
        t.delay = self:timer_resolve_delay(t.unresolved_delay)
        if t.times > 0 then
          t.times = t.times - 1
          if t.times <= 0 then
            t.after()
            self.timer_timers[tag] = nil
          end
        end
      end
    elseif t.type == "after" then
      if t.timer > t.delay then
        t.action()
        self.timer_timers[tag] = nil
      end
    elseif t.type == "every" then
      if t.timer > t.delay*t.multiplier then
        t.action()
        t.timer = t.timer - t.delay*t.multiplier
        t.index = t.index + 1
        t.delay = self:timer_resolve_delay(t.unresolved_delay)
        if t.times > 0 then
          t.times = t.times - 1
          if t.times <= 0 then
            t.after()
            self.timer_timers[tag] = nil
          end
        end
      end
    elseif t.type == "every_step" then
      if t.timer > t.delays[t.index]*t.multiplier then
        t.action()
        t.timer = t.timer - t.delays[t.index]*t.multiplier
        t.index = t.index + 1
        if t.times > 0 then
          t.times = t.times - 1
          if t.times <= 0 then
            t.after()
            self.timer_timers[tag] = nil
          end
        end
      end
    elseif t.type == "during" then
      t.action(dt)
      if t.timer > t.delay then
        t.after()
        self.timer_timers[tag] = nil
      end
    elseif t.type == "tween" then
      for k, v in pairs(t.source) do
        t.target[k] = math.lerp(t.method(t.timer/t.delay), t.initial_values[k], v)
      end
      if t.timer > t.delay then
        t.after()
        self.timer_timers[tag] = nil
      end
    end
  end
end

return timer
