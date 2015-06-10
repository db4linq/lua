sv=net.createServer(net.TCP, 30)    -- 30s time out for a inactive client
    -- server listen on 80, if data received, print data to console, and send "hello world" to remote.
sv:listen(80,function(c)
    c:on("receive", function(c, pl) print(pl) end)
    c:send("hello world")
end)