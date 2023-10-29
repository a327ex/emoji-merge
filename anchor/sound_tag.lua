-- Creates a new tag that can be used to affect sounds collectively.
-- sfx = sound_tag({volume = 0.5})
-- s = sound(..., {tag = sfx})
local sound_tag = class:class_new()
function sound_tag:sound_tag_init(args)
  self.volume = args and args.volume or 1
  self.effects = args and args.effects
  return self
end

function sound_tag:sound_tag_set_volume(volume)
  self.volume = volume or 1
  for name, sound in pairs(sounds) do
    if sound.tag == self then
      sound:sound_set_volume()
    end
  end
end

return sound_tag
