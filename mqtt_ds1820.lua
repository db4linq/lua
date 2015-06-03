DS_PIN = 4  
ID = 5
temperature = 0
t = require("ds18b20")      

-- init mqtt client with keepalive timer 120sec
clientId=node.chipid()
m = mqtt.Client(clientId, 120, "user", "password")
-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
m:lwt("/lwt", "offline", 0, 0)
m:on("connect", function(con) print ("connected") end)
m:on("offline", 
     function(con) 
          print ("offline") 
          node.restart()
     end
)
-- on publish message receive event
m:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print(data)
  end
end)
function publish()
     temperature = (t.read(DS_PIN)) 
     msg = '{"Id": '..ID..', "Temperature": '..temperature..'}'
     print (msg)
     m:publish("/"..clientId.."/temperature",msg,0,0, function(conn) print("sent") end)
end
function start()
     tmr.alarm(1, 20000, 1, function() 
          if pcall(publish) then
               print("Temp sent OK")
          else
               print("Temp sent err" )
          end
     end)
end
-- iot.eclipse.org
-- broker.mqttdashboard.com
-- subscribe topic with qos = 0
m:connect("192.168.1.36", 1883, 0, 
     function(conn)
               publish()
               start()
     end
)
