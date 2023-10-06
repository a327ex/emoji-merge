local system = class:class_new()
function system:system_init()
  return self
end

function system:save_table(filename, t)
  love.filesystem.createDirectory("")
  love.filesystem.write(filename, "return " .. table.tostring(t or {}))
end

function system:load_table(filename)
  local t
  local chunk = love.filesystem.load(filename)
  if chunk then t = chunk() end
  return t
end

return system
