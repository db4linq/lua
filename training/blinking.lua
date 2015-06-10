LED = 7
gpio.mode(LED, gpio.OUTPUT)
tmr.alarm(0, 1000, 1, function() 
    if (gpio.read(LED) == 1) then
        gpio.write(LED, 0)
    else
        gpio.write(LED, 1)
    end
end)