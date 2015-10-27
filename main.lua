local HC = require('HC')
local Entity = require('entity')
local Sector = require('sector')
local Ship = require('ship')
local Planet = require('planet')
local Player = require('player')

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
  ship.img = love.graphics.newImage('ship.png')
  -- ship.img:setFilter('nearest', 'nearest')

  PlayerImage = love.graphics.newImage('player.png')

  love.window.setMode( 800, 800 )
end

local ePressed = false

function love.update(dt)

  -- input
  if love.keyboard.isDown('w', 'up') then
    if Player.instance then
      Player.instance:jump()
    else
      ship:moveForward(dt)
    end
  end

  if love.keyboard.isDown('s', 'down') then
    if Player.instance then

    else
      ship:moveBackward(dt)
    end
  end

  if love.keyboard.isDown('right', 'd') then
    if Player.instance then
      Player.instance:moveRight(dt)
    else
      ship:turnRight(dt)
    end
  end

  if love.keyboard.isDown('left', 'a') then
    if Player.instance then
      Player.instance:moveLeft(dt)
    else
      ship:turnLeft(dt)
    end
  end

  if love.keyboard.isDown('b') then
    if Player.instance then

    else
      ship:boost(dt)
    end
  end

  if love.keyboard.isDown(' ') then
    if Player.instance then
      Player.instance:jump()
    else
      ship:shoot(dt)
    end
  end

  if love.keyboard.isDown('e') then

    if not ePressed then
      if Player.instance then
        Player.instance:enterShip()
      else
        ship:eject()
      end
    end
    ePressed = true
  else
    ePressed = false
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

  -- iterate physics
  ship:update(dt)
  Entity:updateAll(dt)

  -- update camera
  if Player.instance then
    camera.x = Player.instance.x
    camera.y = Player.instance.y

    while Player.instance.angle - camera.angle > math.pi do
      camera.angle = camera.angle + 2 * math.pi
    end

    while Player.instance.angle - camera.angle < - math.pi do
      camera.angle = camera.angle - 2  * math.pi
    end
    camera.angle = camera.angle + 5 * (Player.instance.angle - camera.angle) * dt
    print(camera.angle)
  else
    camera.x = ship.x
    camera.y = ship.y

    while ship.angle - camera.angle > math.pi do
      camera.angle = camera.angle + 2 * math.pi
    end

    while ship.angle - camera.angle < - math.pi do
      camera.angle = camera.angle - 2  * math.pi
    end
    camera.angle = camera.angle + 5 * (ship.angle - camera.angle) * dt
    print(camera.angle)
  end
end

function love.draw(dt)

  -- draw the camera
  local screenWidth = love.graphics:getWidth()
  local screenHeigth = love.graphics:getHeight()

  love.graphics.translate(screenWidth / 2, screenHeigth / 2)
  love.graphics.rotate(-camera.angle)
  love.graphics.translate(-camera.x, -camera.y)

  -- draw the ship
  ship:draw()

  Entity:drawAll()

end
