-- Useful functions, objects and assorted constructs for all games in emoji style.
function emoji_utils_init()
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
end  

function draw_emoji_character(layer, character, x, y, r, sx, sy, ox, oy, color)
  layer:send(shaders.multiply_emoji, 'multiplier', color_to_emoji_multiplier[color])
  layer:draw_image(images[character], x, y, r, sx, sy, ox, oy, nil, shaders.multiply_emoji)
end

-- Layers are drawn such that specific layers have both screen-wide outlines as well as create drop shadows.
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
