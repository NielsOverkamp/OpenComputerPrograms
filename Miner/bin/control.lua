local com = require("com")
local scan = require("scan")

for vein in scan.find_ore_iter() do
    print("sending vein at coordinate")
    print(table.unpack(vein[1]))
    com.send(vein)
end
