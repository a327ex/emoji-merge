-- This is a class system that has only mixins and no inheritance.
-- Create a new class and an instance:
--   a = class:class_new()
--   function a:print1() print(1) end
--   a_instance = a()
--   a_instance:print1() -> prints 1
--
-- Create a new class and instance that uses the functions of another class as a mixin:
--   b = class:class_new(a)
--   function b:print2() print(2) end
--   b_instance = b()
--   b_instance:print2() -> prints 2
--   b_instance:print1() -> prints 1
--
-- The "class_new" function can take in multiple other classes/mixins. The "class_add" function can also be called to add mixins to the class:
--   d = class:class_new(a, b, c)
--   d:class_add(e, f)
--
-- Class/mixin function names must not collide. An error will be thrown if this happens.
class = {}
class.__index = class
function class:new() end

function class:class_new(...)
  local c = {}
  c.__is = {}
  c.__is[c] = true
  c.__index = c
  c.__class = c
  setmetatable(c, self)
  c:class_add(...)
  return c
end

function class:class_add(...)
  local mixins = {...}
  for _, mixin in ipairs(mixins) do
    self.__is[mixin] = true
    for k, v in pairs(mixin) do
      if k ~= 'new' and not k:find('__') then
        if self[k] then
          error('collision on function or attribute name "' .. k .. '"')
        elseif self[k] == nil and type(v) == 'function' then
          self[k] = v
        end
      end
    end
  end
end

function class:class_is(c)
  return self.__is[c]
end

function class:__call(...)
  local instance = setmetatable({}, self)
  if main then instance.id = main:random_uid() else instance.id = 0 end
  instance:new(...)
  return instance
end
