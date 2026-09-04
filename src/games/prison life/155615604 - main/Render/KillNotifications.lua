local KillNotifications

local function getPlayerName(player)
	if typeof(player) == 'Instance' and player:IsA('Player') then
		return player.Name
	end

	return type(player) == 'string' and player or nil
end

KillNotifications = vape.Categories.Render:CreateModule({
	Name = 'KillNotifications',
	Function = function(callback)
		if callback then
			KillNotifications:Clean(vapeEvents.PlayerKill.Event:Connect(function(killer, victim)
				local killerName = getPlayerName(killer)
				local victimName = getPlayerName(victim)
				if victimName == lplr.Name and killerName and killerName ~= lplr.Name then
					notif('KillNotifications', killerName..' killed you!', 5)
				end
			end))
		end
	end,
	Tooltip = 'Sends a notification of who killed you.'
})