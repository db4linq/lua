
gpio.mode(5,gpio.OUTPUT)
gpio.mode(6,gpio.OUTPUT)
gpio.mode(7,gpio.OUTPUT)

gpio.write(5, 0)
gpio.write(6, 0)
gpio.write(7, 0)

server = "192.168.43.94"
port = 5683
node_name = "Lighting-01"
conn=net.createConnection(net.TCP, 0)

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
  conn:on("disconnection", function()  print("Disconnection..")  end)
  conn:on("reconnection", function() print("Reconnection..") end)
  conn:on("connection", function() print("Connected..") end)  
  conn:connect(port, server)
  conn:send('{ "type": 1, "data": "'.. node.chipid() .. '", "name": "'..node_name..'"}')
end

function receive(conn, payload)
     --print(payload)
     list=split(payload,"|")
     if (list[1] == 'V') then
          if (list[2] == 'heap') then
               conn:send('{ "type": 2, "data":"'.. node.heap() .. '"}')
          end                   
     end
     if (list[1] == 'P') then
          if (list[2] == 'heap') then
               conn:send('{ "type": 6, "data": "ok"}')
          end                   
     end
     if (list[1] == 'F') then
          if (list[2] == 'toggle') then
               toggle(list[3])
          end                
     end
end

function close()
  conn:close()
end

function toggle(param)
     --print(param) 
     local pin = tonumber(param) 
     print("Pin: " .. pin) 
     if gpio.read(pin) == 1 then
          gpio.write(pin, 0)
     else
          gpio.write(pin, 1)
     end
     conn:send('{"type": 3, "data": { "status": '..gpio.read(pin)..', "coreID": "'.. node.chipid() ..'", "id": '..pin..' }}')
end


open()

