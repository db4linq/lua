io = require("iothink")
io.init(2, "DS18b20-03") 
temperature = 0
t = require("ds18b20")      

io.addVariable("temp", function()
     temperature = (t.read(4)) 
     if temperature ~= nil then    
          print("Temperature: "..temperature.." deg C") 
          return '{"temperature": '..temperature.. '}'
     end
end)
io.connect()
