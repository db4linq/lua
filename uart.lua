server = "192.168.1.49"
port = 5683
node_name = "Test"
uart.setup( 0, 9600, 8, 0, 1, 0 )
conn=net.createConnection(net.TCP, 0)
function print_ip()
     uart.write(0,0x02) 
     uart.write(0,"I"..wifi.sta.getip())
     uart.write(0,0x03)
end
conn:on("receive", function(conn, payload)
     uart.write(0,0x02) 
     uart.write(0,payload)
     uart.write(0,0x03)
end) 
conn:on("disconnection", function()  
     uart.write(0,0x02) 
     uart.write(0,"C")
     uart.write(0,0x03)    
end)
conn:on("connection", function()
     print_ip()
     function s_output(str)
       if (str.find(str, "GETIP")~=nil) then
          print_ip()
       else
          if(c~=nil) then c:send(str) end 
       end
     end 
     uart.on("data",s_output, 0)
     conn:send('{ "type": 1, "data": "'.. node.chipid() .. '", "name": "'..node_name..'"}')
end)
conn:connect(port, server) 
