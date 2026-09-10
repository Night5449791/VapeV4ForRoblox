local ChatCommand
local cPlayerTP
local cPlayerView
local cRejoin
local cServerHop
local cReloadVape
local cChangeTeam
local cWhitelist
local oldCameraSubject
local viewDeathConnection

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

local function findPlayer(prefix)
	if not prefix or prefix == '' then
		return nil
	end

	local lowered = prefix:lower()
	for _, entity in entitylib.List do
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

local function findPlayerByUsername(prefix)
	if not prefix or prefix == '' then
		return nil
	end

	local lowered = prefix:lower()
	for _, entity in entitylib.List do
		local player = entity and entity.Player
		if entity and entity.Humanoid and entity.Humanoid.Health > 0 and player and player.Name:lower():sub(1, #lowered) == lowered then
			return entity
		end
	end

	return nil
end

ChatCommand = vape.Categories.Utility:CreateModule({
	Name = 'ChatCommand',
	Function = function(callback)
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
			ChatCommand:Clean(lplr.Chatted:Connect(function(message)
				local loweredMessage = message:lower()

				local teamCommand = loweredMessage:match('^%.team%s+(%S+)$')
				if cChangeTeam.Enabled and teamCommand then
					local teamName = teamCommand == 'g' and 'Guards'
						or teamCommand == 'i' and 'Inmates'
						or teamCommand == 'guards' and 'Guards'
						or teamCommand == 'inmates' and 'Inmates'
					if teamName then
						local remotes = game:GetService('ReplicatedStorage'):FindFirstChild('Remotes')
						local requestTeamChange = remotes and remotes:FindFirstChild('RequestTeamChange')
						local teams = game:GetService('Teams')
						local neutral = teams:FindFirstChild('Neutral')
						local targetTeam = teams:FindFirstChild(teamName)
						if requestTeamChange and neutral and targetTeam then
							if lplr.Team ~= neutral then
								requestTeamChange:InvokeServer(neutral, 1)
								task.wait(1)
							end
							requestTeamChange:InvokeServer(targetTeam, 1)
						end
					end
					return
				end

				if loweredMessage == '.reload' and cReloadVape.Enabled then
					delfile('newvape/main.lua')
					delfolder('newvape/libraries')
					delfolder('newvape/games')
					loadstring(game:HttpGet('https://raw.githubusercontent.com/Night5449791/VapeV4ForRoblox/main/NewMainScript.lua', true))()
					return
				end

				if (loweredMessage == '.serverhop' or loweredMessage == '.hop') and cServerHop.Enabled then
					notif('ServerHop', 'Searching for a new server...', 5)
					serverHop(nil, 'Descending')
					return
				end

				if (loweredMessage == '.rj' or loweredMessage == '.rejoin') and cRejoin.Enabled then
					notif('Rejoin', 'Rejoining...', 5)

					if playersService.NumPlayers > 1 then
						teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
					else
						teleportService:Teleport(game.PlaceId)
					end
					return
				end

				local command, prefix = message:match('^%.(%S+)%s+(.+)$')
				if command and (command:lower() == 'wl' or command:lower() == 'whitelist' or command:lower() == 'unwl' or command:lower() == 'unwhitelist') and cWhitelist.Enabled then
					prefix = prefix:match('^%s*(.-)%s*$')
					local target = findPlayer(prefix) or findPlayerByUsername(prefix)
					local player = target and target.Player
					if not player then
						notif('Whitelist', 'No living player found.', 5, 'warning')
						return
					end

					local friends = vape.Categories.Friends
					local isUnwhitelist = command:lower() == 'unwl' or command:lower() == 'unwhitelist'
					if isUnwhitelist then
						if table.find(friends.ListEnabled, player.Name) then
							friends:ChangeValue(player.Name)
						end
						notif('Whitelist', player.DisplayName..' has been unwhitelisted.', 5)
						return
					end

					if not table.find(friends.ListEnabled, player.Name) then
						friends:ChangeValue(player.Name)
					end
					notif('Whitelist', player.DisplayName..' has been whitelisted.', 5)
					return
				end

				if loweredMessage == '.unview' then
					restoreCamera()
					return
				end

				if command and command:lower() == 'tp' and cPlayerTP.Enabled then
					prefix = prefix:match('^%s*(.-)%s*$')
					local target = findPlayer(prefix)
					if not target or not target.RootPart then
						notif('ChatCommand', 'No living player found.', 5, 'warning')
						return
					end

					if entitylib.character and entitylib.character.RootPart then
						entitylib.character.RootPart.CFrame = target.RootPart.CFrame + Vector3.new(0, 2, 0)
					end
					return
				end

				if not command or command:lower() ~= 'view' or not cPlayerView.Enabled then
					return
				end

				if not prefix then
					return
				end

				prefix = prefix:match('^%s*(.-)%s*$')
				local target = findPlayer(prefix)
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
				end
			end))
		else
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
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
		else
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