arena = class:class_new(anchor)
function arena:new(x, y, args)
  self:anchor_init('arena', args)
  self:timer_init()
  self:observer_init()
  self.top_spacing, self.bottom_spacing = 40, 20
  self.w, self.h = 252, 294
  self.x1, self.y1, self.x2, self.y2 = main.w/2 - self.w/2, self.top_spacing, main.w/2 + self.w/2, main.h - self.bottom_spacing
  self.score_x, self.next_x = (self.x1-5)/2, self.x2 + 5 + (main.w - (self.x2 + 5))/2 + 1

  -- main.camera:camera_zoom_to(0.5)
end

function arena:update(dt)
  bg:rectangle(main.w/2, main.h/2, 3*main.w, 3*main.h, 0, 0, colors.fg[0])

  self.emojis:container_update(dt)
  self.plants:container_update(dt)
  self.objects:container_update(dt)
  self.emojis:container_remove_dead()
  self.plants:container_remove_dead()
  self.objects:container_remove_dead()
end

function arena:enter()
  self.emojis = container()
  self.plants = container()
  self.objects = container()

  self.solid_top = self.objects:container_add(solid(main.w/2, -120, 2*self.w, 10))
  self.solid_bottom = self.objects:container_add(solid(main.w/2, self.y2, self.w, 10))
  self.solid_left = self.objects:container_add(solid(self.x1, self.y2 - self.h/2, 10, self.h + 10))
  self.solid_right = self.objects:container_add(solid(self.x2, self.y2 - self.h/2, 10, self.h + 10))
  self.solid_left_joint = self.objects:container_add(joint('weld', self.solid_left, self.solid_bottom, self.x1, self.y2))
  self.solid_right_joint = self.objects:container_add(joint('weld', self.solid_right, self.solid_bottom, self.x2, self.y2))

  self.score = 0
  self.score_board = self.objects:container_add(board('score', self.score_x, 120))
  self.score_left_chain = self.objects:container_add(emoji_chain('vine_chain', self.solid_top, self.score_board, self.score_board.x - 21, self.solid_top.y, self.score_board.x - 21, self.score_board.y - self.score_board.h/2))
  self.score_right_chain = self.objects:container_add(emoji_chain('vine_chain', self.solid_top, self.score_board, self.score_board.x + 21, self.solid_top.y, self.score_board.x + 21, self.score_board.y - self.score_board.h/2))
  self.score_board:collider_apply_impulse(main:random_sign(50)*main:random_float(100, 200), 0)
  self.best = 0
  self.best_board = self.objects:container_add(board('best', self.score_x, 253))
  self.best_chain = self.objects:container_add(emoji_chain('vine_chain', self.score_board, self.best_board, self.best_board.x, self.score_board.y + self.score_board.h/2, self.best_board.x, self.best_board.y - self.best_board.h/2))
  self.best_board:collider_apply_impulse(main:random_sign(50)*main:random_float(75, 150), 0)
  self.next = main:random_int(1, 5)
  self.next_board = self.objects:container_add(board('next', self.next_x, 108))
  self.next_left_chain = self.objects:container_add(emoji_chain('vine_chain', self.solid_top, self.next_board, self.next_board.x - 21, self.solid_top.y, self.next_board.x - 21, self.next_board.y - self.next_board.h/2))
  self.next_right_chain = self.objects:container_add(emoji_chain('vine_chain', self.solid_top, self.next_board, self.next_board.x + 21, self.solid_top.y, self.next_board.x + 21, self.next_board.y - self.next_board.h/2))
  self.next_board:collider_apply_impulse(main:random_sign(50)*main:random_float(100, 200), 0)
  self.emojivolution_chain = self.objects:container_add(emoji_chain('emojivolution', self.solid_right, nil, self.solid_right.x + 5, 188, self.solid_right.x + 5 + 14*13, 188, {chain_part_size = 14}))

  self:spawn_plants()
end

function arena:exit()
  
end

function arena:start_round()
  
end

function arena:merge_emojis()
  
end

function arena:drop_emoji()
  
end

function arena:choose_next_emoji()
  
end

function arena:end_round()
  
end











board = class:class_new(anchor)
function board:new(board_type, x, y, args)
  self:anchor_init('score_board', args)
  self.board_type = board_type
  if self.board_type == 'score' then
    self.emoji = images.red_board
    self:prs_init(x, y, 0, 96/self.emoji.w, 96/self.emoji.h)
    self:collider_init('solid', 'dynamic', 'rectangle', 88, 88)
  elseif self.board_type == 'best' then
    self.emoji = images.green_board
    self:prs_init(x, y, 0, 80/self.emoji.w, 80/self.emoji.h)
    self:collider_init('solid', 'dynamic', 'rectangle', 70, 70)
  elseif self.board_type == 'next' then
    self.emoji = images.blue_board
    self:prs_init(x, y, 0, 112/self.emoji.w, 112/self.emoji.h)
    self:collider_init('solid', 'dynamic', 'rectangle', 96, 96)
  end
  self:collider_set_damping(0.2)
  self:timer_init()
  self:hitfx_init()
  self:shake_init()
end

function board:update(dt)
  self:collider_update_position_and_angle()
  game2:push(self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x)
    game2:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, 1, 1, nil, nil, colors.white[0], (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game2:pop()
  game2:push(self.x, self.y, self.r)
    if self.board_type == 'score' then
      game2:draw_text_centered(self.board_type:upper(), font_2, self.x, self.y - 24, 0, 1, 1, 0, 0, colors.fg[0])
      local score = main.current_level.score
      game2:draw_text_centered(tostring(score), (score < 999 and font_4) or font_3, self.x, self.y + 12, 0, 1, 1, 0, 0, colors.calendar_gray[0])
    elseif self.board_type == 'best' then
      game2:draw_text_centered(self.board_type:upper(), font_2, self.x, self.y - 20, 0, 1, 1, 0, 0, colors.fg[0])
      local best = main.current_level.best
      game2:draw_text_centered(tostring(best), (best < 999 and font_3) or font_2, self.x, self.y + 10, 0, 1, 1, 0, 0, colors.calendar_gray[0])
    elseif self.board_type == 'next' then
      game2:draw_text_centered(self.board_type:upper(), font_2, self.x, self.y - 28, 0, 1, 1, 0, 0, colors.fg[0])
      game3:push(self.x, self.y, self.r)
      local next = main.current_level.next
      if next then
        local sx = 2*value_to_emoji_data[next].rs/value_to_emoji_data[next].emoji.w
        local sy = sx
        next = value_to_emoji_data[next].emoji
        game3:draw_image(next, self.x + self.shake_amount.x, self.y + 15 + self.shake_amount.y, 0, sx, sy, nil, nil, colors.white[0], (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
      end
      game3:pop()
    end
  game2:pop()
  -- self:collider_draw(game2, colors.white[0], 2)
end




emoji_chain = class:class_new(anchor)
function emoji_chain:new(emoji, collider_1, collider_2, x1, y1, x2, y2, args)
  self:anchor_init('emoji_chain', args)
  self.emoji = emoji
  self.x1, self.y1, self.x2, self.y2 = x1, y1, x2, y2

  self.chain_parts = {}
  self.joints = {}
  local chain_part_size = self.chain_part_size or 18
  local total_chain_size = math.distance(x1, y1, x2, y2)
  local chain_part_amount = math.ceil(total_chain_size/chain_part_size)
  local r = math.angle_to_point(x1, y1, x2, y2)
  for i = 1, chain_part_amount do
    local d = 0.5*chain_part_size + (i-1)*chain_part_size
    if self.emoji == 'emojivolution' then
      emoji = utf8.sub(self.emoji, i, i)
      table.insert(self.chain_parts, main.current_level.objects:container_add(chain_part(emoji, x1 + d*math.cos(r), y1 + d*math.sin(r), {character = true, r = r, w = chain_part_size})))
    else
      table.insert(self.chain_parts, main.current_level.objects:container_add(chain_part(emoji, x1 + d*math.cos(r), y1 + d*math.sin(r), {r = r, w = chain_part_size})))
    end
  end
  for i, chain_part in ipairs(self.chain_parts) do
    local next_chain_part = self.chain_parts[i+1]
    if next_chain_part then
      local x, y = (chain_part.x + next_chain_part.x)/2, (chain_part.y + next_chain_part.y)/2
      table.insert(self.joints, main.current_level.objects:container_add(joint('revolute', chain_part, next_chain_part, x, y)))
    end
  end
  table.insert(self.joints, main.current_level.objects:container_add(joint('revolute', collider_1, self.chain_parts[1], x1, y1)))
  if collider_2 then table.insert(self.joints, main.current_level.objects:container_add(joint('revolute', self.chain_parts[#self.chain_parts], collider_2, x2, y2, true))) end

  if self.emoji == 'emojivolution' then
    for _, joint in ipairs(self.joints) do
      joint:revolute_joint_set_limits_enabled(true)
      joint:revolute_joint_set_limits(0, 0)
    end
    for _, chain_part in ipairs(self.chain_parts) do
      chain_part:collider_set_mass(chain_part:collider_get_mass()*0.05)
    end
  end
end

function emoji_chain:update(dt)

end

function emoji_chain:change_target_collider(collider)
  local last_joint = self.joints[#self.joints]
  last_joint:joint_destroy()
  local last_chain_part = self.chain_parts[#self.chain_parts]
  local x, y = last_chain_part.x + 0.5*last_chain_part.w*math.cos(last_chain_part.r), last_chain_part.y + 0.5*last_chain_part.w*math.sin(last_chain_part.r)
  collider:collider_set_position(x, y)
  collider:collider_update_position_and_angle()
  self.joints[#self.joints] = main.current_level.objects:container_add(joint('revolute', last_chain_part, collider, x, y, true))
end




chain_part = class:class_new(anchor)
function chain_part:new(emoji, x, y, args)
  self:anchor_init('chain_part', args)
  if self.character then
    self.emoji = emoji
    self:prs_init(x, y, self.r, self.w/images[emoji].w, self.w/images[emoji].h)
    self:collider_init('solid', 'dynamic', 'rectangle', self.w, self.w)
  else 
    self.emoji = images[emoji or 'chain']
    self:prs_init(x, y, self.r, self.w/self.emoji.w, self.w/self.emoji.h)
    self:collider_init('solid', 'dynamic', 'rectangle', self.w, self.w/2)
  end
  self:collider_set_damping(0.2)
  self:collider_set_angle(self.r)
  self:timer_init()
  self:hitfx_init()
  self:shake_init()
end

function chain_part:update(dt)
  self:collider_update_position_and_angle()
  if self.character then
    draw_emoji_character(game1, self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, 
      (self.dying and 'gray') or (self.flashes.main.x and 'white') or 'blue_original')
  else
    game1:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  end
  --self:collider_draw(ui1, colors.blue[0], 1)
end




--[[
function arena:update(dt)
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
      self.emoji_to_be_dropped.follow_spawner = true
      self.emoji_to_be_dropped:collider_set_position(self.spawner.x - 24, self.spawner.y + self.emoji_to_be_dropped.rs)
      self.emoji_to_be_dropped:collider_set_velocity(0, 0)
      self.emoji_to_be_dropped:collider_set_angular_velocity(0)
      self.emoji_to_be_dropped:collider_set_gravity_scale(0)
      self.emoji_to_be_dropped:collider_set_fixed_rotation(false)
      self.emoji_to_be_dropped:collider_update_position_and_angle()
      self.emoji_to_be_dropped:hitfx_use('main', 0.25)
      self.next_emoji = self.emojis:container_add(emoji(self.next_x, 128, {next_emoji = true, value = value}))
      self.next_emoji:collider_set_fixed_rotation(true)
      self.next_emoji:collider_apply_impulse(main:random_float(-50, 50), 0)
      self.next_emoji:hitfx_use('main', 0.25)
      self.next_emoji_chain:change_target_collider(self.next_emoji)
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

  self.emojis:container_update(dt)
  self.objects:container_update(dt)
  self.emojis:container_remove_dead()
  self.objects:container_remove_dead()
end

function arena:enter()

  self.spawner = self.objects:container_add(spawner())
  self.emoji_line_color = colors.green[0]:color_clone()
  self.emoji_line_color.a = 0.32

  self.emoji_to_be_dropped = self.emojis:container_add(emoji(main.w/2, self.y1, {follow_spawner = true, value = 1}))
  local value = main:random_int(1, 5)
  self.next_emoji = self.emojis:container_add(emoji(self.next_x, 115, {next_emoji = true, value = value}))
  self.next_emoji_chain = self.objects:container_add(emoji_chain(self.solid_top, self.next_emoji, self.next_emoji.x, -90, self.next_emoji.x, self.next_emoji.y - self.next_emoji.rs))
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
]]--




function arena:spawn_plants()
  local spawn_plant_set = function(x, y, direction)
    local n = main:random_weighted_pick(20, 20, 20, 10, 10, 10, 5, 5)
    local r = (direction == 'up' and -math.pi/2) or (direction == 'down' and math.pi/2) or (direction == 'left' and math.pi) or (direction == 'right' and 0)
    if n == 1 then
      self.plants:container_add(arena_plant(x + 5*math.cos(r - math.pi/2), y + 5*math.sin(r - math.pi/2), {w = 11, h = 11, layer = game3, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 5*math.cos(r + math.pi/2), y + 5*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'sheaf', direction = direction}))
    elseif n == 2 then
      self.plants:container_add(arena_plant(x + 5*math.cos(r - math.pi/2), y + 5*math.sin(r - math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 5*math.cos(r + math.pi/2), y + 5*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'seedling', direction = direction}))
    elseif n == 3 then
      self.plants:container_add(arena_plant(x + 8*math.cos(r - math.pi/2), y + 8*math.sin(r - math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'sheaf', direction = direction}))
      self.plants:container_add(arena_plant(x + 0*math.cos(r - math.pi/2), y + 0*math.sin(r - math.pi/2), {w = 20, h = 20, layer = game1, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 8*math.cos(r + math.pi/2), y + 8*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game1, emoji = 'sheaf', direction = direction}))
    elseif n == 4 then
      self.plants:container_add(arena_plant(x + 8*math.cos(r - math.pi/2), y + 8*math.sin(r - math.pi/2), {w = 20, h = 20, layer = game3, emoji = 'blossom', direction = direction}))
      self.plants:container_add(arena_plant(x + 1*math.cos(r + math.pi/2), y + 1*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game1, emoji = 'sheaf', direction = direction}))
      self.plants:container_add(arena_plant(x + 10*math.cos(r + math.pi/2), y + 10*math.sin(r + math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'seedling', direction = direction}))
    elseif n == 5 then
      self.plants:container_add(arena_plant(x + 12*math.cos(r - math.pi/2), y + 12*math.sin(r - math.pi/2), {w = 16, h = 16, layer = game1, emoji = 'sheaf', direction = direction}))
      self.plants:container_add(arena_plant(x + 0*math.cos(r + math.pi/2), y + 0*math.sin(r + math.pi/2), {w = 20, h = 20, layer = game3, emoji = 'tulip', direction = direction}))
      self.plants:container_add(arena_plant(x + 12*math.cos(r + math.pi/2), y + 12*math.sin(r + math.pi/2), {w = 12, h = 12, layer = game3, emoji = 'seedling', direction = direction}))
    elseif n == 6 then
      self.plants:container_add(arena_plant(x + 12*math.cos(r - math.pi/2), y + 12*math.sin(r - math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'sheaf', direction = direction}))
      self.plants:container_add(arena_plant(x + 0*math.cos(r - math.pi/2), y + 0*math.sin(r - math.pi/2), {w = 17, h = 17, layer = game1, emoji = 'four_leaf_clover', direction = direction}))
      self.plants:container_add(arena_plant(x + 8*math.cos(r + math.pi/2), y + 8*math.sin(r + math.pi/2), {w = 12, h = 12, layer = game3, emoji = 'seedling', direction = direction}))
    elseif n == 7 then
      self.plants:container_add(arena_plant(x + 0*math.cos(r - math.pi/2), y + 0*math.sin(r - math.pi/2), {w = 20, h = 20, layer = game1, emoji = 'blossom', direction = direction}))
      self.plants:container_add(arena_plant(x + 10*math.cos(r - math.pi/2), y + 10*math.sin(r - math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'sheaf', direction = direction}))
      self.plants:container_add(arena_plant(x + 5*math.cos(r + math.pi/2), y + 5*math.sin(r + math.pi/2), {w = 11, h = 11, layer = game3, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 10*math.cos(r + math.pi/2), y + 10*math.sin(r + math.pi/2), {w = 11, h = 11, layer = game3, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 20*math.cos(r + math.pi/2), y + 20*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'sheaf', direction = direction}))
    elseif n == 8 then
      self.plants:container_add(arena_plant(x + 0*math.cos(r - math.pi/2), y + 0*math.sin(r - math.pi/2), {w = 20, h = 20, layer = game3, emoji = 'tulip', direction = direction}))
      self.plants:container_add(arena_plant(x + 16*math.cos(r - math.pi/2), y + 16*math.sin(r - math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'tulip', direction = direction}))
      self.plants:container_add(arena_plant(x + 16*math.cos(r + math.pi/2), y + 16*math.sin(r + math.pi/2), {w = 12, h = 12, layer = game1, emoji = 'tulip', direction = direction}))
    end
  end

  -- Bottom solid
  local plant_positions = {}
  for x = self.x1 + 25, self.x1 + self.w - 25, 25 do table.insert(plant_positions, {x = x, y = self.y2 - 15, direction = 'up'}) end
  for i = 1, main:random_int(4, 5) do
    local p = main:random_table_remove(plant_positions)
    spawn_plant_set(p.x, p.y, p.direction)
  end

  -- Left solid
  plant_positions = {}
  for y = self.y1 + 20, self.y1 + self.h - 20, 30 do table.insert(plant_positions, {x = self.x1 + 15, y = y, direction = 'right'}) end
  for i = 1, main:random_int(2, 3) do
    local p = main:random_table_remove(plant_positions)
    spawn_plant_set(p.x, p.y, p.direction)
  end

  -- Right solid
  plant_positions = {}
  for y = self.y1 + 20, self.y1 + self.h - 20, 30 do table.insert(plant_positions, {x = self.x2 - 15, y = y, direction = 'left'}) end
  for i = 1, main:random_int(2, 3) do
    local p = main:random_table_remove(plant_positions)
    spawn_plant_set(p.x, p.y, p.direction)
  end

  -- Score board
  local random_plant = function(plants) return main:random_table(plants or {'sheaf', 'blossom', 'seedling', 'four_leaf_clover'}) end
  self.plants:container_add(board_plant(self.score_board, -21, -self.score_board.h/2 - 11, {w = 20, h = 20, layer = game3, emoji = random_plant(), direction = 'up'}))
  if main:random_bool(75) then
    self.plants:container_add(board_plant(self.score_board, -21 + 12 + main:random_float(-3, 3), -self.score_board.h/2 - 8, {w = 15, h = 15, layer = game3, emoji = random_plant{'sheaf', 'seedling'}, direction = 'up'}))
  end
  if main:random_bool(50) then
    self.plants:container_add(board_plant(self.score_board, -21 - 12 + main:random_float(-3, 3), -self.score_board.h/2 - 6, {w = 11, h = 11, layer = game3, emoji = random_plant{'tulip', 'seedling'}, direction = 'up'}))
  end
  self.plants:container_add(board_plant(self.score_board, 21, -self.score_board.h/2 - 11, {w = 20, h = 20, layer = game3, emoji = random_plant(), direction = 'up'}))
  if main:random_bool(50) then
    self.plants:container_add(board_plant(self.score_board, 21 + 12 + main:random_float(-3, 3), -self.score_board.h/2 - 6, {w = 11, h = 11, layer = game3, emoji = random_plant{'tulip', 'blossom', 'seedling'}, direction = 'up'}))
    self.plants:container_add(board_plant(self.score_board, 21 - 12 + main:random_float(-3, 3), -self.score_board.h/2 - 6, {w = 11, h = 11, layer = game3, emoji = random_plant{'tulip', 'blossom', 'seedling'}, direction = 'up'}))
  end

  -- Best board
  self.plants:container_add(board_plant(self.best_board, 0, -self.best_board.h/2 - 12, {w = 20, h = 20, layer = game3, emoji = random_plant(), direction = 'up'}))
  if main:random_bool(75) then
    self.plants:container_add(board_plant(self.best_board, 12 + main:random_float(-3, 3), -self.best_board.h/2 - 10, {w = 15, h = 15, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
    self.plants:container_add(board_plant(self.best_board, -12 + main:random_float(-3, 3), -self.best_board.h/2 - 10, {w = 15, h = 15, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
    if main:random_bool(50) then
      self.plants:container_add(board_plant(self.best_board, 24 + main:random_float(-3, 3), -self.best_board.h/2 - 8, {w = 11, h = 11, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
      self.plants:container_add(board_plant(self.best_board, -24 + main:random_float(-3, 3), -self.best_board.h/2 - 8, {w = 11, h = 11, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
    end
  end

  -- Next board
  self.plants:container_add(board_plant(self.next_board, 0, -self.next_board.h/2 - 17, {w = 26, h = 26, layer = game3, emoji = random_plant(), direction = 'up'}))
  if main:random_bool(75) then
    self.plants:container_add(board_plant(self.next_board, 16 + main:random_float(-3, 3), -self.next_board.h/2 - 14, {w = 20, h = 20, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
    self.plants:container_add(board_plant(self.next_board, -16 + main:random_float(-3, 3), -self.next_board.h/2 - 14, {w = 20, h = 20, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
    if main:random_bool(50) then
      self.plants:container_add(board_plant(self.next_board, 28 + main:random_float(-3, 3), -self.next_board.h/2 - 12, {w = 15, h = 15, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
      self.plants:container_add(board_plant(self.next_board, -28 + main:random_float(-3, 3), -self.next_board.h/2 - 12, {w = 15, h = 15, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
      if main:random_bool(50) then
        self.plants:container_add(board_plant(self.next_board, 40 + main:random_float(-3, 3), -self.next_board.h/2 - 10, {w = 11, h = 11, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
        self.plants:container_add(board_plant(self.next_board, -40 + main:random_float(-3, 3), -self.next_board.h/2 - 10, {w = 11, h = 11, layer = game3, emoji = random_plant{'sheaf', 'blossom', 'seedling', 'tulip'}, direction = 'up'}))
      end
    end
  end
end

function arena:get_nearby_plants(x, y, r)
  local plants = {}
  for _, plant in ipairs(self.plants.objects) do
    if math.distance(plant.x, plant.y, x, y) < r then
      table.insert(plants, plant)
    end
  end
  return plants
end




plant = class:class_new()
function plant:plant_init(x, y, args)
  self:anchor_init('plant', args)
  self.emoji = images[self.emoji]
  self.flip_sx = self.flip_sx or main:random_sign(50)
  self:prs_init(x, y, 0, self.flip_sx*self.w/self.emoji.w, self.h/self.emoji.h)
  if self.direction == 'up' then
    self.y = self.y + math.remap(self.h, 9, 16, 4, 0)
  elseif self.direction == 'down' then
    self.y = self.y + math.remap(self.h, 9, 16, -4, 0)
  elseif self.direction == 'right' then
    self.x = self.x + math.remap(self.h, 9, 16, -4, 0)
  elseif self.direction == 'left' then
    self.x = self.x + math.remap(self.h, 9, 16, 4, 0)
  end
  if self.no_collider then
    if self.direction == 'right' then
      self.r = math.pi/2
    elseif self.direction == 'left' then
      self.r = 3*math.pi/2
    elseif self.direction == 'down' then
      self.r = math.pi
    end
  else
    self:collider_init('ghost', 'static', 'rectangle', self.w, self.h)
    if self.direction == 'right' then
      self.r = math.pi/2
      self:collider_set_angle(self.r)
    elseif self.direction == 'left' then
      self.r = 3*math.pi/2
      self:collider_set_angle(self.r)
    elseif self.direction == 'down' then
      self.r = math.pi
      self:collider_set_angle(self.r)
    end
  end
  self:timer_init()

  self.constant_wind_r = 0
  self.random_wind_r = 0
  self.random_wind_rv = 0
  self.random_wind_ra = 40
  self.init_max_random_wind_rv = 3
  self.max_random_wind_rv = self.init_max_random_wind_rv
  self.applying_wind_stream = false
  self.moving_wind_force_r = 0
  self.moving_wind_force_rv = 0
  self.moving_wind_force_ra = 40
  self.init_max_moving_wind_force_rv = 4
  self.max_moving_wind_force_rv = self.init_max_moving_wind_force_rv
  self.applying_moving_force = false
  self.direct_wind_force_r = 0
  self.direct_wind_force_rv = 0
  self.direct_wind_force_ra = 200
  self.init_max_direct_wind_force_rv = 6
  self.max_direct_wind_force_rv = self.init_max_direct_wind_force_rv
  self.applying_direct_force = false
end

function plant:plant_update(dt)
  if not self.no_collider then
    self:collider_update_position_and_angle()
  end

  if self.direction == 'up' or self.direction == 'down' then
    self.constant_wind_r = 0.2*math.sin(1.4*main.time + 0.01*self.x)
  elseif self.direction == 'left' or self.direction == 'right' then
    self.constant_wind_r = 0.2*math.sin(1.4*main.time + 0.01*self.y)
  end

  if self.applying_wind_stream then
    self.random_wind_rv = math.min(self.random_wind_rv + main:random_float(0.6, 1.4)*self.random_wind_ra*dt, self.max_random_wind_rv)
    self.random_wind_r = self.random_wind_r + main:random_float(0.6, 1.4)*self.random_wind_rv*dt
  end
  self.random_wind_rv = self.random_wind_rv*56*dt
  self.random_wind_r = self.random_wind_r*56*dt

  if self.applying_moving_force then
    if self.max_moving_wind_force_rv > 0 then self.moving_wind_force_rv = math.min(self.moving_wind_force_rv + self.moving_wind_force_ra*dt, self.max_moving_wind_force_rv)
    else self.moving_wind_force_rv = math.max(self.moving_wind_force_rv - self.moving_wind_force_ra*dt, self.max_moving_wind_force_rv) end
    self.moving_wind_force_r = self.moving_wind_force_r + self.moving_wind_force_rv*dt
  end
  self.moving_wind_force_rv = self.moving_wind_force_rv*57*dt
  self.moving_wind_force_r = self.moving_wind_force_r*57*dt

  if self.applying_direct_force then
    if self.max_direct_wind_force_rv > 0 then self.direct_wind_force_rv = math.min(self.direct_wind_force_rv + self.direct_wind_force_ra*dt, self.max_direct_wind_force_rv)
    else self.direct_wind_force_rv = math.max(self.direct_wind_force_rv - self.direct_wind_force_ra*dt, self.max_direct_wind_force_rv) end
    self.direct_wind_force_r = self.direct_wind_force_r + self.direct_wind_force_rv*dt
  end
  self.direct_wind_force_rv = self.direct_wind_force_rv*58*dt
  self.direct_wind_force_r = self.direct_wind_force_r*58*dt

  self.sx, self.sy = self.flip_sx*self.w/self.emoji.w, self.h/self.emoji.h
end

function plant:plant_draw()
  if self.direction == 'up' or self.direction == 'down' then
    self.layer:push(self.x, self.y + self.h/2, self.r + self.constant_wind_r + self.random_wind_r + self.moving_wind_force_r + self.direct_wind_force_r)
      self.layer:draw_image(self.emoji, self.x, self.y, 0, self.sx, self.sy)
    self.layer:pop()
  elseif self.direction == 'right' or self.direction == 'left' then
    self.layer:push(self.x, self.y, self.r)
      self.layer:push(self.x, self.y + self.h/2, self.constant_wind_r + self.random_wind_r + self.moving_wind_force_r + self.direct_wind_force_r)
        self.layer:draw_image(self.emoji, self.x, self.y, 0, self.sx, self.sy)
      self.layer:pop()
    self.layer:pop()
  end
end

function plant:apply_direct_force(vx, vy, force)
  local direction
  if self.direction == 'up' then direction = math.sign(vx)
  elseif self.direction == 'left' or self.direction == 'right' then direction = math.sign(vy) end

  force = force + main:random_float(-force/3, force/3)
  self.applying_direct_force = true
  local f = math.remap(math.abs(force), 0, 100, 0, self.init_max_direct_wind_force_rv)
  self.max_direct_wind_force_rv = direction*f
  self:timer_after({0.1, 0.2}, function() self.applying_direct_force = false; self.max_direct_wind_force_rv = self.init_max_direct_wind_force_rv end)
end

function plant:apply_moving_force(vx, vy, force)
  local direction
  if self.direction == 'up' then direction = math.sign(vx)
  elseif self.direction == 'left' or self.direction == 'right' then direction = math.sign(vy) end

  self.applying_moving_force = true
  local f = math.remap(math.abs(force), 0, 200, 0, self.init_max_moving_wind_force_rv)
  self.max_moving_wind_force_rv = direction*f
  self:timer_after({0.4, 0.6}, function() self.applying_moving_force = false; self.max_moving_wind_force_rv = self.init_max_moving_wind_force_rv end)
end

function plant:apply_wind_stream(duration, force)
  self:timer_after(0.002*self.x, function()
    self.max_random_wind_rv = force/10
    self.applying_wind_stream = true
    self:timer_after(duration/2, function() self:timer_tween(duration/2 + 0.004*self.x, self, {max_random_wind_rv = 0}, math.linear) end, 'back')
    self:timer_after(duration + 0.004*self.x, function()
      self.applying_wind_stream = false
      self.max_random_wind_rv = self.init_max_random_wind_rv
    end, 'end')
  end)
end

anchor:class_add(plant)


arena_plant = class:class_new(anchor)
function arena_plant:new(x, y, args)
  self:plant_init(x, y, args)
end

function arena_plant:update(dt)
  self:plant_update(dt)
  self:plant_draw()
end


board_plant = class:class_new(anchor)
function board_plant:new(board, x, y, args)
  args.no_collider = true
  self:plant_init(0, 0, args)
  self.board = board

  self.ox, self.oy = x, y
  self.emoji_type = args.emoji
  if self.flip_sx == 1 and args.emoji == 'sheaf' then
    self.ox = self.ox + 0.21*self.w
  elseif self.flip_sx == -1 and args.emoji == 'sheaf' then
    self.ox = self.ox - 0.21*self.w
  end
end

function board_plant:update(dt)
  self:plant_update(dt)
  self.constant_wind_r = 0.1*math.sin(1.4*main.time + 0.01*self.x)
  self.x, self.y = math.rotate_point(self.board.x + self.ox, self.board.y + self.oy, self.board.r, self.board.x, self.board.y)
  local vx, vy = self.board:collider_get_velocity()
  self:apply_moving_force(-vx, 0, 5*vx)

  if self.direction == 'up' or self.direction == 'down' then
    local r_ox, r_oy = 0, self.h/2
    if self.emoji_type == 'sheaf' then r_ox, r_oy = -self.flip_sx*0.21*self.w, self.h/2 end
    self.layer:push(self.x, self.y, self.board.r)
      self.layer:push(self.x + r_ox, self.y + r_oy, self.r + self.constant_wind_r + self.random_wind_r + self.moving_wind_force_r + self.direct_wind_force_r)
        self.layer:draw_image(self.emoji, self.x, self.y, 0, self.sx, self.sy)
      self.layer:pop()
    self.layer:pop()
  end
end




solid = class:class_new(anchor)
function solid:new(x, y, w, h, args)
  self:anchor_init('solid', args)
  self:prs_init(x, y)
  self:collider_init('solid', self.body_type or 'static', 'rectangle', w, h)
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
    (self.dying and self.gray_color) or (self.flashes.main.x and colors.white[0]) or (colors.green[0]))
  game2:pop()
end

--[[
function solid:die()
  if self.dying then return end
  self.dying = true
  self:hitfx_use('main', 0.1)
  self:timer_after(0.15, function() self:shake_shake(2, 0.5) end)
end
]]--
