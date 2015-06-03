-- your offset to UTC
local UTC_OFFSET = 7
-- Enter your city, check openweathermap.org
--  Ban Rangsit, TH
local CITY = "Thanyaburi,TH"
-- Get an APP ID on openweathermap.org
local APPID = "4a7401363b53fcc52892b4ece69c8b36"
-- Update interval in minutes
local INTERVAL = 1

local temp = '0.0'
local humidity = '0'

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

function updateWeather()
    print("Updating weather")
    local conn=net.createConnection(net.TCP, 0)
    conn:on("receive", function(conn, payload) 
        --print(payload)
        local lastUpdate = string.sub(payload,string.find(payload,"Date: ")+23,string.find(payload,"Date: ")+31)
        local hour = string.sub(lastUpdate, 0, 2) + UTC_OFFSET
        lastUpdate = hour..string.sub(lastUpdate, 3, 9)
        local payload = string.match(payload, "{.*}")
        print(payload)
        if (payload ~= nil) then
            weather = nil
            weather = cjson.decode(payload)
            local icon = weather.weather[1].icon
            icon = string.gsub(icon, "n", "d")
            file.open(icon..".MONO", "r")
            xbm_data = file.read()
            file.close()
            drawWeather(xbm_data, weather, lastUpdate)
        else
            if (temp == '0.0') then
                drawWeather(nil,nil, nil)
            end
        end
        
        payload = nil
        conn:close()
        conn = nil
        
    end )
    
    conn:connect(80,"128.199.103.33")
    conn:on("connection", function() 
        print("connection...")
        conn:send("GET /data/2.5/weather?q="..CITY.."&units=metric&APPID="..APPID
          .." HTTP/1.1\r\n"
          .."Host: api.openweathermap.org\r\n"
          .."Connection: close\r\n"
          .."Accept: */*\r\n"
          .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
          .."\r\n")
        conn = nil    
    end)
end
init_i2c_display()
prepare()
updateWeather()


function drawWeather(xbm_data, weather, lastUpdate)
        disp:firstPage()
        repeat
                    if (xbm_data ~= nil) then 
                        disp:drawXBM( 0, 0, 60, 60, xbm_data )
                    end
                    disp:setScale2x2()
                    
                    if (weather ~= nil) then
                        local mult = 10^(idp or 0)
                        temp = math.floor(weather.main.temp + 1)
                        humidity = weather.main.humidity 
                        --disp:drawStr(2,16, weather.weather[1].main)
                    end
                    disp:drawStr(35,5, temp.."C")
                    disp:drawStr(35,15, humidity.."%")
                    --disp:drawStr(10,5, "TH")
                    disp:undoScale()
                    --disp:drawStr(5,17, "Thanyaburi")
                    if (lastUpdate ~= nil) then
                        --disp:drawStr(10,52, weather.wind.speed..'m/s')
                        disp:drawStr(70,52, lastUpdate)
                    end

        until disp:nextPage() == false
end

tmr.alarm(1, INTERVAL * 60000, 1, function() 
   ip = wifi.sta.getip()
   if ip=="0.0.0.0" or ip==nil then
      print("connecting to AP...") 
   else
      print("Loading weather...")
      updateWeather()
   end
end )
