local sound = class:class_new()
function sound:sound_init(filename)
  local info = love.filesystem.getInfo(filename)
  self.sound_source = love.audio.newSource(filename, 'static')
  self.sound_instances = {}
  table.insert(main.sound_objects, self)
  return self
end

-- Cleans up stopped instances.
function sound:sound_update(dt)
  for i = #self.sound_instances, 1, -1 do
    if not self.sound_instances[i].instance:isPlaying() then
      table.remove(self.sound_instances, i)
    end
  end

  -- Allows for setting of tag volume to affect all active instances
  for _, instance in ipairs(self.sound_instances) do
    instance.instance:setVolume(instance.volume*(self.tag and self.tag.volume or 1))
  end
end

-- Plays a sound.
-- sound:play(0.5, an:random_float(0.9, 1.1)) -> returns the instance being played
function sound:sound_play(volume, pitch)
  local instance = self.sound_source:clone()
  local volume = (volume or 1)
  local pitch = (pitch or 1)
  instance:setVolume(volume*(self.tag and self.tag.volume or 1))
  instance:setPitch(pitch)
  instance:play()
  table.insert(self.sound_instances, {instance = instance, volume = volume, pitch = pitch})
  return instance
end

function sound:sound_set_volume(volume)
  for _, instance in ipairs(self.sound_instances) do
    instance.volume = volume or 1
  end
end

function sound:sound_set_pitch(pitch)
  for _, instance in ipairs(self.sound_instances) do
    instance.pitch = pitch or 1
  end
end

return sound
