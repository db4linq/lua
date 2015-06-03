Temperature = 0
t = require("ds18b20")      
t.setup(4)
key = "BW2QUW86FJ96DGIG"

--load DHT11 module and read sensor
function ReadDS1820(pin)
     addrs = t.addrs()
     if (addrs ~= nil) then
       print("Total DS18B20 sensors: "..table.getn(addrs))
     end
     Temperature = (t.read())
     -- Just read temperature
     print("Temperature: "..Temperature.."'C")
end

function sendData()
     ReadDS1820(4)     
     -- conection to thingspeak.com
     print("Sending data to thingspeak.com")
     conn=net.createConnection(net.TCP, 0) 
     conn:on("receive", function(conn, payload) print(payload) end)
     -- api.thingspeak.com 184.106.153.149
     conn:connect(80,'184.106.153.149') 
     conn:send("GET /update?key="..key.."&field3="..Temperature.." HTTP/1.1\r\n") 
     conn:send("Host: api.thingspeak.com\r\n") 
     conn:send("Accept: */*\r\n") 
     conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
     conn:send("\r\n")
     conn:on("sent",function(conn)
          print("Closing connection")
          conn:close()
     end)
     conn:on("disconnection", function(conn)
          print("Got disconnection...")
    end)
end

tmr.alarm(0, 10000, 1, function() sendData() end )