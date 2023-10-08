mlib = require 'anchor.mlib'
utf8 = require 'anchor.utf8'
require 'anchor.sort'
require 'anchor.math'
require 'anchor.string'
require 'anchor.table'
require 'anchor.class'

-- Every object in the game is an anchor.
-- Except for a few modules (math, table, string, graphics...), every functionality is called through an anchor object.
-- This is achieved by adding every functionality as a mixin to the anchor class.
-- For instance, the "timer" mixin is added to the anchor class when "anchor:class_add(require('anchor/timer'))" is called.
-- This means that all anchor objects now can call any timer functions defined by that mixin.
-- When creating a new object, you must call the initialization function for each mixin that's going to be used, like "timer_init".
-- So, for instance, if we wanted to create a function that creates new timer objects, we'd do something like this:
--   function timer()
--     return anchor():timer_init()
--   end
-- And what this does is simply create a new anchor object, and then initialize it as a timer by calling the timer_init function. 
--
-- When creating your own mixins, all methods should be prefixed by the unique name of the mixin. So if you look at the timer mixin, everything is prefixed by "timer_".
-- This is due to the fact that all mixins are added by default to the anchor class, and so if their names collided then method definitions would overwrite each other, so unique names are necessary.
-- If method name collisions happen then an error will happen pointing out which names collided.
-- The same logic applies to attributes although less strictly (no error happens). If a mixin defines the .x attribute for the object in its init function, another mixin defining that same .x attribute will overwrite it.
-- This, however, does not throw an error. If you want to be safe you can prefix all your attributes by your mixin's name, but in general it's up to the user to not initialize mixins that are incompatible.
-- For instance, the color mixin defines .r, .g, .b and .a as attributes. The transform mixin also defines the .r attribute (rotation).
-- In this case, it's acceptable because in general color objects are never going to have transforms and thus the .r attribute confusion won't matter.
anchor = class:class_new()
function anchor:new(type, t) if t then for k, v in pairs(t) do self[k] = v end end; self.type = type end
function anchor:is(type) return self.type == type end
function anchor:has(mixin) end
-- TODO: Because mixins are loaded locally here the user has no access to them globally in a :has call.
-- Either create a global main.mixins table and have the user refer to them there, or add mixin strings to a self.mixins table on each mixin init function and then have :has check for that.
-- Haven't used :has yet in code so I don't know if I'll ever need it.

anchor:class_add(require('anchor.animation'))
function animation(delay, animation_frames, loop_mode, actions) return anchor():animation_init(delay, animation_frames, loop_mode, actions) end
anchor:class_add(require('anchor.animation_frames'))
function animation_frames(filename, frame_w, frame_h, frames_list) return anchor():animation_frames_init(filename, frame_w, frame_h, frames_list) end
anchor:class_add(require('anchor.animation_logic'))
function animation_logic(delay, size, loop_mode, actions) return anchor():animation_logic_init(delay, size, loop_mode, actions) end
anchor:class_add(require('anchor.area'))
anchor:class_add(require('anchor.camera'))
function camera(x, y, w, h) return anchor('camera'):shake_init():camera_init(x, y, w, h) end
anchor:class_add(require('anchor.collider'))
anchor:class_add(require('anchor.color'))
function color(r, g, b, a) return anchor('color'):color_init(r, g, b, a) end
anchor:class_add(require('anchor.color_ramp'))
function color_ramp(color, step) return anchor('color_ramp'):color_ramp_init(color, step) end
anchor:class_add(require('anchor.color_sequence'))
anchor:class_add(require('anchor.container'))
function container() return anchor('container'):container_init() end
anchor:class_add(require('anchor.duration'))
anchor:class_add(require('anchor.flash'))
function flash(duration) return anchor('flash'):flash_init(duration) end
anchor:class_add(require('anchor.font'))
function font(filename, font_size, hinting) return anchor('font'):font_init(filename, font_size, hinting) end
anchor:class_add(require('anchor.gradient_image'))
function gradient_image(direction, ...) return anchor('gradient_image'):gradient_image_init(direction, ...) end
anchor:class_add(require('anchor.graph'))
function graph() return anchor('graph'):graph_init() end
anchor:class_add(require('anchor.grid'))
function grid(w, h, v) return anchor('grid'):grid_init(w, h, v) end
anchor:class_add(require('anchor.hitfx'))
anchor:class_add(require('anchor.image'))
function image(filename) return anchor('image'):image_init(filename) end
anchor:class_add(require('anchor.input'))
anchor:class_add(require('anchor.layer'))
function layer(args) return anchor('layer', args):layer_init() end
anchor:class_add(require('anchor.level'))
anchor:class_add(require('anchor.music_player'))
anchor:class_add(require('anchor.observer'))
anchor:class_add(require('anchor.physics_world'))
anchor:class_add(require('anchor.prs'))
anchor:class_add(require('anchor.random'))
function random(seed) return anchor('random'):random_init(seed) end
anchor:class_add(require('anchor.shader'))
function shader(vs, fs) return anchor('shader'):shader_init(vs, fs) end
anchor:class_add(require('anchor.shake'))
anchor:class_add(require('anchor.slow'))
anchor:class_add(require('anchor.sound'))
function sound(filename, args) return anchor('sound', args):sound_init(filename) end
anchor:class_add(require('anchor.sound_tag'))
function sound_tag(args) return anchor('sound_tag'):sound_tag_init(args) end
anchor:class_add(require('anchor.spring'))
function spring(x, k, d) return anchor('spring'):spring_init(x, k, d) end
anchor:class_add(require('anchor.stats'))
anchor:class_add(require('anchor.system'))
anchor:class_add(require('anchor.text'))
function text(text, args) return anchor('text'):text_init(text, args) end
anchor:class_add(require('anchor.timer'))
function timer() return anchor('timer'):timer_init() end
anchor:class_add(require('anchor.vec2'))
function vec2(x, y) return anchor('vec2'):vec2_init(x, y) end

main = anchor()
main.area_objects = {}
main.collider_objects = {}
main.hitfx_objects = {}
main.input_objects = {}
main.layer_objects = {}
main.music_player_objects = {}
main.observer_objects = {}
main.shake_objects = {}
main.sound_objects = {}
main.stats_objects = {}
main.timer_objects = {}

main.time = 0
main.step = 1
main.frame = 1
main.timescale = 1
main.framerate = 60
main.sleep = .001
main.accumulator = 0
main.rate = 1/60

main:container_init():input_init():input_bind_all():level_init():music_player_init():observer_init():physics_world_init():random_init():shake_init():slow_init():system_init()
main.pointer = anchor('pointer', {pointer = true, x = 0, y = 0}):area_init('point')

function main:init(args)
  args = args or {}
  main.title = args.title or 'No title'
  love.filesystem.setIdentity(main.title)
  main.web = args.web

  if main.web then
    love.graphics.setLineStyle('rough')
    love.graphics.setDefaultFilter('nearest', 'nearest', 0)
    main.w, main.h = args.w or 480, args.h or 270
    main.sx, main.sy = args.sx or 1, args.sy or 1
    main.rx, main.ry = 0, 0
    main.framerate = 60
    main.display = 1
    main.borderless = false
    main.resizable = false
    love.window.setMode(main.w*main.sx, main.h*main.sy, {borderless = false, minwidth = main.w, minheight = main.h, resizable = false})
    love.window.setTitle(main.title)
    main.canvas = love.graphics.newCanvas(main.w, main.h)
    main.camera = camera(main.w/2, main.h/2)

  else
    main:load_state()
    if main.device_state.first_run then
      love.graphics.setLineStyle('rough')
      love.graphics.setDefaultFilter('nearest', 'nearest', 0)
      main.w, main.h = args.w or 480, args.h or 270
      main.sx, main.sy = 1, 1
      main.rx, main.ry = 0, 0
      local _, _, flags = love.window.getMode()
      local desktop_w, desktop_h = love.window.getDesktopDimensions(flags.displayindex)
      main.framerate = (flags.refreshrate == 0 and 60 or flags.refreshrate)
      main.display = flags.displayindex
      main.borderless = true
      main.resizable = false
      main:calculate_main_scale(desktop_w, desktop_h)
      love.window.setMode(main.w*main.sx, main.h*main.sy, {borderless = true, minwidth = main.w, minheight = main.h, resizable = false})
      love.window.setTitle(main.title)
      main:layer_init()
      main.camera = camera(main.w/2, main.h/2)
    else
      love.graphics.setLineStyle('rough')
      love.graphics.setDefaultFilter('nearest', 'nearest', 0)
      main.w, main.h = args.w or 480, args.h or 270
      main.sx, main.sy = main.device_state.sx, main.device_state.sy
      main.rx, main.ry = main.device_state.rx, main.device_state.ry
      local _, _, flags = love.window.getMode()
      main.framerate = main.device_state.framerate
      main.display = main.device_state.display
      main.borderless = main.device_state.borderless
      main.resizable = main.device_state.resizable
      love.window.setMode(main.w*main.sx, main.h*main.sy, {borderless = main.device_state.borderless, displayindex = main.device_state.display, minwidth = main.w, minheight = main.h, resizable = main.device_state.resizable})
      love.window.setTitle(main.title)
      main:layer_init()
      main.camera = camera(main.w/2, main.h/2)
    end
    self:set_graphics_state()
  end

  self:set_theme(args.theme)
end

function main:calculate_main_scale(w, h)
  if w/main.w == h/main.h then -- can multiply on x and y by the same value
    main.rx, main.ry = 0, 0
    main.sx, main.sy = w/main.w, h/main.h
  else
    local scale = math.min(w/main.w, h/main.h)
    main.rx, main.ry = w-scale*main.w, h-scale*main.h -- remainder on both x and y to be used later for letterboxing
    main.sx, main.sy = scale, scale
  end
  self:set_graphics_state()
end

-- Redefine this function from game's side if needed for more complex layer drawing with shader effects and so on.
function main:draw_all_layers_to_main_layer()
  for _, layer in ipairs(main.layer_objects) do 
    main:layer_draw_to_canvas('main', function() 
      layer:layer_draw_commands()
      layer:layer_draw()
    end)
  end
end

function main:load_state()
  if main.web then return end
  main.device_state = main:load_table('device_state.txt')
  main.game_state = main:load_table('game_state.txt')
  if not main.device_state then main.device_state = {first_run = true} end
  if not main.game_state then main.game_state = {first_run = true} end
end

function main:save_state()
  if main.web then return end
  if main.device_state.first_run then main.device_state.first_run = false end
  if main.game_state.first_run then main.game_state.first_run = false end
  main:save_table('device_state.txt', main.device_state)
  main:save_table('game_state.txt', main.game_state)
end

function main:set_graphics_state()
  main.device_state.sx, main.device_state.sy = main.sx, main.sy
  main.device_state.rx, main.device_state.ry = main.rx, main.ry
  main.device_state.display = main.display
  main.device_state.framerate = main.framerate
  main.device_state.borderless = main.borderless
  main.device_state.resizable = main.resizable
end

function main:set_theme(theme)
  main.theme = theme or 'default'
  if main.theme == 'default' then
    colors = {
      white = color_ramp(color(1, 1, 1, 1), 0.025),
      black = color_ramp(color(0, 0, 0, 1), 0.025),
      fg = color_ramp(color(1, 1, 1, 1), 0.025),
      bg = color_ramp(color(0, 0, 0, 1), 0.025),
      gray1 = color_ramp(color(20, 20, 20), 0.025),
      gray2 = color_ramp(color(60, 50, 50), 0.025),
      gray3 = color_ramp(color(70, 70, 70), 0.025),
      gray4 = color_ramp(color(162, 162, 162), 0.025),
      gray5 = color_ramp(color(224, 224, 224), 0.025),
      red1 = color_ramp(color(140, 50, 50), 0.025),
      red2 = color_ramp(color(192, 63, 46), 0.025),
      red3 = color_ramp(color(223, 173, 163), 0.025),
    }
  elseif main.theme == 'snkrx' then
    colors = {
      white = color_ramp(color(1, 1, 1, 1), 0.025),
      black = color_ramp(color(0, 0, 0, 1), 0.025),
      gray = color_ramp(color(0.5, 0.5, 0.5, 1), 0.025),
      bg = color_ramp(color(48, 48, 48), 0.025),
      fg = color_ramp(color(218, 218, 218), 0.025),
      yellow = color_ramp(color(250, 207, 0), 0.025),
      orange = color_ramp(color(240, 112, 33), 0.025),
      blue = color_ramp(color(1, 155, 214), 0.025),
      green = color_ramp(color(139, 191, 64), 0.025),
      red = color_ramp(color(233, 29, 57), 0.025),
      purple = color_ramp(color(142, 85, 158), 0.025),
    }
  elseif main.theme == 'bytepath' then -- https://coolors.co/191516-f5efed-52b3cb-b26ca1-79b159-ffb833-f4903e-d84654
    colors = {
      white = color_ramp(color(1, 1, 1, 1), 0.025),
      black = color_ramp(color(0, 0, 0, 1), 0.025),
      gray = color_ramp(color(0.5, 0.5, 0.5, 1), 0.025),
      bg = color_ramp(color('#111111'), 0.025),
      fg = color_ramp(color('#dedede'), 0.025),
      yellow = color_ramp(color('#ffb833'), 0.025),
      orange = color_ramp(color('#f4903e'), 0.025),
      blue = color_ramp(color('#52b3cb'), 0.025),
      green = color_ramp(color('#79b159'), 0.025),
      red = color_ramp(color('#d84654'), 0.025),
      purple = color_ramp(color('#b26ca1'), 0.025),
    }
  elseif main.theme == 'twitter_emoji' then -- colors taken from twitter emoji set
    colors = {
      white = color_ramp(color(1, 1, 1, 1), 0.025),
      black = color_ramp(color(0, 0, 0, 1), 0.025),
      gray = color_ramp(color(0.5, 0.5, 0.5, 1), 0.025),
      bg = color_ramp(color(48, 49, 50), 0.025),
      fg = color_ramp(color(231, 232, 233), 0.025),
      yellow = color_ramp(color(253, 205, 86), 0.025),
      orange = color_ramp(color(244, 146, 0), 0.025),
      blue = color_ramp(color(83, 175, 239), 0.025),
      green = color_ramp(color(122, 179, 87), 0.025),
      red = color_ramp(color(223, 37, 64), 0.025),
      purple = color_ramp(color(172, 144, 216), 0.025),
      brown = color_ramp(color(195, 105, 77), 0.025),
    }
  elseif main.theme == 'google_noto' then -- colors taken from google noto emoji set
    colors = {
      white = color_ramp(color(1, 1, 1, 1), 0.025),
      black = color_ramp(color(0, 0, 0, 1), 0.025),
      gray = color_ramp(color(0.5, 0.5, 0.5, 1), 0.025),
      bg = color_ramp(color(66, 66, 66), 0.025),
      fg = color_ramp(color(224, 224, 224), 0.025),
      yellow = color_ramp(color(255, 205, 46), 0.025),
      orange = color_ramp(color(255, 133, 0), 0.025),
      blue = color_ramp(color(18, 119, 211), 0.025),
      green = color_ramp(color(125, 180, 64), 0.025),
      red = color_ramp(color(244, 65, 51), 0.025),
      purple = color_ramp(color(172, 69, 189), 0.025),
      brown = color_ramp(color(184, 109, 83), 0.025),
    }
  else
    error('theme name "' .. an.theme .. '" does not exist')
  end
  love.graphics.setBackgroundColor(unpack(colors.bg[0]:color_to_table()))
  love.graphics.setColor(unpack(colors.fg[0]:color_to_table()))
end


function love.run()
  love.timer.step()
  local last_frame = 0
  if init then init() end

  return function()
    main.dt = love.timer.step()*main.timescale
    main.accumulator = main.accumulator + main.dt

    while main.accumulator >= main.rate do
      main.accumulator = main.accumulator - main.rate

      if love.event then
        love.event.pump()
        for name, a, b, c, d, e, f in love.event.poll() do
          if name == 'quit' then
            if main.steam then steam.shutdown() end
            main:save_state()
            return a or 0
          elseif name == 'resize' then
            main:calculate_main_scale(a, b)
          elseif name == 'keypressed' then
            main.input_keyboard_state[a] = true
            main.input_latest_type = 'keyboard'
          elseif name == 'keyreleased' then
            main.input_keyboard_state[a] = false
          elseif name == 'mousepressed' then
            main.input_mouse_state[c] = true
            main.input_latest_type = 'mouse'
          elseif name == 'mousereleased' then
            main.input_mouse_state[c] = false
          elseif name == 'wheelmoved' then
            if b == 1 then main.input_mouse_state.wheel_up = true end
            if b == -1 then main.input_mouse_state.wheel_down = true end
          elseif name == 'gamepadpressed' then
            main.input_gamepad_state[b] = true
            main.input_latest_type = 'gamepad'
          elseif name == 'gamepadreleased' then
            main.input_gamepad_state[b] = false
          elseif name == 'gamepadaxis' then
            main.input_gamepad_state[b] = c
          elseif name == 'joystickadded' then
            main.input_gamepad = a
          elseif name == 'joystickremoved' then
            main.input_gamepad = nil
          end
        end
      end

      main.step = main.step + 1
      main.time = main.time + main.rate*main.slow_amount
      if main.steam then main.steam.runCallbacks() end
      for _, layer in ipairs(main.layer_objects) do layer.draw_commands = {} end
      for _, x in ipairs(main.sound_objects) do x:sound_update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.music_player_objects) do x:music_player_update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.input_objects) do x:input_update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.area_objects) do x:area_update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.observer_objects) do x:observer_update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.timer_objects) do x:timer_update(main.rate*main.slow_amount) end
      main:physics_world_update(main.rate*main.slow_amount)
      for _, x in ipairs(main.hitfx_objects) do x:hitfx_update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.shake_objects) do x:shake_update(main.rate*main.slow_amount) end
      main.camera:camera_update(main.rate*main.slow_amount)
      main:level_update(main.rate*main.slow_amount)
      if update then update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.area_objects) do x:area_update_vertices(main.rate*main.slow_amount) end
      for _, x in ipairs(main.collider_objects) do x:collider_post_update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.stats_objects) do x:stats_post_update(main.rate*main.slow_amount) end
      for _, x in ipairs(main.input_objects) do x:input_post_update(main.rate*main.slow_amount) end
      for i = #main.area_objects, 1, -1 do if main.area_objects[i].dead then table.remove(main.area_objects, i) end end
      for i = #main.collider_objects, 1, -1 do if main.collider_objects[i].dead then table.remove(main.collider_objects, i) end end
      for i = #main.input_objects, 1, -1 do if main.input_objects[i].dead then table.remove(main.input_objects, i) end end
      for i = #main.hitfx_objects, 1, -1 do if main.hitfx_objects[i].dead then table.remove(main.hitfx_objects, i) end end
      for i = #main.shake_objects, 1, -1 do if main.shake_objects[i].dead then table.remove(main.shake_objects, i) end end
      for i = #main.timer_objects, 1, -1 do if main.timer_objects[i].dead then table.remove(main.timer_objects, i) end end
      for i = #main.stats_objects, 1, -1 do if main.stats_objects[i].dead then table.remove(main.stats_objects, i) end end
      for i = #main.observer_objects, 1, -1 do if main.observer_objects[i].dead then table.remove(main.observer_objects, i) end end
      main:container_remove_dead_without_destroying()
    end

    while main.framerate and love.timer.getTime() - last_frame < 1/main.framerate do
      love.timer.sleep(.0005)
    end

    last_frame = love.timer.getTime()
    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear()
      main:draw_all_layers_to_main_layer()
      main:layer_draw('main', main.rx*0.5, main.ry*0.5, 0, main.sx, main.sy)
      love.graphics.present()
      main.frame = main.frame + 1
    end

    love.timer.sleep(main.sleep)
  end
end
