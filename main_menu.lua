main_menu = class:class_new(anchor)
function main_menu:new(x, y, args)
  self:anchor_init('main_menu', args)
  
end

function main_menu:update(dt)

end

function main_menu:enter()
  main:timer_after(0.02, function()
    main:level_goto('classic_arena')
  end)
end

function main_menu:exit()
  
end
