function x.RequireModule(name)
	x.ExpectString(name)

	if not util.IsBinaryModuleInstalled(name) then
		return false, string.format("Binary module \"%s\" not installed")
	end

	local success, err = pcall(require, name)

	if not success then
		return false, string.format("Failed to require binary module \"%s\": %s", name, err)
	end

	return true
end
