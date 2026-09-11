local CheaterDetector
local cheaters = vape.Libraries.cheaters or {}
local file = 'newvape/games/cheater.json'

if not isfile(file) then
	pcall(function()
		writefile(file, '{}')
	end)
end

if isfile(file) then
	local success, localCheaters = pcall(function()
		return httpService:JSONDecode(readfile(file))
	end)
	if success and type(localCheaters) == 'table' then
		for username, reason in localCheaters do
			if cheaters[username] == nil then
				cheaters[username] = reason
			end
		end
	end
end

local function playerAdded(plr)
	local reason = cheaters[plr.Name]
	if reason then
		notif('CheaterDetector', 'Cheater Detected ('..reason..'): '..plr.Name, 60, 'alert')
		whitelist.customtags[plr.Name] = {{text = 'Exploiter', color = Color3.new(1, 0, 0)}}
		tempTargets[plr.Name] = true
	end
end

CheaterDetector = vape.Categories.Utility:CreateModule({
	Name = 'CheaterDetector',
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