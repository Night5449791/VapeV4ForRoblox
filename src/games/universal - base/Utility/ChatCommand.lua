local ChatCommand
local cPlayerTP
local cPlayerView
local cRejoin
local cServerHop
local cReloadVape
local cChangeTeam
local cWhitelist
local cFollow
local viewDeathConnection
local following, followThread
local replicatedStorage = game:GetService('ReplicatedStorage')
local teamsService = game:GetService('Teams')
local pathfindingService = game:GetService('PathfindingService')

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
end

local function trim(s)
	return s and s:match('^%s*(.-)%s*$')
end

local function findPlayer(prefix, includeDead)
	if not prefix or prefix == '' then
		return nil
	end

	local lowered = prefix:lower()
	local length = #lowered
	for _, entity in entitylib.List do
		if entity and entity.Humanoid and (includeDead or entity.Humanoid.Health > 0) then
			local player = entity.Player or entity
			local displayName = player and player.DisplayName
			if displayName and displayName:lower():sub(1, length) == lowered then
				return entity
			end
		end
	end

	return nil
end

local function stopFollow()
	following = false
	if followThread then
		task.cancel(followThread)
		followThread = nil
	end
	local character = lplr.Character
	local humanoid = character and character:FindFirstChildOfClass('Humanoid')
	local root = character and character:FindFirstChild('HumanoidRootPart')
	if humanoid and root then
		humanoid:MoveTo(root.Position)
	end
end

local function startFollow(entity)
	stopFollow()
	following = true
	local targetPlayer = entity.Player or entity
	followThread = task.spawn(function()
		local path = pathfindingService:CreatePath({
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanStep = 2,
			AgentWidth = 2,
			CanWalk = true
		})
		while following do
			local targetChar = targetPlayer.Character
			local targetRoot = targetChar and targetChar:FindFirstChild('HumanoidRootPart')
			local character = lplr.Character
			local humanoid = character and character:FindFirstChildOfClass('Humanoid')
			local root = character and character:FindFirstChild('HumanoidRootPart')
			if not (targetRoot and humanoid and root and humanoid.Health > 0) then
				break
			end

			if (root.Position - targetRoot.Position).Magnitude > 6 then
				local suc = pcall(function()
					path:ComputeAsync(root.Position, targetRoot.Position)
				end)
				if suc and path.Status == Enum.PathStatus.Success then
					for _, waypoint in ipairs(path:GetWaypoints()) do
						if not following then
							break
						end
						if waypoint.Action == Enum.PathWaypointAction.Jump then
							humanoid.Jump = true
						end
						humanoid:MoveTo(waypoint.Position)
						local timeout = os.clock() + 3
						repeat
							task.wait(0.1)
						until not following or not root.Parent or (waypoint.Position - root.Position).Magnitude <= 4 or os.clock() > timeout
					end
				else
					humanoid:MoveTo(targetRoot.Position)
				end
			end

			task.wait(0.25)
		end

		following = false
		followThread = nil
	end)
end

local whitelistCommands = {
	wl = true,
	whitelist = true,
	unwl = true,
	unwhitelist = true
}

local teamAliases = {
	g = 'Guards',
	guards = 'Guards',
	i = 'Inmates',
	inmates = 'Inmates'
}

ChatCommand = vape.Categories.Utility:CreateModule({
	Name = 'ChatCommand',
	Function = function(callback)
		if callback then
			ChatCommand:Clean(lplr.Chatted:Connect(function(message)
				if message:sub(1, 1) ~= '.' then
					return
				end

				local loweredMessage = message:lower()
				local command, prefix = message:match('^%.(%S+)%s+(.+)$')
				local loweredCommand = command and command:lower()
				local teamCommand = loweredMessage:match('^%.team%s+(%S+)$')
				if cChangeTeam.EnablcChangeTeam.Enabled and loweredMessage:match('^%.team%s+(%S+)$')
				local teamName = teamCommand and teamAliases[teamCommand]
				if teamName then
					local remotes = replicatedStorage:FindFirstChild('Remotes')
					local requestTeamChange = remotes and remotes:FindFirstChild('RequestTeamChange')
					local neutral = teamsService:FindFirstChild('Neutral')
					local targetTeam = teamsService:FindFirstChild(teamName)
					if requestTeamChange and neutral and targetTeam then
						if lplr.Team ~= neutral then
							requestTeamChange:InvokeServer(neutral, 1)
							task.wait(1)
						end
						requestTeamChange:InvokeServer(targetTeam, 1)
				elseif loweredMessage == '.reload' and cReloadVape.Enabled then
					delfile('newvape/main.lua')
					delfolder('newvape/libraries')
					delfolder('newvape/games')
					loadstring(game:HttpGet('https://raw.githubusercontent.com/Night5449791/VapeV4ForRoblox/main/NewMainScript.lua', true))()
				elseif (loweredMessage == '.serverhop' or loweredMessage == '.hop') and cServerHop.Enabled then
					serverHop(nil, 'Descending')
				elseif (loweredMessage == '.rj' or loweredMessage == '.rejoin') and cRejoin.Enabled then
					if playersService.NumPlayers > 1 then
						teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
					else
						teleportService:Teleport(game.PlaceId)
					end
				elseif loweredCommand and whitelistCommands[loweredCommand] and cWhitelist.Enabled then
					local isUnwhitelist = loweredCommand == 'unwl' or loweredCommand == 'unwhitelist'
					local name = trim(prefix)
					local target = findPlayer(name, true)
					local player = target and target.Player
					if not player and isUnwhitelist then
						player = playersService:FindFirstChild(name)
					end
					if not player then
						notif('Whitelist', 'No player found.', 5, 'warning')
						return
					end

					local friends = vape.Categories.Friends
					local isWhitelisted = table.find(friends.ListEnabled, player.Name) ~= nil
					if isUnwhitelist then
						if isWhitelisted then
							friends:ChangeValue(player.Name)
						end
						notif('Whitelist', player.DisplayName..' has been unwhitelisted.', 5)
						return
					end

					if not isWhitelisted then
						friends:ChangeValue(player.Name)
					end
					notif('Whitelist', player.DisplayName..' has been whitelisted.', 5)
				elseif loweredMessage == '.unview' then
					restoreCamera()
				elseif loweredMessage == '.unfollow' then
					if following then
						stopFollow()
						notif('ChatCommand', 'Stopped following.', 5)
					end
				elseif loweredCommand == 'follow' and cFollow.Enabled then
					local target = findPlayer(trim(prefix))
					if not target or not target.RootPart then
						notif('ChatCommand', 'No living player found.', 5, 'warning')
						return
					end

					startFollow(target)
					local player = target.Player or target
					notif('ChatCommand', 'Now following '..player.DisplayName..'.', 5)
				elseif loweredCommand == 'tp' and cPlayerTP.Enabled then
					local target = findPlayer(trim(prefix))
					if not target or not target.RootPart then
						notif('ChatCommand', 'No living player found.', 5, 'warning')
						return
					end

					if entitylib.character and entitylib.character.RootPart then
						entitylib.character.RootPart.CFrame = target.RootPart.CFrame + Vector3.new(0, 2, 0)
					end
				elseif loweredCommand == 'view' and cPlayerView.Enabled then
					local target = findPlayer(trim(prefix))
					if not target then
						notif('ChatCommand', 'No living player found.', 5, 'warning')
						return
					end

					if target.Humanoid then
						clearViewDeathConnection()
						gameCamera.CameraSubject = target.Humanoid
						viewDeathConnection = target.Humanoid.Died:Connect(restoreCamera)
						vape:Clean(viewDeathConnection)
					end
				end
			end))
		else
			stopFollow()
			restoreCamera()
		end
	end
})

cPlayerTP = ChatCommand:CreateToggle({
	Name = 'PlayerTP',
	Default = true,
})

cPlayerView = ChatCommand:CreateToggle({
	Name = 'PlayerView',
	Default = true,
	Function = function(callback)
		if not callback then
			restoreCamera()
		end
	end
})

cRejoin = ChatCommand:CreateToggle({
	Name = 'Rejoin',
	Default = true
})

cServerHop = ChatCommand:CreateToggle({
	Name = 'ServerHop',
	Default = true
})

cReloadVape = ChatCommand:CreateToggle({
	Name = 'ReloadVape',
	Default = true
})

cChangeTeam = ChatCommand:CreateToggle({
	Name = 'ChangeTeam',
	Default = true
})

cWhitelist = ChatCommand:CreateToggle({
	Name = 'Whitelist',
	Default = true
})

cFollow = ChatCommand:CreateToggle({
	Name = 'Follow',
	Default = true,
	Function = function(callback)
		if not callback then
			stopFollow()
		end
	end
})