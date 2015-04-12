   --------------------------------------------------------------------------------
-- DHT11 module for NODEMCU
-- LICENCE: http://opensource.org/licenses/MIT
-- zlo2k <zlo2k@bk.ru> from code Pigs Fly
--------------------------------------------------------------------------------
local moduleName = "dht11"
local M = {}
_G[moduleName] = M

local temp = 0
local hum = 0
local bitStream = {}

function M.init(pin)
    bitStream = {}
    for j = 1, 40, 1 do
        bitStream[j] = 0
    end
    bitlength = 0

    gpio.mode(pin, gpio.OUTPUT)
    gpio.write(pin, gpio.LOW)
    tmr.delay(20000)
    --Use Markus Gritsch trick to speed up read/write on GPIO
    gpio_read = gpio.read
    gpio_write = gpio.write

    gpio.mode(pin, gpio.INPUT)

    while (gpio_read(pin) == 0) do end

    c = 0
    while (gpio_read(pin) == 1 and c < 100) do c = c + 1 end

    while (gpio_read(pin) == 0) do end

    c = 0
    while (gpio_read(pin) == 1 and c < 100) do c = c + 1 end

    for j = 1, 40, 1 do
        while (gpio_read(pin) == 1 and bitlength < 10) do
            bitlength = bitlength + 1
        end
        bitStream[j] = bitlength
        bitlength = 0
        while (gpio_read(pin) == 0) do end
    end

    hum = 0
    temp = 0

    for i = 1, 8, 1 do
        if (bitStream[i + 0] > 2) then
            hum = hum + 2 ^ (8 - i)
        end
    end
    for i = 1, 8, 1 do
        if (bitStream[i + 16] > 2) then
            temp = temp + 2 ^ (8 - i)
        end
    end
    bitStream = {}
    gpio_read = nil
    gpio_write = nil
end

function M.getTemp()
    return temp
end

function M.getHumidity()
    return hum
end

return M
