local PlayerTP
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

PlayerTP = vape.Categories.Utility:CreateModule({
	Name = 'PlayerTP',
	Function = function(callback)
		if callback then
			oldCameraSubject = gameCamera.CameraSubject
			PlayerTP:Clean(lplr.Chatted:Connect(function(message)
				if message:lower() == '.unview' then
					restoreCamera()
					return
				end

				local prefix = message:match('^%.view%s+(.+)$')
				if not prefix then
					return
				end

				prefix = prefix:match('^%s*(.-)%s*$')
				local target = findPlayer(prefix)
				if not target then
					notif('PlayerTP', 'No living player found.', 5, 'warning')
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
	Tooltip = 'Use .view <display name prefix> to spectate a player. Use .unview to restore the camera.'
})
