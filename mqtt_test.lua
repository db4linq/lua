STATUS = 5
gpio.mode(STATUS, gpio.OUTPUT)
gpio.write(STATUS, 0)
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
          --node.restart()
          tmr.alarm(0, 2000, 1, function() 
            print ('Reconnect...')
            connect()
          end)
     end
)

-- on publish message receive event
m:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  weather = cjson.decode(data) 
  print("Temperature: "..weather.Temperature..", Humidity: "..weather.Humidity) 
  print("**************************************")   
end)
function connect()
     -- iot.eclipse.org
     -- broker.mqttdashboard.com
     -- subscribe topic with qos = 0
     m:connect("192.168.43.94", 1883, 0, 
          function(conn) 
            gpio.write(STATUS, 1)
            print("connected") 
            m:subscribe("/10040058/temperature",0, function(conn) print("subscribe success") end)
          end
     )
end
connect()
