server = "192.168.1.48"
port = 5683
node_name = "Soil-02"
conn=net.createConnection(net.TCP, 0)
gpio.mode(4,gpio.INPUT,gpio.FLOAT)
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
  conn:on("receive", receive) 
  conn:on("disconnection", function() 
     print("Disconnection..")
  end);
  conn:on("reconnection", function() print("Disconnection..") end);
  conn:on("connection", function() print("Connected..") end);
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
               if gpio.read(4)==1 then
                    soil = "LOW" 
               end
               conn:send('{ "type": 2, "data": { "deviceID": "'..node.chipid()..'", "id": 3, "value": "'..soil..'"}}')
          end          
     end    
end


status_soil2 = "HIGH"
oldstatus_soil2 = "HIGH"

function sendalarm(id, status)
     conn:send('{ "type": 4, "deviceID": "'.. node.chipid() ..'", "data": {"msg": "'..node_name..' status change", "id": '..id..', "value": "'..status..'"}}')
end

tmr.alarm(0, 3000, 1, function() -- Set alarm to one second

  if gpio.read(4)==1 then status_soil2="LOW" else status_soil2="HIGH" end
  if status_soil2 ~= oldstatus_soil2 then sendalarm (3, status_soil2) end
  oldstatus_soil2 = status_soil2 
end)

function close()
  conn:close()
end

tmr.alarm(1, 2000, 1, function() 
     open()
     tmr.stop(1)
end)

