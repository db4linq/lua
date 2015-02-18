SensorPin = 3

function open()
  print("Open connection...")
  conn=net.createConnection(net.TCP, 0)
  conn:on("receive", function(conn, payload) print(payload) end) 
  conn:connect(8888,"192.168.1.35")
  conn:send("{ \"Type\":\"SOIL\",\"SensorID\":\"".. SensorID .. "\"}")
end

function sendalarm(SensorID,status) 
   conn:send("{ \"Type\": \"SOIL\",\"SensorID\":\"".. SensorID .. "\", \"Status\":\"".. status .."\"}")
end

function close()
  conn:close()
end

open()

SensorID = "2"
status = "LOW"
oldstatus = "LOW"

gpio.mode(SensorPin,gpio.INPUT,gpio.FLOAT)

tmr.alarm(0, 1000, 1, function() -- Set alarm to one second
  if gpio.read(SensorPin)==1 then status="LOW" else status="HIGH" end
  if status ~= oldstatus then sendalarm (SensorID,status) end
  oldstatus = status
end)





