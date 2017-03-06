local rob = require('robot')

local api = {}

api.direction = 0
api.x = 0
api.y = 0
api.z = 0

api.waypoints = {}

function api:forward(distance)
  distance = distance or 1
  if self.direction == 0 then
    self.x = self.x + distance
  elseif self.direction == 1 then
    self.y = self.y + distance
  elseif self.direction == 2 then
    self.x = self.x - distance
  elseif self.direction == 3 then
    self.y = self.y - distance
  end

  for i = 0, distance do
    rob.forward()
  end
end

function api:back(distance)
  distance = distance or 1
  if self.direction == 0 then
    self.x = self.x - distance
  elseif self.direction == 1 then
    self.y = self.y - distance
  elseif self.direction == 2 then
    self.x = self.x + distance
  elseif self.direction == 3 then
    self.y = self.y + distance
  end

  for i = 0, distance do
    rob.back()
  end
end

function api:up(distance)
  distance = distance or 1
  self.z = self.z + distance

  for i = 0, distance do
  rob.up()
  end
end

function api:down(distance)
  distance = distance or 1
  self.z = self.z - distance

  for i = 0, distance do
  rob.down()
  end
end

function api:turnLeft()
  direction = (direction - 1) % 4
  rob.turnLeft()
end

function api:turnRight()
  direction = (direction + 1) % 4
  rob.turnRight()
end

api.fd = api.forward
api.bk = api.back
api.dn = api.down
api.lt = api.turnLeft
api.rt = api.turnRight

function api:addWaypoint(x, y, z)
  x = x or self.x
  y = y or self.y
  z = z or self.z

  waypoints[#waypoints + 1] = {
    x = x,
    y = y,
    z = z
  }
end

function api:goTo(waypoint, y, z)
  if typeof(waypoint) == 'table' then
    x = waypoint.x
    y = waypoint.y
    y = waypoint.z
  elseif typeof(waypoint) == 'number' then
    x = waypoint
    y = y or self.y
    z = z or self.z
  else
    error('invalid call')
  end


end

api["goto"] = api.goTo


return api
