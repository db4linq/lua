pin1=5
pin2=6
gpio.mode(pin1,gpio.OUTPUT)
gpio.mode(pin2,gpio.OUTPUT)

pwm.setup(7, 1000, 0)
pwm.start(7)

function sendHeader(conn)
     conn:send("HTTP/1.1 200 OK\r\n")
     conn:send("Access-Control-Allow-Origin: *\r\n")
     conn:send("Content-Type: application/json; charset=utf-8\r\n")
     conn:send("Server:NodeMCU\r\n")
     conn:send("Connection: close\r\n\r\n")
end

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
      print(payload)
      -- "GET /digital/write/4/1 HTTP"
      _, _, method, path, action, pin, state = string.find(payload, "([A-Z]+) /(.+)/(.+)/([0-9]+)/([0-9]+) HTTP")
      -- "GET /digital/read HTTP"
      if (method == nil) then
          _, _, method, path, action = string.find(payload, "([A-Z]+) /(.+)/(.+) HTTP")
      end     
      print(method)
      print(path)
      print(action)
      print(pin)
      print(state)

      if (method == "GET") then
          sendHeader(conn) -- Response Header 
          if (path == "digital") then
               if (action == "dimmer") then
                    local _pin = tonumber(pin)
                    local _value = tonumber(state)
                    if _pin == 7 then
                         pwm.setduty(_pin, _value)
                         conn:send('{"result": "ok"}')
                    else
                         conn:send('{"result": "error", "msg": "pwm index not found"')
                    end
               else
                    conn:send('{"result": "error", "message": "action not found"}')     
               end
          else
               conn:send('{"result": "error", "message": "path not allowed"}')
          end
      else        
          conn:send('{"result": "error", "message": "method not allowed"}')
      end
      conn:close()      
    end) 
end)
