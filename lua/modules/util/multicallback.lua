AddCSLuaFile()
net.SendMultiple = function(callbackStrings, netMessage)
    if(type(callbackStrings)=="table") then
        for k,v in pairs(callbackStrings) do
            net.Start(v)
            netMessage()
        end
    else
        net.Start(callbackStrings)
        netMessage()
    end
end