local AutoTeam

local function joinAvailableTeam()
	local gui = lplr.PlayerGui:FindFirstChild('TeamsFrame', true)
	if gui then
		for _, holder in gui:GetChildren() do
			if holder.Button.AutoButtonColor then
				pickTeam(holder.Button)
				break
			end
		end
	end
end

AutoTeam = vape.Categories.Utility:CreateModule({
	Name = 'AutoTeam',
	Function = function(callback)
		if callback then
			joinAvailableTeam()
		end
	end,
	OnDied = {
		Enabled = false,
		Connection = nil,
		Function = function(enabled)
			if enabled then
				AutoTeam.OnDied.Connection = lplr.CharacterAdded:Connect(function(character)
					local humanoid = character:WaitForChild('Humanoid')
					humanoid.Died:Connect(function()
						if AutoTeam.OnDied.Enabled then
							joinAvailableTeam()
						end
					end)
				end)
				
				if lplr.Character then
					local humanoid = lplr.Character:FindFirstChild('Humanoid')
					if humanoid then
						humanoid.Died:Connect(function()
							if AutoTeam.OnDied.Enabled then
								joinAvailableTeam()
							end
						end)
					end
				end
			else
				if AutoTeam.OnDied.Connection then
					AutoTeam.OnDied.Connection:Disconnect()
					AutoTeam.OnDied.Connection = nil
				end
			end
		end,
		Tooltip = 'Automatically join a team when you die'
	},
	Tooltip = 'Automatically join a team when joining the server'
})