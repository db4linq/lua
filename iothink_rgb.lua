io = require("iothink")
io.init(2, "RGB-01")
io.addFunction("rgb", function(param)
     -- param = pin,r,g,b
     _, _, pin, r, g, b = string.find(param, "([0-9]+),([0-9]+),([0-9]+),([0-9]+)")
     ws2812.writergb(tonumber(pin), string.char(tonumber(r), tonumber(g), tonumber(b)):rep(8))
     return '{"result":"ok"}'
end)
io.connect()


