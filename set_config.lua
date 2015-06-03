ss=net.createServer(net.TCP)
ss:listen(80,function(c)
   c:on("receive",function(c,pl)
      print(pl)
      ssidBegin = string.find(pl, "=", 0)+1
      ssidEnd = string.find(pl, "&", 0)-1
      passBegin = string.find(pl, "=", ssidEnd+2)+1
      passEnd = string.find(pl, "&", ssidEnd+2)-1

      ssidName = string.sub(pl, ssidBegin, ssidEnd)
      pass = string.sub(pl, passBegin, passEnd)

      print ("Got SSID: " .. ssidName)
      print ("key: " .. pass)

      c:send("HTTP/1.1 200 OK\n\n") 
      c:send("<html><body>") 
      c:send("<h1>Your ESP device is now connected to the following SSID.</h1><BR>")
      c:send("SSID : " .. ssidName .. "<BR>") 
      c:send("key : " .. pass .. "<BR>") 
      c:send("</html></body>") 

      c:send("\nTMR:"..tmr.now().." MEM:"..node.heap())
      

      wifi.sta.config(ssidName,pass)
      wifi.sta.connect()
      cnt = 0
      tmr.alarm(0, 1000, 1, function() 
          if (wifi.sta.getip() == nil) and (cnt < 10) then 
               print("IP unavaiable, Waiting...")
               cnt = cnt + 1 
          else
               tmr.stop(0)
               if cnt < 10 then
                    file.open("config.lua","w+")
                    file.writeline(ssidName)
                    file.writeline(pass)
                    file.close()
                    print("Connected to your wifi network!")
                    c:send("\nConnected to your wifi network!")
               else
                    print("Wifi setup time more than 10s, Please verify wifi.sta.config() function. Then re-download the file.")
                    c:send("\nWifi setup time more than 10s, Please verify wifi.sta.config() function. Then re-download the file.")
               end

               c:close()
               ss:close()
          end
      end)
              
    end)
end)