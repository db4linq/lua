gpio.mode(5,gpio.OUTPUT)
gpio.write(5, 0)

io = require("iothink")
io.init("192.168.1.36", 2)

local function spl(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

io.addVariable("heap", function()
     return node.heap()
end)
io.addVariable("temp", function()
     temperature = "35.50"
     humidity = "75.50"
     return '{"id": 2, "temperature": '..temperature..', "humidity": '..humidity..' }'
end)
io.addFunction("rgb", function(param)
     list=spl(payload,",")
     local pin = tonumber(list[1])
     local r = tonumber(list[2]) 
     local g = tonumber(list[3]) 
     local b = tonumber(list[4]) 
     ws2812.writergb(pin, string.char(r, g, b):rep(8)) 
     sendHeader(conn)  
     return '{"result":"ok"}'
end)
io.addFunction("toggle", function(param)
     print("toggle")
     local pin = tonumber(param)
     if gpio.read(pin) == 1 then
          gpio.write(pin, 0)
     else
          gpio.write(pin, 1)
     end     
     return '{ "status": '..gpio.read(pin)..', "coreID": "'.. node.chipid() ..'", "id": '..pin..' }'
end)

io.on("disconnection", function() print("Disconnected..") end)
io.on("connection", function() print("Connected..") end)
io.connect()