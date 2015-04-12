server = "192.168.1.48"
port = 5683
node_name = "Node-03"
conn=net.createConnection(net.TCP, 0)
DHT1_PIN = 4 
humidity = 0
temperature = 0
dht11 = require("dht11")

gpio.mode(5,gpio.INPUT,gpio.FLOAT)
gpio.mode(6,gpio.INPUT,gpio.FLOAT)
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

--load DHT11 module and read sensor
function ReadDHT11(pin)
     
     dht11.init(pin)     
     t = dht11.getTemp()
     h = dht11.getHumidity()
     humidity=(h)
     temperature=(t)
     print("Humidity:    "..humidity.."%")
     print("Temperature: "..temperature.." deg C") 
end

function receive(conn, payload)
     list=split(payload,"|")
     if (list[1] == 'V') then
          if (list[2] == 'heap') then
               conn:send('{ "type": 2, "data":"'.. node.heap() .. '"}')
          end
          if (list[2] == 'temperature1') then
               ReadDHT11(4)
               conn:send('{ "type": 2, "data":{"id": 2, "temperature": '..temperature..', "humidity": '..humidity..' }}')
          end           
     end    
end

function close()
  conn:close()
end


open()
