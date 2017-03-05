local t = require('component').transposer
local side = require('sides')
local args = {...}
local sourceinv = side.left
local targetinv = side.right

local recipies = {}
recipies[#recipies+1] = {''}

function checkSource()
  return t.getStackInSlot(sourceInv, 1) ~= nil
end

function getInvContent(side)
  local content = {}
  for i=1, t.getInventorySize()
end

function findItem(name)
  for slot=1,t.getInventorySize(sourceInv) do
    if t.getStackInslot(sourceInv, slot).name == name then
      return slot
  end
  return nil
end

for p=1,t.getInventorySize(i) do
    item = t.getStackInSlot(i,p)
    if item then
      print('Side: ' .. i)
      print('Slot: ' .. p)
      print('Name: ' .. item.name)
      print('Count: ' .. item.size)
      print('Damage: ' .. item.damage)
    end
  end
end

while true do
  if chechSource() then

  else
    sleep(10)
  end
end
