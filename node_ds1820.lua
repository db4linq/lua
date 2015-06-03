server = "192.168.1.48"
port = 5683
node_name = "Temperature-03"
local nonn = nil
DS_PIN = 4  
ID = 3
temperature = 0
t = require("ds18b20")      
t.setup(DS_PIN)

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function open()
  print("Open connection...") 
  conn=net.createConnection(net.TCP, 0)
  conn:on("receive", receive) 
  conn:on("disconnection", function() 
     print("Disconnection..")
     tmr.stop(0)
     conn= nil
     if (wifi.sta.status() == 5) then
          tmr.alarm(0, 5000, 1, function()
               tmr.stop(0) 
               open() 
          end)  
     end      
  end);
  conn:on("reconnection", function() print("Disconnection..") end);
  conn:on("connection", function() 
     print("Connected..")  
     conn:send('{ "type": 1, "data": "'.. node.chipid() .. '", "name": "'..node_name..'"}')
  end);
  conn:connect(port, server) 
end

--load DHT11 module and read sensor
function ReadDS1820(pin)
     addrs = t.addrs()
     if (addrs ~= nil) then
       print("Total DS18B20 sensors: "..table.getn(addrs))
     end
     temperature = (t.read())
     -- Just read temperature
     print("Temperature: "..temperature.."'C")
end

function receive(conn, payload)
     list=split(payload,"|")
     if (list[1] == 'V') then
          if (list[2] == 'heap') then
               conn:send('{ "type": 2, "data":"'.. node.heap() .. '"}')
          end
          if (list[2] == 'temperature') then
               ReadDS1820(DS_PIN)
               conn:send('{ "type": 2, "data":{ "coreID": '.. node.chipid() ..', "id": '..ID..', "temperature": '..temperature..' }}')
          end           
     end    
end

function close()
  conn:close()
end

open()

