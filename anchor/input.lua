-- Binds input from keyboard, mouse, gamepad to actions.
-- Actions can then be used in gameplay code in an input device agnostic way.
-- For instance, self:input_bind('jump', {'key:x', 'key:space', button:a'}), will bind keyboard keys x and space, as well as gamepad's button a, to the 'jump' action.
-- In an update function, you could then do "if main:input_is_pressed('jump')" to check if the action has been pressed.
-- Possible states for actions: pressed, released, down.
local input = class:class_new()
function input:input_init()
  love.joystick.loadGamepadMappings('anchor/gamecontrollerdb.txt')
  self.input_actions = {}
  self.input_state = {}
  self.input_sequence_state = {}
  self.input_keyboard_state = {}
  self.input_previous_keyboard_state = {}
  self.input_mouse_state = {}
  self.input_previous_mouse_state = {}
  self.input_gamepad_state = {}
  self.input_previous_gamepad_state = {}
  self.input_last_type = nil
  self.input_gamepad = love.joystick.getJoysticks()[1]
  self.input_deadzone = 0.5
  table.insert(main.input_objects, self)
  return self
end

-- Binds an action to a set of controls. This allows you to code all gameplay code using action names rather than key/button names.
-- Controls come in the form '[type]:[key]', for instance:
-- :input_bind('left', {'key:left', 'key:a', 'axis:left_x-', 'button:dpad_left'})
-- :input_bind('right', {'key:right', 'key:d', 'axis:left_x+', 'button:dpad_right'})
-- :input_bind('up', {'key:up', 'key:w', 'axis:left_y-', 'button:dpad_up'})
-- :input_bind('down', {'key:down', 'key:s', 'axis:left_y+', 'button:dpad_down'})
-- :input_bind('jump', {'key:x', 'key:space', 'button:a'})
-- Repeated calls to this function given the same action will add new controls to it.
-- To reset an action's controls entirely call unbind_all. To remove a single control from it (such as when the player is rebinding keys) call unbind.
function input:input_bind(action, controls)
  if not self.input_state[action] then self.input_state[action] = {} end
  if not self.input_state[action].controls then self.input_state[action].controls = {} end
  for _, control in ipairs(controls) do table.insert(self.input_state[action].controls, control) end
  if not table.contains(self.input_actions, action) then table.insert(self.input_actions, action) end
end

-- Binds all keyboard keys to their own actions, so you can easily say "input.a.pressed" without having to bind it for every key.
function input:input_bind_all()
  local controls = {
    'key:a', 'key:b', 'key:c', 'key:d', 'key:e', 'key:f', 'key:g', 'key:h', 'key:i', 'key:j', 'key:k', 'key:l', 'key:m', 'key:n', 'key:o',
    'key:p', 'key:q', 'key:r', 'key:s', 'key:t', 'key:u', 'key:v', 'key:w', 'key:x', 'key:y', 'key:z', 'key:0', 'key:1', 'key:2', 'key:3',
    'key:4', 'key:5', 'key:6', 'key:7', 'key:8', 'key:9', 'key:space', 'key:!', 'key:"', 'key:#', 'key:$', 'key:&', "key:'", 'key:(', 'key:)',
    'key:*', 'key:+', 'key:,', 'key:-', 'key:.', 'key:/', 'key::', 'key:;', 'key:<', 'key:=', 'key:>', 'key:?', 'key:@', 'key:[', 'key:\\',
    'key:^', 'key:_', 'key:`', 'key:kp0', 'key:kp1', 'key:kp2', 'key:kp3', 'key:kp4', 'key:kp5', 'key:kp6', 'key:kp7', 'key:kp8', 'key:kp9',
    'key:kp.', 'key:kp,', 'key:kp/', 'key:kp*', 'key:kp-', 'key:kp+', 'key:kpenter', 'key:kp=', 'key:up', 'key:down', 'key:right', 'key:left',
    'key:home', 'key:end', 'key:pageup', 'key:pagedown', 'key:insert', 'key:backspace', 'key:tab', 'key:clear', 'key:return', 'key:delete',
    'key:f1', 'key:f2', 'key:f3', 'key:f4', 'key:f5', 'key:f6', 'key:f7', 'key:f8', 'key:f9', 'key:f10', 'key:f11', 'key:f12',
    'mouse:1', 'mouse:2', 'mouse:3', 'mouse:4', 'mouse:5',
  }
  for _, control in ipairs(controls) do
    self:input_bind(control:right(':'), {control})
  end
  return self
end

-- Unbinds a single control from a given action.
function input:input_unbind(action, control)
  local control_index = table.contains(self.input_state[action].controls, control)
  if control_index then table.remove(self.input_state[action].controls, control_index) end
end

-- Unbinds all controls from a given action.
function input:input_unbind_all(action)
  self.input_state[action] = nil
end

-- Hides or shows the system cursor.
function input:input_set_mouse_visible(value)
  love.mouse.setVisible(value)
end

-- Locks or unlocks the system cursor to/from the screen.
function input:input_set_mouse_locked(value)
  love.mouse.setGrabbed(value)
end

function input:input_update(dt)
  for _, action in ipairs(self.input_actions) do
    self.input_state[action].pressed = false
    self.input_state[action].down = false
    self.input_state[action].released = false
  end

  for _, action in ipairs(self.input_actions) do
    for _, control in ipairs(self.input_state[action].controls) do
      action_type, key = control:left(':'), control:right(':')
      if action_type == 'key' then
        self.input_state[action].pressed = self.input_state[action].pressed or (self.input_keyboard_state[key] and not self.input_previous_keyboard_state[key])
        self.input_state[action].down = self.input_state[action].down or self.input_keyboard_state[key]
        self.input_state[action].released = self.input_state[action].released or (not self.input_keyboard_state[key] and self.input_previous_keyboard_state[key])
      elseif action_type == 'mouse' then
        if key == 'wheel_up' or key == 'wheel_down' then
          self.input_state[action].pressed = self.input_mouse_state[key]
        else
          self.input_state[action].pressed = self.input_state[action].pressed or (self.input_mouse_state[tonumber(key)] and not self.input_previous_mouse_state[tonumber(key)])
          self.input_state[action].down = self.input_state[action].down or self.input_mouse_state[tonumber(key)]
          self.input_state[action].released = self.input_state[action].released or (not self.input_mouse_state[tonumber(key)] and self.input_previous_mouse_state[tonumber(key)])
        end
      elseif action_type == 'axis' then
        if self.input_gamepad then
          local sign = 1
          if key:find('+') then key, sign = key:left('+'), 1
          elseif key:find('-') then key, sign = key:left('-'), -1 end
          local value = self.input_gamepad:getGamepadAxis(key)
          if value ~= 0 then self.input_latest_type = 'gamepad' end
          local down = false
          if sign == 1 then
            if value >= self.input_deadzone then self.input_gamepad_state[key] = value
            else self.input_gamepad_state[key] = false end
          elseif sign == -1 then
            if value <= -self.input_deadzone then self.input_gamepad_state[key] = value
            else self.input_gamepad_state[key] = false end
          end
          self.input_state[action].pressed = self.input_state[action].pressed or (self.input_gamepad_state[key] and not self.input_previous_gamepad_state[key])
          self.input_state[action].down = self.input_state[action].down or self.input_gamepad_state[key]
          self.input_state[action].released = self.input_state[action].released or (not self.input_gamepad_state[key] and self.input_previous_gamepad_state[key])
        end
      elseif action_type == 'button' then
        if self.input_gamepad then
          self.input_state[action].pressed = self.input_state[action].pressed or (self.input_gamepad_state[key] and not self.input_previous_gamepad_state[key])
          self.input_state[action].down = self.input_state[action].down or self.input_gamepad_state[key]
          self.input_state[action].released = self.input_state[action].released or (not self.input_gamepad_state[key] and self.input_previous_gamepad_state[key])
        end
      end
    end
  end
end

function input:input_post_update()
  self.input_previous_keyboard_state = table.copy(self.input_keyboard_state)
  self.input_previous_mouse_state = table.copy(self.input_mouse_state)
  self.input_previous_gamepad_state = table.copy(self.input_gamepad_state)
  self.input_mouse_state.wheel_up = false
  self.input_mouse_state.wheel_down = false
end

-- Returns true if the action has been pressed this frame.
function input:input_is_pressed(action)
  return self.input_state[action].pressed
end

-- Returns true if the action has been released this frame.
function input:input_is_released(action)
  return self.input_state[action].released
end

-- Returns true if the action is being held down this frame.
-- For actions that come from any gamepad axis, the value is returned if it's over the self.input_deadzone value.
function input:input_is_down(action)
  return self.input_state[action].down
end

-- Returns true if the sequence is completed this frame.
-- The sequence is completed if all actions are pressed within their time intervals, for instance:
--   :input_is_sequence_pressed('action_1', 0.5, 'action_2')
-- will return true when 'action_2' is pressed within 0.5 seconds of 'action_1' being pressed.
function input:input_is_sequence_pressed(...)
  return self:input_process_sequence('pressed', ...)
end

-- Returns true if the sequence is released this frame.
-- The sequence must be completed first, and then released. True will be returned on release after completion. So, for instance:
--   :input_is_sequence_released('action_1', 0.5, 'action_2')
-- will return true when 'action_2' is released within 0.5 seconds of 'action_1' being pressed.
function input:input_is_sequence_released(...)
  return self:input_process_sequence('released', ...)
end

-- Returns true as long as the last action in the sequence is being held down.
-- :input_is_sequence_down('action_1', 0.5, 'action_2') -> returns true as long as 'action_2' is held down, if it was pressed within 0.5 seconds of 'action_1' being pressed.
function input:input_is_sequence_down(...)
  return self:input_process_sequence('down', ...)
end

-- Internal function that processes a sequence. Shouldn't be called by gameplay code.
-- action_state can be: 'pressed', 'down', 'released'.
function input:input_process_sequence(action_state, ...)
  local sequence = {...}
  if #sequence == 0 then return end
  if #sequence % 2 == 0 or type(sequence[#sequence]) ~= 'string' then return error('The number of arguments of a sequence must be odd and end in an action.') end
  if #sequence == 1 then 
    return (action_state == 'pressed' and self:input_is_pressed(sequence[1])) or (action_state == 'down' and self:input_is_down(sequence[1])) or (action_state == 'released' and self:input_is_released(sequence[1]))
  end
  table.insert(sequence, 1, 100000)
  local sequence_key = ''
  for _, s in ipairs(sequence) do sequence_key = sequence_key .. tostring(s) end

  if not self.input_sequence_state[sequence_key] then
    self.input_sequence_state[sequence_key] = {sequence = sequence, i = 1}
  else
    local s = self.input_sequence_state[sequence_key]
    local delay = s.sequence[s.i]
    local action = s.sequence[s.i+1]
    local pressed = self:input_is_pressed(action)
    local released = self:input_is_released(action)
    local last_pressed = s.last_pressed or love.timer.getTime()
    if s.i < #s.sequence-1 then
      if pressed and (love.timer.getTime() - last_pressed) <= delay then
        s.last_pressed = love.timer.getTime()
        s.i = s.i + 2
      elseif pressed and (love.timer.getTime() - last_pressed) > delay then
        self.input_sequence_state[sequence_key] = nil
        return false
      end
    elseif s.i == #s.sequence-1 then
      if pressed and (love.timer.getTime() - last_pressed) <= delay then
        s.last_action = true
        s.last_pressed = love.timer.getTime()
      elseif pressed and (love.timer.getTime() - last_pressed) > delay then
        self.input_sequence_state[sequence_key] = nil
        return false
      end
    end

    if action_state == 'pressed' then
      if s.last_action and pressed then
        self.input_sequence_state[sequence_key] = nil
        return true
      end
    elseif action_state == 'released' then
      if s.last_action and released and (love.timer.getTime() - last_pressed) <= delay then
        self.input_sequence_state[sequence_key] = nil
        return true
      elseif s.last_action and released and (love.timer.getTime() - last_pressed) > delay then
        self.input_sequence_state[sequence_key] = nil
        return false
      end
    elseif action_state == 'down' then
      if s.last_action and self:input_is_down(action) then
        return true
      end
      if s.last_action and released then
        self.input_sequence_state[sequence_key] = nil
        return false
      end
    end
  end
end

return input
