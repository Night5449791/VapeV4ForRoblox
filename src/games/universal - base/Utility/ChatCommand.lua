local ChatCommand
local options = {}
local oldCameraSubject, viewDeathConnection
local teamsService = game:GetService('Teams')

local function clearViewDeathConnection()
	if viewDeathConnection then
		viewDeathConnection:Disconnect()
		viewDeathConnection = nil
	end
end

local function restoreCamera()
	clearViewDeathConnection()
	local character = lplr.Character
	local cameraSubject = character and character:FindFirstChildOfClass('Humanoid')
		or (entitylib.character and entitylib.character.Humanoid)
	if cameraSubject then
		gameCamera.CameraSubject = cameraSubject
		gameCamera.CameraType = Enum.CameraType.Custom
	end
	oldCameraSubject = nil
end

local function findPlayer(prefix, includeDead)
	prefix = prefix and prefix:match('^%s*(.-)%s*$')
	if not prefix or prefix == '' then
		return nil
	end

	local lowered = prefix:lower()
	for _, entity in entitylib.List do
		if entity and entity.Humanoid and (includeDead or entity.Humanoid.Health > 0) then
			local player = entity.Player or entity
			local displayName = player and player.DisplayName
			if displayName and displayName:lower():sub(1, #lowered) == lowered then
				return entity
			end
		end
	end

	return nil
end

local function resolvePlayer(prefix, allowLeft)
	prefix = prefix and prefix:match('^%s*(.-)%s*$')
	local target = findPlayer(prefix, true)
	if target then
		return target.Player
	end

	if allowLeft then
		return playersService:FindFirstChild(prefix)
	end
end

local function syncKickTarget(player, add)
	local kickModule = vape.Modules.KickExploit
	local kickList = kickModule and kickModule.Options['Targets']
	if not kickList then return end

	if add ~= (table.find(kickList.List, player.Name) ~= nil) then
		kickList:ChangeValue(player.Name)
	end
end

local function enableKickModule(mode, text)
	local kickModule = vape.Modules.KickExploit
	kickModule.Options['Mode']:SetValue(mode)
	if not kickModule.Enabled then
		kickModule:Toggle()
	end
	notif('KickExploit', text, 5)
end

local function handleTeam(args)
	if not options.ChangeTeam.Enabled then return end

	local teamCommand = args and args:match('^%S+$')
	local teamName = teamCommand == 'g' and 'Guards'
		or teamCommand == 'i' and 'Inmates'
		or teamCommand == 'guards' and 'Guards'
		or teamCommand == 'inmates' and 'Inmates'
	if not teamName then return end

	task.spawn(function()
		local remotes = replicatedStorage:FindFirstChild('Remotes')
		local requestTeamChange = remotes and remotes:FindFirstChild('RequestTeamChange')
		local neutral = teamsService:FindFirstChild('Neutral')
		local targetTeam = teamsService:FindFirstChild(teamName)
		if not targetTeam then return end

		if lplr.Team ~= neutral then
			if requestTeamChange and neutral then
				requestTeamChange:InvokeServer(neutral, 1)
			end
			task.wait(1.5)
		end

		local clicked
		local gui = lplr.PlayerGui:FindFirstChild('TeamsFrame', true)
		if gui then
			for _, holder in gui:GetChildren() do
				local button = holder:FindFirstChild('Button')
				if button and button.AutoButtonColor then
					local text = (holder.Name..' '..button.Text):lower()
					for _, label in holder:GetDescendants() do
						if label:IsA('TextLabel') or label:IsA('TextButton') then
							text = text..' '..label.Text:lower()
						end
					end
					if text:find(teamName:lower(), 1, true) then
						firesignal(button.MouseButton1Click)
						clicked = true
						break
					end
				end
			end
		end

		if not clicked and requestTeamChange then
			requestTeamChange:InvokeServer(targetTeam, 1)
		end
	end)
end

local function handleReload()
	if not options.ReloadVape.Enabled then return end

	delfile('newvape/main.lua')
	delfolder('newvape/libraries')
	delfolder('newvape/games')
	loadstring(game:HttpGet('https://raw.githubusercontent.com/Night5449791/VapeV4ForRoblox/main/NewMainScript.lua', true))()
end

local function handleHop()
	if options.ServerHop.Enabled then
		serverHop(nil, 'Descending')
	end
end

local function handleRejoin()
	if not options.Rejoin.Enabled then return end

	if playersService.NumPlayers > 1 then
		teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
	else
		teleportService:Teleport(game.PlaceId)
	end
end

local function handleWhitelist(args, un)
	if not options.Whitelist.Enabled then return end

	local player = resolvePlayer(args, un)
	if not player then
		notif('Whitelist', 'No player found.', 5, 'warning')
		return
	end

	local friends = vape.Categories.Friends
	if un == (table.find(friends.ListEnabled, player.Name) ~= nil) then
		friends:ChangeValue(player.Name)
	end
	notif('Whitelist', player.DisplayName..' has been '..(un and 'unwhitelisted.' or 'whitelisted.'), 5)
end

local function handleUnwhitelist(args)
	handleWhitelist(args, true)
end

local function handleTargets(args, un)
	if not options.Blacklist.Enabled then return end

	local player = resolvePlayer(args, un)
	if not player then
		notif('Blacklist', 'No player found.', 5, 'warning')
		return
	end

	local targets = vape.Categories.Targets
	if un == (table.find(targets.ListEnabled, player.Name) ~= nil) then
		targets:ChangeValue(player.Name)
	end
	syncKickTarget(player, not un)
	notif('Blacklist', player.DisplayName..' has been '..(un and 'unblacklisted.' or 'blacklisted.'), 5)
end

local function handleUntarget(args)
	handleTargets(args, true)
end

local function handleKick(args)
	if not options.Kick.Enabled then return end

	local kickModule = vape.Modules.KickExploit
	if not kickModule then
		notif('ChatCommand', 'KickExploit is not available in this game.', 5, 'warning')
		return
	end

	local name = args and (args:match('^target%s+(.+)$') or args):match('^%s*(.-)%s*$') or ''
	local lowerName = name:lower()
	if lowerName == 'all' then
		enableKickModule('All', 'Flinging all players.')
	elseif lowerName == 'none' then
		if kickModule.Enabled then
			kickModule:Toggle()
		end
		notif('KickExploit', 'Kick disabled.', 5)
	elseif name == '' then
		notif('KickExploit', 'Usage: .kick <plr>, .kick all or .kick none', 5, 'warning')
	else
		local player = resolvePlayer(name, true)
		if not player then
			notif('KickExploit', 'No player found.', 5, 'warning')
			return
		end

		syncKickTarget(player, true)
		local targets = vape.Categories.Targets
		if not table.find(targets.ListEnabled, player.Name) then
			targets:ChangeValue(player.Name)
		end
		enableKickModule('Individual', 'Flinging '..player.Name..'.')
	end
end

local function handleTP(args)
	if not options.PlayerTP.Enabled then return end

	local target = findPlayer(args)
	if not target or not target.RootPart then
		notif('ChatCommand', 'No living player found.', 5, 'warning')
		return
	end

	if entitylib.character and entitylib.character.RootPart then
		entitylib.character.RootPart.CFrame = target.RootPart.CFrame + Vector3.new(0, 2, 0)
	end
end

local function handleView(args)
	if not options.PlayerView.Enabled then return end

	local target = findPlayer(args)
	if not target then
		notif('ChatCommand', 'No living player found.', 5, 'warning')
		return
	end

	if target.Humanoid then
		clearViewDeathConnection()
		gameCamera.CameraSubject = target.Humanoid
		viewDeathConnection = target.Humanoid.Died:Connect(function()
			viewDeathConnection = nil
			local character = lplr.Character
			local localHumanoid = character and character:FindFirstChildOfClass('Humanoid')
				or (entitylib.character and entitylib.character.Humanoid)
			if localHumanoid then
				gameCamera.CameraSubject = localHumanoid
				gameCamera.CameraType = Enum.CameraType.Custom
			end
		end)
		vape:Clean(viewDeathConnection)
	end
end

local handlers = {
	team = handleTeam,
	reload = handleReload,
	hop = handleHop,
	serverhop = handleHop,
	rj = handleRejoin,
	rejoin = handleRejoin,
	wl = handleWhitelist,
	whitelist = handleWhitelist,
	unwl = handleUnwhitelist,
	unwhitelist = handleUnwhitelist,
	target = handleTargets,
	blacklist = handleTargets,
	untarget = handleUntarget,
	unblacklist = handleUntarget,
	kick = handleKick,
	kickmethod = handleKick,
	unview = restoreCamera,
	tp = handleTP,
	view = handleView,
}

ChatCommand = vape.Categories.Utility:CreateModule({
	Name = 'ChatCommand',
	Function = function(callback)
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
			ChatCommand:Clean(lplr.Chatted:Connect(function(message)
				if message:sub(1, 1) ~= '.' then
					return
				end

				local command, args = message:match('^%.(%S+)%s+(.+)$')
				local handler = handlers[command and command:lower() or message:sub(2):lower()]
				if handler then
					handler(args)
				end
			end))
		else
			restoreCamera()
		end
	end
})

local toggles = {
	{Name = 'PlayerTP', Tooltip = '.tp <plr>'},
	{Name = 'PlayerView', Tooltip = '.view <plr>\n.unview', Function = function(callback)
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
		else
			restoreCamera()
		end
	end},
	{Name = 'Rejoin', Tooltip = '.rj\n.rejoin'},
	{Name = 'ServerHop', Tooltip = '.hop\n.serverhop'},
	{Name = 'ReloadVape', Tooltip = '.reload'},
	{Name = 'ChangeTeam', Tooltip = '.team <g/i>'},
	{Name = 'Whitelist', Tooltip = '.wl/.whitelist <plr>\n.unwl/.unwhitelist <plr>'},
	{Name = 'Blacklist', Tooltip = '.target/.blacklist <plr>\n.untarget/.unblacklist <plr>'},
	{Name = 'Kick', Tooltip = '.kick/.kickmethod <plr>\n.kick/.kickmethod all\n.kick/.kickmethod none'},
}

for _, toggle in toggles do
	options[toggle.Name] = ChatCommand:CreateToggle({
		Name = toggle.Name,
		Tooltip = toggle.Tooltip,
		Default = true,
		Function = toggle.Function
	})
end