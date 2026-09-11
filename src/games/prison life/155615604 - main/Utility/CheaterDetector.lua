local CheaterDetector
local cheaters = {}
local cheaterFile = 'newvape/cheater.json'
local httpService = cloneref(game:GetService('HttpService'))

vape.Libraries.cheaters = cheaters

local function loadLocalCheaters()
	table.clear(cheaters)
	if not isfile(cheaterFile) then
		pcall(writefile, cheaterFile, '{}')
		return false
	end

	local readSuccess, contents = pcall(readfile, cheaterFile)
	if not readSuccess or type(contents) ~= 'string' or contents == '' then
		return false
	end

	local decodeSuccess, localCheaters = pcall(function()
		return httpService:JSONDecode(contents)
	end)
	if not decodeSuccess or type(localCheaters) ~= 'table' then
		return false
	end

	for username, reason in localCheaters do
		if type(username) == 'string' and type(reason) == 'string' then
			cheaters[username] = reason
		end
	end
	return true
end

local function saveLocalCheaters()
	local success, encoded = pcall(httpService.JSONEncode, httpService, cheaters)
	if success then
		pcall(writefile, cheaterFile, encoded)
	end
end

local function removeCheater(username)
	if not username or username == '' then
		return false
	end

	local storedUsername = username
	if not cheaters[storedUsername] then
		for candidate in cheaters do
			if candidate:lower() == username:lower() then
				storedUsername = candidate
				break
			end
		end
	end

	local removed = cheaters[storedUsername] ~= nil
	cheaters[storedUsername] = nil
	if whitelist and whitelist.customtags then
		whitelist.customtags[storedUsername] = nil
	end
	if tempTargets then
		tempTargets[storedUsername] = nil
	end
	return removed
end

loadLocalCheaters()

local function playerAdded(plr, notifyPlayer)
	local username = plr and plr.Name
	local reason = username and cheaters[username]
	if username and type(reason) == 'string' and reason ~= '' then
		if notifyPlayer ~= false then
			notif('CheaterDetector', 'Cheater Detected ('..reason..'): '..plr.Name, 60, 'alert')
		end
		whitelist.customtags[username] = {{text = 'Exploiter', color = Color3.new(1, 0, 0)}}
		tempTargets[username] = true
	end
end

local function addCheater(username, reason)
	cheaters[username] = reason
	saveLocalCheaters()
	playerAdded(playersService:FindFirstChild(username), false)
end

local function clearCheaters()
	if whitelist and whitelist.customtags then
		for username in cheaters do
			whitelist.customtags[username] = nil
		end
	end
	table.clear(cheaters)
	if tempTargets then
		table.clear(tempTargets)
	end
	saveLocalCheaters()
end

vape.Libraries.addCheater = addCheater
vape.Libraries.removeCheater = function(username)
	local removed = removeCheater(username)
	if removed then
		saveLocalCheaters()
	end
	return removed
end
vape.Libraries.clearCheaters = clearCheaters

CheaterDetector = vape.Categories.Utility:CreateModule({
	Name = 'CheaterDetector',
	Default = true,
	Function = function(callback)
		if callback then
			loadLocalCheaters()
			CheaterDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
			for _, v in playersService:GetPlayers() do
				task.spawn(playerAdded, v)
			end
		end
	end,
	Tooltip = 'Detects people with history of cheating',
})