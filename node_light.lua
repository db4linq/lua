server = "192.168.1.48"
port = 5683
node_name = "Light-01"
sensorPin = 4
gpio.mode(sensorPin, gpio.INPUT,gpio.FLOAT)
soil = "HIGH"
local nonn = nil

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function open()
  conn=net.createConnection(net.TCP, 0)
  print("Open connection...") 
  conn:on("receive", receive) 
  conn:on("disconnection", function() 
     print("Disconnection..")
     tmr.stop(0)
     conn= nil
     if (wifi.sta.status() == 5) then
          tmr.alarm(0, 5000, 1, function()
               open()
               tmr.stop(0) 
          end)  
     end  
  end);
  conn:on("reconnection", function() print("Disconnection..") end);
  conn:on("connection", function() 
     print("Connected..") 
     start()
     conn:send('{ "type": 1, "data": "'.. node.chipid() .. '", "name": "'..node_name..'"}')
  end);
  conn:connect(port, server)  
end

function receive(conn, payload)
     list=split(payload,"|")
     if (list[1] == 'V') then
          if (list[2] == 'heap') then
               conn:send('{ "type": 2, "data":"'.. node.heap() .. '"}')
          end
          
          if (list[2] == 'security1') then
               soil = "CLEAR"
               if gpio.read(4)==0 then
                    soil = "ALARM" 
               end
               conn:send('{ "type": 2, "data": { "deviceID": "'..node.chipid()..'", "id": 1, "value": "'..soil..'"}}')
          end          
     end    
end

light_status = "CLEAR"
light_oldstatus = "CLEAR"

function sendalarm(id, status)
     print(status)
     conn:send('{ "type": 5, "deviceID": "'.. node.chipid() ..'", "data": {"msg": "'..node_name..' status change", "id": '..id..', "value": "'..status..'"}}')
end

function start()
     tmr.alarm(0, 1000, 1, function() -- Set alarm to one second
         if gpio.read(sensorPin)==0 then light_status="ALARM" else light_status="CLEAR" end
         if light_status ~= light_oldstatus then sendalarm(1, light_status) end
         light_oldstatus = light_status
     end)
end

function close()
  conn:close()
end

tmr.alarm(0, 2000, 1, function()
     open()
     tmr.stop(0) 
end)

