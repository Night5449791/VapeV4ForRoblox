local FastChange
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")
local ChooseTeam

FastChange = vape.Categories.Blatant:CreateModule({
    Name = 'FastChange',
    Function = function(callback)
        if callback then 
            if ChooseTeam.Value == 'Guards' then
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Neutral"), 1)
                wait(1)
                if not lplr.PlayerGui.Home.IntroFrame.ContentBackground.MainMenuFrame.TeamsFrame.Guard.Button.TextLabel.Text == "Join" then
                    reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Inmates"), 1)
                else
                    reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Guards"), 1) 
                end
            elseif ChooseTeam.Value == 'Inmates' then
                reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Neutral"), 1)
                wait(1)
                if not lplr.PlayerGui.Home.IntroFrame.ContentBackground.MainMenuFrame.TeamsFrame.Inmates.Button.TextLabel.Text == "Join" then
                    reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Guards"), 1)
                else
                    reqteam:InvokeServer(game:GetService("Teams"):FindFirstChild("Inmates"), 1)
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