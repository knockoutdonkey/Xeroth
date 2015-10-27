Asteroid = require('asteroid')
Planet = require('planet')

local Sector = {}

local seed = 123456789

function Sector:new(x, y)

  obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.x = x
  obj.y = y

  obj.width = 2000
  obj.height = 2000
  obj.asteroidNum = 80

  --obj:placeEntities()

  return obj
end

function Sector:placeEntities()

  math.randomseed(seed * self.y + self.x)

  for i = 1, self.asteroidNum do
    local x = math.random(self.width * (self.x - .5), self.width * (self.x + .5))
    local y = math.random(self.height * (self.y - .5), self.height * (self.y + .5))
    local radius = math.random(10, 60)

    Asteroid:new(x, y, radius)
  end

  local x = math.random(self.width * (self.x - .5), self.width * (self.x + .5))
  local y = math.random(self.height * (self.y - .5), self.height * (self.y + .5))
  local radius = math.random(170, 400)

  Planet:new(x, y, radius)
end

function Sector:destroy()
  --print('destroy this Sector', self.x, self.y)
end

function Sector:getX()
  return self.x
end

return Sector