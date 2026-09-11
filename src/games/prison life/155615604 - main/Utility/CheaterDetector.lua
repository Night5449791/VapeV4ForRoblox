local CheaterDetector
local cheaters = {}
local cheaterFile = 'newvape/cheater.json'

vape.Libraries.cheaters = cheaters

local function loadLocalCheaters()
	if not isfile(cheaterFile) then
		pcall(writefile, cheaterFile, '{}')
		return
	end

	local success, localCheaters = pcall(function()
		return httpService:JSONDecode(readfile(cheaterFile))
	end)
	if not success or type(localCheaters) ~= 'table' then
		return
	end

	for username, reason in localCheaters do
		if type(username) == 'string' and type(reason) == 'string' then
			cheaters[username] = reason
		end
	end
end

loadLocalCheaters()

local tagCallbackAdded = false
local function addTag(plr, tags)
	if type(tags) ~= 'table' then
		return
	end

	local username = plr and plr.Name
	local reason = username and cheaters[username]
	if type(reason) ~= 'string' or reason == '' then
		return
	end

	for _, tag in tags do
		if tag.text == 'Exploiter' then
			return
		end
	end

	table.insert(tags, {text = 'Exploiter', color = Color3.new(1, 0, 0)})
end

local function trim(value)
	return value:match('^%s*(.-)%s*$')
end

local function findPlayer(prefix)
	if not prefix or prefix == '' then
		return nil
	end

	local lowered = prefix:lower()
	for _, player in playersService:GetPlayers() do
		local displayName = player.DisplayName
		if displayName and displayName:lower():sub(1, #lowered) == lowered then
			return player
		end
	end
	return nil
end

local function saveCheater(username, reason)
	local list = {}
	if isfile(cheaterFile) then
		local success, data = pcall(function()
			return httpService:JSONDecode(readfile(cheaterFile))
		end)
		if success and type(data) == 'table' then
			list = data
		end
	end

	list[username] = reason
	local success = pcall(function()
		writefile(cheaterFile, httpService:JSONEncode(list))
	end)
	if success then
		cheaters[username] = reason
	end
	return success
end

local function removeCheater(username)
	if not isfile(cheaterFile) then
		return false
	end

	local success, list = pcall(function()
		return httpService:JSONDecode(readfile(cheaterFile))
	end)
	if not success or type(list) ~= 'table' or list[username] == nil then
		return false
	end

	list[username] = nil
	local saved = pcall(function()
		writefile(cheaterFile, httpService:JSONEncode(list))
	end)
	if saved then
		cheaters[username] = nil
	end
	return saved
end

local function parseAddSkid(body)
	for split = #body, 1, -1 do
		if body:sub(split, split):match('%s') then
			local player = findPlayer(trim(body:sub(1, split - 1)))
			local reason = trim(body:sub(split + 1))
			if player and reason ~= '' then
				return player, reason
			end
		end
	end
	return nil
end

local function clearPlayer(player)
	whitelist.customtags[player.Name] = nil
	tempTargets[player.Name] = nil
end

local function handleChat(message)
	local command, args = message:match('^%.(%S+)%s*(.*)$')
	command = command and command:lower()
	if command == 'addskid' then
		local player, reason = parseAddSkid(args)
		if not player or not saveCheater(player.Name, reason) then
			notif('CheaterDetector', 'Usage: .addskid <displayname> <reason>', 5, 'warning')
			return
		end

		whitelist.customtags[player.Name] = {{text = 'Exploiter', color = Color3.new(1, 0, 0)}}
		tempTargets[player.Name] = true
		notif('CheaterDetector', 'Added '..player.DisplayName..' to cheater list.', 5, 'alert')
	elseif command == 'rmskid' or command == 'delskid' then
		local player = findPlayer(trim(args))
		if not player or not removeCheater(player.Name) then
			notif('CheaterDetector', 'Player is not in the local cheater list.', 5, 'warning')
			return
		end

		clearPlayer(player)
		notif('CheaterDetector', 'Removed '..player.DisplayName..' from cheater list.', 5)
	end
end

local function playerAdded(plr)
	local username = plr and plr.Name
	local reason = username and cheaters[username]
	if username and type(reason) == 'string' and reason ~= '' then
		notif('CheaterDetector', 'Cheater Detected ('..reason..'): '..plr.Name, 60, 'alert')
		whitelist.customtags[username] = {{text = 'Exploiter', color = Color3.new(1, 0, 0)}}
		tempTargets[username] = true
	end
end

CheaterDetector = vape.Categories.Utility:CreateModule({
	Name = 'CheaterDetector',
	Default = true,
	Function = function(callback)
		if callback then
			if not tagCallbackAdded and whitelist and whitelist.tagcallback then
				table.insert(whitelist.tagcallback, addTag)
				tagCallbackAdded = true
			end
			CheaterDetector:Clean(lplr.Chatted:Connect(handleChat))
			CheaterDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
			for _, v in playersService:GetPlayers() do
				task.spawn(playerAdded, v)
			end
		end
	end,
	Tooltip = 'Detects people with history of cheating',
})