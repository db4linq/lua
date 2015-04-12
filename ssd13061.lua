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

function box_frame(a)
     disp:drawStr(0, 0, "drawBox")
     disp:drawBox(5, 10, 20, 10)
     disp:drawBox(10+a, 15, 30, 7)
     disp:drawStr(0, 30, "drawFrame")
     disp:drawFrame(5, 10+30, 20, 10)
     disp:drawFrame(10+a, 15+30, 30, 7)
end

function ascii_1()
     local x, y, s
     disp:drawStr(0, 0, "ASCII page 1")
     for y = 0, 5, 1 do
          for x = 0, 15, 1 do
               s = y*16 + x + 32
               disp:drawStr(x*7, y*10+10, string.char(s))
          end
     end
end
 
init_i2c_display()
prepare()

disp:firstPage()
repeat
     box_frame(6)
until disp:nextPage() == false
tmr.delay(50000)
-- re-trigger Watchdog!
tmr.wdclr()
disp:firstPage()
repeat
    ascii_1()
until disp:nextPage() == false

