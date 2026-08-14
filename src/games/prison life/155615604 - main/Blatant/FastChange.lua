local FastChange
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")
local ChooseTeam

FastChange = vape.Categories.Utility:CreateModule({
    Name = 'FastChange',
    Function = function(callback)
        if callback then 
            if ChooseTeam.Value == 'Guards' then
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Neutral"), 1)
                wait(.5)
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Guards"), 1)
                -- useful wait as the server is a fucking jerk
                wait(.5)
                if lplr.Team == 'Neutral' then
                    reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Inmates"), 1)
                end
            elseif ChooseTeam.Value == 'Inmates' then
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Neutral"), 1)
                wait(.5)
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Inmates"), 1)
                wait(.5)
                if lplr.Team == 'Neutral' then
                    reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Guards"), 1)
                end
            end
            FastChange:Toggle()
        end
    end,
    Tooltip = 'not-Automatically switch team'
})

ChooseTeam = FastChange:CreateDropdown({
	Name = 'Team',
	List = {'Guards', 'Inmates'}
})