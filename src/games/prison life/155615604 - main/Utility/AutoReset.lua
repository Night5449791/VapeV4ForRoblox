local AutoReset
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")
local conns = {}

AutoReset = vape.Categories.Utility:CreateModule({
	Name = 'AutoReset',
	Function = function(callback)
		if callback then
			local t = lplr.Team and game:GetService("Teams"):FindFirstChild(lplr.Team.Name)
			if t then reqteam:InvokeServer(t, 1) end
		end
	end,
	Tooltip = 'Automatically switch team when lplr is dead.'
})