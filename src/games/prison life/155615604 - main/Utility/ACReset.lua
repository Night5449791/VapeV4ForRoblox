local ACReset
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")
local conns = {}

ACReset = vape.Categories.Utility:CreateModule({
	Name = 'ACReset',
	Function = function(callback)
		if callback then
			local t = lplr.Team and game:GetService("Teams"):FindFirstChild(lplr.Team.Name)
			lplr.Character.Humanoid.Died:Connect(function()
				if t then 
					reqteam:InvokeServer("Neutral", 1)
					reqteam:InvokeServer(t, 1)
				end
			end)
		end
	end,
	Tooltip = 'Automatically switch team when lplr is dead.'
}) 