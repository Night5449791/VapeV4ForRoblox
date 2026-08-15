-- we all code for shits lol

local CheaterDetector
local cUsernames
local Users

local cUsernames = {
	['WyRaff'] = 'speedhack,teleporting', -- vc server common
	['Bonjour394'] = 'skid thinks hes powerful', -- hes js a jerk
	['princeofegypt'] = 'skid, gets kicked for fling attempt', -- imagine gets kicked for script that kicks
	
	['PraiseDracc'] = 'known exploiter', -- since he is commonly in vc server
	['jerry_plsnoban7'] = 'skid,fling and got kicked', -- cringe
	['jerry_plsnoban6'] = 'skid alt acc,fling and got kicked',
	['jerry_plsnoban5'] = 'skid alt acc,fling and got kicked',
	
	['rudeeis_ab'] = 'noclipping ahhh hack', -- saint member, dont they even use the same thing
	['centipedeinmyheads'] = 'aimbot, wallbanging', -- another saint member lol
	['dannielll51'] = 'headsit rip', -- inspired, vape antiheadsit soon.
	['JOJI12416'] = 'known exploiter', -- kerax if u wonder
	['BestCode_BaconThx'] = 'fling attempt, ac mod',  -- ac mod in .gg/prisonlife
	['RazhulanDeveloper'] = 'fling attempt, not a skid but he does that', -- respect, ac mod
	--skids
	['jbskjbg'] = 'platform stand exp',
	['1267_isevil'] = 'skid, failed fling attempt',
	['1987_isevil'] = 'skid, failed fling attempt',
	['HeyiamTheCooolest'] = 'skid, slimed w/ vape v4',
	['Chill_baconr00'] = 'skid, highjump', -- skid using vape v4 from 7granddadpgn and cant beat me XD
	['PrisonLife_UberDrive'] = 'skid, vfly user', -- hes chilling added for vfly
	['gcfhjfjf4'] = 'skid, highjump . aimbot'
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