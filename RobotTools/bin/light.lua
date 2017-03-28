local robot = require "robot"
local os = require "os"


local light = {
  tools = {}
}

function light.set(arg)
  light.setDec(light.tools.toDec(arg))
end

function light.tools.toDec(arg)
  if type(arg) == "number" then
    return arg
  elseif type(arg) == "string" then
    return light.tools.hexToDec(arg)
  elseif type(arg) == "table" then
    return light.tools.RGBToDec(arg)
  else
    error("invalid input")
  end
end

function light.tools.hexToDec(hexString)
  if (string.sub(hexString,1,2) == "0x") then
    return tonumber(hexString)
  else
    return tonumber(hexString,16)
  end
end

function light.tools.RGBToDec(rgbTable)
  rgbTable = light.tools.RGBtoRGB(rgbTable)
  return rgbTable.r*256*256 + rgbTable.g*256 + rgbTable.b
end

function light.tools.toRGB(arg)
  if type(arg) == "table" then
    return light.tools.RGBtoRGB(arg)
  elseif type(arg) == "string" then
    return light.tools.hexToRGB(arg)
  elseif type(arg) == "number" then
    return light.tools.decToRGB(arg)
  else
    error("invalid input")
  end
end

function light.tools.RGBtoRGB(rgbTable)
  return {
    r = (rgbTable.r or rgbTable[1]) or 0,
    g = (rgbTable.g or rgbTable[2]) or 0,
    b = (rgbTable.b or rgbTable[3]) or 0
  }
end


function light.tools.decToRGB(number)
  b = number % 256
  g = ((number - b) % (256*256)) / 256
  r = ((number - b - g)) / (256*256)
  return {r = r, g = g, b = b}
end

function light.tools.hexToRGB(hexString)
  if (string.sub(hexString,1,2) == "0x") then
    hexString = string.sub(hexString,3,#hexString)
  end
  return {
    r=tonumber(string.sub(hexString,1,2),16),
    g=tonumber(string.sub(hexString,3,4),16),
    b=tonumber(string.sub(hexString,5,6),16)
  }
end

function light.setDec(number)
  return robot.setLightColor(number)
end

function light.setHex(hexString)
  return light.setDec(light.tools.hexToDec(hexString))
end

function light.setRGB(rgbTable)
  return light.setDec(light.tools.RGBToDec(rgbTable))
end


return light
