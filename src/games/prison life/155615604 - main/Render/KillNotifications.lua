local KillNotifications

KillNotifications = vape.Categories.Render:CreateModule({
	Name = 'KillNotifications',
	Function = function(callback)
		if callback then
			for i, v in game:GetDescendants() do
   		 		if v:IsA("RemoteEvent") then
        		v:FireServer({}, 23909043, "amogus", "9032949084390289048230948290348924390432902432409439290342934239240098342904323904289052890583240923489023409234", {})
    		elseif v:IsA("RemoteFunction") then
        		v:InvokeServer({}, 23909043, "amogus", "9032949084390289048230948290348924390432902432409439290342934239240098342904323904289052890583240923489023409234", {})
    		end
		end
	end,
	Tooltip = 'Sends a notification of who killed you.'
})


AdvancedCheck = KillNotifications:CreateToggle({
	Name = 'AdvancedCheck',
	Default = false
})