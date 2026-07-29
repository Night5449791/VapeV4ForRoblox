local CheaterDetector
local Mode
local Profile
local Users
local Group
local Role

local cIds = {
	[2237398751] = true,
	[2030419772] = true,
}

local function playerAdded(plr)
	if not vape.Loaded then
		repeat task.wait() until vape.Loaded
	end
	
	local reason = (Users and table.find(Users.ListEnabled, tostring(plr.UserId))) and 'blacklisted_user'
		or cIds[plr.UserId] and 'cheater_userid'
		
	if reason then
		notif('CheaterDetector', 'Cheater Detected ('..reason..'): '..plr.Name, 60, 'alert')
		whitelist.customtags[plr.Name] = {{text = 'CHEATER', color = Color3.new(1, 0, 0)}}
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