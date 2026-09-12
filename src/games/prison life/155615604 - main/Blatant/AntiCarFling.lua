local AntiCarFling
local CarContainer
local CarContainerParent
local afmode
local teleportService = cloneref(game:GetService('TeleportService'))
local lastPosition
local head
local rootPart
local rejoining

local function updateCharacter(character)
	head = character:WaitForChild('Head', 5)
	rootPart = character:WaitForChild('HumanoidRootPart', 5)
	lastPosition = nil
end

local function rejoin()
	if rejoining then
		return
	end
	rejoining = true
	AntiCarFling:Toggle()
	notif('AntiCarFling', 'Fling detected, rejoining...', 5, 'alert')
	lplr:Kick('Fling detected, rejoining...')
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
				AntiCarFling:Clean(runService.Heartbeat:Connect(function(dt)
					local trackedPart = rootPart or head
					if not trackedPart or not trackedPart.Parent or not lastPosition or dt <= 0 then
						if trackedPart and trackedPart.Parent then
							lastPosition = trackedPart.Position
						end
						return
					end

					local position = trackedPart.Position
					local speed = (position - lastPosition).Magnitude / dt
					lastPosition = position
					if speed > 1500 or trackedPart.AssemblyLinearVelocity.Magnitude > 1500 then
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
			rootPart = nil
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