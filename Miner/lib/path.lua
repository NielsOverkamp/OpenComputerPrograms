local Map = require("Map")
local iter = require("iter")
local Heap = require("heap")

local MAPBOUND = 32

local DEBUG = false
function debug_print()

end

if DEBUG then
    debug_print = function(...)
        print(...);
        io.read()
    end
end

local path = {}

function path.manhattan(from, to)
    local xdif = to[1] - from[1]
    local zdif = to[3] - from[3]
    local ddif = 0
    if xdif > 0 then
        if zdif > 0 then
            if (from[4] == 2) or (from[4] == 3) then
                ddif = 2
            else
                ddif = 1
            end
        elseif zdif < 0 then
            if (from[4] == 1) or (from[4] == 2) then
                ddif = 2
            else
                ddif = 1
            end
        else
            if (from[4] == 1) or (from[4] == 3) then
                ddif = 1
            elseif (from[4] == 2) then
                ddif = 2
            end
        end
    elseif xdif < 0 then
        if zdif > 0 then
            if (from[4] == 0) or (from[4] == 3) then
                ddif = 2
            else
                ddif = 1
            end
        elseif zdif < 0 then
            if (from[4] == 1) or (from[4] == 0) then
                ddif = 2
            else
                ddif = 1
            end
        else
            if (from[4] == 1) or (from[4] == 3) then
                ddif = 1
            elseif (from[4] == 0) then
                ddif = 2
            end
        end
    else
        if zdif > 0 then
            if (from[4] == 0) or (from[4] == 2) then
                ddif = 1
            elseif (from[4] == 3) then
                ddif = 2
            end
        elseif zdif < 0 then
            if (from[4] == 0) or (from[4] == 2) then
                ddif = 1
            elseif (from[4] == 1) then
                ddif = 2
            end
        end
    end
    return math.abs(xdif) + math.abs(zdif) + math.abs(to[2] - from[2]) + ddif
end

path.actions = {}

path.directions = { { 1, 0 }, { 0, 1 }, { -1, 0 }, { 0, -1 } }

path.actions = { { mutate = function(coord)
    return { coord[1] + path.directions[coord[4] + 1][1], coord[2], coord[3] + path.directions[coord[4] + 1][2], coord[4] }
end,
                   name = "forward"
                 },
    --                 { mutate = function(coord)
    --    return { coord[1] - path.directions[coord[4] + 1][1], coord[2], coord[3] - path.directions[coord[4] + 1][2], coord[4] }
    --end,
    --                      name = "back"
    --                 },
                 { mutate = function(coord)
                     return { coord[1], coord[2], coord[3], (coord[4] + 1) % 4 }
                 end,
                   name = "turnRight"
                 }, { mutate = function(coord)
        return { coord[1], coord[2], coord[3], (coord[4] - 1) % 4 }
    end,
                      name = "turnLeft"
                 }, { mutate = function(coord)
        return { coord[1], coord[2] + 1, coord[3], coord[4] }
    end,
                      name = "up"
                 }, { mutate = function(coord)
        return { coord[1], coord[2] - 1, coord[3], coord[4] }
    end,
                      name = "down"
                 } }

--local include_base = {{-2,-2,-1,4,5,9},{-3,-2,4,-2,5,9}}
local forbidden = {{-7,-2,-1,4,5,6}}
local allowed = {{-5,0,4,-5,5,4}}
--local forbidden = { { -4, -4, -4, 4, 4, 4 } }
--local allowed = { { 0, 0, 0, 0, 4, 0 } }
path.allowed = Map.new(MAPBOUND, true)
for _, rect in ipairs(forbidden) do
    for x, y, z in iter.sphere_cube_coords_iter({ min_x = rect[1], min_y = rect[2], min_z = rect[3], max_x = rect[4], max_y = rect[5], max_z = rect[6] }) do
        path.allowed(x, y, z, false)
    end
end
for _, rect in ipairs(allowed) do
    for x, y, z in iter.sphere_cube_coords_iter({ min_x = rect[1], min_y = rect[2], min_z = rect[3], max_x = rect[4], max_y = rect[5], max_z = rect[6] }) do
        path.allowed(x, y, z, true)
    end
end

function path.compare_f(c1, c2)
    if c1.f < c2.f then
        return true
    elseif c1.f == c2.f then
        return c1.h < c2.h
    else
        return false
    end
end

function path.find(from, to)
    debug_print("finding path from ", table.unpack(from))
    debug_print("to ", table.unpack(to))
    local frontier = Heap:new(path.compare_f)
    local visited = Map.new(MAPBOUND, false, true)
    local cameBy = Map.new(MAPBOUND, nil, true)
    local gscore = Map.new(MAPBOUND, nil, true)
    local current, neighbour

    from.h = path.manhattan(from, to)
    from.g = 0
    from.f = from.h + from.g
    frontier:insert(from, true)
    gscore(from[1], from[2], from[3], from[4], from.g)

    while not frontier:empty() do
        current = frontier:pop()
        if current[1] == to[1] and current[2] == to[2] and current[3] == to[3] then
            return path.reconstruct(cameBy, current), current[4]
        end

        visited(current[1], current[2], current[3], current[4], true)

        for _, action in ipairs(path.actions) do
            neighbour = action.mutate(current)
            if visited:within(neighbour[1], neighbour[2], neighbour[3], neighbour[4]) and (not visited(neighbour[1], neighbour[2], neighbour[3], neighbour[4]))
                    and (path.allowed(neighbour[1], neighbour[2], neighbour[3])) then
                neighbour.g = current.g + 1
                if (gscore(neighbour[1], neighbour[2], neighbour[3], neighbour[4]) == nil) or
                        (gscore(neighbour[1], neighbour[2], neighbour[3], neighbour[4]) > neighbour.g) then
                    neighbour.h = path.manhattan(neighbour, to)
                    neighbour.f = neighbour.g + neighbour.h
                    frontier:insert(neighbour, true)
                    gscore(neighbour[1], neighbour[2], neighbour[3], neighbour[4], neighbour.g)
                    cameBy[neighbour] = { action = action.name, cameFrom = current }
                end
            end
        end
    end
    error("path not found")
end

function path.reconstruct(cameBy, current)
    local r = {}
    local by = cameBy[current]
    while by do
        table.insert(r, by.action)
        current = by.cameFrom
        by = cameBy[current]
    end
    return r
end

return path