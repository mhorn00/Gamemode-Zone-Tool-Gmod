AddCSLuaFile()

if SERVER then
    util.AddNetworkString("gzt_chunkmessage")
    util.AddNetworkString("gzt_ratemessage")
end

net.gzt_ChunkQueue = {}
local tickdelay = 0
hook.Add("Tick", "gzt_chunkqueue", function()
    if #net.gzt_ChunkQueue > 0 then
        local chunkspertick = 4
        if tickdelay == 0 then
            tickdelay = 35 //32 seems to be the fastest but i want to allow some headroom if other things are sent
            for i=1, #net.gzt_ChunkQueue<=chunkspertick and #net.gzt_ChunkQueue or chunkspertick do
                local chunkdata = net.gzt_ChunkQueue[i]
                print("CHUNK Q sending chunk "..chunkdata.num_chunk.." of "..chunkdata.total_chunks.." for "..chunkdata.callback)
                net.Start("gzt_chunkmessage")
                    net.WriteString(chunkdata.callback)
                    net.WriteUInt(chunkdata.num_chunk, 16)
                    net.WriteUInt(chunkdata.total_chunks, 16)
                    net.WriteUInt(chunkdata.chunk_length, 16)
                    net.WriteData(chunkdata.data, chunkdata.chunk_length)
                if SERVER then
                    if(!IsValid(chunkdata.ply)) then
                        net.Broadcast()
                    else
                        net.Send(chunkdata.ply)
                    end
                end
                if CLIENT then
                    net.SendToServer()
                end
            end
            for i=1, #net.gzt_ChunkQueue<=chunkspertick and #net.gzt_ChunkQueue or chunkspertick do
                table.remove(net.gzt_ChunkQueue, 1)
            end
        else 
            --print("tick delay... "..tickdelay)
            tickdelay = tickdelay-1
        end
    elseif tickdelay!=0 then
        tickdelay=0
    end
end)

net.SendChunks = function(cb, tableToSend, ply)
    local max_bytes_per_chunk = 64000 - (#cb+1) - 2 - 2 - 2 //callback len +1 for string overhead, curChunk, num_chunks, chunk_len for unsigned 16 bit int
    local compressed = util.Compress(util.TableToJSON(tableToSend))    
    local num_chunks = math.ceil(#compressed / max_bytes_per_chunk)
    local curChunk = 1
    repeat
        print("Processing chunk "..curChunk.." of "..num_chunks.." for "..cb)
        local chunkdata = {
            data="", 
            callback=cb, 
            num_chunk=curChunk, 
            total_chunks=num_chunks, 
            chunk_length=-1,
            ply=ply
        }
        local endPos = curChunk*max_bytes_per_chunk
        if endPos>#compressed then
            endPos = #compressed
        end
        chunkdata.data=string.sub(compressed,(curChunk-1)*max_bytes_per_chunk+1,endPos)
        chunkdata.chunk_length = #chunkdata.data
        net.gzt_ChunkQueue[#net.gzt_ChunkQueue+1] = chunkdata
        curChunk = curChunk+1
    until curChunk>num_chunks
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
    print("RECIVING CHUNK "..chunk_num.." of "..total_chunks.." for "..msg_name)
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

local message_buffer = {}
net.RateReceive = function(msg,callback)
    net.Receive(msg, function(len,ply)
        if message_buffer[ply:UserID()]==nil then
            message_buffer[ply:UserID()] = false
        end
        if message_buffer[ply:UserID()]==false then
            callback(len,ply)
            message_buffer[ply:UserID()] = true
            timer.Simple(0.175,function()
                message_buffer[ply:UserID()] = false
            end)
        end
    end)
end