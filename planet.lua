Asteroid = require('asteroid')

local Planet = {}
setmetatable(Planet, Asteroid)

Planet.planets = {}
local currentPlanetId = 0

function Planet:new(x, y, radius)

  local obj = Asteroid:new(x, y, radius)
  setmetatable(obj, self)
  self.__index = self

  obj.planetId = currentPlanetId
  currentPlanetId = currentPlanetId + 1

  self.planets[obj.planetId] = obj

  return obj

end

function Planet:destroy()
  Asteroid.destroy(self)
  Planet.planets[self.planetId] = nil
end

function Planet:draw()
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(255, 255, 255, 255)
end

return Planet