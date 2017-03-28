  local rob = require('robot')

  local api = {}

  api.pos = {
    direction = 0, --X+ = 0; Y+ = 1; X- = 2; Y- = 3
    x = 0,
    y = 0,
    z = 0,
    path = '/home/pos.ser'
  }

  api.autosave = true


  api.waypoints = {
    path = '/home/waypoints.ser'
  }


  function api:load(object)
    if not require('filesystem').exists(object.path) then return object end
    local file = assert(io.open(object.path, 'r'))
    local text = file:read('*all') or ''
    file:close()
    return require('serialization').unserialize(text) or object
  end

  function api:loadPos()
    self.pos = self:load(self.pos)
  end

  function api:loadWaypoints()
    self.waypoints = self:load(self.waypoints)
  end


  function api:save(object)
    local text = require('serialization').serialize(object) or ''
    local file = assert(io.open(object.path, 'w'))
    file:write(text)
    file:close()
  end

  function api:savePos()
    self:save(self.pos)
  end

  function api:saveWaypoints()
    self:save(self.waypoints)
  end



  function api:forward(distance)
    distance = distance or 1
    if self.pos.direction == 0 then
      self.pos.x = self.pos.x + distance
    elseif self.pos.direction == 1 then
      self.pos.y = self.pos.y + distance
    elseif self.pos.direction == 2 then
      self.pos.x = self.pos.x - distance
    elseif self.direction == 3 then
      self.pos.y = self.pos.y - distance
    end

    for i = 1, distance do
      rob.forward()
    end

    if autosave then self:savePos() end
  end

  function api:back(distance)
    distance = distance or 1
    if self.pos.direction == 0 then
      self.pos.x = self.pos.x - distance
    elseif self.pos.direction == 1 then
      self.pos.y = self.pos.y - distance
    elseif self.pos.direction == 2 then
      self.pos.x = self.pos.x + distance
    elseif self.pos.direction == 3 then
      self.pos.y = self.pos.y + distance
    end

    for i = 1, distance do
      rob.back()
    end

    if autosave then self:savePos() end
  end

  function api:up(distance)
    distance = distance or 1
    self.pos.z = self.pos.z + distance

    for i = 1, distance do
      rob.up()
    end

    if autosave then self:savePos() end
  end

  function api:down(distance)
    distance = distance or 1
    self.pos.z = self.pos.z - distance

    for i = 1, distance do
      rob.down()
    end

    if autosave then self:savePos() end
  end

  function api:turnLeft()
    self.pos.direction = (self.pos.direction - 1) % 4
    rob.turnLeft()

    if autosave then self:savePos() end
  end

  function api:turnRight()
    self.pos.direction = (self.pos.direction + 1) % 4
    rob.turnRight()

    if autosave then self:savePos() end
  end

  api.fd = api.forward
  api.bk = api.back
  api.dn = api.down
  api.lt = api.turnLeft
  api.rt = api.turnRight

  function api:addWaypoint(x, y, z)
    x = x or self.pos.x
    y = y or self.pos.y
    z = z or self.pos.z

    waypoints[#waypoints + 1] = {
      x = x,
      y = y,
      z = z
    }
    self:saveWaypoints()
  end

  function api:goTo(waypoint, y, z)
    if typeof(waypoint) == 'table' then
      x = waypoint.x
      y = waypoint.y
      y = waypoint.z
    elseif typeof(waypoint) == 'number' then
      x = waypoint
      y = y or self.pos.y
      z = z or self.pos.z
    else
      x = x or self.pos.x
      y = y or self.pos.y
      z = z or self.pos.z
    end


  end

  api['goto'] = api.goTo


  api:loadPos()
  api:loadWaypoints()


  return api
