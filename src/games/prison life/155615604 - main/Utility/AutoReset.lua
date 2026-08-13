local AutoReset
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")
local team = lplr.Team.Name

AutoReset = vape.Categories.Utility:CreateModule({
	Name = 'AutoReset',
	Function = function(callback)
		if callback then
			-- i use kill notify cuz this would be simple 
			AutoReset:Clean(vapeEvents.PlayerKill.Event:Connect(function()
				reqteam:InvokeServer(
					game:GetService("Teams"):FindFirstChild(team),
					1
				)
			end))
		end
	end,
	Tooltip = 'Automatically switch team when lplr is dead.'
})