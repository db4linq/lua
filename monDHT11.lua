
tmr.delay(1000000)
humi="-1"
temp="-1"
fare="-1"
bimb=1
PIN = 4 --  data pin, GPIO2
--load DHT11 module and read sensor
function ReadDHT11()
	dht11 = require("dht11")
	dht11.read(PIN)
	t = dht11.getTemperature()
	h = dht11.getHumidity()
	humi=(h)
	temp=(t)
	fare=((t*9/5)+32)
	print("Humidity:    "..humi.."%")
	print("Temperature: "..temp.." deg C")
	print("Temperature: "..fare.." deg F")
	-- release module
	dht11 = nil
	package.loaded["dht11"]=nil
end

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
    --print(list[1])
    list=split(list[1]," ")
    --print(list[2])
    list=split(list[2],"\/")

    table.insert(result, list[1]);
    table.insert(result, list[2]);
    table.insert(result, list[3]);

    return result;
end


tmr.alarm(1,10000, 1, function() ReadDHT11() bimb=bimb+1 if bimb==5 then bimb=0 wifi.sta.connect() print("Reconnect")end end)

function index(conn)
    conn:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
     <!DOCTYPE HTML>\
    <html><head><meta content="text/html;charset=utf-8"><title>ESP8266</title></head>\
     <body bgcolor="#ffe4c4"><h2>Hygrometer with<br>DHT11 sensor</h2>\
     <h3><font color="green">\
     <IMG SRC="http://esp8266.fancon.cz/common/hyg.gif"WIDTH="64"HEIGHT="64"><br>\
     <input style="text-align: center"type="text"size=4 name="j"value="'..humi..'"> % of relative humidity<br><br>\
     <IMG SRC="http://esp8266.fancon.cz/common/tmp.gif"WIDTH="64"HEIGHT="64"><br>\
     <input style="text-align: center"type="text"size=4 name="p"value="'..temp..'"> Temperature grade C<br>\
     <input style="text-align: center"type="text"size=4 name="p"value="'..fare..'"> Temperature grade F</font></h3>\
     <IMG SRC="http://esp8266.fancon.cz/common/dht11.gif"WIDTH="200"HEIGHT="230"BORDER="2"></body></html>')        
end

function notfound(conn)
     conn:send('HTTP/1.1 200 OK\r\nConnection: keep-alive\r\nCache-Control: private, no-store\r\n\r\n\
          <!DOCTYPE HTML>\
         <html><head><meta content="text/html;charset=utf-8"><title>ESP8266</title></head>\
          <body bgcolor="#ffe4c4"><h2>Page Not Found</h2>\
          </body></html>') 
end

function read_temperature(conn)
    conn:send('HTTP/1.1 200 OK\r\nAccess-Control-Allow-Origin: *\r\nContent-Type: application/json; charset=utf-8\r\nConnection: close\r\nCache-Control: private, no-store\r\n\r\n\
          {\"result\":\"ok\",\"Temperature\": '..temp..', \"Humidity\": '..humi..'}')
end

srv=net.createServer(net.TCP) srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)
     	--print(payload) -- for debugging only
     	--generates HTML web site
          list=urldecode(payload)
                 
          if (list[2]=="index.html") then
               index(conn)
          elseif (list[2]=="temperature") then
               read_temperature(conn)
          else
               notfound(conn)
          end      
    end)    
    conn:on("sent",function(conn) conn:close() end)
end)
