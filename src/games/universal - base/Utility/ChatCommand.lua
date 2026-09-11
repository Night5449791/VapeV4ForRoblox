local ChatCommand
local cPlayerTP
local cPlayerView
local cRejoin
local cServerHop
local cReloadVape
local cChangeTeam
local cWhitelist
local cAddSkid
local oldCameraSubject
local viewDeathConnection

local skidCommands = {
	addskid = true,
	 skidcmd = true,
	rmskid = true,
	delskid = true
}

local function trim(value)
	return (value or ''):match('^%s*(.-)%s*$')
end

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
			local username = player and player.Name
			local displayName = player and player.DisplayName
			if username and username:lower():sub(1, #lowered) == lowered
				or displayName and displayName:lower():sub(1, #lowered) == lowered then
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

local function handleWhitelistCommand(command, prefix)
	local isUnwhitelist = command == 'unwl' or command == 'unwhitelist'
	local target = findPlayer(prefix)
	local player = getPlayer(target)
	if not player and isUnwhitelist then
		player = playersService:FindFirstChild(prefix)
	end
	if not player then
		notif('Whitelist', 'No living player found.', 5, 'warning')
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
end

local function handleSkidCommand(command, args)
	local cheaters = vape.Libraries.cheaters
	if not cheaters or not vape.Libraries.addCheater then
		notif('CheaterDetector', 'CheaterDetector is unavailable.', 5, 'warning')
		return
	end

	args = trim(args)
	if command == 'skidcmd' then
		local displayPattern, reason = args:match('^(%S+)%s+(.+)$')
		if not displayPattern or not reason then
			notif('CheaterDetector', 'Usage: .skidcmd <displayname pattern> <reason>', 5, 'warning')
			return
		end

		local success, matched = pcall(function()
			local count = 0
			local loweredPattern = displayPattern:lower()
			for _, player in playersService:GetPlayers() do
				if player.DisplayName:lower():find(loweredPattern) then
					vape.Libraries.addCheater(player.Name, reason)
					count += 1
				end
			end
			return count
		end)
		if not success then
			notif('CheaterDetector', 'Invalid displayname pattern.', 5, 'warning')
		elseif matched == 0 then
			notif('CheaterDetector', 'No display names matched.', 5, 'warning')
		else
			notif('CheaterDetector', tostring(matched)..' player(s) added to the cheater list.', 5)
		end
	elseif command == 'addskid' then
		local username, reason = args:match('^(%S+)%s*(.-)$')
		if not username or username == '' then
			notif('CheaterDetector', 'Usage: .addskid <username> [reason]', 5, 'warning')
			return
		end

		vape.Libraries.addCheater(username, reason ~= '' and reason or 'manual')
		notif('CheaterDetector', username..' added to the cheater list.', 5)
	elseif command == 'rmskid' then
		if vape.Libraries.removeCheater(args) then
			notif('CheaterDetector', args..' removed from the cheater list.', 5)
		else
			notif('CheaterDetector', 'No cheater found for '..(args ~= '' and args or 'the provided username')..'.', 5, 'warning')
		end
	elseif args == '' then
		vape.Libraries.clearCheaters()
		notif('CheaterDetector', 'Cheater list cleared.', 5)
	elseif vape.Libraries.removeCheater(args) then
		notif('CheaterDetector', args..' removed from the cheater list.', 5)
	else
		notif('CheaterDetector', 'No cheater found for '..args..'.', 5, 'warning')
	end
end

ChatCommand = vape.Categories.Utility:CreateModule({
	Name = 'ChatCommand',
	Function = function(callback)
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
			ChatCommand:Clean(lplr.Chatted:Connect(function(message)
				local loweredMessage = message:lower():match('^%s*(.-)%s*$')
				local command, prefix = message:match('^%.(%S+)%s*(.*)$')
				local loweredCommand = command and command:lower()

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

				if loweredCommand and skidCommands[loweredCommand] and cAddSkid.Enabled then
					handleSkidCommand(loweredCommand, prefix)
					return
				end

				if loweredCommand and whitelistCommands[loweredCommand] and cWhitelist.Enabled then
					handleWhitelistCommand(loweredCommand, trim(prefix))
					return
				end

				if loweredMessage == '.unview' then
					restoreCamera()
					return
				end

				if loweredCommand == 'tp' and cPlayerTP.Enabled then
					prefix = trim(prefix)
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

				if loweredCommand ~= 'view' or not cPlayerView.Enabled then
					return
				end

				if not prefix then
					return
				end

				prefix = trim(prefix)
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

cAddSkid = ChatCommand:CreateToggle({
	Name = 'AddSkid',
	Default = true
})