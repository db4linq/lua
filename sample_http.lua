
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

function index(conn)
    conn:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
     <!DOCTYPE HTML><html><head>\
     <meta content="text/html;charset=utf-8"><title>ESP8266</title>\
     <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">\
     <body bgcolor="#ffe4c4">\
     <h2>Page Index</h2><hr>\
     </body></html>')
end

function about(conn)
    conn:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
     <!DOCTYPE HTML><html><head>\
     <meta content="text/html;charset=utf-8"><title>ESP8266</title>\
     <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">\
     <body bgcolor="#ffe4c4">\
     <h2>Page About</h2><hr>\
     </body></html>')
end

function notfound(conn)
     conn:send('HTTP/1.1 404 Not Found\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
          <!DOCTYPE HTML>\
         <html><head><meta content="text/html;charset=utf-8"><title>ESP8266</title></head>\
          <body bgcolor="#ffe4c4"><h2>Page Not Found</h2>\
          </body></html>') 
end

srv=net.createServer(net.TCP)


srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
      print("Http Request..\r\n")
      print (payload)
      list=urldecode(payload) 
      
      if ((list[2]=="") or (list[2]=="index.html")) then 
          index(conn)     
      elseif (list[2]=="about.html") then 
          about(conn)  
      else
          notfound(conn)   
      end      
      conn:close()
    end) 
end)
