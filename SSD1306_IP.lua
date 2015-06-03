
-- SDA and SCL can be assigned freely to available GPIOs
sda = 3
scl = 4
sla = 0x3c
i2c.setup(0, sda, scl, i2c.SLOW)
disp = u8g.ssd1306_128x64_i2c(sla)
-- graphic test components
disp:setFont(u8g.font_6x10)
disp:setFontRefHeightExtendedText()
disp:setDefaultForegroundColor()
disp:setFontPosTop()
if ssid == nil then ssid = "N/A" end
function init()
     disp:firstPage()
     repeat
          disp:drawStr(40, 10, "NodeMCU")
          disp:drawStr(5, 28, "SSID: " .. ssid)
          disp:drawStr(15, 47, "Connecting ...")
     until disp:nextPage() == false
end
function display()
     disp:firstPage()
     repeat
          disp:drawStr(10, 10, "IP Address:")
          disp:drawStr(30, 28, wifi.sta.getip().."")
          disp:drawStr(20, 47, "ID: "..node.chipid())
     until disp:nextPage() == false
end


