require 'anchor'

function init()
  main:init{title = 'emoji merge', theme = 'twitter_emoji', web = false, w = 640, h = 360, sx = 2.5, sy = 2.5}

  bg, bg_fixed, game, effects, ui, shadow = layer(), layer({fixed = true}), layer(), layer(), layer({fixed = true}), layer({x = 4*main.sx, y = 4*main.sy, shadow = true})
  game:layer_add_canvas('outline')
  effects:layer_add_canvas('outline')
  ui:layer_add_canvas('outline')
  shadow_shader = shader(nil, 'assets/shadow.frag')
  outline_shader = shader(nil, 'assets/outline.frag')

  main:input_set_mouse_visible(false)
  main:input_set_mouse_locked(true)

  frames = {}
  frames.hit = animation_frames('assets/hit.png', 96, 48)
  frames.disappear = animation_frames('assets/disappear.png', 40, 40)

  images = {}
  images.cloud = image('assets/cloud.png')
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

  main:physics_world_set_gravity(0, 320)
  main:physics_world_set_collision_tags{'solid', 'ball', 'ball_ghost'}
  main:physics_world_disable_collision_between('ball', {'ball_ghost'})
  main:physics_world_disable_collision_between('ball_ghost', {'ball_ghost'})

  value_to_ball_data = {
    [1] = {image = images.slight_smile, rs = 9},
    [2] = {image = images.blush, rs = 11.5},
    [3] = {image = images.devil, rs = 16.5},
    [4] = {image = images.angry, rs = 18.5},
    [5] = {image = images.relieved, rs = 23},
    [6] = {image = images.yum, rs = 29.5},
    [7] = {image = images.joy, rs = 35},
    [8] = {image = images.sob, rs = 41.5},
    [9] = {image = images.skull, rs = 47.5},
    [10] = {image = images.thinking, rs = 59},
    [11] = {image = images.sunglasses, rs = 70},
  }

  objects = container()
  arena_bottom_spacing = 40
  arena_w, arena_h = 240, 280
  objects:container_add(solid(main.w/2, main.h - arena_bottom_spacing, arena_w, 10))
  objects:container_add(solid(main.w/2 - arena_w/2, main.h - arena_bottom_spacing - arena_h/2, 10, arena_h))
  objects:container_add(solid(main.w/2 + arena_w/2, main.h - arena_bottom_spacing - arena_h/2, 10, arena_h))
  objects:container_add(cloud())

  ball_to_be_dropped = objects:container_add(ball(main.w/2, 40, {follow_pointer = true, value = 1}))
end

function update(dt)
  bg:rectangle(main.w/2, main.h/2, 3*main.w, 3*main.h, 0, 0, colors.fg[0])
  bg_gradient:gradient_image_draw(bg_fixed, main.w/2, main.h/2, main.w, main.h)
  bg:line(main.pointer.x, 20, main.pointer.x, main.h - arena_bottom_spacing, colors.yellow[0], 2)

  if main:input_is_pressed('1') and ball_to_be_dropped then
    ball_fall(ball_to_be_dropped)
    ball_to_be_dropped = nil
    main:timer_after(1, function() ball_to_be_dropped = objects:container_add(ball(main.pointer.x, 40, {follow_pointer = true, value = main:random_weighted_pick(30, 25, 20, 15, 10)})) end)
  end

  objects:container_update(dt)
  objects:container_remove_dead()
end


ball = function(x, y, args)
  self = anchor('ball', args)
  self.value = self.value or 1
  self.rs = value_to_ball_data[self.value].rs
  self.emoji = value_to_ball_data[self.value].image
  self:prs_init(x, y, 0, 2*self.rs/self.emoji.w, 2*self.rs/self.emoji.h)
  self:collider_init('ball', 'dynamic', 'circle', self.rs)
  self:collider_set_restitution(0.1)
  self:collider_set_gravity_scale(0)

  self.update = function(self, dt)
    self:collider_update_position_and_angle()
    if self.follow_pointer then self:collider_move_towards_mouse_horizontally(nil, 0.1) end

    -- If it's the second ball's update and it has already been killed this frame by the collision, do nothing
    -- If this ball is attached to the cloud still, do nothing
    if not self.dead and not self.follow_pointer then 
      for other, contact in pairs(self.collision_enter['ball'] or {}) do
        if self.value == other.value then
          local x, y = contact:getPositions()
          self.dead = true
          other.dead = true
          ball_fall(objects:container_add(ball(x, y, {value = self.value + 1, rs = self.rs*1.2})))
        end
      end
    end

    game:draw_image(self.emoji, self.x, self.y, self.r, self.sx, self.sy)
  end
  return self
end

ball_fall = function(self)
  self:collider_set_gravity_scale(1)
  self.follow_pointer = false
end


cloud = function()
  self = anchor('cloud')
  self.emoji = images.cloud
  self:prs_init(main.pointer.x, 40, 0, 24/self.emoji.w, 24/self.emoji.h)
  
  self.update = function(self, dt)
    self.x, self.y = main.pointer.x, 20
    game:draw_image(images.cloud, self.x, self.y, self.r, self.sx, self.sy)
  end
  return self
end


solid = function(x, y, w, h)
  self = anchor('solid')
  self:prs_init(x, y)
  self:collider_init('solid', 'static', 'rectangle', w, h)
  self:collider_set_friction(1)
  
  self.update = function(self, dt)
    game:rectangle(self.x, self.y, self.w, self.h, 4, 4, colors.green[0])
  end
  return self
end


function main:draw_layers()
  bg:layer_draw_commands()
  bg_fixed:layer_draw_commands()
  game:layer_draw_commands()
  effects:layer_draw_commands()
  ui:layer_draw_commands()

  shadow:layer_draw_to_canvas('main', function()
    game:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shadow_shader, true)
    effects:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], shadow_shader, true)
  end)
  game:layer_draw_to_canvas('outline', function() game:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], outline_shader) end)
  effects:layer_draw_to_canvas('outline', function() effects:layer_draw('main', 0, 0, 0, 1, 1, colors.white[0], outline_shader) end)

  main:layer_draw_to_canvas(main.canvas, function() 
    bg:layer_draw()
    bg_fixed:layer_draw()
    shadow:layer_draw()
    game:layer_draw('outline')
    game:layer_draw()
    effects:layer_draw('outline')
    effects:layer_draw()
    ui:layer_draw()
  end)
end
