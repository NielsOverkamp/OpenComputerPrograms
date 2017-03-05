-- Author: Simon Struck

-- platform.lua
-- A simple platform-builder.

local rob = require('robot')
local args = {...}
local slot = 1

function place()
  if rob.count(slot) == 0 then
    slot = slot + 1
  end
  rob.select(slot)
  rob.placeDown()
end

if not #args == 2 then
  print("Width: distance to the left")
  print("Height: distance forward")
  print()
  print("Usage: platform <width> <height>")
  os.exit()
end

local width = tonumber(args[1])
local height = tonumber(args[2])

local oddLineNumber = true

rob.forward()

for x=1, width do
  for y=2,height do
    place()
    rob.forward()
  end

  place()

  if oddLineNumber then
    rob.turnLeft()
  else
    rob.turnRight()
  end

  rob.forward()

  if oddLineNumber then
    rob.turnLeft()
  else
    rob.turnRight()
  end

  oddLineNumber = not oddLineNumber
end
