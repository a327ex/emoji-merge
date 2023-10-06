-- Creates a new tag that can be used to affect sounds collectively.
-- sfx = sound_tag({volume = 0.5})
-- s = sound(..., {tag = sfx})
local sound_tag = class:class_new()
function sound_tag:sound_tag_init(args)
  self.volume = args and args.volume or 1
  self.effects = args and args.effects
end

return sound_tag
