oled = require("oled")

oled.init(14, 12)

oled.set_pos(75, 3) -- set cursor to 75, 3

we = {"1","2","3","4","5","6"}

oled.write_word(we) -- write Hello(lol)
