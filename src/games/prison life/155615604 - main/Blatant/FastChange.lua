local FastChange
local ChooseTeam
local teamsService = game:GetService('Teams')

local function clickTeamButton()
	local gui = lplr.PlayerGui:FindFirstChild('TeamsFrame', true)
	if gui then
		for _, holder in gui:GetChildren() do
			if holder.Button.AutoButtonColor then
				firesignal(holder.Button.MouseButton1Click)
				return true
			end
		end
	end
	return false
end

FastChange = vape.Categories.Blatant:CreateModule({
    Name = 'FastChange',
    Function = function(callback)
        if callback then
            task.spawn(function()
                local remotes = replicatedStorage:FindFirstChild('Remotes')
                local reqteam = remotes and remotes:FindFirstChild('RequestTeamChange')
                local neutral = teamsService:FindFirstChild('Neutral')
                if lplr.Team ~= neutral then
                    if reqteam and neutral then
                        reqteam:InvokeServer(neutral, 1)
                    end
                    task.wait(1.5)
                end

                if not clickTeamButton() then
                    if reqteam then
                        reqteam:InvokeServer(teamsService:FindFirstChild(ChooseTeam.Value), 1)
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