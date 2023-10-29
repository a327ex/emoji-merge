local sound = class:class_new()
function sound:sound_init(filename)
  local info = love.filesystem.getInfo(filename)
  self.sound_source = love.audio.newSource(filename, (info and info.size and info.size < 5e5) and 'static' or 'stream')
  self.sound_instances = {}
  self.volume = 1
  self.pitch = 1
  table.insert(main.sound_objects, self)
  return self
end

-- Cleans up stopped instances.
function sound:sound_update(dt)
  for i = #self.sound_instances, 1, -1 do
    if not self.sound_instances[i]:isPlaying() then
      table.remove(self.sound_instances, i)
    end
  end
end

-- Plays a sound.
-- sound:play(0.5, an:random_float(0.9, 1.1)) -> returns the instance being played
function sound:sound_play(volume, pitch)
  local instance = self.sound_source:clone()
  local volume = (self.volume or volume or 1)
  local pitch = (self.pitch or pitch or 1)
  instance:setVolume(volume*(self.tag and self.tag.volume or 1))
  instance:setPitch(pitch)
  instance:play()
  table.insert(self.sound_instances, instance)
  return instance
end

function sound:sound_set_volume(volume)
  self.volume = (volume or 1)
  for _, sound_instance in ipairs(self.sound_instances) do
    sound_instance:setVolume(self.volume*(self.tag and self.tag.volume or 1))
  end
end

function sound:sound_set_pitch(pitch)
  self.pitch = (pitch or 1)
  for _, sound_instance in ipairs(self.sound_instances) do
    sound_instance:setPitch(self.pitch)
  end
end

return sound
