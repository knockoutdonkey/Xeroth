local Entity = require('entity')
local HC = require('HC')

local Player = {}
setmetatable(Player, Entity)

Player.instance = nil

function Player:new(x, y, angle, ship)

  local obj = Entity:new(x, y, HC.rectangle(x, y, 20, 20), 0, 0, angle)
  setmetatable(obj, self)
  self.__index = self

  obj.ship = ship

  obj.acc = 300
  obj.jumpSpeed = 10

  Player.instance = obj

  return obj
end

function Player:destroy()
  Entity.destroy(self)

  Player.instance = nil
end

function Player:moveLeft(dt)
  self.vx = self.vx - self.acc * dt * math.cos(self.angle)
  self.vy = self.vy - self.acc * dt * math.sin(self.angle)
end

function Player:moveRight(dt)
  self.vx = self.vx + self.acc * dt * math.cos(self.angle)
  self.vy = self.vy + self.acc * dt * math.sin(self.angle)
end

function Player:jump()
  self.vx = self.vx + self.jumpSpeed * math.sin(self.angle)
  self.vy = self.vy - self.jumpSpeed * math.cos(self.angle)
end

function Player:enterShip()
  if not self.ship then
    return
  end

  local distX = self.ship.x - self.x
  local distY = self.ship.y - self.y
  local dist = math.sqrt(distX * distX + distY * distY)

  if dist < 30 then
    self:destroy()
  end
end

function Player:touch(x, y)
  local bounceRatio = .4

  local normX = self.x - x
  local normY = self.y - y

  local norm = math.sqrt(normX * normX + normY * normY)
  local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)

  local normalizedX = normX * speed / norm
  local normalizedY = normY * speed / norm

  local newVX = 2 * normalizedX - self.vx
  local newVY = 2 * normalizedY - self.vy

  self.vx = normalizedX * bounceRatio
  self.vy = normalizedY * bounceRatio
end

function Player:update(dt)
  Entity.update(self, dt)

  local closestDist = 800
  local closestPlanet = nil
  -- apply gravity
  for key, planet in pairs(Planet.planets) do
    if planet then
      local k = 400 * planet.radius * planet.radius
      local distX = planet.x - self.x
      local distY = planet.y - self.y
      local dist = math.sqrt(distX * distX + distY * distY)
      local force = k / (dist * dist)
      local forceX = force * distX / dist
      local forceY = force * distY / dist
      self.vx = self.vx + forceX * dt
      self.vy = self.vy + forceY * dt

      if dist < closestDist then
        closestDist = dist
        closestPlanet = planet
      end
    end
  end

  -- adjust angle to closest planet
  if closestPlanet then
    self.angle = math.atan2(- closestPlanet.x + self.x, closestPlanet.y - self.y)
  end

  -- check for collisions
  for shape, delta in pairs(HC.collisions(self.body)) do
    if shape.tag == 'asteroid' then
      self:touch(shape:center())
    end
  end

end

function Player:draw()
  local playerWidth = PlayerImage:getWidth()
  local playerHeight = PlayerImage:getHeight()
  love.graphics.draw(PlayerImage, self.x, self.y, self.angle, 1, 1, playerWidth / 2, playerHeight / 2)
end

return Player