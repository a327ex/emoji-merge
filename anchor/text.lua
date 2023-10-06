-- Mixin that adds character based text functionality to the object.
-- This implements a character based effect system which should allow you to implement any kind of text effect possible, from setting a character's color, to making it move, shake or play sounds.
-- WARNING: currently the | character cannot be used in the text or bugs will happen, will be fixed when I need to use it in a game
--
-- Defining an effect:
--   color_effect = function(dt, layer, text, c, color)
--     layer:set_color(color)
--   end
--
-- Every effect is a single function that gets called every frame for every character before each character is drawn.
-- In the example above, we define the color effect as a function that simply sets the color for next draw operations, which will be the operations in which this specific character is drawn, and so it will be drawn with that color.
-- The effect function receives the following arguments:
--   dt - time step
--   layer - the layer the character will be drawn to, don't call any draw functions for the character yourself or you'll be just drawing the character twice
--   text - a reference to the text object
--   c - an anchor object, which is a table containing .x, .y, .r, .sx, .sy, .ox, .oy, .c, .line, .i and .effects attributes
--   effect arguments - all arguments after c are the effect's arguments, for color it's just a single color, but for other effects it might be multiple values
--
-- Another effect:
--  shake = function(dt, layer, text, c, intensity, duration)
--    if text.first_frame then
--      if not c.shakes then c:shake_init() end
--      c:shake_shake(intensity, duration)
--    end
--    c.ox, c.oy = c.shake_amount.x, c.shake_amount.y
--  end,
--
-- For some effects it makes sense to do most or all of its operations only when the text object is created, and to do this it's useful to use the text.first_frame variable, which is only true on the frame the text object is created.
-- In shake_effect's case, we initialize the character's shake mixin and then call the shake function to start shaking, and then on update we set the object's offset to the shake amount.
-- Both intensity and duration values are passed in from the text's definition: i.e. [this text is shaking](shake=4,2) <- 4 is intensity, 2 is duration
-- Arguments for effects can theoretically be any Lua value, as internally it just loadstrings the string for each argument, but in some cases this might break and I haven't tested for every possible thing so keep that in mind.
--
-- Creating a text object:
--   text('[this text is red](color=colors.red2[0]), [this text is shaking](shake=4,4), [this text is red and shaking](color=colors.red2[0];shake=4,4), this text is normal', {
--     text_font = some_font, -- optional, defaults to engine's default font
--     text_effects = {color = color_effect, shake = shake_effect}, -- optional, defaults to engine's default effects; if defined, effect key name has to be same as the effect's name on the text inside delimiters ()
--     text_alignment = 'center', -- optional, defaults to 'left'
--     w = 200, -- mandatory, acts as wrap width for text
--     height_multiplier = 1 -- optional, defaults to 1
--   })
-- The text can be created from the global text function, or as a mixin in your own objects.
-- The text additionally receives a table of attributes after the text string with the following properties:
--   .text_font - the font to be used for the text, if not specified will use the engine's default font
--   .text_effects - the effects to be used for the text, if not specified will use the engine's default text effects
--   .text_alignment - how the text should align itself with regards to its wrap width, possible values are 'center', 'justified', 'right' and 'left'; if not specified defaults to 'left'
--   .w - the object's width, used as wrap width; if not specified an error will happen, the width must be defined before initializing this object as a text
--   .height_multiplier - multiplier over the font's height for placing the line below

local default_text_effects = {
  color = function(dt, layer, text, c, color)
    layer:set_color(color)
  end,

  shake = function(dt, layer, text, c, intensity, duration)
    if text.first_frame then
      if not c.shakes then c:shake_init() end
      c:shake_shake(intensity, duration)
    end
    c.ox, c.oy = c.shake_amount.x, c.shake_amount.y
  end,
}

local text = class:class_new()
function text:text_init(raw_text, args)
  for k, v in pairs(args or {}) do self[k] = v end
  self.raw_text = raw_text
  self.first_frame = true
  self.text_font = self.text_font
  self.text_effects = self.text_effects or default_text_effects
  self.text_alignment = self.text_alignment or 'left'
  self.height_multiplier = self.height_multiplier or 1
  self:text_parse()
  self:text_format()
  return self
end

-- Parses .raw_text into the .characters table, which contains every valid character as the following table: {c = character as a string, effects = effects that apply to this character as a table}
function text:text_parse()
  local parse_arg = function(arg)
    if arg:find('#') then return tostring(arg)
    else return loadstring('return ' .. tostring(arg))() end
  end

  -- Parse text and store all delimiters as well as text field and effects into the parsed_text table
  local parsed_text = {}
  for i, field, j, effects, k in utf8.gmatch(self.raw_text, "()%[(.-)%]()%((.-)%)()") do
    local effects_temp = {}
    for effect in utf8.gmatch(effects, "[^;]+") do table.insert(effects_temp, effect) end

    -- Parse each effect: 'effect_name=arg1,arg2' becomes {effect_name, arg1, arg2}
    local parsed_effects = {}
    for _, effect in ipairs(effects_temp) do
      local effect_table = {}
      local effect_name = effect:left('=')
      table.insert(effect_table, effect_name)
      local args = effect:right('=')
      if args:find(',') then
        for arg in utf8.gmatch(args, "[^,]+") do
          table.insert(effect_table, parse_arg(arg))
        end
      else
        table.insert(effect_table, parse_arg(args))
      end
      table.insert(parsed_effects, effect_table)
    end

    table.insert(parsed_text, {i = tonumber(i), j = tonumber(j), k = tonumber(k), field = field, effects = parsed_effects})
    -- i to j-1 is [field]
    -- i+1 to j-2 is field
    -- j to k-1 is (effects)
    -- j+1 to k-2 is effects
  end

  -- Read the parsed_text table to figure out which characters should be in the final text ([] and () delimiters shouldn't be in, neither should any text inside effect () delimiters)
  -- Build the characters table containing each valid character as well as the effects that apply to it
  -- Each character is transformed into an anchor object here as well, which is useful for applying mixins when coding text effects
  local characters = {}
  for i = 1, utf8.len(self.raw_text) do
    local c = utf8.sub(self.raw_text, i, i)
    local effects
    local should_be_character = true
    for _, t in ipairs(parsed_text) do
      if i >= t.i+1 and i <= t.j-2 then
        effects = t.effects
      end
      if (i >= t.j and i <= t.k-1) or i == t.i or i == t.j-1 then
        should_be_character = false
      end
    end
    if should_be_character then
      table.insert(characters, anchor({c = c, effects = effects or {}}))
    end
  end

  --[[
  for _, c in ipairs(characters) do
    print(c.c, table.tostring(c.effects))
  end
  ]]--

  self.characters = characters
end

-- Formats characters in the .characters table by setting .x, .y, .r, .sx, .sy, .ox, .oy, .line and .i attributes.
-- All of these values are applied locally, i.e. .x, .y is the character's local position.
-- The character's world position is text object's .x + character's .x + character's .ox offset.
--
-- Additionally, the text object's following attributes will affect formatting:
--   .text_font - the font to be used for the text, if not specified will use the engine's default font
--   .text_effects - the effects to be used for the text, if not specified will use the engine's default text effects
--   .text_alignment - how the text should align itself with regards to its wrap width, possible values are 'center', 'justified', 'right' and 'left'; if not specified defaults to 'left'
--   .w - the object's width, used as wrap width; if not specified an error will happen, the width must be defined before initializing this object as a text
--   .height_multiplier - multiplier over the font's height for placing the line below
--
-- From this function the text object itself will also have .text_w and .text_h attributes defined.
-- .text_w should be the same as .w, and .text_h will be the height of all lines + spacing put together.
function text:text_format()
  if not self.w then error('.w must be defined for text mixin to work.') end
  local cx, cy = 0, 0
  local line = 1

  -- Set .x, .y, .r, .sx, .sy, .ox, .oy and .line for each character
  for i, c in ipairs(self.characters) do
    if c.c == '|' then
      cx = 0
      cy = cy + self.text_font.h*self.height_multiplier
      line = line + 1
    elseif c.c == ' ' then
      local wrapped
      if #c.effects <= 1 then -- only check for wrapping if this space is not inside effect delimiters ()
        local from_space_x = cx
        for j = i+1, (table.find(table.get(self.characters, i+1, -1), function(v) return v.c == ' ' end) or 0) + i do -- go from next character to next space (the next word) to see if it fits this line
          from_space_x = from_space_x + self.text_font:font_get_width(self.characters[j].c)
        end
        if from_space_x > self.w then -- if the word doesn't fit then wrap line here
          cx = 0
          cy = cy + self.text_font.h*self.height_multiplier
          line = line + 1
          wrapped = true
        end
      end
      if not wrapped then
        c.x, c.y = cx, cy
        c.line = line
        c.r = 0
        c.sx, c.sy = 1, 1
        c.ox, c.oy = 0, 0
        c.w, c.h = self.text_font:font_get_width(c.c), self.text_font.h
        cx = cx + c.w
        if cx > self.w then
          cx = 0
          cy = cy + self.text_font.h*self.height_multiplier
          line = line + 1
        end
      else
        c.c = '|' -- set | to remove it in the next step, as it was already wrapped and doesn't need to be visually represented
      end
    else
      c.x, c.y = cx, cy
      c.line = line
      c.r = 0
      c.sx, c.sy = 1, 1
      c.ox, c.oy = 0, 0
      c.w, c.h = self.text_font:font_get_width(c.c), self.text_font.h
      cx = cx + c.w
      if cx > self.w then
        cx = 0
        cy = cy + self.text_font.h*self.height_multiplier
        line = line + 1
      end
    end
  end

  -- Remove line separators as they're not needed anymore
  for i = #self.characters, 1, -1 do
    if self.characters[i].c == '|' then
      table.remove(self.characters, i)
    end
  end

  -- Set .i for each character
  for i, c in ipairs(self.characters) do
    c.i = i
  end

  -- Find .text_w (.w), .text_h and the width of each line to set alignments next
  local text_w = 0
  local line_widths = {}
  for i = 1, self.characters[#self.characters].line do
    local line_w = 0
    for j, c in ipairs(self.characters) do
      if c.line == i then
        line_w = line_w + self.text_font:font_get_width(c.c)
      end
    end
    line_widths[i] = line_w
    if line_w > text_w then
      text_w = line_w
    end
  end
  self.text_w = text_w
  self.text_h = self.characters[#self.characters].y + self.text_font.h*self.height_multiplier
  if not self.h then self.h = self.text_h end

  -- Sets .x of each character to match the given .text_alignment, unchanged if it is 'left'
  for i = 1, self.characters[#self.characters].line do
    local line_w = line_widths[i]
    local leftover_w = self.text_w - line_w
    if self.text_alignment == 'center' then
      for _, c in ipairs(self.characters) do
        if c.line == i then
          c.x = c.x + leftover_w/2
        end
      end
    elseif self.text_alignment == 'right' then
      for _, c in ipairs(self.characters) do
        if c.line == i then
          c.x = c.x + leftover_w
        end
      end
    elseif self.text_alignment == 'justify' then
      local spaces_count = 0
      for _, c in ipairs(self.characters) do
        if c.line == i then
          if c.c == ' ' then
            spaces_count = spaces_count + 1
          end
        end
      end
      local added_width_to_each_space = math.floor(leftover_w/spaces_count)
      local total_added_width = 0
      for _, c in ipairs(self.characters) do
        if c.line == i then
          if c.c == ' ' then
            c.x = c.x + added_width_to_each_space
            total_added_width = total_added_width + added_width_to_each_space
          else
            c.x = c.x + total_added_width
          end
        end
      end
    end
  end
end

function text:text_update(dt, layer, x, y, r, sx, sy)
  layer:push(x, y, r, sx, sy)
    for _, c in ipairs(self.characters) do
      for _, effect_table in ipairs(c.effects) do
        for effect_name, effect_function in pairs(self.text_effects) do
          if effect_name == effect_table[1] then
            local args = {}
            for i = 2, #effect_table do table.insert(args, effect_table[i]) end
            effect_function(dt, layer, self, c, unpack(args))
          end
        end
      end
      layer:draw_text(c.c, self.text_font, x + c.x + c.ox - self.text_w/2, y + c.y + c.oy - self.text_h/2, c.r or 0, c.sx, c.sy)
      layer:set_color(colors.white[0])
    end
  layer:pop()
  if self.first_frame then self.first_frame = false end
end

return text
