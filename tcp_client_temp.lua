SensorID = node.chipid()
local humidity = 0
local temperature = 0 
server = "192.168.1.36"
port = 8888
PIN = 0
DHT= require("dht_lib")

function readTemp()
    DHT.read11(PIN)
    temperature = DHT.getTemperature()
    humidity = DHT.getHumidity()
end

function open()
  print("Open connection...")
  conn=net.createConnection(net.TCP, 0)
  conn:on("receive", function(conn, payload) print(payload) end) 
  conn:on("disconnection", function()  
    print("Disconnection..")  
  end)
  conn:on("reconnection", function() 
    print("Reconnection..") 
  end)
  conn:on("connection", function() 
    print("Connected..")
    conn:send("{ \"Type\":\"TEMP\",\"SensorID\":\"".. SensorID .. "\"}") 
  end) 
  conn:connect(port, server)  
end

function sebddaa() 
   readTemp()
   if (humidity ~= nil) then
        conn:send('{ "Type": "TEMP", "SensorID":'.. SensorID .. ', "temperature": '..temperature..', "humidity": '..humidity..'}')
   end
end

function close()
  conn:close()
end
open()
sebddaa()
tmr.alarm(0, 5000, 1, function() -- Set alarm to one second
    sebddaa()
end)
