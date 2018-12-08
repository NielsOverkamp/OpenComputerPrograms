local iter = {}

function iter.sphere_cube_coords_iter(opt)
    local d = opt.d or 1
    local min_x = opt.min_x or (- opt.n * d + (opt.x or 0))
    local min_y = opt.min_y or (- opt.n * d + (opt.y or 0))
    local min_z = opt.min_z or (- opt.n * d + (opt.z or 0))
    local max_x = opt.max_x or (opt.n * d + (opt.x or 0))
    local max_y = opt.max_y or (opt.n * d + (opt.y or 0))
    local max_z = opt.max_z or (opt.n * d + (opt.z or 0))
    local x = min_x
    local y = min_y
    local z = min_z
    local done = false
    return function()
        if done then return nil end
        local rx,ry,rz = x, y, z
        x = x + d
        if x > max_x then
            x = min_x
            y = y + d
            if y > max_y then
                y = min_y
                z = z + d
                if z > max_z then
                    done = true
                end
            end
        end
        return rx,ry,rz
    end
end

function iter.cube_coords_iter(n,d,opt)
    opt = opt or {}
    opt.d = d
    opt.min_x = opt.x or 0
    opt.min_y = opt.y or 0
    opt.min_z = opt.z or 0
    opt.max_x = opt.min_x + n -1
    opt.max_y = opt.min_y + n -1
    opt.max_z = opt.min_z + n -1
    return iter.sphere_cube_coords_iter(opt)
end

function iter.sphere_coords_iter(n, d, opt)
    opt = opt or {}
    opt.n = n
    opt.d = d
    local cube_iter = iter.sphere_cube_coords_iter(opt)
    local x0, y0, z0 = opt.x or 0, opt.y or 0, opt.z or 0
    n = n*(d or 1)
    return function()
        local x,y,z
        while true do
            x,y,z = cube_iter()
            if x == nil then
                return nil
            end
            if math.sqrt(math.pow(x-x0,2) + math.pow(y-y0,2) + math.pow(z-z0,2)) <= n then
                return x,y,z
            end
        end
    end
end

function iter.nil_iter()
    return nil
end

return iter