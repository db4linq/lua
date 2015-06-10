print("set up wifi AP mode")
wifi.setmode(wifi.SOFTAP) 
cfg = {}
cfg.ssid = 'ESP8266-'..node.chipid()
cfg.pwd = '1234567890'
wifi.ap.config(cfg)

tmr.alarm(0, 2000, 0, function() 
    print ('Start HTTP Server')
    dofile('sample_http3.lc')
end)
