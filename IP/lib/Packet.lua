Packet = {}


function Packet:new()
  packet = {
    __length = 16,
  }
  setmetatable(packet, self)
  self.__index = self
  return packet
end

Packet.Field = {}

function Packet.Field:new(content,lengthInBits)
  field = {
    content = content,
    lengthInBits = lengthInBits
  }
  return field
end

function Packet:addField(content, lengthInBits, fieldName)
  checkArg(1,content,"string","number","boolean")
  self:incrementLength(content, lengthInBits)
  fieldName = fieldName or (#self + 1)
  self[fieldName] = self.Field:new(content,lengthInBits)
end

function Packet:incrementLength(content, lengthInBits)
  if (type(content) == "number") then
    checkArg(2,lengthInBits,"number")
    self.__length = self.__length + lengthInBits
  elseif (type(content) == "string") then
    if not lengthInBits then
      lengthInBits = #content
    else
      checkArg(2,lengthInBits,"number")
    end
    if lengthInBits < 1 then
      self.__length = self.__length + 8
    else
      self.__length = self.__length + lengthInBits
    end
  else
    self.__length = self.__length + 1
  end
end



return Packet
