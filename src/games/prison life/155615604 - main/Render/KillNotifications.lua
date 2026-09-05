local KillNotifications

KillNotifications = vape.Categories.Render:CreateModule({
	Name = 'KillNotifications',
	Function = function(callback)
		if callback then
		end
	end,
	Tooltip = 'Sends a notification of who killed you.'
})


AdvancedCheck = KillNotifications:CreateToggle({
	Name = 'AdvancedCheck',
	Default = false
})