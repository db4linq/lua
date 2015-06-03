gpio.mode(5,gpio.OUTPUT)
gpio.mode(6,gpio.OUTPUT)
gpio.mode(7,gpio.OUTPUT)
gpio.write(5, 0)
gpio.write(6, 0)
gpio.write(7, 0)
io = require("iothink")
io.init(2, "Relay-88") 

io.addFunction("toggle", function(param)
     local pin = tonumber(param)
     if pin ~= nil then 
          print("Pin: " .. pin) 
          if gpio.read(pin) == 1 then
               gpio.write(pin, 0)
          else
               gpio.write(pin, 1)
          end
     end
     return '{ "status": '..gpio.read(pin)..', "pin": '..pin..' }'
end)
io.connect()
