io = require("iothink")
local humidity = 0
local temperature = 0 
PIN = 5
DHT= require("dht_lib")
io.init(2, "Temperature-01") 

function readTemp()
    DHT.read11(PIN)
    temperature = DHT.getTemperature()
    humidity = DHT.getHumidity()
end

io.addVariable("temp", function()
     readTemp()     
     print("Humidity:    "..humidity.."%")
     print("Temperature: "..temperature.." deg C") 
     return '{"temperature": '..temperature..', "humidity": '..humidity..' }'
end)

io.connect()
