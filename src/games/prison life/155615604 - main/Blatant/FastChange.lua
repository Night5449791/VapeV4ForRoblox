local FastChange
local ChooseTeam

local function requestTeam(team)
    local replicatedStorage = game:GetService('ReplicatedStorage')
    local remotes = replicatedStorage:WaitForChild('Remotes', 5)
    local reqteam = remotes and remotes:WaitForChild('RequestTeamChange', 5)
    if not reqteam or not team then return false end

    for _ = 1, 4 do
        if lplr.Team == team then return true end
        local success = pcall(function()
            reqteam:InvokeServer(team, 1)
        end)
        if success then
            local deadline = os.clock() + 1.5
            repeat
                task.wait(0.1)
                if lplr.Team == team then return true end
            until os.clock() >= deadline
        end
    end
    return lplr.Team == team
end

FastChange = vape.Categories.Blatant:CreateModule({
    Name = 'FastChange',
    Function = function(callback)
        if callback then
            local targetTeam = game:GetService('Teams'):FindFirstChild(ChooseTeam.Value)
            local neutralTeam = game:GetService('Teams'):FindFirstChild('Neutral')
            if not targetTeam or not neutralTeam then
                notif('FastChange', 'Team objects are not ready.', 5, 'alert')
                FastChange:Toggle()
                return
            end

            if lplr.Team ~= targetTeam then
                requestTeam(neutralTeam)
                task.wait(0.25)
            end
            if not requestTeam(targetTeam) then
                notif('FastChange', 'Team change was rejected or timed out.', 5, 'alert')
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