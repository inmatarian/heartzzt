-- Lightweight Object Class system

local Object = {}
function Object:clone(def)
  def = def or {}
  def.__index = self
  return setmetatable( def, def )
end

function Object:new(...)
  local inst = self:clone()
  inst:init(...)
  return inst
end

function Object:isA(class)
  while self and self ~= class do self = self.__index end
  return self == class
end

function Object:init() end

return Object

