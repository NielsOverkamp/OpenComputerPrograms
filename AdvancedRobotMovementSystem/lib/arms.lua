local rob = require('robot')

local api = {}

api.direction = 0
api.x = 0
api.y = 0
api.z = 0

api.waypoints = {}

function api:fwd(distance=1)
  if api.direction == 0 then
    api.x = api.x + distance
  elseif api.direction == 1 then
    api.y = api.y + distance
  elseif api.direction == 2 then
    api.x = api.x - distance
  elseif api.direction == 3 then
    api.y = api.y - distance
  end

  for i = 0, distance do
    rob.forward()
  end
end

function api:back(distance=1)
  if api.direction == 0 then
    api.x = api.x - distance
  elseif api.direction == 1 then
    api.y = api.y - distance
  elseif api.direction == 2 then
    api.x = api.x + distance
  elseif api.direction == 3 then
    api.y = api.y + distance
  end

  for i = 0, distance do
    rob.back()
  end
end

function api:up(distance=1)
  api.z = api.z + distance

  for i = 0, distance do
  rob.up()
  end
end

function api:down(distance=1)
  api.z = api.z - distance

  for i = 0, distance do
  rob.down()
  end
end

function api:turnLeft()
  direction = direction - 1
  if direction < 0 then
    direction = 3
  end
  rob.turnLeft()
end

function api:turnRight()
  direction = direction + 1
  if direction > 3 then
    direction = 0
  end
  rob.turnRight()
end

function api:addWaypoint(x, y, z)
  x = x or api.x
  y = y or api.y
  z = z or api.z

  waypoints[#waypoints + 1] = {
    x = x,
    y = y,
    z = z
  }
end

function api:goto(waypoint, y, z)
  if typeof(waypoint) == 'table' then
    x = waypoint.x
    y = waypoint.y
    y = waypoint.z
  elseif typeof(waypoint) == 'number' then
    x = waypoint
    y = y or api.y
    z = z or api.z
  else
    error('invalid call')
  end


end


return api
