local moduleName = 'dht_lib'
local M = {}
_G[moduleName] = M
local humidity
local temperature
local bitStream = {}

local function read(pin)
  local bitlength = 0
  humidity = 0
  temperature = 0
  local gpio_read = gpio.read
  for j = 1, 40, 1 do
    bitStream[j] = 0
  end
  gpio.mode(pin, gpio.OUTPUT)
  gpio.write(pin, gpio.HIGH)
  tmr.delay(100)
  gpio.write(pin, gpio.LOW)
  tmr.delay(20000)
  gpio.write(pin, gpio.HIGH)
  gpio.mode(pin, gpio.INPUT)
  while (gpio_read(pin) == 0 ) do end
  local c=0
  while (gpio_read(pin) == 1 and c < 500) do c = c + 1 end

  while (gpio_read(pin) == 0 ) do end
  c=0
  while (gpio_read(pin) == 1 and c < 500) do c = c + 1 end
  
  for j = 1, 40, 1 do
    while (gpio_read(pin) == 1 and bitlength < 10 ) do
      bitlength = bitlength + 1
    end
    bitStream[j] = bitlength
    bitlength = 0

    while (gpio_read(pin) == 0) do end
  end
end
function M.read11(pin)
 read(pin)
 local checksum = 0
 local checksumTest
  for i = 1, 8, 1 do -- Byte[0]
    if (bitStream[i] > 3) then
      humidity = humidity + 2 ^ (8 - i)
    end
  end
  for i = 1, 8, 1 do -- Byte[2]
    if (bitStream[i + 16] > 3) then
      temperature = temperature + 2 ^ (8 - i)
    end
  end
  for i = 1, 8, 1 do --Byte[4]
    if (bitStream[i + 32] > 3) then
      checksum = checksum + 2 ^ (8 - i)
    end
  end

  if(checksum ~= humidity+temperature) then
    humidity = nil
    temperature = nil
  end
  
end
function M.read22( pin )
  read(pin)
  local checksum = 0
  local checksumTest
  for i = 1, 16, 1 do
    if (bitStream[i] > 3) then
      humidity = humidity + 2 ^ (16 - i)
    end
  end
  for i = 1, 16, 1 do
    if (bitStream[i + 16] > 3) then
      temperature = temperature + 2 ^ (16 - i)
    end
  end
  for i = 1, 8, 1 do
    if (bitStream[i + 32] > 3) then
      checksum = checksum + 2 ^ (8 - i)
    end
  end
  checksumTest = (bit.band(humidity, 0xFF) + bit.rshift(humidity, 8) + bit.band(temperature, 0xFF) + bit.rshift(temperature, 8))
  checksumTest = bit.band(checksumTest, 0xFF)
  if temperature > 0x8000 then
    temperature = -(temperature - 0x8000)
  end
  if (checksumTest - checksum >= 1) or (checksum - checksumTest >= 1) then
    humidity = nil
  end
end

function M.getTemperature()
  return temperature
end

function M.getHumidity()
  return humidity
end

return M
