-- TODO: remove x.HasBinaryModule
--
-- util.IsBinaryModuleInstalled available on the dev branch 2022.08.12
if util.IsBinaryModuleInstalled == x.HasBinaryModule then
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

	util.IsBinaryModuleInstalled = x.HasBinaryModule
else
	x.ErrorNoHalt("util.IsBinaryModuleInstalled has been added (2022.08.12)")
end

function x.RequireModule(name)
	x.ExpectString(name)

	if not util.IsBinaryModuleInstalled(name) then
		return false, string.format("Binary module \"%s\" not installed", name)
	end

	local success, err = pcall(require, name)

	if not success then
		return false, string.format("Failed to require binary module \"%s\": %s", name, err)
	end

	return true
end
