require 'anchor'

--{{{ init
function init()
  main:init{title = 'super emoji merge', theme = 'twitter_emoji', w = 640, h = 360, sx = 2.5, sy = 2.5}

  bg, bg_fixed, game1, game2, game3, effects, ui1, ui2, shadow = layer(), layer({fixed = true}), layer(), layer(), layer(), layer(), layer({fixed = true}), layer({fixed = true}), layer({x = 4*main.sx, y = 4*main.sy, shadow = true})
  game1:layer_add_canvas('outline')
  game2:layer_add_canvas('outline')
  game3:layer_add_canvas('outline')
  effects:layer_add_canvas('outline')
  ui2:layer_add_canvas('outline')

  font_1 = font('assets/fusion-pixel-12px-monospaced-latin.ttf', 12, 'mono')
  font_2 = font('assets/volkswagen-serial-bold.ttf', 26, 'mono')
  font_3 = font('assets/volkswagen-serial-bold.ttf', 36, 'mono')
  font_4 = font('assets/volkswagen-serial-bold.ttf', 46, 'mono')

  main:input_bind('action_1', {'mouse:1', 'key:z', 'key:h', 'key:j', 'key:space', 'key:enter', 'axis:triggerright', 'button:a', 'button:x'})
  main:input_bind('action_2', {'mouse:2', 'key:x', 'key:k', 'key:l', 'key:tab', 'key:backspace', 'axis:triggerleft', 'button:b', 'button:y'})
  main:input_bind('left', {'key:a', 'key:left', 'axis:leftx-', 'axis:rightx-', 'button:dpad_left', 'button:leftshoulder'})
  main:input_bind('right', {'key:d', 'key:right', 'axis:leftx+', 'axis:rightx+', 'button:dpad_right', 'button:rightshoulder'})
  main:input_bind('up', {'key:w', 'key:up', 'axis:lefty-', 'axis:righty-', 'button:dpad_up'})
  main:input_bind('down', {'key:s', 'key:down', 'axis:lefty+', 'axis:righty+', 'button:dpad_down'})

  colors.calendar_gray = color_ramp(color(102, 117, 127), 0.025)

  shaders = {}
  shaders.shadow = shader(nil, 'assets/shadow.frag')
  shaders.outline = shader(nil, 'assets/outline.frag')
  shaders.combine = shader(nil, 'assets/combine.frag')
  shaders.grayscale = shader(nil, 'assets/grayscale.frag')
  shaders.hue_shift = shader(nil, 'assets/hue_shift.frag')
  shaders.hue_shift:shader_send('hue', 0)
  shaders.multiply_emoji = shader(nil, 'assets/multiply_emoji.frag')
  shaders.multiply_emoji:shader_send('multiplier', {1, 1, 1})

  -- main:input_set_mouse_visible(false)
  -- main:input_set_mouse_locked(true)

  frames = {}
  frames.hit = animation_frames('assets/hit.png', 96, 48)
  frames.disappear = animation_frames('assets/disappear.png', 40, 40)

  images = {}
  images.blossom = image('assets/blossom.png')
  images.four_leaf_clover = image('assets/four_leaf_clover.png')
  images.herb = image('assets/herb.png')
  images.leaf = image('assets/leaf.png')
  images.leaf_2 = image('assets/leaf_2.png')
  images.seedling = image('assets/seedling.png')
  images.sheaf = image('assets/sheaf.png')
  images.sunflower = image('assets/sunflower.png')
  images.tulip = image('assets/tulip.png')
  images.vine_chain = image('assets/vine_chain.png')
  images['0'] = image('assets/0.png')
  images['1'] = image('assets/1.png')
  images['2'] = image('assets/2.png')
  images['3'] = image('assets/3.png')
  images['4'] = image('assets/4.png')
  images['5'] = image('assets/5.png')
  images['6'] = image('assets/6.png')
  images['7'] = image('assets/7.png')
  images['8'] = image('assets/8.png')
  images['9'] = image('assets/9.png')
  images['a'] = image('assets/a.png')
  images['b'] = image('assets/b.png')
  images['c'] = image('assets/c.png')
  images['d'] = image('assets/d.png')
  images['e'] = image('assets/e.png')
  images['f'] = image('assets/f.png')
  images['g'] = image('assets/g.png')
  images['h'] = image('assets/h.png')
  images['i'] = image('assets/i.png')
  images['j'] = image('assets/j.png')
  images['k'] = image('assets/k.png')
  images['l'] = image('assets/l.png')
  images['m'] = image('assets/m.png')
  images['n'] = image('assets/n.png')
  images['o'] = image('assets/o.png')
  images['p'] = image('assets/p.png')
  images['q'] = image('assets/q.png')
  images['r'] = image('assets/r.png')
  images['s'] = image('assets/s.png')
  images['t'] = image('assets/t.png')
  images['u'] = image('assets/u.png')
  images['v'] = image('assets/v.png')
  images['w'] = image('assets/w.png')
  images['x'] = image('assets/x.png')
  images['y'] = image('assets/y.png')
  images['z'] = image('assets/z.png')
  images.cloud = image('assets/cloud.png')
  images.star = image('assets/star.png')
  images.slight_smile = image('assets/slight_smile.png')
  images.blush = image('assets/blush.png')
  images.devil = image('assets/devil.png')
  images.angry = image('assets/angry.png')
  images.relieved = image('assets/relieved.png')
  images.yum = image('assets/yum.png')
  images.joy = image('assets/joy.png')
  images.sob = image('assets/sob.png')
  images.skull = image('assets/skull.png')
  images.thinking = image('assets/thinking.png')
  images.sunglasses = image('assets/sunglasses.png')
  images.board = image('assets/board.png')
  images.blue_board = image('assets/blue_board.png')
  images.red_board = image('assets/red_board.png')
  images.green_board = image('assets/green_board.png')
  images.chain = image('assets/chain.png')
  images.curving_arrow = image('assets/curving_arrow.png')
  images.blue_chain = image('assets/blue_chain.png')
  
  bg_gradient = gradient_image('vertical', color(0.5, 0.5, 0.5, 0), color(0, 0, 0, 0.3))

  main:physics_world_set_gravity(0, 360)
  main:physics_world_set_callbacks()
  main:physics_world_set_collision_tags{'emoji', 'ghost', 'solid'}
  main:physics_world_disable_collision_between('emoji', {'ghost'})
  main:physics_world_disable_collision_between('ghost', {'emoji', 'ghost', 'solid'})

  color_to_emoji_multiplier = {
    white = {3, 3, 3},
    gray = {1, 1, 1},
    black = {0.40833, 0.45833, 0.50833},
    yellow = {2.10833, 1.69166, 0.73333},
    yellow_original = {2.125, 1.7, 0.64166},
    yellow_star = {2.125, 1.43333, 0.425},
    orange = {2.03333, 1.2, 0.1},
    red = {1.84166, 0.38333, 0.56666},
    green = {1, 1.475, 0.74166},
    blue = {0.70833, 1.43333, 1.98333},
    blue_original = {0.49166, 1.13333, 1.625},
    purple = {1.41666, 1.18333, 1.78333},
    brown = {1.60833, 0.875, 0.65833},
  }

  value_to_emoji_data = {
    [1] = {emoji = 'slight_smile', rs = 9, score = 1, mass_multiplier = 1, stars = 2},
    [2] = {emoji = 'blush', rs = 11.5, score = 3, mass_multiplier = 1, stars = 2},
    [3] = {emoji = 'devil', rs = 16.5, score = 6, mass_multiplier = 1, stars = 3},
    [4] = {emoji = 'angry', rs = 18.5, score = 10, mass_multiplier = 1, stars = 3},
    [5] = {emoji = 'relieved', rs = 23, score = 15, mass_multiplier = 1, stars = 4},
    [6] = {emoji = 'yum', rs = 29.5, score = 21, mass_multiplier = 1, stars = 4},
    [7] = {emoji = 'joy', rs = 35, score = 28, mass_multiplier = 1, stars = 5},
    [8] = {emoji = 'sob', rs = 41.5, score = 36, mass_multiplier = 1, stars = 6},
    [9] = {emoji = 'skull', rs = 47.5, score = 45, mass_multiplier = 1, stars = 8},
    [10] = {emoji = 'thinking', rs = 59, score = 56, mass_multiplier = 1, stars = 12},
    [11] = {emoji = 'sunglasses', rs = 70, score = 66, mass_multiplier = 1, stars = 24},
  }

  main:level_add('classic_arena', arena())
  main:level_goto('classic_arena')
end

function draw_emoji_character(layer, character, x, y, r, sx, sy, ox, oy, color)
  layer:send(shaders.multiply_emoji, 'base', 161/255)
  layer:send(shaders.multiply_emoji, 'multiplier', color_to_emoji_multiplier[color])
  layer:draw_image(images[character], x, y, r, sx, sy, ox, oy, nil, shaders.multiply_emoji)
end

function main:draw_all_layers_to_main_layer()
  bg:layer_draw_commands()
  bg_fixed:layer_draw_commands()
  game1:layer_draw_commands()
  game2:layer_draw_commands()
  game3:layer_draw_commands()
  effects:layer_draw_commands()
  ui1:layer_draw_commands()
  ui2:layer_draw_commands()

  shadow:layer_draw_to_canvas('main', function()
    game1:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.shadow, true)
    game2:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.shadow, true)
    game3:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.shadow, true)
    effects:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.shadow, true)
  end)
  game1:layer_draw_to_canvas('outline', function() game1:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.outline) end)
  game2:layer_draw_to_canvas('outline', function() game2:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.outline) end)
  game3:layer_draw_to_canvas('outline', function() game3:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.outline) end)
  effects:layer_draw_to_canvas('outline', function() effects:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.outline) end)
  ui2:layer_draw_to_canvas('outline', function() ui2:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.outline) end)

  main:layer_draw_to_canvas(main.canvas, function() 
    bg:layer_draw()
    bg_fixed:layer_draw()
    shadow:layer_draw()
    game1:layer_draw('outline')
    game1:layer_draw()
    game2:layer_draw('outline')
    game2:layer_draw()
    game3:layer_draw('outline')
    game3:layer_draw()
    effects:layer_draw('outline')
    effects:layer_draw()
    ui1:layer_draw()
    ui2:layer_draw('outline')
    ui2:layer_draw()
  end)
end

function update(dt)
  if main:input_is_pressed'f11' then love.event.restart() end
end
--}}}


--{{{ arena
arena = class:class_new(anchor)
function arena:new(x, y, args)
  self:anchor_init('arena', args)
  self:timer_init()
  self:observer_init()
  self.top_spacing, self.bottom_spacing = 40, 20
  self.w, self.h = 252, 294
  self.x1, self.y1, self.x2, self.y2 = main.w/2 - self.w/2, self.top_spacing, main.w/2 + self.w/2, main.h - self.bottom_spacing
  self.score_x, self.next_x = (self.x1-5)/2, self.x2 + 5 + (main.w - (self.x2 + 5))/2 + 1

end

function arena:enter()
  self.emojis = container()
  self.plants = container()
  self.objects = container()

  -- Solids
  self.solid_top = self.objects:container_add(solid(main.w/2, -120, 2*self.w, 10))
  self.solid_bottom = self.objects:container_add(solid(main.w/2, self.y2, self.w, 10))
  self.solid_left = self.objects:container_add(solid(self.x1, self.y2 - self.h/2, 10, self.h + 10))
  self.solid_right = self.objects:container_add(solid(self.x2, self.y2 - self.h/2, 10, self.h + 10))
  self.solid_left_joint = self.objects:container_add(joint('weld', self.solid_left, self.solid_bottom, self.x1, self.y2))
  self.solid_right_joint = self.objects:container_add(joint('weld', self.solid_right, self.solid_bottom, self.x2, self.y2))

  -- Boards
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

  self:spawn_plants()

  -- Emojivolution objects
  self.curving_arrow = self.objects:container_add(evoji_emoji(self.next_x, 249, {emoji = 'curving_arrow'}))
  self.evoji_emojis = {}
  local r = -math.pi/4 + (3*math.pi/2)/22
  for i = 1, 11 do
    table.insert(self.evoji_emojis, self.objects:container_add(evoji_emoji(self.next_x + 64*math.cos(r), 249 + 64*math.sin(r), {emoji = value_to_emoji_data[i].emoji, rs = 12})))
    r = r + (3*math.pi/2)/11
  end
  self.joints = {}
  for i, emoji in ipairs(self.evoji_emojis) do
    local next_emoji = self.evoji_emojis[i+1]
    if next_emoji then
      local x, y = (emoji.x + next_emoji.x)/2, (emoji.y + next_emoji.y)/2
      table.insert(self.joints, self.objects:container_add(joint('weld', emoji, next_emoji, x, y)))
    end
  end
  local e = self.curving_arrow
  e = self.evoji_emojis[#self.evoji_emojis]
  local r = math.angle_to_point(self.next_board.x - self.next_board.w/2 + 8, self.next_board.y + self.next_board.h/2, e.x, e.y)
  self.evoji_chain_left = self.objects:container_add(emoji_chain('blue_chain', self.next_board, e, self.next_board.x - self.next_board.w/2 + 8, self.next_board.y + self.next_board.h/2, 
    e.x + e.rs*math.cos(r + math.pi), e.y + e.rs*math.sin(r + math.pi)))
  e = self.evoji_emojis[1]
  r = math.angle_to_point(self.next_board.x + self.next_board.w/2 - 8, self.next_board.y + self.next_board.h/2, e.x, e.y)
  self.evoji_chain_right = self.objects:container_add(emoji_chain('blue_chain', self.next_board, e, self.next_board.x + self.next_board.w/2 - 8, self.next_board.y + self.next_board.h/2, 
    e.x + e.rs*math.cos(r + math.pi), e.y + e.rs*math.sin(r + math.pi)))
  e = self.evoji_emojis[6]
  self.curving_chain = self.objects:container_add(emoji_chain('blue_chain', self.curving_arrow, e, self.curving_arrow.x, self.curving_arrow.y + self.curving_arrow.h/2, e.x, e.y - e.rs))

  self.spawner = self.objects:container_add(spawner())
  self.emoji_line_color = colors.blue[0]:color_clone()
  self.emoji_line_color.a = 0.32
  self:choose_next_emoji()
end

function arena:update(dt)
  bg:rectangle(main.w/2, main.h/2, 3*main.w, 3*main.h, 0, 0, colors.fg[0])
  bg_gradient:gradient_image_draw(bg_fixed, 0.5*main.w, 0.5*main.h, 2*main.w, 2*main.h)

  -- Spawner movement
  if self.spawner then
    local left_offset, right_offset = 32, 16
    if self.spawner_emoji then
      left_offset = left_offset + self.spawner_emoji.rs
      right_offset = right_offset - self.spawner_emoji.rs
    end
    self.spawner.x, self.spawner.y = math.clamp(main.pointer.x, self.x1 + left_offset, self.x2 + right_offset), 20
    self.spawner:collider_set_position(self.spawner.x, self.spawner.y)
  end

  -- Spawner emoji movement
  if self.spawner_emoji and not self.spawner_emoji.dropping then
    self.spawner_emoji:collider_set_position(self.spawner.x - 24, self.spawner.y + self.spawner_emoji.rs)
    if main:input_is_pressed('action_1') then
      self:drop_emoji()
    end
    bg:line(self.spawner.x - 24, self.spawner.y, self.spawner.x - 24, self.y2, self.emoji_line_color, 2)
  end

  -- Merge emojis
  for _, c in ipairs(main:physics_world_get_collision_enter('emoji', 'emoji')) do
    local a, b = c[1], c[2]
    if not a.dead and not b.dead and a.has_dropped and b.has_dropped then
      if a.value == b.value then
        self:merge_emojis(a, b, c[3])
      end
    end
  end

  -- Apply moving force to plants
  for _, c in ipairs(main:physics_world_get_trigger_enter('emoji', 'plant')) do
    local a, b = c[1], c[2]
    local vx, vy = a:collider_get_velocity()
    b:apply_moving_force(vx, vy, 0.5*math.abs(math.max(vx, vy)))
  end

  -- Apply direct force to plants when hitting bottom solid
  for _, c in ipairs(main:physics_world_get_collision_enter('emoji', 'solid')) do
    local a, b = c[1], c[2]
    local x, y = c[3]:getPositions()
    if b.id == self.solid_bottom.id then
      local plants = self:get_nearby_plants(x, y, 50)
      for _, plant in ipairs(plants) do
        local dx = a.x - plant.x
        local vx, vy = a:collider_get_velocity()
        if math.abs(vy) > 30 and plant.direction == 'up' then
          local mass = a:collider_get_mass()
          plant:apply_direct_force(-math.sign(dx), nil, 2*mass*math.remap(math.abs(dx), 0, 50, 75, 25))
        end
      end
    end
  end

  -- Round end condition
  if not self.round_ending then
    for _, emoji in ipairs(self.emojis.objects) do
      if emoji.y < self.y1 and emoji.id ~= self.spawner_emoji.id and not emoji.dropping then
        self:end_round()
      end
    end
  end

  if main:input_is_pressed'k' then
    self:end_round()
  end

  
  self.emojis:container_update(dt)
  self.plants:container_update(dt)
  self.objects:container_update(dt)
  self.emojis:container_remove_dead()
  self.plants:container_remove_dead()
  self.objects:container_remove_dead()
end

function arena:exit()
  --[[
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
  ]]--
end

function arena:drop_emoji()
  local x, y = (self.spawner.x + self.spawner_emoji.x)/2, (self.spawner.y + self.spawner_emoji.y)/2
  self.spawner.drop_x, self.spawner.drop_y = x, y
  self.spawner_emoji.drop_x, self.spawner_emoji.drop_y = x, y
  self.spawner:hitfx_use('drop', 0.25)
  self.spawner_emoji:hitfx_use('drop', 0.25)

  self.spawner_emoji:collider_set_gravity_scale(1)
  self.spawner_emoji:collider_apply_impulse(0, 0.01)
  self.spawner_emoji.dropping = true
  self.spawner_emoji.has_dropped = true
  self.spawner_emoji:observer_condition(function() return (self.spawner_emoji.collision_enter.emoji or self.spawner_emoji.collision_enter.solid) and self.spawner_emoji.dropping end, function()
    self.spawner_emoji.dropping = false
    self:choose_next_emoji()
  end, nil, nil, 'drop_emoji')
  self:timer_after(3, function()
    if self.spawner_emoji.dropping then
      self.spawner_emoji.dropping = false
      self:choose_next_emoji()
    end
  end, 'drop_safety')
end

function arena:choose_next_emoji()
  self:timer_cancel('drop_safety')
  self.spawner_emoji = self.emojis:container_add(emoji(self.spawner.x, self.y1, {hitfx_on_spawn_no_flash = 0.5, value = self.next}))
  self.next = main:random_int(1, 5)
  self.next_board:hitfx_use('emoji', 0.5)
end


function arena:merge_emojis(a, b, contact)
  local x, y = contact:getPositions()
  a.dead = true
  b.dead = true
  self.objects:container_add(emoji_merge_effect(a.x, a.y, {emoji = a.emoji, r = a.r, sx = a.sx, sy = a.sy, target_x = x, target_y = y}))
  self.objects:container_add(emoji_merge_effect(b.x, b.y, {emoji = b.emoji, r = b.r, sx = b.sx, sy = b.sy, target_x = x, target_y = y}))
  local avx, avy = a:collider_get_velocity()
  local bvx, bvy = b:collider_get_velocity()
  self.score = self.score + value_to_emoji_data[a.value].score
  self:timer_after(0.15, function()
    local emoji = self.emojis:container_add(emoji(x, y, {from_merge = true, hitfx_on_spawn = true, value = a.value + 1}))
    emoji.has_dropped = true
    emoji:collider_set_gravity_scale(1)
    emoji:collider_apply_impulse((avx+bvx)/6, (avy+bvy)/6)
  end, 'merge_emojis')
end

function arena:end_round()
  self.round_ending = true
  self:timer_cancel('drop_emoji')
  self:timer_cancel('drop_safety')
  self:timer_cancel('merge_emojis')

  local top_emoji = self.emojis:container_get_highest_object(function(v) return v.id ~= self.spawner_emoji.id end)
  table.sort(main.objects, function(a, b)
    if a.x and b.x then
      return math.distance(top_emoji.x, top_emoji.y, a.x, a.y) < math.distance(top_emoji.x, top_emoji.y, b.x, b.y)
    end
  end)

  -- Turn objects black and white by setting .dying to true
  local i = 1
  for _, object in ipairs(main.objects) do
    if object:is('board') or object:is('solid') or object:is('emoji') or object:is('plant') or object:is('chain_part') or object:is('evoji_emoji') then
      self:timer_after(0.025*i, function()
        if object.dying then return end
        object.dying = true
        object:hitfx_use('main', 0.25)
        object:timer_after(0.15, function() object:shake_shake(4, 0.5) end)
      end)
      i = i + 1
    end
  end

  --[[

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
  --]]
end
--}}}


--{{{ boards + chains
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
  self:shake_init()
  self:hitfx_init()
  self:hitfx_add('emoji', 1)
end

function board:update(dt)
  self:collider_update_position_and_angle()
  game2:push(self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x)
    game2:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, 1, 1, 0, 0, colors.white[0], (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game2:pop()
  game2:push(self.x, self.y, self.r)
    if self.board_type == 'score' then
      game2:draw_text_centered(self.board_type:upper(), font_2, self.x, self.y - 24, 0, 1, 1, 0, 0, colors.fg[0])
      local score = main.level.score
      game2:draw_text_centered(tostring(score), (score < 999 and font_4) or font_3, self.x, self.y + 12, 0, 1, 1, 0, 0, colors.calendar_gray[0])
    elseif self.board_type == 'best' then
      game2:draw_text_centered(self.board_type:upper(), font_2, self.x, self.y - 20, 0, 1, 1, 0, 0, colors.fg[0])
      local best = main.level.best
      game2:draw_text_centered(tostring(best), (best < 999 and font_3) or font_2, self.x, self.y + 10, 0, 1, 1, 0, 0, colors.calendar_gray[0])
    elseif self.board_type == 'next' then
      game2:draw_text_centered(self.board_type:upper(), font_2, self.x, self.y - 28, 0, 1, 1, 0, 0, colors.fg[0])
      game3:push(self.x, self.y, self.r)
      local next = main.level.next
      if next then
        local sx = 2*value_to_emoji_data[next].rs/images[value_to_emoji_data[next].emoji].w
        local sy = sx
        next = images[value_to_emoji_data[next].emoji]
        game3:push(self.x, self.y + 15, 0, self.springs.emoji.x, self.springs.emoji.x)
          game3:draw_image(next, self.x + self.shake_amount.x, self.y + 15 + self.shake_amount.y, 0, sx*self.springs.main.x, sy*self.springs.main.x, 0, 0, colors.white[0], 
            (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
        game3:pop()
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
    table.insert(self.chain_parts, main.level.objects:container_add(chain_part(emoji, x1 + d*math.cos(r), y1 + d*math.sin(r), {hidden = self.hidden, r = r, w = chain_part_size})))
  end
  for i, chain_part in ipairs(self.chain_parts) do
    local next_chain_part = self.chain_parts[i+1]
    if next_chain_part then
      local x, y = (chain_part.x + next_chain_part.x)/2, (chain_part.y + next_chain_part.y)/2
      table.insert(self.joints, main.level.objects:container_add(joint('revolute', chain_part, next_chain_part, x, y)))
    end
  end
  table.insert(self.joints, main.level.objects:container_add(joint('revolute', collider_1, self.chain_parts[1], x1, y1)))
  if collider_2 then table.insert(self.joints, main.level.objects:container_add(joint('revolute', self.chain_parts[#self.chain_parts], collider_2, x2, y2, true))) end
end

function emoji_chain:update(dt)

end


text_chain = class:class_new(anchor)
function text_chain:new(text, collider, x, y, chain_part_size, args)
  self:anchor_init('text_chain', args)
  self.text = text
  self.x, self.y = x, y

  self.chain_parts = {}
  self.joints = {}
  local chain_part_size = chain_part_size or 18
  local total_chain_size = utf8.len(text)*chain_part_size
  local chain_part_amount = math.ceil(total_chain_size/chain_part_size)
  local r = 0
  for i = 1, chain_part_amount do
    local d = 0.5*chain_part_size + (i-1)*chain_part_size
    character = utf8.sub(self.text, i, i)
    table.insert(self.chain_parts, main.level.objects:container_add(chain_part(character, self.x + d*math.cos(r), self.y + d*math.sin(r), {character = true, r = r, w = chain_part_size})))
  end
  for i, chain_part in ipairs(self.chain_parts) do
    local next_chain_part = self.chain_parts[i+1]
    if next_chain_part then
      local x, y = (chain_part.x + next_chain_part.x)/2, (chain_part.y + next_chain_part.y)/2
      table.insert(self.joints, main.level.objects:container_add(joint('revolute', chain_part, next_chain_part, x, y)))
    end
  end
  table.insert(self.joints, main.level.objects:container_add(joint('revolute', collider, self.chain_parts[1], x, y)))

  for _, joint in ipairs(self.joints) do
    joint:revolute_joint_set_limits_enabled(true)
    joint:revolute_joint_set_limits(0, 0)
  end
  for _, chain_part in ipairs(self.chain_parts) do
    chain_part:collider_set_mass(chain_part:collider_get_mass()*0.05)
  end
end

function text_chain:update(dt)

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
  if self.hidden then return end
  if self.character then
    draw_emoji_character(game1, self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, 
      (self.dying and 'gray') or (self.flashes.main.x and 'white') or 'blue_original')
  else
    game1:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  end
  --self:collider_draw(ui1, colors.blue[0], 1)
end
--}}}


--{{{ plants
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
  self:timer_init()
  self:hitfx_init()
  self:shake_init()

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
  self:collider_update_position_and_angle()

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
      self.layer:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0],
        (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
    self.layer:pop()
  elseif self.direction == 'right' or self.direction == 'left' then
    self.layer:push(self.x, self.y, self.r)
      self.layer:push(self.x, self.y + self.h/2, self.constant_wind_r + self.random_wind_r + self.moving_wind_force_r + self.direct_wind_force_r)
        self.layer:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0],
          (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
      self.layer:pop()
    self.layer:pop()
  end
end

function plant:apply_direct_force(vx, vy, force)
  local direction
  if self.direction == 'up' then direction = math.sign(vx)
  elseif self.direction == 'down' then direction = -math.sign(vx)
  elseif self.direction == 'left' then direction = -math.sign(vy)
  elseif self.direction == 'right' then direction = math.sign(vy) end

  force = force + main:random_float(-force/3, force/3)
  self.applying_direct_force = true
  local f = math.remap(math.abs(force), 0, 100, 0, self.init_max_direct_wind_force_rv)
  self.max_direct_wind_force_rv = direction*f
  self:timer_after({0.1, 0.2}, function() self.applying_direct_force = false; self.max_direct_wind_force_rv = self.init_max_direct_wind_force_rv end)
end

function plant:apply_moving_force(vx, vy, force)
  local direction
  if self.direction == 'up' then direction = math.sign(vx)
  elseif self.direction == 'down' then direction = -math.sign(vx)
  elseif self.direction == 'left' then direction = -math.sign(vy)
  elseif self.direction == 'right' then direction = math.sign(vy) end

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
  self:collider_set_position(self.x, self.y)

  if self.direction == 'up' or self.direction == 'down' then
    local r_ox, r_oy = 0, self.h/2
    if self.emoji_type == 'sheaf' then r_ox, r_oy = -self.flip_sx*0.21*self.w, self.h/2 end
    self.layer:push(self.x, self.y, self.board.r)
      self.layer:push(self.x + r_ox, self.y + r_oy, self.r + self.constant_wind_r + self.random_wind_r + self.moving_wind_force_r + self.direct_wind_force_r)
        self.layer:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0],
          (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
      self.layer:pop()
    self.layer:pop()
  end
end
--}}}


--{{{ misc + effects
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


evoji_emoji = class:class_new(anchor)
function evoji_emoji:new(x, y, args)
  self:anchor_init('evoji_emoji', args)
  if self.rs then
    self.emoji = images[self.emoji]
    self:prs_init(x, y, 0, 2*self.rs/self.emoji.w, 2*self.rs/self.emoji.h)
    self:collider_init('solid', 'dynamic', 'circle', self.rs)
    self:collider_set_restitution(1)
    self:collider_set_mass(self:collider_get_mass()*0.1)
    self:collider_set_damping(0.1)
  else
    if self.emoji == 'curving_arrow' then self.r_offset = math.pi/2 end
    self.emoji = images[self.emoji]
    self.w, self.h = self.w or 48, self.h or 48
    self:prs_init(x, y, 0, self.w/self.emoji.w, self.h/self.emoji.h)
    self:collider_init('solid', 'dynamic', 'rectangle', self.w*0.95, self.h*0.95)
    self:collider_set_restitution(1)
    self:collider_set_mass(self:collider_get_mass()*0.1)
    self:collider_set_damping(0.25)
    self:collider_set_angular_damping(0.25)
    self:collider_set_gravity_scale(-1)
  end
  self:timer_init()
  self:hitfx_init()
  self:shake_init()
end

function evoji_emoji:update(dt)
  self:collider_update_position_and_angle()
  game2:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r + (self.r_offset or 0), self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
    (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
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
  if self.dying then return end
  game3:push(self.x, self.y, self.r)
  game3:rectangle(self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.w*self.springs.main.x, self.h*self.springs.main.x, 4, 4, 
    (self.dying and self.gray_color) or (self.flashes.main.x and colors.white[0]) or (colors.green[0]))
  game3:pop()
end


emoji_merge_effect = class:class_new(anchor)
function emoji_merge_effect:new(x, y, args)
  self:anchor_init('emoji_merge_effect', args)
  self:prs_init(x, y)
  self:hitfx_init()
  self:hitfx_use('main', 0.5, nil, nil, 0.2)
  self:timer_init()
  self:timer_tween(0.15, self, {x = self.target_x, y = self.target_y, sx = 0, sy = 0}, math.cubic_in_out, function() self.dead = true end)
end

function emoji_merge_effect:update(dt)
  game2:draw_image(self.emoji, self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, nil, nil, colors.white[0], self.flashes.main.x and shaders.combine)
end


emoji_particle = class:class_new(anchor)
function emoji_particle:new(emoji, x, y, args)
  self:anchor_init('emoji_particle', args)
  self.emoji = images[emoji]
  self:prs_init(x, y, self.r or main:random_angle(), (self.s or 1)*14/self.emoji.w, (self.s or 1)*14/self.emoji.h)
  self:timer_init()
  self:hitfx_init()
  if self.hitfx_on_spawn then self:hitfx_use('main', 0.5*self.hitfx_on_spawn, nil, nil, 0.3*self.hitfx_on_spawn) end

  self.v = self.v or main:random_float(75, 150)
  self.visual_r = self.visual_r or 0
  self.rotation_v = self.rotation_v or 0
  self.duration = self.duration or main:random_float(0.4, 0.6)
  self:timer_tween(self.duration, self, {v = 0, sx = 0, sy = 0}, math.linear, function() self.dead = true end)
end

function emoji_particle:update(dt)
  if self.angular_v then self.r = self.r + self.angular_v*dt end
  self.x = self.x + self.v*math.cos(self.r)*dt
  self.y = self.y + self.v*math.sin(self.r)*dt
  self.visual_r = self.visual_r + self.rotation_v*dt
  effects:draw_image(self.emoji, self.x, self.y, self.r + self.visual_r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, nil, nil, colors.white[0], self.flashes.main.x and shaders.combine)
end


hit_effect = class:class_new(anchor)
function hit_effect:new(x, y, args)
  self:anchor_init('hit_effect', args)
  self:prs_init(x, y, self.r or main:random_angle())
  self.animation = animation(0.04, frames.hit, 'once', {[0] = function() self.dead = true end})
end

function hit_effect:update(dt)
  self.animation:animation_update(dt, effects, self.x, self.y, self.r, self.sx, self.sy)
end
--}}}


--{{{ spawner, emoji
spawner = class:class_new(anchor)
function spawner:new(x, y, args)
  self:anchor_init('spawner', args)
  self.emoji = images.cloud
  self:prs_init(main.pointer.x, main.level.y1, 0, 42/self.emoji.w, 42/self.emoji.h)
  self:collider_init('ghost', 'dynamic', 'circle', 16)
  self:collider_set_gravity_scale(0)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()

  self:hitfx_add('drop', 1)
  self.drop_x, self.drop_y = 0, 0
end

function spawner:update(dt)
  game1:push(self.drop_x, self.drop_y, 0, self.springs.drop.x, self.springs.drop.x)
    game1:draw_image(images.cloud, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game1:pop()
end


emoji = class:class_new(anchor)
function emoji:new(x, y, args)
  self:anchor_init('emoji', args)
  self.value = self.value or 1
  self.rs = value_to_emoji_data[self.value].rs
  self.emoji = images[value_to_emoji_data[self.value].emoji]
  self.stars = value_to_emoji_data[self.value].stars
  self:prs_init(x, y, 0, 2*self.rs/self.emoji.w, 2*self.rs/self.emoji.h)
  self:collider_init('emoji', 'dynamic', 'circle', self.rs)
  self:collider_set_restitution(0.1)
  self:collider_set_gravity_scale(0)
  self:collider_set_mass(value_to_emoji_data[self.value].mass_multiplier*self:collider_get_mass())
  self:timer_init()
  self:observer_init()
  self:hitfx_init()
  self:shake_init()

  if self.hitfx_on_spawn then self:hitfx_use('main', 0.5, nil, nil, 0.15) end
  if self.hitfx_on_spawn_no_flash then self:hitfx_use('main', 0.5) end
  if self.from_merge then
    self:timer_after(0.01, function()
      local s = math.remap(self.rs, 9, 70, 1, 3)
      for i = 1, self.stars do 
        local r = main:random_angle()
        local d = main:random_float(0.8, 1)
        local x, y = self.x + d*self.rs*math.cos(r), self.y + d*self.rs*math.sin(r)
        main.level.objects:container_add(emoji_particle('star', x, y, {hitfx_on_spawn = 0.75, r = r, rotation_v = main:random_float(-2*math.pi, 2*math.pi), s = s, v = s*main:random_float(50, 100)}))
      end
    end)
  end

  self.has_dropped = false -- if the emoji has been dropped from the cloud, used to prevent the current .spawner_emoji from merging; merged emojis should have this set to true so they can merge again
  self:hitfx_add('drop', 1)
  self.drop_x, self.drop_y = 0, 0
end

function emoji:update(dt)
  self:collider_update_position_and_angle()
  game2:push(self.drop_x, self.drop_y, 0, self.springs.drop.x, self.springs.drop.x)
    game2:draw_image(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game2:pop()
end
--}}}
