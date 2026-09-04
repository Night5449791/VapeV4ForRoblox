local FastChange
local ChooseTeam

local function requestTeam(reqteam, team)
    return reqteam and pcall(reqteam.InvokeServer, reqteam, team, 1) or false
end

local function waitForTeam(team, timeout)
    local deadline = os.clock() + timeout
    while lplr.Team ~= team and os.clock() < deadline do
        task.wait()
    end
    return lplr.Team == team
end

local function changeTeam(reqteam, team, neutralTeam)
    if lplr.Team == team then
        return true
    end

    if lplr.Team ~= neutralTeam then
        requestTeam(reqteam, neutralTeam)
        waitForTeam(neutralTeam, 0.5)
    end

    return requestTeam(reqteam, team) and waitForTeam(team, 1)
end

FastChange = vape.Categories.Blatant:CreateModule({
    Name = 'FastChange',
    Function = function(callback)
        if not callback then
            return
        end

        local targetName = ChooseTeam.Value
        local targetTeam = teams:FindFirstChild(targetName)
        local neutralTeam = teams:FindFirstChild('Neutral')
        local fallbackName = targetName == 'Guards' and 'Inmates' or 'Guards'
        local fallbackTeam = teams:FindFirstChild(fallbackName)
        local remotes = replicatedStorage:FindFirstChild('Remotes')
        local reqteam = remotes and remotes:FindFirstChild('RequestTeamChange')
        if not reqteam or not neutralTeam or not targetTeam or not fallbackTeam then
            notif('FastChange', 'Team change remote is unavailable.', 5, 'alert')
            FastChange:Toggle()
            return
        end

        if not changeTeam(reqteam, targetTeam, neutralTeam) then
            changeTeam(reqteam, fallbackTeam, neutralTeam)
        end
        FastChange:Toggle()
    end,
    Tooltip = 'Quickly switch teams.'
})

ChooseTeam = FastChange:CreateDropdown({
	Name = 'Team',
	List = {'Guards', 'Inmates'}
})