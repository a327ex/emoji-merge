local random = class:class_new()
function random:random_init(seed)
  self.random_id = 0
  self.random_seed = seed or os.time()
  self.generator = love.math.newRandomGenerator(self.random_seed)
  return self
end

-- Returns true at the given chance.
-- :bool(50) -> returns true 50% of the time
-- :bool(25) -> returns true 25% of the time
-- :bool(3) -> returns true 3% of the time
function random:random_bool(chance)
  if self.generator:random(1, 1000) < 10*chance then
    return true
  end
end

-- Returns a random real number between the range.
-- :float(0, 1) -> returns a random number between 0 and 1, like 0.432
-- :float(-100, 45.2) -> returns a random number between -100 and 45.2, like -99.7
function random:random_float(min, max)
  min = min or 0
  max = max or 1
  return (min > max and (self.generator:random()*(min - max) + max)) or (self.generator:random()*(max - min) + min)
end

-- Returns a random integer number between the range.
-- :int(1, 7) -> returns a random integer between 1 and 7, like 4
-- :int(-2, 0) -> returns a random integer between -2 and 0, like -2
function random:random_int(min, max)
  return self.generator:random(min or 0, max or 1)
end

-- Returns a random value of the table.
-- a = {7, 6, 5, 4}
-- :table(a) -> returns either 7, 6, 5 or 4 randomly
function random:random_table(t)
  return t[self.generator:random(1, #t)]
end

-- Returns a random value of the table and also removes it.
-- a = {7, 6, 5, 4}
-- :table_remove(a) -> returns either 7, 6, 5 or 4 randomly and removes it from the table as well
function random:random_table_remove(t)
  return table.remove(t, self.generator:random(1, #t))
end

-- Returns a 1 at the given chance, otherwise returns -1.
-- :sign(65) -> returns 1 65% of the time and -1 35% of the time
-- :sign(20) -> returns 1 20% of the time and -1 80% of the time
function random:random_sign(chance)
  if self.generator:random(1, 1000) < 10*chance then return 1
  else return -1 end
end

-- Returns a random index at the given weights.
-- :weighted_pick(50, 30, 20) -> will return 1 50% of the time, 2 30% of the time and 3 20% of the time
-- :weighted_pick(10, 8, 2) -> will return 1 50% of the time, 2 40% of the time and 3 10% of the time
-- :weighted_pick(2, 1) -> will return 1 66% of the time, will return 2 33% of the time
function random:random_weighted_pick(...)
  local weights = {...}
  local total_weight = 0
  local pick = 0
  for _, weight in ipairs(weights) do total_weight = total_weight + weight end

  total_weight = self:random_float(0, total_weight)
  for i = 1, #weights do
    if total_weight < weights[i] then
      pick = i
      break
    end
    total_weight = total_weight - weights[i]
  end
  return pick
end

-- Returns a unique identifier (integer).
function random:random_uid()
  self.random_id = self.random_id + 1
  return self.random_id
end

-- Returns a random angle from 0 to 2*math.pi.
function random:random_angle()
  return self:random_float(0, 2*math.pi)
end

return random
