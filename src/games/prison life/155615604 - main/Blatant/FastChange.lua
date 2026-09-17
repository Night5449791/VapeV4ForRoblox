local FastChange
local ChooseTeam
local teamsService = game:GetService('Teams')

local function clickTeamButton(name)
	local deadline = os.clock() + 1
	repeat
		local gui = lplr.PlayerGui:FindFirstChild('TeamsFrame', true)
		if gui then
			for _, holder in gui:GetChildren() do
				local button = holder:FindFirstChild('Button')
				if button and button.AutoButtonColor and holder.Name:lower() == name:lower() then
					firesignal(button.MouseButton1Click)
					return true
				end
			end
		end
		task.wait(0.1)
	until os.clock() > deadline
	return false
end

FastChange = vape.Categories.Blatant:CreateModule({
    Name = 'FastChange',
    Function = function(callback)
        if callback then
            task.spawn(function()
                if not clickTeamButton(ChooseTeam.Value) then
                    local remotes = replicatedStorage:FindFirstChild('Remotes')
                    local reqteam = remotes and remotes:FindFirstChild('RequestTeamChange')
                    local targetTeam = teamsService:FindFirstChild(ChooseTeam.Value)
                    if reqteam and targetTeam then
                        reqteam:InvokeServer(targetTeam, 1)
                    else
                        notif('FastChange', 'Team button not found.', 5, 'warning')
                    end
                end

                if FastChange.Enabled then
                    FastChange:Toggle()
                end
            end)
        end
    end,
    Tooltip = 'Instantly switch team by clicking the team select GUI'
})

ChooseTeam = FastChange:CreateDropdown({
	Name = 'Team',
	List = {'Guards', 'Inmates'}
})