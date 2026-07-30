-- i vibecoded this enjoy

local CheaterDetector
local Mode
local Profile
local Users

local cUsernames = {
	["LaylaPowerGalaxy"] = 'known exploiter', -- @night5449791
	['WyRaff'] = 'speedhack,teleporting', -- vc server common
	['Bonjour394'] = 'skid thinks hes powerful', -- hes js a jerk
	['princeofegypt'] = 'skid, gets kicked for fling attempt', -- imagine gets kicked for script that kicks
	['Chill_baconr00'] = 'skid, highjump', -- skid using vape v4 from 7granddadpgn and cant beat me XD
	['PraiseDracc'] = 'known exploiter', -- since he is commonly in vc server
	['jerry_plsnoban7'] = 'skid,fling and got kicked',
	['jerry_plsnoban6'] = 'skid alt acc,fling and got kicked',
	['jerry_plsnoban5'] = 'skid alt acc,fling and got kicked',
}

local function playerAdded(plr)
	local reason = (Users and table.find(Users.ListEnabled, tostring(plr.UserId))) or cUsernames[plr.Name]	
	if reason then
		notif('CheaterDetector', 'Cheater Detected ('..reason..'): '..plr.Name, 60, 'alert')
		whitelist.customtags[plr.Name] = {{text = 'CHEATER', color = Color3.new(1, 0, 0)}}
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