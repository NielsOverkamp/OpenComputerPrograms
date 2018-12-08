local Map = {}

function Map.new(halfbound, default, directionb)
    if type(halfbound) ~= "number" then
        error("halfbound must be integer")
    end
    local map = { __default = default, __directionb = directionb, __halfbound = halfbound }
    local bound = halfbound * 2
    if directionb then
        map.__z_step = 4
        map.__y_step = bound * map.__z_step
        map.__x_step = bound * map.__y_step
        map.__i_bound = bound * map.__x_step
    else
        map.__y_step = bound
        map.__x_step = bound * map.__y_step
        map.__i_bound = bound * map.__x_step
    end
    return setmetatable(map, Map.mt)
end

Map.mt = {}

function Map.mt.__index(map, key)
    if type(key) == "number" then
        return map.__default
    else
        return Map.prototype[key]
    end
end

function Map.mt.__call(self, x, y, z, dv, v)
    if self.__directionb then
        if v == nil then
            return Map.prototype.get(self, x, y, z, dv)
        else
            return Map.prototype.set(self, x, y, z, dv, v)
        end
    else
        if dv == nil then
            return Map.prototype.get(self, x, y, z)
        else
            return Map.prototype.set(self, x, y, z, dv)
        end
    end
end

Map.prototype = {}

local function nextnum(t, k)
    local v
    k, v = next(t, k)
    while type(k) ~= "number" and k ~= nil do
        k, v = next(t, k)
    end
    return k, v
end

local function numpairs(t)
    return nextnum, t, nil
end

function Map.prototype.iter(self)
    local layer_iter, _, layer_i = numpairs(self)
    local layer, line, line_i, block_i
    local lines_iter = function()
        return nil
    end
    local blocks_iter = lines_iter
    return function()
        local r
        block_i, r = blocks_iter(line, block_i)
        while not r do
            line_i, line = lines_iter(layer, line_i)
            while not line do
                layer_i, layer = layer_iter(self, layer_i)
                if not layer then
                    return nil
                end
                lines_iter = numpairs(layer)
                line_i, line = lines_iter(layer, line_i)
            end
            blocks_iter = numpairs(line)
            block_i, r = blocks_iter(line, block_i)
        end
        return block_i, layer_i, line_i, r
    end
end

function Map.prototype.add(self, map1, self_priority)
    for x, y, z, v in Map.prototype.iter(map1) do
        self[z] = self[z] or {}
        self[z][y] = self[z][y] or {}
        if (not self_priority) or (self[z][y][x] == nil) then
            self[z][y][x] = v
        end
    end
end

function Map.prototype.get(self, x, y, z, d)
    if self.__directionb then
        if x > self.__halfbound or x <= -self.__halfbound or y > self.__halfbound or y <= -self.__halfbound or z > self.__halfbound or z <= -self.__halfbound or d >= 4 or d < 0 then
            error("invalid index " .. x .. ", " .. y .. ", " .. z .. ", " .. d)
        end
        return self[(x - 1 + self.__halfbound) * self.__x_step + (y - 1 + self.__halfbound) * self.__y_step + (z - 1 + self.__halfbound) * self.__z_step + d + 1]
    else
        if x > self.__halfbound or x <= -self.__halfbound or y > self.__halfbound or y <= -self.__halfbound or z > self.__halfbound or z <= -self.__halfbound then
            error("invalid index " .. x .. ", " .. y .. ", " .. z)
        end
        return self[(x - 1 + self.__halfbound) * self.__x_step + (y - 1 + self.__halfbound) * self.__y_step + z + self.__halfbound]
    end
end

function Map.prototype.set(self, x, y, z, dv, v)
    if self.__directionb then
        if x > self.__halfbound or x <= -self.__halfbound or y > self.__halfbound or y <= -self.__halfbound or z > self.__halfbound or z <= -self.__halfbound or dv >= 4 or dv < 0 then
            error("invalid index " .. x .. ", " .. y .. ", " .. z .. ", " .. dv)
        end
        self[(x - 1 + self.__halfbound) * self.__x_step + (y - 1 + self.__halfbound) * self.__y_step + (z - 1 + self.__halfbound) * self.__z_step + dv + 1] = v
    else
        if x > self.__halfbound or x <= -self.__halfbound or y > self.__halfbound or y <= -self.__halfbound or z > self.__halfbound or z <= -self.__halfbound then
            error("invalid index " .. x .. ", " .. y .. ", " .. z)
        end
        self[(x - 1 + self.__halfbound) * self.__x_step + (y - 1 + self.__halfbound) * self.__y_step + z + self.__halfbound] = dv
    end
end

function Map.prototype.within(self, x, y, z, dv)
    if self.__directionb then
        if x > self.__halfbound or x <= -self.__halfbound or y > self.__halfbound or y <= -self.__halfbound or z > self.__halfbound or z <= -self.__halfbound or dv >= 4 or dv < 0 then
            return false
        else
            return true
        end
    else
        if x > self.__halfbound or x <= -self.__halfbound or y > self.__halfbound or y <= -self.__halfbound or z > self.__halfbound or z <= -self.__halfbound then
            return false
        else
            return true
        end
    end
end

return Map