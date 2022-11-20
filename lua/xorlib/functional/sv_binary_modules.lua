do
	local isX86 = jit.arch == "x86"

	if system.IsLinux() then
		x.BinaryArch = isX86 and "linux" or "linux64"
	elseif system.IsWindows() then
		x.BinaryArch = isX86 and "win32" or "win64"
	elseif system.IsOSX() then
		x.BinaryArch = "osx"
	end
end

function x.HasBinaryModule(name)
	return file.Exists(
		string.format(
			"bin/gmsv_%s_%s.dll",
			name,
			x.BinaryArch
		),
		"LUA"
	)
end

function x.RequireModule(name)
	x.ExpectString(name)

	if not x.HasBinaryModule(name) then
		x.ErrorNoHalt(
			"Binary module \"%s\" doesn't exist",
			name
		)

		return false
	end

	local success, err = pcall(require, name)

	if not success then
		x.ErrorNoHalt(
			"Failed to require binary module \"%s\": %s",
			name,
			err
		)

		return false
	end

	return true
end
