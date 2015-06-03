server = "192.168.1.48"
port = 5683
node_name = "Door-Switch-01"
local nonn = nil
ID = 2
conn=net.createConnection(net.TCP, 0)
soil = "CLEAR"
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
               if gpio.read(5)==0 then
                    soil = "ALARM" 
               end
               conn:send('{ "type": 2, "data": { "deviceID": "'..node.chipid()..'", "id": '..ID..', "value": "'..soil..'"}}')
          end          
     end    
end

gpio.mode(5,gpio.INPUT,gpio.FLOAT)
status_soil2 = "ALARM"
oldstatus_soil2 = "ALARM"
function sendalarm(id, status)
     print("ID: "..id..", "..status)
     conn:send('{ "type": 5, "deviceID": "'.. node.chipid() ..'", "data": {"msg": "'..node_name..' status change", "id": '..id..', "value": "'..status..'"}}')
end

function start()
     tmr.alarm(0, 2000, 1, function() -- Set alarm to one second
       if gpio.read(5)==1 then status_soil2="CLEAR" else status_soil2="ALARM" end
       if status_soil2 ~= oldstatus_soil2 then sendalarm(ID, status_soil2) end
       oldstatus_soil2 = status_soil2
     end)
end

tmr.alarm(0, 2000, 1, function()
     tmr.stop(0)
     open() 
end)

