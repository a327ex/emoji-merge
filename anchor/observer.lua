local observer = class:class_new()
local empty_function = function() end
function observer:observer_init()
  self.observer_observers = {}
  table.insert(main.observer_objects, self)
  return self
end

-- Calls the action when self[field] changes.
-- If times is passed in then it only calls action for that amount of times.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other observer actions with the same tag are automatically cancelled.
-- :observer_change('hp', function(current, previous) print(current, previous) end) -> prints self.hp as well as its previous value when self.hp changes
-- :observer_change('can_attack', function(current, previous) if current then self:attack() end end, 5) -> calls self:attack() every time self.can_attack becomes true for a total of 5 times
function observer:observer_change(field, action, times, after, tag)
  local tag = tag or main:random_uid()
  self.observer_observers[tag] = {type = 'change', field = field, current = self[field], previous = self[field], action = action, times = times or 0, max_times = times or 0, after = after or empty_function}
end

-- Calls the action when self[field] changes to a specific value.
-- If times is passed in then it only calls action for that amount of times.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other observer actions with the same tag are automatically cancelled.
-- :observer_value('hp', 0, function() self.dead = true end) -> sets self.dead to true when self.hp becomes 0
function observer:observer_value(field, target_value, action, times, after, tag)
  local tag = tag or main:random_uid()
  self.observer_observers[tag] = {type = 'value', field = field, target_value = target_value, current = self[field], previous = self[field], action = action, times = times or 0, max_times = times or 0, after = after or empty_function}
end

-- Calls the action once when the condition becomes true.
-- This is the same as storing the condition's result in a variable and then using observer_change or observer_value (true) to track it, except that it allows for logic to be locally contained instead of spread across the codebase.
-- If times is passed in then it only calls action for that amount of times.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other observer actions with the same tag are automatically cancelled.
-- :observer_condition(function() return self.hp == 0 end, function() self.dead = true end) -> sets self.dead to true when self.hp becomes 0
function observer:observer_condition(condition, action, times, after, tag)
  local tag = tag or main:random_uid()
  self.observer_observers[tag] = {type = 'condition', condition = condition, last_condition = false, action = action, times = times or 0, max_times = times or 0, after = after or empty_function}
end

-- Cancels an observer based on its tag.
-- This is automatically called if repeated tags are given to timer actions.
function observer:observer_cancel(tag)
  self.observer_observers[tag] = nil
end

-- Returns the current iteration of an observer with the given tag.
-- Useful if you need to know that its the nth time an observer action has been called.
function observer:observer_get_iteration(tag)
  return self.observer_observers[tag].max_times - self.observer_observers[tag].times 
end

function observer:observer_update(dt)
  for tag, o in pairs(self.observer_observers) do
    if o.type == 'change' then
      o.previous = o.current
      o.current = self[o.field]
      if o.previous ~= o.current then
        o.action(o.current, o.previous)
        if o.times > 0 then
          o.times = o.times - 1
          if o.times <= 0 then
            o.after()
            self.observer_observers[tag] = nil
          end
        end
      end
    elseif o.type == 'value' then
      o.previous = o.current
      o.current = self[o.field]
      if o.current == o.target_value and o.previous ~= o.current then
        o.action(o.current, o.previous)
        if o.times > 0 then
          o.times = o.times - 1
          if o.times <= 0 then
            o.after()
            self.observer_observers[tag] = nil
          end
        end
      end
    elseif o.type == 'condition' then
      local condition = o.condition()
      if condition and not o.last_condition then
        o.action()
        if o.times > 0 then
          o.times = o.times - 1
          if o.times <= 0 then
            o.after()
            self.observer_observers[tag] = nil
          end
        end
      end
      o.last_condition = condition
    end
  end
end

return observer
