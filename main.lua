require 'anchor'

function init()
  main:init{title = 'emoji merge', theme = 'twitter_emoji', web = false, w = 640, h = 360, sx = 2.5, sy = 2.5}

  bg, bg_fixed, game1, game2, effects, ui, shadow = layer(), layer({fixed = true}), layer(), layer(), layer(), layer({fixed = true}), layer({x = 4*main.sx, y = 4*main.sy, shadow = true})
  game1:layer_add_canvas('outline')
  game2:layer_add_canvas('outline')
  effects:layer_add_canvas('outline')
  ui:layer_add_canvas('outline')

  shaders = {}
  shaders.shadow = shader(nil, 'assets/shadow.frag')
  shaders.outline = shader(nil, 'assets/outline.frag')
  shaders.combine = shader(nil, 'assets/combine.frag')

  main:input_set_mouse_visible(false)
  main:input_set_mouse_locked(true)

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
  main:physics_world_set_collision_tags{'solid', 'ball', 'ball_ghost'}
  main:physics_world_disable_collision_between('ball', {'ball_ghost'})
  main:physics_world_disable_collision_between('ball_ghost', {'ball_ghost'})

  value_to_ball_data = {
    [1] = {image = images.slight_smile, rs = 9, stars = 2},
    [2] = {image = images.blush, rs = 11.5, stars = 2},
    [3] = {image = images.devil, rs = 16.5, stars = 3},
    [4] = {image = images.angry, rs = 18.5, stars = 3},
    [5] = {image = images.relieved, rs = 23, stars = 4},
    [6] = {image = images.yum, rs = 29.5, stars = 4},
    [7] = {image = images.joy, rs = 35, stars = 5},
    [8] = {image = images.sob, rs = 41.5, stars = 6},
    [9] = {image = images.skull, rs = 47.5, stars = 8},
    [10] = {image = images.thinking, rs = 59, stars = 12},
    [11] = {image = images.sunglasses, rs = 70, stars = 24},
  }

  objects = container()
  arena_bottom_spacing = 20
  arena_top_y = 40
  arena_w, arena_h = 240, 280
  arena_x1, arena_y1, arena_x2, arena_y2 = main.w/2 - arena_w/2, arena_top_y, main.w/2 + arena_w/2, main.h - arena_bottom_spacing
  objects:container_add(solid(main.w/2, main.h - arena_bottom_spacing, arena_w, 10))
  objects:container_add(solid(main.w/2 - arena_w/2, main.h - arena_bottom_spacing - arena_h/2, 10, arena_h))
  objects:container_add(solid(main.w/2 + arena_w/2, main.h - arena_bottom_spacing - arena_h/2, 10, arena_h))
  spawner = objects:container_add(cloud())

  ball_to_be_dropped = objects:container_add(ball(main.w/2, arena_top_y, {follow_spawner = true, value = 1}))
end

function update(dt)
  bg:rectangle(main.w/2, main.h/2, 3*main.w, 3*main.h, 0, 0, colors.fg[0])
  bg_gradient:gradient_image_draw(bg_fixed, main.w/2, main.h/2, main.w, main.h)
  if ball_to_be_dropped then bg:line(spawner.x - 24, spawner.y, spawner.x - 24, arena_y2, colors.yellow[0], 2) end

  if main:input_is_pressed('1') and ball_to_be_dropped then
    spawner:hitfx_use('main', 0.15)
    ball_to_be_dropped:hitfx_use('main', 0.25)

    ball_fall(ball_to_be_dropped)
    ball_to_be_dropped = nil
    local value = main:random_weighted_pick(30, 25, 20, 15, 10)
    main:timer_after(1, function() ball_to_be_dropped = objects:container_add(ball(spawner.x - 24, spawner.y + value_to_ball_data[value].rs, {follow_spawner = true, value = value})) end)
  end

  objects:container_update(dt)
  objects:container_remove_dead()
end


ball = function(x, y, args)
  local self = anchor('ball', args)
  self.value = self.value or 1
  self.rs = value_to_ball_data[self.value].rs
  self.emoji = value_to_ball_data[self.value].image
  self.stars = value_to_ball_data[self.value].stars
  self:prs_init(x, y, 0, 2*self.rs/self.emoji.w, 2*self.rs/self.emoji.h)
  self:collider_init('ball', 'dynamic', 'circle', self.rs)
  self:collider_set_restitution(0.1)
  self:collider_set_gravity_scale(0)
  self:hitfx_init()

  if self.hitfx_on_spawn then self:hitfx_use('main', 0.5, nil, nil, 0.15) end
  if self.from_merge then
    main:timer_after(0.01, function()
      local s = math.remap(self.rs, 9, 70, 1, 3)
      for i = 1, self.stars do 
        local r = main:random_angle()
        local d = main:random_float(0.8, 1)
        local x, y = self.x + d*self.rs*math.cos(r), self.y + d*self.rs*math.sin(r)
        objects:container_add(emoji_particle('star', x, y, {hitfx_on_spawn = 0.75, r = r, rotation_v = main:random_float(-2*math.pi, 2*math.pi), s = s, v = s*main:random_float(50, 100)}))
      end
    end)

    if self.vx and self.vy then
      self:collider_apply_impulse(self.vx/3, self.vy/3)
    end
  end

  self.update = function(self, dt)
    self:collider_update_position_and_angle()
    if self.follow_spawner then
      self:collider_set_position(spawner.x - 24, spawner.y + self.rs)
    end

    -- If it's the second ball's update and it has already been killed this frame by the collision, do nothing
    -- If this ball is attached to the cloud still, do nothing
    if not self.dead and not self.follow_spawner then 
      for other, contact in pairs(self.collision_enter['ball'] or {}) do
        if self.value == other.value and not other.follow_spawner then
          local x, y = contact:getPositions()
          self.dead = true
          other.dead = true
          objects:container_add(ball_merge_effect(self.x, self.y, {emoji = self.emoji, r = self.r, sx = self.sx, sy = self.sy, target_x = x, target_y = y}))
          objects:container_add(ball_merge_effect(other.x, other.y, {emoji = other.emoji, r = other.r, sx = other.sx, sy = other.sy, target_x = x, target_y = y}))
          local svx, svy = self:collider_get_velocity()
          local ovx, ovy = other:collider_get_velocity()
          main:timer_after(0.15, function()
            ball_fall(objects:container_add(ball(x, y, {from_merge = true, hitfx_on_spawn = true, value = self.value + 1, vx = (svx+ovx)/2, vy = (svy+ovy)/2})))
          end)
        end
      end
    end

    game2:draw_image(self.emoji, self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, nil, nil, colors.white[0], self.flashes.main.x and shaders.combine)
  end
  return self
end

ball_fall = function(self)
  self:collider_set_gravity_scale(1)
  self:collider_apply_impulse(0, 0.01)
  self.follow_spawner = false
end


cloud = function()
  local self = anchor('cloud')
  self.emoji = images.cloud
  self:prs_init(main.pointer.x, arena_top_y, 0, 42/self.emoji.w, 42/self.emoji.h)
  self:hitfx_init()
  
  self.update = function(self, dt)
    self.x, self.y = math.clamp(main.pointer.x, arena_x1 + 40, arena_x2 + 8), 20
    game1:draw_image(images.cloud, self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], self.flashes.main.x and shaders.combine)
  end
  return self
end


ball_merge_effect = function(x, y, args)
  local self = anchor('ball_merge_effect', args)
  self:prs_init(x, y)
  self:hitfx_init()
  self:hitfx_use('main', 0.5, nil, nil, 0.2)
  self:timer_init()
  self:timer_tween(0.15, self, {x = self.target_x, y = self.target_y, sx = 0, sy = 0}, math.cubic_in_out, function() self.dead = true end)
  
  self.update = function(self, dt)
    game2:draw_image(self.emoji, self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, nil, nil, colors.white[0], self.flashes.main.x and shaders.combine)
  end
  return self
end


emoji_particle = function(emoji, x, y, args)
  local self = anchor('emoji_particle', args)
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
  
  self.update = emoji_particle_update
  return self
end

emoji_particle_update = function(self, dt)
  if self.angular_v then self.r = self.r + self.angular_v*dt end
  self.x = self.x + self.v*math.cos(self.r)*dt
  self.y = self.y + self.v*math.sin(self.r)*dt
  self.visual_r = self.visual_r + self.rotation_v*dt
  effects:draw_image(self.emoji, self.x, self.y, self.r + self.visual_r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, nil, nil, colors.white[0], self.flashes.main.x and shaders.combine)
end


hit_effect = function(x, y, args)
  local self = anchor('hit_effect', args)
  self:prs_init(x, y, self.r or main:random_angle())
  self.animation = animation(0.04, frames.hit, 'once', {[0] = function() self.dead = true end})
  self.update = function(self, dt)
    self.animation:animation_update(dt, effects, self.x, self.y, self.r, self.sx, self.sy)
  end
  return self
end


solid = function(x, y, w, h)
  local self = anchor('solid')
  self:prs_init(x, y)
  self:collider_init('solid', 'static', 'rectangle', w, h)
  self:collider_set_friction(1)
  
  self.update = function(self, dt)
    game2:rectangle(self.x, self.y, self.w, self.h, 4, 4, colors.green[0])
  end
  return self
end


function main:draw_layers()
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
