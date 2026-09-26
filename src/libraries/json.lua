local httpService = cloneref(game:GetService("HttpService"))

local jsonlib = {}

function jsonlib.read(path)
	local data = readfile(path)
	if not data then return nil end
	local ok, res = pcall(function()
		return httpService:JSONDecode(data)
	end)
	if not ok then return nil end
	return res
end

function jsonlib.write(path, content)
	local data = httpService:JSONEncode(content)
	if not data then return false end
	local ok = pcall(function()
		writefile(path, data)
	end)
	return ok
end

return jsonlib
