--Author Niels Overkamp

--build.lua
--Provides an api to build virtually any structure
--its function 'build' needs:
-- -a function taking the arguments x, y, and returning true or false
--    corresponding to respectively an empty or filled spot
-- -the lower and upper pairs of respectively x, y, and z (inclusive)

arms = require "arms"
robot = require "robot"

build = {}

function build.execute(func, lowerX, upperX, lowerY, upperY, lowerZ, upperZ)
  arms.pos = {
    direction = 0,
    x = 0,
    y = 0,
    z = 0
  }
  direction = 0
  arms.autosave = false
  right = true
  for z = lowerZ, upperZ do
    arms:up()
    for y = lowerY, upperY do
      for x = lowerX, upperX do
        if isTurningPoint(x, y, z, lowerX, upperX, lowerY, upperY, lowerZ, upperZ) then
          if direction < 2 then
            arms:turnRight()
          else
            arms:turnLeft()
          end
          direction = (direction + 1) % 4
        end
        if func(arms.pos.x,arms.pos.y,arms.pos.z-1) then
          robot.placeDown()
        end
        arms:forward()
        event.timeout = 1
        repeat
          _,_,id = event.pull("key_up")
        until id == 113
      end
    end
    arms:turnRight()
    arms:turnRight()
  end
end


function isTurningPoint(x, y, z, lowerX, upperX, lowerY, upperY, lowerZ, upperZ)
  return ((x == upperX) and (y ~= upperY)) or ((x == lowerX) and (y~=lowerY))
end

return build
