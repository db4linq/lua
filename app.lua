
function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
function urlencode(payload)
    result = {};
    list=split(payload,"\r\n")
    --print(list[1])
    list=split(list[1]," ")
    --print(list[2])
    list=split(list[2],"\/")

    table.insert(result, list[1]);
    table.insert(result, list[2]);
    table.insert(result, list[3]);

    return result;
end
function sendHeader(conn)
     conn:send("HTTP/1.1 200 OK\r\n")
     conn:send("Access-Control-Allow-Origin: *\r\n")
     conn:send("Content-Type: application/json; charset=utf-8\r\n")
     conn:send("Server:NodeMCU\r\n")
     conn:send("Connection: close\r\n\r\n")
end
function index(conn)
    conn:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
     <!DOCTYPE HTML><html><head>\
     <meta content="text/html;charset=utf-8"><title>ESP8266</title>\
     <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">\
     </head>\
     <body bgcolor="#ffe4c4">\
     <H2>ESP8266 GOIP API</H2>\
     </body></html>')
end
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
      list=urlencode(payload)
      if (list[2]=="") then
        index(conn)
      elseif (list[2]=="write") then
        local pin = tonumber(list[3])
        --print("Pin: "..pin) 
        local status = tonumber(list[4])
        --print("State: "..status)
        gpio.write(pin, status)
        -- Response Header
        sendHeader(conn) 
        -- Response Content
        conn:send('{"result":"ok","digitalPin": '..pin..', "status": '..gpio.read(pin)..'}')
      elseif (list[2]=="read") then
        -- Response Header
        sendHeader(conn) 
        -- Response Content
        conn:send('{"result":"ok", "digitalPins":[\
                       {"digitalPin": 4,"status": '..gpio.read(4)..'},\
                       {"digitalPin": 5, "status": '..gpio.read(5)..'},\
                       {"digitalPin": 6, "status": '..gpio.read(6)..'},\
                       {"digitalPin": 7, "status": '..gpio.read(7)..'}\
                       ]}')
      else
        -- Response Header
        sendHeader(conn) 
        -- Response Content
        conn:send('{"result":"error","message": "command not found"}')        
      end
      conn:close()
    end) 
end)
