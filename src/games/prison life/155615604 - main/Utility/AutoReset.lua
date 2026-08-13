local AutoReset
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")
local conns = {}

AutoReset = vape.Categories.Utility:CreateModule({
	Name = 'AutoReset',
	Function = function(callback)
		if callback then
			local function bind(char)
				table.insert(conns, char:WaitForChild("Humanoid").Died:Connect(function()
					local t = lplr.Team and game:GetService("Teams"):FindFirstChild(lplr.Team.Name)
					if t then reqteam:InvokeServer(t, 1) end
				end))
			end
			table.insert(conns, lplr.CharacterAdded:Connect(bind))
			if lplr.Character then bind(lplr.Character) end
		else
			for _, c in ipairs(conns) do c:Disconnect() end
			table.clear(conns)
		end
	end,
	Tooltip = 'Automatically switch team when lplr is dead.'
})