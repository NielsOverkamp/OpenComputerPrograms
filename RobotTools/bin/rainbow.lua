args = {...}

startColor = {}
if (#args >= 1) then
  if #args >= 3 then
    startColor = {r=tonumber(args[1]),g=tonumber(args[2]),b=tonumber(args[3])}
  else
    startColor = light.tools.toRGB(args[1])
  end
else
  startColor = {r=255,g=0,b=0}
end

light = require "light"
max = math.max(startColor.r,startColor.g,startColor.b)
min = math.min(startColor.r,startColor.g,startColor.b)
toString = {"r","g","b"}
maxI = 0
minI = 0
varI = 0
for i=1, 3 do
  if (max == startColor[toString[i]]) and (maxI == 0) then
    maxI = i
  elseif min == startColor[toString[i]] and (minI == 0) then
    minI = i
  else
    varI = i
  end
end
color = {
  startColor.r,
  startColor.g,
  startColor.b
}
--206 48 62
--245 4 67
function color:equals(color)
  return (self[1] == color.r)
  and (self[2] == color.g)
  and (self[3] == color.b)
end
step = 32
if ((varI + 1) % 3) == minI then
  step = step * -1
end

repeat
  repeat
    color[varI] = math.max(math.min(color[varI] + step,max),min)
    light.setRGB(color)
  until (color[varI] >= max) or (color[varI] <= min)
  if (step > 0) then
    oldMaxI = maxI
    maxI = varI
    varI = oldMaxI
  else
    oldMinI = minI
    minI = varI
    varI = oldMinI
  end
  step = step * -1
until color:equals(startColor)
