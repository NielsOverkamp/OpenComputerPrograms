local component = require("component")
local hologram = component.hologram
local map_util = require("map")

local holo = {}

function holo.draw_map(map, map_offset)
    local ox, oy, oz = table.unpack(map_offset)
    for x,y,z,v in map_util.map_iter(map) do
        if v == 0 then
            v = 0
        elseif v ~= 0 and v < 2.5 then
            v = 1
        elseif v < 3.5 then
            v = 2
        elseif v < 98 then
            v = 1
        else
            v = 3
        end
        holo.draw(x-ox, y-oy, z-oz, v)
    end
end

function holo.draw_map_part(_iter, map,map_offset)
    local ox,oy,oz = table.unpack(map_offset)
    for x,y,z in _iter do
        holo.draw(x, y, z, (map and (map[y+oy][z+oz][x+ox] ~= 0) or (not map)))
    end
end

function holo.draw(x,y,z,v)
    hologram.set(x+24,y+16,z+24,v)
end

return holo