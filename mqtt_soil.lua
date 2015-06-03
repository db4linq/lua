SOIL1 = 5  
SOIL2 = 6
gpio.mode(SOIL1,gpio.INPUT,gpio.FLOAT)
gpio.mode(SOIL2,gpio.INPUT,gpio.FLOAT)
ID = 1
status_soil2 = "HIGH"
oldstatus_soil2 = "HIGH"
status_soil3 = "HIGH"
oldstatus_soil3 = "HIGH"
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
function connect()
     -- iot.eclipse.org
     -- broker.mqttdashboard.com
     -- subscribe topic with qos = 0
     m:connect("192.168.1.36", 1883, 0, 
          function(conn) 
               print("connected") 
               publish()
               start()
          end
     )
end

function publish()
     if gpio.read(SOIL1)==1 then status_soil2="LOW" else status_soil2="HIGH" end
     --if status_soil2 ~= oldstatus_soil2 then sendalarm (1, status_soil2) end
     oldstatus_soil2 = status_soil2
     
     if gpio.read(SOIL2)==1 then status_soil3="LOW" else status_soil3="HIGH" end
     --if status_soil3 ~= oldstatus_soil3 then sendalarm (2, status_soil3) end
     oldstatus_soil3 = status_soil3

     msg = '{ "Id": '..ID..', "soil1": "'..status_soil2..'", "soil2": "'..status_soil3..'" }'
     print (msg)
     m:publish("/"..clientId.."/soil",msg,0,0, function(conn) print("sent") end)
end
function start()
     tmr.alarm(1, 20000, 1, function() 
          if pcall(publish) then
               print("Send OK")
          else
               print("Send err" )
          end
     end)
end


connect()
