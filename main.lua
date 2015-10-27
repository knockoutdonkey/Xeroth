local HC = require('HC')
local Entity = require('entity')
local Sector = require('sector')
local Ship = require('ship')
local Planet = require('planet')

local sectors = {}
for y = -1, 1 do
  for x = -1, 1 do
    local newSector = Sector:new(x, y)
    newSector:placeEntities()
    sectors[x .." ".. y] = newSector
  end
end

local camera = {
  x = 0,
  y = 0,
  angle = 0,
  vAngle = 0
}

function love.load(arg)

  ship = Ship:new()
  ship.img = love.graphics.newImage( 'player.png' )
  -- ship.img:setFilter( 'nearest', 'nearest' )

  love.window.setMode( 800, 800 )
end

function love.update(dt)

  -- input
  if love.keyboard.isDown('w', 'up') then
    ship:moveForward(dt)
  end

  if love.keyboard.isDown('s', 'down') then
    ship:moveBackward(dt)
  end

  if love.keyboard.isDown('right', 'd') then
    ship:turnRight(dt)
  end

  if love.keyboard.isDown('left', 'a') then
    ship:turnLeft(dt)
  end

  if love.keyboard.isDown('b') then
    ship:boost(dt)
  end

  if love.keyboard.isDown(' ') then
    ship:shoot(dt)
  end

  -- create any new sectors
  shipXCoord = math.floor(ship.x / 2000 - .5)
  shipYCoord = math.floor(ship.y / 2000 - .5)

  for x = -1, 1 do
    for y = -1, 1 do
      if not sectors[(shipXCoord + x).." "..(shipYCoord + y)] then
        sectors[(shipXCoord + x).." "..(shipYCoord + y)] = Sector:new(shipXCoord + x, shipYCoord + y)
        sectors[(shipXCoord + x).." "..(shipYCoord + y)]:placeEntities()
      end
    end
  end

  -- destroy old sectors
  for key, sector in pairs(sectors) do
    if math.abs(shipXCoord - sector.x) > 1 or math.abs(shipYCoord - sector.y) > 1 then
      sector:destroy()
      sectors[key] = nil
    end
  end

  -- apply gravity
  for key, planet in pairs(Planet.planets) do
    if planet then
      local k = 200 * planet.radius * planet.radius
      local diffX = (planet.x - ship.x)
      local diffY = (planet.y - ship.y)
      local diff = math.sqrt(diffX * diffX + diffY * diffY)
      local force = k / (diff * diff)
      local forceX = force * diffX / diff
      local forceY = force * diffY / diff
      ship.vx = ship.vx + forceX * dt
      ship.vy = ship.vy + forceY * dt
    end
  end

  -- iterate physics
  ship:update(dt)
  Entity:updateAll(dt)

  camera.angle = camera.angle + 5 * (ship.angle - camera.angle) * dt
end

function love.draw(dt)


  -- draw the camera
  local screenWidth = love.graphics:getWidth()
  local screenHeigth = love.graphics:getHeight()

  love.graphics.translate(screenWidth / 2, screenHeigth / 2)
  love.graphics.rotate(-camera.angle)
  love.graphics.translate(-ship.x, -ship.y)

  -- draw the ship
  ship:draw()

  Entity:drawAll()

end
