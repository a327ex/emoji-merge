main_menu = function(x, y, args)
  local self = anchor('main_menu', args)
  self.enter = main_menu_enter
  self.exit = main_menu_exit
  self.update = main_menu_update
  return self
end

main_menu_enter = function(self)
  main:timer_after(0.02, function()
    main:level_goto('classic_arena')
  end)
end

main_menu_update = function(self, dt)

end

main_menu_exit = function(self)

end
