arena = function(x, y, args)
  local self = anchor('arena', args)
  self.emojis = container()
  self.objects = container()
  self.top_spacing = 40
  self.bottom_spacing = 20
  self.w, self.h = 240, 280
  self.x1, self.y1, self.x2, self.y2 = main.w/2 - self.w/2, self.top_spacing, main.w/2 + self.w/2, main.h - self.bottom_spacing 
  
  self.enter = arena_enter
  self.leave = arena_leave
  self.update = arena_update
  return self
end

arena_enter = function(self)
  self.solid_bottom = self.objects:container_add(solid(main.w/2, self.y2, self.w, 10))
  self.solid_left = self.objects:container_add(solid(self.x1, self.y2 - self.h/2, 10, self.h))
  self.solid_right = self.objects:container_add(solid(self.x2, self.y2 - self.h/2, 10, self.h))
  self.spawner = self.objects:container_add(spawner())
  self.emoji_to_be_dropped = self.emojis:container_add(emoji(main.w/2, self.y1, {follow_spawner = true, value = 1}))
  self.emoji_line_color = colors.green[0]:color_clone()
  self.emoji_line_color.a = 0.32

  main:observer_condition(function()
    for _, emoji in ipairs(self.emojis.objects) do
      if emoji.y < self.y1 and not emoji.follow_spawner and not emoji.just_fell then
        return object
      end
    end
  end, function(emoji)
    arena_end_round_1(self, emoji)
  end)
end

arena_end_round_1 = function(self, emoji)
  main:timer_cancel('emoji_spawn')
  self.round_ending = true
  for _, object in ipairs(self.emojis.objects) do
    emoji_die(object)
  end
end

--[[
arena_end_round_2 = function(self, i)
  main:timer_after(0.3*i, function()
    -- Repeat emoji_die chain until there are no more emojis left
    -- This has to be here in case arena_end_round_1 was called while some emojis were merging and the new ones didn't get tagged initially.
    if #self.emojis:container_get_objects_by_attribute('dying_marked') < #self.emojis.objects then
      emoji_die(emoji, 1)
    else
      spawner_die(self.spawner)
    end
  end)
end
]]--

arena_update = function(self, dt)
  bg:rectangle(main.w/2, main.h/2, 3*main.w, 3*main.h, 0, 0, colors.fg[0])
  bg_gradient:gradient_image_draw(bg_fixed, main.w/2, main.h/2, main.w, main.h)
  if self.emoji_to_be_dropped then bg:line(self.spawner.x - 24, self.spawner.y, self.spawner.x - 24, self.y2, self.emoji_line_color, 2) end

  if main:input_is_pressed('1') and self.emoji_to_be_dropped and not self.round_ending then
    self.spawner:hitfx_use('main', 0.15)
    self.emoji_to_be_dropped:hitfx_use('main', 0.25)

    emoji_fall(self.emoji_to_be_dropped)
    self.emoji_to_be_dropped = nil
    local value = main:random_weighted_pick(30, 25, 20, 15, 10)
    main:timer_after(1, function() self.emoji_to_be_dropped = self.emojis:container_add(emoji(self.spawner.x - 24, self.spawner.y + value_to_emoji_data[value].rs, {follow_spawner = true, value = value})) end, 'emoji_spawn')
  end

  if main:input_is_pressed('2') then
    local min_y, min_object = 1000000, nil
    for i, object in ipairs(self.emojis.objects) do
      if object.y < min_y then
        min_y = object.y
        min_object = object
      end
    end
    arena_end_round_1(self, min_object)
  end

  self.emojis:container_update(dt)
  self.objects:container_update(dt)
  self.emojis:container_remove_dead()
  self.objects:container_remove_dead()
end

arena_exit = function(self)
  self.emoji_to_be_dropped = nil
  self.spawner = nil
  self.solid_bottom = nil
  self.solid_left = nil
  self.solid_right = nil
  self.objects:container_destroy()
end


spawner = function()
  local self = anchor('spawner')
  self.emoji = images.cloud
  self:prs_init(main.pointer.x, main.current_level.y1, 0, 42/self.emoji.w, 42/self.emoji.h)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()
  
  self.update = function(self, dt)
    if not main.current_level.round_ending then self.x, self.y = math.clamp(main.pointer.x, main.current_level.x1 + 40, main.current_level.x2 + 8), 20 end
    game1:draw_image(images.cloud, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  end
  return self
end

spawner_die = function(self)
  self.dying = true
  self:hitfx_use('main', 0.25, nil, nil, 0.15)
  self:timer_after(0.15, function() self:shake_shake(4, 0.5) end)
end


solid = function(x, y, w, h)
  local self = anchor('solid')
  self:prs_init(x, y)
  self:collider_init('solid', 'static', 'rectangle', w, h)
  self:collider_set_friction(1)
  self.update = function(self, dt) game2:rectangle(self.x, self.y, self.w, self.h, 4, 4, colors.green[0]) end
  return self
end
