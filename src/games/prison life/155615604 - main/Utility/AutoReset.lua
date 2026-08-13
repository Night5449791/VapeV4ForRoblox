local AutoReset
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")

AutoReset = vape.Categories.Utility:CreateModule({
	Name = 'AutoReset',
	Function = function(callback)
		if callback then
			-- i use kill notify cuz this would be simple 
			AutoReset:Clean(vapeEvents.PlayerKill.Event:Connect(function()
				local team = lplr.Team
				reqteam:InvokeServer(
					game:GetService("Teams"):FindFirstChild(.. team ..),
					1
				)
			end))
		end
	end,
	Tooltip = 'Automatically switch team when lplr is dead.'
})