local ChatCommand
local PlayerTP
local PlayerView
local Rejoin
local ServerHop
local ReloadVape
local oldCameraSubject

local function restoreCamera()
	if oldCameraSubject and gameCamera.CameraSubject ~= oldCameraSubject then
		gameCamera.CameraSubject = oldCameraSubject
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

ChatCommand = vape.Categories.Utility:CreateModule({
	Name = 'ChatCommand',
	Function = function(callback)
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
			ChatCommand:Clean(lplr.Chatted:Connect(function(message)
				local loweredMessage = message:lower()
				local diedTPState = loweredMessage:match('^%.diedtp%s+(on|off)$')
				if diedTPState or loweredMessage == '.diedtp' then
					local DiedTP = vape.Modules.DiedTP
					local enabled = diedTPState and diedTPState == 'on' or (DiedTP and not DiedTP.Enabled)
					if DiedTP and DiedTP.Enabled ~= enabled then
						DiedTP:Toggle()
					end
					return
				end

				if loweredMessage == '.reload' and ReloadVape.Enabled then
					ReloadVape:Toggle()
					delfile('newvape/main.lua')
					delfolder('newvape/libraries')
					delfolder('newvape/games')
					delfolder('newvape/assets')
					delfolder('newvape/guis')
					loadstring(game:HttpGet('https://raw.githubusercontent.com/Night5449791/VapeV4ForRoblox/main/NewMainScript.lua', true))()
					return
				end

				if (loweredMessage == '.serverhop' or loweredMessage == '.hop') and ServerHop.Enabled then
					notif('ServerHop', 'Searching for a new server...', 5)
					ServerHop:Toggle()
					serverHop(nil, 'Descending')
					return
				end

				if (loweredMessage == '.rj' or loweredMessage == '.rejoin') and Rejoin.Enabled then
					notif('Rejoin', 'Rejoining...', 5)
					Rejoin:Toggle()

					if playersService.NumPlayers > 1 then
						teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
					else
						teleportService:Teleport(game.PlaceId)
					end
					return
				end

				if loweredMessage == '.unview' and PlayerView.Enabled then
					restoreCamera()
					return
				end

				local command, prefix = message:match('^%.(%S+)%s+(.+)$')
				if command and command:lower() == 'tp' and PlayerTP.Enabled then
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

				if not command or command:lower() ~= 'view' or not PlayerView.Enabled then
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
					gameCamera.CameraSubject = target.Humanoid
				end
			end))
		else
			restoreCamera()
		end
	end,
	Tooltip = 'Use .view <display name prefix> to spectate a player, .tp <display name prefix> to teleport to them, .unview to restore the camera, .diedtp on/off to toggle DiedTP, .rj/.rejoin to rejoin, .serverhop/.hop to hop servers, or .reload to reload Vape.'
})

PlayerTP = ChatCommand:CreateToggle({
	Name = 'PlayerTP'
})

PlayerView = ChatCommand:CreateToggle({
	Name = 'PlayerView',
	Function = function(callback)
		if not callback then
			restoreCamera()
		end
	end
})

Rejoin = ChatCommand:CreateToggle({
	Name = 'Rejoin'
})

ServerHop = ChatCommand:CreateToggle({
	Name = 'ServerHop'
})

ReloadVape = ChatCommand:CreateToggle({
	Name = 'ReloadVape'
})
