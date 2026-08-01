-- i vibecoded this enjoy
-- we all code for shits lol

local CheaterDetector
local Mode
local Profile
local Users

local cUsernames = {
	['WyRaff'] = 'speedhack,teleporting', -- vc server common
	['Bonjour394'] = 'skid thinks hes powerful', -- hes js a jerk
	['princeofegypt'] = 'skid, gets kicked for fling attempt', -- imagine gets kicked for script that kicks
	['Chill_baconr00'] = 'skid, highjump', -- skid using vape v4 from 7granddadpgn and cant beat me XD
	['PraiseDracc'] = 'known exploiter', -- since he is commonly in vc server
	['jerry_plsnoban7'] = 'skid,fling and got kicked', -- cringe
	['jerry_plsnoban6'] = 'skid alt acc,fling and got kicked',
	['jerry_plsnoban5'] = 'skid alt acc,fling and got kicked',
	['PrisonLife_UberDrive'] = 'uber, vfly user', -- hes chilling added for vfly
	['HeyiamTheCooolest'] = 'worst hack, slimed w/ vape v4',
	['rudeeis_ab'] = 'noclipping ahhh hack', -- saint member, dont they even use the same thing
	['centipedeinmyheads'] = 'aimbot, wallbanging', -- another saint member lol
	['dannielll51'] = 'headsit rip', -- inspired, vape antiheadsit soon.
	['1267_isevil'] = 'skid, failed fling attempt',
	['1987_isevil'] = 'skid, failed fling attempt',
	['JOJI12416'] = 'known exploiter', -- kerax if u wonder
	['jbskjbg'] = 'platform stand exp',
	['BestCode_BaconThx'] = 'fling attempt, worst communist>',
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