require 'anchor'

function init()
  main:init{title = 'emoji merge', theme = 'twitter_emoji', w = 640, h = 360, sx = 2.5, sy = 2.5}

  bg, bg_fixed, game1, game2, effects, ui, shadow = layer(), layer({fixed = true}), layer(), layer(), layer(), layer({fixed = true}), layer({x = 4*main.sx, y = 4*main.sy, shadow = true})
  game1:layer_add_canvas('outline')
  game2:layer_add_canvas('outline')
  effects:layer_add_canvas('outline')
  ui:layer_add_canvas('outline')

  shaders = {}
  shaders.shadow = shader(nil, 'assets/shadow.frag')
  shaders.outline = shader(nil, 'assets/outline.frag')
  shaders.combine = shader(nil, 'assets/combine.frag')
  shaders.grayscale = shader(nil, 'assets/grayscale.frag')

  main:input_set_mouse_visible(false)
  -- main:input_set_mouse_locked(true)

  frames = {}
  frames.hit = animation_frames('assets/hit.png', 96, 48)
  frames.disappear = animation_frames('assets/disappear.png', 40, 40)

  images = {}
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
  bg_gradient = gradient_image('vertical', color(0.5, 0.5, 0.5, 0), color(0, 0, 0, 0.3))

  main:physics_world_set_gravity(0, 360)
  main:physics_world_set_collision_tags{'emoji', 'ghost', 'solid'}
  main:physics_world_disable_collision_between('emoji', {'ghost'})
  main:physics_world_disable_collision_between('ghost', {'ghost'})

  value_to_emoji_data = {
    [1] = {emoji = images.slight_smile, rs = 9, mass_multiplier = 1, stars = 2},
    [2] = {emoji = images.blush, rs = 11.5, mass_multiplier = 1, stars = 2},
    [3] = {emoji = images.devil, rs = 16.5, mass_multiplier = 1, stars = 3},
    [4] = {emoji = images.angry, rs = 18.5, mass_multiplier = 1, stars = 3},
    [5] = {emoji = images.relieved, rs = 23, mass_multiplier = 1, stars = 4},
    [6] = {emoji = images.yum, rs = 29.5, mass_multiplier = 1, stars = 4},
    [7] = {emoji = images.joy, rs = 35, mass_multiplier = 1, stars = 5},
    [8] = {emoji = images.sob, rs = 41.5, mass_multiplier = 1, stars = 6},
    [9] = {emoji = images.skull, rs = 47.5, mass_multiplier = 1, stars = 8},
    [10] = {emoji = images.thinking, rs = 59, mass_multiplier = 1, stars = 12},
    [11] = {emoji = images.sunglasses, rs = 70, mass_multiplier = 1, stars = 24},
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

function main:draw_all_layers_to_main_layer()
  bg:layer_draw_commands()
  bg_fixed:layer_draw_commands()
  game1:layer_draw_commands()
  game2:layer_draw_commands()
  effects:layer_draw_commands()
  ui:layer_draw_commands()

  shadow:layer_draw_to_canvas('main', function()
    game1:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.shadow, true)
    game2:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.shadow, true)
    effects:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.shadow, true)
  end)
  game1:layer_draw_to_canvas('outline', function() game1:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.outline) end)
  game2:layer_draw_to_canvas('outline', function() game2:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.outline) end)
  effects:layer_draw_to_canvas('outline', function() effects:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shaders.outline) end)

  main:layer_draw_to_canvas(main.canvas, function() 
    bg:layer_draw()
    bg_fixed:layer_draw()
    shadow:layer_draw()
    game1:layer_draw('outline')
    game1:layer_draw()
    game2:layer_draw('outline')
    game2:layer_draw()
    effects:layer_draw('outline')
    effects:layer_draw()
    ui:layer_draw()
  end)
end
