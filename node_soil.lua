server = "103.22.180.136"
port = 5683
node_name = "Soil-01"
conn=nil
gpio.mode(5,gpio.INPUT,gpio.FLOAT)
gpio.mode(6,gpio.INPUT,gpio.FLOAT)
soil = "HIGH"
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
               open()
               tmr.stop(0) 
          end)  
     end       
  end);
  conn:on("reconnection", function() print("Disconnection..") end);
  conn:on("connection", function() 
     print("Connected..")
     start() 
  end);
  conn:connect(port, server)
  conn:send('{ "type": 1, "data": "'.. node.chipid() .. '", "name": "'..node_name..'"}')
end
function receive(conn, payload)
     list=split(payload,"|")
     if (list[1] == 'V') then
          if (list[2] == 'heap') then
               conn:send('{ "type": 2, "data":"'.. node.heap() .. '"}')
          end          
          if (list[2] == 'soil1') then
               soil = "HIGH"
               if gpio.read(5)==1 then
                    soil = "LOW" 
               end
               conn:send('{ "type": 2, "data": { "deviceID": "'..node.chipid()..'", "id": 1, "value": "'..soil..'"}}')
          end
          if (list[2] == 'soil2') then
               soil = "HIGH"
               if gpio.read(6)==1 then
                    soil = "LOW" 
               end
               conn:send('{ "type": 2, "data": { "deviceID": "'..node.chipid()..'", "id": 2, "value": "'..soil..'"}}')
          end          
     end    
end
status_soil2 = "HIGH"
oldstatus_soil2 = "HIGH"
status_soil3 = "HIGH"
oldstatus_soil3 = "HIGH"
function sendalarm(id, status)
     conn:send('{ "type": 4, "deviceID": "'.. node.chipid() ..'", "data": {"msg": "'..node_name..' status change", "id": '..id..', "value": "'..status..'"}}')
end
function start()
     tmr.alarm(0, 3000, 1, function() -- Set alarm to one second
       if gpio.read(5)==1 then status_soil2="LOW" else status_soil2="HIGH" end
       if status_soil2 ~= oldstatus_soil2 then sendalarm (1, status_soil2) end
       oldstatus_soil2 = status_soil2
     
       if gpio.read(6)==1 then status_soil3="LOW" else status_soil3="HIGH" end
       if status_soil3 ~= oldstatus_soil3 then sendalarm (2, status_soil3) end
       oldstatus_soil3 = status_soil3
     end)
end
function close()
  conn:close()
end
tmr.alarm(0, 2000, 1, function()
     open()
     tmr.stop(0) 
end)

open()

