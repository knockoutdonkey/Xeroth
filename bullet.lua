local HC = require('HC')
local Entity = require('entity')

local Bullet = {}
setmetatable(Bullet, Entity)

function Bullet:new(x, y, vx, vy, angle)

  -- TODO: do math here to find out vx and vy instead of using angle each frame

  -- Class Setup
  radius = 5
  obj = Entity:new(x, y, HC.circle(x, y, radius - 1), vx, vy)
  setmetatable(obj, self)
  self.__index = self

  obj.radius = radius
  obj.bulletRange = 15
  obj.angle = angle + math.random(-obj.bulletRange, 0, obj.bulletRange) / 60

  obj.bulletSpeed = 150
  obj.damage = 5

  obj.body.tag = 'bullet'

  return obj
end

function Bullet:update(dt)
  self.x = self.x + self.bulletSpeed * math.sin(self.angle) * dt + self.vx * dt
  self.y = self.y - self.bulletSpeed * math.cos(self.angle) * dt + self.vy * dt

  self.body:moveTo(self.x, self.y)

  for shape, delta in pairs(HC.collisions(self.body)) do
    if shape.tag == 'asteroid' then
      self:destroy()
      Entity.entities[shape.id]:damage(self.damage)
    end
  end
end

function Bullet:draw()
  love.graphics.setColor(255, 0, 0, 255)
  love.graphics.circle("fill", self.x, self.y, self.radius)
  love.graphics.setColor(255, 255, 255, 255)
end

return Bullet