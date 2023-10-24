-- The joint mixin is an extension of a box2d joint. It works in conjunction with the physics_world and collider mixins.
-- Because I don't use joints much, specific joint functions are added here on demand instead of preemptively.
-- So for instance, if I need to use RevoluteJoint's setLimits function, I'll define the "joint:revolute_joint_set_limits" function here when I need it.
-- You could also just use self.joint:setLimits directly, but one of the purposes of the engine is having a layer of indirection between gameplay code and any LÖVE calls.
local joint = class:class_new()
function joint:joint_init(joint_type, a, b, c, d, e, f, g, h, i, j, k, l)
  self.joint_type = joint_type

  if self.joint_type == 'distance' then
    self.joint = love.physics.newDistanceJoint(a.body, b.body, c, d, e, f, g)
  elseif self.joint_type == 'friction' then
    self.joint = love.physics.newFrictionJoint(a.body, b.body, c, d, e, f, g)
  elseif self.joint_type == 'gear' then
    self.joint = love.physics.newGearJoint(a.joint, b.joint, c, d)
  elseif self.joint_type == 'motor' then
    self.joint = love.physics.newMotorJoint(a.body, b.body, c, d)
  elseif self.joint_type == 'mouse' then
    self.joint = love.physics.newMouseJoint(a.body, b, c) 
  elseif self.joint_type == 'prismatic' then
    self.joint = love.physics.newPrismaticJoint(a.body, b.body, c, d, e, f, g, h, i, j)
  elseif self.joint_type == 'pulley' then
    self.joint = love.physics.newPulleyJoint(a.body, b.body, c, d, e, f, g, h, i, j, k, l)
  elseif self.joint_type == 'revolute' then
    self.joint = love.physics.newRevoluteJoint(a.body, b.body, c, d, e)
  elseif self.joint_type == 'rope' then
    self.joint = love.physics.newRopeJoint(a.body, b.body, c, d, e, f, g, h)
  elseif self.joint_type == 'weld' then
    self.joint = love.physics.newWeldJoint(a.body, b.body, c, d, e)
  elseif self.joint_type == 'wheel' then
    self.joint = love.physics.newWheelJoint(a.body, b.body, c, d, e, f, g, h, i)
  end
  
  return self
end

function joint:joint_draw(layer, color, line_width, z)
  local x1, y1, x2, y2 = self.joint:getAnchors()
  layer:circle(x1, y1, 4, color, line_width, z)
  layer:circle(x2, y2, 4, color, line_width, z)
end

-- Returns the objects attached to this joint.
function joint:joint_get_objects()
  local body1, body2 = self.joint:getBodies()
  return body1:getFixtures()[1]:getUserData(), body2:getFixtures()[1]:getUserData()
end

function joint:revolute_joint_get_angle()
  return self.joint:getJointAngle()
end

function joint:revolute_joint_set_limits_enabled(value)
  self.joint:setLimitsEnabled(value)
end

function joint:revolute_joint_set_limits(lower, upper)
  self.joint:setLimits(lower, upper)
end

function joint:joint_destroy()
  self.dead = true
  if self.joint and not self.joint:isDestroyed() then
    self.joint:destroy()
    self.joint = nil
  end
end

return joint
