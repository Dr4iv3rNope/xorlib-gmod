function x.SetupScreenSize(callback, id)
	x.ExpectFunction(callback)
	id = x.ExpectStringOrDefault(id, x.CalleePath())

	callback(ScrW(), ScrH())

	if not (hook.GetTable().OnScreenSizeChanged or {})[id] then
		hook.Add("OnScreenSizeChanged", id, callback)
	end
end
