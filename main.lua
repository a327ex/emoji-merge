require 'anchor'

function init()
  main:init{title = 'emoji merge', theme = 'twitter_emoji', w = 640, h = 360, sx = 2.5, sy = 2.5}

  bg, bg_fixed, game1, game2, effects, ui1, ui2, shadow = layer(), layer({fixed = true}), layer(), layer(), layer(), layer({fixed = true}), layer({fixed = true}), layer({x = 4*main.sx, y = 4*main.sy, shadow = true})
  game1:layer_add_canvas('outline')
  game2:layer_add_canvas('outline')
  effects:layer_add_canvas('outline')
  ui2:layer_add_canvas('outline')

  font_1 = font('assets/fusion-pixel-12px-monospaced-latin.ttf', 12, 'mono')
  font_2 = font('assets/volkswagen-serial-bold.ttf', 26, 'mono')
  font_3 = font('assets/volkswagen-serial-bold.ttf', 46, 'mono')
  font_4 = font('assets/volkswagen-serial-bold.ttf', 36, 'mono')

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
  images.calendar = image('assets/calendar.png')
  images.chain = image('assets/chain.png')
  bg_gradient = gradient_image('vertical', color(0.5, 0.5, 0.5, 0), color(0, 0, 0, 0.3))

  main:physics_world_set_gravity(0, 360)
  main:physics_world_set_collision_tags{'emoji', 'ghost', 'solid'}
  main:physics_world_disable_collision_between('emoji', {'ghost'})
  main:physics_world_disable_collision_between('ghost', {'emoji', 'ghost', 'solid'})

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
  require 'emoji_utils'
  emoji_utils_init()
  main:level_add('classic_arena', arena())
  main:level_add('main_menu', main_menu())
  main:level_goto('classic_arena')
end

function update(dt)

end
