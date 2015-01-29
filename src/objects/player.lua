local spriteLayer
function initPlayer(Layer, entity)
  print("initPlayer")
  spriteLayer = map.layers["Sprite Layer"]
  
  -- Add Player
  spriteLayer.player = {
  image = love.graphics.newImage("graphics/kim.png"),
  w = 20,
  h = 29,
  r = 0,
  isTouchingGround,
  xv = 0,
  momentum = 1,
  x = entity.x,
  y = entity.y,
  health = 3
  }
  spriteLayer.player.body = love.physics.newBody(world, spriteLayer.player.x + spriteLayer.player.w/2,spriteLayer.player.y + spriteLayer.player.h,"dynamic")
  --spriteLayer.player.shape = love.physics.newRectangleShape(20, 29)
  spriteLayer.player.shape = love.physics.newCircleShape(15,15,15) --breaks debug-mode
  spriteLayer.player.fixture = love.physics.newFixture(spriteLayer.player.body, spriteLayer.player.shape, 1)
  spriteLayer.player.fixture:setUserData("Player")
  spriteLayer.player.body:setLinearDamping(2)
  spriteLayer.player.body:setFixedRotation(false)
end

function drawPlayer()
  love.graphics.draw(spriteLayer.player.image, spriteLayer.player.x, spriteLayer.player.y,spriteLayer.player.r, 1, 1, 16, 16)
end

function updatePlayer(dt)
  local player = map.layers["Sprite Layer"].player
  local down = love.keyboard.isDown
  
  if player.health  < 1 then love.filesystem.load("gui/lose.lua")() end
  
  
  local xv, y = player.xv, 0
  local ts = 75 --timescale
  local arfg = player.x
  --if down("down") then y = y + 2002 end
  --process player input
  if down("left") then xv = xv-player.momentum/30*dt*ts end
  if down("right") then xv = xv+player.momentum/30*dt*ts end
  --allows for proper movement with minimal momentum
  if math.abs(player.momentum) < 50 then
    if down("left") then xv = xv-3 end
    if down("right") then xv = xv+3 end
  end
  --basic movement
  player.body:applyForce(xv*dt*ts, 0)
  --player.body:setY(player.body:getY()-1)
  --synchronizes sprite with actual placement
  player.x, player.y = player.body:getWorldCenter()
  
  if arfg-player.x == 0 and not (down("right") or down("left")) and math.abs(xv) > 50 then
    xv = 0
  end
  
  --controls momentum increase when at full speed
  if math.abs(xv) > player.momentum then
    player.momentum = player.momentum+2*math.cos((player.momentum/maxMomentum)*math.pi/2)*dt*ts
    local negation = 0
    if xv >= 0 then
      negation = 1
    else
      negation = -1
    end
    xv = player.momentum*negation
  end
  --controls momentum drop when not moving
  if player.momentum > math.abs(xv) then
    map.layers["Sprite Layer"].player.momentum = player.momentum - 3*dt*ts
  end
  
  --applies the momentum value to the global object/updates the momentum stat
  map.layers["Sprite Layer"].player.momentum = player.momentum
  --same for x-velocity
  map.layers["Sprite Layer"].player.xv = xv
  

  player.x, player.y = player.body:getWorldCenter()
  if player.health > 3 then player.health = 3 end
end