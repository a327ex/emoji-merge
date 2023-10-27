-- A contact mixin. This is to fix a bug that happens sometimes where contacts get destroyed on the same frame as they were created and then gameplay code can't use it.
-- This is a copy of idbrii's solution here: https://github.com/idbrii/love-windfield/commit/a91c293ced8697e1e48016459ddfbd3021c4338b
-- UPDATE: this solution is not being used because it creates too many contacts per frame.
-- I could pool them but I decided that for now I'd just take positions + normals from the contact in the callback, since that's usually all I need anyway.
local contact = class:class_new()
function contact:contact_init(c)
  self.fixtures = {c:getFixtures()}
  self.normal = {c:getNormal()}
  self.positions = {c:getPositions()}
  self.friction = c:getFriction()
  self.restitution = c:getRestitution()
  self.enabled = c:isEnabled()
  self.touching = c:isTouching()
  return self
end

function contact:contact_get_fixtures()
  return unpack(self.fixtures)
end

function contact:contact_get_normal()
  return unpack(self.normal)
end

function contact:contact_get_positions()
  return unpack(self.positions)
end

return contact
