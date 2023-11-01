require 'anchor'

--{{{ init
function init()
  main:init{title = 'emoji merge', theme = 'twitter_emoji', web = true, w = 640, h = 360, sx = 2, sy = 2}
  main:set_icon('assets/sunglasses_icon.png')

  bg, bg_fixed, game1, game2, game3, effects, ui1, ui2, shadow = layer(), layer({fixed = true}), layer(), layer(), layer(), layer(), layer({fixed = true}), layer({fixed = true}), layer({x = 4*main.sx, y = 4*main.sy, shadow = true})
  game1:layer_add_canvas('outline')
  game2:layer_add_canvas('outline')
  game3:layer_add_canvas('outline')
  effects:layer_add_canvas('outline')
  ui2:layer_add_canvas('outline')

  main_font = font('assets/HoneyPigeon.ttf', 22, 'mono')
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
  shaders.multiply_emoji = shader(nil, 'assets/multiply_emoji.frag')
  shaders.multiply_emoji:shader_send('multiplier', {1, 1, 1})

  main:input_set_mouse_visible(false)

  if main.web then
    images = image('assets/texture.png'):image_load_texture_atlas(128, 128, {
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'angry', 'b', 'blossom', 'blue_board', 'blue_chain', 'blush', 'c', 'close', 'closed_hand', 'cloud', 'cloud_gray', 'curving_arrow', 'd', 'devil', 'e', 'f', 
      'four_leaf_clover', 'g', 'green_board', 'h', 'i', 'index', 'j', 'joy', 'k', 'l', 'm', 'n', 'o', 'open_hand', 'p', 'q', 'r', 'red_board', 'relieved', 'retry', 's', 'screen', 'seedling', 'sheaf', 'slight_smile', 
      'smirk', 'sob', 'sound_0', 'sound_1', 'sound_2', 'sound_3', 'sound_4', 'star', 'star_gray', 'sunflower', 'sunglasses', 't', 'thinking', 'tulip', 'u', 'v', 'vine_chain', 'w', 'x', 'y', 'yum', 'z'
    }, 1)
  else
    images = {}
    images.blossom = image('assets/blossom.png')
    images.four_leaf_clover = image('assets/four_leaf_clover.png')
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
    images.star = image('assets/star.png')
    images.slight_smile = image('assets/slight_smile.png')
    images.blush = image('assets/blush.png')
    images.devil = image('assets/devil.png')
    images.angry = image('assets/angry.png')
    images.relieved = image('assets/relieved.png')
    images.yum = image('assets/yum.png')
    images.joy = image('assets/joy.png')
    images.sob = image('assets/sob.png')
    images.smirk = image('assets/smirk.png')
    images.thinking = image('assets/thinking.png')
    images.sunglasses = image('assets/sunglasses.png')
    images.blue_board = image('assets/blue_board.png')
    images.red_board = image('assets/red_board.png')
    images.green_board = image('assets/green_board.png')
    images.curving_arrow = image('assets/curving_arrow.png')
    images.blue_chain = image('assets/blue_chain.png')
    images.retry = image('assets/retry.png')
    images.index = image('assets/index.png')
    images.sound_4 = image('assets/sound_4.png')
    images.sound_3 = image('assets/sound_3.png')
    images.sound_2 = image('assets/sound_2.png')
    images.sound_1 = image('assets/sound_1.png')
    images.sound_0 = image('assets/sound_0.png')
    images.screen = image('assets/screen.png')
    images.closed_hand = image('assets/closed_hand.png')
    images.open_hand = image('assets/open_hand.png')
    images.close = image('assets/close.png')
    images.star_gray = image('assets/star_gray.png')
    images.cloud = image('assets/cloud.png')
    images.cloud_gray = image('assets/cloud_gray.png')
  end

  -- bg_1 = gradient_image('vertical', color(0.5, 0.5, 0.5, 0), color(0, 0, 0, 0.3))
  bg_1 = gradient_image('vertical', color(colors.fg[0].r, colors.fg[0].g, colors.fg[0].b, 1), color(colors.blue[10].r, colors.blue[10].g, colors.blue[10].b, 1))
  bg_2 = gradient_image('vertical', color(colors.fg[0].r, colors.fg[0].g, colors.fg[0].b, 1), color(colors.fg[0].r, colors.fg[0].g, colors.fg[0].b, 0.4))
  bg_gradient = bg_1
  bg_color = colors.blue[10]:color_clone()

  sfx = sound_tag{volume = 0.5}
  music = sound_tag{volume = 0.5}
  sounds = {}
  sounds.closed_shop = sound('assets/Recettear OST - Closed Shop.ogg', {tag = music})
  sounds.drop = sound('assets/パパッ.ogg', {tag = sfx})
  sounds.merge_1 = sound('assets/スイッチを押す.ogg', {tag = sfx})
  sounds.merge_2 = sound('assets/ぷよん.ogg', {tag = sfx})
  sounds.final_merge = sound('assets/可愛い動作1.ogg', {tag = sfx})
  sounds.its_over = sound('assets/ショック1.ogg', {tag = sfx})
  sounds.button_press = sound('assets/カーソル移動2.ogg', {tag = sfx})
  sounds.collider_button_press = sound('assets/カーソル移動12.ogg', {tag = sfx})
  sounds.button_hover = sound('assets/hover.ogg', {tag = sfx})
  sounds.end_round_retry = sound('assets/se_19.ogg', {tag = sfx})
  sounds.end_round_retry_press = sound('assets/se_17.ogg', {tag = sfx})
  sounds.end_round_score = sound('assets/se_13.ogg', {tag = sfx})
  sounds.end_round_fall = sound('assets/se_11.ogg', {tag = sfx})
  sounds.end_round = sound('assets/se_14.ogg', {tag = sfx})
  sounds.death_hit = sound('assets/se_22.ogg', {tag = sfx})

  main:physics_world_set_gravity(0, 360)
  main:physics_world_set_callbacks(nil, 'type')
  main:physics_world_set_collision_tags{'emoji', 'ghost', 'solid'}
  main:physics_world_disable_collision_between('emoji', {'ghost'})
  main:physics_world_disable_collision_between('ghost', {'emoji', 'ghost', 'solid'})
  main:physics_world_enable_trigger_between('ghost', {'emoji', 'ghost', 'solid'})

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
  color_multipliers = {'black', 'yellow', 'yellow_original', 'yellow_star', 'orange', 'red', 'green', 'blue', 'blue_original', 'purple', 'brown'}

  value_to_emoji_data = {
    [1] = {emoji = 'slight_smile', rs = 9, score = 1, mass_multiplier = 8, stars = 2, spawner_offset = vec2(0, 18)},
    [2] = {emoji = 'blush', rs = 11.5, score = 3, mass_multiplier = 6, stars = 2, spawner_offset = vec2(0, 20)},
    [3] = {emoji = 'thinking', rs = 16.5, score = 6, mass_multiplier = 4, stars = 3, spawner_offset = vec2(0, 25)},
    [4] = {emoji = 'devil', rs = 18.5, score = 10, mass_multiplier = 2, stars = 3, spawner_offset = vec2(0, 27)},
    [5] = {emoji = 'angry', rs = 23, score = 15, mass_multiplier = 1, stars = 4, spawner_offset = vec2(0, 32)},
    [6] = {emoji = 'relieved', rs = 29.5, score = 21, mass_multiplier = 1, stars = 4},
    [7] = {emoji = 'yum', rs = 35, score = 28, mass_multiplier = 1, stars = 5},
    [8] = {emoji = 'joy', rs = 41.5, score = 36, mass_multiplier = 1, stars = 6},
    [9] = {emoji = 'sob', rs = 47.5, score = 45, mass_multiplier = 0.5, stars = 8},
    [10] = {emoji = 'smirk', rs = 59, score = 56, mass_multiplier = 0.5, stars = 12},
    [11] = {emoji = 'sunglasses', rs = 70, score = 66, mass_multiplier = 0.25, stars = 24},
  }

  main.pointer = anchor('pointer'):init(function(self)
    self:prs_init(0, 0)
    self:collider_init('ghost', 'dynamic', 'rectangle', 2, 2)
    self:collider_set_gravity_scale(0)
    self:collider_set_bullet(true)
    self:hitfx_init()
  end):action(function(self, dt)
    self.x, self.y = main.camera.mouse.x, main.camera.mouse.y
    self:collider_set_position(self.x, self.y)
    if main:input_is_pressed'action_1' then self:hitfx_use('main', 0.25) end
    if not main.transitioning then
      local s = 18/images.index.w
      ui2:draw_image_or_quad(images.index, self.x + 6, self.y + 6, -math.pi/6, s*self.springs.main.x, s*self.springs.main.x, 0, 0, colors.white[0], (self.flashes.main.x and shaders.combine))
    end
    -- self:collider_draw(ui2, colors.blue[0])
  end)

  main.sfx_sound_level = main.game_state.sfx_sound_level or 4
  main.music_sound_level = main.game_state.music_sound_level or 4
  main.any_button_hot = false
  local level_to_volume = {0, 0.0625, 0.125, 0.25, 0.5}
  sfx.volume = level_to_volume[main.sfx_sound_level + 1]
  music.volume = level_to_volume[main.music_sound_level + 1]
  main.sfx_button = emoji_button(20, main.h - 20, {emoji = 'sound_' .. main.sfx_sound_level, w = 18, action = function(self)
    sounds.button_press:sound_play(1, main:random_float(0.95, 1.05))
    main.sfx_sound_level = main.sfx_sound_level - 1
    if main.sfx_sound_level < 0 then main.sfx_sound_level = 4 end
    main.game_state.sfx_sound_level = main.sfx_sound_level
    main:save_state()
    self.emoji = images['sound_' .. main.sfx_sound_level]
    sfx.volume = level_to_volume[main.sfx_sound_level + 1]
  end})
  main.music_button = emoji_button(48, main.h - 20, {emoji = 'sound_' .. main.music_sound_level, w = 18, action = function(self)
    sounds.button_press:sound_play(1, main:random_float(0.95, 1.05))
    main.music_sound_level = main.music_sound_level - 1
    if main.music_sound_level < 0 then main.music_sound_level = 4 end
    main.game_state.music_sound_level = main.music_sound_level
    main:save_state()
    self.emoji = images['sound_' .. main.music_sound_level]
    music.volume = level_to_volume[main.music_sound_level + 1]
  end})

  if not main.web then
    main.screen_button = emoji_button(78, main.h - 20, {emoji = 'screen', w = 18, action = function(self)
      sounds.button_press:sound_play(0.5, main:random_float(0.95, 1.05))
      main:resize_up(0.5)
    end})
  end
  main.close_button = emoji_button(main.w - 20, 20, {emoji = 'close', w = 18, action = function(self)
    sounds.button_press:sound_play(0.5, main:random_float(0.95, 1.05))
    main:quit()
  end})

  main.stars = {}
  main.distance_to_top = 294
  local r = math.pi/6 + math.pi
  local w, h = main.w/8, main.h/6
  for j = 1, 8 do
    for i = 1, 10 do
      local x_offset = 0
      if j % 2 == 0 then x_offset = w/2 end
      table.insert(main.stars, anchor('background_star'):init(function(self)
        self:prs_init((i-1)*w + x_offset, (j-1)*h, main:random_angle(), 32/images.star_gray.w, 32/images.star_gray.w)
        self.color = colors.fg[10]:color_clone()
      end):action(function(self, dt)
        local v = math.remap(main.distance_to_top, 0, 294, 16, 4)
        local vr = math.remap(main.distance_to_top, 0, 294, -0.2*math.pi, -0.05*math.pi)
        self.x = self.x + v*math.cos(r)*dt
        self.y = self.y + v*math.sin(r)*dt
        self.r = self.r + vr*dt
        if self.x <= -80 then self.x = main.w + 80 end
        if self.y <= -60 then self.y = main.h + 60 end
        if self.y < main.h - 120 then self.color.a = math.clamp(math.remap(self.y - (main.h - 120), -60, 0, 0, 1), 0, 1)
        else self.color.a = 1 end
        bg:draw_image_or_quad(images.star_gray, self.x, self.y, self.r, self.sx, self.sy, 0, 0, self.color)
      end))
    end
  end

  main.clouds = {}
  local w, h = main.w/8, main.h/6
  for j = 1, 3 do
    for i = 1, 10 do
      local x_offset = 0
      if j % 2 == 0 then x_offset = w/2 end
      table.insert(main.clouds, anchor('background_cloud'):init(function(self)
        self:prs_init((i-1)*w + x_offset, (j-1)*h + 14, 0, 32/images.cloud.w, 32/images.cloud.w)
        self.flip_sx = main:random_sign(50)
        self.emoji = images.cloud
      end):action(function(self, dt)
        self.x = self.x + 10*dt
        if self.x >= main.w + w + x_offset then self.x = -w + x_offset end
        bg:draw_image_or_quad(self.emoji, self.x, self.y, self.r, self.flip_sx*self.sx, self.sy)
      end))
    end
  end

  profile.start()
  profile_report = 'Please wait...'
  main:timer_every(2, function()
    profile_report = profile.report(20)
    print(profile_report)
    profile.reset()
  end)

  main:level_add('arena', arena())
  main:level_goto('arena')
  --[[
  main:level_add('title', title())
  main:level_goto('title')
  ]]--
end

function update(dt)
  --[[
  bg:rectangle(main.w/2, main.h/2, 3*main.w, 3*main.h, 0, 0, colors.fg[0])
  bg_fixed:push(0.5*main.w, 0.5*main.h, -math.pi/6)
  bg_2:gradient_image_draw(bg_fixed, 0.5*main.w, 0.5*main.h, main.w, -main.h)
  bg_fixed:pop()
  ]]--
  
  bg:rectangle(main.w/2, 75, main.w, 150, 0, 0, bg_color)
  bg_gradient:gradient_image_draw(bg, main.w/2, main.h/2, main.w, -60)
  bg:rectangle(main.w/2, main.h - 75, main.w, 150, 0, 0, colors.fg[0])
  for _, star in ipairs(main.stars) do star:update(dt) end
  for _, cloud in ipairs(main.clouds) do cloud:update(dt) end

  main.pointer:update(dt)
  main.lose_line:update(dt) 

  main.any_button_hot = false
  main.sfx_button:update(dt)
  main.music_button:update(dt)
  if not main.web then main.screen_button:update(dt) end
  if main.logical_fullscreen then main.close_button:update(dt) end
  if main.sfx_button.trigger_active[main.pointer] then main.any_button_hot = true end
  if main.music_button.trigger_active[main.pointer] then main.any_button_hot = true end
  if not main.web then
    if main.screen_button.trigger_active[main.pointer] then main.any_button_hot = true end
  end
  if main.close_button.trigger_active[main.pointer] then main.any_button_hot = true end

  if main.transitioning then ui2:circle(main.w/2, main.h/2, main.transition_rs, colors.blue[5]) end
end

function draw_emoji_character(layer, character, x, y, r, sx, sy, ox, oy, color)
  layer:send(shaders.multiply_emoji, 'base', 161/255)
  layer:send(shaders.multiply_emoji, 'multiplier', color_to_emoji_multiplier[color])
  layer:draw_image_or_quad(images[character], x, y, r, sx, sy, ox, oy, nil, shaders.multiply_emoji)
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
    shadow.x, shadow.y = 4*main.sx, 4*main.sy
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
--}}}


--{{{ title
title = class:class_new(anchor)
function title:new(x, y, args)
  self:anchor_init('title', args)
end

function title:enter()
  self.objects = container()
  self.objects:container_add(text_roped_chain('emoji merge', main.w/2, main.h/2, {w = 24, chain_part_size = 12, no_impulse = true}))
  self.objects:container_add(emoji_collider(main.w/2, main.h/2 - 40, {emoji = 'sunglasses', w = 56, damping = 0.5}))
  self.objects:container_add(emoji_collider(main.w/2 - 60, main.h/2 - 40, {emoji = 'sob', w = 42, r = math.pi/16, damping = 0.5}))
  self.objects:container_add(emoji_collider(main.w/2 + 60, main.h/2 - 40, {emoji = 'joy', w = 42, r = -math.pi/16, damping = 0.5}))
end

function title:update(dt)
  -- Apply mouse movement to colliders
  for _, object in ipairs(self.objects.objects) do
    if (object:is('emoji_collider') or object:is('emoji_character') or object:is('chain_part')) and object.trigger_active[main.pointer] then
      if main:input_is_pressed'action_1' then
        self.held_object = object
        object:hitfx_use('main', 0.25)
      end
      if object.trigger_enter[main.pointer] then object:hitfx_use('main', 0.125) end
    end
  end
  if main:input_is_released'action_1' then self.held_object = nil end
  if self.held_object and main:input_is_down'action_1' then
    self.held_object:collider_set_angular_damping(4)
    local d = math.remap(math.distance(main.camera.mouse.x, main.camera.mouse.y, self.held_object.x, self.held_object.y), 0, 300, 64, 16)
    self.held_object:collider_apply_force(d*main.camera.mouse_dt.x, d*main.camera.mouse_dt.y, self.held_object.x, self.held_object.y)
  end

  self.objects:container_update(dt)
  self.objects:container_remove_dead()
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
  self.chain_amount = 0
end

function arena:enter()
  bg_color = colors.blue[10]:color_clone()
  bg_gradient = bg_1
  for _, cloud in ipairs(main.clouds) do cloud.emoji = images.cloud end

  main:music_player_play_song(sounds.closed_shop, 0.375)

  self.emojis = container()
  self.plants = container()
  self.objects = container()
  self.merge_objects = {}
  self.chain_amount = 0

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
  main:load_state()
  self.best = main.game_state.best or 0
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
  self:choose_next_emoji()

  -- Lose condition line
  main.lose_line = anchor('lose_line'):init(function(self)
    self:prs_init(main.w/2, main.level.y1)
    self:observer_init()
    self:timer_init()
    self.color = colors.red[0]:color_clone()
    self.color.a = 0
    self.active = false
    self:observer_condition(function() return main.distance_to_top <= 64 end, function()
      self.active = true
      self:timer_tween(0.5, self.color, {a = 1}, math.cubic_in_out, nil, 'alpha')
    end, nil, nil, 'active_true')
    self:observer_condition(function() return main.distance_to_top > 64 end, function()
      self.active = false
      self:timer_tween(0.5, self.color, {a = 0}, math.cubic_in_out, nil, 'alpha')
    end, nil, nil, 'active_false')
  end):action(function(self, dt)
    ui1:dashed_line(main.level.x1 + 8, self.y, main.level.x2 - 8, self.y, 16, 8, self.color, 2)
  end)
end

function arena:update(dt)
  -- Spawner movement
  if self.spawner and not self.round_ending then
    local left_offset, right_offset = 0, 0
    if self.spawner_emoji then
      left_offset = left_offset + self.spawner_emoji.rs - 4
      right_offset = right_offset - self.spawner_emoji.rs - 20
    end
    local y_offset = 0
    if main.distance_to_top <= 100 then
      y_offset = math.remap(main.distance_to_top, 100, 0, 0, -42)
    end
    self.spawner.x = math.clamp(main.pointer.x - 12, self.x1 + left_offset, self.x2 + right_offset)
    self.spawner.y = math.lerp_dt(5, dt, self.spawner.y, 20 + y_offset)
    self.spawner:collider_set_position(self.spawner.x, self.spawner.y)
  end

  -- Spawner emoji movement
  if self.spawner_emoji and not self.spawner_emoji.dropping and not self.round_ending then
    local o = value_to_emoji_data[self.spawner_emoji.value].spawner_offset
    self.spawner_emoji:collider_set_position(self.spawner.x + 12 + o.x, self.spawner.y + o.y)
    if main:input_is_pressed('action_1') and not main.any_button_hot then
      self:drop_emoji()
    end
  end

  -- Merge emojis
  for _, c in ipairs(main:physics_world_get_collision_enter('emoji', 'emoji')) do
    local a, b = c[1], c[2]
    if not a.dead and not b.dead and a.has_dropped and b.has_dropped then
      if a.value == b.value then
        self:merge_emojis(a, b, c[3], c[4])
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
    local x, y = c[3], c[4]
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
    local top_emoji = self.emojis:container_get_highest_object(function(v) return v.id ~= self.spawner_emoji.id end)
    if top_emoji then main.distance_to_top = top_emoji.y - self.y1
    else main.distance_to_top = self.y2 - self.y1 end

    for _, emoji in ipairs(self.emojis.objects) do
      if emoji.y < self.y1 and emoji.id ~= self.spawner_emoji.id and not emoji.dead and not emoji.dropping and not emoji.just_merged then
        self:end_round()
      end
    end
  end

  -- Apply mouse movement to colliders
  if self.score_ending then
    for _, object in ipairs(self.objects.objects) do
      if (object:is('emoji_collider') or object:is('emoji_character') or object:is('chain_part')) and object.trigger_active[main.pointer] then
        if main:input_is_pressed'action_1' then
          self.held_object = object
          object:hitfx_use('main', 0.25)
          sounds.collider_button_press:sound_play(1, main:random_float(0.95, 1.05))
        end
        if object.trigger_enter[main.pointer] then
          object:hitfx_use('main', 0.125)
          sounds.button_hover:sound_play(1, main:random_float(0.95, 1.05))
        end
      end
    end
    if main:input_is_released'action_1' then self.held_object = nil end
    if self.held_object and main:input_is_down'action_1' then
      self.held_object:collider_set_angular_damping(4)
      local d = math.remap(math.distance(main.camera.mouse.x, main.camera.mouse.y, self.held_object.x, self.held_object.y), 0, 300, 64, 16)
      self.held_object:collider_apply_force(d*main.camera.mouse_dt.x, d*main.camera.mouse_dt.y, self.held_object.x, self.held_object.y)
    end
  end

  -- Retry button
  if self.score_ending then
    if self.retry_button.trigger_active[main.pointer] then
      self.retry_button.hot = true
    else
      self.retry_button.hot = false
    end

    if self.retry_button.hot and not self.retry_button.pressed and main:input_is_pressed'action_1' then
      sounds.end_round_retry_press:sound_play(1)
      self.retry_button.pressed = true
      self.retry_button:hitfx_use('main', 0.25, nil, nil, 0.15)
      self:timer_after(0.066, function() self.retry_chain:flash_text() end)
      main.transitioning = true
      main.transition_rs = 0
      main:timer_after(0.066*7, function()
        sounds.end_round_retry:sound_play(0.75, main:random_float(0.95, 1.05))
        main:timer_tween(0.8, main, {transition_rs = 0.75*main.w}, math.cubic_in_out, function()
          main:timer_after(0.4, function()
            main:level_goto('arena')
            main:timer_tween(0.8, main, {transition_rs = 0}, math.cubic_in_out, function() main.transitioning = false end)
          end)
        end)
      end)
    end
  end

  --[[
  if main:input_is_pressed'2' then
    self:end_round()
  end
  ]]--
  
  self.emojis:container_update(dt)
  self.plants:container_update(dt)
  self.objects:container_update(dt)
  self.emojis:container_remove_dead()
  self.plants:container_remove_dead()
  self.objects:container_remove_dead()
end

function arena:exit()
  self.solid_top = nil
  self.solid_bottom = nil
  self.solid_left = nil
  self.solid_right = nil
  self.solid_left_joint = nil
  self.score_board = nil
  self.score_left_chain = nil
  self.score_right_chain = nil
  self.best_board = nil
  self.best_chain = nil
  self.next_board = nil
  self.next_left_chain = nil
  self.next_right_chain = nil
  self.next_board = nil
  self.curving_arrow = nil
  self.evoji_emojis = nil
  self.joints = nil
  self.evoji_chain_left = nil
  self.evoji_chain_right = nil
  self.curving_chain = nil
  self.spawner = nil
  self.spawner_emoji = nil
  self.round_ending = false
  self.score_ending = false
  self.retry_button = nil
  self.retry_chain = nil
  self.final_score_chain = nil
  self.merge_objects = nil
  self.plants:container_destroy()
  self.emojis:container_destroy()
  self.objects:container_destroy()
  self.plants = nil
  self.emojis = nil
  self.objects = nil
  self.all_objects = nil
  main:container_remove_dead_without_destroying()
end

function arena:drop_emoji()
  sounds.drop:sound_play(0.6, main:random_float(0.95, 1.05))
  local x, y = (self.spawner.x + self.spawner_emoji.x)/2, (self.spawner.y + self.spawner_emoji.y)/2
  self.spawner.drop_x, self.spawner.drop_y = x, y
  self.spawner_emoji.drop_x, self.spawner_emoji.drop_y = x, y
  self.spawner:hitfx_use('drop', 0.25)
  self.spawner_emoji:hitfx_use('drop', 0.25)
  self.spawner.emoji = images.open_hand
  self.spawner:timer_after(0.5, function() self.spawner.emoji = images.closed_hand end, 'close_hand')

  self.spawner_emoji:collider_set_gravity_scale(1)
  self.spawner_emoji:collider_apply_impulse(0, 0.01)
  self.spawner_emoji.dropping = true
  self.spawner_emoji.has_dropped = true
  self.spawner_emoji:observer_condition(function() return (self.spawner_emoji.collision_enter.emoji or self.spawner_emoji.collision_enter.solid) and self.spawner_emoji.dropping end, function()
    if main.lose_line.active then return end
    self.spawner_emoji.dropping = false
    self:choose_next_emoji()
  end, nil, nil, 'drop_emoji')
  self:timer_after(2, function()
    self.spawner.emoji = images.closed_hand
    if self.spawner_emoji.dropping then
      self.spawner_emoji.dropping = false
      self:choose_next_emoji()
    end
  end, 'drop_safety')
end

function arena:choose_next_emoji()
  if self.round_ending then return end
  self:timer_cancel('drop_safety')
  self.spawner.emoji = images.closed_hand
  self.spawner_emoji = self.emojis:container_add(emoji(self.spawner.x, self.y1, {hitfx_on_spawn_no_flash = 0.5, value = self.next}))
  local x, y = (self.spawner.x + self.spawner_emoji.x)/2, (self.spawner.y + self.spawner_emoji.y)/2
  self.spawner.drop_x, self.spawner.drop_y = x, y
  self.spawner:hitfx_use('drop', 0.25)
  self.next = main:random_weighted_pick(30, 25, 20, 15, 10)
  self.next_board:hitfx_use('emoji', 0.5)
end

function arena:merge_emojis(a, b, x, y)
  if self.round_ending then return end
  a.dead = true
  b.dead = true
  self.objects:container_add(emoji_merge_effect(a.x, a.y, {emoji = a.emoji, r = a.r, sx = a.sx, sy = a.sy, target_x = x, target_y = y}))
  self.objects:container_add(emoji_merge_effect(b.x, b.y, {emoji = b.emoji, r = b.r, sx = b.sx, sy = b.sy, target_x = x, target_y = y}))
  local avx, avy = a:collider_get_velocity()
  local bvx, bvy = b:collider_get_velocity()
  self.chain_amount = self.chain_amount + 1
  local added_score = value_to_emoji_data[a.value].score
  self.score = self.score + added_score
  self:timer_after(1, function() self.chain_amount = 0 end, 'chain_amount')

  if a.value < 11 and b.value < 11 then
    sounds.merge_1:sound_play(0.4, main:random_float(0.95, 1.05))
    sounds.merge_2:sound_play(0.4, main:random_float(0.95, 1.05))
    local merge_object = self.objects:container_add(anchor('merge_object'):timer_init():action(function() end))
    table.insert(self.merge_objects, merge_object)
    merge_object:timer_after(0.15, function()
      local emoji = self.emojis:container_add(emoji(x, y, {from_merge = true, hitfx_on_spawn = 1, value = a.value + 1}))
      emoji.has_dropped = true
      emoji:collider_set_gravity_scale(1)
      emoji:collider_apply_impulse((avx+bvx)/6, (avy+bvy)/6)
    end, 'merge_emojis')
  end
  if a.value == 11 and b.value == 11 then
    sounds.final_merge:sound_play(0.5, main:random_float(0.95, 1.05))
  end
end

function arena:end_round()
  if self.round_ending then return end
  self.round_ending = true

  main:music_player_stop()
  sounds.end_round:sound_play(1, main:random_float(0.95, 1.05))

  self:observer_cancel('drop_emoji')
  self:timer_cancel('drop_safety')
  for _, object in ipairs(self.merge_objects) do object:timer_cancel('merge_emojis') end
  self:timer_cancel('lose_line')
  main.lose_line:observer_cancel('active_true')
  main.lose_line:observer_cancel('active_false')
  main.lose_line.color.a = 0
  main.lose_line.active = false

  if self.score > self.best then self.best = self.score end
  main.game_state.best = self.best
  main:save_state()

  local top_emoji = self.emojis:container_get_highest_object(function(v) return v.id ~= self.spawner_emoji.id end)
  local objects = {}
  for _, object in ipairs(main.objects) do
    if object:is('board') or object:is('solid') or object:is('emoji') or object:is('plant') or object:is('chain_part') or object:is('evoji_emoji') or object:is('spawner') then
      table.insert(objects, object)
    end
  end
  table.sort(objects, function(a, b) return math.distance(top_emoji.x, top_emoji.y, a.x, a.y) < math.distance(top_emoji.x, top_emoji.y, b.x, b.y) end)

  -- Turn objects black and white by setting .dying to true
  -- PERFORMANCE: the browser really does not like to play the same sound effect every 0.02s (????), so disable it for web version
  local i = 1
  self:timer_every(0.02, function()
    local object = objects[i]
    if object.dying then return end
    object.dying = true
    if not main.web then sounds.death_hit:sound_play(0.5, main:random_float(0.95, 1.05)) end
    if object:is('solid') or object:is('board') or object:is('evoji_emoji') then
      object:hitfx_use('main', 0.125)
      object:timer_after(0.15, function() object:shake_shake(2, 0.5) end)
    else
      object:hitfx_use('main', 0.25)
      object:timer_after(0.15, function() object:shake_shake(4, 0.5) end)
    end
    i = i + 1
  end, #objects)

  -- Turn background elements to grayscale
  bg_color = color(colors.fg[0].r, colors.fg[0].g, colors.fg[0].b, 0.4)
  bg_gradient = bg_2
  for _, cloud in ipairs(main.clouds) do cloud.emoji = images.cloud_gray end

  -- Prevent dying objects from moving
  self:timer_run(function()
    for _, object in ipairs(objects) do
      if object.body then
        object:collider_set_awake(false)
      end
    end
  end, nil, 'prevent_dying_movement')

  -- Make all objects fall
  self:timer_after(0.02*#objects + 0.5, function()
    self:timer_cancel('prevent_dying_movement')
    sounds.end_round_fall:sound_play(1, main:random_float(0.95, 1.05))

    -- Remove joints
    local solid_joints = {self.solid_left_joint, self.solid_right_joint}
    main:random_table_remove(solid_joints):joint_destroy()
    self:timer_after({0.4, 0.8}, function() main:random_table_remove(solid_joints):joint_destroy() end)
    self:timer_after({0.6, 0.8}, function() self.best_chain:remove_random_joint() end)
    local score_chains = {self.score_left_chain, self.score_right_chain}
    self:timer_after({0, 0.8}, function()
      main:random_table_remove(score_chains):remove_random_joint()
      self:timer_after({0.4, 0.8}, function() main:random_table_remove(score_chains):remove_random_joint() end)
    end)
    local evoji_chains = {self.evoji_chain_left, self.evoji_chain_right}
    self:timer_after({0, 0.8}, function()
      main:random_table_remove(evoji_chains):remove_random_joint()
      self:timer_after({0.4, 0.8}, function() main:random_table_remove(evoji_chains):remove_random_joint() end)
    end)
    local next_chains = {self.next_left_chain, self.next_right_chain}
    self:timer_after({0, 0.8}, function()
      main:random_table_remove(next_chains):remove_random_joint()
      self:timer_after({0.4, 0.8}, function() main:random_table_remove(next_chains):remove_random_joint() end)
    end)

    -- Apply impulses
    for _, object in ipairs(objects) do
      if object.body then -- BUG: when the game ends and the arena is filled it happened once that an emoji object didn't have a body anymore, don't know why so this is here
        if object:is('solid') then
          if object.id == self.solid_left.id then
            object:collider_set_body_type('dynamic')
            object:collider_apply_impulse(-100, 0, object.x, object.y - object.h/4 + main:random_float(-object.h/8, object.h/8))
            object:collider_set_gravity_scale(main:random_float(0.3, 0.5))
          elseif object.id == self.solid_right.id then
            object:collider_set_body_type('dynamic')
            object:collider_apply_impulse(100, 0, object.x, object.y - object.h/4 + main:random_float(-object.h/8, object.h/8))
            object:collider_set_gravity_scale(main:random_float(0.3, 0.5))
          elseif object.id == self.solid_bottom.id then
            object:collider_set_body_type('dynamic')
            object:collider_set_gravity_scale(main:random_float(0.3, 0.5))
          end

        elseif object:is('emoji') then
          local mass_multiplier = 4*object:collider_get_mass()
          object:collider_set_gravity_scale(main:random_float(0.8, 1.2))
          object:collider_apply_impulse(mass_multiplier*main:random_float(-20, 20), mass_multiplier*main:random_float(-40, 0))
          object:collider_apply_angular_impulse(mass_multiplier*main:random_float(-4*math.pi, 4*math.pi))

        elseif object:is('spawner') then
          object:collider_set_gravity_scale(main:random_float(1, 1.2))
          local vx = main:random_float(-40, 40)
          object:collider_apply_impulse(vx, main:random_float(-60, -20))
          object:collider_apply_angular_impulse(-math.sign(vx)*main:random_float(-24*math.pi, -8*math.pi))

        elseif object:is('plant') and not object.board then
          object:collider_set_body_type('dynamic')
          object:collider_set_gravity_scale(main:random_float(0.1, 0.6))
          object:collider_apply_impulse(main:random_float(-5, 5), main:random_float(-5, 0))
          object:collider_apply_angular_impulse(main:random_float(-12*math.pi, 12*math.pi))
          object:timer_after({0.2, 1}, function()
            object:timer_every(0.05, function() object.hidden = not object.hidden end, 7, true, function() object.dead = true end)
          end)
        end
      end
    end
  end)

  -- Spawn score
  self:timer_after(0.02*#objects + 3, function()
    self.score_ending = true
    sounds.end_round_score:sound_play(0.75)
    sounds.its_over:sound_play(0.75)

    local text = 'score ' .. self.score
    self.final_score_chain = text_roped_chain(text, -46*utf8.len(text), main.h/2 + 48)
    self.retry_button = emoji_collider(main.w + 64 + main:random_float(-2, 2), main.h/2 - 48 + main:random_float(-8, 8), {emoji = 'retry', w = 64})
    self.retry_button:collider_apply_angular_impulse(main:random_sign(50)*main:random_float(48, 96)*math.pi)
    self.retry_button:collider_apply_impulse(-128, 0)
    self.retry_button:timer_after(4, function() 
      self.retry_button:collider_set_damping(0.5)
      self.retry_button:collider_set_angular_damping(0.5)
    end)
    self.objects:container_add(self.retry_button)
    self.retry_chain = self.objects:container_add(text_chain('retry', self.retry_button, self.retry_button.x + self.retry_button.w/2, self.retry_button.y, 16))
  end)
end
--}}}


--{{{ boards + chains
board = class:class_new(anchor)
function board:new(board_type, x, y, args)
  self:anchor_init('board', args)
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
  if self.trigger_active[main.pointer] then
    local multiplier = main:input_is_down'action_1' and 3 or 1
    self:collider_apply_force(multiplier*self.w*main.camera.mouse_dt.x, multiplier*self.h*main.camera.mouse_dt.y)
  end
  if self.trigger_active[main.pointer] and main:input_is_pressed'action_1' then 
    self:hitfx_use('main', 0.25)
    for i = 1, main:random_int(2, 3) do 
      main.level.objects:container_add(emoji_particle('star', main.camera.mouse.x, main.camera.mouse.y, {hitfx_on_spawn_no_flash = 0.75, r = main:random_angle(), rotation_v = main:random_float(-2*math.pi, 2*math.pi)}))
    end
  end

  game2:push(self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x)
    game2:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, 1, 1, 0, 0, colors.white[0], (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game2:pop()
  game2:push(self.x, self.y, self.r, self.springs.main.x, self.springs.main.x)
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
          game3:draw_image_or_quad(next, self.x + self.shake_amount.x, self.y + 15 + self.shake_amount.y, 0, sx*self.springs.main.x, sy*self.springs.main.x, 0, 0, colors.white[0], 
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

function emoji_chain:remove_random_joint()
  local joint = main:random_table_remove(self.joints)
  joint:joint_destroy()
end

function emoji_chain:set_gravity_scale(g)
  for _, chain_part in ipairs(self.chain_parts) do
    chain_part:collider_set_gravity_scale(g)
  end
end


text_chain = class:class_new(anchor)
function text_chain:new(text, collider, x, y, chain_part_size, args)
  self:anchor_init('text_chain', args)
  self:timer_init()
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
    chain_part:collider_set_gravity_scale(0)
    chain_part:collider_set_mass(chain_part:collider_get_mass()*0.05)
  end
end

function text_chain:update(dt)

end

function text_chain:flash_text()
  for i, chain_part in ipairs(self.chain_parts) do
    self:timer_after((i-1)*0.066, function()
      chain_part:hitfx_use('main', 0.5, nil, nil, 0.15)
    end)
  end
end


text_roped_chain = class:class_new(anchor)
function text_roped_chain:new(text, x, y, args)
  self:anchor_init('text_roped_chain', args)
  self.text = text
  self.x, self.y = x, y
  self.w = self.w or 32

  self.characters = {}
  local x = self.x
  for i = 1, utf8.len(self.text) do
    local c = utf8.sub(self.text, i, i)
    if c == ' ' then
      x = x + self.w*1.1875
    else
      local character = emoji_character(x, main.h/2 + 48, {character = c, color = 'blue_original', w = self.w})
      table.insert(self.characters, character)
      main.level.objects:container_add(character)
      x = x + self.w*1.5
    end
  end

  self.chains = {}
  for i, character in ipairs(self.characters) do
    local next_character = self.characters[i+1]
    if next_character then
      local chain = main.level.objects:container_add(emoji_chain('blue_chain', character, next_character, character.x + character.w/2, character.y, next_character.x - next_character.w/2, next_character.y, 
        {chain_part_size = self.chain_part_size or 9}))
      table.insert(self.chains, chain)
      chain:set_gravity_scale(0)
    end
  end

  for _, character in ipairs(self.characters) do
    if not self.no_impulse then
      character:collider_apply_angular_impulse(main:random_float(8, 12)*main:random_float(math.pi/2, math.pi))
      character:collider_apply_impulse(48, 0)
    end
    character:timer_after(4, function() character:collider_set_damping(0.5) end)
  end
end

function text_roped_chain:update(dt)

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
    game1:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
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
      self.plants:container_add(arena_plant(x + 5*math.cos(r - math.pi/2), y + 5*math.sin(r - math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 5*math.cos(r + math.pi/2), y + 5*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game1, emoji = 'sheaf', direction = direction}))
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
      self.plants:container_add(arena_plant(x + 12*math.cos(r + math.pi/2), y + 12*math.sin(r + math.pi/2), {w = 12, h = 12, layer = game1, emoji = 'seedling', direction = direction}))
    elseif n == 6 then
      self.plants:container_add(arena_plant(x + 12*math.cos(r - math.pi/2), y + 12*math.sin(r - math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'sheaf', direction = direction}))
      self.plants:container_add(arena_plant(x + 0*math.cos(r - math.pi/2), y + 0*math.sin(r - math.pi/2), {w = 17, h = 17, layer = game1, emoji = 'four_leaf_clover', direction = direction}))
      self.plants:container_add(arena_plant(x + 8*math.cos(r + math.pi/2), y + 8*math.sin(r + math.pi/2), {w = 12, h = 12, layer = game3, emoji = 'seedling', direction = direction}))
    elseif n == 7 then
      self.plants:container_add(arena_plant(x + 0*math.cos(r - math.pi/2), y + 0*math.sin(r - math.pi/2), {w = 20, h = 20, layer = game1, emoji = 'blossom', direction = direction}))
      self.plants:container_add(arena_plant(x + 10*math.cos(r - math.pi/2), y + 10*math.sin(r - math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'sheaf', direction = direction}))
      self.plants:container_add(arena_plant(x + 5*math.cos(r + math.pi/2), y + 5*math.sin(r + math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 10*math.cos(r + math.pi/2), y + 10*math.sin(r + math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 20*math.cos(r + math.pi/2), y + 20*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'sheaf', direction = direction}))
    elseif n == 8 then
      self.plants:container_add(arena_plant(x + 0*math.cos(r - math.pi/2), y + 0*math.sin(r - math.pi/2), {w = 20, h = 20, layer = game3, emoji = 'tulip', direction = direction}))
      self.plants:container_add(arena_plant(x + 16*math.cos(r - math.pi/2), y + 16*math.sin(r - math.pi/2), {w = 15, h = 15, layer = game1, emoji = 'tulip', direction = direction}))
      self.plants:container_add(arena_plant(x + 16*math.cos(r + math.pi/2), y + 16*math.sin(r + math.pi/2), {w = 12, h = 12, layer = game1, emoji = 'tulip', direction = direction}))
    end
  end

  -- Bottom solid
  local plant_positions = {}
  for x = self.x1 + 25, self.x1 + self.w - 25, 25 do table.insert(plant_positions, {x = x, y = self.y2 - 15, direction = 'up'}) end
  for i = 1, main:random_int(2, 3) do
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
  self:collider_init('ghost', 'dynamic', 'rectangle', self.w, self.h)
  self:collider_set_gravity_scale(0)
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
  self:collider_set_awake(true)

  if self.trigger_active[main.pointer] then
    self:apply_moving_force(main.camera.mouse_dt.x, main.camera.mouse_dt.y, 50*main.camera.mouse_dt:vec2_length())
  end

  if self.direction == 'up' or self.direction == 'down' then
    self.constant_wind_r = 0.2*math.sin(1.4*main.time + 0.01*self.x)
  elseif self.direction == 'left' or self.direction == 'right' then
    self.constant_wind_r = 0.2*math.sin(1.4*main.time + 0.01*self.y)
  end

  if self.dying then self.constant_wind_r = 0 end

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
  if self.hidden then return end
  if self.direction == 'up' or self.direction == 'down' then
    self.layer:push(self.x, self.y + self.h/2, self.r + self.constant_wind_r + self.random_wind_r + self.moving_wind_force_r + self.direct_wind_force_r)
      self.layer:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0],
        (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
    self.layer:pop()
  elseif self.direction == 'right' or self.direction == 'left' then
    self.layer:push(self.x, self.y, self.r)
      self.layer:push(self.x, self.y + self.h/2, self.constant_wind_r + self.random_wind_r + self.moving_wind_force_r + self.direct_wind_force_r)
        self.layer:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0],
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

  self.board_ox, self.board_oy = x, y
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
  self.x, self.y = math.rotate_point(self.board.x + self.board_ox, self.board.y + self.board_oy, self.board.r, self.board.x, self.board.y)
  local vx, vy = self.board:collider_get_velocity()
  if self.trigger_active[main.pointer] then self:apply_direct_force(main.camera.mouse_dt.x, main.camera.mouse_dt.y, 5*main.camera.mouse_dt:vec2_length()) end
  self:apply_moving_force(-vx, 0, 5*vx)
  self:collider_set_position(self.x, self.y)

  if self.dying then self.constant_wind_r = 0 end

  if self.direction == 'up' or self.direction == 'down' then
    local r_ox, r_oy = 0, self.h/2
    if self.emoji_type == 'sheaf' then r_ox, r_oy = -self.flip_sx*0.21*self.w, self.h/2 end
    self.layer:push(self.x, self.y, self.board.r)
      self.layer:push(self.x + r_ox, self.y + r_oy, self.r + self.constant_wind_r + self.random_wind_r + self.moving_wind_force_r + self.direct_wind_force_r)
        self.layer:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0],
          (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
      self.layer:pop()
    self.layer:pop()
  end

  -- self:area_draw(game3, colors.blue[0]) 
end
--}}}


--{{{ misc + effects
emoji_button = class:class_new(anchor)
function emoji_button:new(x, y, args)
  self:anchor_init('emoji_button', args)
  self.emoji = images[self.emoji]
  self:prs_init(x, y, 0, self.w/self.emoji.w, self.w/self.emoji.h)
  self:collider_init('ghost', 'dynamic', 'rectangle', self.w, self.w)
  self:collider_set_gravity_scale(0)
  self:hitfx_init()
  self:timer_init()
end

function emoji_button:update(dt)
  self:collider_set_awake(true)

  if self.trigger_enter[main.pointer] then
    sounds.button_hover:sound_play(1, main:random_float(0.95, 1.05))
    self:hitfx_use('main', 0.25)
  end
  if self.trigger_active[main.pointer] and main:input_is_pressed'action_1' then
    self:hitfx_use('main', 0.5, nil, nil, 0.15)
    self:action()
  end
  game3:draw_image_or_quad(self.emoji, self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], self.flashes.main.x and shaders.combine)
end


emoji_character = class:class_new(anchor)
function emoji_character:new(x, y, args)
  self:anchor_init('emoji_character', args)
  self.emoji = images[self.character]
  self.color = self.color or 'blue_original'
  self:prs_init(x, y, 0, self.w/self.emoji.w, self.w/self.emoji.h)
  self:collider_init('emoji', 'dynamic', 'rectangle', self.w, self.w)
  self:collider_set_gravity_scale(0)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()
end

function emoji_character:update(dt)
  self:collider_update_position_and_angle()
  draw_emoji_character(game2, self.character, self.x + self.shake_amount.x, self.y + self.shake_amount.y + self.oy, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, 
    (self.flashes.main.x and 'white') or (self.dying and 'gray') or self.color)
end

function emoji_character:change_effect()
  self:hitfx_use('main', 0.2, nil, nil, 0.15)
  self.oy = 6
  self:timer_tween(0.2, self, {oy = 0}, math.linear, function() self.oy = 0 end, 'oy')
end


emoji_collider = class:class_new(anchor)
function emoji_collider:new(x, y, args)
  self:anchor_init('emoji_collider', args)
  self.emoji = images[self.emoji]
  self:prs_init(x, y, self.r or 0, self.w/self.emoji.w, self.w/self.emoji.h)
  self:collider_init('emoji', 'dynamic', 'rectangle', self.w, self.w)
  self:collider_set_gravity_scale(0)
  self:collider_set_angle(self.r)
  self:hitfx_init()
  self:timer_init()
  self:shake_init()
  self.hot_offset = 0
  self.hot_animation = animation_logic(0.08, 4, 'bounce', {
    [1] = function() self.hot_offset = 0 end,
    [2] = function() self.hot_offset = 2 end,
    [3] = function() self.hot_offset = 4 end,
    [4] = function() self.hot_offset = 6 end,
  })
  if self.damping then self:collider_set_damping(0.5) end
end

function emoji_collider:update(dt)
  self.hot_animation:animation_logic_update(dt)
  self:collider_update_position_and_angle()

  game2:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
    (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  if self.hot and not main.transitioning then
    game3:push(self.x, self.y, self.r, self.springs.main.x, self.springs.main.x)
    local x1, y1, x2, y2 = self.x - 1.3*self.w/2 + self.hot_offset, self.y - 1.3*self.h/2 + self.hot_offset, self.x + 1.3*self.w/2 - self.hot_offset, self.y + 1.3*self.h/2 - self.hot_offset
    game3:line(x1, y1, x1 + 6, y1, colors.fg[0], 2)
    game3:line(x1, y1, x1, y1 + 6, colors.fg[0], 2)
    game3:line(x2 - 6, y1, x2, y1, colors.fg[0], 2)
    game3:line(x2, y1, x2, y1 + 6, colors.fg[0], 2)
    game3:line(x2 - 6, y2, x2, y2, colors.fg[0], 2)
    game3:line(x2, y2, x2, y2 - 6, colors.fg[0], 2)
    game3:line(x1, y2 - 6, x1, y2, colors.fg[0], 2)
    game3:line(x1, y2, x1 + 6, y2, colors.fg[0], 2)
    game3:pop()
  end
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
  if self.trigger_active[main.pointer] then
    local multiplier = main:input_is_down'action_1' and 2 or 1
    self:collider_apply_force(multiplier*self.w*main.camera.mouse_dt.x, multiplier*self.h*main.camera.mouse_dt.y)
  end
  if self.trigger_active[main.pointer] and main:input_is_pressed'action_1' then
    self:hitfx_use('main', 0.25)
    for i = 1, main:random_int(2, 3) do 
      main.level.objects:container_add(emoji_particle('star', main.camera.mouse.x, main.camera.mouse.y, {hitfx_on_spawn_no_flash = 0.75, r = main:random_angle(), rotation_v = main:random_float(-2*math.pi, 2*math.pi)}))
    end
  end
  game2:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r + (self.r_offset or 0), self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
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
  game2:draw_image_or_quad(self.emoji, self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, nil, nil, colors.white[0], self.flashes.main.x and shaders.combine)
end


emoji_particle = class:class_new(anchor)
function emoji_particle:new(emoji, x, y, args)
  self:anchor_init('emoji_particle', args)
  self.emoji = images[emoji]
  self:prs_init(x, y, self.r or main:random_angle(), (self.s or 1)*14/self.emoji.w, (self.s or 1)*14/self.emoji.h)
  self:timer_init()
  self:hitfx_init()
  if self.hitfx_on_spawn then self:hitfx_use('main', 0.5*self.hitfx_on_spawn, nil, nil, 0.3*self.hitfx_on_spawn) end
  if self.hitfx_on_spawn_no_flash then self:hitfx_use('main', 0.5*self.hitfx_on_spawn_no_flash) end

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
  effects:draw_image_or_quad(self.emoji, self.x, self.y, self.r + self.visual_r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, nil, nil, colors.white[0], self.flashes.main.x and shaders.combine)
end
--}}}


--{{{ spawner, emoji
spawner = class:class_new(anchor)
function spawner:new(x, y, args)
  self:anchor_init('spawner', args)
  self.emoji = images.closed_hand
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
  self:collider_update_position_and_angle()
  game3:push(self.drop_x, self.drop_y, 0, self.springs.drop.x, self.springs.drop.x)
    game3:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game3:pop()
end


emoji = class:class_new(anchor)
function emoji:new(x, y, args)
  self:anchor_init('emoji', args)
  self.value = self.value or 1
  self.rs = value_to_emoji_data[self.value].rs
  self.emoji_name = value_to_emoji_data[self.value].emoji
  self.emoji = images[self.emoji_name]
  self.stars = value_to_emoji_data[self.value].stars
  self:prs_init(x, y, 0, 2*self.rs/self.emoji.w, 2*self.rs/self.emoji.h)
  self:collider_init('emoji', 'dynamic', 'circle', self.rs)
  self:collider_set_restitution(0.2)
  self:collider_set_gravity_scale(0)
  self:collider_set_mass(value_to_emoji_data[self.value].mass_multiplier*self:collider_get_mass())
  self:timer_init()
  self:observer_init()
  self:hitfx_init()
  self:shake_init()

  if self.hitfx_on_spawn then self:hitfx_use('main', 0.5*self.hitfx_on_spawn, nil, nil, 0.15) end
  if self.hitfx_on_spawn_no_flash then self:hitfx_use('main', 0.5*self.hitfx_on_spawn_no_flash) end
  if self.from_merge then
    self.just_merged = true
    self:timer_after(0.5, function() self.just_merged = false end)
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
  if self.trigger_active[main.pointer] and main:input_is_pressed'action_1' then
    self:hitfx_use('main', 0.25)
    --[[
    for i = 1, main:random_int(2, 3) do 
      main.level.objects:container_add(emoji_particle('star', main.camera.mouse.x, main.camera.mouse.y, {hitfx_on_spawn_no_flash = 0.75, r = main:random_angle(), rotation_v = main:random_float(-2*math.pi, 2*math.pi)}))
    end
    ]]--
  end
  game2:push(self.drop_x, self.drop_y, 0, self.springs.drop.x, self.springs.drop.x)
    game2:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game2:pop()
end
--}}}
