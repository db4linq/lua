handlers = {}
length = 0
function response(status, body)
    if body == nil then
        body = ''
    end
    length = string.len(body)
    return 'HTTP/1.0 '..status..' OK\r\nServer: esphttpd/0.9\r\nContent-Type: text/html\r\nContent-Length: '..length..'\r\nConnection: close\r\n\r\n'..body
end
function urlDecode(str)
    if str == nil then
        return nil
    end
    str = string.gsub(str, '+', ' ')
    str = string.gsub(str, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return str
end
function render(filename, subs)
    file.open(filename, 'r')
    content = ''
    while true do
        local line = file.readline()
        if line == nil then
            break
        end
        for k, v in pairs(subs) do
            line = string.gsub(line, '{{'..k..'}}', v)
        end
        content = content .. line
        line = nil
    end
    return content
end
function hello(conn, path, method, data)
    conn:send(response(200, '<h1>hello world</h1>'))
end
function calculator(conn, path, method, data)
    local result = '<h1>result: <strong>1 + 1 = 2</strong></h1>'
    if method == 'POST' then
        local num1 = tonumber(string.gmatch(data, 'num1=([0-9]+)')())
        local sign = urlDecode(string.gmatch(data, 'sign=([^&]+)')())
        local num2 = tonumber(string.gmatch(data, 'num2=([0-9]+)')())
        local resultNum = 'NaN'
        if sign == '+' then
            resultNum = num1 + num2
        end
        if sign == '-' then
            resultNum = num1 - num2
        end
        if sign == '*' then
            resultNum = num1 * num2
        end
        if sign == '/' then
            resultNum = num1 / num2
        end
        result = '<h1>result: <strong>'..num1..' '..sign..' '..num2..' = '..resultNum..'</strong></h1>'
    end
    local body = render('calculator.html', {result=result})
    conn:send(response(200, body))
end
function receive(conn, data)
    local i, j = string.find(data, '\r\n\r\n')
    if i == nil then
        return false
    end
    local header = string.sub(data, 1, i-1)
    local body = string.sub(data, i+4, -1)
    local data = nil
    local method, path = 'GET', string.gmatch(header, 'GET ([0-9a-zA-Z.-_/]+) HTTP/1.+')()
    if path == nil then
        method, path = 'POST', string.gmatch(header, 'POST ([0-9a-zA-Z.-_/]+) HTTP/1.+')()
    end
    if path == nil then
        return
    end
    func = handlers[path]
    if func == nil then
        conn:send(response(404, '404 Not Found'))
        return
    end
    func(conn, path, method, body)
    i = nil
    j = nil
    header = nil
    body = nil
    data = nil
    method = nil
    path = nil
    
end
function handle(path, func)
    handlers[path] = func
end
function run()
    srv = net.createServer(net.TCP) 
    srv:listen(80, function(conn)
     conn:on('receive', receive)
    end)
    handle('/', calculator)
    handle('/hello/', hello)
end
run()

