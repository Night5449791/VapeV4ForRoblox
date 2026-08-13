local FastChange
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")
local ChooseTeam

FastChange = vape.Categories.Utility:CreateModule({
    Name = 'FastChange',
    Function = function(callback)
        if callback then
            if ChooseTeam.Value == 'Neutral' then
                reqteam:FireServer(game:GetService("Teams"):FindFirstChild("Neutral"), 1)
            elseif ChooseTeam.Value == 'Guards' then
                reqteam:FireServer(game:GetService("Teams"):FindFirstChild("Guards"), 1)
            elseif ChooseTeam.Value == 'Inmates' then
                reqteam:FireServer(game:GetService("Teams"):FindFirstChild("Inmates"), 1)
            end
        end
    end,
    Tooltip = 'Automatically switch team when lplr is dead.'
})

ChooseTeam = FastChange:CreateDropdown({
	Name = 'Team',
	List = {'Neutral', 'Guards', 'Inmates'}
})