arena = function(x, y, args)
  local self = anchor('arena', args)
  self.top_spacing = 40
  self.bottom_spacing = 20
  self.w, self.h = 240, 280
  self.x1, self.y1, self.x2, self.y2 = main.w/2 - self.w/2, self.top_spacing, main.w/2 + self.w/2, main.h - self.bottom_spacing 
  self.round_ending = false
  self.enter = arena_enter
  self.exit = arena_exit
  self.update = arena_update
  return self
end

arena_enter = function(self)
  self.emojis = container()
  self.solids = container()
  self.objects = container()
  self.solid_bottom = self.solids:container_add(solid(main.w/2, self.y2, self.w, 10))
  self.solid_left = self.solids:container_add(solid(self.x1, self.y2 - self.h/2, 10, self.h + 10))
  self.solid_right = self.solids:container_add(solid(self.x2, self.y2 - self.h/2, 10, self.h + 10))
  self.spawner = self.objects:container_add(spawner())
  self.emoji_to_be_dropped = self.emojis:container_add(emoji(main.w/2, self.y1, {follow_spawner = true, value = 1}))
  self.emoji_line_color = colors.green[0]:color_clone()
  self.emoji_line_color.a = 0.32

  main:observer_condition(function()
    if self.round_ending then return end
    for _, emoji in ipairs(self.emojis.objects) do
      if emoji.y < self.y1 and not emoji.follow_spawner and not emoji.just_fell then
        return emoji
      end
    end
  end, function(emoji)
    if self.round_ending then return end
    arena_end_round(self, emoji)
  end, nil, nil, 'arena_end_round_observer')
end

arena_update = function(self, dt)
  bg:rectangle(main.w/2, main.h/2, 3*main.w, 3*main.h, 0, 0, colors.fg[0])
  bg_gradient:gradient_image_draw(bg_fixed, main.w/2, main.h/2, main.w, main.h)
  if self.emoji_to_be_dropped and not self.round_ending then bg:line(self.spawner.x - 24, self.spawner.y, self.spawner.x - 24, self.y2, self.emoji_line_color, 2) end

  if main:input_is_pressed('1') and self.emoji_to_be_dropped and not self.round_ending then
    self.spawner:hitfx_use('main', 0.15)
    self.emoji_to_be_dropped:hitfx_use('main', 0.25)

    emoji_fall(self.emoji_to_be_dropped)
    self.emoji_to_be_dropped = nil
    local value = main:random_weighted_pick(30, 25, 20, 15, 10)
    main:timer_after(1, function() self.emoji_to_be_dropped = self.emojis:container_add(emoji(self.spawner.x - 24, self.spawner.y + value_to_emoji_data[value].rs, {follow_spawner = true, value = value})) end, 'emoji_spawn')
  end

  --[[
  if main:input_is_pressed('2') then
    local min_y, min_object = 1000000, nil
    for i, object in ipairs(self.emojis.objects) do
      if object.y < min_y then
        min_y = object.y
        min_object = object
      end
    end
    arena_end_round(self, min_object)
  end
  ]]--

  self.emojis:container_update(dt)
  self.objects:container_update(dt)
  self.solids:container_update(dt)
  self.emojis:container_remove_dead()
  self.objects:container_remove_dead()
  self.solids:container_remove_dead()
end

arena_exit = function(self)
  self.emoji_to_be_dropped = nil
  self.spawner = nil
  self.solid_bottom = nil
  self.solid_left = nil
  self.solid_right = nil
  self.round_ending = false
  main:timer_cancel('arena_end_round_timer_1')
  main:timer_cancel('arena_end_round_timer_2')
  main:timer_cancel('arena_end_round_observer')
  self.solids:container_destroy()
  self.emojis:container_destroy()
  self.objects:container_destroy()
end

arena_end_round = function(self, emoji)
  main:timer_cancel('emoji_spawn')
  table.sort(main.objects, function(a, b) return math.distance(emoji.x, emoji.y, a.x, a.y) < math.distance(emoji.x, emoji.y, b.x, b.y) end)

  local i = 1
  for _, object in ipairs(main.objects) do
    if object:is('solid') or object:is('emoji') or object:is('spawner') then
      main:timer_after(0.025*i, function()
        if object:is('emoji') then
          emoji_die(object)
        elseif object:is('spawner') then
          spawner_die(object)
        elseif object:is('solid') then
          spawner_die(object)
        end
      end)
      i = i + 1
    end
  end
  self.round_ending = true

  main:timer_after(0.025*i + 1, function()
    for _, object in ipairs(main.objects) do
      if object:is('solid') then
        object:collider_set_body_type('dynamic')
        if object.id == self.solid_left.id then
          object:collider_apply_impulse(-100, 0, object.x, object.y - object.h/4 + main:random_float(-object.h/8, object.h/8))
          object:collider_set_gravity_scale(main:random_float(0.3, 0.5))
        elseif object.id == self.solid_right.id then
          object:collider_apply_impulse(100, 0, object.x, object.y - object.h/4 + main:random_float(-object.h/8, object.h/8))
          object:collider_set_gravity_scale(main:random_float(0.3, 0.5))
        elseif object.id == self.solid_bottom.id then
          object:collider_set_gravity_scale(main:random_float(0.1, 0.3))
        end
      elseif object:is('emoji') then
        if self.emoji_to_be_dropped and object.id == self.emoji_to_be_dropped.id then
          object.follow_spawner = false
        end
        object.dying_and_falling = true
        object:collider_set_gravity_scale(main:random_float(0.8, 1.2))
        object:collider_apply_impulse(main:random_float(-20, 20), main:random_float(-40, 0))
        object:collider_apply_angular_impulse(main:random_float(-4*math.pi, 4*math.pi))
      elseif object:is('spawner') then
        object.dying_and_falling = true
        object:collider_set_gravity_scale(main:random_float(1, 1.2))
        local vx = main:random_float(-40, 40)
        object:collider_apply_impulse(vx, main:random_float(-60, -20))
        object:collider_apply_angular_impulse(-math.sign(vx)*main:random_float(-24*math.pi, -8*math.pi))
      end
    end
  end, 'arena_end_round_timer_1')

  main:timer_after(4.5, function()
    main:level_goto('main_menu')
  end, 'arena_end_round_timer_2')
end


spawner = function()
  local self = anchor('spawner')
  self.emoji = images.cloud
  self:prs_init(main.pointer.x, main.current_level.y1, 0, 42/self.emoji.w, 42/self.emoji.h)
  self:collider_init('ghost', 'dynamic', 'circle', 16)
  self:collider_set_gravity_scale(0)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()
  
  self.update = function(self, dt)
    if not main.current_level.round_ending then
      self.x, self.y = math.clamp(main.pointer.x, main.current_level.x1 + 40, main.current_level.x2 + 8), 20
      self:collider_set_position(self.x, self.y)
    end
    if self.dying_and_falling then self:collider_update_position_and_angle() end
    game1:draw_image(images.cloud, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  end
  return self
end

spawner_die = function(self)
  if self.dying then return end
  self.dying = true
  self:hitfx_use('main', 0.1, nil, nil, 0.15)
  self:timer_after(0.15, function() self:shake_shake(2, 0.5) end)
end


solid = function(x, y, w, h)
  local self = anchor('solid')
  self:prs_init(x, y)
  self:collider_init('solid', 'static', 'rectangle', w, h)
  self:collider_set_friction(1)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()
  self.gray_color = color(161, 161, 161)
  self.update = function(self, dt)
    self:collider_update_position_and_angle()
    game2:push(self.x, self.y, self.r)
    game2:rectangle(self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.w*self.springs.main.x, self.h*self.springs.main.x, 4, 4, 
      (self.dying and self.gray_color) or (self.flashes.main.x and colors.white[0]) or (colors.green[0]))
    game2:pop()
  end
  return self
end

solid_die = function(self)
  if self.dying then return end
  self.dying = true
  self:hitfx_use('main', 0.1, nil, nil, 0.15)
  self:timer_after(0.15, function() self:shake_shake(2, 0.5) end)
end
