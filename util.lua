
local io = io
local math = math
local table = table
local type = type

----------------------------------------
local util = {}
----------------------------------------

local function sortcomp( l, r )
  if type(l)=="number" and type(r)=="string" then return false end
  if type(l)=="string" and type(r)=="number" then return true end
  return l < r
end

function util.print_r(t, indent)
  if not t then return end
  local indent=indent or ''
  local keys = {}
  for k, _ in pairs(t) do
    keys[#keys+1]=k
  end
  table.sort( keys, sortcomp )
  for _, key in ipairs(keys) do
    local value = t[key]
    io.write(indent,'[',tostring(key),']') 
    if type(value)=="table" then io.write(':\n') util.print_r(value,indent..' ')
    else io.write(' = ',tostring(value),'\n') end
  end
end

function util.bounded( a, b, c )
  return math.max( a, math.min( b, c ) )
end

function util.random( l, r )
  local d = math.random( 0, 10000 ) / 10000 
  return l + (d * (r - l))
end

function util.fuzzycmp( x, y )
  local r = math.abs(x - y)
  return ( ( r < 0.001 ) and true ) or false
end

function util.shuffle( list )
  local N = #list
  for i = 1, N do
    local x = math.random( i, N )
    list[i], list[x] = list[x], list[i]
  end
end

function util.truncate( x, p )
  p = p or 1
  return math.floor(x/p)*p
end

function util.coErrorWrap(...)
  local ok = select(1, ...)
  local mesg = select(2, ...)
  if not ok then error(message) end
  return ...
end

----------------------------------------

local Queue = {}
util.Queue = Queue

function Queue:new()
  local t = { front=0, back=0 }
  t.__index = self
  return setmetatable( t, t )
end

function Queue:size()
  return self.back - self.front
end

function Queue:pushFront(x)
  self.front = self.front - 1
  self[self.front] = x
end

function Queue:pushBack(x)
  self[self.back] = x
  self.back = self.back + 1
end

function Queue:popFront()
  if self.front >= self.back then return end
  local v = self[self.front]
  self[self.front] = nil
  self.front = self.front + 1
  if self.front >= self.back then self.front, self.back = 0, 0 end
  return v
end

function Queue:popBack()
  if self.front >= self.back then return end
  self.back = self.back - 1
  local v = self[self.back]
  self[self.back] = nil
  if self.front >= self.back then self.front, self.back = 0, 0 end
  return v
end

function Queue:clear()
  for i = self.front, self.back do
    self[i] = nil
  end
  self.front, self.back = 0, 0
end

----------------------------------------
return util
----------------------------------------

