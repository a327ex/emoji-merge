emoji = function(x, y, args)
  local self = anchor('emoji', args)
  self.value = self.value or 1
  self.rs = value_to_emoji_data[self.value].rs
  self.emoji = value_to_emoji_data[self.value].emoji
  self.stars = value_to_emoji_data[self.value].stars
  self:prs_init(x, y, 0, 2*self.rs/self.emoji.w, 2*self.rs/self.emoji.h)
  self:collider_init('emoji', 'dynamic', 'circle', self.rs)
  self:collider_set_restitution(0.1)
  self:collider_set_gravity_scale(0)
  self:collider_set_mass(value_to_emoji_data[self.value].mass_multiplier*self:collider_get_mass())
  self:timer_init()
  self:hitfx_init()
  self:shake_init()

  if self.hitfx_on_spawn then self:hitfx_use('main', 0.5, nil, nil, 0.15) end
  if self.from_merge then
    self:timer_after(0.01, function()
      local s = math.remap(self.rs, 9, 70, 1, 3)
      for i = 1, self.stars do 
        local r = main:random_angle()
        local d = main:random_float(0.8, 1)
        local x, y = self.x + d*self.rs*math.cos(r), self.y + d*self.rs*math.sin(r)
        main.current_level.objects:container_add(emoji_particle('star', x, y, {hitfx_on_spawn = 0.75, r = r, rotation_v = main:random_float(-2*math.pi, 2*math.pi), s = s, v = s*main:random_float(50, 100)}))
      end
    end)
    if self.vx and self.vy then
      self:collider_apply_impulse(self.vx/3, self.vy/3)
    end
  end

  if main.current_level.round_ending then
    emoji_die(self, 1)
  end

  self.update = emoji_update
  return self
end

emoji_update = function(self, dt)
  self:collider_update_position_and_angle()
  if self.follow_spawner then
    self:collider_set_position(main.current_level.spawner.x - 24, main.current_level.spawner.y + self.rs)
  end
  if self.dying and not self.dying_and_falling then
    self:collider_set_velocity(0, 0)
    self:collider_set_angular_velocity(0)
  end

  -- If it's the second emoji's update and it has already been killed this frame by the collision, do nothing
  -- If this emoji is attached to the spawner still, do nothing
  -- If the round is ending, do nothing
  if not self.dead and not self.follow_spawner and not main.current_level.round_ending then 
    for other, contact in pairs(self.collision_enter['emoji'] or {}) do
      if self.value == other.value and not other.follow_spawner then
        local x, y = contact:getPositions()
        self.dead = true
        other.dead = true
        main.current_level.objects:container_add(emoji_merge_effect(self.x, self.y, {emoji = self.emoji, r = self.r, sx = self.sx, sy = self.sy, target_x = x, target_y = y}))
        main.current_level.objects:container_add(emoji_merge_effect(other.x, other.y, {emoji = other.emoji, r = other.r, sx = other.sx, sy = other.sy, target_x = x, target_y = y}))
        local svx, svy = self:collider_get_velocity()
        local ovx, ovy = other:collider_get_velocity()
        main:timer_after(0.15, function() emoji_fall(main.current_level.emojis:container_add(emoji(x, y, {from_merge = true, hitfx_on_spawn = true, value = self.value + 1, vx = (svx+ovx)/2, vy = (svy+ovy)/2}))) end)
      end
    end
  end

  game2:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, nil, nil, colors.white[0], 
    (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
end

emoji_fall = function(self)
  self:collider_set_gravity_scale(1)
  self:collider_apply_impulse(0, 0.01)
  self.follow_spawner = false
  self.just_fell = true
  self:timer_after(0.5, function() self.just_fell = false end)
end

emoji_die = function(self)
  if self.dying then return end
  self.dying = true
  self:collider_set_gravity_scale(0)
  self:hitfx_use('main', 0.25, nil, nil, 0.15)
  self:timer_after(0.15, function() self:shake_shake(4, 0.5) end)
end
