local com = require("com")
local robot = require("robot")
local path = require("path")

local pos = { -5, 0, 4, 1 }
local inverse_step = {}
inverse_step.forward = "back"
inverse_step.back = "forward"
inverse_step.turnRight = "turnLeft"
inverse_step.turnLeft = "turnRight"
inverse_step.up = "down"
inverse_step.down = "up"

local mine_step = {}
mine_step.forward = function()
    robot.swingUp();
    robot.swing()
end
mine_step.up = function()
    robot.swing();
    robot.swingUp()
end
mine_step.down = function()
    robot.swing();
    robot.swingDown()
end

while true do
    local vein = com.receive()
    local ps = {}
    if vein[1] then
        local cur_pos = pos
        for _, coord in ipairs(vein) do
            print("heading to", coord[1], coord[2], coord[3])
            local p, dir = path.find(cur_pos, coord)
            if p then
                table.insert(ps, p)
                for i = #p, 1, -1 do
                    local step = p[i]
                    if mine_step[step] then
                        mine_step[step]()
                    end
                    robot[step]()
                end
            else
                print("no path found")
            end
            cur_pos = coord
            cur_pos[4] = dir
        end
        while #ps > 0 do
            local p = table.remove(ps)
            for i = 1, #p do
                local step = inverse_step[p[i]]
                if mine_step[step] then
                    mine_step[step]()
                end
                robot[step]()
            end
        end
    else
        break
    end
end