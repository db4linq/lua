dofile('ssd1306.lc')
STATUS = 6
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
function drawWeather(xbm_data, weather)
    disp:firstPage()
    repeat
        if (xbm_data ~= nil) then 
            disp:drawXBM( 0, 0, 60, 60, xbm_data )
        end
        disp:setScale2x2()           
        disp:drawStr(35,5, weather.Temperature.."C")
        disp:drawStr(35,15, weather.Humidity.."%") 
        disp:undoScale() 
    until disp:nextPage() == false
end
-- on publish message receive event
m:on("message", function(conn, topic, data) 
  print(topic .. ":" ) 
  if data ~= nil then
    weather = cjson.decode(data) 
    file.open("temp.MONO", "r")
    xbm_data = file.read()
    file.close()
    drawWeather(xbm_data, weather)
    xbm_data = nil
    print("Temperature: "..weather.Temperature..", Humidity: "..weather.Humidity)    
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
            m:subscribe("/10038268/temperature",0, function(conn) print("subscribe success") end)
          end
     )
end
init_i2c_display()
prepare()
connect()
