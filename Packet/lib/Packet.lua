Packet = {}


function Packet:new()
  packet = {
    __length = 0,
    fields = {}
  }
  setmetatable(packet, self)
  self.__index = self
  return packet
end

Packet.NumberField32 = {}

function Packet.NumberField32:new(number, lengthInBits)
  field = {
    number = number,
    length = lengthInBits
  }
  setmetatable(field, self)
  self.__index = self
  return field
end

function Packet.NumberField32:getBitAt(disp)
  return bit32.band(bit32.rshift(self.content, disp),1)
end

function Packet.NumberField32:length()
  return self.length
end

function Packet:addFields(...)
  for i=1,#arg do
    field = arg[i]
    checkArg(i,field,"table")
    self.__length =  self.__length + field:length()
    self.fields[#self] = field
  end
end

function Packet:getStringRepresentation()
  result = ""
  currentCharInByte = 0
  bitPointer = 0
  for _, field in ipairs(self.fields) do
    for i = 0, field:length() do
      currentCharInByte = currentCharInByte +
        bit32.lshift(bitPointer,field:getBitAt(i))
      bitPointer = bitPointer + 1
      if bitPointer >= 8 then
        bitPointer = 0
        result = result .. string.char(currentCharInByte)
        currentCharInByte = 0
      end
    end
  end
  return result
end




return Packet
