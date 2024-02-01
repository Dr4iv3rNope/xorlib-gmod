xorlib.Dependency("xorlib/containers", "sh_map.lua")

local developer = GetConVar("developer")

x.OutgoingRequests = x.OutgoingRequests or {}

x.REQUEST_DIE_TIME = 30

local MAX_UINT = 4294967295

local function allocateNewRequest(callback)
    local id

    repeat
        id = math.random(0, MAX_UINT)
    until not x.OutgoingRequests[id]

    local request = {
        ID        = id,
        DieTime   = CurTime() + x.REQUEST_DIE_TIME,
        Callback  = callback,
        Traceback = developer:GetBool() and debug.traceback() or nil
    }

    x.OutgoingRequests[id] = request

    return request
end

local function processRequest(len, ply, netID, requestID, callback)
    net.Start(netID)
    net.WriteBool(false) -- response
    net.WriteUInt(requestID, 32)

    callback(len, ply)

    if CLIENT then
        net.SendToServer()
    else
        net.Send(ply)
    end
end

local function processResponse(len, ply, requestID)
    local request = x.OutgoingRequests[requestID]

    if not request then
        return x.Warn("Received unknown request (%d)", requestID)
    end

    x.OutgoingRequests[requestID] = nil

    request.Callback(len, ply)
end

function x.AddRequestNetworkString(netID, onRequest)
    if SERVER then
        util.AddNetworkString(netID)
    end

    net.Receive(netID, function(len, ply)
        local isRequest = net.ReadBool()
        len = len - 1

        local requestID = net.ReadUInt(32)
        len = len - 4

        if isRequest then
            if not onRequest then
                -- no process request callback
                return
            end

            processRequest(len, ply, netID, requestID, onRequest)
        else
            processResponse(len, ply, requestID)
        end
    end)
end

function x.StartRequest(netID, callback)
    local request = allocateNewRequest(callback)

    net.Start(netID)
    net.WriteBool(true) -- request
    net.WriteUInt(request.ID, 32)

    return request
end
