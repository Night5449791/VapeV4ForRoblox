local ToxicDetector
local tUsernames

local tUsernames = {
	['maxsully124'] = 'underaged + toxic on cheater',
	['charIespl'] = 'sad guy cant realize i didnt kick him',
	['gundpro99'] = '"buddy you ain tuff", kys ninja',
	['PIutto777'] = 'he called me mossad agent + toxic',
}

local function playerAdded(plr)
	local reason = (Users and table.find(Users.ListEnabled, tostring(plr.UserId))) or cUsernames[plr.Name]	
	if reason then
		notif('ToxicDetector', 'Toxic Detected ('..reason..'): '..plr.Name, 60, 'warn')
		whitelist.customtags[plr.Name] = {{text = 'TOXIC', color = Color3.new(255, 255, 0)}}
		tempTargets[plr.Name] = true
	end
end

ToxicDetector = vape.Categories.Utility:CreateModule({
	Name = 'ToxicDetector',
	Function = function(callback)
		if callback then
			ToxicDetector:Clean(playersService.PlayerAdded:Connect(playerAdded))
			for _, v in playersService:GetPlayers() do
				task.spawn(playerAdded, v)
			end
		end
	end,
	Tooltip = 'Detects people with history of toxic, etc',
})