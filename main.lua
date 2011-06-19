
local Object = require "object"
local Friend = require "friend"

local Tester = Object:clone()

function Tester:init(x)
  self.x = x
end

function Tester:echo(...)
  if self.x > 0 then
    self.x = self.x - 1
    print(...)
  end
end

----------------------------------------
local Layer = Object:clone()

function Layer:init()
  self.floor = {}
end

function Layer:set( x, y, entity )
  self.floor[ y*60+x ] = entity
end

function Layer:get( x, y )
  return self.floor[ y*60+x ]
end

function Layer:update()
  local updated = {}
  for y = 0, 24 do
    for x = 0, 59 do
      local entity = self.floor[ y*60+x ]
      if type(entity)=="table" and not updated[entity] then
        entity:update( self, x, y )
        updated[entity] = true
      end
    end
  end
end

function Layer:draw( painter )
  for y = 0, 24 do
    for x = 0, 59 do
      local entity = self.floor[ y*60+x ]
      if type(entity)=="table" then
        entity:draw( painter, x, y )
      end
    end
  end
end

function Layer:move( x, y, nx, ny )
  if x < 0 or y < 0 or x >= 60 or y >= 25 or
    nx < 0 or ny < 0 or nx >= 60 or ny >= 25 then
    return false
  end

  local entity = self.floor[ y*60+x ]
  self.floor[ y*60+x ] = nil
  self.floor[ ny*60+nx ] = entity
  return true
end

----------------------------------------
local Entity = Object:clone()

function Entity:init( char, color )
  self.char = char or 0
  self.color = color or 0
end

function Entity:draw( painter, x, y )
  painter:drawChar( x, y, self.char, self.color )
end

function Entity:update() end

----------------------------------------

local Sprite = Entity:clone()

function Sprite:init( char, color )
  Entity.init( self, char, color )
end

function Sprite:moveDir(d)
  if not d then return end
  local nx, ny = self.x, self.y
  if d == 'up' then ny = ny - 1
  elseif d == 'down' then ny = ny + 1
  elseif d == 'left' then nx = nx - 1
  elseif d == 'right' then nx = nx + 1
  end

  local other = self.layer:get( nx, ny )
  if not other or not other:isA( Sprite ) then
    local ok = self.layer:move( self.x, self.y, nx, ny )
    if ok then self:setPos( nx, ny ) end
  end
end

function Sprite:setPos( x, y )
  self.x = x or 0
  self.y = y or 0
end

function Sprite:update( layer, x, y )
  self:setPos( x, y )
  self.layer = layer
  self:behavior()
end

function Sprite:behavior() end

----------------------------------------

local TestObject = Sprite:clone()

function TestObject:init()
  Sprite.init(self, 1, 7)
end

function TestObject:behavior()
  local x = math.random(25)
  if x <= 3 then
    local d = {"up","down","left","right"}
    self:moveDir( d[x+1] )
  end
end

----------------------------------------

local Player = Sprite:clone()

function Player:init()
  Sprite.init(self, 2, 0)
  self.dir = nil
end

function Player:getDirPressed()
  local d = self.dir
  if not d or not Friend.pressed(d) then
    if Friend.pressed('up') then d = 'up'
    elseif Friend.pressed('down') then d = 'down'
    elseif Friend.pressed('left') then d = 'left'
    elseif Friend.pressed('right') then d = 'right'
    else d = nil
    end
  end
  self.dir = d
end

function Player:behavior()
  self:getDirPressed()
  self:moveDir(self.dir)
end

----------------------------------------

local Painter = Object:clone()

function Painter:init( filename )
  filename = filename or "default.png"
  self:loadTileset(filename)
end

function Painter:loadTileset(filename)
  self.image = love.graphics.newImage( filename )
  self.image:setFilter("nearest", "nearest")
  local sw = self.image:getWidth()
  local sh = self.image:getHeight()
  self.quads = {}
  local i, y = 0, 0
  while y < sh do
    local x = 0
    while x < sw do
      self.quads[i] = love.graphics.newQuad(x, y, 8, 16, sw, sh)
      i, x = i + 1, x + 8
    end
    y = y + 16
  end
end

function Painter:drawChar( x, y, char, color )
  love.graphics.drawq(self.image, self.quads[char], x*8, y*16)
end

----------------------------------------

local Game = Object:clone()

function Game:init()
  self.clock = { max = 1.0 / 30.0, step = 0.0 }
  self.layer = Layer:new()
  self.painter = Painter:new()
  local player = Player:new()
  local sprite = TestObject:new()
  self.layer:set(0, 0, player)
  self.layer:set(30, 15, sprite)
end

function Game:draw()
  love.graphics.setColor( 255, 255, 255 )
  self.layer:draw( self.painter )
end

function Game:update(dt)
  self.clock.step = self.clock.step + dt
  if self.clock.step < self.clock.max then return end
  repeat
    self.clock.step = self.clock.step - self.clock.max
  until self.clock.step < self.clock.max
  self.layer:update()
end

Friend.setState( Game:new() )


