AddCSLuaFile()
string.compare = function(a,b)
    local alow = string.lower(a)
    local blow = string.lower(b)
    for i=0,math.max(#alow,#blow) do
        local aval = ""
        if(i<=#alow) then
            aval = alow[i]
        end
        local bval = ""
        if(i<=#blow) then
            bval = blow[i]
        end
        if(aval!=bval) then
            return string.byte(aval,0,1)-string.byte(bval,0,1)
        end
    end
    return 0
end