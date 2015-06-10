ssid = 'Xperia_Z2'
pwd = '1234567890'
print("set up wifi mode")
wifi.setmode(wifi.STATION) 
wifi.sta.config(ssid, pwd)
wifi.sta.connect()
cnt = 0
tmr.alarm(0, 1000, 1, function() 
        if (wifi.sta.getip() == nil) and (cnt < 10) then 
          print("IP unavaiable, Waiting...")
          cnt = cnt + 1 
        else 
          tmr.stop(0)
          if (cnt < 10) then 
               print("Config done, IP is "..wifi.sta.getip())
               tmr.alarm(0, 2000, 1, function() 
                    tmr.stop(0)
                    print("WIFI connected...")
                    --dofile('sample_http.lua')
                    --dofile("iothink_relay.lc")
                    --dofile("sample_http3.lua")
                    --dofile("iothink_weather.lc")
               end) 
          else 
               print("Wifi setup time more than 10s, Please verify wifi.sta.config() function. Then re-download the file.")
          end
        end 
end)
