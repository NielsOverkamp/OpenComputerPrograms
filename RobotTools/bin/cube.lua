args = {...}
if #args < 1 then
  print "Usage cube <size>"
  return
else
  size = tonumber(args[1])
  if not size then
    print "Usage cube <size>"
    return
  end
end




function func(x,y,z)
  print("pos = ",x,y,z)
  return
    (x == size-1) or (x == 0) or
    (y == size-1) or (y == 0) or
    (z == size-1) or (z == 0)
end


build = require "build"

build.execute(func,1,size,1,size,1,size)
