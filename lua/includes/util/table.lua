AddCSLuaFile()

function table.indexOf(t, object)
    if type(t) ~= "table" then error("table expected, got " .. type(t), 2) end
    for i, v in pairs(t) do
        if object == v then
            return i
        end
    end
end

function table.filter(t, func)
    if type(t) ~= "table" then error("table expected, got " .. type(t), 2) end
    if type(func) ~= "function" then error("function expected, got "..type(func), 2) end
    for i,v in pairs(t) do
        if(!func(v)) then
            table.remove(t, i)
        end
    end
end

