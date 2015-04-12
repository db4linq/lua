gpio.mode(4,gpio.OUTPUT)
gpio.mode(5,gpio.OUTPUT)
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
function urldecode(payload)
    result = {};
    list=split(payload,"\r\n")
    list=split(list[1]," ")
    list=split(list[2],"\/")
    table.insert(result, list[1]);
    table.insert(result, list[2]);
    table.insert(result, list[3]);
    return result;
end

function notfound(conn)
     conn:send('HTTP/1.1 404 Not Found\r\nConnection: close\r\nCache-Control: private, no-store\r\n\r\n\
          <!DOCTYPE HTML>\
         <html><head><meta content="text/html;charset=utf-8"><title>ESP8266</title></head>\
          <body bgcolor="#ffe4c4"><h2>Page Not Found</h2>\
          </body></html>') 
end

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
      print("Http Request..\r\n")
      --print (payload)
      list=urldecode(payload) 
      if (list[2]=="write") then
        local pin = tonumber(list[3]) 
        local status = tonumber(list[4]) 
        gpio.write(pin, status) 
        sendHeader(conn)  
        conn:send("{\"result\":\"ok\",\"digitalPin\": "..pin..", \"status\": "..gpio.read(pin).."}")
      elseif (list[2]=="toggle") then
        local pin = tonumber(list[3]) 
        if (gpio.read(pin) == 1) then
          gpio.write(pin, 0)
        else
          gpio.write(pin,1) 
        end 
        sendHeader(conn)  
        conn:send("{\"result\":\"ok\",\"digitalPin\": "..pin..", \"status\": "..gpio.read(pin).."}")       
      elseif (list[2]=="read") then 
        local pin = tonumber(list[3]) 
        sendHeader(conn)  
        conn:send("{\"result\":\"ok\", \"digitalPins\": [{\"digitalPin\": 4, \"status\": "..gpio.read(4).."},{\"digitalPin\": 5, \"status\": "..gpio.read(5).."}]}")
      else
        notfound(conn)   
      end     
      conn:close() 
    end)
end)
