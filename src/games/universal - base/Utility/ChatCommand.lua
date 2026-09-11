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
local localCheaterFile = 'newvape/cheater.json'

local function trim(value)
	return value:match('^%s*(.-)%s*$')
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
			local displayName = player and player.DisplayName
			if displayName and displayName:lower():sub(1, #lowered) == lowered then
				return entity
			end
		end
	end

	return nil
end

local function getPlayer(entity)
	return entity and (entity.Player or entity)
end

local function parseAddSkidCommand(body)
	for split = #body, 1, -1 do
		if body:sub(split, split):match('%s') then
			local displayName = trim(body:sub(1, split - 1))
			local reason = trim(body:sub(split + 1))
			local target = reason ~= '' and findPlayer(displayName)
			if target then
				return target, reason
			end
		end
	end

	return nil
end

local function saveLocalCheater(username, reason)
	local usernames = {}
	if isfile(localCheaterFile) then
		local success, data = pcall(function()
			return httpService:JSONDecode(readfile(localCheaterFile))
		end)
		if success and type(data) == 'table' then
			usernames = data
		end
	end

	usernames[username] = reason
	return pcall(function()
		writefile(localCheaterFile, httpService:JSONEncode(usernames))
	end)
end

local function removeLocalCheater(username)
	if not isfile(localCheaterFile) then
		return false
	end

	local success, usernames = pcall(function()
		return httpService:JSONDecode(readfile(localCheaterFile))
	end)
	if not success or type(usernames) ~= 'table' or usernames[username] == nil then
		return false
	end

	usernames[username] = nil
	return pcall(function()
		writefile(localCheaterFile, httpService:JSONEncode(usernames))
	end)
end

local function clearSkid(player)
	local username = player.Name
	vape.Libraries.cheaters[username] = nil
	whitelist.customtags[username] = nil
	tempTargets[username] = nil
end

local function addSkid(target, reason)
	local player = getPlayer(target)
	local cheaters = vape.Libraries.cheaters
	if not player or type(cheaters) ~= 'table' then
		return false
	end

	local saved = saveLocalCheater(player.Name, reason)
	if not saved then
		notif('ChatCommand', 'Could not save cheater list.', 5, 'warning')
		return false
	end

	cheaters[player.Name] = reason
	whitelist.customtags[player.Name] = {{text = 'Exploiter', color = Color3.new(1, 0, 0)}}
	tempTargets[player.Name] = true
	notif('ChatCommand', 'Added '..player.DisplayName..' to cheater list.', 5, 'alert')
	return true
end

local function removeSkid(target)
	local player = getPlayer(target)
	local cheaters = vape.Libraries.cheaters
	if not player or type(cheaters) ~= 'table' then
		return false
	end

	if not removeLocalCheater(player.Name) then
		notif('ChatCommand', player.DisplayName..' is not in the local cheater list.', 5, 'warning')
		return false
	end

	clearSkid(player)
	notif('ChatCommand', 'Removed '..player.DisplayName..' from local cheater list.', 5)
	return true
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

				local command, prefix = message:match('^%.(%S+)%s*(.*)$')
				local loweredCommand = command and command:lower()
				if loweredCommand == 'addskid' then
					local target, reason = parseAddSkidCommand(prefix)
					if target then
						addSkid(target, reason)
					else
						notif('ChatCommand', 'Usage: .addskid <displayname> <reason>', 5, 'warning')
					end
					return
				end

				if loweredCommand == 'rmskid' or loweredCommand == 'delskid' then
					local target = findPlayer(trim(prefix))
					if target then
						removeSkid(target)
					else
						notif('ChatCommand', 'Usage: .'..loweredCommand..' <displayname>', 5, 'warning')
					end
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