PIN=0
STATUS = 7
humi=0
temp=0
DHT= require("dht_lib")
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
          node.restart()
     end
)
-- on publish message receive event
m:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    print('Message: '..data) 
    print('*****************************')
  end
end)
function connect()
     -- iot.eclipse.org
     -- broker.mqttdashboard.com
     -- subscribe topic with qos = 0
     m:connect("iot.eclipse.org", 1883, 0, 
          function(conn) 
            gpio.write(STATUS, 1)
            print("connected") 
            m:subscribe("/"..clientId.."/temperature",0, function(conn) print("subscribe success") end)
            publish()
            start()
          end
     )
end
function ReadDHT11()
     DHT.read11(PIN)
     temp = DHT.getTemperature()
     humi = DHT.getHumidity() 
     print("Temperature: "..temp.." deg C, Humidity: "..humi.."%")
end
function publish()
     ReadDHT11()
     msg = '{"Id": 2, "Temperature": '..temp..', "Humidity": '..humi..'}'
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

connect()
