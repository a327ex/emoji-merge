# emoji-merge

emoji merge is a Suika Game clone about merging emojis, play it here: https://a327ex.itch.io/emoji-merge

https://github.com/a327ex/emoji-merge/assets/409773/372693e2-c648-447b-b947-4d6a63e28787

## Table of Contents
* [Engine overview](#engine-overview)
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
* [Gameplay code](#gameplay-code)
  - [Init](#init)
  - [Update](#update)
  - [Title](#title)
  - [Emoji rules](#emoji-rules)
  - [Arena](#arena)
  - [Arena:enter](#arenaenter)
  - [Boards](#boards)
  - [Plants](#plants)
  - [Arena:enter 2](#arenaenter-2)
  - [Arena:update](#arenaupdate)
  - [Arena:drop_emoji](#arenadrop_emoji)
  - [Arena:choose_next_emoji](#arenachoose_next_emoji)
  - [Arena:merge_emojis](#arenamerge_emojis)
  - [Roguelite tangent](#roguelite-tangent)
  - [Arena:end_round](#arenaend_round)
  - [Arena:update 2](#arenaupdate-2)
  - [Emoji](#emoji)
  - [Future gameplay code](#future-gameplay-code)
  - [Future engine code](#future-engine-code)
  - [END](#end)

# Engine overview 

> 10/11/23 12:37

A few months ago someone asked me to explain how some of my code worked. I said I was going to do so after I released a new game, and while [emoji merge](https://a327ex.itch.io/emoji-merge) isn't a full release, it's a perfectly sized project to use for giving a fairly in-depth explanation of how my code currently works. I'm fairly happy with my codebase, and it's likely I won't change it significantly for the next 2-3 Steam games I release, so there's no better time than now, while everything's fresh on my mind, to explain it all completely.

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

So personally, I find the collective move to Godot distasteful both because it's a repeat of the same mistake as the one made with Unity 5+ years ago, but also because, logically speaking, it's better to make such a move in the future rather than now. Often times in life you have situations where the correct decision is either 0 or 1. You either do something in a very limited fashion or don’t do it at all, or you do something in a very maximalist and expanded fashion. In these situations the middleground is always going to be the worse option because the math of effort spent for results gained just doesn’t make sense.

Parsimony/risk-version are considered shrewd and realistic - but "realism" denotes a belief congruent with reality, and congruence with reality is measured by success (success = attainment of desired and expected outcome - success of a predictive model), and deluded self-assurance most reliably delivers success - thus delusion is the more realistic model of reality. Aversion to risk is an atheistic neurosis that underestimates the consequences of inaction. You pledge a minute-to-minute decay of your soul in preemption of a more conspicuous kind of failure - but a grander and more poetic kind, too. In exchange you fail constantly, and mundanely. And then you die and God reveals that you could have had more fun with a little faith, because God respects the grindset of a big dick balla. You were so scared to fail that you failed life... all you could have risked was success, and enlightenment. There is no avoidance of risk, just as there is no avoidance of suffering; only their redistribution into a toxic slow-burning disillusionment, or their transfiguration into holiness and sublimity.

In this case, the extremes are better bets. If I was unprepared and had gotten used to Unity, the right move is to either keep using it, or to make your own engine. Moving to Godot is the middleground of toxic slow-burning disillusionment that mathematically doesn't make sense.

In any case... The second (and weaker) reason for why I make my framework easily swappable is because eventually I want to make an MMO. I especially want this MMO to be extremely accessible. Someone should be able to click a Discord link and it opens a tab on their browser where they're immediately in game and can start playing right away, no accounts, no nothing. And this should work properly with proper platform-specific integrations on every device that people use.

An MMO released recently that gets close to this and is thus a nice example of the idea is [Flyff Universe](https://universe.flyff.com/play). Click the link and try it out. It just works everywhere, everything is properly integrated, it runs well, etc. The only downside it has is that you have to create a character before starting play instead of just being spawned in game directly, but that's a fairly small detail all things considered. This was also all done on a 20+ year old codebase!!! So congratulations to everyone at [Sniegu Technologies](https://github.com/Sniegu-Technologies) for this because I think it's a pretty impressive achievement.

So, this is the kind of thing I want from the technology side of things. Could this be achieved with LÖVE? Maybe, I guess. If I release a few more successful games and make more money I could probably hire a bloke to make sure that LÖVE works everywhere and does so nicely, but, you know, if I'm going to pay anyone to code anything for me it's just not going to be to improve code that I don't own. And so the natural conclusion here is the same as what was described before, where the framework would be swapped for my own code and then I'd have more flexibility to do whatever, including what's needed to make sure the MMO works nicely.

And so this is the high level overarching explanation of my why my engine code is structured the way it is. Now we can get into some actual detail. Oh, and one last note. I am a low IQ dumb idiot retard. I have no professional experience in the game's industry, so take everything you read here with as many grains of salt as you have in the house. If you see me doing something one way and I make no mention as to why I'm not doing it in some other obviously better way, it's often the case that I simply don't know any better. I'm open to comments, corrections, suggestions, anything, so feel free to point things out to me if you feel like it.

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

Timers are the most important concept in the entire engine. The idea was initially taken, many years ago, from [vrld's](https://github.com/vrld) [hump.timer](https://hump.readthedocs.io/en/latest/timer.html) library, and then over the years I have gradually changed it to suit my needs. Timers are important because they are my way of doing things over time completely *locally*. Consider the [`timer_after`](https://github.com/a327ex/emoji-merge/blob/main/anchor/timer.lua#L20) function:

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

There's not much else to say about this. Most functions are well documented and simple to understand, so let's move on.

### [↑](#table-of-contents)

## Thin wrappers and miscellaneous

Most other files don't really require much comment either because they're either just thin wrappers over one or another thing the framework does or they do something very simple that is self-documenting. Those files are: 

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

My little mixin setup, which is really just a preference thing, could have been anything else, and as long as it didn't get in the way with pointless abstractions and bureaucracy it would have been fine.

In the next section of this post, I'm going to cover emoji merge's entire codebase and explain every decision behind most of the code. Anything that was already explained in this post will not be repeated there, so make sure to refer back to this one if you don't understand how something works.

### [Comments](https://github.com/a327ex/emoji-merge/issues/1)

### [↑](#table-of-contents)

---

# Gameplay code

> 22/12/23 19:30

There are two types of gameplay code: action-based and rules-based gameplay code. Action-based gameplay code happens in games where most of the game's rules take place within game objects or when game objects interact. Most action and physics games are like this, for example: Spelunky, Risk of Rain, Hades, Isaac, Vampire Survivors, Fall Guys, etc. In most games like this, objects and interactions between objects are the primary way the game's design happens, and so it makes sense that there should be a 1:1 mapping between game objects and their representation in code. This means that for these kinds of games, they are best coded using a primarily game object oriented approach.

Rules-based gameplay code, on the other hand, happens in games where most of the game's rules take place above game objects. Most turn-based games are like this, but also various simulation games, puzzle games, card games and strategy games. For example: Cities: Skylines, Slay the Spire, Artifact, FTL, Slipways, Mini Metro/Motorways, etc. In most games like this, high level game rules are the primary way the game's design happens, and so it makes sense that there should be a 1:1 mapping between those rules and their representation in code. This most often makes sense with a function oriented approach, where ideally each rule is a function that does everything needed for that rule to work completely, and objects are mostly there as structs that hold data relevant to themselves and nothing more. In these games most of the gameplay code will be in the functions, and not in the objects, which is the opposite of the action-based games.

Most gameplay code can be placed somewhere between those two extremes, and it is my claim that knowing exactly where each piece of your game falls on this spectrum, and where your game as a whole also falls on it, is what makes a game's code easy to read and work with, versus making it an unmanageable and confusing hellscape. If a problem clearly is of the rules-based type, forcing the rules into objects is going to be a mistake that is going to make the game's code harder to reason about, because you'll effectively be dividing a rule that should be one thing into multiple objects. Conversely, if a problem clearly is of the action-based type, forcing the rule to be outside the object it belongs to will also be unnatural because often the rules are about how objects react or feel when something happens to them, and coding most of that outside the object itself would be incorrect. 

Most of the hard problems in gameplay code are problems that are right in the center of the spectrum, where both solutions are needed in different places of it. A good example of this is UI code. UI has high level rules that have to be outside any one object (i.e. behavior that happens when multiple objects are selected, or when frames can be moved by the user and have to reorder how other frames look, etc), but each UI object also clearly has its own behaviors that can get quite internally complex. It's a perfect mix of needing both approaches, and people hate it because it's hard to context switch between both, since it's often hard to identify this distinction in reality in the first place. Retained mode UIs, for instance, are an example of an overly action-based solution. IMGUIs, on other hand, try to turn the problem into a rules-based one entirely, which might work depending on the kind of UI work you have to do, but doesn't work as well whenever you need to do fundamentally action-based things with your UIs that require stateful objects to have more ownership of the rules.

It is tempting to think that what I'm saying can be expressed as "object oriented vs. functional" or "stateful vs. stateless", but that would be a mistake. You can have very action-oriented code written completely procedurally or even completely functionally, and you can have very rules-oriented code written entirely in one of those languages that only allows functions inside classes. It's more about the fact that a game design rule exists, and this rule needs to be represented in code. There is a way to express this (design rule, code) pair in a way that comes naturally to most human brains, and you could say that this way is the ground reality, or the truth of how the (design rule, code) pair should be expressed. In the same way that a structural engineer has to consider physical rules in his calculations so the building doesn't collapse, a gameplay coder has to consider the reality of each (design rule, code) pair so that his code doesn't get unmanageable.

Deviations from these truths will generate complexity, and I would argue that most complexity in gameplay code comes from failure to properly identify the truth of each (design rule, code) pair. When a (design rule, code) pair is far away from its truth, coding any further design rules that depend on it becomes a problem, it feels as though you are coding against something that is resisting. When a (design rule, code) pair is close to its truth, on the other hand, the feeling is completely different, everything else that depends on that rule simply flows naturally from it as though it didn't even exist in the first place.

Most games have both types of rules in them, so whenever I'm coding something new I often ask myself: is this a more action-based game or a more rules-based game? And then further, what are this game's design rules, and then for each of those, is this an action-based rule or a rules-based rule? This offers a very nice and clean first cut for organizing your code, and I find that in lots of cases getting this right leads to prosperity, and getting it wrong leads to ruin. There is a reality to how gameplay code should be expressed, and that reality lives on this spectrum. Being able to identify it correctly is, to me, one of the most important skills I've developed so far, as this action-based vs. rules-based distinction has proven itself to be a useful way of thinking about gameplay code.

This rules vs. action dichotomy and the idea of locality explained in the previous post are two high level ideas that are constantly in my mind, and there are multiple examples of both in this codebase. You can find them immediately if you want by just CTRL+Fing "local" or "rules" or "action". While these are important ideas for gameplay code in general, they're not meant to be all-consuming, or super hard rules, or anything like that. They are things I think about and that I care about, but often times there are situations that can't be analyzed using them, and so there's also a matter of knowing when to apply them vs. when not to, like with any technique you might learn.

With this out of the way, we can start going over the codebase block by block. I'll try to go from [line 1](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1) to [line 1755](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1755) in sequence, but often times it'll be better to explain things that are logically close to each other but might be far away from each other in code.

Oh yea, and one last note, I'll assume you read the previous post. Nothing about how the engine works will be explained, if it was already explained in the previous post. If you don't understand something and you really want to understand it, check if the previous post explains it. And if you still can't understand it, then leave a comment with a question and I'll answer.

### [Comments](https://github.com/a327ex/emoji-merge/issues/1)

### [↑](#table-of-contents)

## init

```lua
require 'anchor'

function init()
  main:init{title = 'emoji merge', theme = 'twitter_emoji', w = 640, h = 360, sx = 2, sy = 2}
  main:set_icon('assets/sunglasses_icon.png')
```

Most of this has already been explained in the previous post, however I glossed over the game's size. Here you can see that the game's internal size is set to `w = 640` and `h = 360`. This means that for each layer, a `640x360` canvas is created and then it is multiplied by some `sx, sy` value (not the one passed in), while keeping its aspect ratio, such that it maximally fills the user's monitor. `640x360` was chosen because I looked at [Steam's Hardware Survey](https://store.steampowered.com/hwsurvey/Steam-Hardware-Software-Survey-Welcome-to-Steam) and this was the resolution that multiplies neatly to most people's (80%+) monitors.

In cases where the resolution doesn't multiply neatly to the user's monitor, then it multiplies to the highest possible value while keeping the aspect ratio and then draws the canvas offset by the remainder horizontally/vertically. This all happens on the game's desktop version, which automatically tries to go for windowed fullscreen when the game is first run, I believe. For the web version it just does base resolution times the passed in scale, in this case `640x360` times `2`, which is the resolution I set for the game on itch.io:

![](https://i.imgur.com/rmY8Ann.png)

Next:

```lua
  bg, bg_fixed, game1, game2, game3, effects, ui1, ui2, shadow = layer(), layer({fixed = true}), layer(), layer(), layer(), layer(), layer({fixed = true}), layer({fixed = true}), layer({x = 4*main.sx, y = 4*main.sy, shadow = true})
  game1:layer_add_canvas('outline')
  game2:layer_add_canvas('outline')
  game3:layer_add_canvas('outline')
  effects:layer_add_canvas('outline')
  ui2:layer_add_canvas('outline')
```

Here all layers are defined. `bg_fixed`, `ui1` and `ui2` are fixed layers, which means that they aren't affected by the camera's transform. `game1`, `game2`, `game3`, `effects` and `ui2` have outline canvasses generated for them, which means that they will be affected by the outline shader. And the `shadow` layer has its `.shadow` attribute set to true, which will be used later when we define `main:draw_all_layers_to_main_layer` to make the shadow layer create the game's dropshadow effect.

Perhaps it's worth going over [`main:draw_all_layers_to_main_layer`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L332) here (I'll often do this, where I copy the entire code we'll go over next, and then explain each section block by block, however, you can also just click the what I linked and follow along from another tab):

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

First, all layers have their `layer_draw_commands` function called, which draws the layer's stored commands for this frame to their `'main'` canvas. If all we did was draw commands to layers and then draw them directly to the main layer, without shadow or outline, it would look like this:

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

  main:layer_draw_to_canvas(main.canvas, function() 
    bg:layer_draw()
    bg_fixed:layer_draw()
    game1:layer_draw()
    game2:layer_draw()
    game3:layer_draw()
    effects:layer_draw()
    ui1:layer_draw()
    ui2:layer_draw()
  end)
end
```

![](https://i.imgur.com/4cdu6px.png)

Very odd looking duck. To make it look better, we can add a dropshadow effect, which is achieved by drawing several layers to the shadow layer while using the shadow shader, whose code looks like this:

```lua
vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  return vec4(0.1, 0.1, 0.1, Texel(texture, tc).a*0.2);
}
```

And all this shader does is turn all non-transparent pixels into a transparent-ish gray. So doing all that would look like this:

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

  main:layer_draw_to_canvas(main.canvas, function() 
    bg:layer_draw()
    bg_fixed:layer_draw()
    shadow.x, shadow.y = 4*main.sx, 4*main.sy
    shadow:layer_draw()
    game1:layer_draw()
    game2:layer_draw()
    game3:layer_draw()
    effects:layer_draw()
    ui1:layer_draw()
    ui2:layer_draw()
  end)
end
```

![](https://i.imgur.com/KXKTlIk.png)

Better. As can be seen in the code, all that happens is that we draw `game1`, `game2`, `game3` and `effects` canvases to the shadow layer using the `layer_draw` function, which draws a canvas, and then we draw the shadow layer behind everything (except background layers) with a 4 pixel offset.

Now finally, adding outlines:

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

![](https://i.imgur.com/Ezg2LWY.png)

The outline shader application is similar to the shadow's. For each layer that should be affected by an outline, the layer's `'main'` canvas is drawn to the layer's `'outline'` canvas while using the outline shader, and then whenever drawing that layer to the main layer, first the outline canvas is drawn and then the normal one on top of it. All the outline shader does is turn non-transparent pixels black, as well as their close neighbors:

```lua
vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  vec4 t = Texel(texture, tc);
  float x = 1.0/love_ScreenSize.x;
  float y = 1.0/love_ScreenSize.y;

  float a = 0.0;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y - 2.0*y)).a;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y - y)).a;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y)).a;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y + 2.0*y)).a;
  a += Texel(texture, vec2(tc.x - 2.0*x, tc.y + y)).a;
  a += Texel(texture, vec2(tc.x - x, tc.y + y)).a;
  a += Texel(texture, vec2(tc.x, tc.y + y)).a;
  a += Texel(texture, vec2(tc.x + x, tc.y + y)).a;
  a += Texel(texture, vec2(tc.x + 2.0*x, tc.y + y)).a;
  a = min(a, 1.0);

  return vec4(0.0, 0.0, 0.0, a);
}
```

And that's about it. I'm sure this could have been coded better, but it doesn't matter. In the end it works and that's all that matters to me. I'm not sure if this layer API is what I'll keep using forever or anything, but it works for now and does what I need it to do.

Next:

```lua
  main_font = font('assets/HoneyPigeon.ttf', 22, 'mono')
  font_2 = font('assets/volkswagen-serial-bold.ttf', 26, 'mono')
  font_3 = font('assets/volkswagen-serial-bold.ttf', 36, 'mono')
  font_4 = font('assets/volkswagen-serial-bold.ttf', 46, 'mono')
```

Here all fonts are loaded, the first font isn't used anywhere and I simply forgot to remove it. The other ones are used for the boards on the side of the arena as well as the score blocks when the game ends. The font itself is the font that twitter's emoji set uses, which I found by using one of those font finders, [this one](https://www.fontsquirrel.com/matcherator). 

Next:

```lua
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
```

Input bindings were already explained in the [input section](#input). `colors.calendar_gray` is the color of text in the :calendar: emoji, which is what I used for the boards on the side. This color is defined here simply so we can use it later when drawing text to the boards. Shaders are also loaded here, the only ones I haven't explained so far are `grayscale` and `multiply_emoji`, which will be explained in time. And then the cursor is made invisible because we have the :point_up_2: emoji as the cursor.

Next, loading images:

```lua
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
```

Here all images the game will use are loaded, and they are loaded in two different ways. The normal way is just loading each image individually and then when using them in code you just refer to the `images.image_name` image object. This is the simplest way of loading any asset. The problem is that each image is sized `512x512` because I took them from [emojipedia](https://emojipedia.org/twitter), and initially when I was trying to fix performance issues for the web version I thought this was an issue, so I made a texture of `128x128` images instead. It turns out this wasn't a big issue, but I just left the texture way there just to show how it would be done. This is what the texture looks like:

![](https://i.imgur.com/wTzr4VK.png)

Image mixin's [`image_load_texture_atlas`](https://github.com/a327ex/emoji-merge/blob/main/anchor/image.lua#L11) goes through the texture image and assigns each quad to the name passed in from the table that is the third argument. So the first quad will be assigned to key `'0'` in the table that that function creates, and then that table will be assigned to `images`, and so `images['0']` will have a reference to the quad that contains that image. In gameplay code, if we want draw that image we'll just refer `images['0']`, which will be a `quad` in the web version and an `image` in the desktop version, which is why every image drawing function in the game uses the [`draw_image_or_quad`](https://github.com/a327ex/emoji-merge/blob/main/anchor/layer.lua#L171) function.

That's all there is to this. One thing you could say is that, for the desktop method, I could just do a for loop on all files in the assets directory and load them automatically instead of loading them manually. And that's true. However, one thing I've learned to do over time is to load assets manually because you want assets to have the original names of their files, and then you want to refer to them by other names in game. This is more clear with sounds instead of these images:

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

I have so many sound packs, and I grab sounds from so many different sources, that if I want to properly credit everyone when the game is done I just *need* files to have their original names otherwise I won't know where anything came from. And in this case I got sounds from [Sound-Effect Lab](https://soundeffect-lab.info/) and from [Ghost Mayoker](https://kohada.ushimairi.com/game.html)+[Dequivsia](https://kohada.ushimairi.com/game.html), and I can clearly see that because the files have names that are specific to those projects. So while this didn't make sense for the images because I renamed them anyway, since I know I got them from emojipedia, I just automatically do things this way now for every asset type.

Next:

```lua
  -- bg_1 = gradient_image('vertical', color(0.5, 0.5, 0.5, 0), color(0, 0, 0, 0.3))
  bg_1 = gradient_image('vertical', color(colors.fg[0].r, colors.fg[0].g, colors.fg[0].b, 1), color(colors.blue[10].r, colors.blue[10].g, colors.blue[10].b, 1))
  bg_2 = gradient_image('vertical', color(colors.fg[0].r, colors.fg[0].g, colors.fg[0].b, 1), color(colors.fg[0].r, colors.fg[0].g, colors.fg[0].b, 0.4))
  bg_gradient = bg_1
  bg_color = colors.blue[10]:color_clone()
```

`bg_1` and `bg_2` are the background gradients. `bg_1` is a white to blue one to be used normally, while `bg_2` is a black and white one to be used when the round ends and is turned to grayscale. This is the `bg_1` gradient being drawn by itself:

![](https://i.imgur.com/e0o6f8b.png)

And then drawing the whole background is just a matter of drawing two more rectangles, one above and one below it. This happens in the [`update`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L302) function:

```lua
function update(dt)
  bg:rectangle(main.w/2, 75, main.w, 150, 0, 0, bg_color)
  bg_gradient:gradient_image_draw(bg, main.w/2, main.h/2, main.w, -60)
  bg:rectangle(main.w/2, main.h - 75, main.w, 150, 0, 0, colors.fg[0])
```

Next:

```lua
  main:physics_world_set_gravity(0, 360)
  main:physics_world_set_callbacks(nil, 'type')
  main:physics_world_set_collision_tags{'emoji', 'ghost', 'solid'}
  main:physics_world_disable_collision_between('emoji', {'ghost'})
  main:physics_world_disable_collision_between('ghost', {'emoji', 'ghost', 'solid'})
  main:physics_world_enable_trigger_between('ghost', {'emoji', 'ghost', 'solid'})
```

This was already explained in the [physics section](#colliders-and-physics-world). The only thing of note here is that we initialize callbacks with `nil, 'type'`, meaning that we have access both collider and world types of callbacks, and that our collisions are based on anchor types instead of physics tags. `'ghost'` avoids physical collision with everyone else but generates trigger events with everyone else too; and `'emoji'` and `'solid'` physically collide with each other.

Next:

```lua
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
```

These are the colors used for the `multiply_emoji` shader. I am actually very ashamed of this because I spent like a day on it and I both didn't end up using it, but I also couldn't figure out how to do it properly. Essentially, when you look at all emojis, there are the alphanumerical ones that are these blue blocks:

![](https://i.imgur.com/JcWS4km.png)

What I wanted to do was turn these blue emojis into any other specific color because I thought it would look cool to have them in different colors (it didn't look cool at all). The way I initially went about it was just swap that specific blue color for the color I wanted, but that didn't work because the emoji is not a single blue color, there's like, lots of them on the edges:

![](https://i.imgur.com/ZFqPuLE.png)

So now I figured I'd have to multiple the blue by some value that makes it become my target color, and so I decided instead to just turn all colors to gray, see what value that gray turned out to be (161 on all channels), and then multiply that value by some number that gets me to my target color. This is all the `multiply_emoji` shader does:

```lua
uniform float base;
uniform vec3 multiplier;

float map(float v, float old_min, float old_max, float new_min, float new_max) {
  return ((v - old_min)/(old_max - old_min))*(new_max - new_min) + new_min;
}

float imap(float v, float min, float max) {
  return min*(1.0-v) + max*v;
}

vec4 effect(vec4 vcolor, Image texture, vec2 tc, vec2 pc) {
  vec4 t = Texel(texture, tc);
  float v = map(t.r, base, 1.0, 0.0, 1.0);
  vec3 scaled_multiplier = vec3(imap(v, multiplier.r, 1.0), imap(v, multiplier.g, 1.0), imap(v, multiplier.b, 1.0));
  return vec4(t.rgb*scaled_multiplier.rgb, t.a);
}
```

`base` is `161/255`, and `multiplier` is one of the multiplier tables in `color_to_emoji_multiplier`. You can see this in the `draw_emoji_character` function, which draws one of these block characters:

```lua
function draw_emoji_character(layer, character, x, y, r, sx, sy, ox, oy, color)
  layer:send(shaders.multiply_emoji, 'base', 161/255)
  layer:send(shaders.multiply_emoji, 'multiplier', color_to_emoji_multiplier[color])
  layer:draw_image_or_quad(images[character], x, y, r, sx, sy, ox, oy, nil, shaders.multiply_emoji)
end
```

I am absolutely sure that there must be a simpler way of doing these kinds of color swaps, but this was my solution. In the end I didn't actually need this for any colors other than blue, so this was mostly a waste of time.

Next:

```lua
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
```

This is the table that holds all values for each emoji size. `rs` was copied directly from Suika Game, although in proportion to my game's size (which was also proportionally copied from Suika Game). `score` is the same as Suika Game for each emoji too. And `mass_multiplier` isn't, although I tried to make it similar. This is a multiplier that affects how heavy each emoji is, and in the original Suika Game smaller balls are heavier than the bigger ones, and so some multiplier on their mass is needed. These are the values I reached through observation of the original game, although they probably aren't completely right. `stars` is the number of star particles that spawn when two emojis are merged, and `spawner_offset` is the distance the emoji has from the hand when it's about to be spawned (it is a vector instead of a single y value because before it also had a horizontal offset).

Next:

```lua
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
```

This creates the :point_up_2: cursor, and does so in one of those completely local ways mentioned in the previous post because this is the only pointer that's going to exist. This object is a small ghost collider, because the way I'm doing anything UI related for this game is by using the physics engine, so by making the cursor a collider and any buttons colliders as well I get collision events for UI purposes for "free". This is obviously not ideal, but it's currently how I'm doing my UIs.

I didn't mention this in the previous post, but there's no mixin for anything UI related. I've tried *many* different types of UI mixins/libraries over the years, many different setups and techniques, and so far I haven't found anything that generalizes properly yet. And by generalizes properly I mean, the timer/observer mixins generalize properly, I've been using them for 5+ years, and they're roughly the same as they've been since the start, and they do their job well. A general UI system is one that simply does its job well for every type of game and every type of requirement imposed on it, and I simply haven't found any UI setup that meets those demands yet. And so I just decided to start doing it all manually instead of relying on any reusable UI code. If I keep doing it manually like this I'm sure that eventually some good general idea for it will hit me, until then I prefer to not deal with coding against any existing UI related code.

In any case, in the code above the pointer is simply started as a ghost collider, it's set as a bullet so that it doesn't miss collision events if it's going too fast (I think this is why at least), and then its update function just sets its position to the mouse's position and draws the :point_up_2: emoji.

The next section handles the creation of all buttons, and they all use the [`emoji_button`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1472) class, which we'll go over here:

```lua
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
```

This is similarly a ghost collider, except that in its update function it checks for collisions with `main.pointer`. As mentioned before, we start the physics world with both `'world'` and `'collider'` callback types, which means that whenever collisions/triggers happen, they'll fill up both `main`'s and every collider's `.collision_enter/exit` and `.trigger_enter/exit` tables with the collisions/triggers that happened on that frame.

So emoji button's update function is first checking to see if `main.pointer` has entered a trigger with this button (and it's a trigger instead of a collision because they're both ghosts, and ghosts physically ignore each other, remember that this was set above with `main:physics_world_disable_collision_between`), and if it has, then play a hover sound + does a small boing.

It's also then checking if there's an active trigger with `main.pointer` and if left click was pressed, and if it was, then do a bigger boing and call `self.action`, which is a function that is passed in when an `emoji_button` object is created that will do whatever it is that this button is supposed to do. And that's about it.

Oh, yea, there's also a `collider_set_awake(true)` call there, since because this is a physics object that is not affected by any forces and is just there to be a button, it will go to sleep by default and when that happens it won't trigger collision events. So the `collider_set_awake(true)` call every frame is there to make sure it doesn't sleep. This should have been a `collider_set_sleeping_allowed(false)` on the constructor, but in the end it's the same thing.

Now back to our `init` function, first these are defined:

```lua
  main.sfx_sound_level = main.game_state.sfx_sound_level or 4
  main.music_sound_level = main.game_state.music_sound_level or 4
  main.any_button_hot = false
  local level_to_volume = {0, 0.0625, 0.125, 0.25, 0.5}
  sfx.volume = level_to_volume[main.sfx_sound_level + 1]
  music.volume = level_to_volume[main.music_sound_level + 1]
```

And these are the volume levels for both sound effects and music. First they're read from `main.game_state` which saves whatever volume level the user set the game to in prior playthroughs, and then those are applied to both `sfx` and `music` tags. Next the two volume buttons:

```lua
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
```

This code creates these two buttons at the bottom left of the screen:

![](https://i.imgur.com/5UmsKl6.png)

The code is ultimately fairly simple. For each button, it creates an `emoji_button` object with the emoji that corresponds to its volume level (there are a total of 5 levels). Then it defines `.action`, which is what will happen when the button gets pressed, and in both cases what that action does is change the volume for either `main.sfx_sound_level` or `main.music_sound_level`, save those values to the `game_state.txt` file, then change the volume for `sfx` or `music` tags. Not really that complicated, but this is basically all you need to do to change the volume of all sounds/music and these buttons do it.

These two buttons are also good example of high locality. Most of the code needed to make them work is here, you can read it in one go and it's not that complicated. The only non-local part is the `emoji_button` definition, but once you know what it does you know that the only thing that matters about it is the `action` function. You'll see this over and over across the codebase, code that defines objects very locally, as it is a properly that I like a lot and thus I engineer things such that this is both possible and common.

The following two buttons work similarly:

```lua
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
```

The first button is the screen button at the bottom left of the screen:

![](https://i.imgur.com/tcopu64.png)

This button is only visible on the desktop version of the game, and when you click it it increases the game's scale by `0.5`. In practice this increases the window's size by `320x180` each time, which is a nice value that will work for most people's monitors until they reach (windowed) fullscreen, and in the cases it doesn't, the `resize_up` function also handles it well by creating either horizontal or vertical black borders.

The second button is the close button, and it literally just quits the game. This button similarly is only available on the desktop version, because it only gets updated and drawn when the game is on windowed fullscreen mode (`main.logical_fullscreen` is true):

```lua
  if main.logical_fullscreen then main.close_button:update(dt) end
```

Next, star and cloud objects are defined. This is what it looks like with only them being drawn (no backgrounds):

![](https://i.imgur.com/bPslJOb.png)

First the star objects:

```lua
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
```

Because these are permanent objects that simply need to be updated and aren't colliders, I'm storing them in `main.stars` and `main.clouds` instead of any container, since the containers are reset every time the game restarts, and these objects don't need to be recreated every level restart.

This is creating 80 stars around the entire play area, and all these stars do is move to the left and up, and once they reach a far enough left-up offscreen position, they're teleported to a far enough right-bottom position so the loop starts again. In the end only 30 or so stars are visible at any time, because once they reach the gradient in the middle of the screen they start fading out, but I created 80 of them because initially they were covering the whole screen and I just forgot to change it. Ideally this could have been just a scrolling texture, but this is how I did it and it works.

Next the cloud objects:

```lua
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
```

These use literally the same logic, except they move from left to right and they don't fade out. 

The main thing worth mentioning is that both types of objects are created using, again, a highly local method of creating objects with the function definitions chaining and all that. For object types that are one-offs and are only going to appear in this place in code, creating them like this, using `anchor('type'):init(...):action(...)` makes the most sense since it's the most local way of doing it. It's more local than the previous examples with the `emoji_button` objects, since there's no need for a class definition elsewhere in the codebase. If you're creating *lots* of these types of objects every frame, there is a performance hit to creating multiple closures using this method, so it should be avoided in that case.

Next: 

```lua
  --[[
  profile.start()
  profile_report = 'Please wait...'
  main:timer_every(2, function()
    profile_report = profile.report(20)
    print(profile_report)
    profile.reset()
  end)
  ]]--
```

This is a simple profiler taken from [2dengine/profile](https://github.com/2dengine/profile.lua). It does its job, it works, I used it to fix performance issues with the web version, nothing more to say about it.

Next:

```lua
  main:level_add('arena', arena())
  main:level_goto('arena')
  --[[
  main:level_add('title', title())
  main:level_goto('title')
  ]]--
end
```

This is where the `init` function ends, and where we finally create the `arena` level, which is where all gameplay will take place. The difference between an anchor object that is going to be used as a level vs. one that is not, is that the levels simply have `enter` and `exit` functions defined, and those functions are called when `level_goto` is called.

In this case, `main:level_goto('arena')` is being called, and so the arena object we created and identified with the name `'arena'` will have its `enter` function called. If there was a previously active level, then that level would have had its `exit` function called before. That's all that's happening here.

The `title` level is the level I used to create the game's capsule for itch.io, and it will be explained soon!

### [↑](#table-of-contents)

## update

Next we have the [`update`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L301) function defined:

```lua
function update(dt)
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
```

Most of the game's behavior will be in [`arena:update`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L518) instead, but the update function here is used for any objects that are not destroyed between levels. The game only has one level (the arena), and all gameplay objects are created on `arena:enter` and deleted on `arena:end_round` or `arena:exit`, except for ones that were initialized in the init function and that are being updated here.

The first thing this does is draw backgrounds and stars + clouds:

```lua
function update(dt)
  bg:rectangle(main.w/2, 75, main.w, 150, 0, 0, bg_color)
  bg_gradient:gradient_image_draw(bg, main.w/2, main.h/2, main.w, -60)
  bg:rectangle(main.w/2, main.h - 75, main.w, 150, 0, 0, colors.fg[0])
  for _, star in ipairs(main.stars) do star:update(dt) end
  for _, cloud in ipairs(main.clouds) do cloud:update(dt) end
```

Fairly straightforward and we already went over this. Next the pointer and `main.lose_line` are updated and drawn:

```lua
  main.pointer:update(dt)
  main.lose_line:update(dt) 
```

Turns out that the lose line object (the red dashed line that appears when emojis are close to the top of the arena) is created mistakenly in the `arena:enter` function. In the end it doesn't quite matter, but it should have been created in init instead. Here's the code for it:

```lua
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
```

This is a fairly standard object that operates on two `observer_conditions`. The first is if `main.distance_to_top` is below `64`. `main.distance_to_top` is the distance of the top most emoji to the top of the arena. So when this distance is low, this object's `.color.a` will become 1 (non-transparent). If that distance is instead higher than `64`, then the object's transparency will be set to 0 instead (invisible). Notice how both tweens inside each observer call have the `'alpha'` tag, meaning that if one is called while the other is running, it will cancel it and take over. Each `observer_condition` also have their own `'active_false'` and `'active_true'` tags, which are used when the round ends to cancel the observers so that the line doesn't suddenly appear after the round is over.

Next the buttons are updated:

```lua
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
```

The main thing of note here is the `main.any_button_hot` variable, which is set to true if any button is being hovered over. When this is the case, we don't want to drop emojis whenever the player left clicks, and so we set this variable here and use it in `arena:update` when we're checking for input to drop the next emoji.

This is an example of a kind of rules-based code, where there's a rule needed "above" all buttons, and thus it makes sense to add some code to it outside the class for that kind of button. Technically, for this particular example, it could have been done so that in the `emoji_button` class, it would check for activity with `main.pointer` and set `main.any_button_hot` accordingly. The problem with this is that some buttons are `emoji_button` objects, while others were created locally because they were one-offs. Now we'd have to create some general button code that all buttons would implement, or just repeat the setting of `main.any_button_hot` for each type of button manually... In both cases it's a worse solution than just doing it here, in the update function, in a rules-based manner.

There's also the fact that for some types of UI code, doing them in each object just doesn't work that well. For instance, consider the setting or unsetting of objects' selection state. More specifically, consider that you can select multiple objects by holding shift, and then if you click on one object without using shift, it unselects all others and selects that one alone. You could code this in an action-based manner, with all relevant code inside each button object, but it would feel much more natural to code that logic above all objects, in an updat efunction, and handle the coordination of selections/unselections that way. Quite a lot of editor-like UI code functions like this, and it's a decent example of where rules-based UI code works better.

Next:

```lua
  if main.transitioning then ui2:circle(main.w/2, main.h/2, main.transition_rs, colors.blue[5]) end
end
```

The update function ends with the transition circle being drawn if a transition is happening, which is true when the player presses the retry button. And this is what the retry button does when its clicked (this is in `arena:update`):

```lua
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
```

When it's clicked, `main.transitioning` is set to true and `main.transition_rs` is set to 0. After 0.066*7 seconds, a tween is created to increase `main.transition_rs` to `0.75*main.w` (this size makes the circle covers the entire screen) over 0.8 seconds, and then after that + 0.4 seconds, the level is changed to `'arena'` again, which calls `exit` on the previous level, which was this same arena object, and then calls enter on the next level, which is this same arena object. In this way this same arena object gets recycled and `arena:exit` + `arena:enter` is called on it every time the player restarts the game. And then as this is happening, `main.transition_rs` is being tweened to 0 over another 0.8 seconds.

This is what all this looks like:

https://github.com/a327ex/emoji-merge/assets/409773/158e01f2-46af-426e-a7ed-d17bfe2bcaed

So this makes it clear why some things should be outside any one level object and instead be updated in `update` instead of `arena:update`. Things like this transition circle necessarily need to exist between levels, therefore they can't be contained to any single level.

### [↑](#table-of-contents)

## title

The [title level](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L375) is what I used to create the game's capsule image for itch.io:

![1nc5An](https://github.com/a327ex/emoji-merge/assets/409773/51dc40a8-e930-4b4d-83f3-65bee31ddbbe)

It's a simple level that creates some objects, and those objects can be moved around with the mouse. I then moved them around with the mouse and took a picture.

```lua
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
```

Here some objects are created, specifically `text_roped_chain` and `emoji_collider`. Let's start with the latter. An `emoji_collider` is a rectangle collider that has an emoji attached to it and that can be moved with the mouse. These are only created here, and for the retry button after a round ends. Here's what the code for it looks like:

```lua
emoji_collider = class:class_new(anchor)
function emoji_collider:new(x, y, args)
  self:anchor_init('emoji_collider', args)
  self.emoji = images[self.emoji]
  self:prs_init(x, y, self.r or 0, self.w/self.emoji.w, self.w/self.emoji.h)
  self:collider_init('emoji', 'dynamic', 'rectangle', self.w, self.w)
  self:collider_set_gravity_scale(0)
  self:collider_set_angle(self.r)
  self:collider_set_sleeping_allowed(false)
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
```

There are a few things to note here. First is that because these are being used as buttons or being moved by the mouse, they can't be allowed to sleep, so we call `collider_set_sleeping_allowed(false)` on creation. This is the same as what I mentioned before for the `emoji_button` objects. The second thing of note is that this object only has drawing behavior defined in its update function. More specifically, whenever it's `.hot` (being hovered over), it draws a little crosshair animation around it to show that it can be clicked:

https://github.com/a327ex/emoji-merge/assets/409773/384b4722-9abb-465f-8216-b4616ff4c5d3

But the actual behavior of clicking itself, and the actual behavior of dragging the object around with the mouse is defined elsewhere, more specifically in `title:update` or `arena:update`. This goes back to the action vs. rules distinction, and this is a case where I decided this should be mostly a dumb object, while its behavior should be defined in a rules-based manner in some update function. The behavior I want is that whenever an object is clicked, as long as the mouse button is held down, any mouse movement will apply a force to that object regardless of where it is. Consider the code for it below:

```lua
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
```

All the behavior needed for these kinds of objects to be moved around with the mouse is here, whereas if the first portion of it (what's inside the for loop) was inside each object's class' update function, this behavior would now be expressed in a less local manner (you'd have to jump around the codebase to find it). Not only that, as you can see from the code, this same behavior applies to 3 kinds of objects: `'emoji_collider'`, `'emoji_character'` and `'chain_part'`, which means that it would be less local in 3 different places, or you'd have to use some kind of functionality sharing mechanism, either a function or a mixin, which would still make the code less local. So this is a very good example of both rules-based code *and* highly local code working together to make things simpler.

As for the mechanics of this behavior itself, whenever the left mouse button is clicked while one of those objects is being hovered over it becomes the `.held_object`, and then whenever the left mouse button is held down a force is applied to the currently held object. If the button is released then `.held_object` is set to nil.

If you're wondering about how I reached the values for how much force should be applied to the objects to make them move, how much damping it should have, etc. In all cases in the codebase, it's all just trial and error. I try some value, it either does what I want or not, and then I refine it until I get to what I want. I won't explain any of these values anywhere because it's just unnecessary.

Next, the other object that's created in the `title:enter` function is a `text_roped_chain`, this is a chain of emoji characters that you can see when the score appears after the game ends, or in this case for the title level, the "emoji merge" text itself that makes up the game's title. A `text_roped_chain` does nothing more than create a bunch of `emoji_character` objects, one for each letter of the word it's supposed to represent, and each `emoji_character` is connected by multiple `chain_part` objects, which are themselves connected to each other and to the emoji characters by multiple `joint` objects.

Let's first see what `emoji_character` looks like:

```lua
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
```

This is a simple collider that has an emoji and is drawn to the screen using `draw_emoji_character`. One thing I noticed about this codebase is that there are quite a few different classes that do the same thing, and so in retrospect I should have probably spent some time doing some cleaning up of it and merging a few classes together here or there. Because this game is so small I didn't do this, but this would be the kind of refactoring that goes on in a normal codebase when you're making games that are a bit more involved.

In any case, there's nothing too interesting about this, it's very similar to an `emoji_collider`. It has an additional `change_effect` function, which I don't think is called anywhere, so it's just dead code I forgot to remove. So next, let's look at a `chain_part`:

```lua
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
```

This is also very similar to the other two objects, with the exception that its visuals/collider shape can be either an emoji character (a letter/digit) or a normal chain using `images.blue_chain` or `images.vine_chain`. And then yea, nothing special happening, just another dumb type of object that just gets drawn.

As I said above, a lot of these classes could have been made into the same class, I mean a lot of them, you'll see as we progress. They all have the same shape. They're a collider, some emoji represents them visually, they have timer, hitfx and shake mixins initialized, and sometimes they have mouse interactions going on as well. I think this codebase could have been about 1000 lines of code instead of 1750 if I spent some time merging common/similar code.

And finally the `text_roped_chain` object itself:

```lua
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
```

Quite a bit of code, so it's worth going over it block by block. It's important to note that this code is also very similar to the code in other `_chain` type of classes, of which there are a few. The creation of all different kinds of chains and the common code between them is the kind of thing that I would make into a mixin for a next project that needs chains. 

I generally try to avoid generalizing mixins while I'm working on a given project because I've found that that often creates more problems than it solves, and so one thing I'll often do is finish/drop some prototype, some time will pass where I'll be working on another prototype that needs some generalizable behavior that I already coded in a previous prototype, and then here I'll spend some time turning it into a general mixin that can make things easier, since I both have its uses on the previous project, as well as on this one, and thus the generalization is less likely to be wrong. The same applies to all these `_chain` classes, which will become clear as we go through the rest of the codebase.

In any case, the first block:

```lua
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
```

This is going through all characters in the text, and creating `emoji_character` objects for each one of them. Those objects are added to `text_roped_chain`'s `.characters` table, as well as to arena's `objects` container. Anything added to any of the containers in arena means that that object needs to be updated or deleted via the container. In general this happens for objects that are colliders so that their references in the physics engine get destroyed automatically when the container is destroyed, and `emoji_character` objects are colliders so they should be in a container.

Next block:

```lua
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
```

This creates all the chains that bind `emoji_character` objects together. For every character in the `.characters` table, it picks the next character and then creates an `emoji_chain` between them. The `emoji_chain` object makes sure that the chain is created such that it covers the distance between both objects exactly based on the positions they were just spawned in as well as their sizes. The chains are added to `self.chains`, and aren't added to any container probably because at no point do I need to globally refer to them.

And the final block:

```lua
for _, character in ipairs(self.characters) do
  if not self.no_impulse then
    character:collider_apply_angular_impulse(main:random_float(8, 12)*main:random_float(math.pi/2, math.pi))
    character:collider_apply_impulse(48, 0)
  end
  character:timer_after(4, function() character:collider_set_damping(0.5) end)
end
```

`.no_impulse` is set to true from the caller whenever this is created as the "emoji merge" roped chain, otherwise it's false and thus has impulse, which is the case when it gets created as the final score. Whenever it has impulse it will move to the right with some force. See here:

https://github.com/a327ex/emoji-merge/assets/409773/d43916e2-eee1-426e-a00e-7616a57066a2

And then after 4 seconds its damping gets set to some value and it slowly stops moving. Here's what the creation code for it as a score looks like:

```lua
local text = 'score ' .. self.score
self.final_score_chain = text_roped_chain(text, -46*utf8.len(text), main.h/2 + 48)
```

And here's what the creation code as the "emoji merge" text looks like:

```lua
self.objects:container_add(text_roped_chain('emoji merge', main.w/2, main.h/2, {w = 24, chain_part_size = 12, no_impulse = true}))
```

And that's about it. Note that this `text_roped_chain` object is a logical object that coordinates other objects but has no visual representation. For most of the chains in the game this is useful because when the game ends and we want all objects to collapse and fall, we need to be able to refer to the object that represents that chain and tell it to randomly remove some joints. You could do this without the logical object existing, but it would be more annoying.

`emoji_chain` is used widely in the codebase and was also just used in `text_roped_chain`, so it makes sense to also explain it here. Here's the code for it:

```lua
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
```

It's somewhat involved so it's worth going over it block by block too. The first thing of note is that it receives 2 colliders and then two positions. If you imagine `collider_1` on the left and `collider_2` on the right, the two positions should be the rightmost position of `collider_1`, and the leftmost position of `collider_2`, right? We want a chain between those two, so this is what makes most sense. And if you look back at `text_roped_chain`, this is exactly how the `emoji_chain` object is created, between two characters, with the first on the left and the second on the right, and their positions being offset to their right/left by half the width:

```lua
local chain = main.level.objects:container_add(emoji_chain('blue_chain', character, next_character,
  character.x + character.w/2, character.y, next_character.x - next_character.w/2, next_character.y,
  {chain_part_size = self.chain_part_size or 9}))
```

We want things arranged this way precisely because we'll also soon create joints, and the joints will bind objects together based on their positions in the world which need to be what we expect them to be. Now for the first block:

```lua
self.chain_parts = {}
self.joints = {}
local chain_part_size = self.chain_part_size or 18
local total_chain_size = math.distance(x1, y1, x2, y2)
local chain_part_amount = math.ceil(total_chain_size/chain_part_size)
```

This will store both `chain_part` and `joint` instances. The chain parts are just normal colliders, the joints are box2d joints. We want to automatically create as many chain parts as needed to cover the distance between `collider_1` and `collider_2`, and so these 3 variables here, `chain_part_size`, `total_chain_size` and `chain_part_amount` are the math needed to get that going.

```lua
local r = math.angle_to_point(x1, y1, x2, y2)
for i = 1, chain_part_amount do
  local d = 0.5*chain_part_size + (i-1)*chain_part_size
  table.insert(self.chain_parts, main.level.objects:container_add(chain_part(emoji, x1 + d*math.cos(r), y1 + d*math.sin(r), {hidden = self.hidden, r = r, w = chain_part_size})))
end
```

Then, for however many chain parts we need, we create however many `chain_part` objects are necessary, always offsetting them by the correct amount. Note that this also takes into account the angle of the chain and works for any angle. If you need to understand this kind of `math.cos` and `math.sin` math and how that generally works for placing things in 2D space, I recommend the [5th part of my BYTEPATH tutorial, in the "Player Movement Exercises" section](https://github.com/a327ex/blog/issues/19).

```lua
for i, chain_part in ipairs(self.chain_parts) do
  local next_chain_part = self.chain_parts[i+1]
  if next_chain_part then
    local x, y = (chain_part.x + next_chain_part.x)/2, (chain_part.y + next_chain_part.y)/2
    table.insert(self.joints, main.level.objects:container_add(joint('revolute', chain_part, next_chain_part, x, y)))
  end
end
```

After all `chain_part` objects are created, for each chain part we pick the next one, and then create a joint between the two of them. This effectively creates the chain itself. The joint used is a [`revolute joint`](https://love2d.org/wiki/RevoluteJoint). I tried a bunch of different ones and this one gave the correct chain/rope-like behavior. And finally:

```lua
table.insert(self.joints, main.level.objects:container_add(joint('revolute', collider_1, self.chain_parts[1], x1, y1)))
if collider_2 then table.insert(self.joints, main.level.objects:container_add(joint('revolute', self.chain_parts[#self.chain_parts], collider_2, x2, y2, true))) end
```

After the joints connecting chain parts are created, we also need to create 2 joints, one connecting the first chain part to the first collider, and one connecting the last chain part to the second collider, otherwise the chain won't be attached to any of the objects it's supposed to connect. Fairly straightforward. One last thing to note is that like `text_roped_chain`, `emoji_chain` is also a logical object that simply coordinates all these other objects that make up the chain.

In any case, that's it for the `title` level. When everything is created it looks like this and everything can be moved around as you'd expect:

https://github.com/a327ex/emoji-merge/assets/409773/8483b13c-6563-405d-ad91-cbf8f6ba10d5

Other than the emojis and the little decoration plants, a lot of the rest of the code for this game is a variation of what's inside this level: some colliders and some chain parts + joints binding them together. In the future, if I don't explain some of that kind of code as thoroughly as I did here, refer back to this portion of the post if you don't understand how something works.

### [↑](#table-of-contents)

## Emoji rules

Before we move on to the [`arena level`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L413), it's worth going over the game's rules and how that affects the codebase, especially when it comes to the rules vs. action distinction. The first question to ask is: is [Suika Game](https://www.nintendo.com/us/store/products/suika-game-switch/) a more action-based or more rules-based game?

[![](https://img.youtube.com/vi/7p1d6wl-t0A/maxresdefault.jpg)](https://www.youtube.com/watch?v=7p1d6wl-t0A)

Instinctively it would strike me as an action-based game, as the entire gameplay is emojis touching each other and merging. But instead of relying on instinct alone, it's a good idea to break the game down as a list of all its rules and then assess each rule and where it lies on the action/rules spectrum. And I think most programmers, when watching the video above, would reach this set of rules:

* Emoji merge: emojis merge with each other when they collide and have the same value
* Emoji drop: emojis can be dropped from the hand when the player presses a key
* Next emoji selection: when the dropped emoji hits another emoji/wall, the next emoji and the next next emoji are selected
* End round: when an emoji hits the top of the arena the round ends

And these are essentially the four rules of Suika Game. Now we should classify them along the rules/action spectrum.

The round ending rule seems to like it would be a fairly rules-based rule. It's a rule that would be constantly checking for all emojis if they're over the arena's line, and then ending the round if any of them are. I guess you could code this inside the emoji class itself, and thus as emojis are updated, they're also checking for themselves if they're above the line and calling a round ending function if they are, but, to me, this feels unnatural. Generally when I think of these high level game rules like "has the round ended" or "has a goal been scored", I think "the game is checking for this rule" and not "each object is checking for this rule and then reporting back to the game". Because it *could* be coded in an action-based manner without seemingly any issues, one could classify it as mostly rules-based, but kinda action-based too.

Dropping an emoji seems mostly action-based, as you need to change the emoji's values so it becomes affected by gravity and drops, on top of watching it for collisions so that it triggers the next emoji selection rule. Similarly to the previous one though, because this rule is so simple, it could be coded in a rules-based manner above the emoji object itself without many issues, so I'd say mostly action-based, but kinda rules-based too.

Emoji selection involves two things: spawning the emoji that's going to be dropped next and selecting the next emoji to be placed on the "next" sidebar thingy. You could say that these are two separate things that should each be their own rule, but because they both happen on the same condition (when the dropped emoji hits another emoji/wall), I'm treating them as the same. The first part of this rule is ultimately about both the spawning and the behavior of the emoji that is yet to be dropped. That emoji behaves differently than others because it has to follow the hand, which follows the player's pointer. The question then is, should that following behavior be inside the emoji class itself, or should it be above it? Perhaps the hand object should contain the emoji it's about to drop and move that emoji itself? Or perhaps it should be in neither object? Intuitively, to me, this question has no clear answer. When that's the case it's usually best to wait until more details make themselves visible as you build the game. The second part of this is choosing the next emoji, and because this is so simple it doesn't quite matter which way it leans. In the end, this rule cannot be classified clearly yet.

Finally emoji merging. Merging two emojis works by killing them and creating a new on that is one size higher. This kind of behavior, if you try to code it into an emoji class, will lead to problems. This is because every emoji will be running that code, and thus when a merging collision happens, they both will run the merging code. To make this work you'll have to do something, doesn't matter what it is, to make it so that only one of the emojis does the merging. Whatever it is that is done, it is unnatural. This is clearly a problem that is best coded above any one emoji object, rather than inside it, and thus it's a fairly rules-based rule. Because this behavior is pretty simple and what you'd have to do to code it in action-based manner isn't too complicated, I'd say it's very highly rules-based, but rules-based implementation of it is possible with few issues.

So in the end, our actions look like this:

* Merge : very rules-based
* Drop: mostly action-based
* Selection: undefined
* Round end: mostly rules-based

Ultimately in a situation like this, where there are arguments both ways and things aren't 100% clear yet, and the game is a very simple game with few rules, I generally just default to doing things in a rules-based way. This is because when coding things in a rules-based way I get to contain behaviors in single functions first.

There was already an example of this shown in the title level with the mouse hover + dragging behavior, and this is something I mentioned in the previous post, the property of *locality*. Ideally, all code for a game design rule should be contained in a single function, because then you only need to go to one place to know everything about that rule. This would be highly local code.

One good property of highly local code is that it can be very easily changed, due to the fact that everything about it is in the same place. And so if you mistakenly code something in a rules-oriented way that was actually action-oriented, it's often (not always) easier to fix it than the reverse. The reverse means that you took a rule that was supposed to be a single thing and separated it into multiple classes, inherently a harder problem to grapple with.

So knowing this, it makes sense that the first line of attack for this game is creating functions for these four rules, and the entire behavior for each rule, ideally, should be contained in those functions. I ended up calling these functions `merge_emojis`, `drop_emoji`, `choose_next_emoji` and `end_round`. You can now go look into the codebase and see that I have those four functions in the arena level, and they have a bunch of things in them which describes the behavior for that particular design rule. With all this in mind, we can now start going over the arena level.

However, one quick aside before that. Suika Game/emoji merge are ultimately very simple games. Ideally I should have written a post like this on a real game that I released on Steam, something like a roguelite with lots of rules and a lot more complexity. In that case the truth of this rules vs. action idea would have been made more clear. Maybe I'll do this in the future, who knows (writing this is very time consuming and somewhat boring... so you know, I have to be in the right mood for months).

But what I wanted to say is to keep this rules vs. action distinction in mind whenever you think about the things you're doing in your game. Game design rules often stack and depend on each other, and if you pay attention to this, sooner or later you'll find that when rules are represented in code in the correct way along this spectrum, everything flows naturally. There isn't much of this particular aspect of the idea in this codebase, but pay attention to this yourself in your own codebases and you'll see it!

### [↑](#table-of-contents)

## arena

The arena class starts with its constructor:

```lua
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
```

It's initialized as a timer and observer for some reason, I don't really remember it since you can just use `main` as a timer/observer. The other variables, `top_spacing`, `bottom_spacing`, `w`, `h`, `x1`, `y1`, `x2`, `y2`, `score_x` and `next_x` are as shown in the picture below:

![position_vars](https://github.com/a327ex/emoji-merge/assets/409773/d1edba7f-aac1-49c9-9a57-b904ee0ef2b4)

The size of the arena is proportionally the same as the original Suika Game, and the same goes for the size of the emojis. `.chain_amount` is dead code I forgot to remove, at some point I was doing different things based on how many emojis merged in a row, but I ended up removing that and forgot to remove this variable.

An arena object is only initialized once in [`init`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L293):

```lua
main:level_add('arena', arena())
```

So this constructor is only ever called once. The way the level mixin works makes it only store levels without ever recreating them anew. This is how I decided to do it for now, you could decide to instead create a new `arena` object every time the game has to be restarted. In the end it's going to be the same thing, and most of the arena's creation of objects would either be in the constructor, or how it is now in `arena:enter`.

Before we get into `arena:enter`, it's worth listing all the functions that the arena class has:

* [`arena:enter`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L426): called when the arena starts or restarts
* [`arena:update`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L518): called every frame
* [`arena:exit`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L663): called when the arena ends (restarts)
* [`arena:drop_emoji`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L663): called when the player left clicks
* [`arena:choose_next_emoji`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L730): called after a dropped emoji hits a solid or other emoji
* [`arena:merge_emojis`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L742): called when two emojis of the same value collide
* [`arena:end_round`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L772): called when the round ends

For the rest of this post, we'll go through each of these functions one by one, and once we're done with it we'll be done with the entire game, because the entire game plays out in these functions. Ultimately this entire codebase is structured very simply. There are `init` and `update` that handle global objects that persist between rounds, and then there's `arena:enter` and `arena:update` which are the equivalents for objects that should only exist within each round and should get reset when a new round starts.

### [↑](#table-of-contents)

## arena:enter

With this in mind, let's start with [`arena:enter`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L426):

```lua
function arena:enter()
  bg_color = colors.blue[10]:color_clone()
  bg_gradient = bg_1
  for _, cloud in ipairs(main.clouds) do cloud.emoji = images.cloud end
```

When the round ends, all emojis + background becomes black and white. Because background objects are global and don't get created/deleted between rounds, `arena:enter` is where they have to be set back to their natural color, and these 3 lines are simply just doing that for the background color variable, the background gradient, as well as the cloud objects.

```lua
  main:music_player_play_song(sounds.closed_shop, 0.375)
```

When the round ends the song that's playing while the game is running stops, starting it again when a new round starts makes sense.

```lua
  self.emojis = container()
  self.plants = container()
  self.objects = container()
  self.merge_objects = {}
  self.chain_amount = 0
```

I already explained the containers before but to do it again: the `emojis` container contains all emojis inside the arena, the ones that can merge with each other; the `plants` container contains all little plants that decorate the arena; the `objects` container contains all other objects. The containers are divided this way based entirely on access patterns, meaning, I often need to do things with all emojis and all plants, therefore they get their special container, whereas every other object doesn't need to be accessed in any special way, so they're all in a singular container.

The `container` mixin could additionally have some facilities for easily filtering objects based on their type, but I find that that's unnecessary as I can just create different containers to do that. Note that a single object might also be in multiple containers, because it will be removed as long as its `.dead` attribute is set to true and the user is calling `:container_remove_dead` on all containers its in. And because a single object might be in multiple containers, you can achieve pretty much anything by just creating as many containers as the game requires based on how you need to look for objects.

The `merge_objects` table is a table that will be used to hold temporary objects whenever a merge happens. We'll get to what this means exactly when we go over the `merge_emojis` function but it's nothing too complicated. And `chain_amount` is dead code I forgot to remove.

```lua
  -- Solids
  self.solid_top = self.objects:container_add(solid(main.w/2, -120, 2*self.w, 10))
  self.solid_bottom = self.objects:container_add(solid(main.w/2, self.y2, self.w, 10))
  self.solid_left = self.objects:container_add(solid(self.x1, self.y2 - self.h/2, 10, self.h + 10))
  self.solid_right = self.objects:container_add(solid(self.x2, self.y2 - self.h/2, 10, self.h + 10))
  self.solid_left_joint = self.objects:container_add(joint('weld', self.solid_left, self.solid_bottom, self.x1, self.y2))
  self.solid_right_joint = self.objects:container_add(joint('weld', self.solid_right, self.solid_bottom, self.x2, self.y2))
```

Next the arena walls are created. They look like this by themselves:

![love_oZammD1Xef](https://github.com/a327ex/emoji-merge/assets/409773/df16b55d-c3b8-4294-b1ea-c4bdb6febf25)

Additionally two weld joints are created at the bottom left and bottom right junctions to join those solids. All solid objects are static by default, but when the game ends and the arena falls, they are turned dynamic and have gravity apply to them, and at that point the weld joints are also destroyed so that the arena looks like it's falling apart. That looks like this (notice the bottom left/right of the solids and how they disconnect):

https://github.com/a327ex/emoji-merge/assets/409773/6aedbe67-13ae-460d-80a6-3db5e59bb9c6

And the code for solid class looks like this:

```lua
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
```

Nothing much to note here, it's a normal static rectangle collider. Its color turns to `.gray_color` when `.dying` is true (that's when the arena is falling apart), otherwise its drawn with the `colors.green[0]` color. You'll note that there are 2 rectangles being drawn for the object, and the `game3` one is there so that the plants look correct. If the `game3` rectangle isn't draw, plants will be drawn over the solid and they will look slightly off. 

So drawing another rectangle on top of that is needed. This changes when `.dying` is true and all objects are falling, at which point we want the solid to be drawn at its normal layer, which is `game2`. I think the correct form of this code would have been `if dying then game2 else game3` instead of `game2 if dying return; game3`, but it is what it is and I'm never changing this codebase anymore.

In any case, this is another good example of the layer mixin enabling locality of code. Here I am drawing, from the solid object, across two different layers and sandwiching plant objects without having to care about the order in which I'm calling these draw functions relative to other objects. Everything is contained here, where it belongs, and it just works. Lots of decisions I've made for my engine are around stuff like this that just enables me to express things as locally as possible, since that simplifies the codebase a lot and makes me faster at doing what I need to do.

Next:

```lua
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
```

Next the boards are created, these are the "score" and "best" boards to the left, and the "next" board to the right. The boards are all attached by chains to `.solid_top`, which is spawned outside the screen and looks like this (zoomed out so you can see it):

https://github.com/a327ex/emoji-merge/assets/409773/c37d2853-b98c-475c-85ad-e07fe60abfac

Because we already went over the `emoji_chain` object this should be pretty straightforward to understand. The score and next boards are connected to `.solid_top` by four chains: `.score_left_chain`, `.score_right_chain`, `.next_left_chain` and `.next_right_chain`. And the best board is connected to the score board by one chain, `.best_chain`.

`self.score` is the user's current score; `self.best` contains the user's best score, which is loaded from the `game_state.txt` file when `main:load_state()` is called; and `self.next` contains the next emoji to be spawned, which is initially a random number from 1 to 5 (1 for the smallest emoji and 5 for the biggest that can be spawned, in total it goes up to 11).

And that's about it for this block of code. The boards also have some impulse applied to them initially for some little juice. Next, let's see what the board class looks like.

### [↑](#table-of-contents)

## Boards

The [`board`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L925) class in its entirety looks like this:

```lua
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
```

Very big, so let's go block by block:

```lua
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
```

Each board has a different size, so here we handle the three types of boards that exist by creating them with different widths and heights. Each board also has a different image attached to it (each image is just the same board emoji but with a different color).

```lua
  self:collider_set_damping(0.2)
  self:timer_init()
  self:shake_init()
  self:hitfx_init()
  self:hitfx_add('emoji', 1)
```

Next the boards have to have some amount of damping to them. This is just so that when they're moved they eventually stop, since having moving objects on the sides of the screen forever is distracting and probably sets off some people's autism. Each board object is also initialized with the timer, shake and hitfx mixins. All objects in the arena are initialized with these 3 mixins because they need it, the shake one specifically is needed for when the round ends and every object shakes when it turns to grayscale. The `'emoji'` hitfx is also added, which is just going to be used for juicing the emoji image on the `next` board.

```lua
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
```

In the first conditional a force is applied to the board if the mouse is going over it. This is just a little something nice to add that has no gameplay significance. Notice that the force applied is stronger is the left mouse button is held down, which intuitively makes sense. The second conditional applies a boing effect to the board and spawns a few particles when its clicked.

Again, just something nice to add that has no real gameplay significance. For these kinds of small details it doesn't matter if they're in the object or in some update function elsewhere because they're not really design rules and they generally have no future significance, as in, nothing depends on them, it's just a one-off effect so the rules vs. action idea doesn't apply.

```lua
  game2:push(self.x, self.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x)
    game2:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, 0, 1, 1, 0, 0, colors.white[0], (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game2:pop()
```

Next the board is drawn. I already explained all of this in the previous post, this is the default way everything is drawn. The `'main'` spring is attached to the object's scale, shake mixin's `.shake_amount` is offsetting the draw position, and different shaders/colors are being applied depending on the object's state.

```lua
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
```

And then finally the contents of each board is drawn. For all boards you have a line that starts like `game2:draw_text_centered(self.board_type:upper()`, and this is the title of the board being drawn, like SCORE, BEST or NEXT.
For the score and best boards, next the actual values are drawn:

```lua
local score = main.level.score
game2:draw_text_centered(tostring(score), (score < 999 and font_4) or font_3, self.x, self.y + 12, 0, 1, 1, 0, 0, colors.calendar_gray[0])
```

There's a little conditional logic going on here. Essentially if the score has 3 digits it uses a bigger font otherwise it uses a smaller one or the value won't fit the board's size and it will look wrong.

The NEXT board is the only one that is a little different, because its content is not a value, but it's the next emoji. And after getting the necessary information to draw the emoji correctly its drawn like this:

```lua
game3:push(self.x, self.y + 15, 0, self.springs.emoji.x, self.springs.emoji.x)
  game3:draw_image_or_quad(next, self.x + self.shake_amount.x, self.y + 15 + self.shake_amount.y, 0, sx*self.springs.main.x, sy*self.springs.main.x, 0, 0, colors.white[0], 
    (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
game3:pop()
```

As mentioned above, the `'emoji'` spring is used first to center the emoji's scaling for its own boing effect (which happens when it gets chosen in `arena:choose_next_emoji`), while the `'main'` one is used to make the emoji boing along with the board, such as when the board is clicked by the user. Otherwise the emoji is drawn as you'd expect anything to be drawn.

And that's it for the board class. Like most objects in this game it's ultimately something very simple as it's there just for decoration pretty much. 

### [↑](#table-of-contents)

## Plants

Now going back to the `arena:enter` function, the next line is this one:

```lua
  self:spawn_plants()
```

Like the boards, the plants have no gameplay significance, but they're a good example of several things so it's worth going over their 300~ lines. The plants looks like this:

https://github.com/a327ex/emoji-merge/assets/409773/fff50bf9-1abd-4234-97bd-a724a5fb9cab

As you can see they're spawned both inside the gameplay area as well as on top of the boards. They sway from side to side, and are affected by the pointer as well as emojis passing through them. 

What the plants actually do from a coding perspective is the following: they have some amount of wind constantly being applied to them, when emojis collide to them they also react as though something brushed against them, when the player passes the cursor above them they also react, when the boards move side to side they also have a wind force applied to them, and when an emoji falls near them they also react from the wind of that impact. 

A lot of small details that add to the feeling that the screen is alive, and a lot of them using the same mechanism, which is the plants reacting to some force. The specific way in which they react to these forces is rotating left/right or up/down.

In every emoji prototype I made in the past I used these little plants like this, they're just a nice thing to have that adds to the game. Here's an example for a [Seraph's Last Stand](https://store.steampowered.com/app/1919460/Seraphs_Last_Stand/) clone I was working on earlier this year (click the image):

[![](https://img.youtube.com/vi/AwZO-HVjXyA/maxresdefault.jpg)](https://www.youtube.com/watch?v=AwZO-HVjXyA)

They are ultimately very simple objects, and I'm sure there are simpler ways of doing them than how I did them but my way works. Before getting into the [`arena:spawn_plants`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1167https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1167) function itself, it's better to look at how the [`plant class`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1283) works first:

```lua
plant = class:class_new()
function plant:plant_init(x, y, args)
  self:anchor_init('plant', args)
  self.emoji = images[self.emoji]
  self.flip_sx = self.flip_sx or main:random_sign(50)
  self:prs_init(x, y, 0, self.flip_sx*self.w/self.emoji.w, self.h/self.emoji.h)
```

It's a normal anchor object, it has an emoji for its visual, a position and a scale, and a `.flip_sx` attribute attached to the object's `sx` scale, which will flip the plant's sprite horizontally for some visual variation alone.

```lua
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
```

This sets the plant's position based on its direction. The `.direction` attribute represents which direction the plant object is pointing, and as you can see in-game, the plants are generally pointing up, but they can also be attached to the walls on either left or right, in which case they would be pointing right and left respectively. The plant object should work seamlessly regardless of position, and this makes sure that collider + sprite positions (which are based on the object's `.x, .y` attributes) are aligned correctly. Because this is a decorative object that should have no gameplay effect but it's located inside the gameplay area, it's initialized as a ghost collider.

```lua
  self:timer_init()
  self:hitfx_init()
  self:shake_init()
```

This was already mentioned for another object above; all objects in the arena have these three mixins initialized as they need them. Next:

```lua
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
```

This is where the plant's constructor ends, and where all variables that affect its angle are defined. The plant moves around from side to side as it has forces applied to it, and this is mainly done by changing its `.r` attribute, which is its angle. All the attributes here that end in `_r`, such as `constant_wind_r`, are the amount of angle change applied to the plant by that kind of force. Anything that ends with `_rv` represents the velocity of that angle change, and anything that ends with `_ra` represents the acceleration of that velocity. Constant wind is a force of wind that never ends; moving wind is a force of wind that should be applied by objects that move through the plant with some velocity; and direct wind is an impulse instead of a continuous force.

Now for the update function:

```lua
function plant:plant_update(dt)
  self:collider_update_position_and_angle()
  self:collider_set_awake(true)

  if self.direction == 'up' or self.direction == 'down' then
    self.constant_wind_r = 0.2*math.sin(1.4*main.time + 0.01*self.x)
  elseif self.direction == 'left' or self.direction == 'right' then
    self.constant_wind_r = 0.2*math.sin(1.4*main.time + 0.01*self.y)
  end
```

Like with the buttons, every time the player's pointer passes through a plant it applies a small force to it, just to add a little juice, so the plants also need to be awake every frame, otherwise the player's pointer won't be able to interact with them. Next the plant's constant wind force is set to oscillate according to some sine function that's based on its `.x` position, this makes it so that the plants oscillate like real plants do, as though the wind was passing through them quickly in waves.

```lua
  if self.dying then self.constant_wind_r = 0 end
  self.sx, self.sy = self.flip_sx*self.w/self.emoji.w, self.h/self.emoji.h
  if main.web then return end
```

Every object that has `.dying` set to true is an object that is both grayscale and falling down at the end of the round, so when this is the case the plant isn't affected by any constant wind. And for performance reasons, on the web version of the game I disabled most plant behaviors as it showed up on the profiler as something that was costly. I have no real idea why this would be the case and it's probably something I should look at for next games, but it worked.

```lua
  if self.trigger_active[main.pointer] then
    self:apply_moving_force(main.camera.mouse_dt.x, main.camera.mouse_dt.y, 50*main.camera.mouse_dt:vec2_length())
  end
```

As mentioned previously, if the pointer is touching a plant it applies a force to it. It applies this force using `self:apply_moving_force`, which is one of the functions used for that purpose that will be explained soon. Next:

```lua
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
end
```

And this is where the plant update function ends. This is nothing but some basic velocity + acceleration with damping applied to the plant's angle, for both moving and direct wind forces. Because of the way the `apply_moving_force` and `apply_direct_force` functions work, there needs to be a check that only applies that force if either of those functions has been called recently, and that's what `.applying_moving_force` and `.applying_direct_force` are doing.

There is some raw damping going on here with multiplications by `57*dt` and `58*dt`, which only works because the game's update rate is 60 updates per second. There is a correct way to do damping independent of framerate, but I didn't do it for this because this code is copypasted from years ago and I just haven't bothered to change it yet. I will fix it some day though, I'm pretty sure I already have the function for it in the `math` module somewhere.

Next let's look at the imeplementation of the force functions:

```lua
function plant:apply_direct_force(vx, vy, force)
  if main.web then return end
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
```

As can be seen by the last line in the `apply_direct_force` function, the `.applying_direct_force` attribute is only true for between 0.1-0.2 seconds, which is enough for the plant to quickly move to one side or the other, which gives the impression of a forceful impulse rather than a continuous force. The math for how the force is applied is simple, and what it does is setting the maximum amount of velocity for the moving force. This velocity is then applied to the angle, and the angle is applied when drawing the plant. The `apply_moving_force` function is similar:

```lua
function plant:apply_moving_force(vx, vy, force)
  if main.web then return end
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
```

The only difference between this and the other function is that this lasts for longer, between 0.4-0.6 seconds. The maximum moving force is also quite a lot lower than the direct force, so on top of lasting longer it has a general less aggressive feel to it that correctly captures the feeling of a continuous force being applied to it instead of an instantaneous one. All of these 3 types of forces, constant, moving and direct, are applied visually when the plant is drawn:

```lua
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
```

There's a difference between how the plant is drawn horizontally vs. vertically. I don't remember why exactly this difference is here, but from the code it's clear that drawing the plant horizontally uses two pushes instead of a single one. The first push is centered on the plant's true center and applies the collider's rotation (`.r`), while the second push is centered on the plant's bottom center and applies all wind force rotations. This makes sense given that we want the plant to be rotated around its bottom and not its center, since that will give the correct impression of wind being applied to it (notice how it rotates around the bottom center):

https://github.com/a327ex/emoji-merge/assets/409773/cbe94cbf-61ef-4094-ad23-c4c0c80e0908

Why this needs to be separated out in two pushes when it's horizontal? I honestly don't remember and don't feel like trying to figure it out again. Anyway, in both cases the plant is drawn as every other object in the game is drawn, so there's nothing else special going on here.

And so after the plant object is defined entirely like this, I also do this:

```lua
anchor:class_add(plant)
```

This means that `plant` is going to be used as a mixin instead of a normal object. It will be used as a mixin for the `arena_plant` and `board_plant` classes, which are the plants that are inside the walls and on top of each board, respectively. This is the only instance of code reuse using the mixin system in this game, but this is how I'd do it for more complex games if required.

I mentioned this before, but in general I try to avoid generalization like this while working on the game and prefer to do the generalization work in between projects, but in this case it just makes perfect sense to reuse all the plant code to create different objects that need slightly different behavior (`board_plant` needs forces applied to it based on the board's movement).

```lua
arena_plant = class:class_new(anchor)
function arena_plant:new(x, y, args)
  self:plant_init(x, y, args)
end

function arena_plant:update(dt)
  self:plant_update(dt)
  self:plant_draw()
end
```

The `arena_plant` object doesn't have any special behavior, so it just uses the plant as a mixin. This would be no different than doing something like `anchor('arena_plant'):plant_init(...)`, if the plant's update function wasn't separated between `plant_update` and `plant_draw`. But that separation is there because `board_plant` has special behavior:

```lua
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
```

Let's go block by block:

```lua
board_plant = class:class_new(anchor)
function board_plant:new(board, x, y, args)
  self:plant_init(0, 0, args)
  self.board = board
```

This initializes the plant mixin and `.board` contains a reference to the board object, which is what this plant will be attached to.

```lua
  self.board_ox, self.board_oy = x, y
  self.emoji_type = args.emoji
  if self.flip_sx == 1 and args.emoji == 'sheaf' then
    self.ox = self.ox + 0.21*self.w
  elseif self.flip_sx == -1 and args.emoji == 'sheaf' then
    self.ox = self.ox - 0.21*self.w
  end
end
```

`.board_ox` and `.board_oy` are the offset values for the plant's position in the board's local coordinates. Every frame we'll calculate where the plant should be relative to the board, since its attached to it, and we'll do this by using these offsets which represent that fixed value in the board's local coordinates. `.ox` and `.oy` instead are the plant's offset for rotation position, which only affect the `'sheaf'` emoji. This can be seen more easily with an image:

![sheaf](https://github.com/a327ex/emoji-merge/assets/409773/11ebd748-c2ba-4850-a313-64e24fc87919)

If the sheaf's rotation had no offset it would rotate around its bottom center, but that would be wrong because the base of the emoji isn't in the actual bottom center, it's a little to the side. So the `.ox` offset makes sure that that distance is accounted for.

```lua
function board_plant:update(dt)
  self:plant_update(dt)
  self.constant_wind_r = 0.1*math.sin(1.4*main.time + 0.01*self.x)
  self.x, self.y = math.rotate_point(self.board.x + self.board_ox, self.board.y + self.board_oy, self.board.r, self.board.x, self.board.y)
```

Plant's update function is called, a different constant wind is set (this is smaller/more subtle than the one in the plant mixin), and then `math.rotate_point` is used to set the plant's position based on the board's position. This is a basic rotation of the point `self.board.x + self.board_ox`, `self.board.y + self.board_oy` into another by `self.board.r` degrees, with a pivot at `self.board.x`, `self.board.y`. Doing it this way makes sure that whenever the board object goes from side to side and rotates a little, the plant is always in the same position, which was set by its `.board_ox` and `.board_oy` offsets.

```lua
  local vx, vy = self.board:collider_get_velocity()
  if self.trigger_active[main.pointer] then self:apply_direct_force(main.camera.mouse_dt.x, main.camera.mouse_dt.y, 5*main.camera.mouse_dt:vec2_length()) end
  self:apply_moving_force(-vx, 0, 5*vx)
  self:collider_set_position(self.x, self.y)
```

Here forces are applied to the plant. The first is based on the pointer and it's similar to all other instances where this happens. The second is the force based on the board's movement. If the board is moving in one direction, the plant should have a force applied in the opposite direction to give the impression of wind from the board's movement, that's what the third line is doing. And then `collider_set_position` is used to update the collider's position based on the `.x, .y` position. If this is not done then the collider will never follow the plant's position, since the plant's position is always calculated based on the board's position with `math.rotate_point`.

```lua
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
```

And then after all that the plant is drawn. It has two pushes applied to it, the first attached to the board's angle, and the second to the plant's angle along with all wind forces being applied to it. Nothing that should look too unusual by now.

And so with `plant`, `arena_plant` and `board_plant` explained, we can finally start going over [`arena:spawn_plants`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1167).

What this function does is spawn all plants in the game, just like `arena:enter` spawns all other objects. It's a very simple function, but it's a lot of manual setting of positions. This is the kind of thing that's probably best done with a visual editor, but I don't have a visual editor, so code it is. So let's go over it block by block:

```lua
function arena:spawn_plants()
  local spawn_plant_set = function(x, y, direction)
```

The function starts by defining the internal `spawn_plant_set` function. This function takes in a position and a direction, and spawns a corresponding set of plants. A set of a plants is a group of anywhere between 2 and 5 plants that is close to one another. There's a total of 8 of them, and they look like this:

![love_x5rCoG1Mya](https://github.com/a327ex/emoji-merge/assets/409773/3bc5bf49-12a0-4e8c-8dcb-f7d86c64d2f5)

![love_zm7bu0YTUL](https://github.com/a327ex/emoji-merge/assets/409773/aae4b503-bfb3-4d6f-8d1b-3eac490466c9)

![love_W7tdryCdmg](https://github.com/a327ex/emoji-merge/assets/409773/1ba30a61-a399-4917-a2dc-643634a26cab)

![love_vghceBTCyv](https://github.com/a327ex/emoji-merge/assets/409773/35cbd10a-39ca-485a-9f5b-d3562ce2a637)

![love_gs9vrPCcYo](https://github.com/a327ex/emoji-merge/assets/409773/abefd6b4-179c-4d6d-947c-afbfff41a0f3)

![love_YkoiDbgTJt](https://github.com/a327ex/emoji-merge/assets/409773/5b628b23-1f1d-47e4-945a-0dff29bc4383)

![love_Y25toSw0U8](https://github.com/a327ex/emoji-merge/assets/409773/d30d8bf7-4590-43ad-b393-2696157866db)

![love_bRhXRp6cIY](https://github.com/a327ex/emoji-merge/assets/409773/dfb21dfe-933b-41c7-9e11-87fea560b15b)

Here's what the code for the first of these looks like:

```lua
    local n = main:random_weighted_pick(20, 20, 20, 10, 10, 10, 5, 5)
    local r = (direction == 'up' and -math.pi/2) or (direction == 'down' and math.pi/2) or (direction == 'left' and math.pi) or (direction == 'right' and 0)
    if n == 1 then
      self.plants:container_add(arena_plant(x + 5*math.cos(r - math.pi/2), y + 5*math.sin(r - math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 5*math.cos(r + math.pi/2), y + 5*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game1, emoji = 'sheaf', direction = direction}))
```

First `n` is chosen, which is a value from 1 to 8, with the weights in percentages as they appear in the `random_weighted_pick` function. Then the plant set's angle is set based on the direction passed in to `spawn_plant_set`. And after that we spawn the plants proper. For the first case, 2 plants are spawned 10 pixels apart from each other, the left one is a small seedling while the right one is a bigger sheaf. All the other ones follow a similar format, here's the second:

```lua
    elseif n == 2 then
      self.plants:container_add(arena_plant(x + 5*math.cos(r - math.pi/2), y + 5*math.sin(r - math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 5*math.cos(r + math.pi/2), y + 5*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game3, emoji = 'seedling', direction = direction}))
```

The only thing that changes here are the emojis, as they're both seedlings. Here's the third:

```lua
    elseif n == 3 then
      self.plants:container_add(arena_plant(x + 8*math.cos(r - math.pi/2), y + 8*math.sin(r - math.pi/2), {w = 11, h = 11, layer = game1, emoji = 'sheaf', direction = direction}))
      self.plants:container_add(arena_plant(x + 0*math.cos(r - math.pi/2), y + 0*math.sin(r - math.pi/2), {w = 20, h = 20, layer = game1, emoji = 'seedling', direction = direction}))
      self.plants:container_add(arena_plant(x + 8*math.cos(r + math.pi/2), y + 8*math.sin(r + math.pi/2), {w = 15, h = 15, layer = game1, emoji = 'sheaf', direction = direction}))
```

This one is spawning 3 instead, with each being 8 pixels apart from one another. You get the idea, right? I'm not going go over all of them as they're basically all variations of this and once you understand one you understand them all. And so this is the `spawn_plant_set` function. This function is called multiple times to spawn plant sets across the map, which we'll see next:

```lua
  -- Bottom solid
  local plant_positions = {}
  for x = self.x1 + 25, self.x1 + self.w - 25, 25 do table.insert(plant_positions, {x = x, y = self.y2 - 15, direction = 'up'}) end
  for i = 1, main:random_int(2, 3) do
    local p = main:random_table_remove(plant_positions)
    spawn_plant_set(p.x, p.y, p.direction)
  end
```

This defines a number of positions that are 25 pixels apart from each other along the bottom solid. This same thing is done for the side solids as well, and this is what all these positions would look like if I were to draw a blue circle on each of their centers:

![love_c8utqRvrHl](https://github.com/a327ex/emoji-merge/assets/409773/2dde6c70-c711-4ad5-8793-028aa7481451)

Then, for each solid, it spawns a plant set at 2 or 3 of those positions randomly, without a position being able to be repeated.

```lua
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
```

Because of the way we set up the `spawn_plant_set` function as well as the plant objects with their positions and rotations/directions, all of the code that creates those objects turns out to be simple enough and we don't have to do any math to calculate rotated positions on the plants or anything like that.

After the solid plants are spawned, we spawn plants on top of the 3 boards:

```lua
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
```

This is a bit more involved and doesn't use the `spawn_plant_set` functions, instead spawning plants individually. Remember that `board_plant`'s positions are represented as an offset from the the board's center, and so in this case the positions for all the plants that can be spawned on top of the score board use values based on its center. So, for instance, `-21` means it's a bit to the left, while `21` a bit to the right; `-self.score_board.h/2 - 11` is a bit above the top of the board, and so on.

Some board plants are also spawned with some chance, instead of always spawning. In general, for the score board, you have 2 plants around the center, and then a bunch more to the sides randomly. The same idea applies to the best board:

```lua
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
```

This one has one big plant in the center, then 75% chance for 2 smaller plants on both sides, and then if this 75% was successful, a 50% chance of another set of 2 even smaller plants further out to the sides. The next board follows the same idea:

```lua
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
```

Same thing, one big plant at the center, 2 with 75% chance to the sides, 2 with 50% chance further out if the first 2 were spawned, more 2 with another 50% chance if the previous 2 were also spawned. These chances are run every time the arena starts (remember that this function is being called in `arena:enter`), so each time the game is restarted the plants will look a bit different. So all of this is just a simple way of adding some variation to how the level looks, but it also happens to be a good example of how I'd go about spawning different things.

In an ideal world, most things that are being spawned in `arena:enter`, the plants included, should have their positions set with a visual editor instead of by hand with code like this. But I have not spent time building a visual editor, so I have to do with code alone. I have quite a few ideas for a game editor that would help me with this, but I want to get a few different pieces of technology down before I try it. One of them is a general UI system, which I currently don't have. Another is a cleaner API for most common tasks.

Essentially the game editor idea I have is for an editor where you could make the game entirely with your gamepad, so the constraint is like, 6 buttons not counting directional ones, and the way to achieve this is by having functions that do a lot of very specific things, but having lots of those functions be able to build on each other seamlessly without requiring many traditional coding structures (conditionals, loops, etc). The goal being to maximize muscle memory and be able to do lots of things quickly without having to type anything. But yea, to do that I need to get a bunch of things right from the code side of things first, so no editor until then.

Now, the last plant related function:

```lua
function arena:get_nearby_plants(x, y, r)
  local plants = {}
  for _, plant in ipairs(self.plants.objects) do
    if math.distance(plant.x, plant.y, x, y) < r then
      table.insert(plants, plant)
    end
  end
  return plants
end
```

This is called whenever forces need to be applied around an area instead of when an object collides directly with a plant. For this game, this only happens when an emoji collides with a wall, in which case I simulate a wind force around the collision area to both sides of the emoji. Here's what that looks like, in [`arena:update`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L569):

```lua
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
```

When an emoji collides with a solid, it checks to see if that solid is the bottom one, and if it is then it grabs all plants within a 50 pixels radius from the collision position, and then for all those plants it applies a direct force to them based on their distance from that position. The effect that creates is this:

https://github.com/a327ex/emoji-merge/assets/409773/d0003c9d-bf27-454e-b919-4a902066ae96

Very nice and cool, it's the same process I used for the lightning bolts in the video below:

[![](https://img.youtube.com/vi/AwZO-HVjXyA/maxresdefault.jpg)](https://www.youtube.com/watch?v=AwZO-HVjXyA&t=82s)

This is the only reason why plants need their own container, by the way. I thought I'd use it in more places but it turns out this was the only one. But even if it's only this use it's still fine, since it's useful for `get_nearby_plants` to be able to just directly go over all plants instead of having to first process them from another list.

And that's all the code related to plants.

### [↑](#table-of-contents)

## arena:enter 2

Now we can continue with the rest of [`arena:enter`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L466):

```lua
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
```

"Emojivolution objects" refers to the objects on the right bottom side of the screen. These ones:

![love_GMwSpW02I4](https://github.com/a327ex/emoji-merge/assets/409773/5860d8df-ade1-4a16-870c-851aa5e995d4)

They are there just to show the evolution order for emojis. All of these objects, except for the chain, are `evoji_emoji` objects, which are another one of those objects that are just colliders + the emoji sprite. Here's what the code looks like:

```lua
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
```

Not going to over this again because it's so similar to many of the other objects of this type, but the only thing of note here is that there's an if for if the object is a circle vs. a square. If it's a circle then it's one of the 11 emojis that make up the evolution circle, if it's a square then it's the `images.curving_arrow` emoji that's in the middle of the circle. These colliders have slightly different properties so they need to be handled slightly differently, but everything else is the same.

And I think I already said this, but it bears repeating, this object and all others like it, where it's just a collider, some light interaction with the mouse and the object's sprite as an emoji, could have been merged into a single class that creates a collider as a polygon out of the emoji's shape. This is not a hard procedure to code at all, and it would work perfectly for all of these different use cases where the object acts physically exactly like the shape of its visual. The codebase would have gone from 1700 to 1000 or so lines, probably, had I done this. And I would have done it on a refactor pass if I were to keep working on this game.

Now, let's look at how these objects are created:

```lua
  -- Emojivolution objects
  self.curving_arrow = self.objects:container_add(evoji_emoji(self.next_x, 249, {emoji = 'curving_arrow'}))
  self.evoji_emojis = {}
  local r = -math.pi/4 + (3*math.pi/2)/22
  for i = 1, 11 do
    table.insert(self.evoji_emojis, self.objects:container_add(evoji_emoji(self.next_x + 64*math.cos(r), 249 + 64*math.sin(r), {emoji = value_to_emoji_data[i].emoji, rs = 12})))
    r = r + (3*math.pi/2)/11
  end
```

First, the curving arrow is created. This is a rectangular collider with the curving arrow emoji:

![love_gQB8qUAqAE](https://github.com/a327ex/emoji-merge/assets/409773/81d0d27f-32cc-47fd-ad1b-5c26a445f161)

This object has reverse gravity (see that on creation it calls `collider_set_gravity_scale(-1)`) and is attached to the emojis in the circle by a single chain. The 11 emojis in the circle themselves are created next and stored in the `.evoji_emojis` table, as well as on the objects container. Next:

```lua
  self.joints = {}
  for i, emoji in ipairs(self.evoji_emojis) do
    local next_emoji = self.evoji_emojis[i+1]
    if next_emoji then
      local x, y = (emoji.x + next_emoji.x)/2, (emoji.y + next_emoji.y)/2
      table.insert(self.joints, self.objects:container_add(joint('weld', emoji, next_emoji, x, y)))
    end
  end
```

Joints are created to attach all 11 emojis together. Unlike chains which are created using revolute joints, for this one weld joints are used, since we don't really want the emojis moving relative to each other in any way. The joints are simply created at the midpoint between any two of the 11 emojis, and are stored in the `.joints` table, as well as on the objects container. Next:

```lua
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
```

Next the 3 chains are created. There's one chain created binding the leftmost emoji to the next board, one binding the rightmost emoji to it, and one binding the middlemost emoji to the curving arrow. We already went over the `emoji_chain` class, and the chains here are all instances of it. There's some math done to make sure that the chains are connected at the correct angles with both edge emojis, but this math has already been explained. Refer to the section where I pointed to the BYTEPATH tutorial, since the cos/sin math there is the same as the one being used here. Other than that all of this is straightforward given you already know how `emoji_chain` objects work.

The end result of all that is this:

https://github.com/a327ex/emoji-merge/assets/409773/34d59a3f-54e2-42d4-b7ba-25afd9e5ac62

This is yet another example of the kind of thing that would probably be better done with a visual editor, but since I don't have that it has to be done with code.

Next are the final lines of the `arena:enter` function:

```lua
  self.spawner = self.objects:container_add(spawner())
  self:choose_next_emoji()
```

This creates the spawner object (the hand that drops emojis) and then calls `choose_next_emoji`, which will create one emoji and attach it to the hand, such that when the player presses a key that emoji will be dropped. The `spawner` class is fairly simple and looks like this:

```lua
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
```

This is an object that by itself doesn't do anything, it's just a ghost collider with an emoji visual attached to it. Most of the behavior for the spawner object will be defined in `arena:update`, which is what we'll go over next.

### [↑](#table-of-contents)

## arena:update

The [`arena:update`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L518) function is where most of the gameplay rules are located or triggered due to our decision of modelling the game as a rules-based game. If we have a rules-based game and we want rules to not be attached to objects, they need to be attached to their individual functions, and those functions either happen directly on some update function somewhere when something happens, or are triggered by code that's in the update function. If this doesn't make sense now it will soon, but, when it comes to rules-based code, the update function ends up being the most natural place to place most rules or at least the trigger for most rules' behaviors.

So let's get started:

```lua
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
      local rs_oy = 0
      if self.spawner_emoji then
        if self.spawner_emoji.value <= 3 then
          rs_oy = self.spawner_emoji.rs
        else
          rs_oy = 1.5*self.spawner_emoji.rs
        end
      end
      y_offset = math.remap(main.distance_to_top, 100, 0, 0, -32 - rs_oy)
    end
    self.spawner.x = math.clamp(main.pointer.x - 12, self.x1 + left_offset, self.x2 + right_offset)
    self.spawner.y = math.lerp_dt(5, dt, self.spawner.y, 20 + y_offset)
    self.spawner:collider_set_position(self.spawner.x, self.spawner.y)
  end
```

The first things defined are the rules for the spawner object's movement. There are three different things to take into consideration here, so let's go block by block:

```lua
    local left_offset, right_offset = 0, 0
    if self.spawner_emoji then
      left_offset = left_offset + self.spawner_emoji.rs - 4
      right_offset = right_offset - self.spawner_emoji.rs - 20
    end
```

`left_offset` and `right_offset` are offsets for where the spawner object stops moving on the edges of the play area. The edges of the play area are the two side solids, and you'll notice from the video below that the hand's collider + the emoji it holds are not perfectly centered, which means that when we need different values for left and right side so that it plays correctly. If those values are wrong then whenever an emoji is dropped it will hit one of the side walls and move wrong. Importantly, the offsets are only set if `.spawner_emoji` is true, which will be the case when the hand is holding an emoji.

https://github.com/a327ex/emoji-merge/assets/409773/2b2f9dfb-4fe4-445e-9525-e450be57c838

```lua
    local y_offset = 0
    if main.distance_to_top <= 100 then
      local rs_oy = 0
      if self.spawner_emoji then
        if self.spawner_emoji.value <= 3 then
          rs_oy = self.spawner_emoji.rs
        else
          rs_oy = 1.5*self.spawner_emoji.rs
        end
      end
      y_offset = math.remap(main.distance_to_top, 100, 0, 0, -32 - rs_oy)
    end
```

Next, `y_offset` is defined such that it will be set to a given value if `main.distance_to_top` is lower than 100. What this means is that whenever the `.lose_line` object is showing, and the gameplay area is filled with emojis and the player is about to lose, the hand should be moved up a little otherwise whenever new emojis controlled by the hand appear they will be colliding with the top emojis on the board, and when they're dropped they will not generate any collision enter events.

Because the emoji merging logic, which we'll see soon, relies on collision enter events, the easiest solution is to simply move the hand up, which is what this section of the code does. Another possible solution would be to check for collisions every frame manually and merge the ones that can be merged, but that would be a bit more work to code than just changing the hand's position.

```lua
    self.spawner.x = math.clamp(main.pointer.x - 12, self.x1 + left_offset, self.x2 + right_offset)
    self.spawner.y = math.lerp_dt(5, dt, self.spawner.y, 20 + y_offset)
    self.spawner:collider_set_position(self.spawner.x, self.spawner.y)
  end
```

And the final piece of code here simply sets the spawner's `x` and `y` positions according to what I just described. `x` follows the pointer's position and is clamped by `.x1` + the left offset and `.x2` + the right offset. `y` has a set position at `y = 20`, which is then offset by some value if the game is close to ending. The `y` position is also moved using `math.lerp_dt`, which gives it a nice and smooth movement over multiple frames. This is what all that looks like:

https://github.com/a327ex/emoji-merge/assets/409773/ee6fdc5d-a148-40d0-828e-3c1a6186978d

Next the spawner's emoji:

```lua
  -- Spawner emoji movement
  if self.spawner_emoji and not self.spawner_emoji.dropping and not self.round_ending then
    local o = value_to_emoji_data[self.spawner_emoji.value].spawner_offset
    self.spawner_emoji:collider_set_position(self.spawner.x + 12 + o.x, self.spawner.y + o.y)
    if main:input_is_pressed('action_1') and not main.any_button_hot then
      self:drop_emoji()
    end
  end
```

This is very simple and takes care of all logic for `.spawner_emoji`, which is the emoji attached to the hand and that is about to be dropped. This emoji follows the hand's movement, and you can see that by how `collider_set_position` is used to set its position to the spawner's position + some other values (those values are offsets based on the emoji's size). After setting the position it only checks if the left mouse button has been clicked (and if no buttons are currently being hovered over), and if it has then it calls [`arena:drop_emoji`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L702), which looks like this:

### [↑](#table-of-contents)

## arena:drop_emoji

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

The first block does something that was already mentioned elsewhere, which is making both the hand and the emoji it's holding go boing, but having that be centered around their midpoint. `.drop_x, .drop_y` for both objects refers to the point to use as the center for this particular type of scaling, and then `hitfx_use('drop'` makes the effect actually happen. Additionally, the spawner's emoji is changed to `images.open_hand` and then 0.5 seconds after it's changed back to `images.closed_hand`, to properly give the feeling that the emoji that was being held was dropped.

The second block actually does the job of dropping the emoji. Its gravity scale is set to 1, `.dropping` and `.has_dropped` are set to true (what they do will be shown soon), and `collider_apply_impulse` is called with a small downwards value otherwise the emoji won't move from its previously resting state. Then there are two functions defined that will eventually call `arena:choose_next_emoji`, which is the function that both spawns the emoji that was in the next board to the hand, as well as choose the next next emoji to be shown on the next board.

The first function is `observer_condition`, which as already explained in the [timers and observers](#timers-and-observers) section, calls the given function whenever the condition becomes true. In this case the condition its looking for is if the dropped emoji hits a wall or another emoji, in which case the `choose_next_emoji` can be called. This is how Suika Game works as well, if you play it yourself. This is also a good example of rules-based + highly local code, as this thing that happens many frames in the future is coded right here, contained in the single function that is most pertinent to it.

The other function, `timer_after`, is a fallback in case the observer one doesn't trigger. If it doesn't trigger, for whatever reason, then after `1.4` seconds it will call `choose_next_emoji` anyway, otherwise the player wouldn't have another emoji to drop and would be soft locked. This is why this timer is called `'drop_safety'`, and this timer, along with the `'drop_emoji'` observer, is cancelled whenever `choose_next_emoji` is called, since if that function is called it means the precaution isn't needed anymore. This is yet another example of rules-based local code, everything needed to make the emoji dropping functionality work is here, except for part in `arena:update` that calls `arena:drop_emoji` initially. But that's a reasonable break of locality that would be too unnatural to try to achieve otherwise.

### [↑](#table-of-contents)

## arena:choose_next_emoji

Since we're talking about `arena:choose_next_emoji`, it makes sense to go over it quickly:

```lua
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
```

A lot of the code here is fairly similar to the code in `arena:drop_emoji`, since it's mostly about doing the boing visual effect on the hand + on the emoji to be dropped. The only real new lines here are the last two ones, which are actually doing the work of choosing the next emoji, and that work consistents of choosing a value from 1 to 5 and setting that value to the `.next` variable. If you go to the [board class](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L976) you'll see that it refers to this variable when drawing the next emoji on the board:

```lua
local next = main.level.next
```

This `arena` is the current level, so it can be accessed by `main.level`, and then any variable set to it can be accessed normally. So the `.next` attribute is chosen using `random_weighted_pick`, which is a function that returns an index based on the probabilities given. For instance, `main:random_weighted_pick(50, 50)` will return 1 50% of the time and 2 50% of the time. `main:random_weighted_pick(1, 1, 1)` will return 1, 2 or 3 33.3% of the time each. So in the case of `arena:choose_next_emoji`, `main:random_weighted_pick(30, 25, 20, 15, 10)` will return: 1 at 30%, 2 at 25%, 3 at 20%, 4 at 15%, 5 at 10%. This means that whenever a new emoji is chosen, there's always a higher chance of choosing the smaller emojis above the bigger ones. I don't know exactly if this is how it works in Suika Game, but it seems like there is some weighting smaller emojis being spawned more, so I also did it.

### [↑](#table-of-contents)

## arena:merge_emojis

Next, we have the merging of emojis in [`arena:update`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L552):

```lua
  -- Merge emojis
  for _, c in ipairs(main:physics_world_get_collision_enter('emoji', 'emoji')) do
    local a, b = c[1], c[2]
    if not a.dead and not b.dead and a.has_dropped and b.has_dropped then
      if a.value == b.value then
        self:merge_emojis(a, b, c[3], c[4])
      end
    end
  end
```

This is a fairly straightforward checking of collision enter events between two colliders of the `'emoji'` type, and then calling `arena:merge_emojis` on them if multiple conditions are true. The first condition is that both objects aren't dead; this is to prevent the calling of the merge emojis function multiple times in odd situations. The second condition is that both objects have their `.has_dropped` attribute set to true; this attribute gets set to true whenever an emoji is dropped by the `arena:drop_emojis` function we just covered, and if one of the emojis hasn't dropped yet, like when it's being held by the hand, then it won't trigger a merge event. The third and final condition is that both emojis must have the same `.value` attribute, given the rule in Suika Game that balls only merge with balls of the same size as them. The [`arena:merge_emojis`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L742) function looks like this:

```lua
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
```

Let's go block by block:

```lua
function arena:merge_emojis(a, b, x, y)
  if self.round_ending then return end
  a.dead = true
  b.dead = true
  self.objects:container_add(emoji_merge_effect(a.x, a.y, {emoji = a.emoji, r = a.r, sx = a.sx, sy = a.sy, target_x = x, target_y = y}))
  self.objects:container_add(emoji_merge_effect(b.x, b.y, {emoji = b.emoji, r = b.r, sx = b.sx, sy = b.sy, target_x = x, target_y = y}))
```

When two emojis merge we want the old objects to die and then we want to create a new one around their center. We want this to look like both emojis are merging too, so they have to move close together until they become one. Except our emoji colliders are solids that can't go inside one another, which means that to do this effect we need to do it visually only, and despawn/spawn emoji objects according to how far into the effect we are. So the first thing this code does is destroy the two emojis merging by setting their `.dead` attribute to true. Then we spawn two `emoji_merge_effect` objects in each of the collider's position, with a target position of `x, y`, which is where the two emojis collided in the first place. The `emoji_merge_effect` object looks like this:

```lua
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
```

It's a very simple object that only exists visually and matches the visuals of the emoji it replaced. With the `timer_tween` call it also moves towards its target position. In practice this is what the merging looks like:

https://github.com/a327ex/emoji-merge/assets/409773/4941eaf3-660e-4c4c-bece-6f8dde701e8e

It's hard to see properly at normal speed, but here's roughly the same effect, except if it took 0.5 seconds to happen instead of the 0.15 seconds it does:

https://github.com/a327ex/emoji-merge/assets/409773/fabb9fde-0d63-43d2-ba07-feb62a4986d4

The only thing different in this slower case is that I forgot to change the flashing effect, so it still flashes for only 0.15 seconds. In any case, the emojis that move closer to each other and slowly decrease in size are the two `emoji_merge_effect` objects. The rest of the effect is coded like this:

```lua
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
```

If the emojis being merged are not the biggest ones (two sunglasses), then the rest of the effect happens. And the effect creates a `merge_object`, which is a locally defined object built for the purpose of creating the new emoji collider 0.15 seconds after the `arena:merge_emojis` function is called. This is because the act of moving the two `emoji_merge_effect` visuals together takes 0.15 seconds (you can see in their `timer_tween` call), and so we only want to create the new merged emoji after that duration.

The new emoji is created with a few specific settings to say that it was created from the merge event, and we'll discuss those settings when we go over the `emoji` object (soon). But more pertinently, there's an important reason why the merge effect uses a locally defined `merge_object` construct to happen, instead of anything else. Consider the normal alternative, which is using `main:timer_after` to do the 0.15 seconds delay. In this case, 99% of the time it will work just as it works now, after 0.15 seconds the merge will happen and the new emoji object is created just fine.

But in 1% of cases, like when a merge happens right before a round ends, the guard we have at the top of the `arena:merge_emojis` function, the `if self.round_ending then return end` line, will not be triggered because the round hasn't ended yet, yet we'll add a `timer_after` for 0.15 seconds later, which means that now our emoji is created after the round has ended, and as we'll see in the `arena:end_round` function, this can lead to all sorts of issues. So what we actually want is for the emoji merging effect to be contained to the `arena` object, especifically to be contained to the `objects` container (although it could have been any of the other containers), since if that's the case, then whenever the container is deleted, the `merge_object` will also be deleted, and thus the `timer_after` call attached to it also will, and thus we won't get merges happening in odd conditions.

This situation is an example of two things. The first is the kind of care you have to have while using timers. If you use timers incorrectly, if you don't tag them properly and cancel tags correctly, or if you attach a timer to the wrong object, you'll get into these odd bugs that happen rarely but that can totally break the game in one way or another. SNKRX was full of these bugs, eventually I fixed most of them, but this is definitely a big drawback that comes with using the timer/observer constructs. I said so in the engine section, but this is great example of how it plays out practically.

And the second thing this situation is an example of is how useful it is to have the mixin setup we have. Note that the `merge_object` construct is a new type of object entirely, but because it's only used here, it can be created completely locally as an anchor object with a timer mixin, and everything just works fine. This kind of flexibility of being able to create objects to do these kinds of things across time, and to be able to do that fully locally, is one of the best examples of why I really like this mixin + god object setup with the anchor objects.

Now, there are a few extra lines in `arena:merge_emojis`:

```lua
  local added_score = value_to_emoji_data[a.value].score
  self.score = self.score + added_score
  self.chain_amount = self.chain_amount + 1
  self:timer_after(1, function() self.chain_amount = 0 end, 'chain_amount')
```

The first two increase the score by the amount this merge is worth. The second two are dead code that I forgot to remove. At some point I added the ability for score to increase more based on previous recent merges, and that was counted with the `chain_amount` variable. As you can see, it increases by 1 with each merge, but then resets to 0 with 1 second passes, meaning it would give extra score to merges that happened close together, in sequence, but not if they happened seconds apart from each other.

```lua
  if a.value == 11 and b.value == 11 then
    sounds.final_merge:sound_play(0.5, main:random_float(0.95, 1.05))
  end
```

And finally, if a merge happens but the two emojis merging are sunglasses, the biggest emojis possible, no new emoji is created and simply plays a different sound. This is the behavior of the original Suika Game as well, where if you merge two watermelons they just disappear.

### [↑](#table-of-contents)

## Roguelite tangent

emoji merge is a fairly small game, so the amount of knowledge it can pass is limited. It covers some common things that happen in most games, but lots of them are still missing. One important one is how to handle LOTS of event types. For instance, consider that emoji merge was a roguelite, and it was such that there were hundreds of different types of emojis, and whenever any 2 of them merged, it would have a different effect. If you have 100 emojis alone, then you have around 5000 possible effects. How to handle such a large number?

And my answer is that in this particular case, where you have 5000 possible different merging effects, you'd simply have a huge if/else statement inside the `arena:merge_emojis` function, each case handling each different type of merge possible as highly locally as possible. In lots of cases it would be unwise to handle what a particular effect needs to do entirely locally, so it's fine to have some things happen elsewhere, but the primary goal would be for it to happen locally.

This decision perhaps sounds odd, but it actually is the simplest thing you can do. The alternatives, which I've done many types in the past, and it was always a mistake, of trying to deal with this complexity by creating some clever system of abstractions around it, or creating a single file for each possible merge event, or any other number of non-local things you might want to do, they're always wrong because they're trying to obfuscate what's actually happening. What's actually happening is that when two emojis merge, you have 5000 possibilties based on which emojis are merging, so there's absolutely no need to hide that fact from yourself. This is just how it goes for these types of games.

You can arrange things inside the `arena:merge_emojis` function such that you'll repeat code less. You can group certain types of effects together, you can take the results from other systems that might apply to multiple merge events and place them in the scope above any one single event. Just because you're doing everything here it doesn't mean you can't make things better for yourself, but anything more than that is too much. If you look at SNKRX's codebase you'll find this often. Just places where there are these huge if/else chains where lots of things happen. Those are not that way by mistake, or because I don't know how to code, or because I'm lazy. Those are very intentionally that way because it's the best way to do it.

And it's the best way to do it because it's both simple and fast. It's simple because it's local + it doesn't have unnecessary abstractions to it, it's fast because to add a new effect, all you have to do is copypaste a similar effect that's nearby and change it to do what you want. Doing things this way is fast, it allows you to ship code quickly, and it works. It's just what makes the most sense to do. 

While emoji merge itself doesn't have good examples of handling this type of code, this is my explanation for how I'd do it. This is an important thing to know how to handle if you wanna make games with lots of items/abilities/etc to them, and I think that my solution is pretty good. It's worked out well for me so far, so at least it's not actively that bad.

### [↑](#table-of-contents)

## arena:end_round

Next in the `arena:update` function:

```lua
  -- Apply moving force to plants
  for _, c in ipairs(main:physics_world_get_trigger_enter('emoji', 'plant')) do
    local a, b = c[1], c[2]
    local vx, vy = a:collider_get_velocity()
    b:apply_moving_force(vx, vy, 0.5*math.abs(math.max(vx, vy)))
  end
```

This applies forces from emojis to plants using the `plant:apply_moving_force` function. We already described plants before so it should be easy to understand. Next:

```lua
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
```

This is what triggers the `arena:end_round` function. First, let's look at what the round ending actually looks like:

https://github.com/a327ex/emoji-merge/assets/409773/05421943-e39e-44e7-bc2e-411ff7c8c9ce

A lot of things happening. But in sequence, roughly: an emoji goes over the red line and stays there for a while, objects shake and turn to grayscale in sequence, once all objects are gray then chains start disconnecting and objects start falling, after all objects have fallen the score + retry button appear from the sides of the screen. It's an involved process, but it's ultimately just a bunch of things happening in sequence. These can be either achieved with timers, or with observers if the next trigger on the sequence is based on something other than time.

But now let's go back to the update function. This is where all of this gets triggered. Every frame, the first block finds the topmost emoji that isn't the emoji being held by the hand, and then calculates `main.distance_to_top`, which is the distance from that emoji to the top of the arena (where the red line is). `main.distance_to_top` is used in multiple places in the codebase, and I think most of them have already been explained.

The second block actually does the check for the round ending condition: for all emojis, if an emoji is above the top limit of the arena (`self.y1`), and that emoji is not the one being held by the hand, and it's not dead, and it's not dropping, and it hasn't been merged recently, then the [`arena:end_round`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L772) function is called. This function is fairly big, so we'll go over it block by block. But remember that all this function is doing are the steps described 2 paragraphs above this one.

```lua
function arena:end_round()
  if self.round_ending then return end
  self.round_ending = true

  main:music_player_stop()
  sounds.end_round:sound_play(1, main:random_float(0.95, 1.05))
```

`self.round_ending` is set to true here, and you'll see that in many places in the codebase this variable is checked. This is because there are lots of things we don't want to do if the round is ending, since it would mess up the sequence of events that follows. Here the music is also stopped, and a particular round ending sound is played.


```lua
  self:observer_cancel('drop_emoji')
  self:timer_cancel('drop_safety')
  for _, object in ipairs(self.merge_objects) do object:timer_cancel('merge_emojis') end
  self:timer_cancel('lose_line')
  main.lose_line:observer_cancel('active_true')
  main.lose_line:observer_cancel('active_false')
  main.lose_line.color.a = 0
  main.lose_line.active = false
```

Next the observer and timer from the `arena:drop_emoji` function are cancelled, so that `arena:choose_next_emoji` isn't called while the round is ending. Then all merge objects have their timers cancelled as well, so that no new emoji colliders are created while the round is ending. Note that if we had a merge queued up on the `main` object, we could also cancel it here, but then we'd only be able to have one merge happening at a time, as in, if two merges happened right before the round ended, then another merge would fail to get cancelled, and thus we'd have problems. So we instead have a list of all merges as objects, and then we cancel each one individually.

All `'lose_line'` timers and observers are also cancelled here, and the lose line's color is set to transparent, and it's active state set to false. This means that whatever happens, the lose line object's state won't change anymore, which is what we want, since we don't want the lose line showing up while the round is ending. Next:

```lua
  if self.score > self.best then self.best = self.score end
  main.game_state.best = self.best
  main:save_state()
```

Here we just save the player's score this round to the best score, if it was higher than the previous best score. And regardless of which it was, all game state is saved to a file here as well. Next:

```lua
  local top_emoji = self.emojis:container_get_highest_object(function(v) return v.id ~= self.spawner_emoji.id end)
  local objects = {}
  for _, object in ipairs(main.objects) do
    if object:is('board') or object:is('solid') or object:is('emoji') or object:is('plant') or object:is('chain_part') or object:is('evoji_emoji') or object:is('spawner') then
      table.insert(objects, object)
    end
  end
  table.sort(objects, function(a, b) return math.distance(top_emoji.x, top_emoji.y, a.x, a.y) < math.distance(top_emoji.x, top_emoji.y, b.x, b.y) end)
```

This is where the round ending behavior actually starts. First, we find the topmost emoji that isn't an emoji beind held by the hand. Then, for all objects (using `main.objects`, which automatically gets populated with any and all objects that are added to any container), we add them a local objects list if they are of the types described in the conditional there. Those objects are then sorted according to their distance to the top emoji. This is because we want to gradually turn all objects gray, and by sorting them this way it creates a nice effect that ripples out from the emoji that caused the loss.

```lua
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
```

This next section does as the comment says, it turns all objects into black and white by setting their `.dying` attribute to true. If you CRTL+F `.dying` you should find that it appears a lot whenever an object is drawn, and especially if it is true then it will apply the grayscale shader to whatever is being drawn.

As mentioned above, the objects get turned to grayscale gradually, starting to the topmost emoji that was responsible for the loss. And this effect is achieved by simply going over the `objects` list and setting each object's `.dying` attribute to true with a small delay based on the object's position on that list. To do this the code above uses `timer_every`, which calls the given function every n seconds. In this case, `timer_every(0.02` will call the function defined every `0.02` seconds. Additionally, we want to call the function only for however many objects there are in the `objects` table, which is why the last argument to `timer_every` is `#objects`, since that limits how many times the function defined to it is called.

Another way of achieving the exact same goal would be like this:

```lua
for i = 1, #objects do
  self:timer_after(0.02*(i-1), function()
    ...
  end)
end
```

In this example, instead of using `timer_every` with a limit on the number calls, we use a for loop and for each iteration of the loop we define a `timer_after` function with a delay based on the iteration. It achieves exactly the same goal, except it creates `#objects` `timer_after` calls and closures, which is more expensive than just a single one with `timer_every`.

In any case, the actual code is simple:

```lua
  local i = 1
  self:timer_every(0.02, function()
    local object = objects[i]
    if object.dying then return end
    object.dying = true
```

This starts the `i` index at `1` outside the scope of the `timer_every` function, and this index will be increased by 1 each time the function is called. Because of the way closures work, the inner function has access to the scope above it, which means that this kind of thing works as you'd expect it to. Because we have the index, we can use it to get each object and then set its `.dying` attribute to true. This will happen for one object per 0.02 seconds.

```lua
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
```

The rest of the function does a few things. First it plays a sound for each object being grayscaled. This sound isn't played on the web version because for some reason, I don't know why exactly, it was leading to performance issues. Then, after the sound is played, depending on the object we both boing it with `hitfx_use` and shake it with `shake_shake`. This particular part of the code is why every object in the game is initialized with both the hitfx mixin as well as the shake one, since this needs to happen to them eventually. And finally, before the function ends, the index is incremented.

This is the simplest way of doing what needs to be done here. And notice, again, how everything is very highly local. This code is happening across many frames and all the code needed for it is here.

```lua
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
```

I believe the first block was already explained elsewhere, but it turns all background objects to grayscale as well, since some of those are blueish when the game is going on. The second block uses `timer_run` to make sure that all objects stop moving, and it achieves this by setting them to sleep with `collider_set_awake(false)`. If this isn't done, then it's possible that some objects will collide with other objects and move outside the arena or in an otherwise undesirable way, so this prevents that.

```lua
  -- Make all objects fall
  self:timer_after(0.02*#objects + 0.5, function()
    self:timer_cancel('prevent_dying_movement')
    sounds.end_round_fall:sound_play(1, main:random_float(0.95, 1.05))
```

These next blocks of code are the ones that make all objects fall. This process is a multi-step one where things happen in a specific order, all orchestrated by `timer_after` calls. For instance, in the block of code above, the function is called `0.02*#objects + 0.5` seconds after `arena:end_round` was called, which means that it happens after 0.5 seconds from when all objects have been turned gray, since previously we made all objects turn to grayscale 0.02 seconds at a time. And so this function starts by first cancelling the timer that prevented objects from moving, since now they need to fall, and then a sound is played to signify that objects will start falling.

```lua
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
```

This next block of code removes various joints from the game randomly within 0-0.8 seconds. Visually, this gives the effect that things are crumbling instead of simply falling, which is a cooler effect. Let's go removal by removal:

```lua
local solid_joints = {self.solid_left_joint, self.solid_right_joint}
main:random_table_remove(solid_joints):joint_destroy()
self:timer_after({0.4, 0.8}, function() main:random_table_remove(solid_joints):joint_destroy() end)
```

This takes both solid joints and removes both of them. Solid joints are the ones connecting left wall + bottom solid and right wall + bottom solid. One joint is removed immediately, while the other is removed 0.4-0.8 seconds later.

```lua
self:timer_after({0.6, 0.8}, function() self.best_chain:remove_random_joint() end)
```

`.best_chain` is the single chain that connects the best board with the score board. This line of code simply removes a random joint from it by calling `remove_random_joint`, and does it after 0.6-0.8 seconds from when then object falling anonymous function is called.

```lua
local score_chains = {self.score_left_chain, self.score_right_chain}
self:timer_after({0, 0.8}, function()
  main:random_table_remove(score_chains):remove_random_joint()
  self:timer_after({0.4, 0.8}, function() main:random_table_remove(score_chains):remove_random_joint() end)
end)
```

Score chains are the two chains connecting the score board to the offscreen top solid. A random joint from one of the chains is removed after 0-0.8 seconds, and a random joint from the other chain is removed 0.4-0.8 seconds after that. Note that in all these cases we have a list of chains, in this case `score_chains`, and then we use `random_table_remove` to remove a random chain from in a non-repeating manner, since now the list doesn't have that chain anymore and whenever we call `random_table_remove` again it will give us one that wasn't used before.

```lua
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
```

And finally, these last lines of code here remove random joints from the chains on the right side of the screen. The code is pretty much the same as before, just applied to a different set of chains. All of these chains are broken in a 0-0.8 seconds interval randomly, so it gives the effect that things are gradually falling apart.

The next blocks of code apply impulses to all objects based on their type, to make them fall in a specific way that's appropriate for that type of object. In general, here an object's gravity scale is set to some value so that it's affected by gravity; a linear impulse is applied to make it fall; and an angular impulse is applied to make it spin a little. That's essentially it! So let's go type by type:

```lua
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
```

For all solids, depending on which solid it is something slightly different will happen. If it's the left one then it will have an impulse applied to its left, at some point that is slightly above its center. This will make the left solid fall in a way that looks like the arena sort of opened up... if that makes sense? The same happens to the right solid, except the impulse is applied to the right instead. And for the bottom solid it simply falls without any impulse. For all solids, because solid colliders are static, we use `collider_set_body_type('dynamic')` to enable them to actually be affected by forces and move.

```lua
elseif object:is('emoji') then
  local mass_multiplier = 4*object:collider_get_mass()
  object:collider_set_gravity_scale(main:random_float(0.8, 1.2))
  object:collider_apply_impulse(mass_multiplier*main:random_float(-20, 20), mass_multiplier*main:random_float(-40, 0))
  object:collider_apply_angular_impulse(mass_multiplier*main:random_float(-4*math.pi, 4*math.pi))
```

The next object type are the emojis. Emojis have both impulse and angular impulse applied to them based on their mass. Heavier emojis will have more force applied otherwise the forces wouldn't affect them as much. For all emojis they're either pushed left/right, and with a slight movement up before falling. This gives them a little bump effect that looks nice.

```lua
elseif object:is('spawner') then
  object:collider_set_gravity_scale(main:random_float(1, 1.2))
  local vx = main:random_float(-40, 40)
  object:collider_apply_impulse(vx, main:random_float(-60, -20))
  object:collider_apply_angular_impulse(-math.sign(vx)*main:random_float(-24*math.pi, -8*math.pi))
```

The spawner hand is about the same as the emojis, just a force left/right with a slight bump up. It has more angular impulse than the emojis comparatively which makes it spin more as it falls, but that's about the only difference.

```lua
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
```

And the plants are the last ones. Their gravity scale is set to a comparatively smaller value, the forces applied to them are also fairly small, but the rotation is fairly big. This is because I wanted the plants to look like they were getting sort of ripped from the solids they were standing on, but then they should quickly disappear instead of falling like every other object. To me, this looked better, so it's what I did. And this disappearing is achieved by the last couple of lines:

```lua
object:timer_after({0.2, 1}, function()
  object:timer_every(0.05, function() object.hidden = not object.hidden end, 7, true, function() object.dead = true end)
end)
```

This is the general way that I do blinking object removal for every game. `timer_every(0.05`, repeat this around 7-8 times, and each time set the object's `.hidden` variable to its previous opposite. This will make the object blink, and then once the blink is done after 0.35-0.4 seconds the object can be killed. 

And that concludes the part of `arena:end_round` that deals with making objects fall. After that there's only one thing left, which is spawning the score + retry button:

```lua
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
```

This part starts after `0.02*#objects + 3` seconds, which is enough time for all objects to have fallen off the screen. Then `.score_ending` is set to true, which signifies we're in this particular portion of the round ending function. This will be useful later as we continue going over the `arena:update` function.

Then the score is spawned. The score is nothing but a `text_roped_chain` object with the actual score as its text. So if the score is 1374, then the `text_roped_chain` object will be created with a string that says "score 1374", and it will create letter emoji colliders for each character, and link them together with chains. The way `.final_score_chain` is impulsed and moved was already explained when the `text_roped_chain` class was first explained, so refer to that for further information.

Next, the retry button is created. It's a simple emoji collider that is created on the right side of the screen and is impulsed to the left. After 4 seconds its damping gets set to some value that makes it stop moving. This is the same as how the `.final_score_chain` object works. Additionally, however, the retry button has a `text_chain` object attached to it that says `'retry'`. A `text_chain` is nothing but a chain of emoji letters, except without any chain parts in between them. The code for that looks like this:

```lua
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
```

This looks pretty much the same as all other chain-like objects, so I'm not going to explain it. The only difference is the `flash_text` function, which makes each part of the chain flash white in sequence. This gets called whenever the retry button is pressed, as just an extra added effect for fun that looks like this:

https://github.com/a327ex/emoji-merge/assets/409773/96c4c588-4beb-4304-adfd-870827b3a31e

But yea, the retry button is created, then the retry chain is created and attaches itself to the retry button:

```lua
self.retry_chain = self.objects:container_add(text_chain('retry', self.retry_button, self.retry_button.x + self.retry_button.w/2, self.retry_button.y, 16))
```

`.retry_button` is `collider` inside the `text_chain` constructor, and so the attachment happens when that collider has a joint created between it and the first chain part:

```lua
table.insert(self.joints, main.level.objects:container_add(joint('revolute', collider, self.chain_parts[1], x, y)))
```

And yea, that's it for the `arena:end_round` function. Now we should continue with the rest of `arena:update`.

### [↑](#table-of-contents)

## arena:update 2

The next block of code in `arena:update` has to do with applying forces to colliders with the mouse in the score ending section (the one we just covered). This code is an exact copypaste from the code that was explained in the `title:update` function, so I'm not going to explain it over again, but here it is:

```lua
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
```

Next, there's code pertaining to the functioning of the retry button, block by block:

```lua
  -- Retry button
  if self.score_ending then
    if self.retry_button.trigger_active[main.pointer] then
      self.retry_button.hot = true
    else
      self.retry_button.hot = false
    end
```

This sets retry button's `.hot` attribute to true or false based on the pointer's position. This is similar to code for many other objects in the game.

```lua
    if self.retry_button.hot and not self.retry_button.pressed and main:input_is_pressed'action_1' then
      sounds.end_round_retry_press:sound_play(1)
      self.retry_button.pressed = true
      self.retry_button:hitfx_use('main', 0.25, nil, nil, 0.15)
      self:timer_after(0.066, function() self.retry_chain:flash_text() end)
```

Next we start doing what happens when the button is pressed. First a sound is pressed, the button goes boing and flashes with `hitfx_use`, and the retry chain also flashes as `flash_text` is called for it. Next:

```lua
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
```

And then finally the transition starts. This is a transition from this arena object to this same arena object by calling `main:level_goto('arena')`. All this transition does is call `arena:exit`, run the garbage collector so all unreferenced things are collected (this is not necessary, but I did it anyway and I left it that way because I was checking for leaks), then it calls `arena:enter` again and the round starts anew.

The transition proper starts after `0.066*7`, which is how much time it takes for the "retry" chain attached to the retry button to flash white. After that happens, the `main.transition_rs` variable is tweened up to `0.75*main.w` over 0.8 seconds. This variable is used to draw a circle on top of everything, as seen in the [`update`](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L323) function:

```lua
if main.transitioning then ui2:circle(main.w/2, main.h/2, main.transition_rs, colors.blue[5]) end
```

It stays at its the highest value possible and covers the whole screen, and then after 0.4 seconds the transition actually happens by calling `main:level_goto('arena')` and then tweening the circle back down to 0. `level_goto` looks like this:

```lua
-- Changes to the target level. The current level (.level) has :exit called on it, and the new level has :enter called on it.
-- This reuses the level object that was already in memory and doesn't create it anew.
function level:level_goto(name, ...)
  if self.level and self.level.exit then self.level:exit(...) end
  collectgarbage("collect")
  -- print(collectgarbage("count")/1024, #main.objects, #main.world:getBodies(), #main.world:getJoints())
  self.level = self.levels[name]
  if self.level.enter then self.level:enter(...) end
end
```

And as I said before, it calls this level's `exit` function, collects garbage, and then calls `enter` for it. `arena:exit` looks like this:

```lua
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
```

And this is just, for every object that was assigned a variable in the arena object, that is set to nil so that it can be collected when the level changes. The 3 containers also have `container_destroy` called on them, which also deletes all box2d objects from `main.world`. And the `main` container also has `container_remove_dead_without_destroying`, which removes additional references to any object that was still alive and being referenced there. And then after this happens `arena:enter` is called again, and a new round starts.

The way the `level` mixin works is very particular for this game. Other games might need slightly different setups, but this is what I decided to do for this game and I decided to do it last, so it's in no way something solid that's going to remain like this forever or anything like that. Just something to keep in mind in case you're wondering why this works the way it does. For instance, instead of reusing this arena object, I could have instead made it so that the level mixin creates a new one from scratch every time. It functionally would be no different, but it would differ implementation-wise.

And that's it for the transition. Next are the last few blocks of code for the `arena:update` function:

```lua
  --[[
  if main:input_is_pressed'2' then
    self:end_round()
  end
  ]]--
```

This is just some commented code that I uncomment whenever I wanted to test the round ending function, since pressing a button is faster than playing a round through to the end.

```lua
  self.emojis:container_update(dt)
  self.plants:container_update(dt)
  self.objects:container_update(dt)
  self.emojis:container_remove_dead()
  self.plants:container_remove_dead()
  self.objects:container_remove_dead()
end
```

And this is the very end of `arena:update`, where all 3 containers get updated and have objects whose `.dead` attributes are true removed. Every container should have its `container_update` function called manually by the user like this, as well as its `container_remove_dead` function. I've tried many different setups before and I really don't like ones where object updating happens automatically somehow. I can't quite figure out why, because the engine does a lot of things automatically, but for some reason I really feel like it's important that, if I want things to be updated/drawn, I should call functions to make that happen otherwise it doesn't. Probably something about explicit code being better than implicit code...

But yea, this marks the end of the `arena:update` function. There are only around 100 lines of code left to cover, so let's go over those next!

### [↑](#table-of-contents)

## emoji

The emoji object is like many other emoji collider objects in that most of the code for what's happening with it is elsewhere, in a rules-based manner. Because of this it's a fairly small and standard amount of code. Let's go over it block by block:

```lua
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
  self:collider_set_sleeping_allowed(false)
  self:timer_init()
  self:observer_init()
  self:hitfx_init()
  self:shake_init()
```

This initializes the object as a collider. Most variables from the `value_to_emoji_data` table are also initialized in their appropriate place here. `self.stars` refers to the number of stars that are created whenever this object merges with another, and `.mass_multiplier` is how heavy the object is relative to its size. Based on Suika Game rules, the smaller emojis are heavier for their size than the bigger ones.

```lua
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
```

These are a few different conditionals that will do different things based on how the object is created. When the object is created from a merge, both `.hitfx_on_spawn` and `.from_merge` are set to true. When `.hitfx_on_spawn` is true it does just that, it calls `hitfx_use` on the `'main'` spring that is attached to the emoji's scale, making it move and also flash for 0.15 seconds. This flashing makes an emoji that was just created from a merge white, which looks like this:

https://github.com/a327ex/emoji-merge/assets/409773/c862c9ec-4297-43ec-931b-d47148df8307

The `.from_merge` attribute makes it so that whenever this emoji spawns from a merge, a few star particles also spawn around it. The number of stars depends on how big the emoji is and is defined by the `self.stars` value. If you look at the video above you can see the stars moving away from the spawned emoji. Importantly, they're not spawned from the center of the emoji, but from its edges, because that looks a lot better. If they were to be spawned from its center they'd have to move a lot faster for it to look right, and the effect would look worse. So these lines:

```lua
  local r = main:random_angle()
  local d = main:random_float(0.8, 1)
  local x, y = self.x + d*self.rs*math.cos(r), self.y + d*self.rs*math.sin(r)
```

Are making sure that there's an offset of between `0.8*self.rs` and `1*self.rs` pixels from the center for each star spawn position. And then the stars get spawned in the next line with the use of the `emoji_particle` class, which looks like this:

```lua
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
```

This is a generic particle type of object that looks like the emoji that's passed into it and then moves in a linear fashion for a given duration until it slowly stops. It additionally spins around itself a little using the `.rotation_v` variable, which represents the particle's rotation velocity, and `.visual_r`, which represents the particle's visual angle (`.r` is the movement angle). There's nothing else particular special about this class, everything should be familiar by now.

And so after these particles are created if the emoji comes from a merge, the final lines of the constructor look like this:

```lua
  self.has_dropped = false -- if the emoji has been dropped from the cloud, used to prevent the current .spawner_emoji from merging; merged emojis should have this set to true so they can merge again
  self:hitfx_add('drop', 1)
  self.drop_x, self.drop_y = 0, 0
end
```

Both `.has_dropped` and `.drop_x, .drop_y` have been covered previously and so next we have the emoji's update function:

```lua
function emoji:update(dt)
  self:collider_update_position_and_angle()
  if self.trigger_active[main.pointer] and main:input_is_pressed'action_1' then
    self:hitfx_use('main', 0.25)
  end  
  game2:push(self.drop_x, self.drop_y, 0, self.springs.drop.x, self.springs.drop.x)
    game2:draw_image_or_quad(self.emoji, self.x + self.shake_amount.x, self.y + self.shake_amount.y, self.r, self.sx*self.springs.main.x, self.sy*self.springs.main.x, 0, 0, colors.white[0], 
      (self.dying and shaders.grayscale) or (self.flashes.main.x and shaders.combine))
  game2:pop()
end
```

This is also fairly straightforward and all of it covered in other objects. The only additional code that could be here is the emoji merging code that's in `arena:update`, but because of what we discussed there regarding how it should be rules-based, we decided that code shouldn't be here, so it isn't.

And with this, the entire codebase has been covered. Now for some additional, summarizing thoughts!

### [↑](#table-of-contents)

## Future gameplay code

Were I to keep working on this game somehow (I won't), there are only two important things to change about its gameplay code before moving forward. They were mentioned multiple times throughout the post, and they have to do with merging all the emoji-collider-like objects, as well as merging all the chain-like objects. These two types of objects are the ones for which there's most repeated code that could be easily unified, and thus it would make sense to do it.

The first type, the emoji-collider-likes, would cover the following classes: [board](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L924), [chain_part](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1133), [emoji_character](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1499), [emoji_collider](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1525), [evoji_emoji](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1569), [spawner](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1682) and [emoji](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1706).

All of these classes behave according to what the emoji that represents them looks like, therefore they should be unified into one that simply creates a collider based on the shape of the emoji its supposed to represent. It's not difficult to code a procedure that would create a polygon collider that matches the shape of any emoji, and that's how I'd go about it. Then for behavior that is specific to each one of these objects, I'd just either do the behavior in some update function somewhere, add it directly to the object if it's a one-off type of thing, or generalize it with mixins/inheritance if needed.

The second type, the chain-likes, would cover the following classes: [emoji_chain](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L994), [text_chain](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1037) and [text_roped_chain](https://github.com/a327ex/emoji-merge/blob/main/main.lua#L1087). All of these are subtly different from each other, but they have the same core chain-like behavior. For this one I'd simply make it a general `chain` mixin at the engine level that would facilitate this particular type of chain creating logical object.

And that's it for gameplay changes. Overall this is a very simple game so there's not much difficult about it design-wise, sadly. Maybe in the future I'll write something like this again and I'll try to pick something that has more complications to it.

### [↑](#table-of-contents)

## Future engine code

I'd say that writing this blog post made me realize a few things about my engine code that I hadn't realized before. I started this post by saying that I was fairly happy with my engine code and that I'd use it without many changes for the next 2-3 Steam games, which is largely still true, however, I think two important changes are in order.

First, the mixin system is not particularly necessary. I don't actually use it when coding a game for any actual purpose, therefore it doesn't need to exist. I don't need the mixins to have god objects like I do now. Instead of coding things like [this](https://github.com/a327ex/emoji-merge/blob/main/anchor/init.lua#L29):

```lua
anchor = class:class_new()
function anchor:new(type, t) if t then for k, v in pairs(t) do self[k] = v end end; self.type = type end
function anchor:anchor_init(type, t) if t then for k, v in pairs(t) do self[k] = v end end; self.type = type; return self end
function anchor:is(type) return self.type == type end
function anchor:init(f) f(self); return self end
function anchor:action(f) self.update = f; return self end

anchor:class_add(require('anchor.animation'))
...
```

Where the anchor god class is lean and all functionality is added via mixins, I can just code a fat and heavy anchor class with all the behaviors I need, and forego the mixin mechanism altogether, since I don't actually use it for other purposes. This is not some ECS codebase where I have delusions that I'm going to be reusing my gameplay components left and right, it's just not how I work, so the concept of mixins is just unnecessary and I can go straight for the god object and do everything there directly. Which in some sense was already what was happening, since the mixins just merge into the classes they're added to, but conceptually it was an additional "thing" that existed that just doesn't need to exist.

I'd say that's the first change. It's not a particularly big change, it's just moving a few things around. But it's a change that makes things simpler and it's something that was consistently bothering while I was writing this post.

The second change is that I want to figure out a retained mode API for drawing things. A lot of the draw code for objects in this game was repeated, and the same is true for pretty much all my prototypes. It'd be much simpler to have access to a retained mode API where things are drawn in a default way and I can change a few settings around, instead of having to carry all these big draw calls all over the codebase. 

These retained mode APIs are especially useful when they get anchoring right. There are quite a few places in this codebase, and in all my prototypes as well, where I'm having nested push/pop pairs so I can get things to rotate/scale around different points of an object's sprite, and I feel like a lot of this can be expressed more simply with some kind of anchoring system that allows me to say "anchor this rotation value to this object's center left while also anchoring this other rotation value to the parent's top right" and then it just does that and I don't have to do any math. There are lots of engines that do things like this, so I can find inspiration for it in lots of places.

And then further changes are just nice to haves that aren't related to this particular game. I mentioned a few times in the post how having a visual editor would be nice. I had what I think is a really really nice idea for a visual editor that I posted about on my twitter account. I'm going to copy it here for future reference:

>Had an idea for a game engine/editor that'd let you do everything with a gamepad. So you have 8 buttons + directionals, and every action can be achieved with a combination of 2-3 presses of the 8 buttons. This setup would optimize for muscle memory and allow the user to go FAST.

>With 2 presses you have 64 possible actions, with 3 you have 512, more than enough for most things you'd want to do, especially considering that the set of actions could also be dependent on which type of object is currently selected. 

>The goal for such an editor would be letting the user do things with minimal coding. Construct is a good example of something that already exists in this direction. However, the problem with all these existing no code solutions is that the goal behind their no coding is appealing to non-coders, which is not what I want.

>I want no coding because I'm lazy and I want to go fast. I know how to code, I know that I'm often doing similar kinds of things, so a game engine/editor optimized for the kinds of things someone in my position, who knows how to code, is often doing would be best.

>If you really think about it you're always doing similar things. You're creating objects, inserting them into lists, removing them from lists, creating functions, those functions do things to objects with some conditions/loops, you're setting an object's variables, calling functions, getting a value from somewhere and using it somewhere nearby, etc, etc. It really is all the same thing that can be encoded with some care into a set of button presses, I really don't see why it couldn't.

>Still, ultimately you'd probably need a fallback to normal coding for things that the editor would not be good for, although I assume that if I were to make this editor, over time my no code coverage would increase, hopefully to a point where eventually I'd code most things naturally using the gamepad only.

>And the gamepad is just a particularly good example of limiting number of keys to maximize for muscle memory. It'd make sense to also be able to use the keyboard/mouse, although I can see optimizing things so that you use the keyboard only with the left hand on its left side, like around the wasd area, while the mouse is on the right hand for other soft movement actions that on the gamepad would be relegated to the thumbsticks (i.e. drawing a curve for some tween, choosing an angle on an angle wheel pop up, stuff like that).

I can actually see myself coding in an editor like this and having a good time. Despite what it may seem like, I don't actually like programming that much. Well, maybe that's wrong. I like the activity and I try to be decent at it, but primarily because it gets me to the goal of creating some artifact that does something useful (in this case a game). I wouldn't program for the sake of programming alone.

Which is why this editor idea is good to me, as it would allow me to more naturally make things less about programming and more about what kinds of high level actions you're routinely taking when you're making a game. Seems like a meaningless or small difference but consider this line of code:

```lua
self.spawner_emoji = self.emojis:container_add(emoji(self.spawner.x, self.y1, {hitfx_on_spawn_no_flash = 0.5, value = self.next}))
```

Tens of lines exactly like this all over the codebase where some object is added to some container and also has a reference to it stored in some variable. This is a single action, "add object to container with reference", and I should be able to press a button and have the process for making this particular action happen start. 

I'd then fill out what needs to be filled out, what's the object type, where is it (because it's a visual editor you get this for free), what are its settings, and what is it called (because it's a visual editor things don't need names since you can just see them/click them on the editor, or even have an easy-motion like thing where objects have shortcuts attached to them and you can just refer to them by their shortcuts). All of this could be arranged that it happens very quickly, in like a second or two, by an experienced user who has memorized what keys to press and when. I really don't see why this shouldn't be possible. 

And then you imagine this for every possible high level action you code when making a game, and I really like what I see. [This tweet](https://twitter.com/sparseal/status/1735725958781386958) shows an example of something kind of like this, kind of not like this, in action, so it's not an idea that is that out there.

There's lots I'd need to make this happen, like I don't even have a general UI system right now, I'd need to have that. I'd also need to just sit down and try to map what are all the high level actions you code when making most games and how to map those to as few button presses as possible, so it's probably a good idea to just release a few more games. I'd also like to have automatic crash reports, which is actually not that hard to get going currently, I just need to actually sit down and do it. 

I've really wanted a feature for a long time now which is the ability to record play sessions both for testing purposes, like watching replays from players, but also to make it easier to make trailers for games from within the game itself. I think Unity has a host of features that support this, so it'd probably be worth it to look at how it works there. It would also be nice if all of this could be very performant, so I think it would also make sense to move away from the framework and own the C/C++ part of the codebase, which is something I mentioned at the start of the post as well...

There are so many things I'd like to do, and I can do all of them in time. I think this is what I like the most about owning most of my code. It all depends on me and me alone, and this gives me a really good sense of control, responsibility and direction. If things work and are nice it's because I did a good job, if they don't it's because I didn't, there's no getting around it. And I like it being this way, I really like it.

### [↑](#table-of-contents)

## END

So yea, hopefully this post has been useful. High level ideas that I think are important: locality + rules/action spectrum. Many examples of these throughout the post, unfortunately this wasn't a more complicated game to see better examples of these ideas in action.

But these ideas also apply to my engine code. I've organized things such that I have these god objects that I do everything around, and they enable me to do lots of things locally. But the objects themselves are highly action-based/retained. Despite this, the user can use them in any way he desires and they don't really impose any particular structure strongly. 

This kind of pattern, where you have objects that an entire system is built around, but they don't impose any particular structure strongly, is a pattern that I really like and I see it in lots of places. It generally tends to be a good, harmonious mix of both modes that sort of solves most conceptual problems people have with code organization. I think the most clear example of it I have is with [amulet.xyz](https://www.amulet.xyz/doc/), especially visible in this [example game](https://github.com/ianmaclarty/amulet/blob/master/examples/defenders.lua). I think if you pay attention to these ideas as you code your games you'll probably come to similar conclusions as I have, and hopefully that will lead you towards better code. 

In any case, with all that said, I must depart. Good luck with your endeavours, dear reader, and thanks for your attention! Good bye!

### [Comments](https://github.com/a327ex/emoji-merge/issues/1)

### [↑](#table-of-contents)
