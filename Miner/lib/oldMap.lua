local Map = {}

function Map.new(default, directionb, bound)
    return setmetatable({ __default = default, __directionb = directionb, __bound = bound }, Map.mt)
end

Map.mt = {}

function Map.mt.__index(map, key)
    if type(key) == "number" then
        map[key] = Map.Layer.new(map.__default, map.__directionb)
        return rawget(map, key)
    else
        return Map.prototype[key]
    end
end

Map.Layer = {}

function Map.Layer.new(default, directionb)
    return setmetatable({ __default = default, __directionb = directionb }, Map.Layer.mt)
end

Map.Layer.mt = {}

function Map.Layer.mt.__index(layer, key)
    if type(key) == "number" then
        layer[key] = Map.Row.new(layer.__default, layer.__directionb)
    end
    return rawget(layer, key)
end

Map.Row = {}

function Map.Row.new(default, directionb)
    return setmetatable({ __default = default, __directionb = directionb }, Map.Row.mt)
end

Map.Row.mt = {}

function Map.Row.mt.__index(row, key)
    if type(key) == "number" then
        if row.__directionb then
            row[key] = Map.DirectionCell.new(row.__default)
        else
            row[key] = row.__default
        end
    end
    return rawget(row, key)
end

Map.DirectionCell = {}

function Map.DirectionCell.new(default)
    return setmetatable({ __default = default }, Map.DirectionCell.mt)
end

Map.DirectionCell.mt = {}

function Map.DirectionCell.mt.__index(cell, key)
    if type(key) == "number" then
        cell[key] = cell.__default
    end
    return rawget(cell, key)
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

return Map