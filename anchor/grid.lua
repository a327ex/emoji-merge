-- Starts a new grid with 10 width, 5 height and all values 0ed
-- grid(10, 5, 0)
-- Starts a new grid with 3 width, 2 height and values 1, 2, 3 in the first row and 3, 4, 5 in the second row.
-- grid(3, 2, {1, 2, 3, 4, 5, 6})
local grid = class:class_new()
function grid:grid_init(w, h, v)
  self.grid = {}
  self.w, self.h = w, h
  if type(v) ~= 'table' then
    for j = 1, h do
      for i = 1, w do
        self.grid[w*(j-1) + i] = v or 0
      end
    end
  else
    for j = 1, h do
      for i = 1, w do
        self.grid[w*(j-1) + i] = v[w*(j-1) + i]
      end
    end
  end
  return self
end

-- Creates a copy of a grid object
-- g = grid(10, 5, 0)
-- clone = g:grid_clone()
function grid:grid_clone()
  return anchor('grid'):grid_init(self.w, self.h, self.grid)
end

-- g = grid(10, 5, 0)
-- g:grid_get(2, 2) -> 0
-- g:grid_set(2, 2, 1)
-- g:grid_get(2, 2) -> 1
-- g:grid_set(11, 1, 1) -> doesn't actually set because out of bounds, fails silently
function grid:grid_set(x, y, v)
  if not self:grid_is_outside_bounds(x, y) then
    self.grid[self.w*(y-1) + x] = v
  end
end

-- Applies function f to all grid elements
-- If i1,j1 and i2,j2 are passed then it applies only to the subgrid defined by those values.
-- g:grid_for_each(function(h, i, j) h:set(i, j, 0) end) -> sets all elements in the grid to 0
-- g:grid_for_each(function(h, i, j) h:set(i, j, 0) end, 2, 2, 4, 4) -> sets all elements in the subgrid 2,2x4,4 to 0
function grid:grid_for_each(f, i1, j1, i2, j2)
  if i1 and j1 and i2 and j2 then
    for i = i1, i2 do
      for j = j1, j2 do
        f(self:grid_get(i, j), i, j)
      end
    end
  else
    for i = 1, self.w do
      for j = 1, self.h do
        f(self:grid_get(i, j), i, j)
      end
    end
  end
end

-- g = grid(10, 5, 0)
-- print(g:grid_get(2, 2)) -> 0
-- g:grid_set(2, 2, 1)
-- g:grid_get(2, 2) -> 1
-- g:grid_get(11, 1) -> nil, out of bounds, fails silently
function grid:grid_get(x, y)
  if not self:grid_is_outside_bounds(x, y) then
    return self.grid[self.w*(y-1) + x]
  end
end

-- Converts the 2D grid to a 1D array
-- If i1,j1 and i2,j2 are passed then it applies only to the subgrid defined by those values.
-- g = grid(3, 2, 1)
-- g:grid_to_table() -> {1, 1, 1, 1, 1, 1}
-- g:grid_to_table(1, 1, 2, 2) -> {1, 1, 1, 1}
function grid:grid_to_table(i1, j1, i2, j2)
  local t = {}
  if i1 and j1 and i2 and j2 then
    for j = j1, j2 do
      for i = i1, i2 do
        if self:grid_get(i, j) then
          table.insert(t, self:grid_get(i, j))
        end
      end
    end
  else
    for j = 1, self.h do
      for i = 1, self.w do
        table.insert(t, self:grid_get(i, j))
      end
    end
  end
  return t, self.w
end

-- Rotates the grid in an anti-clockwise direction
-- g = grid(3, 2, {1, 2, 3, 4, 5, 6}) -> the grid looks like this:
-- [1, 2, 3]
-- [4, 5, 6]
-- g:grid_rotate_anticlockwise() -> now the grid looks like this:
-- [3, 6]
-- [2, 5]
-- [1, 4]
-- g:grid_rotate_anticlockwise() -> now the grid looks like this:
-- [6, 5, 4]
-- [3, 2, 1]
function grid:grid_rotate_anticlockwise()
  local new_grid = grid(self.h, self.w, 0)
  for i = 1, self.w do
    for j = 1, self.h do
      new_grid:grid_set(j, i, self:grid_get(i, j))
    end
  end

  for i = 1, new_grid.w do
    for k = 0, math.floor(new_grid.h/2) do
      local v1, v2 = new_grid:grid_get(i, 1+k), new_grid:grid_get(i, new_grid.h-k)
      new_grid:grid_set(i, 1+k, v2)
      new_grid:grid_set(i, new_grid.h-k, v1)
    end
  end

  return new_grid
end

-- Rotates the grid in a clockwise direction
-- g = grid(3, 2, {1, 2, 3, 4, 5, 6}) -> the grid looks like this:
-- [1, 2, 3]
-- [4, 5, 6]
-- g:grid_rotate_clockwise() -> now the grid looks like this:
-- [4, 1]
-- [5, 2]
-- [6, 3]
-- g:grid_rotate_clockwise() -> now the grid looks like this:
-- [6, 5, 4]
-- [3, 2, 1]
function grid:grid_rotate_clockwise()
  local new_grid = grid(self.h, self.w, 0)
  for i = 1, self.w do
    for j = 1, self.h do
      new_grid:grid_set(j, i, self:grid_get(i, j))
    end
  end

  for j = 1, new_grid.h do
    for k = 0, math.floor(new_grid.w/2) do
      local v1, v2 = new_grid:grid_get(1+k, j), new_grid:grid_get(new_grid.w-k, j)
      new_grid:grid_set(1+k, j, v2)
      new_grid:grid_set(new_grid.w-k, j, v1)
    end
  end

  return new_grid
end

-- Assume the following grid:
-- g = grid(10, 10, {
--   1, 1, 1, 0, 0, 0, 0, 1, 1, 0,
--   1, 1, 0, 0, 0, 0, 1, 1, 1, 1,
--   1, 0, 0, 0, 1, 0, 1, 0, 1, 0,
--   0, 0, 0, 1, 1, 1, 0, 0, 1, 0,
--   0, 0, 0, 0, 1, 0, 0, 0, 0, 0,
--   1, 0, 0, 0, 0, 0, 0, 1, 0, 0,
--   1, 1, 0, 0, 0, 0, 1, 1, 0, 0,
--   1, 1, 0, 1, 1, 0, 0, 1, 1, 1,
--   1, 1, 0, 1, 1, 0, 0, 0, 0, 1,
--   0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
-- })
-- In this grid you can see that there are multiple islands of solid positions formed.
-- This function will go over the entire grid and find all the islands of solid values, mark them with different numbers, and return them.
-- Essentially, it would do this: {
--   1, 1, 1, 0, 0, 0, 0, 2, 2, 0,
--   1, 1, 0, 0, 0, 0, 2, 2, 2, 2,
--   1, 0, 0, 0, 3, 0, 2, 0, 2, 0,
--   0, 0, 0, 3, 3, 3, 0, 0, 2, 0,
--   0, 0, 0, 0, 3, 0, 0, 0, 0, 0,
--   4, 0, 0, 0, 0, 0, 0, 5, 0, 0,
--   4, 4, 0, 0, 0, 0, 5, 5, 0, 0,
--   4, 4, 0, 6, 6, 0, 0, 5, 5, 5,
--   4, 4, 0, 6, 6, 0, 0, 0, 0, 5,
--   0, 0, 7, 0, 0, 0, 0, 0, 0, 0,
-- }
-- All values form islands that are connected, and each of those islands is identified by a different number.
-- The function returns this information in two formats: an array of positions per island number, and the marked grid as shown above.
-- islands, marked_grid = g:grid_flood_fill(1) -> (the value passed in is what the solid value should be, in the case of the array we're using as an example 1 is the proper value)
-- islands is an array that looks like this: {
--  [1] = {{1, 1}, {2, 1}, {3, 1}, {1, 2}, {2, 2}, {1, 3}},
--  [2] = {{8, 1}, {9, 1}, {7, 2}, {8, 2}, {9, 2}, {10, 2}, {7, 3}, {9, 3}, {9, 4}},
--  ...
--  [7] = {{3, 10}}
-- }
-- It contains all the positions in each island, indexed by island number.
-- And marked_grid is simply a grid instance that looks exactly like the one shown above right after I said "Essentially, it would do this:"
function grid:grid_flood_fill(v)
  local islands = {}
  local marked_grid = grid(self.w, self.h, 0)

  local flood_fill = function(i, j, color)
    local queue = {}
    table.insert(queue, {i, j})
    while #queue > 0 do
      local x, y = unpack(table.remove(queue, 1))
      marked_grid:grid_set(x, y, color)
      table.insert(islands[color], {x, y})

      if self:grid_get(x, y-1) == v and marked_grid:grid_get(x, y-1) == 0 then table.insert(queue, {x, y-1}) end
      if self:grid_get(x, y+1) == v and marked_grid:grid_get(x, y+1) == 0 then table.insert(queue, {x, y+1}) end
      if self:grid_get(x-1, y) == v and marked_grid:grid_get(x-1, y) == 0 then table.insert(queue, {x-1, y}) end
      if self:grid_get(x+1, y) == v and marked_grid:grid_get(x+1, y) == 0 then table.insert(queue, {x+1, y}) end
    end
  end

  local color = 1
  islands[color] = {}
  for i = 1, self.w do
    for j = 1, self.h do
      if self:grid_get(i, j) == v and marked_grid:grid_get(i, j) == 0 then
        flood_fill(i, j, color)
        color = color + 1
        islands[color] = {}
      end
    end
  end

  islands[color] = nil
  return islands, marked_grid
end

function grid:grid_is_outside_bounds(x, y)
  if x > self.w then return true end
  if x < 1 then return true end
  if y > self.h then return true end
  if y < 1 then return true end
end

function grid:grid_tostring()
  local str = ''
  for j = 1, self.h do
    str = str .. '['
    for i = 1, self.w do
      str = str .. self:grid_get(i, j) .. ', '
    end
    str = str:sub(1, -3) .. ']\n'
  end
  return str
end

return grid
