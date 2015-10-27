local HC = require('HC')
local Entity = require('entity')

local Asteroid = {}
setmetatable(Asteroid, Entity)

function Asteroid:new(x, y, radius, vx, vy)

  -- Class Setup
  obj = Entity:new(x, y, HC.circle(x, y, radius - 1), vx, vy)
  setmetatable( obj, self )
  self.__index = self

  obj.x = x
  obj.y = y
  obj.vx = vx or 0
  obj.vy = vy or 0
  obj.radius = radius

  obj.body.tag = 'asteroid'

  obj.health = radius * 2

  return obj
end

function Asteroid:damage(damage)
  self.health = self.health - damage
  if self.health <= 0 then
    self:split()
  end
end

function Asteroid:split()
  if self  then
    self:destroy()

    if self.radius > 5 * 2 then
      Asteroid:new(self.x, self.y, self.radius / 2, self.vx + math.random(-50, 50), self.vy + math.random(-50, 50))
      Asteroid:new(self.x, self.y, self.radius / 2, self.vx + math.random(-50, 50), self.vy + math.random(-50, 50))
    end
  end
end

function Asteroid:update(dt)
  self.x = self.x + dt * self.vx
  self.y = self.y + dt * self.vy
  self.body:moveTo(self.x, self.y)
end

function Asteroid:draw()
  love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Asteroid