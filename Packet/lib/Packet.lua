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
    lengthInBits = lengthInBits
  }
  setmetatable(field, self)
  self.__index = self
  return field
end

function Packet.NumberField32:getBitAt(disp)
  return bit32.band(bit32.rshift(self.number, disp),1)
end

function Packet.NumberField32:setBitAt(disp, value)
  self.number = self.number + bit32.lshift(bit32.band(value,1),disp)
end

function Packet.NumberField32:length()
  return self.lengthInBits
end

function Packet:addFields(...)
  args = {...}
  for i=1,#args do
    field = args[i]
    checkArg(i,field,"table")
    self.__length =  self.__length + field:length()
    self.fields[#self.fields + 1] = field
  end
end

function Packet:getStringRepresentation()
  result = ""
  currentCharInByte = 0
  bitPointer = 0
  for _, field in ipairs(self.fields) do
    for i = 0, (field:length() - 1) do
      currentCharInByte = currentCharInByte +
        bit32.lshift(field:getBitAt(i),bitPointer)
      bitPointer = bitPointer + 1
      if bitPointer >= 8 then
        bitPointer = 0
        result = result .. string.char(currentCharInByte)
        currentCharInByte = 0
      end
    end
  end
  result = result .. string.char(currentCharInByte)
  return result
end

function Packet:readFromString(packetString)
  print("bitP","i","number")
  byteArray = {string.byte(packetString, 1, #packetString)}
  charPointer = 1
  bitPointer = 0
  for _, field in ipairs(self.fields) do
    for i = 0, (field:length()-1) do
      field:setBitAt(i, bit32.rshift(byteArray[charPointer], bitPointer))
      bitPointer = bitPointer + 1
      print(bitPointer, i, field.number)
      if bitPointer >= 8 then
        bitPointer = 0
        charPointer = charPointer + 1
        if (charPointer > #byteArray) then
          return
        end
      end
    end
  end
end




return Packet
