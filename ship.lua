local Bullet = require('bullet')
local Player = require('player')
local HC = require('HC')

local Ship = {}
Ship.instance = nil

function Ship:new()

  -- Class Setup
  obj = {}
  setmetatable( obj, self )
  self.__index = self

  obj.x = 0
  obj.y = 0
  obj.vx = 0
  obj.vy = 0
  obj.acc = 400

  obj.angle = 0
  obj.angleSpeed = 3

  obj.boostTimer = 0
  obj.boostSpeed = 400

  obj.radius = 10
  obj.img = nil

  obj.fireRate = 30
  obj.fireTimer = 0

  obj.body = HC.rectangle(obj.x, obj.y, obj.radius * 2, obj.radius * 2)
  obj.body.tag = 'ship'

  obj.bullets = {}

  self.instance = obj
  return obj
end

function Ship:turnRight(dt)
  self.angle = self.angle + self.angleSpeed * dt
end

function Ship:turnLeft(dt)
  self.angle = self.angle - self.angleSpeed * dt
end

function Ship:shoot(dt)
  if self.fireTimer > 1 / self.fireRate then
    self.fireTimer = 0
    table.insert(self.bullets, #self.bullets, Bullet:new(self.x, self.y, self.vx, self.vy, self.angle))
  end
end

function Ship:moveForward(dt)
  self.vy = self.vy - self.acc * dt * math.cos(self.angle)
  self.vx = self.vx + self.acc * dt * math.sin(self.angle)
end

function Ship:moveBackward(dt)
  self.vy = self.vy + self.acc * dt * math.cos(self.angle)
  self.vx = self.vx - self.acc * dt * math.sin(self.angle)
end

function Ship:boost(dt)
  if self.boostTimer > 1 then
    self.boostTimer = 0
    self.vy = self.vy - self.boostSpeed * math.cos(self.angle)
    self.vx = self.vx + self.boostSpeed * math.sin(self.angle)
  end
end

function Ship:eject()
  Player:new(self.x, self.y, self.angle, self)
end

function Ship:restart()
  self.x = 0
  self.y = 0
  self.vx = 0
  self.vy = 0

  self.body:moveTo(self.x, self.y)
end

function Ship:bounceOff(x, y)
  local bounceRatio = .6

  local normX = self.x - x
  local normY = self.y - y

  local norm = math.sqrt(normX * normX + normY * normY)
  local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)

  -- if speed < 10 then
  --   self.vx = 0
  --   self.vy = 0
  --   return
  -- end

  local normalizedX = normX * speed / norm
  local normalizedY = normY * speed / norm

  local newVX = 2 * normalizedX - self.vx
  local newVY = 2 * normalizedY - self.vy

  self.vx = normalizedX * bounceRatio
  self.vy = normalizedY * bounceRatio
end

function Ship:update(dt)

  -- apply gravity
  for key, planet in pairs(Planet.planets) do
    if planet then
      local k = 400 * planet.radius * planet.radius
      local diffX = (planet.x - self.x)
      local diffY = (planet.y - self.y)
      local diff = math.sqrt(diffX * diffX + diffY * diffY)
      local force = k / (diff * diff)
      local forceX = force * diffX / diff
      local forceY = force * diffY / diff
      self.vx = self.vx + forceX * dt
      self.vy = self.vy + forceY * dt
    end
  end

  -- check for collisions
  for shape, delta in pairs(HC.collisions(self.body)) do
    if shape.tag == 'asteroid' then
      self:bounceOff(shape:center())
    end
  end

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  self.body:moveTo(self.x, self.y)

  -- update timers
  self.boostTimer = self.boostTimer + dt
  self.fireTimer = self.fireTimer + dt
end

function Ship:draw()
  local shipWidth = self.img:getWidth()
  local shipHeight = self.img:getHeight()
  love.graphics.draw(self.img, self.x, self.y, self.angle, 1, 1, shipWidth / 2, shipHeight / 2)
end

return Ship