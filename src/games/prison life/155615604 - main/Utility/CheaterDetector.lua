local CheaterDetector
local cheaters = {}
local cheaterFile = 'newvape/cheater.json'
local playerAdded
local skidCommands = {
	addskid = true,
	rmskid = true,
	delskid = true
}

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

local function handleChat(message)
	local command, args = message:match('^%.(%S+)%s*(.*)$')
	command = command and command:lower()
	if not command or not skidCommands[command] then
		return
	end

	args = args:match('^%s*(.-)%s*$')
	if command == 'addskid' then
		local username, reason = args:match('^(%S+)%s*(.-)$')
		if not username or username == '' then
			notif('CheaterDetector', 'Usage: .addskid <username> [reason]', 5, 'warning')
			return
		end

		cheaters[username] = reason ~= '' and reason or 'manual'
		saveLocalCheaters()
		playerAdded(playersService:FindFirstChild(username))
		notif('CheaterDetector', username..' added to the cheater list.', 5)
	elseif command == 'rmskid' then
		if removeCheater(args) then
			saveLocalCheaters()
			notif('CheaterDetector', args..' removed from the cheater list.', 5)
		else
			notif('CheaterDetector', 'No cheater found for '..(args ~= '' and args or 'the provided username')..'.', 5, 'warning')
		end
	elseif args == '' then
		table.clear(cheaters)
		if whitelist and whitelist.customtags then
			for username in tempTargets do
				whitelist.customtags[username] = nil
			end
		end
		if tempTargets then
			table.clear(tempTargets)
		end
		saveLocalCheaters()
		notif('CheaterDetector', 'Cheater list cleared.', 5)
	else
		if removeCheater(args) then
			saveLocalCheaters()
			notif('CheaterDetector', args..' removed from the cheater list.', 5)
		else
			notif('CheaterDetector', 'No cheater found for '..args..'.', 5, 'warning')
		end
	end
end

loadLocalCheaters()

playerAdded = function(plr)
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
			CheaterDetector:Clean(lplr.Chatted:Connect(handleChat))
			CheaterDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
			for _, v in playersService:GetPlayers() do
				task.spawn(playerAdded, v)
			end
		end
	end,
	Tooltip = 'Detects people with history of cheating',
})