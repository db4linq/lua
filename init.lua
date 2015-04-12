ssid = "see_dum"
pwd = "0863219053"
print("set up wifi mode")
wifi.setmode(wifi.STATION)
wifi.sta.config(ssid, pwd)
wifi.sta.connect()
cnt = 0
tmr.alarm(0, 1000, 1, function() 
        if (wifi.sta.getip() == nil) and (cnt < 20) then 
          print("IP unavaiable, Waiting...")
          cnt = cnt + 1 
        else 
          tmr.stop(0)
          if (cnt < 20) then 
               print("Config done, IP is "..wifi.sta.getip())
               tmr.alarm(0, 1000, 1, function() 
                    tmr.stop(0)
                    --dofile("uart.lua")
                    --dofile("config.lua")
                    --print("Run script...")
               end) 
          else 
               print("Wifi setup time more than 20s, Please verify wifi.sta.config() function. Then re-download the file.")
          end
        end 
end)


