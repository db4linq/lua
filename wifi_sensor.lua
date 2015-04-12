SensorPin1 = 5
status1 = "LOW"
oldstatus1 = "LOW"
gpio.mode(SensorPin1,gpio.INPUT,gpio.FLOAT)

SensorPin2 = 6
status2 = "LOW"
oldstatus2 = "LOW"
gpio.mode(SensorPin2,gpio.INPUT,gpio.FLOAT)


SensorPin3 = 4

function ReadDHT11()  
     dht11 = require("dht11")   
     dht11.init(SensorPin3)
     t = dht11.getTemp()
     h = dht11.getHumidity()
     humi=(h)
     temp=(t)
     fare=((t*9/5)+32)
     print("Humidity:    "..humi.."%")
     print("Temperature: "..temp.." deg C")
     print("Temperature: "..fare.." deg F")
     print("==================================")
     dht11 = nil
     package.loaded["dht11"]=nil
end

function run()
     tmr.alarm(0, 500, 1, function() -- Set alarm to one second
       if gpio.read(SensorPin1)==1 then status1="LOW" else status1="HIGH" end
       if status1 ~= oldstatus1 then 
          print("Soil 1: "..status1) 
          print("==================================")
       end
       oldstatus1 = status1
     end)

     tmr.alarm(1, 500, 1, function() -- Set alarm to one second
       if gpio.read(SensorPin2)==1 then status2="LOW" else status2="HIGH" end
       if status2 ~= oldstatus2 then 
          print("Soil 2: "..status2) 
          print("==================================") 
       end
       oldstatus2 = status2
     end)  

     tmr.alarm(2, 5000, 1, function() -- Set alarm to one second
       ReadDHT11()
     end)             
end

run()