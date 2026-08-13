local ACReset
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")

ACReset = vape.Categories.Utility:CreateModule({
    Name = 'ACReset',
    Function = function(callback)
        if callback then
            entity.isAlive:Connect(function()
                if not entity.isAlive then
                    local team = game:GetService("Players").LocalPlayer.Team
                    reqteam:InvokeServer("Neutral")
                    wait(.5)
                    reqteam:InvokeServer(team)
                end
            end)
        end
    end,
    Tooltip = 'Automatically switch team when lplr is dead.'
})