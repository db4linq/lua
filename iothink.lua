local moduleName = "iothink"
local M = {}
_G[moduleName] = M
local func = {}
local var = {}
local conn = nil
local deviceId = 1
local node_name = "Node 1"
local core_Id = node.chipid()
local server = "103.22.180.136"

local function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
local function receive(conn, payload)
     list=split(payload,"|")
     if (list[1] == 'V') then
          local _valiable = var[list[2]]
          if (_valiable ~= nil) then
               local _result = _valiable()
               conn:send('{ "type": 2, "data": '.._result..' }')
          else
               conn:send('{ "type": 2, "data": { "result": "error", "msg": "Valiable not found" } }')
          end
     end
     if (list[1] == 'F') then
          local _function = func[list[2]]
          if (_function ~= nil) then
               local param = list[3]
               local _result = _function(param)
               --print(_result)
               conn:send('{ "type": 3, "data": '.._result..' }')
          else
               conn:send('{ "type": 3, "data": { "result": "error", "msg": "function not found" } }')
          end
     end
end
function M.init(id, nodeName, coreId) 
     deviceId = id
     if (nodeName ~= nil) then
          node_name = nodeName
     end
     if (coreId ~= nil) then
          core_Id = coreId
     end
end
function M.connect()  
     
     conn=net.createConnection(net.TCP, 0)
     --conn:on("reconnection", function() 
     --     print("Disconnection..") 
     --end);
     conn:on("connection", function() 
          print("Connected..")
          print("You Core ID: "..core_Id.."")
          conn:send('{ "type": 1, "data": "'.. core_Id .. '", "name": "'..node_name..'"}')
     end);
     conn:on("receive", receive)
     conn:on("disconnection", function() 
          print("Disconnected..")
          tmr.alarm(0, 3000, 0, function() 
               ip = wifi.sta.getip()
               if ip=="0.0.0.0" or ip==nil then
                   node.restart()
               else
                   print("Reconnection..") 
                   conn = nil
                   M.connect() 
               end
          end)
     end);   
     conn:connect(5683, server)  
end
function M.alert(msg, msgType)
     conn:send('{ "type": '..msgType..', "deviceID": "'.. core_Id ..'", "data": '..msg..' }')
end
function M.addVariable(name, vr)
     var[name] = vr
end
function M.addFunction(name, fn)
     func[name] = fn
end

return M
