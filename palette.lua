dofile("SSD1306_IP.lua")
display()
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
     <!DOCTYPE HTML><html><head><style>input[type=button] {font-size:large;width:10em;height:5em;}</style>\
     <meta content="text/html;charset=utf-8"><title>ESP8266</title>\
     <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">\
     <link rel="stylesheet" href="http://192.168.1.49:8001/css/palette.css">\
     <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>\
     <script src="http://192.168.1.49:8001/js/palette.js"></script>\
     <script>$(document).ready(function(){\
     function write_rgb(r, g, b){$.ajax({url:"/rgb/"+r+"/"+g+"/"+b, success:function(result){console.log(result);}});}\
     function updateInfo(c){}\
     function updateColor(c){write_rgb(c.r,c.g,c.b)}\
     var pal;resize();pal = new abdias.palette("palette", updateInfo);pal.oncolorselect = updateColor;\
     write_rgb(20,20,20)\
     });</script></head>\
     <body bgcolor="#ffe4c4">\
     <canvas width="500" height="400" id="palette"></canvas>\
     </body></html>')
end
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
      print("Http Request..")
      list=urlencode(payload) 
      if (list[2]=="") then 
          index(conn)
      elseif (list[2]=="rgb") then
        local r = tonumber(list[3]) 
        local g = tonumber(list[4]) 
        local b = tonumber(list[5]) 
        print(r)
        print(g)
        print(b)
        ws2812.writergb(5, string.char(r, g, b):rep(8)) 
        sendHeader(conn)  
        conn:send("{\"result\":\"ok\"}")
      else 
        sendHeader(conn)  
        conn:send("{\"result\":\"error\",\"message\": \"command not found\"}")        
      end
      conn:close()
    end) 
end)
