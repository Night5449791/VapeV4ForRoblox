-- we all code for shits lol

local CheaterDetector
local cUsernames
local Users

local cUsernames = {
	['WyRaff'] = 'speedhack,teleporting', -- vc server common
	['PraiseDracc'] = 'known exploiter', -- since he is commonly in vc server
	['jerry_plsnoban7'] = 'fling and got kicked', -- cringe
	['jerry_plsnoban6'] = 'fling and got kicked',
	['jerry_plsnoban5'] = 'fling and got kicked',
	['rudeeis_ab'] = 'phase/noclip ahhh hack', -- saint member, dont they even use the same thing
	['centipedeinmyheads'] = 'aimbot, wallbanging', -- another saint member lol
	['JOJI12416'] = 'known exploiter', -- kerax if u wonder
	['BestCode_BaconThx']= 'fling attempt, ac mod',   -- ac mod in .gg/prisonlife
	['RazhulanDeveloper'] = 'fling attempt, not a  but he does that', -- respect, ac mod
	['SaintSkirr'] = 'fling attempt', -- not a big deal, why kerax just why
	['DawnPulseVoid'] = 'known exploiter',
	-- skids list
	['jbskjbg'] = 'invalid state Platform Stand exp',
	['1267_isevil'] = 'failed fling attempt',
	['1987_isevil'] = 'failed fling attempt',
	['HeyiamTheCooolest'] = 'slimed w/ vape v4',
	['Chill_baconr00'] = 'highjump', --  using vape v4 from 7granddadpgn and cant beat me XD
	['PrisonLife_UberDrive'] = 'vfly user', -- hes chilling added for vfly
	['gcfhjfjf4'] = 'highjump . aimbot',
	['dannielll51'] = 'headsit rip', -- inspired, vape antiheadsit soon.
	['Bonjour394'] = 'skid thinks hes powerful', -- hes js a jerk
	['princeofegypt'] = 'gets kicked for fling attempt', -- imagine gets kicked for script that kicks
	['bilinmez4095'] = 'invalid state Platform Stand',
	['djdjdd54321'] = 'phase/noclip into walls',
	['cnmjm222'] = 'invisible',
	['oyeuser67'] = 'speedhack',
	['BetterCallMe788'] = 'fling',
	['Avacad0731'] = 'phase/noclip',
	['C0nquerons'] = 'Platform Stand exploit',
	['goobyzoobytv'] = 'phase/noclip',
	['Joni_8824'] = 'skid thought fling + noclip = op',
	['jaycomputing'] = 'skid using selenium larps and got kicked',
	['tooodarl9'] = 'skid exploiter',
	['Henr45555455'] = 'invalid state Platform Stand',
	['Marssimo_14'] = 'invalid state Platform Stand',
	['boy_cantot2'] = 'invalid state Platform Stand',
	['killerdoy372bro'] = 'invalid animation',
	['X4AY67'] = 'skid exploiter',
	['trervoTDJ'] = 'aimbotting',
	['Pedro9Henrique2000'] = 'phase/noclip',
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