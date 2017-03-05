local rob = require('robot')

local args = {...}

if not #args == 1 then
  error("Specify distance!")
end

local distance = tonumber(args[1])

for i=1,distance do
  rob.placeDown()
  rob.forward()
end

rob.placeDown()
