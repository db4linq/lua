ssid = "see_dum"
pwd = "0863219053"
FILE = "http.lua"

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

if true then  --change to if true
     print("set up wifi mode")
     wifi.setmode(wifi.STATION)
     --please config ssid and password according to settings of your wireless router.
     wifi.sta.config(ssid, pwd)
     wifi.sta.connect()
     cnt = 0
     tmr.alarm(1, 1000, 1, function() 
         if (wifi.sta.getip() == nil) and (cnt < 20) then 
          print("IP unavaiable, Waiting...")
          cnt = cnt + 1 
         else 
          tmr.stop(1)
          if (cnt < 20) then print("Config done, IP is "..wifi.sta.getip())
          if (file_exists) then
               --dofile(FILE)
               print("Run script...")
          else
               print("File not found: "..FILE)
          end
          else print("Wifi setup time more than 20s, Please verify wifi.sta.config() function. Then re-download the file.")
          end
         end 
      end)
else
     print("\n")
     print("Please edit 'init.lua' first:")
     --print("Step 1: Modify wifi.sta.config() function in line 5 according settings of your wireless router.")
     --print("Step 2: Change the 'if false' statement in line 1 to 'if true'.")
end


