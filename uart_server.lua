uart.setup( 0, 9600, 8, 0, 1, 0 )
function print_ip()
     uart.write(0,0x02) 
     uart.write(0,"I"..wifi.sta.getip())
     uart.write(0,0x03)
end
print_ip()
s=net.createServer(net.TCP,180) 
s:listen(1001,function(c)   
    c:on("receive",function(c,l)       
     uart.write(0,0x02) 
     uart.write(0,l)
     uart.write(0,0x03)
    end) 
    function s_output(str)
       if (str.find(str, "GETIP")~=nil) then
          print_ip()
       else
          if(c~=nil) then c:send(str) end 
       end
    end 
    uart.on("data",s_output, 0)
    print("Connected\r\n")
end)
