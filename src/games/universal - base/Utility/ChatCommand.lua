local ChatCommand
local cPlayerTP, cPlayerView, cRejoin, cServerHop, cReloadVape, cChangeTeam, cWhitelist, cTarget, cFollow
local oldCameraSubject, viewDeathConnection, playerLeftConnection

local function clearViewDeathConnection()
	if viewDeathConnection then
		viewDeathConnection:Disconnect()
		viewDeathConnection = nil
	end
	if playerLeftConnection then
		playerLeftConnection:Disconnect()
		playerLeftConnection = nil
	end
end

local function restoreCamera()
	clearViewDeathConnection()
	local cameraSubject = lplr.Character and lplr.Character:FindFirstChildOfClass('Humanoid')
		or (entitylib and entitylib.character and entitylib.character.Humanoid)
	if cameraSubject then
		gameCamera.CameraSubject = cameraSubject
		gameCamera.CameraType = Enum.CameraType.Custom
	end
	oldCameraSubject = nil
end

local function findPlayer(prefix)
	if not prefix or prefix == '' then
		return nil
	end

	local lowered = prefix:lower()
	local entities = entitylib and entitylib.List or {}
	for _, entity in ipairs(entities) do
		if entity and entity.Humanoid and entity.Humanoid.Health > 0 then
			local player = entity.Player or entity
			local displayName = player and player.DisplayName
			if displayName and displayName:lower():sub(1, #lowered) == lowered then
				return entity
			end
		end
	end

	return nil
end

local whitelistCommands = {
	 wl = true,
	 whitelist = true,
	 unwl = true,
	 unwhitelist = true
}

local targetCommands = {
	target = true,
	blacklist = true
}

local followCommands = {
	follow = true,
	unfollow = true
}

local waypointCommands = {
	waypoint = true,
	savetp = true,
	save = true,
	wtp = true
}



ChatCommand = vape.Categories.Utility:CreateModule({
	Name = 'ChatCommand',
	Function = function(callback)
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
			local chatConnection = lplr.Chatted:Connect(function(message)
				if message:sub(1, 1) ~= '.' then return end

				local command, prefix = message:match('^%.(%S+)%s*(.*)$')
				local loweredCommand = command and command:lower()
				prefix = prefix and prefix:match('^%s*(.-)%s*$') or ''
				
				if loweredCommand == 'team' and cChangeTeam.Enabled then
					local teamCommand = prefix:lower()
					if teamCommand ~= '' then
						local teamName = teamCommand == 'g' and 'Guards' or
									   teamCommand == 'i' and 'Inmates' or
									   teamCommand == 'guards' and 'Guards' or
									   teamCommand == 'inmates' and 'Inmates'
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
							end
						end
					end
				end
				
				if loweredCommand == 'reload' and prefix == '' and cReloadVape.Enabled then
					delfile('newvape/main.lua')
					delfolder('newvape/libraries')
					delfolder('newvape/games')
					loadstring(game:HttpGet('https://raw.githubusercontent.com/Night5449791/VapeV4ForRoblox/main/NewMainScript.lua', true))()
				elseif (loweredCommand == 'serverhop' or loweredCommand == 'hop') and prefix == '' and cServerHop.Enabled then
					serverHop(nil, 'Descending')
				elseif (loweredCommand == 'rj' or loweredCommand == 'rejoin') and prefix == '' and cRejoin.Enabled then
					teleportService:Teleport(game.PlaceId, game.JobId)
				end
				
				if loweredCommand and whitelistCommands[loweredCommand] and cWhitelist.Enabled then
					local isUnwhitelist = loweredCommand == 'unwl' or loweredCommand == 'unwhitelist'
					local target = findPlayer(prefix)
					local player = target and target.Player or (isUnwhitelist and playersService:FindFirstChild(prefix))
					
					if player then
						local friends = vape.Categories.Friends
						local isWhitelisted = table.find(friends.ListEnabled, player.Name) ~= nil
						
						if isUnwhitelist then
							if isWhitelisted then friends:ChangeValue(player.Name) end
							notif('Whitelist', player.DisplayName..' has been unwhitelisted.', 5)
						else
							if not isWhitelisted then friends:ChangeValue(player.Name) end
							notif('Whitelist', player.DisplayName..' has been whitelisted.', 5)
						end
					else
						notif('Whitelist', 'No living player found.', 5, 'warning')
					end
				elseif loweredCommand and targetCommands[loweredCommand] and cTarget.Enabled then
					local isBlacklist = loweredCommand == 'blacklist'
					local target = findPlayer(prefix)
					local player = target and target.Player or (isBlacklist and playersService:FindFirstChild(prefix))
					
					if player then
						local targets = vape.Categories.Targets
						local isTargeted = table.find(targets.ListEnabled, player.Name) ~= nil
						
						if isBlacklist then
							if isTargeted then targets:ChangeValue(player.Name) end
							notif('Target', player.DisplayName..' has been blacklisted.', 5)
						else
							if not isTargeted then targets:ChangeValue(player.Name) end
							notif('Target', player.DisplayName..' has been targeted.', 5)
						end
					else
						notif('Target', 'No living player found.', 5, 'warning')
					end
				end
				
				if loweredCommand == 'unview' then
					restoreCamera()
				elseif loweredCommand == 'tp' and cPlayerTP.Enabled then
					local target = findPlayer(prefix)
					if target and target.RootPart and entitylib and entitylib.character and entitylib.character.RootPart then
						entitylib.character.RootPart.CFrame = target.RootPart.CFrame + Vector3.new(0, 2, 0)
					else
						notif('ChatCommand', 'No living player found.', 5, 'warning')
					end
				elseif loweredCommand == 'view' and cPlayerView.Enabled and prefix then
					local target = findPlayer(prefix)
					if target and target.Humanoid then
						clearViewDeathConnection()
						gameCamera.CameraSubject = target.Humanoid
						
						viewDeathConnection = target.Humanoid.Died:Connect(function()
							viewDeathConnection = nil
						end)
						
						playerLeftConnection = target.Player:GetPropertyChangedSignal("Parent"):Connect(function()
							if not target.Player or target.Player.Parent == nil then
								restoreCamera()
							end
						end)
						
						vape:Clean(viewDeathConnection, playerLeftConnection)
					else
						notif('ChatCommand', 'No living player found.', 5, 'warning')
					end
				end
				
				if loweredCommand and followCommands[loweredCommand] and cFollow.Enabled then
					local isUnfollow = loweredCommand == 'unfollow'
					local target = findPlayer(prefix)
					local player = target and target.Player or (isUnfollow and playersService:FindFirstChild(prefix))
					
					if player then
						local follow = vape.Categories.Follow
						local isFollowing = table.find(follow.ListEnabled, player.Name) ~= nil
						
						if isUnfollow then
							if isFollowing then
								follow:ChangeValue(player.Name)
							end
							notif('Follow', player.DisplayName..' has been unfollowed.', 5)
						else
							if not isFollowing then
								follow:ChangeValue(player.Name)
							end
							notif('Follow', player.DisplayName..' is now being followed.', 5)
						end
					else
						notif('Follow', 'No living player found.', 5, 'warning')
					end
				elseif loweredCommand and waypointCommands[loweredCommand] and cWaypoint.Enabled then
					local waypointName = prefix:match('^%s*(.-)%s*$')
					
					if loweredCommand == 'waypoint' and waypointName ~= '' then
						-- Save waypoint with custom name
						local waypoint = {
							Name = waypointName,
							CFrame = lplr.Character and lplr.Character:FindFirstChild('HumanoidRootPart') and lplr.Character.HumanoidRootPart.CFrame or nil,
							Time = tick()
						}
						
						if waypoint.CFrame then
							if not shared.Waypoints then shared.Waypoints = {} end
							table.insert(shared.Waypoints, waypoint)
							notif('Waypoint', 'Waypoint "'..waypointName..'" saved successfully.', 5)
						else
							notif('Waypoint', 'Failed to save waypoint - no valid character position.', 5, 'warning')
						end
					elseif loweredCommand == 'savetp' or loweredCommand == 'save' then
						-- Save waypoint with default name
						local waypoint = {
							Name = 'Waypoint '..(#(shared.Waypoints or {}) + 1),
							CFrame = lplr.Character and lplr.Character:FindFirstChild('HumanoidRootPart') and lplr.Character.HumanoidRootPart.CFrame or nil,
							Time = tick()
						}
						
						if waypoint.CFrame then
							if not shared.Waypoints then shared.Waypoints = {} end
							table.insert(shared.Waypoints, waypoint)
							notif('Waypoint', 'Waypoint saved successfully.', 5)
						else
							notif('Waypoint', 'Failed to save waypoint - no valid character position.', 5, 'warning')
						end
					elseif loweredCommand == 'wtp' and waypointName ~= '' then
						-- Teleport to waypoint
						if shared.Waypoints then
							for _, waypoint in ipairs(shared.Waypoints) do
								if waypoint.Name:lower() == waypointName:lower() and waypoint.CFrame then
									if entitylib and entitylib.character and entitylib.character:FindFirstChild('HumanoidRootPart') then
										entitylib.character.HumanoidRootPart.CFrame = waypoint.CFrame
										notif('Waypoint', 'Teleported to "'..waypoint.Name..'"', 5)
									else
										notif('Waypoint', 'Failed to teleport - no valid character.', 5, 'warning')
									end
									return
								end
							end
							notif('Waypoint', 'Waypoint "'..waypointName..'" not found.', 5, 'warning')
						else
							notif('Waypoint', 'No waypoints saved.', 5, 'warning')
						end
					end
				end
			end)
			
			ChatCommand:Clean(chatConnection)
		else
			restoreCamera()
		end
	end
})

cPlayerTP = ChatCommand:CreateToggle({
	Name = 'PlayerTP',
	Default = true,
	Tooltip = '.tp <player>\nTeleport to player'
})

cPlayerView = ChatCommand:CreateToggle({
	Name = 'PlayerView',
	Default = true,
	Function = function(callback)
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
		else
			restoreCamera()
		end
	end,
	Tooltip = '.view <player>\nView player (continues viewing even if target dies)'
})

cRejoin = ChatCommand:CreateToggle({
	Name = 'Rejoin',
	Default = true,
	Tooltip = '.rj/.rejoin\nRejoin current server'
})

cServerHop = ChatCommand:CreateToggle({
	Name = 'ServerHop',
	Default = true,
	Tooltip = '.serverhop/.hop\nFind new server'
})

cReloadVape = ChatCommand:CreateToggle({
	Name = 'ReloadVape',
	Default = true,
	Tooltip = '.reload\nRestart Vape'
})

cChangeTeam = ChatCommand:CreateToggle({
	Name = 'ChangeTeam',
	Default = true,
	Tooltip = '.team <g/i/guards/inmates>\nChange teams'
})

cWhitelist = ChatCommand:CreateToggle({
	Name = 'Whitelist',
	Default = true,
	Tooltip = '.wl/.whitelist/.unwl/.unwhitelist\nManage friend list'
})

cTarget = ChatCommand:CreateToggle({
	Name = 'Target',
	Default = true,
	Tooltip = '.target/.blacklist\nManage target list'
})

cFollow = ChatCommand:CreateToggle({
	Name = 'Follow',
	Default = true,
	Tooltip = '.follow/.unfollow\nManage follow list'
})

cWaypoint = ChatCommand:CreateToggle({
	Name = 'Waypoint',
	Default = true,
	Tooltip = '.waypoint <name>\n.savetp/.save\n.wtp <waypoint>\nManage waypoints'
})