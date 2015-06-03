pwmPin = 7
pwm.setup(pwmPin, 1000, 0)
pwm.start(pwmPin)
io = require("iothink")
io.init(2, "Dimmer-04") 
io.addFunction("dimmer", function(param)
     _, _, pin, value = string.find(param, "([0-9]+),([0-9]+)")
     local _pin = tonumber(pin)
     local _value = tonumber(value)
     if pin ~= nil then 
          print("Pin: " .. _pin) 
          print("Value: " .. _value) 
          pwm.setduty(_pin, _value)
     end
     return '{ "status": "ok"}'
end)
io.connect()