local FastChange
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")
local ChooseTeam

FastChange = vape.Categories.Utility:CreateModule({
    Name = 'FastChange',
    Function = function(callback)
        if callback then 
            if ChooseTeam.Value == 'Guards' then
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Neutral"), 1)
                wait(1)
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Guards"), 1)
                if lplr.Team == game:GetService("Teams"):FindFirstChild("Neutral") then
                    reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Inmates"), 1)
                end
            elseif ChooseTeam.Value == 'Inmates' then
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Neutral"), 1)
                wait(1)
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Inmates"), 1)
                if lplr.Team == game:GetService("Teams"):FindFirstChild("Neutral") then
                    reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Guards"), 1)
                end
            end
            FastChange:Toggle()
        end
    end,
    Tooltip = 'Automatically switch team when lplr is dead.'
})

ChooseTeam = FastChange:CreateDropdown({
	Name = 'Team',
	List = {'Guards', 'Inmates'}
})