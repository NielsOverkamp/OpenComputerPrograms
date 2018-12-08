local component = require("component")
local geolyzer = component.geolyzer
local Map = require("oldMap")
local iter = require("iter")

local scan = {}

scan.scan_radius = 8 -- with a 4x4x4 resolutions, so radius of 8 will correspond to about 32 blocks across

function scan.scan(x,y,z,r)
    local times = scan.get_scan_times(scan.get_furthest_distance(x,y,z,4,4,4))
    r = r or Map.new(0)
    for _=1, times do
        local scan_result = geolyzer.scan(x,z,y,4,4,4)
        local i = 1
        for yr=y,y+3 do
            for zr=z,z+3 do
                for xr=x,x+3 do
                    r[yr][zr][xr] = r[yr][zr][xr] + (scan_result[i]/times)
                    i = i + 1
                end
            end
        end
    end
    return r
end

function scan.scan_sphere_iter(opt)
    opt = opt or {}
    local iter_opt = {x=opt.x, y=opt.y, z=opt.z}
    local coords_iter = iter.sphere_coords_iter(scan.scan_radius, 4, iter_opt)
    return function()
        local x,y,z = coords_iter()
        if x then
            return x,y,z, function (r) return scan.scan(x,y,z,r) end
        else
            return x
        end
    end
end

local function list(iterable, inv, ...)
    local r = {}
    local _r = {}
    local i = 0
    local v = {...}
    while true do
        v = {iterable(inv, table.unpack(v))}
        if #v == 0 then
            return r, _r, i
        end
        i = i + 1
        r[i] = v[1]
        _r[i] = v
    end
end

function scan.scan_sphere(opt)
    opt = opt or {}
    opt.acc_r = true
    local r
    for x,y,z,f in scan.scan_sphere_iter(opt) do
        print("scanning...", x,y,z)
        r = f(r)
    end
    return r
end

function scan.get_scan_times(distance)
    if distance < 8 then
        return 1
    end
    if distance <= 16 then
        return distance - 7
    end
    if distance <= 32 then
        return 2*distance - 23
    end
    error("distance "..distance.." too far")
end

function scan.get_furthest_distance(x,y,z,w,d,h)
    if x < 0 then
        w = 0
    end
    if y < 0 then
        h = 0
    end
    if z < 0 then
        d = 0
    end
    return math.ceil(math.sqrt(math.pow(x+w,2)+math.pow(y+h,2)+math.pow(z+d,2)))
end


local function flood_fill(map, x,y,z, f)
    local filled = {{x,y,z}}
    local frontier = {{x,y,z}}
    local found = Map.new(false)
    found[y][z][x] = true
    while #frontier > 0 do
        local source = table.remove(frontier)
        for dim=1,3 do
            for d =-1,1,2 do
                local dest = {source[1],source[2],source[3]}
                dest[dim] = dest[dim] + d
                if f(map[dest[2]][dest[3]][dest[1]]) and (not found[dest[2]][dest[3]][dest[1]]) then
                    found[dest[2]][dest[3]][dest[1]] = true
                    table.insert(frontier, dest)
                    table.insert(filled, dest)
                end
            end
        end
    end
    return filled
end

function scan.find_ore_iter(opt)
    local scan_iter = scan.scan_sphere_iter(opt)
    local current_map_iter = iter.nil_iter
    local found = Map.new(false)
    local map
    return function()
        local x, y, z, v
        repeat
            x, y, z, v = current_map_iter()
            while x == nil do
                local _,_,_,f = scan_iter()
                if f then
                    map = f()
                    current_map_iter = map:iter()
                    x, y, z, v = current_map_iter()
                else
                    return nil
                end
            end
        until scan.in_ore_range(v) and (not found[y][z][x])
        local ore_coords =  flood_fill(map, x, y, z, scan.in_ore_range)
        for _,r in ipairs(ore_coords) do
            found[r[2]][r[3]][r[1]] = true
        end
        return ore_coords
    end
end


function scan.in_ore_range(v)
    return (v < 3.5) and (v >= 2.5)
end

return scan