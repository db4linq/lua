ssid = "you_ssid"
pwd = "you_password"
FILE = "run.lua"

function file_exists(name)
   local f=file.open(name,"r")
   if f~=nil then file.close(f) return true else return false end
end

if true then  --change to if true
     print("set up wifi mode")
     wifi.setmode(wifi.STATION)
     wifi.sta.config(ssid, pwd)
     wifi.sta.connect()
     cnt = 0
     tmr.alarm(1, 1000, 1, function() 
         if (wifi.sta.getip() == nil) and (cnt < 20) then 
          print("IP unavaiable, Waiting...")
          cnt = cnt + 1 
         else 
          tmr.stop(1)
          if (cnt < 20) then 
               print("Config done, IP is "..wifi.sta.getip())
               if (file_exists(FILE)) then
                    dofile(FILE)
                    print("Run script...")
               end
          else 
               print("Wifi setup time more than 20s, Please verify wifi.sta.config() function. Then re-download the file.")
          end
         end 
     end)
else
     print("\n")
     print("Please edit 'init.lua' first:")
end


