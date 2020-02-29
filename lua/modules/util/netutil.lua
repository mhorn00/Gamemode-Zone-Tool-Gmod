AddCSLuaFile()

if SERVER then
    util.AddNetworkString("gzt_chunkmessage")
end

net.SendMultiple = function(callbackStrings, netMessage)
    if(type(callbackStrings)=="table") then
        for k,v in pairs(callbackStrings) do
            util.AddNetworkString(v)
            net.Start(v)
            netMessage()
        end
    else
        net.Start(callbackStrings)
        netMessage()
    end
end

local server_chunks = {}

net.SendChunks = function(cb, tableToSend, ply)
    local max_bytes_per_chunk = 64000 - #cb - 2 - 2 - 2// callback len, curChunk, num_chunks, chunk_len for unsigned 16 bit int
    local json_string = util.TableToJSON(tableToSend)
    local compressed = util.Compress(json_string)    
    local chunks = {}
    local num_chunks = #compressed / max_bytes_per_chunk
    local curChunk = 0
    repeat 
        print("sending a chunk")
        net.Start("gzt_chunkmessage")
            net.WriteString(cb)
            net.WriteUInt(curChunk, 16)
            net.WriteUInt(num_chunks, 16)  
            local endPos = (curChunk+1)*(max_bytes_per_chunk)
            if((curChunk+1)*(max_bytes_per_chunk)>#compressed) then
                endPos = #compressed
            end
            net.WriteUInt(endPos-curChunk*max_bytes_per_chunk,16)
            local substr = string.sub(compressed,curChunk*max_bytes_per_chunk+1,endPos)
            net.WriteData(substr,endPos-curChunk*max_bytes_per_chunk)
        if(!IsValid(ply)) then
            net.Broadcast()
        else
            net.Send(ply)
        end
        curChunk = curChunk+1
    until curChunk>=num_chunks

end

local receiving_chunks = {}

net.Receive("gzt_chunkmessage", function(len, ply)
    local msg = nil
    local msg_name = net.ReadString()
    if(!receiving_chunks[msg_name]) then
        receiving_chunks[msg_name]= {}
    end
    local chunk_num = net.ReadUInt(16)
    local total_chunks = net.ReadUInt(16)
    local chunk_len = net.ReadUInt(16)
    receiving_chunks[msg_name][chunk_num]=net.ReadData(chunk_len)
    if(#receiving_chunks[msg_name]==total_chunks) then
        for k,v in pairs(receiving_chunks[msg_name]) do
            if(msg !=nil ) then
                msg = msg .. v
            else
                msg=v
            end
        end
        local receivedtable = util.JSONToTable(util.Decompress(msg))
        hook.Run(msg_name,receivedtable)
    end
end)