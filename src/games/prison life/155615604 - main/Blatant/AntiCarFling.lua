local AntiCarFling
local CarContainer
local CarContainerParent
local afmode
local teleportService = cloneref(game:GetService('TeleportService'))
local lastPosition
local head
local rejoining

local function updateCharacter(character)
	head = character:WaitForChild('Head', 5)
	lastPosition = nil
end

local function rejoin()
	if rejoining then
		return
	end

	rejoining = true
	AntiCarFling:Toggle()
	notif('AntiCarFling', 'Fling detected, rejoining...', 5, 'alert')
	if playersService.NumPlayers > 1 then
		teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
	else
		teleportService:Teleport(game.PlaceId)
	end
end

AntiCarFling = vape.Categories.Blatant:CreateModule({
	Name = 'AntiCarFling',
	Function = function(callback)
		if callback then
			if afmode.Value == 'CarContainers' then
				CarContainer = workspace:FindFirstChild('CarContainer')
				if CarContainer then
					CarContainerParent = CarContainer.Parent
					CarContainer.Parent = nil
				end
			else
				updateCharacter(lplr.Character or lplr.CharacterAdded:Wait())
				AntiCarFling:Clean(lplr.CharacterAdded:Connect(updateCharacter))
				AntiCarFling:Clean(runService.PreSimulation:Connect(function()
					if head then
						lastPosition = head.Position
					end
				end))
				AntiCarFling:Clean(runService.PostSimulation:Connect(function(dt)
					if not head or not lastPosition or dt <= 0 then
						return
					end

					if (head.Position - lastPosition).Magnitude / dt > 1500 then
						rejoin()
					end
				end))
			end
		else
			if CarContainer then
				CarContainer.Parent = CarContainerParent
				CarContainer = nil
				CarContainerParent = nil
			end
			head = nil
			lastPosition = nil
			rejoining = nil
		end
	end,
	Tooltip = 'just prevents u getting fucked by cars'
})

afmode = AntiCarFling:CreateDropdown({
	Name = 'Type',
	List = {'CarContainers', 'Brute AF'},
	Function = function()
		if AntiCarFling.Enabled then
			AntiCarFling:Toggle()
			AntiCarFling:Toggle()
		end
	end,
	Tooltip = 'CarContainers nil\nBrute AF: kick and rejoin',
})