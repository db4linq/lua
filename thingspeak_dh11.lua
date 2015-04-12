dht11 = require("dht11")
Temperature = 0
Humidity = 0
key = "BW2QUW86FJ96DGIG"

PIN = 4 --  data pin, GPIO2
--load DHT11 module and read sensor
function ReadDHT11()  
     dht11.init(PIN)
     t = dht11.getTemp()
     h = dht11.getHumidity()
     Humidity=(h)
     Temperature=(t)
     --fare=((Temperature*9/5)+32)
     print("Humidity:    "..Humidity.."%")
     print("Temperature: "..Temperature.." deg C")
     --print("Temperature: "..fare.." deg F") 
end

function sendData()
     ReadDHT11()     
     -- conection to thingspeak.com
     print("Sending data to thingspeak.com")
     conn=net.createConnection(net.TCP, 0) 
     conn:on("receive", function(conn, payload) print(payload) end)
     -- api.thingspeak.com 184.106.153.149
     conn:connect(80,'184.106.153.149') 
     conn:send("GET /update?key="..key.."&field1="..Temperature.. "&field2="..Humidity.. " HTTP/1.1\r\n") 
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
