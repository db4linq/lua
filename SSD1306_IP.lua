function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     sda = 5 -- GPIO14
     scl = 6 -- GPIO12
     sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
end
-- graphic test components
function prepare()
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end
function ip()
     disp:drawStr(10, 10, "IP Address:")
     disp:drawStr(30, 25, wifi.sta.getip().."")
     disp:drawStr(20, 47, "Power By NodeMCU")
end
function display()
     init_i2c_display()
     prepare()

     disp:firstPage()
     repeat
         ip()
     until disp:nextPage() == false
end

display()