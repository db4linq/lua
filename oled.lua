local moduleName = "oled"
local M = {}
_G[moduleName] = M

oled_id = 0
oled_gpio = {[0]=3,[2]=4,[4]=2,[5]=1,[12]=6,[13]=7,[14]=5}
oled_sda = oled_gpio[0]
oled_scl = oled_gpio[2]
oled_addr = 0x3C

ascii = {}

ascii[0] = {}
ascii[0][0] = 0x3e
ascii[0][1] = 0x51
ascii[0][2] = 0x49
ascii[0][3] = 0x45
ascii[0][4] = 0x3e

ascii[1] = {}
ascii[1][0] = 0x00
ascii[1][1] = 0x42
ascii[1][2] = 0x7f
ascii[1][3] = 0x40
ascii[1][4] = 0x00

ascii[2] = {}
ascii[2][0] = 0x42
ascii[2][1] = 0x61
ascii[2][2] = 0x51
ascii[2][3] = 0x49
ascii[2][4] = 0x46

ascii[3] = {}
ascii[3][0] = 0x21
ascii[3][1] = 0x41
ascii[3][2] = 0x45
ascii[3][3] = 0x4b
ascii[3][4] = 0x31

ascii[4] = {}
ascii[4][0] = 0x18
ascii[4][1] = 0x14
ascii[4][2] = 0x12
ascii[4][3] = 0x7f
ascii[4][4] = 0x10

ascii[5] = {}
ascii[5][0] = 0x27
ascii[5][1] = 0x45
ascii[5][2] = 0x45
ascii[5][3] = 0x45
ascii[5][4] = 0x39

ascii[6] = {}
ascii[6][0] = 0x3c
ascii[6][1] = 0x4a
ascii[6][2] = 0x49
ascii[6][3] = 0x49
ascii[6][4] = 0x30

ascii[7] = {}
ascii[7][0] = 0x01
ascii[7][1] = 0x71
ascii[7][2] = 0x09
ascii[7][3] = 0x05
ascii[7][4] = 0x03

ascii[8] = {}
ascii[8][0] = 0x36
ascii[8][1] = 0x49
ascii[8][2] = 0x49
ascii[8][3] = 0x49
ascii[8][4] = 0x36

ascii[9] = {}
ascii[9][0] = 0x06
ascii[9][1] = 0x49
ascii[9][2] = 0x49
ascii[9][3] = 0x29
ascii[9][4] = 0x1e

function write_reg(dev_addr, reg_addr, reg_val)
     i2c.start(oled_id)
     i2c.address(oled_id, dev_addr, i2c.TRANSMITTER)
     i2c.write(oled_id, reg_addr)
     i2c.write(oled_id, reg_val)
     i2c.stop(oled_id)
end

function oled_command(cmd)
     write_reg(oled_addr, 0, cmd)
end

function M.init(sda_n, scl_n)
     oled_sda = oled_gpio[sda_n]
     oled_scl = oled_gpio[scl_n]

     i2c.setup(oled_id, oled_sda, oled_scl, i2c.SLOW)

     oled_command(0x8d)
     oled_command(0x14)
     oled_command(0xaf)
     
     oled_command(0xd3)
     oled_command(0x00)
     oled_command(0x40)
     oled_command(0xa1)
     oled_command(0xc8)
     oled_command(0xda)
     oled_command(0x12)
     oled_command(0x81)
     oled_command(0xff)

     oled_command(0x20)
     oled_command(0x02)
end

function M.on()
     oled_command(0xAF)
end

function M.off()
     oled_command(0xAE)
end

function M.invert(state)
     if state == 1 then
          oled_command(0xA7)
     else
          oled_command(0xA6)
     end
end

function M.scroll(start, stop, left)
     if left then
          oled_command(0x26)
     else
          oled_command(0x27)
     end
     oled_command(0X00)
     oled_command(start)
     oled_command(0X00)
     oled_command(stop)
     oled_command(0X00)
     oled_command(0XFF)
     oled_command(0x2F)
end

function M.scroll_stop()
     oled_command(0x2E)
end

function M.set_pos(x, y)
     xp = bit.band(x, 0xf0)
     xp = bit.rshift(xp, 4)
     xp = bit.bor(xp, 0x10)
     
     xr = bit.band(x, 0x0f)
     xr = bit.bor(xr, 0x01)
     
     oled_command(0xB0+y)
     oled_command(xp)
     oled_command(xr)
end

function M.clear()
     oled_command(0x20)
     oled_command(0x01)
     for i=0,1024 do
          write_reg(oled_addr, 0x40, 0x00)
          tmr.wdclr()
     end
     oled_command(0x20)
     oled_command(0x02)
end

function M.write_char(char)
     for ic=0,4 do
          write_reg(oled_addr, 0x40, ascii[char][ic])
          tmr.wdclr()
     end
end

function M.write_word(_word)
     _wc = 1
     while _word[_wc] do
          M.write_char(_word[_wc])
          _wc=_wc+1
     end
end

return M