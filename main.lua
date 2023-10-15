require 'anchor'

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

  main:input_set_mouse_visible(false)
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
  
  bg_gradient = gradient_image('vertical', color(0.5, 0.5, 0.5, 0), color(0, 0, 0, 0.3))

  main:physics_world_set_gravity(0, 360)
  main:physics_world_set_callbacks_as_global_functions()
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

  emoji_type_to_base = {
    character = 161/255,
    board = 101/255,
  }

  value_to_emoji_data = {
    [1] = {emoji = images.slight_smile, rs = 9, score = 1, mass_multiplier = 1, stars = 2},
    [2] = {emoji = images.blush, rs = 11.5, score = 3, mass_multiplier = 1, stars = 2},
    [3] = {emoji = images.devil, rs = 16.5, score = 6, mass_multiplier = 1, stars = 3},
    [4] = {emoji = images.angry, rs = 18.5, score = 10, mass_multiplier = 1, stars = 3},
    [5] = {emoji = images.relieved, rs = 23, score = 15, mass_multiplier = 1, stars = 4},
    [6] = {emoji = images.yum, rs = 29.5, score = 21, mass_multiplier = 1, stars = 4},
    [7] = {emoji = images.joy, rs = 35, score = 28, mass_multiplier = 1, stars = 5},
    [8] = {emoji = images.sob, rs = 41.5, score = 36, mass_multiplier = 1, stars = 6},
    [9] = {emoji = images.skull, rs = 47.5, score = 45, mass_multiplier = 1, stars = 8},
    [10] = {emoji = images.thinking, rs = 59, score = 56, mass_multiplier = 1, stars = 12},
    [11] = {emoji = images.sunglasses, rs = 70, score = 66, mass_multiplier = 1, stars = 24},
  }

  require 'arena'
  require 'effects'
  require 'emoji'
  require 'main_menu'
  main:level_add('classic_arena', arena())
  main:level_add('main_menu', main_menu())
  main:level_goto('classic_arena')
end

function update(dt)

end

function draw_emoji_character(layer, character, x, y, r, sx, sy, ox, oy, color)
  layer:send(shaders.multiply_emoji, 'base', emoji_type_to_base.character)
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
