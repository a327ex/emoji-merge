arena = class:class_new(anchor)
function arena:new(x, y, args)
  self:anchor_init('arena', args)
  self:timer_init()
  self:observer_init()
  self.top_spacing = 40
  self.bottom_spacing = 20
  self.w, self.h = 240, 280
  self.score_x = (main.w - self.w)/4 - 4
  self.next_x = main.w - (main.w - self.w)/4 - 4
  self.x1, self.y1, self.x2, self.y2 = main.w/2 - self.w/2, self.top_spacing, main.w/2 + self.w/2, main.h - self.bottom_spacing 
end

function arena:update(dt)
  bg:rectangle(main.w/2, main.h/2, 3*main.w, 3*main.h, 0, 0, colors.fg[0])
  bg_gradient:gradient_image_draw(bg_fixed, main.w/2, main.h/2, main.w, main.h)
  if self.emoji_to_be_dropped and not self.round_ending then bg:line(self.spawner.x - 24, self.spawner.y, self.spawner.x - 24, self.y2, self.emoji_line_color, 2) end
  -- game1:rectangle(self.next_x, 72, 56, 56, 4, 4, colors.fg[0])

  if main:input_is_pressed('1') and self.emoji_to_be_dropped and not self.round_ending then
    self.spawner:hitfx_use('main', 0.15)
    self.emoji_to_be_dropped:hitfx_use('main', 0.25)
    self.emoji_to_be_dropped:drop()
    self.emoji_to_be_dropped = nil
    local value = main:random_weighted_pick(30, 25, 20, 15, 10)
    self:timer_after(0.75, function()
      self.emoji_to_be_dropped = self.next_emoji
      self.emoji_to_be_dropped.next_emoji = false
      self.emoji_to_be_dropped.follow_spawner = true
      self.emoji_to_be_dropped:collider_set_position(self.spawner.x - 24, self.spawner.y + self.emoji_to_be_dropped.rs)
      self.emoji_to_be_dropped:hitfx_use('main', 0.25)
      self.next_emoji = self.emojis:container_add(emoji(self.next_x, 64, {next_emoji = true, value = value}))
      self.next_emoji:hitfx_use('main', 0.25)
    end, 'emoji_spawn')
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
    self:end_round(min_object)
  end
  ]]--

  self.emojis:container_update(dt)
  self.objects:container_update(dt)
  self.emojis:container_remove_dead()
  self.objects:container_remove_dead()
end

function arena:enter()
  self.emojis = container()
  self.objects = container()
  self.solid_bottom = self.objects:container_add(solid(main.w/2, self.y2, self.w, 10))
  self.solid_left = self.objects:container_add(solid(self.x1, self.y2 - self.h/2, 10, self.h + 10))
  self.solid_right = self.objects:container_add(solid(self.x2, self.y2 - self.h/2, 10, self.h + 10))
  self.spawner = self.objects:container_add(spawner())
  self.emoji_line_color = colors.green[0]:color_clone()
  self.emoji_line_color.a = 0.32

  self.emoji_to_be_dropped = self.emojis:container_add(emoji(main.w/2, self.y1, {follow_spawner = true, value = 1}))
  local value = main:random_int(1, 5)
  self.next_emoji = self.emojis:container_add(emoji(self.next_x, 64, {next_emoji = true, value = value}))
  self.score = 0
  self.score_board = self.objects:container_add(score_board(self.score_x, 106))
  self.round_ending = false

  self:observer_condition(function()
    if self.round_ending then return end
    for _, emoji in ipairs(self.emojis.objects) do
      if emoji.y < self.y1 and not emoji.follow_spawner and not emoji.just_fell then
        return emoji
      end
    end
  end, function(emoji)
    if self.round_ending then return end
    self:end_round(emoji)
  end, nil, nil, 'end_round_observer')
end

function arena:exit()
  self.emoji_to_be_dropped = nil
  self.spawner = nil
  self.solid_bottom = nil
  self.solid_left = nil
  self.solid_right = nil
  self.score_board = nil
  self.round_ending = false
  self:timer_cancel('end_round_timer_1')
  self:timer_cancel('end_round_timer_2')
  self:timer_cancel('end_round_observer')
  self.emojis:container_destroy()
  self.objects:container_destroy()
end

function arena:end_round(emoji)
  self:timer_cancel('emoji_spawn')
  table.sort(main.objects, function(a, b) return math.distance(emoji.x, emoji.y, a.x, a.y) < math.distance(emoji.x, emoji.y, b.x, b.y) end)

  local i = 1
  for _, object in ipairs(main.objects) do
    if object:is('solid') or object:is('emoji') or object:is('spawner') or object:is('emoji_character') then
      self:timer_after(0.025*i, function() object:die() end)
      i = i + 1
    end
  end
  self.round_ending = true

  self:timer_after(0.025*i + 1, function()
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
        if self.emoji_to_be_dropped and object.id == self.emoji_to_be_dropped.id then object.follow_spawner = false end
        if self.next_emoji and object.id == self.next_emoji.id then object.next_emoji = false end
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
      elseif object:is('emoji_character') then
        object.dying_and_falling = true
        object:collider_set_gravity_scale(main:random_float(1, 1.2))
        local vx = main:random_float(-20, 20)
        object:collider_apply_impulse(vx, main:random_float(-20, -10))
        object:collider_apply_angular_impulse(-math.sign(vx)*main:random_float(-12*math.pi, -6*math.pi))
      end
    end
  end, 'end_round_timer_1')

  self:timer_after(4.5, function()
    main:level_goto('main_menu')
  end, 'end_round_timer_2')
end




score_board = class:class_new(anchor)
function score_board:new(x, y, args)
  self:anchor_init('score_board', args)
  self.emoji = images.calendar
  self:prs_init(x, y, 0, 96/self.emoji.w, 96/self.emoji.h)
  self:collider_init('solid', 'dynamic', 'rectangle', 100, 100)
  self:collider_set_gravity_scale(0)
  self:timer_init()
  self:hitfx_init()
  self:shake_init()
  
end

function score_board:update(dt)
  self:collider_update_position_and_angle()
  game2:push(self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x)
    game2:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, 1, 1, nil, nil, colors.white[0], (self.flashes.main.x and shaders.combine) or (self.dying and shaders.grayscale))
    game2:draw_text_centered('SCORE', font_2, self.x, self.y - 18, 0, 1, 1, 0, 0, colors.fg[0])
    local score = main.current_level.score
    game2:draw_text_centered(tostring(score), (score < 999 and font_3) or font_4, self.x, self.y + 18, 0, 1, 1, 0, 0, colors.calendar_gray[0])
  game2:pop()
  -- self:collider_draw(game2, colors.white[0], 2)
end

--[[
score_ui = class:class_new(anchor)
function score_ui:new(x, y, args)
  self:anchor_init('score_ui', args)
  self:prs_init(x, y)
  self:collider_init('ghost', 'dynamic', 'rectangle', 144, 56)
  self:collider_set_gravity_scale(0)
  self.score_text = emoji_text('score', self.x, self.y - 32, {character_size = 16, character_spacing = 4})
  self.score_value_text = emoji_text('0000', self.x, self.y, {character_size = 24, character_spacing = 6, color = 'black'})
  self.r_spring = spring(0, main:random_float(0, 4*math.pi), 0)
  self.r_spring:spring_pull(math.pi/128)
end

function score_ui:update(dt)
  -- self.r_spring:spring_update(dt)
  game1:push(self.x, self.y, self.r_spring.x, self.sx, self.sy)
    game1:rectangle(self.x, self.y, self.w, self.h, 4, 4, colors.brown[0])
  game1:pop()
  self.score_text:update(dt)
  self.score_value_text:update(dt)
end

function score_ui:change_score_text(new_score_text)
  for i = 1, 4 do
    local new, old = utf8.sub(new_score_text, i, i), utf8.sub(self.text, i, i)
    if new ~= old then
      local c = tostring(tonumber(new))
      self.score_value_text.characters[i].character = c
      self.score_value_text.characters[i]:change_effect()
    end
  end
  self.text = new_score_text
end




next_ui = class:class_new(anchor)
function next_ui:new(x, y, args)
  self:anchor_init('next_ui', args)
  self.next_text = emoji_text('next', self.next_x, 24, {character_size = 16, character_spacing = 4})
end

function next_ui:update(dt)

end
]]--




emoji_text = class:class_new(anchor)
function emoji_text:new(text, x, y, args)
  self:anchor_init('emoji_text', args)
  self:prs_init(x, y)
  self.text = text
  self.character_size = self.character_size or 24
  self.character_spacing = self.character_spacing or 6
  self.text_length = utf8.len(self.text)
  self.w, self.h = self.character_size*self.text_length + self.character_spacing*(self.text_length-1), self.character_size

  self.characters = {}
  local x = self.x - self.w/2 + self.character_size/2
  for i = 1, utf8.len(self.text) do
    local c = utf8.sub(self.text, i, i)
    table.insert(self.characters, emoji_character(x, self.y, {character = c, color = self.color, w = self.character_size}))
    x = x + (self.character_size + self.character_spacing)
  end
end

function emoji_text:update(dt)
  for _, character in ipairs(self.characters) do character:update(dt) end
end




emoji_character = class:class_new(anchor)
function emoji_character:new(x, y, args)
  self:anchor_init('emoji_character', args)
  self.emoji = images[self.character]
  self.color = self.color or 'blue_original'
  self:prs_init(x, y, 0, self.w/self.emoji.w, self.w/self.emoji.h)
  self:collider_init('ghost', 'dynamic', 'rectangle', self.w, self.w)
  self:collider_set_gravity_scale(0)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()
end

function emoji_character:update(dt)
  self:collider_update_position_and_angle()
  draw_emoji_character(ui2, self.character, self.x + self.shake_amount.x, self.y + self.shake_amount.y + self.oy, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, 
    (self.flashes.main.x and 'white') or (self.dying and 'gray') or self.color)
end

function emoji_character:change_effect()
  self:hitfx_use('main', 0.2, nil, nil, 0.15)
  self.oy = 6
  self:timer_tween(0.2, self, {oy = 0}, math.linear, function() self.oy = 0 end, 'oy')
end

function emoji_character:die()
  if self.dying then return end
  self.dying = true
  self:collider_set_gravity_scale(0)
  self:hitfx_use('main', 0.25, nil, nil, 0.15)
  self:timer_after(0.15, function() self:shake_shake(4, 0.5) end)
end




spawner = class:class_new(anchor)
function spawner:new(x, y, args)
  self:anchor_init('spawner', args)
  self.emoji = images.cloud
  self:prs_init(main.pointer.x, main.current_level.y1, 0, 42/self.emoji.w, 42/self.emoji.h)
  self:collider_init('ghost', 'dynamic', 'circle', 16)
  self:collider_set_gravity_scale(0)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()
end

function spawner:update(dt)
  if not main.current_level.round_ending then
    self.x, self.y = math.clamp(main.pointer.x, main.current_level.x1 + 40, main.current_level.x2 + 8), 20
    self:collider_set_position(self.x, self.y)
  end
  if self.dying_and_falling then self:collider_update_position_and_angle() end
  game1:draw_image(images.cloud, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
    (self.flashes.main.x and shaders.combine) or (self.dying and shaders.grayscale))
end

function spawner:die()
  if self.dying then return end
  self.dying = true
  self:hitfx_use('main', 0.1)
  self:timer_after(0.15, function() self:shake_shake(2, 0.5) end)
end




solid = class:class_new(anchor)
function solid:new(x, y, w, h)
  self:anchor_init('solid')
  self:prs_init(x, y)
  self:collider_init('solid', 'static', 'rectangle', w, h)
  self:collider_set_friction(1)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()
  self.gray_color = color(161, 161, 161)
end

function solid:update(dt)
  self:collider_update_position_and_angle()
  game2:push(self.x, self.y, self.r)
  game2:rectangle(self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.w*self.springs.main.x, self.h*self.springs.main.x, 4, 4, 
    (self.flashes.main.x and colors.white[0]) or (self.dying and self.gray_color) or (colors.green[0]))
  game2:pop()
end

function solid:die()
  if self.dying then return end
  self.dying = true
  self:hitfx_use('main', 0.1)
  self:timer_after(0.15, function() self:shake_shake(2, 0.5) end)
end
