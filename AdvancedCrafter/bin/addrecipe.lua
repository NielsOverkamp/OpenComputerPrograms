t = require('component').transposer
sides = require('sides')

possible_sides = {}

function getSideName(side)
  local lookup = {}
  lookup[sides.left] = 'left'
  lookup[sides.right] = 'right'
end

local itemcount = 0
for i=1,6 do
  itemcount = t.getInventorySize(i)
  if (itemcount or 0) > 0 then
    possible_sides[#possible_sides+1] = {name = getSideName(i), count = itemcount}
  end
end

print('===============')

for k,side in pairs(sides) do
  print(k .. side)
emd
