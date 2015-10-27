local HC = require('HC')

local Entity = {}

Entity.entities = {}

local currentId = 0

function Entity:new(x, y, body, vx, vy, angle)

  obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.x = x
  obj.y = y
  obj.body = body
  obj.vx = vx or 0
  obj.vy = vy or 0
  obj.angle = obj.angle or 0

  obj.id = currentId
  obj.body.id = obj.id
  currentId = currentId + 1

  self.entities[obj.id] = obj

  return obj
end

function Entity:update(dt)
  self.x = self.x + dt * self.vx
  self.y = self.y + dt * self.vy

  self.body:moveTo(self.x, self.y)
end

function Entity:updateAll(dt)
  for key, entity in pairs(self.entities) do
    entity:update(dt)
  end
end

function Entity:draw()

end

function Entity:drawAll()
  for key, entity in pairs(self.entities) do
    entity:draw()
  end
end

function Entity:destroy()
  if not self.entities[self.id] then
    -- print ('Error: Entity:destroy() trying to eliminate an object which is already destroyed')
    return
  end
  HC.remove(self.body)   -- Find out if this function does what I think it does
  self.entities[self.id] = nil
end

function Entity:destroyAll()
  for key, entity in pairs(self.entities) do
    entity:destroy()
  end
end

return Entity