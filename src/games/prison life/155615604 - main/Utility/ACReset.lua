local ACReset
local reqteam = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes"):FindFirstChild("RequestTeamChange")

ACReset = vape.Categories.Utility:CreateModule({
    Name = 'ACReset',
    Function = function(callback)
        if callback then
            local t = lplr.Team and game:GetService("Teams"):FindFirstChild(lplr.Team.Name)

            local char = lplr.Character or lplr.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildWhichIsA("Humanoid")

            if not humanoid then
                humanoid = char:WaitForChild("Humanoid", 5)
            end

            if humanoid then
                humanoid.Died:Connect(function()
                    if t then
                        notif("ACReset", "You have died, switching team to " .. t.Name)
                    end
                end)
            end
        end
    end,
    Tooltip = 'Automatically switch team when lplr is dead.'
})