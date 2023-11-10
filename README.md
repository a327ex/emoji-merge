# emoji-merge

emoji merge is a Suika Game clone about merging emojis, play it here: https://a327ex.itch.io/emoji-merge

https://github.com/a327ex/emoji-merge/assets/409773/372693e2-c648-447b-b947-4d6a63e28787

## Table of Contents
- [Engine overview](#engine-overview)
  - [Anchor](#anchor)
    - [Requires](#requires)
    - [Anchor class](#anchor-class)
    - [Mixins](#mixins)
    - [Main object](#main-object)
    - [Main init](#main-init)
    - [Main loop](#main-loop)
  - [Timers and observers](#timers-and-observers)
  - [Input](#input)
  - [Layer](#layer)
  - [Container](#container)
  - [Colliders and physics world](#colliders-and-physics-world)
  - [Text](#text)
  - [hitfx, flashes and springs](#hitfx-flashes-and-springs)
  - [Animation](#animation)
  - [Camera](#camera)
  - [Shake](#shake)
  - [Color](#color)
  - [Sounds and music player](#sounds-and-music-player)
  - [Random](#random)
  - [Slow](#slow)
  - [Stats](#stats)
  - [Grid and graph](#grid-and-graph)
  - [Thin wrappers and miscellaneous](#thin-wrappers-and-miscellaneous)

# Engine overview 

> 10/11/23 12:37

A few months ago someone asked me to explain how some of my code worked. I said I was going to do so after I released a new game, and while [emoji merge](https://a327ex.itch.io/emoji-merge) isn't a full release, it's a perfectly sized project to use for giving a fairly in-depth explanation of how my code currently works. I'm fairly happy with my codebase, and it's likely I won't change it significantly for the next 2-3 Steam games I release, so there's no better time than now, while everything's fresh in my mind, to explain it all completely.

This is also an opportune moment to do so given the collective realization by indie developers that they were, all of them, deceived. For their executables were controlled by someone... or something else. In the land of California, in the fires of San Francisco, the Dark Lords of Big ECS, aided by the Fallen Angels of Capital, forged their Master Engine - an engine to control all indiedevs. And into this engine they poured their cruelty, their malice, and their will to dominate all games. One engine to rule them all, one engine to bind them, one engine to unite them all, and in the darkness RUNTIME FEE BACKSTAB THEM!!!

Very, very sad situation all around. But, you know, as time passes and the future becomes the present becomes the past, when we look back on life with the benefit of hindsight, there's always a positive framing to negative past events. We, in fact, often look at these negative past events as pivotal moments in our development, and we even come to deeply believe that we wouldn't be who we are without those events having happened to make us stronger and more resilient.

And so these events - Unity's Runtime Backstabbing of 23' and Godot's Great Fork of 27' - have reminded many of one ever-present truth: gamedevs should aim to own as high a percentage of their codebases as they reasonably can in order to decrease the amount of technological risk they're exposing themselves to. A simple truth, yet one that is hard to live up to.

Which brings us back to this post. For clarity's sake, from now on I'm going to refer to code that is common across my games as "engine code", and to code that is specific to a single game as "gameplay code". My engine code is written in Lua on top of [LÖVE](https://love2d-community.github.io/love-api/), which I'll also refer to generally as "the framework".

One of the important things I do with this engine code is structure it such that gameplay code *never* has to call any functions exposed by the framework directly. This means I should be able to CTRL+F all my gameplay code for a game and find no instances of any `love.*` calls happening anywhere. I do this for two reasons.

The first is that this decreases the amount of technological risk I'm exposing myself to by using the framework. If my gameplay code doesn't directly call any framework functions, if for any reason whatsoever I have to swap one framework for another, none of my gameplay code has to be changed, since a layer exists between it and the underlying framework. Ultimately this means that this engine code will, in some cases, have a bunch of extremely thin wrappers that do nothing but call some of the framework's functions, which looks and seems kind of dumb, but it's done that way for a reason.

Open-source frameworks such as LÖVE, Monogame, libGDX, Phaser, etc already have a low amount of risk, so one could argue that doing this is unnecessary. In some sense this is true. By their nature as frameworks, they inherently have lower risk than full-fledged engines like Unity or Godot because they do less, and thus are less entangled with your own code. By their nature as open-source frameworks, some would argue that this also decreases their risk, because if anything goes wrong you can just fork it, right? Just fork it! It's simple! Well, I don't think that argument is solid at all, so in my view some code being open-source is at best a neutral proposition, because open-source software has several downsides that people often don't consider, but perhaps it's best to leave that discussion for another post (maybe the Godot bashing one in 2027).

In any case, even if open-source frameworks have decreased risk, they still have risk regardless. You can never truly know what's going to happen. Maybe one day it turns out that aliens are real, one of LÖVE's early developers is identified as an alien, and the Global American Empire (GAE) decides that any code written by him cannot, by law, be distributed anymore. Valve would have to comply and remove all LÖVE games from their store as well as reject any further LÖVE games with maximum prejudice. Sad, but true. Is this likely to happen? No. But is it impossible? Well, given the way reality is going, I would also say no. The point is that there are any number of odd events that could happen to either prevent you or heavily disincentivize you from using your technology of choice, and if you have to do a very small amount of extra work to defend yourself against those unlikely events then it makes no sense to not do it.

So this is my first reason for structuring my code this way. By the way, for those not familiar with my posts from before SNKRX, I already did the work of swapping my framework for my own code 5 years ago once. You can read about it [here](https://github.com/a327ex/blog/issues/39). And you can read my reasonings for doing it in [this post](https://github.com/a327ex/blog/issues/31), in the engine section. Back then, in the process of swapping LÖVE, I also realized how to fix most issues I initially had with it (they were a literal skill issue on my part and *mostly* not to do with the framework itself), which is why I'm still using it today, 5 years later.

But, knowing what I know now and due to how I structured things, if I had to I could swap it in like a week, as it's really not a lot of work. And the environment for C/C++ libraries now is much better than it was 5 years ago too, there are many frameworks that pretty much do everything you'd need while allowing for a high amount of flexibility if you need it.

One good example is [Randy Gaul's](https://twitter.com/RandyPGaul) [Cute Framework](https://github.com/RandyGaul/cute_framework), which has about 90% of what I need. Randy also seems to both have good taste/aesthetic sense for making his APIs clean, and also just seems to have built his framework for solving actual real problems that people making 2D games have specifically, which is a great fit for me.

All of this to say, this defense against unlikely events by making it easy for the framework to be swapped is not some fantasy in my head, right? It's very feasible, I've done it before, I know roughly how much work it takes, and so if I ever find myself in the spot that Unity devs found themselves in a few months ago, I know exactly what I need to do. In my opinion, everyone should have a realistic plan like this for when some technology they depend on disappears, because if you don't then you're just not being responsible about your art, your craft, your livelihood.

Which is why I find it so distasteful to see so many devs seeing what happened with Unity and jumping straight into Godot. It's like, that's still millions of lines of code you don't own... why would you do that? At least take the opportunity to switch to something significantly simpler! But no, people just want the same thing again... I understand why people want comfort and why they need the editor and all that, and in some sense I empathize. But I'm a 0 or 1 guy. If I really found myself unprepared, and had I been using Unity for the last 10 years and gotten used it, I know myself well enough to know that I would simply go down with the ship and only stop using it when my (now cloud) editor stopped working.

I am very autistic about the way my tools work and I simply would not allow myself to take the mental damage of changing to something else just because there's now a small runtime fee, I'd very likely just eat the bullet and keep making my games the same as before. At the point where the editor stops working because the engine has literally disappeared, the rent has not been paid, the offices are closed, then I would have enough motivation to look for alternatives, and the alternatives would also be in a better place, since it would be at least like 5 years from now.

So personally, I find the collective move to Godot distasteful both because it's a repeat of the same mistake as the one made with Unity 5+ years ago, but also because, logically speaking, it's better to make such a move in the future rather than now. I made this point in [one of my blog posts](https://a327ex.com/posts/marketing_skills) before but it bears repeating:

>Often times in life you have situations where the correct decision is either 0 or 1. You either do something in a very limited fashion or don’t do it at all, or you do something in a very maximalist and expanded fashion. In these situations the middleground is always going to be the worse option because the math of effort spent for results gained just doesn’t make sense. [...] This series of tweets explains this idea perfectly:

>![](https://cdn.blot.im/blog_13d6ee76e82c4da8b3e12f8748579ad0/_image_cache/c57ee6e6-0c4f-4b14-aef8-e0591b8ce8cf.png)

And so, to me, the extremes here are better bets. If I was unprepared and had gotten used to Unity, the right move is to either keep using it, or to make your own engine. Moving to Godot is the middleground of toxic slow-burning disillusionment that mathematically doesn't make sense.

In any case... The second (and weaker) reason for why I make my framework easily swappable is because eventually I want to make an MMO. I especially want this MMO to be extremely accessible. Someone should be able to click a Discord link and it opens a tab on their browser where they're immediately in game and can start playing right away, no accounts, no nothing. And this should work properly with proper platform-specific integrations on every device that people use.

An MMO released recently that gets close to this and is thus a nice example of the idea is [Flyff Universe](https://universe.flyff.com/play). Click the link and try it out. It just works everywhere, everything is properly integrated, it runs well, etc. The only downside it has is that you have to create a character before starting play instead of just being spawned in game directly, but that's a fairly small detail all things considered. This was also all done on a 20+ year old codebase!!! So congratulations to everyone at [Sniegu Technologies](https://github.com/Sniegu-Technologies) for this because I think it's a pretty impressive achievement.

So, this is the kind of thing I want from the technology side of things. Could this be achieved with LÖVE? Maybe, I guess. If I release a few more successful games and make more money I could probably hire a bloke to make sure that LÖVE works everywhere and does so nicely, but, you know, if I'm going to pay anyone to code anything for me it's just not going to be to improve code that I don't own. And so the natural conclusion here is the same as what was described before, where the framework would be swapped for my own code and then I'd have more flexibility to do whatever, including what's needed to make sure the MMO works nicely.

And so this is the high level overarching explanation of my why my engine code is structured the way it is. Now we can get into some actual detail. One last note before we start, though. Despite my code being written in Lua/LÖVE, I'm going to do my best to not get into too many language/framework specific details so that this post remains useful to the broadest set of developers possible. Ideally people using any language/engine/framework combo should be able to read this and take ideas from here for their own workflow. Sometimes I'll necessarily have to get more specific, but that won't be the goal. This should be read more as a "this is how I get things done" post that others can use for comparison/inspiration/curiosity rather than a step-by-step tutorial.

Oh, and one last last note. I am a low IQ dumb idiot retard. I have no professional experience in the game's industry, so take everything you read here with as many grains of salt as you have in the house. If you see me doing something one way and I make no mention as to why I'm not doing it in some other obviously better way, it's often the case that I simply don't know any better. I'm open to comments, corrections, suggestions, anything, so feel free to point things out to me if you feel like it.

### [Comments](https://github.com/a327ex/emoji-merge/issues/1)

### [↑](#table-of-contents)

## Anchor

### Requires

Alright, so everything starts in the [`anchor/init.lua`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua) file. This file is probably the most important, so I'm going to go over it block by block. First, some external libraries are loaded:

```lua
mlib = require 'anchor.mlib'
utf8 = require 'anchor.utf8'
profile = require 'anchor.profile'
require 'anchor.sort'
```

Not really important what they do, I just load them here and first because they're self-contained and don't depend on anything, so why not. Then a few of my own files are loaded:

```lua
require 'anchor.math'
require 'anchor.string'
require 'anchor.table'
require 'anchor.class'
```

These are modules that add functions to Lua's default [`math`](https://github.com/a327ex/emoji-merge/blob/main/anchor/math.lua), [`string`](https://github.com/a327ex/emoji-merge/blob/main/anchor/string.lua) and [`table`](https://github.com/a327ex/emoji-merge/blob/main/anchor/table.lua) tables respectively. Because of the way the engine works, which I'll explain next, these are loaded first here as they are the only modules that have non-mixin functions in them. The [`class`](https://github.com/a327ex/emoji-merge/blob/main/anchor/class.lua) module is loaded last, and it gives me a simple class mechanism (Lua doesn't have one by default) that is a modified version of [rxi/classic](https://github.com/rxi/classic) which only implements mixins (no inheritance), because most things in the engine are mixins.

### [↑](#table-of-contents)

### Anchor class

Next comes the definition of the `anchor` class:

```lua
anchor = class:class_new()
function anchor:new(type, t) if t then for k, v in pairs(t) do self[k] = v end end; self.type = type end
function anchor:anchor_init(type, t) if t then for k, v in pairs(t) do self[k] = v end end; self.type = type; return self end
function anchor:is(type) return self.type == type end
function anchor:init(f) f(self); return self end
function anchor:action(f) self.update = f; return self end
```

From this, you can create a new anchor object like this:

```lua
object = anchor('object_type')
```

You can check if the object is of a given type like this:

```lua
if object:is('object_type') then
```

You can create a new class like this:

```lua
object_type = class:class_new(anchor)
function object_type:new()
  self:anchor_init('object_type')
end

function object_type:update(dt)

end
```

And you can create a new object entirely *locally* like this:

```lua
object = anchor('object_type'):init(function(self)
  -- do constructor things
end):action(function(self, dt)
  -- do update things
end)
```

This last one is a way of creating objects that I really like that I picked up from both [amulet.xyz](https://www.amulet.xyz/doc/#running-a-script) and [kaboom.js](https://kaboomjs.com/). I like it because, for objects that are one-offs, I can define everything about the object locally, meaning, in the same place in the file.
This is an idea that I'll refer to often because I value it, and in my head I call it *locality*, but others might have other names for it. But it's essentially being able to, within reason, define everything about a given behavior in the same place in code.

### [↑](#table-of-contents)

### Mixins

In my games, every object is an anchor object, and I've built those objects such that they have all/most of the engine's functionalities inserted in them as mixins. If you look at the [`anchor/init.lua`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L36) file below the anchor class definition, you'll see lots of lines of the type `anchor:class_add(...)`. These are mixins being added to the anchor class. Because of the way mixins work, this means that every anchor object has access to every function defined in a mixin, as well as to the state defined by that mixin, if any. This makes anchor objects kind of like God objects.

I did things this way mostly for convenience. It's really just a way for me to have easy access to everything everywhere with zero bureaucracy. I could have just as easily defined all these functions in their own modules that are then imported globally, and you'd then just call each function and pass in whatever objects it needs to operate on. The conveniences of doing things like I did add up in small ways, so they'll only become more clear in the next post when I start going over some actual gameplay code. So for now this is basically all the reasoning I can give for it.

Importantly, whenever coding games, I rarely think of adding new gameplay features in terms of mixins and rarely also define my own mixins in gameplay code. My process so far has been mostly to finish a prototype, and then generalize whatever can be generalized into mixins to the engine side of things for the next prototype. Rarely while in the process of making a game will I create general mixins for game functionality because I think this kind of premature generalization often creates more problems than it solves. So even though in theory this is an optimally flexible "you can be anyone and do anything" kind of setup, I don't actually use it that way.

Mixin functions can be called by their objects at any time, but most mixins have some internal state, and thus objects need to initialize that state before using the mixin's functions. This is done by calling `mixin_init` in the constructor, where *mixin* is the mixin's name. This name is also unique among all mixins, and all mixin functions are prefixed by their unique names to avoid name collisions.

[Here](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L36) all mixins get added to the anchor class, and you'll often see a pattern of this type:

```lua
anchor:class_add(require('anchor.timer'))
function timer() return anchor('timer'):timer_init() end
```

The mixin is added to the anchor class via `class_add`, but then a global function with the mixin's name is also created. This is mostly because some types of objects are used often in gameplay code and having a shorter alias like this is good. So whenever I need a timer, instead of saying `anchor('timer'):timer_init()` I can just say `timer()`.

### [↑](#table-of-contents)

### Main object

[Next](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L102), the `main` object is defined, which will contain any and all global state needed for the engine to work.

```lua
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
```

Here a few additional tables are defined to hold objects that have been initialized as certain mixins. For instance, if we go to the [collider mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/collider.lua), at the end of its `collider_init` function we see these lines:

```lua
  table.insert(main.collider_objects, self)
  return self
end
```

This means that whenever we initialize an anchor object as a collider, that object is also added to the `main.collider_objects` table. These tables are useful to automatically call any update or post_update functions that mixins might have, so that I don't have to manually call them for every object. Because of the way garbage collection works in Lua, I have to make sure that whenever objects are destroyed their references are also removed from these tables otherwise memory will leak. The deletion of these references happens at the bottom of this file, where the main loop is defined, [here](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L428):

```lua
for i = #main.area_objects, 1, -1 do if main.area_objects[i].dead then table.remove(main.area_objects, i) end end
for i = #main.collider_objects, 1, -1 do if main.collider_objects[i].dead then table.remove(main.collider_objects, i) end end
for i = #main.input_objects, 1, -1 do if main.input_objects[i].dead then table.remove(main.input_objects, i) end end
for i = #main.hitfx_objects, 1, -1 do if main.hitfx_objects[i].dead then table.remove(main.hitfx_objects, i) end end
for i = #main.shake_objects, 1, -1 do if main.shake_objects[i].dead then table.remove(main.shake_objects, i) end end
for i = #main.timer_objects, 1, -1 do if main.timer_objects[i].dead then table.remove(main.timer_objects, i) end end
for i = #main.stats_objects, 1, -1 do if main.stats_objects[i].dead then table.remove(main.stats_objects, i) end end
for i = #main.observer_objects, 1, -1 do if main.observer_objects[i].dead then table.remove(main.observer_objects, i) end end
```

Next some main loop variables are defined: 

```lua
main.time = 0
main.step = 1
main.frame = 1
main.timescale = 1
main.framerate = 60
main.sleep = .001
main.lag = 0
main.rate = 1/60
main.max_frame_skip = 25
```

My loop is a slightly modified version of [bjornbytes/tick](https://github.com/bjornbytes/tick), which is a simple fixed timestep loop. Next the `main` object is initialized with some mixins:

```lua
main:container_init():input_init():level_init():music_player_init():observer_init()
    :physics_world_init():random_init():shake_init():slow_init():system_init()
```

Each mixin and why they're here will be explained in its own section.

### [↑](#table-of-contents)

### Main init

The [`main:init`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L127) function is defined below this. This is the function that gameplay code calls to set most engine settings up. In emoji merge it looks like this, for instance:

```lua
main:init{title = 'emoji merge', web = true, theme = 'twitter_emoji', w = 640, h = 360, sx = 2, sy = 2}
```

And what this function does is call a bunch of standard initialization functions for various systems, mostly creating the window and setting up all window/graphics related variables in the `main` object. One thing this also does is call `main:load_state`, which loads any previously saved state files. These are two files by default: `device_state.txt` and `game_state.txt`. Device state contains anything pertaining to this particular device, so window size, monitor, framerate, etc. Game state contains any game related state that should be saved between playthroughs, achievements, high scores, run state, etc. These are separated like this because when you have your game on Steam you want to cloud sync the game state, while not syncing the device state, since different devices will have different settings generally. `main:init` also checks to see if it's the first time the game is running, which is useful to know if you want to do something differently in that case. This is located at `main.device_state.first_run`.

Next there are two functions, `main:resize` and `main:resize_up`, and they handle resizing the game's window to a particular size, or simply resizing it up by a certain scaling amount. In both cases it automatically handles cases where the game's internal size (set by `w` and `h` values sent to `main:init`) doesn't fit the monitor properly. Related to the resize functions is the `main:update_mode_and_set_window_state` a few [blocks below](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L243), which actually does the job of changing the window's size and is called by both `main:init` as well as both resize functions.

Next there are `main:load_state` and `main:save_state`, which were already explained, and finally [`main:set_theme`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L268), which sets the global `colors` table to a default color palette. For emoji merge the theme set was `'twitter_emoji'`, which has colors taken from the twitter emoji set. This is so that whenever I'm making a game using twitter emojis and I draw some shape that needs to use a color, I'll use these colors that were taken from the emoji set so that it all goes nicely together. Below `main:set_theme` there are two additional functions named `main:set_icon` and `main:quit` that respectively do what you'd expect them to.

And then finally, before the game loop itself is defined, there is the [`main:draw_all_layers_to_main_layer`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L218) function. In my engine, whenever anything needs to be drawn to the screen it needs to happen through a layer object, which is just an anchor object initialized with the [layer](https://github.com/a327ex/emoji-merge/blob/main/anchor/layer.lua) mixin. I'll explain this mixin in more detail in its own section, but for the purposes of this particular function, the only thing that matters is that the main object is [also a layer mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L168), which means that it has a canvas of the game's internal size and that this canvas can be drawn to:

```lua
function main:draw_all_layers_to_main_layer()
  for _, layer in ipairs(main.layer_objects) do 
    main:layer_draw_to_canvas('main', function() 
      layer:layer_draw_commands()
      layer:layer_draw()
    end)
  end
end
```

As the code above shows, what the `main:draw_all_layers_to_main_layer` function does is as its name implies, it goes over all layer objects, and draws them to the main object's layer canvas. This canvas is then drawn to the screen at the [end of the game loop](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L451):

```lua
 if love.graphics and love.graphics.isActive() then
   main.frame = main.frame + 1
   love.graphics.origin()
   love.graphics.clear()
   main:draw_all_layers_to_main_layer()
   main:layer_draw('main', main.rx*0.5, main.ry*0.5, 0, main.sx, main.sy)
   love.graphics.present()
 end
```

If all you need is to just draw layers in the order they were created, this is fine. But this function is meant to be changed by gameplay code so that you have control over when and how layers are drawn. For instance, here's what emoji merge's `main:draw_all_layers_to_main_layer` looks like:

```lua
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
```

This particular block of code will be explained entirely in the next post, and the particulars of how and why layers work will be explained in their section in this post.

### [↑](#table-of-contents)

### Main loop

Now, finally, the last section of this file, the main loop. In LÖVE the main loop is defined by defining the [`love.run`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L359) function, and that's what I'm doing here.

```lua
function love.run()
  if init then init() end
  love.timer.step()
  local last_frame = 0
```

The application starts by calling an `init` function. This is a function defined by gameplay code in the `main.lua` file, which is the entry point for the program. This is one of two functions gameplay code has to define, the other being `update`. This is what the most basic `main.lua` script that invokes the engine looks like:

```lua
require 'anchor'

function init()
  main:init()
end

function update(dt)

end
```

And so after `init` is called the loop starts proper:

```lua
return function()
  main.dt = love.timer.step()*main.timescale
  main.lag = math.min(main.lag + main.dt, main.rate*main.max_frame_skip)

  while main.lag >= main.rate do
```

This is a fixed timestep loop copied from [bjornbytes/tick](https://github.com/bjornbytes/tick/), which is based on the "Free the physics" section from the [Fix Your Timestep](https://gafferongames.com/post/fix_your_timestep/) article. `main.rate` is the fixed delta and it gets passed to all update functions. `main.lag` is the accumulator, with a small change to make it so that in a situation where things are very laggy you don't get into a death spiral situation by capping the amount of lag that can accumulate, via the use of the `main.max_frame_skip` variable.

After the end of this while loop - which I believe Unity friends call "fixed update", so who am I to refuse the terminology - after fixed update comes rendering everything, which looks like this:

```lua
  while main.framerate and love.timer.getTime() - last_frame < 1/main.framerate do
    love.timer.sleep(.0005)
  end

  last_frame = love.timer.getTime()
  if love.graphics and love.graphics.isActive() then
    main.frame = main.frame + 1
    love.graphics.origin()
    love.graphics.clear()
    main:draw_all_layers_to_main_layer()
    main:layer_draw('main', main.rx*0.5, main.ry*0.5, 0, main.sx, main.sy)
    love.graphics.present()
  end

  love.timer.sleep(main.sleep)
end
```

The while is there, I assume, to make everything render with what `main.framerate` is set to. If VSync is on this already happens naturally, so I would intuit that it only comes into play when VSync is off or when `main.framerate` is smaller than `main.rate`.

`main.framerate` is set to the monitor's refresh rate in `main:init`, so, for instance, my monitor is 144Hz, which means that `main.framerate` gets set to 144 while `main.rate` is 1/60. This means that for every fixed update there are 2, sometimes 3 display updates and that while doesn't really get activated since `current_time - last_time` will rarely be smaller than `1/main.framerate`. However, if I manually set `main.framerate` to 30, for instance, that while will be activated often since the time between frames will often be smaller than `1/30`.

So yea, after that everything gets drawn, and then `love.timer.sleep` is called at the end to not hog the user's CPU more than necessary, as far as I understand it.

Now for what's inside [fixed update](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L368):

```lua
  while main.lag >= main.rate do
    if love.event then
      love.event.pump()
      for name, a, b, c, d, e, f in love.event.poll() do
        if name == 'quit' then
          if main.steam then steam.shutdown() end
          main:save_state()
          return a or 0
        elseif name == 'resize' then
          main:resize(a, b)
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
```

This is all my event handling, most of it input. Based on some quick research it appears that generally input is not handled inside fixed update, however I thought about this carefully and I feel like I have good reasons to do it. I might be wrong, and if I am feel free to correct me, but this is my thought process.

My input mixin, which is initialized in the `main` object only, allows me to say `if main:input_is_pressed('some_action')` anywhere in code and it will return me true or false based on if that action was pressed that frame (same applies for down/released). Having the ability to do this is important because it increases locality. The default way the framework gives me for handling input is with the use of callbacks, which decreases locality so I don't want to do it like that.

This means that I have to set some state for every event that happens, and every frame check for events this frame + last frame to set pressed/down/released state to true or false. Pressed will be true if the event happened this frame but didn't last frame, released will be true if the event didn't happen this frame but happened last frame, and down will be true if it's happening this frame.

Knowing this, I can now do some analysis on the drawbacks of having input handling inside vs. outside fixed update under different conditions, mostly when `main.lag` is very small vs. very large. Let's start with inside fixed update + very small `main.lag`. When that's the case, fixed update may not be called on a given frame, which will result in either dropped input or a delayed input response. If events are queued by the underlying framework until they're read, then they won't be dropped, otherwise they will. I don't actually know which it is so let's find out.

Our event handling block starts with [`love.event.pump`](https://love2d.org/wiki/love.event.pump), which describes its behavior as "pump events into the event queue". I assume this means it takes events from SDL into LÖVE's own event queue to later be used with `love.event.poll`. Looking at LÖVE's source, it does [this](https://github.com/love2d/love/blob/2aad15c865da4f0cce061c479100341430800f52/src/modules/event/sdl/Event.cpp#L124):

```c++
while (SDL_PollEvent(&e))
{
  Message *msg = convert(e);
  if (msg)
  {
    push(msg);
```

Which seems to confirm my assumption. [`SDL_PollEvent`](https://github.com/libsdl-org/SDL/blob/930438dfb7408a6104325cdf4d6796f26acb06a4/src/events/SDL_events.c#L864) itself does this:

```c
SDL_bool SDL_PollEvent(SDL_Event *event)
{
    return SDL_WaitEventTimeoutNS(event, 0);
}
```

[`SDL_WaitEventTimeoutNS`](https://github.com/libsdl-org/SDL/blob/930438dfb7408a6104325cdf4d6796f26acb06a4/src/events/SDL_events.c#L992) with 0 as the second calls [`SDL_PeepEventsInternal`](https://github.com/libsdl-org/SDL/blob/930438dfb7408a6104325cdf4d6796f26acb06a4/src/events/SDL_events.c#L691) to get events from the event queue, and that function itself does this:

```c
/* Lock the event queue, take a peep at it, and unlock it */
static int SDL_PeepEventsInternal(SDL_Event *events, int numevents, SDL_eventaction action,
                                  Uint32 minType, Uint32 maxType, SDL_bool include_sentinel)
{
    int i, used, sentinels_expected = 0;

    /* Lock the event queue */
    used = 0;

    SDL_LockMutex(SDL_EventQ.lock);
    {
```

And so, yea, because this is locking SDL's event queue to take events from it, I can assume that this queue is populated whenever events happen at the system level, and we read from it whenever we need by using `SDL_PollEvent` -> `love.event.pump`. Which means that when `main.lag` is very small and the event handling block is inside fixed update, events won't be dropped, they'll simply be delayed. This is definitely a negative, but now let's continue the thought process with the other 3 scenarios.

Now for large `main.lag` and event handling block still inside fixed update. When this happens fixed update will be called multiple times (but not more than `main.max_frame_skip` times) before rendering the next frame, and input will be polled every one of those times. Because we know that SDL's event queue is being populated in another thread, whenever events happen during those consecutive fixed updates we'll be able to read them just fine and nothing abnormal will happen.

Now the cases where the event handling block is outside fixed update. If `main.lag` is very big we will get multiple fixed updates for every normal update. Because input handling (love.event.pump) is in normal update, all those fixed updates will happen without having the ability to read for any new events until that's done with. Because events are queued they will not be dropped, but they will be delayed.

If `main.lag` is very small instead and we are handling input outside fixed update, our fixed update might not be called while our normal update does. What happens in this case is that input state will be set to true/false without our game logic (which is inside fixed update) having the chance to properly read it, which means that input will actually be dropped. 

For instance, if some piece of code is checking for a released event inside fixed update, but the release happens in a frame where `main.lag` is very small, when a fixed update tick is allowed to happen next frame, that key won't be released anymore, because released is true when the key isn't being pressed this frame but was last frame, except it got released last frame, so it isn't being pressed this frame but it also wasn't being pressed last frame, and thus our fixed update check simply fails.

This happens due to my requirement for locality which forces me to keep track of state changes like this, but if all my gameplay code is in fixed update and fixed update can not happen sometimes then it breaks. There's one way I could fix this, which is moving most of my gameplay code outside fixed update and only leaving some kinds of gameplay code in there. This is the solution Unity goes for I believe (not primarily for this reason), but to me it's a very tasteless solution. I am simply not dividing my code between multiple types of update functions, it's just not happening because it's a kind of added complexity that's just not my vibe. I am not very smart, there's no reason to make things harder for myself.

There's probably some other way I could fix this, but I really can't of it right now (if you know make sure to comment). And so when analyzing the situation as a whole, input handling inside fixed update wins because it has less drawbacks. When `main.lag` is small it delays inputs, when `main.lag` is big nothing bad happens. Whereas for the alternative when `main.lag` is small it drops inputs, and when `main.lag` is big it delays them. And so that's why it's inside fixed update. Again, I could be wrong about my analysis in some important way, but this has been my thought process on it so far.

OK, so for the rest of fixed update we have [this](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L409):

```lua
  if main.steam then main.steam.runCallbacks() end
  for _, layer in ipairs(main.layer_objects) do layer.draw_commands = {} end
  for _, x in ipairs(main.sound_objects) do x:sound_update(main.rate*main.slow_amount) end
  for _, x in ipairs(main.music_player_objects) do x:music_player_update(main.rate*main.slow_amount) end
  for _, x in ipairs(main.input_objects) do x:input_update(main.rate*main.slow_amount) end
  main:physics_world_update(main.rate*main.slow_amount)
  for _, x in ipairs(main.area_objects) do x:area_update(main.rate*main.slow_amount) end
  for _, x in ipairs(main.observer_objects) do x:observer_update(main.rate*main.slow_amount) end
  for _, x in ipairs(main.timer_objects) do x:timer_update(main.rate*main.slow_amount) end
  for _, x in ipairs(main.hitfx_objects) do x:hitfx_update(main.rate*main.slow_amount) end
  for _, x in ipairs(main.shake_objects) do x:shake_update(main.rate*main.slow_amount) end
  main.camera:camera_update(main.rate*main.slow_amount)
  main:level_update(main.rate*main.slow_amount)
  if update then update(main.rate*main.slow_amount) end
  for _, x in ipairs(main.area_objects) do x:area_update_vertices(main.rate*main.slow_amount) end
  for _, x in ipairs(main.collider_objects) do x:collider_post_update(main.rate*main.slow_amount) end
  for _, x in ipairs(main.stats_objects) do x:stats_post_update(main.rate*main.slow_amount) end
  main:physics_world_post_update(main.rate*main.slow_amount)
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

  main.lag = main.lag - main.rate*main.slow_amount
end
```

And this is just calling updates, post updates and deleting references to anything that has its `.dead` attribute set to true.
The order in which things are called follows these general categories: layer draw commands reset -> mixin updates -> physics world update -> gameplay code update -> mixin post updates -> physics world post update -> mixin dead removal. Within each of those categories the order doesn't matter, although I've had to change the order of one thing or another here or there for reasons I don't quite remember.

And that's about it. I think I've explained everything about this file. It is the most important file in the whole thing, so it makes sense to go over it in a bit more detail. From here until the end of this post, we will now simply go over every mixin that shows up [here](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L36) in a way less detailed manner. I'll explain why the mixins are the way they are, mostly why their functions/interfaces/APIs look like they do, without going into too much code detail like I did for this file. If you want to see how anything works implementation wise you can just read it yourself, it's code that's ultimately fairly simple to understand.

Mixins will be covered in order of most to least important/interesting/cool:

### [↑](#table-of-contents)

## Timers and observers

Timers are the most important concept in the entire engine. The idea was initially taken, many years ago, from [vrld's](https://github.com/vrld) [hump.timer](https://hump.readthedocs.io/en/latest/timer.html) library, and then over the years I have gradually changed them to suit my needs. Timers are important because they are my way of doing things over time completely *locally*. Consider the [`timer_after`](https://github.com/a327ex/emoji-merge/blob/main/anchor/timer.lua#L20) function:

```lua
function init()
  main:timer_after(4, function() print(1) end)
end
```

Placing this on the `init` function will make it so `1` is printed to the console after 4 seconds. This can happen because `main` has been initialized with the timer mixin (see [here](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L125) with the [slow mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/slow.lua)), and thus can use timer functions. Internally, the `timer_after` function looks like this:

```lua
function timer:timer_after(delay, action, tag)
  local tag = tag or main:random_uid()
  self.timer_timers[tag] = {type = "after", timer = 0, unresolved_delay = delay, delay = self:timer_resolve_delay(delay), action = action}
end
```

And all it does is create a table storing the `action` function indexed by this particular timer call's unique tag. This table is then updated on the [`timer_update`](https://github.com/a327ex/emoji-merge/blob/main/anchor/timer.lua#L162) function like so:

```lua
function timer:timer_update(dt)
  for tag, t in pairs(self.timer_timers) do
    if t.timer then t.timer = t.timer + dt end
    if t.type == "after" then
      if t.timer > t.delay then
        t.action()
        self.timer_timers[tag] = nil
      end
    end
```

This is advancing the timer in time, and once it goes over the `.delay` value, which in our example was `4`, it calls the stored `action` function and then removes the timer from the `.timer_timers` table. All other types of timer and observer functions are doing this same thing, except with slightly different logic each time.

The usefulness of this construct really can't be overstated, as it means that you can code all sorts of behavior that needs to happen over any number of frames, under any number of different conditions, and have all that code be in the same place in your codebase, which increases locality by a lot.

For example, here's the `drop_emoji` function in emoji merge, which is what happens when the player clicks to drop an emoji into the arena:

```lua
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
  self:timer_after(1.4, function()
    self.spawner.emoji = images.closed_hand
    if self.spawner_emoji.dropping then
      self.spawner_emoji.dropping = false
      self:choose_next_emoji()
    end
  end, 'drop_safety')
end
```

It does a bunch of stuff, but it ends with an `observer_condition` call and a `timer_after` call. [`observer_condition`](https://github.com/a327ex/emoji-merge/blob/main/anchor/observer.lua#L36) takes in two functions, a condition and an action, and executes the action once when the condition becomes true. Internally what this is doing is running the condition function every frame, storing its result, and only triggering the action once the current result is true and the result for the prior frame is false.

In this example, the `observer_condition` function is waiting until the emoji that was just dropped (`self.spawner_emoji`) enters a collision with either another emoji or one of the arena's walls, and once that happens it calls the `choose_next_emoji` function. Both the `observer_condition` and `timer_after` calls have tags defined for them, `'drop_emoji'` and `'drop_safety'` respectively. These tags are like unique handles that can be later cancelled if necessary. In this example, the `'drop_safety'` timer is cancelled in the `choose_next_emoji` function because the timer exists in case the observer condition isn't triggered like it should, but if the function was called at all then in either case it doesn't need to be active anymore.

The tags also serve another purpose: when a timer or observer is created with the same tag as an existing one, it automatically cancels it. This is often the behavior you want, since these timers/observers generally get triggered on events you don't control, and thus you don't want multiple of them running and doing the same thing by accident (this leads to lots of bugs).

I believe this timer/observer setup is not uncommon, I see [libraries in Unity](https://github.com/akbiggs/UnityTimer) that do roughly the same thing, and I think many devs must eventually reach something similar to this. In any case, it's very useful. As you can see from the `drop_emoji` function example, all the behavior needed to make that function work is inside the function's body, even though it's behavior that's happening across hundreds of frames and on unpredictable events.

This is pretty much how I code most multi-frame behaviors in my games now, and even in SNKRX's codebase from 3 years ago you can see examples of this everywhere, like [here](https://github.com/a327ex/SNKRX/blob/master/enemies.lua). It's just an extremely local and thus fast way of doing things that just works.

There are drawbacks to it, though. You have to be careful with tagging things properly and cancelling them when needed, and you have to be careful with memory leaks. Suppose an object dies and you want to do something over some indefinite period of time from its death. You can't do this from the object's timer functions because the object is dead and thus not being updated anymore (you could simply hide the object, but generally when I kill an object I prefer to really kill it), and thus you have to do it from another object's timer, generally I default to using `main`'s one. But because of the way closures work, as long as that timer on `main` is alive, a reference to this now dead object will still be held, and thus it won't be collected. And so small mistakes like this one can lead to leaks that are annoying to track across the codebase. I've gotten used to it now and don't make these kinds of mistakes anymore, but there's definitely some kind of learning curve.

And yea, that's about it. All the functions for the timer/observer mixins can be seen in their files, [here](https://github.com/a327ex/emoji-merge/blob/main/anchor/timer.lua) and [here](https://github.com/a327ex/emoji-merge/blob/main/anchor/observer.lua). Everything is fairly well documented and self-explanatory. I'd say the only thing worth mentioning still is perhaps the [`timer_tween`](https://github.com/a327ex/emoji-merge/blob/main/anchor/timer.lua#L92) function, which is also very useful:

```lua
-- Tweens the target's values specified by the source table for delay seconds using the given tweening method.
-- All tween methods can be found in the math/math file.
-- If after is passed in then it is called after the duration ends.
-- If tag is passed in then any other timer actions with the same tag are automatically cancelled.
-- :timer_tween(0.2, self, {sx = 0, sy = 0}, math.linear) -> tweens this object's scale variables to 0 linearly over 0.2 seconds
-- :timer_tween(0.2, self, {sx = 0, sy = 0}, math.linear, function() self.dead = true end) -> tweens this object's scale variables to 0 linearly over 0.2 seconds and then kills it
function timer:timer_tween(delay, target, source, method, after, tag)
...
```

This API is similar to most tweening libraries I see in the wild, like [this one](https://github.com/AnnulusGames/MagicTween) and can do pretty much anything they can. For instance, this one has lots of helpful functions like `SetLoops` and `SetDelay`, which I can do with `timer_every` and `timer_after`.

An alternative to using timers/observers that people have told me about is using coroutines. [Elias Daler](https://twitter.com/eliasdaler) has a [nice article](https://edw.is/how-to-implement-action-sequences-and-cutscenes/) on the advantages of coroutines. I, personally, just have never vibed with coroutines at all. I can see how it's solving the same (and perhaps even more) problems as the ones that timers/observers do, but when I think about those problems the solution that just naturally makes sense to me is timers/observers and not coroutines. I don't know, something about them just does not intuitively sit well with me, and I've learned to trust my intuition, so I never ended up using them. But I understand that many people do, and they're an alternative that exists in most engines/languages now, so I thought I'd mention it.

### [↑](#table-of-contents)

## Input

My [input mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/input.lua) is very simple. As mentioned before it's in fixed update, and whenever events happen some state gets set, like `.input_keyboard_state['a']` is set to true if the `'a'` key is down this frame. Every frame, input's update function checks for these states and sets pressed/down/released state for every action based on a combination of current and past frame's state.

Actions are the common binding mechanism that I think everyone uses where you bind multiple keys to a specific action. For instance, this is what a default action binding might look like for me:

```lua
main:input_bind('action_1', {'mouse:1', 'key:z', 'key:h', 'key:j', 'key:space', 'key:enter', 'axis:triggerright', 'button:a', 'button:x'})
main:input_bind('action_2', {'mouse:2', 'key:x', 'key:k', 'key:l', 'key:tab', 'key:backspace', 'axis:triggerleft', 'button:b', 'button:y'})
main:input_bind('left', {'key:a', 'key:left', 'axis:leftx-', 'axis:rightx-', 'button:dpad_left', 'button:leftshoulder'})
main:input_bind('right', {'key:d', 'key:right', 'axis:leftx+', 'axis:rightx+', 'button:dpad_right', 'button:rightshoulder'})
main:input_bind('up', {'key:w', 'key:up', 'axis:lefty-', 'axis:righty-', 'button:dpad_up'})
main:input_bind('down', {'key:s', 'key:down', 'axis:lefty+', 'axis:righty+', 'button:dpad_down'})
```

And here `main` can make use of input functions because it has been initialized with the input mixin [here](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L125). What these input bindings do is that they allow for gameplay code to only have to care about actions instead of individual keys. So you'd do something like this:

```lua
if main:input_is_pressed('action_1')
```

And that would return true on the frame where any of the `'action_1'` keys have been pressed, which in this example are left mouse button, z, h, j, space, gamepad's right trigger or gamepad's right or bottom face buttons.

The only additional thing of note in this input mixin are perhaps the `input_is_sequence_pressed/down/released` functions, which allow you to do stuff like this:

```lua
if main:input_is_sequence_pressed('right', 0.5, 'right')
```

And that would return true only when the `'right'` action has been pressed twice, and the second press happened within 0.5 seconds of the first. This is useful for things like dashes, double clicks or any fighting game style combos. Other than that, the code is pretty self-explanatory and simple, and it just works.

### [↑](#table-of-contents)

## Layer

The [layer mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/layer.lua) is responsible for anything drawing related. Anything that gets drawn to the screen needs to be drawn to a layer, which is then draw to the main layer via the previously mentioned [`main:draw_all_layers_to_main_layer`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L218) function, and then this main layer is finally drawn to the screen.

A layer is nothing more than a single or multiple [`canvases`](https://love2d.org/wiki/Canvas). Each canvas is of the game's internal size, and if you have multiple of them it's generally for applying some screen-wide effect. For instance, multiple layers in emoji merge have canvases in them called [`'outline'`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L9):

```lua
game1:layer_add_canvas('outline')
game2:layer_add_canvas('outline')
game3:layer_add_canvas('outline')
effects:layer_add_canvas('outline')
ui2:layer_add_canvas('outline')
```

And this is because outline is a screen-wide shader that applies an outline around non-transparent objects, and it does so only for these particular layers. The default canvas that every layer has is called `'main'`, while additional ones are given unique names to the user's liking.

In addition to these effects, the primary purpose of the layer is to enable to me send draw commands from anywhere in gameplay code, since this increases locality. The most straightforward way I found of doing this was to store every command in a table, and then only draw them once [`layer_draw_commands`](https://github.com/a327ex/emoji-merge/blob/main/anchor/layer.lua#L32) is called. So, internally, each layer command is doing this:

```lua
function graphics.draw_text(text, font, x, y, r, sx, sy, ox, oy, color)
  local _r, g, b, a = love.graphics.getColor()
  if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
  love.graphics.print(text, font.object, x, y, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
  if color then love.graphics.setColor(_r, g, b, a) end
end

function layer:draw_text(text, font, x, y, r, sx, sy, ox, oy, color, z)
  table.insert(self.draw_commands, {type = 'draw_text', args = {text, font, x, y, r, sx, sy, ox, oy, color}, z = z or 0})
end
```

[`layer_draw_text`](https://github.com/a327ex/emoji-merge/blob/main/anchor/layer.lua#L183) creates a table that is added to the layer's `.draw_commands` table, and then once it's time to actually draw the commands this happens:

```lua
function layer:layer_draw_commands(name)
  self:layer_draw_to_canvas(name or 'main', function()
    if not self.fixed then main.camera:camera_attach() end
    for _, command in ipairs(self.draw_commands) do
      if graphics[command.type] then
        graphics[command.type](unpack(command.args))
      else
        error('undefined layer graphics function for ' .. command.type)
      end
    end
    if not self.fixed then main.camera:camera_detach() end
  end)
end
```

[`layer_draw_commands`](https://github.com/a327ex/emoji-merge/blob/main/anchor/layer.lua#L32) simply goes over all commands in the `.draw_commands` table and calls `graphics[command.type]`, which in our example above would be `graphics.draw_text`, which actually contains the draw instructions.

This is wasteful and there are certainly better ways of achieving the same goal, but this is what I currently arrived at and it works. In gameplay code all the user has to do is say `layer_name:draw_text(...)` anywhere and the commands will be stored and then drawn when the frame ends.

I actually spent quite some time trying to figure out better ways of doing this, but I couldn't really because I don't understand anything about graphics coding. The way LÖVE's loop works is that it exposes `love.update` and `love.draw`, and you can only call draw functions in `love.draw`. This is bad because it decreases locality. To solve this, you can simply change [`love.run`](https://love2d.org/wiki/love.run) so that `love.graphics.clear` is called before your update functions, allowing you to call graphics functions from anywhere.

The problem with this is that you're still bound by the order in which you call things, and this decreases locality. Often in code I'll have multiple objects that have to be drawn in completely distant orders but that have to be in the same place in code, and if your draw calls are ordered based on when they appear in code this just doesn't work.

This is why layers that store commands to be drawn later are a good concept and I couldn't find a better way of achieving this goal with LÖVE's API alone. I did find that Randy's framework has the concept of [layers](https://randygaul.github.io/cute_framework/#/draw/cf_draw_push_layer) in it:

```c
void cf_draw_push_layer(int layer);
int cf_draw_pop_layer();

// Draw layers are sorted before rendering. Lower numbers are rendered first, while larger numbers are rendered last.
// This can be used to pick which sprites/shapes should draw on top of each other.
```

Which seems like a good indication that I both reached a correct conclusion with this concept (which is hardly surprising, it just makes sense that 2D games use layers) and that when I swap the framework, if I swap to his it will support this particular mixin's workings better.

### [↑](#table-of-contents)

## Container

[`container`](https://github.com/a327ex/emoji-merge/blob/main/anchor/container.lua) doesn't betray its name, it's a simple container of objects with some functions to operate on them. In general objects should go in containers, although that's not strictly required (you'll just have to handle object destruction manually in that case, which is fine in some cases). Containers should be created according to access patterns, so, for instance, in emoji merge I have [3 containers](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L433):

```lua
self.emojis = container()
self.plants = container()
self.objects = container()
```

Emojis and plants are in their own containers because I often need to do things querying all emojis or all plants, and then all other objects are in the objects container because they don't matter. The `main` object is a container because sometimes I also need to query *all objects*, regardless of which container they're in. So my solution for this was to make `main` a container and add a reference to an object to it [whenever it is added](https://github.com/a327ex/emoji-merge/blob/main/anchor/container.lua#L36) to any container:

```lua
function container:container_add(object)
  object.container = self
  table.insert(self.objects, object)
  self.by_id[object.id] = object
  main:container_add_without_changing_attributes(object)
  return object
end
```

This way, all objects that are in any container can be easily accessed at `main.objects`. Like with the `mixin_objects` tables, references also need to be removed from the main container otherwise leaks will happen, and that also happens at the [end of this file](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L436):

```lua
main:container_remove_dead_without_destroying()
```

`container_remove_dead_without_destroying` removes all objects which have their `.dead` attribute set to true, but without calling any destroy functions on them. One thing that containers do automatically when removing objects is calling any destroy functions, which are functions that also need to remove references from other systems, the main (and only so far) one being the destruction of box2d bodies/fixtures/shapes/joints. So this container function just makes sure to remove the objects from the main container without destroying them again.

### [↑](#table-of-contents)

## Colliders and physics world

The [collider mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/collider.lua) is an extension of a box2d body + fixture + shape. It works in conjunction the [physics_world mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/physics_world.lua) and provides collision detection and resolution functionalities, on top of several movement functions and steering behaviors.

Currently this is the only thing I'm using for collision detection, so even things like UI, which need collision detection with the mouse, are using box2d colliders. There used to be an area mixin, but I decided to stop using it because I want to spend one or two projects using only the collider + physics_world mixins, and then build a lighter, no physics engine version of it (some frameworks call this an "arcade" mode), that uses the exact same API. So gameplay code can be the exact same if it's using box2d or not (except of course for things that are not feasible to do myself, like realistic physics behaviors, joints, etc).

To use these mixins, from the `init` function you must call [`main:physics_world_set_callbacks`](https://github.com/a327ex/emoji-merge/blob/main/anchor/physics_world.lua#L40), which will create callback functions for when collisions between colliders happen. It accepts two arguments, `callback_type` and `tag_or_type`. `callback_type` can be `'collider'` or `'world'`, the first means that collision callbacks will populate each collider's `.collision_enter/active/exit` and `.trigger_enter/active/exit` tables every frame, which can then be read on a collider's update function like so:

```lua
for _, collision_data in ipairs(self.collision_enter['other_type']) do
  local object, x, y = collision_data[1], collision_data[2], collision_data[3]
  ...
end
```

This is a very high locality way of doing things, because no matter where you are in code, for every object, you can simply go over the list of collisions that happened this frame and do whatever you need. If `callback_type` is `'world'` instead, though, then collision callbacks will populate the physics world's `.collision_enter/active/exit` and `.trigger_enter/active/exit` tables every frame, which can then be read anywhere like so:

```lua
for _, collision_data in ipairs(main:physics_world_get_collision_enter('type_1', 'type_2') do
  local object_1, object_2, x, y = collision_data[1], collision_data[2], collision_data[3], collision_data[4]
  ...
end
```

This is similar to the other one, except it's better suited for situations where it doesn't quite make sense for collision events to be handled in any one object's update function. For instance, in emoji merge, it doesn't make sense to merge emojis from any one emoji's update function, and thus [this code](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L553) appears in `arena:update` instead:

```lua
for _, c in ipairs(main:physics_world_get_collision_enter('emoji', 'emoji')) do
  local a, b = c[1], c[2]
  if not a.dead and not b.dead and a.has_dropped and b.has_dropped then
    if a.value == b.value then
      self:merge_emojis(a, b, c[3], c[4])
    end
  end
end
```

Very straightforward. `tag_or_type`, the other argument passed in to `physics_world_set_callbacks` defines if the tag type to be used by the callbacks is based on physics tags or anchor object types. The latter are the types defined when you call `anchor('type')` or `anchor_init('type')` to create an object, while physics tags are tags defined with the [`main:physics_world_set_collision_tags`](https://github.com/a327ex/emoji-merge/blob/main/anchor/physics_world.lua#L128) function. For instance, here's their definition for [emoji merge](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L150):

```lua
main:physics_world_set_collision_tags{'emoji', 'ghost', 'solid'}
main:physics_world_disable_collision_between('emoji', {'ghost'})
main:physics_world_disable_collision_between('ghost', {'emoji', 'ghost', 'solid'})
main:physics_world_enable_trigger_between('ghost', {'emoji', 'ghost', 'solid'})
```

And so these tags are there so that the user can call `physics_world_enable/disable_collision_between` and `physics_world_enable/disable_trigger_between` various physics tags. A collision refers to a physical collision, while a trigger refers to a sensor collision. Every collider has both a normal fixture and a sensor, so that whenever objects physically ignore each other they can still generate collision events (triggers) between them. So, if `tag_or_type` is `'tag'` then these physics tags are used, otherwise if it's `'type'`, then the anchor object types are used instead.

And yea, I think that's about it for the physics world. The `main` object is initialized as a physics world [here](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L125), thus there's one global box2d world being used if you decide to use these physics world mixin functions via `main`. Any collider that is added to a container automatically has its body + fixture + shape destroyed at the end of the frame whenever its `.dead` attribute is set to true. If you decide to create collider objects and not use containers then you must remember to destroy these yourself by calling `:collider_destroy`.

There are lots of useful collider functions for movement, such as [`collider_move_towards_point`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L125), [`collider_move_towards_angle`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L125) or [`collider_rotate_towards_velocity`](https://github.com/a327ex/emoji-merge/blob/main/anchor/collider.lua#L414). Additionally, there are also various steering functions such as [`collider_arrive`](https://github.com/a327ex/emoji-merge/blob/main/anchor/collider.lua#L464), [`collider_wander`](https://github.com/a327ex/emoji-merge/blob/main/anchor/collider.lua#L482) or [`collider_separate`](https://github.com/a327ex/emoji-merge/blob/main/anchor/collider.lua#L494). These steering functions all return forces to be applied to the collider, which you then must do manually.

For being thin wrappers over box2d I'm pretty happy with these mixins, they work well and make implementing everything I need pretty easy.

### [↑](#table-of-contents)

## Text

Next, the [text mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/text.lua). This is one that I'm really happy with given how much it does, how easily expandable it is, and how few lines of code it uses to do it. This mixin implements a character based effect system that lets you do pretty much anything you might need to do to individual characters when drawing text to the screen. For instance, here's a simple example:

```lua
color_effect = function(dt, layer, text, c, color)
  layer:set_color(color)
end
```

And this defines a color effect. The way effects work is that every frame, for every character, the effects that apply to that character are called before the character is drawn. Every effect function receives the same arguments, which are the time step, the layer the character is being drawn to, a reference to the text object, a reference to the character object (every character is an anchor object), and then any arguments that the effect defines. An example of another effect:

```lua
shake = function(dt, layer, text, c, intensity, duration)
  if text.first_frame then
    if not c.shakes then c:shake_init() end
    c:shake_shake(intensity, duration)
  end
  c.ox, c.oy = c.shake_amount.x, c.shake_amount.y
end
```

Same deal, this makes use of two extra ideas though. First, it uses `text.first_frame`, which is true in the first frame of the text object's existence. And we want this because, in this case, we want to initialize each character with the `shake` mixin (which will be explained later), so that we shake it, which happens by setting the characters `.ox, .oy` attributes to the values calculated by the shake mixin.

Now, finally, the way a text object is created is like so:

```lua
text('[this text is red](color=colors.red2[0]), [this text is shaking](shake=4,4), [this text is red and shaking](color=colors.red2[0];shake=4,4), this text is normal', {
  text_font = some_font, -- optional, defaults to engine's default font
  text_effects = {color = color_effect, shake = shake_effect}, -- optional, defaults to engine's default effects; if defined, effect key name has to be same as the effect's name on the text inside delimiters ()
  text_alignment = 'center', -- optional, defaults to 'left'
  w = 200, -- mandatory, acts as wrap width for text
  height_multiplier = 1 -- optional, defaults to 1
})
```

Tags for characters are defined using a markdown-like syntax, so `[this text is red](color=colors.red2[0])` sets all those characters to the color `colors.red2[0]`. Arguments for any given tag can theoretically be any Lua value since I'm using Lua's equivalent of `eval` to parse them, although I haven't tested if it works for everything. And after the text itself is defined it can also optionally have a bunch of other settings applied to it, like the font, alignment, wrap width and so on.

This is a very simple setup that quite literally allows for everything. Wanna do a textbox-like effect? Just make all characters hidden and unhide them using `timer_after` and the character's index, like so:

```lua
textbox = function(dt, layer, text, c)
  if text.first_frame then
    c.hidden = true
    c:timer_init()
    c:timer_after(0.05*c.i, function() c.hidden = false end)
  end
  if c.hidden then layer:set_color(colors.invisible)
  else layer:set_color(colors.white[0]) end
end
```

Something like this would do it by making use of the character's `.i` attribute, which is the character's position in the text, thus making every character visible after 0.05*index seconds.

This system is also very easily expandable. For instance, suppose I wanted to add support for images in the text, so that I can have emojis in there. Because each character is an anchor object, and because I'm already doing the calculations to place every character manually (since I have to align + wrap them to new lines), as long as the object has `.w, .h` attributes, its position can be easily calculated and it can be added no problem. So not only could I add images, I could add any kind of arbitrary anchor object, images, colliders, buttons, etc.

And all this in just 300 lines of code!!! This, to me, is a good example of everything that's nice about owning your own code. I get everything I want and need, I can add features to it easily, and I don't have to depend on anyone's code to do so. Perfect!

### [↑](#table-of-contents)

## hitfx, flashes and springs

The [hitfx mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/hitfx.lua) is used to make objects flash and go boing whenever they're hit by something. It's a conjunction of [springs](https://github.com/a327ex/emoji-merge/blob/main/anchor/spring.lua) and [flashes](https://github.com/a327ex/emoji-merge/blob/main/anchor/flash.lua) into one because they're often used together. If you want an explanation of how the springs work I wrote [this post](https://github.com/a327ex/blog/issues/60) before which goes over it in great detail.

The way to create a new hitfx effect is simply to call [`hitfx_add`](https://github.com/a327ex/emoji-merge/blob/main/anchor/hitfx.lua#L24):

```lua
self:hitfx_add('hit', 1)
```

And this would add a spring + flash named `'hit'` to the object. This spring's default value would be `1`, which is a useful value when you want to attach it to an object's scale, for instance, since when you pull on the spring it will bounce around that 1 value, which is what you want to make an object go boing:

```lua
self:hitfx_use('hit', 0.5)
```

And so this would make the springs initial value 1.5, and it would slowly converge to 1 while bouncing around in a spring-like fashion. To use the spring's value you would simply access `self.springs.hit.x` and then do whatever you'd want with it. This is one of the advantages of having everything as mixins. Because the mixin is in the object itself, accessing any mixin state is as easy as accessing any other variable, a zero bureaucracy setup. In code, you'll often find me using these [like this](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1751):

```lua
game2:push(self.drop_x, self.drop_y, 0, self.springs.drop.x, self.springs.drop.x)
  game2:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, 
    self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
    (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
game2:pop()
```

This example is a bit involved, but given how common it is and how it has the use of multiple mixins, multiple springs and flashes, it's worth going over it. First, this is the part where an emoji in emoji merge gets drawn. The push/pop pair is making it so that the `'drop'` spring scales the emoji around the `.drop_x, .drop_y` position, which is a position that is the exact middle between the emoji that is about to be dropped and the little hand that drops it. Scaling things around their center vs. scaling things around a common shared position looks different, and in this case I wanted to scale both the hand and the emoji around their common center, so that's how to do it.

Then, the emoji itself gets drawn using [`draw_image_or_quad`](https://github.com/a327ex/emoji-merge/blob/main/anchor/layer.lua#L171). Its `x, y` position is offset by `.shake_amount`, which is a vector that contains the results from the `shake` mixin. This is another example of a mixin's result simply being available by accessing a variable on the object itself. Then the emoji's scale is multiplied by `self.springs.main.x`, which is the `'main'` spring that every hitfx mixin enabled object has, and then finally the image is drawn with a shader active based on two conditions. If `self.dying` is true, then it uses the grayscale shader to be drawn in black and white, while if `self.flashes.main.x` is true, it gets drawn with the combine shader, which allows the color passed in (in this case `colors.white[0]`) to affect the emoji's color and make it white. `self.flashes.main.x` is true for a given duration based on its `hitfx_use` call, which for the emoji happens when its created anew from two other emojis being merged:

```lua
if self.hitfx_on_spawn then self:hitfx_use('main', 0.5*self.hitfx_on_spawn, nil, nil, 0.15) end
if self.hitfx_on_spawn_no_flash then self:hitfx_use('main', 0.5*self.hitfx_on_spawn_no_flash) end
```

This is on the emoji's constructor. The first `hitfx_use` calls the `'main'` spring and has it move around by 0.5 (1.5 starting value until settles back on 1), with a flash duration of 0.15 seconds. While the second `hitfx_use` simply moves it by 0.5 with no flash.

And that's about it. This is a fairly useful construct that I use a lot. There are probably better ways of doing it but this works well enough for me.

### [↑](#table-of-contents)

## Animation

Animation is divided between three mixins: [`animation_frames`](https://github.com/a327ex/emoji-merge/blob/main/anchor/animation_frames.lua), [`animation_logic`](https://github.com/a327ex/emoji-merge/blob/main/anchor/animation_logic.lua), and [`animation`](https://github.com/a327ex/emoji-merge/blob/main/anchor/animation.lua). The animation mixin is just a mix of animation frames and animation logic to create a simple animation object. 

Animation frames handles the visual aspect of an animation, currently just loading a spritesheet and drawing it. It looks like this:

```lua
player_spritesheet = image('assets/player_spritesheet.png')
player_idle_frames = animation_frames(player_spritesheet, 32, 32, {{1, 1}, {2, 1}})
player_run_frames = animation_frames(player_spritesheet, 32, 32, {{1, 2}, {2, 2}, {3, 2}})
player_attack_frames = animation_frames(player_spritesheet, 32, 32, {{1, 3}, {2, 3}, {3, 3}, {4, 3}})
```

You provide it a spritesheet, the size of each sprite, and then where in the spritesheet each animation is and it will go through it as you'd expect it to. If the spritesheet only has a single animation on a single row, then you can omit the last argument.

Animation logic handles the logical aspect of an animation, which looks like this:

```lua
self.animation = animation_logic(0.04, 6, 'loop', {
  [1] = function()
    for i = 1, main:random_int(1, 3) do floor:container_add(dust_particle(self.x, self.y)) end
    self.z = 9
  end,
  [2] = function() self:timer_tween(0.025, self, {z = 6}, math.linear, nil, 'move_2') end,
  [3] = function() self:timer_tween(0.025, self, {z = 3}, math.linear, nil, 'move_3') end,
  [4] = function()
    self:timer_tween(0.025, self, {z = 0}, math.linear, nil, 'move_4')
    self.sx = 0.1
    self:timer_tween(0.05, self, {sx = 0}, math.linear, nil, 'move_5')
  end
})
```

And in this example, each frame is going to last 0.04 seconds, there are 6 frames, they'll loop from the first frame once the end is reached, and for the first 4 frames the functions provided will be called. So whenever the first frame happens, some dust particles will be created and the object's `.z` attribute will be set to 9. I separated both concepts like this because I often find myself doing animations with code, and being able to use the logical part of an animation like this comes in handy in a lot of situations. For instance, all the animations for how the mage does its attacks in the video below (click the image), which are inspired by how [Archvale](https://store.steampowered.com/app/1296360/Archvale/) did it, were made using this animation_logic mixin:

[![](https://img.youtube.com/vi/1szzTEk5fpQ/maxresdefault.jpg)](https://www.youtube.com/watch?v=1szzTEk5fpQ&t=162s)

### [↑](#table-of-contents)

## Camera

The [camera mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/camera.lua) is nothing special. It has the functions [`camera_attach`](https://github.com/a327ex/emoji-merge/blob/main/anchor/camera.lua#L22) and [`camera_detach`](https://github.com/a327ex/emoji-merge/blob/main/anchor/camera.lua#L37) that apply the camera's transform to any draw operations between them, and then it has [`camera_get_local_coords`](https://github.com/a327ex/emoji-merge/blob/main/anchor/camera.lua#L57) and [`camera_get_world_coords`](https://github.com/a327ex/emoji-merge/blob/main/anchor/camera.lua#L45) to translate from local to world to local positions. Those are really the only things that the camera is actually doing.

Everything else could be another mixin, for instance, if I need the camera to move I could just make it a ghost collider and use the collider movement functions. To make it shake I can just make it a shake mixin and apply the shake values to its position. I think even the transform thing could be a general parent/child mixin instead of behavior unique to the camera. So really the camera could mostly just be a mesh of other mixins instead of having any unique code for itself at all. But currently that's not the case, and the only other mixin that I actually use in it is the shake one.

By default there's one global camera at `main.camera`, and every layer references this global camera. If a layer has its `.fixed` attribute set to true, then all its draw operations will not use the camera's transform, otherwise they will, as can be seen [here](https://github.com/a327ex/emoji-merge/blob/main/anchor/layer.lua#L35):

```lua
function layer:layer_draw_commands(name)
  self:layer_draw_to_canvas(name or 'main', function()
    if not self.fixed then main.camera:camera_attach() end
    ...
```

There's not much to it because I just don't need that much for the kinds of games I'm making now.

### [↑](#table-of-contents)

## Shake

The [shake mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/shake.lua) makes any object its initialized in shake. The shake function is based on some article I read a while ago, I thought it was referenced in the shake file but it isn't anymore for whatever reason. I'm sure it's in one of my old repositories, but I'm not gonna go grab the external drive with my old code to go search for it. And it's probably uploaded to github, but github now, you can't use it for search anymore because \*Jon Blow voice on\* some idiots at github, some real gits these people, decided in their grand fucking stupidity that you shouldn't be able to search for things anymore, now if you wanna search for something you get no results because it "isn't indexed". Wanna sort your results by date? You can't! That's modern software for you, I don't understand how these people live with themselves. These web people... Ugh, I can't. And you go look for the explanation, why doesn't the search function work properly anymore, why doesn't it? And you get this:

![](https://i.imgur.com/3dkiQml.png)

See, this is what's so terrible about modern developers. Who makes these decisions? It's so goddamn bad. Like, you implement the new search function, and you can't sort it because it's "technically challenging". How about implementing it such that it makes sorting easy, huh? This is so summer intern that it's insane. All of the people involved in this decision, all of them, fired immediately with prejudice. Not only fired, also sued, to take back all the time lost to this stupidity. Ugh, I just can't \*hits desk\* with these people...  I just fucking HATE Visual Studio so godd-\*Jon Blow voice off\*

Anyway, [this post](http://www.davetech.co.uk/gamedevscreenshake) is probably as good as the other one, in the end it doesn't matter. There are two main shake functions, [`shake_shake`](https://github.com/a327ex/emoji-merge/blob/main/anchor/shake.lua#L62) which implements a normal shake with intensity falloff, and [`shake_spring`](https://github.com/a327ex/emoji-merge/blob/main/anchor/shake.lua#L52) which implements a directional springy shake. While there are many kinds of different shaking functions you could implement, these two have served me pretty well so far.

As explained before, when the any of the two shake functions is called, the [`shake_update`](https://github.com/a327ex/emoji-merge/blob/main/anchor/shake.lua#L89) function will run its calculations and ultimately change the `.shake_amount` vector with the current shake values. The object then simply needs to read those values, and when drawing it, offset the object's position by it.

## Color

There are three color mixins: [`color`](https://github.com/a327ex/emoji-merge/blob/main/anchor/color.lua), [`color_ramp`](https://github.com/a327ex/emoji-merge/blob/main/anchor/color_ramp.lua) and [`color_sequence`](https://github.com/a327ex/emoji-merge/blob/main/anchor/color_sequence.lua). The color mixin is just that, it takes in `r, g, b, a` values or a hex code and then you use the color object to draw things with... the color...

Most colors that I use are defined in the `main:set_theme` function, which sets a global table of colors based on a given theme, for instance, here's the `'twitter_emoji'` theme, with colors taken from the twitter emoji set:

```lua
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
```

This uses the `color_ramp` mixin, which works by taking a color and then creating 20 colors with an offset of, in this example, 0.025 between them (or ~6 in 0-255 range), which lets you refer to colors by index. So `colors.fg[0]` is `231, 232, 233`,  `colors.fg[-5]` is `199, 200, 201`, and `colors.fg[5]` is `255, 255, 255`. Very useful, and while I'm also sure that there are better and more informed ways of doing stuff like this (I see people making color palettes all the time and they seem to do it with some proper technique to it), this does the job well enough for me.

Finally, `color_sequence` facilitates the change of an object's `.color` attribute over time. For instance:

```lua
self:color_sequence_init(colors.fg[0], 0.5, colors.blue[0], 1, colors.red[0])
```

Will set `.color` to `colors.fg[0]` immediately, then after 0.5 seconds will change it to `colors.blue[0]`, then 1 second after that will change it to `colors.red[0]`. It's just a handy way of changing something's color in sequence. I could do this with timers, I could do this with animation_logic, so this mixin doesn't really need to exist, but it does and sometimes I use it.

### [↑](#table-of-contents)

## Sounds and music player

The [sound](https://github.com/a327ex/emoji-merge/blob/main/anchor/sound.lua) and [music player](https://github.com/a327ex/emoji-merge/blob/main/anchor/music_player.lua) mixins either play sounds or music. The sounds mixin keeps an internal list of sound instances and updates them every frame for every sound that has been loaded, removing the instances that have reached their end. The music player mixin plays one song at a time, `.current_song`, but has some functionality so that songs can be played on loops, in specific orders, shuffled, and so on, like you would expect from a music player.

Additionally, there's a [sound_tag](https://github.com/a327ex/emoji-merge/blob/main/anchor/sound_tag.lua) mixin, which is useful for tagging different sounds that might need different volumes or effects applied to them. I generally use just two tags: `sfx` and `music` since those reflect the in-game options for sound volume.

Loading sounds looks [like this](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L129):

```lua
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
```

And here both tags are applied to their specific sounds, and so, for instance, setting `sfx.volume` to 0, would automatically mute all current and future sounds that have that tag. Playing a sound looks like this:

```lua
sounds.drop:sound_play(0.6, main:random_float(0.95, 1.05))
```

The first argument is volume, the second is pitch. And playing a song looks like this:

```lua
main:music_player_play_song(sounds.closed_shop, 0.375)
```

All very simple. One thing I like to do, which isn't in the current version of the engine, is changing a song's pitch whenever the player gets hit. And this could be easily done by going into the music player mixin and changing `.current_song`'s pitch by whatever value. The same for sounds, for instance, [here's](https://github.com/a327ex/emoji-merge/blob/main/anchor/sound.lua#L19) what setting the volume of every active instance based on a tag's volume looks like:

```lua
for _, instance in ipairs(self.sound_instances) do
  instance.instance:setVolume(instance.volume*(self.tag and self.tag.volume or 1))
end
```

And that's basically all I use for sounds. LÖVE has a fairly nice API for more [complicated sound effects](https://love2d.org/wiki/EffectType) but I really haven't found the need for them so far, so none of my code has any support for it currently.

### [↑](#table-of-contents)

## Random

The [random mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/random.lua) is responsible for generating random numbers. One global instance of it is initialized to the `main` object. You can create your own random objects with specific seeds, which would look like this:

```lua
rng = random(seed)
```

And then you can call a bunch of functions on it, like [`random_float`](https://github.com/a327ex/emoji-merge/blob/main/anchor/random.lua#L22), [`random_int`](https://github.com/a327ex/emoji-merge/blob/main/anchor/random.lua#L31), [`random_angle`](https://github.com/a327ex/emoji-merge/blob/main/anchor/random.lua#L90), and so on. Perhaps the only function that warrants comment is [`random_weighted_pick`](https://github.com/a327ex/emoji-merge/blob/main/anchor/random.lua#L66), which gives you a random number affected by the given weights. So, for instance:

```lua
main:random_weighted_pick(50, 30 20)
```

Will return 1 50% of the time, 2 30% of the time, and 3 20% of the time. You can pass in any number of values and the weights will be calculated accordingly, they don't have to add up to any specific value. So all these 3 are valid:

```lua
main:random_weighted_pick(1, 2, 1, 2, 1, 2, 1, 2, 3, 4, 1, 2)
main:random_weighted_pick(1000, 40, 2, 0.5, 601)
main:random_weighted_pick(10, 8, 2)
```

But, except for the last one, the others are hard to actually calculate what the chances are. So you're probably better off using sensible numbers, i.e. it's easy to see the total in the last one is 20, so it will return 1 50% of the time, because 10 is half of 20...

### [↑](#table-of-contents)

## Slow

The [slow mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/slow.lua) uses the timer mixin to slow down the game by a certain percentage and slowly tween it back to normal speed. The `main.slow_amount` variable is multiplied by `main.rate` in [`love.run`](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L411) whenever it is passed to any update function, so if `main.slow_amount` is 0.5 then the game will run half as fast as normal.

So, whenever [`main:slow_slow`](https://github.com/a327ex/emoji-merge/blob/main/anchor/slow.lua#L8) is called it just does that for a given duration:

```lua
function slow:slow_slow(amount, duration, tween_method)
  amount = amount or 0.5
  duration = duration or 0.5
  tween_method = tween_method or math.cubic_in_out
  self.slow_amount = amount
  self:timer_tween(duration, self, {slow_amount = 1}, tween_method, function() self.slow_amount = 1 end, 'slow')
end
```

Here you can see a real use of timer's tagging mechanism. This slow timer call is tagged with the `'slow'` tag, which means that if its called multiple times while another slow is going on, the slows won't stack. The old one will simply stop working and the new one will take over, which is the behavior you'd generally want.

### [↑](#table-of-contents)

## Stats

The [stats mixin](https://github.com/a327ex/emoji-merge/blob/main/anchor/stats.lua) wasn't used in emoji merge, but I use it in any game where entities need to have any kind of stat, especially if they need buff/debuff-like functionality.

To add a stat:

```lua
self:stats_set_stat('str', 0, -10, 10)
```

And this would make it so that `self.stats.str.x` is a value that is initially 0 and that can go from -10 to 10. Changing this value can be done by calling [`stats_add_to_stat`](https://github.com/a327ex/emoji-merge/blob/main/anchor/stats.lua#L64):

```lua
self:stats_add_to_stat('str', 5) -- self.stats.str.x is now 5
self:stats_add_to_stat('str', 5000) -- self.stats.str.x is now 10 because the upper limit is 10
self:stats_add_to_stat('str', -15) -- self.stats.str.x is now -5
```

And then adding buffs or debuffs to this value can be done by calling [`stats_set_adds`](https://github.com/a327ex/emoji-merge/blob/main/anchor/stats.lua#L72) or [`stats_set_mults`](https://github.com/a327ex/emoji-merge/blob/main/anchor/stats.lua#L79). For instance:

```lua
self:stats_set_adds('str', self.str_buff_1 and 1 or 0, self.str_buff_2 and 1 or 0, self.str_buff_3 and 2 or 0)
self:stats_set_mults('str', self.str_buff_4 and 0.2 or 0, self.str_debuff_1 and -0.2 or 0, self.str_buff_6 and 0.5 or 0)
```

The general formula for stat adds and mults is `(base + adds)*(1 + mults)`. So if `self.str_buff_1` is true for this frame, then 1 will be added to the base str stat this frame. Similarly, if `self.str_buff_4` is true, then 0.2 will be added to the final multiplier. Assuming that all these buffs are true this frame, and the base str stat is `2`, then our final value would be `(2 + (1+1+2))*(1 + (0.2-0.2+0.5))` which would be equal to `6*1.5` which is `9`.

It's important to note that at the end of the frame, `stats_post_update` is called automatically by the engine and resets all adds and mults that were applied this frame, which is why they need to be reapplied every frame, and `stats_update` has to be called after they are applied so the calculations actually take place.

This setup doesn't allow for certain types of modifiers currently. Like, for instance, in Path of Exile there's a difference between normal multipliers, which are added together into a single multiplier like in this mixin, and multipliers that multiply everything else. This is the difference between the keywords `increased` and `more`. To support `more` type of multipliers, I'd simply need to change the calculation to be like `(base + adds)*(1 + mults)*(more mult 1)*(more mult 2)*...`. So far I haven't found the need to do this yet, but this is how it'd be done.

Similarly, in a game like Tree of Savior there exists the concept of a `damage line`. These are essentially additional instances of damage that all your modifiers apply to, and thus getting more damage lines is another (fun) way of increasing your damage output. Coding multiple damage lines in a game would simply require you to create multiple instances of damage, but the equivalent of this in the stat mixin alone would be having multiple `(base + adds)*(1 + mults)` lines applying to the same stat, so just a flat int multiplier, like `2*(base + adds)*(1 + mults)` for 2 lines.

In some games you also have concepts for added/additional damage/stats that don't get affected by any other modifiers, which would look like `(base + adds)*(1 + mults) + added`. The point being, this mixin doesn't support everything, but it's easily expandable to do so, it's like 80 lines of code, most of which are comments, easy.

### [↑](#table-of-contents)

## Grid and graph

The [grid](https://github.com/a327ex/emoji-merge/blob/main/anchor/grid.lua) and [graph](https://github.com/a327ex/emoji-merge/blob/main/anchor/graph.lua) mixins are literally just that, just implementations of those particular data structures. The graph mixin is just a graph, you can create the graph, add and remove nodes and edges, and there's only one function that does anything which is [`graph_floyd_warshall`](https://github.com/a327ex/emoji-merge/blob/main/anchor/graph.lua#L77) which implements that particular algorithm. Pretty sure I only used this like 5+ years ago for one procedural generation experiment or another.

The grid mixin is much more useful and I use it much more often, but it's similarly just a 2D grid. You can set some `i, j` value, you can get it back, you can apply operations to all values for [`grid_for_each`](https://github.com/a327ex/emoji-merge/blob/main/anchor/grid.lua#L47), you can rotate the grid clockwise or anticlockwise with [`grid_rotate_clockwise`](https://github.com/a327ex/emoji-merge/blob/main/anchor/grid.lua#L140) or [`grid_rotate_anticlockwise`](https://github.com/a327ex/emoji-merge/blob/main/anchor/grid.lua#L110) (this changes the width/height of the grid by creating a new one), and you can also flood fill it with [`grid_flood_fill`](https://github.com/a327ex/emoji-merge/blob/main/anchor/grid.lua#L197).

And yea... As I sit here writing this, I'm realizing that all my engine code is fairly well documented already and that a big portion of this post is redundant because everything is already explained in the files themselves. Oh well, you know, at least the AI has 2 sources to learn from now, so it'll probably be trained better or something, right? Really, I'm helping my future self here. When my memory starts fading and my IQ drops by 20 points, Mother will be able to help me code because past me wrote this very thorough blog post explaining all the reasonings behind everything. I didn't waste 1 week of my life writing this, I didn't!

Now let's get this shit over with!!!

### [↑](#table-of-contents)

## Thin wrappers and miscellaneous

Most other files don't really require much comment because they're either just thin wrappers over one or another thing the framework does or they do something very simple that is self-documenting. Those files are: 

* [`duration`](https://github.com/a327ex/emoji-merge/blob/main/anchor/duration.lua): kills the object after a certain duration, can be easily supplanted by `:timer_after`, don't really remember why this exists and should probably be deleted
* [`font`](https://github.com/a327ex/emoji-merge/blob/main/anchor/font.lua): literally just thin wrapper over LÖVE's font
* [`gradient_image`](https://github.com/a327ex/emoji-merge/blob/main/anchor/gradient_image.lua): uses LÖVE's mesh to create a horizontal or vertical gradient, could probably just create a literal gradient image in paint or something instead
* [`image`](https://github.com/a327ex/emoji-merge/blob/main/anchor/image.lua): thin wrapper over LÖVE's image
* [`joint`](https://github.com/a327ex/emoji-merge/blob/main/anchor/joint.lua): thin wrapper over box2d's joint, don't forget to call `joint_destroy` if you're not adding this to any container!
* [`level`](https://github.com/a327ex/emoji-merge/blob/main/anchor/level.lua): a simple scene switching mechanism, you can call `level_go_to` and it will switch levels, calling `:enter` on the new level and `:exit` on the old one
* [`prs`](https://github.com/a327ex/emoji-merge/blob/main/anchor/prs.lua): some kind of transform object, it really does nothing currently and I should probably delete it
* [`quad`](https://github.com/a327ex/emoji-merge/blob/main/anchor/quad.lua): thin wrapper over LÖVE's quad
* [`shader`](https://github.com/a327ex/emoji-merge/blob/main/anchor/shader.lua): thin wrapper over LÖVE's shader
* [`system`](https://github.com/a327ex/emoji-merge/blob/main/anchor/system.lua): anything system related, currently only has 2 functions to save/load save files
* [`vec2`](https://github.com/a327ex/emoji-merge/blob/main/anchor/vec2.lua): simple vec2 mixin, I don't really use it because creating lots of vectors every frame is slow and I couldn't be bothered to make a pooling mixin yet.


And yea, this is it. Hopefully this has been useful + made somewhat visible how owning your code is not that hard. Most of these files don't have more than a few hundred lines of code, and some of them, like the text mixin, provide quite a lot of useful functionality.

I'd say most of the problems people have with owning their code and using a framework is that they can spend quite a lot of time deciding how things should be structured, but after all these years I've ultimately found that how things are structured really doesn't matter at all. As long as you can insert, remove and update entities at will, you can do anything, and you don't really need anything more complicated than that.

My little mixin setup, which is really just a preference thing, it could have been anything else, and as long as it didn't get in the way with pointless abstractions and bureaucracy it would have been fine.

In the next post, I'm going to cover emoji merge's entire codebase and explain every decision behind most of the code. Anything that was already explained in this post will not be repeated there, so make sure to refer back to this one if you don't understand how something works.

### [Comments](https://github.com/a327ex/emoji-merge/issues/1)

### [↑](#table-of-contents)

---
