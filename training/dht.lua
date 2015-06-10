PIN = 0 --  data pin, GPIO2

DHT= require("dht_lib")

function read()
    DHT.read11(PIN)
    --DHT.read22(PIN)
    t = DHT.getTemperature()
    h = DHT.getHumidity()
    if h == nil then
      print("Error reading from DHT11/22")
      
    else
      -- *********** DHT11 ********************
      print("Temperature: "..t.." deg C")
      print("Humidity: "..h.."%")
      -- *********** DHT22 ********************
      -- temperature in degrees Celsius  and Farenheit
      --print("Temperature: "..((t-(t % 10)) / 10).."."..(t % 10).." deg C")
      --print("Temperature: "..(9 * t / 50 + 32).."."..(9 * t / 5 % 10).." deg F")
      -- humidity
      --print("Humidity: "..((h - (h % 10)) / 10).."."..(h % 10).."%")
    end
end

read()

-- release module
--DHT = nil
--package.loaded["dht_lib"]=nil