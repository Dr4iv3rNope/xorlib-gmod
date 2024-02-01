timer.Create("xorlib requests cleanup", 30, 0, function()
    for id, request in pairs(x.OutgoingRequests) do
        if CurTime() > request.DieTime then
            x.OutgoingRequests[id] = nil

            if request.Traceback then
                x.Warn("Request \"%d\" timed out!\n%s", id, request.Traceback)
            else
                x.Warn("Request \"%d\" timed out!", id)
            end
        end
    end
end)
