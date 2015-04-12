print("\r\n\r\nDevice ID: "..node.chipid())
server = "192.168.1.48"
port = 5683
node_name = "Test"
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
     list=split(payload,"|")
     if (list[1] == 'V') then
          if (list[2] == 'heap') then
               conn:send('{ "type": 2, "data":"'.. node.heap() .. '"}')
          end                   
     end
     if (list[1] == 'F') then
          if (list[2] == 'led') then
               led(list[3])
          end
          if (list[2] == 'toggle') then
               toggle(list[3])
          end          
          if (list[2] == 'status') then
               status(list[3])
          end          
     end
end

function close()
  conn:close()
end

function led(param)
     print(param)
     list=split(param,",")
     local pin = tonumber(list[1])
     local state = tonumber(list[2])
     print("Pin: " .. pin)
     print("State: " .. state)
     gpio.write(pin, state)
     conn:send('{"type": 3, "data": '.. gpio.read(pin) ..'}')
end

function toggle(param)
     print(param)
     list=split(param,",")
     local pin = tonumber(list[1]) 
     print("Pin: " .. pin) 
     if gpio.read(pin) == 1 then
          gpio.write(pin, 0)
     else
          gpio.write(pin, 1)
     end 
     conn:send('{"type": 3, "data": '.. gpio.read(pin) ..'}')
end

function status(param)
     local pin = tonumber(param)
     conn:send('{"type": 3, "data": '.. gpio.read(pin) ..'}')
end

open()

