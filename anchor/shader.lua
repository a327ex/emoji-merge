local shader = class:class_new()
function shader:shader_init(vs, fs)
  self.object = love.graphics.newShader(vs or 'anchor/default.vert', fs)
  return self
end

function shader:shader_send(name, ...)
  self.object:send(name, ...)
end

return shader
