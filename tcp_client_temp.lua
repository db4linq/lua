SensorID = node.chipid()
local humidity = 0
local temperature = 0 
server = "192.168.1.36"
port = 8888
PIN = 5
DHT= require("dht_lib")

function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     sda = 3 -- GPIO14
     scl = 4 -- GPIO12
     sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
end

function prepare()
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end

function readTemp()
    DHT.read11(PIN)
    local t = DHT.getTemperature()
    local h = DHT.getHumidity()

    if h == nil then
      print("Error reading from DHT11/22")
    else
      -- temperature in degrees Celsius  and Farenheit
      humidity = h --((h - (h % 10)) / 10).."."..(h % 10)
      temperature = t --((t-(t % 10)) / 10).."."..(t % 10)
      print("Temperature: "..temperature.." deg C") 
      print("Humidity: "..humidity.."%")
    end 
end

function open()
  print("Open connection...")
  conn=net.createConnection(net.TCP, 0)
  conn:on("receive", function(conn, payload) print(payload) end) 
  conn:on("disconnection", function()  
    print("Disconnection..")
    tmr.stop(0)  
  end)
  conn:on("reconnection", function() 
    print("Reconnection..") 
  end)
  conn:on("connection", function() 
    print("Connected..")
    start()
    --conn:send("{ \"Type\":\"TEMP\",\"SensorID\":\"".. SensorID .. "\"}") 
  end) 
  conn:connect(port, server)  
end

function send() 
   readTemp()
   if (humidity ~= nil) then
        file.open("temp.MONO", "r")
        xbm_data = file.read()
        file.close()
        disp:firstPage()
        repeat
            disp:drawXBM( 0, 0, 60, 60, xbm_data )
            disp:setScale2x2()
            disp:drawStr(35,5, temperature.."C")
            disp:drawStr(35,15, humidity.."%") 
            disp:undoScale()
        until disp:nextPage() == false
        xbm_data = nil
        conn:send('{ "Type": "TEMP", "SensorID":'.. SensorID .. ', "temperature": '..temperature..', "humidity": '..humidity..'}')
   end
end

function close()
  conn:close()
end
init_i2c_display()
prepare()
tmr.alarm(0, 2000, 0, function()
    open()
end)
function start()
    send()
    tmr.alarm(0, 5000, 1, function() -- Set alarm to one second
        send()
    end)
end
--tmr.stop(0)
