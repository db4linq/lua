-- ***************************************************************************
-- DHT11 module for ESP8266 with nodeMCU
--
-- Written by Javier Yanez
-- but based on a script of Pigs Fly from ESP8266.com forum
--
-- MIT license, http://opensource.org/licenses/MIT
-- ***************************************************************************

local moduleName = "dht11"
local M = {}
_G[moduleName] = M

local humidity
local temperature
local checksum
local checksumTest
local checko1
local checko2

function M.read(pin)
  humidity = 0
  temperature = 0
  checksum = 0
  checko1=0
  checko2=0
  -- Use Markus Gritsch trick to speed up read/write on GPIO
  gpio_read = gpio.read
  gpio_write = gpio.write

  bitStream = {}
  for j = 1, 40, 1 do
    bitStream[j] = 0
  end
  bitlength = 0

  -- Step 1:  send out start signal to DHT11
  gpio.mode(pin, gpio.OUTPUT)
  gpio.write(pin, gpio.HIGH)
  tmr.delay(100)
  gpio.write(pin, gpio.LOW)
  tmr.delay(20000)
  gpio.write(pin, gpio.HIGH)
  gpio.mode(pin, gpio.INPUT)

  -- Step 2:  DHT11 send response signal
  -- bus will always let up eventually, don't bother with timeout
  while (gpio_read(pin) == 0 ) do end
  c=0
  while (gpio_read(pin) == 1 and c < 100) do c = c + 1 end
  -- bus will always let up eventually, don't bother with timeout
  while (gpio_read(pin) == 0 ) do end
  c=0
  while (gpio_read(pin) == 1 and c < 100) do c = c + 1 end

  -- Step 3: DHT11 send data
  for j = 1, 40, 1 do
    while (gpio_read(pin) == 1 and bitlength < 10 ) do
      bitlength = bitlength + 1
    end
    bitStream[j] = bitlength
    bitlength = 0
    -- bus will always let up eventually, don't bother with timeout
    while (gpio_read(pin) == 0) do end
  end

  --DHT data acquired, process.
  for i = 1, 8, 1 do
    if(bitStream[i+0]>2)then
      humidity=humidity+2^(8-i)
    end
	if(bitStream[i+8]>2)then
      checko1=checko1+2^(8-i)
    end
    if(bitStream[i+16]>2)then
      temperature=temperature+2^(8-i)
    end
    if(bitStream[i+24]>2)then
      checko2=checko2+2^(8-i)
	end
    if (bitStream[i+32]>2)then
      checksum=checksum+2^(8-i)
    end
  end

  checksumTest=(humidity+checko1+temperature+checko2)%256

 -- convert to negative format
 --if temperature > 0x8000 then temperature = -(temperature - 0x8000)
 --end

  if checksum ~= checksumTest then
    humidity = -1
  end
end

function M.getTemperature()
  return temperature
end

function M.getHumidity()
  return humidity
end

return M
