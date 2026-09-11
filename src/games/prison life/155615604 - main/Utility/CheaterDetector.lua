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
			CheaterDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
			for _, v in playersService:GetPlayers() do
				task.spawn(playerAdded, v)
			end
		end
	end,
	Tooltip = 'Detects people with history of cheating',
})