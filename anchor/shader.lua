local shader = class:class_new()
function shader:shader_init(vs, fs)
  self.shader = love.graphics.newShader(vs or 'anchor/default.vert', fs)
  return self
end

function shader:shader_send(name, ...)
  self.shader:send(name, ...)
end

return shader
