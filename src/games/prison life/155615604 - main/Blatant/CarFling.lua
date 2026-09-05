local CarFling
local GuardTarget
local InmateTarget
local CriminalTarget
local Mode
local FlingPower
local FlickerSpeed

local oldTargetY = 178
local newTargetY = 300
local shakeAmount = 0.04
local shakeSpeed = 8
local oldMinFollowY, oldMaxFollowY = -50, 160
local newMinFollowY, newMaxFollowY = -50, 999999
local offset = Vector3.new(1.5, 3, 11.7)
local predictionMultiplier = 0.75
local pingMultiplier = 1
local minLead, maxLead = 0.08, 0.65
local leadPullback = 3.5

local carModel
local rootPart
local partOffsets = {}
local savedX, savedZ
local frameCount, shakeTime = 0, 0
local waitingForDeath, flinging = false, false

local function playerNames(teamName)
	local names = {'None'}
	for _, player in playersService:GetPlayers() do
		if player ~= lplr and player.Team and player.Team.Name == teamName then
			table.insert(names, player.DisplayName .. ' - ' .. player.Name)
		end
	end
	return names
end

local function getTargetPlayer(value)
	local username = value:match(' %- (.+)$')
	return username and playersService:FindFirstChild(username)
end

local function selectedTarget()
	for _, value in {GuardTarget.Value, InmateTarget.Value, CriminalTarget.Value} do
		local player = getTargetPlayer(value)
		if player then return player end
	end
end

local function refreshTargets()
	GuardTarget:Change(playerNames('Guards'))
	InmateTarget:Change(playerNames('Inmates'))
	CriminalTarget:Change(playerNames('Criminals'))
end

local function inPrison(position)
	return position.X > 700 and position.X < 1250 and position.Z > 2100 and position.Z < 2700
end

local function getPingLead(player, speed)
	local ping = 0
	pcall(function()
		ping = player:GetNetworkPing() or 0
	end)
	if ping <= 0 then
		return math.clamp(speed * 0.24, 0.22, 0.85)
	end
	return math.clamp(ping * pingMultiplier, minLead, maxLead)
end

local function isWheel(part)
	local name = part.Name:lower()
	return name:find('wheel') or name:find('tire') or name:find('rim')
end

local function lockWheels(car)
	if not car then return end
	for _, object in car:GetDescendants() do
		if object:IsA('BasePart') and isWheel(object) then
			object.AssemblyLinearVelocity = Vector3.zero
			object.AssemblyAngularVelocity = Vector3.zero
		elseif object:IsA('HingeConstraint') or object:IsA('CylindricalConstraint') then
			local name = object.Name:lower()
			local parentName = object.Parent and object.Parent.Name:lower() or ''
			if name:find('wheel') or parentName:find('wheel') then
				object.AngularVelocity = 0
				object.MotorMaxTorque = 0
			end
		end
	end
end

local function getCarFromSeat(seat)
	local object = seat
	while object and object.Parent do
		if object:IsA('Model') then
			return object
		end
		object = object.Parent
	end
end

local function cacheCar(car)
	partOffsets = {}
	rootPart = car.PrimaryPart or car:FindFirstChild('RWD') or car:FindFirstChildWhichIsA('BasePart', true)
	if not rootPart then return false end

	local rootCFrame = rootPart.CFrame
	for _, part in car:GetDescendants() do
		if part:IsA('BasePart') then
			partOffsets[part] = rootCFrame:ToObjectSpace(part.CFrame)
		end
	end
	lockWheels(car)
	return true
end

local function moveCar(cframe, applyFling, targetPosition)
	if not rootPart or not rootPart.Parent then return end

	if carModel.PrimaryPart then
		carModel:PivotTo(cframe)
	else
		for part, partOffset in partOffsets do
			if part.Parent then
				part.CFrame = cframe * partOffset
			end
		end
	end

	local linearVelocity, angularVelocity = Vector3.zero, Vector3.zero
	if applyFling then
		local direction = targetPosition - rootPart.Position
		local distance = direction.Magnitude
		direction = distance > 0.1 and direction.Unit or Vector3.zero
		local force = math.clamp(FlingPower.Value * 1.8, 80, 18000)
		linearVelocity = direction * force + Vector3.new(
			math.random(-force * 0.25, force * 0.25),
			math.random(-force * 0.15, force * 0.35),
			math.random(-force * 0.25, force * 0.25)
		)
		angularVelocity = Vector3.new(
			math.random(-FlingPower.Value * 0.4, FlingPower.Value * 0.4),
			FlingPower.Value * (math.random() > 0.5 and 1 or -1),
			math.random(-FlingPower.Value * 0.4, FlingPower.Value * 0.4)
		)
	end

	for part in partOffsets do
		if part.Parent then
			if isWheel(part) then
				part.AssemblyLinearVelocity = Vector3.zero
				part.AssemblyAngularVelocity = Vector3.zero
			else
				part.AssemblyLinearVelocity = linearVelocity
				part.AssemblyAngularVelocity = angularVelocity
			end
		end
	end
	lockWheels(carModel)
end

local function resetState()
	waitingForDeath, flinging = false, false
	frameCount, shakeTime = 0, 0
	carModel, rootPart = nil, nil
	partOffsets = {}
	savedX, savedZ = nil, nil
end

local function startFling(targetPlayer)
	flinging = true
	frameCount, shakeTime = 0, 0
	CarFling:Clean(runService.Heartbeat:Connect(function(deltaTime)
		if not flinging or not targetPlayer.Character or not carModel or not carModel.Parent then
			return
		end

		local targetRoot = targetPlayer.Character:FindFirstChild('HumanoidRootPart')
		if not targetRoot then return end

		frameCount += 1
		shakeTime += deltaTime
		local humanoid = targetPlayer.Character:FindFirstChildOfClass('Humanoid')
		local velocity = targetRoot.AssemblyLinearVelocity
		local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
		local moveDirection = humanoid and humanoid.MoveDirection or Vector3.zero
		local direction

		if moveDirection.Magnitude > 0.1 then
			direction = Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
		elseif horizontalVelocity.Magnitude > 1.5 then
			direction = horizontalVelocity.Unit
		end

		local predictedPosition, yaw
		if direction then
			local speed = math.max(horizontalVelocity.Magnitude, Mode.Value == 'New' and 20 or 16)
			local leadTime
			if Mode.Value == 'New' then
				leadTime = math.max(0, speed * getPingLead(targetPlayer, speed) * predictionMultiplier - leadPullback)
				predictedPosition = targetRoot.Position + direction * leadTime
			else
				leadTime = math.clamp(speed * 0.18, 0.18, 0.65)
				predictedPosition = targetRoot.Position + direction * speed * leadTime
			end
			yaw = math.deg(math.atan2(-direction.X, -direction.Z))
		else
			predictedPosition = targetRoot.Position
			yaw = targetRoot.Orientation.Y
		end

		local shake = Vector3.new(
			math.sin(shakeTime * shakeSpeed) * shakeAmount,
			math.sin(shakeTime * shakeSpeed * 1.4) * shakeAmount * 0.3,
			math.cos(shakeTime * shakeSpeed * 0.85) * shakeAmount
		)
		local maxFollowY = Mode.Value == 'New' and newMaxFollowY or oldMaxFollowY
		local minFollowY = Mode.Value == 'New' and newMinFollowY or oldMinFollowY
		local position = Vector3.new(
			predictedPosition.X + shake.X,
			math.clamp(predictedPosition.Y, minFollowY, maxFollowY) - 0.6 + shake.Y,
			predictedPosition.Z + shake.Z
		)
		local playerCFrame = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.new(offset)
		local targetY = Mode.Value == 'New' and newTargetY or oldTargetY
		local highCFrame = CFrame.new(savedX, targetY, savedZ) * CFrame.Angles(0, math.rad(yaw), 0)
		local flicker = FlickerSpeed.Value
		if Mode.Value == 'New' and inPrison(predictedPosition) then
			flicker = math.max(flicker, 6)
		end
		local usePlayer = frameCount % flicker == 0
		local shouldFling = Mode.Value == 'Old' or usePlayer
		moveCar(usePlayer and playerCFrame or highCFrame, shouldFling, predictedPosition)
	end))
end

CarFling = vape.Categories.Blatant:CreateModule({
	Name = 'CarFling',
	Function = function(callback)
		if not callback then
			resetState()
			return
		end

		local targetPlayer = selectedTarget()
		local character = lplr.Character
		local humanoid = character and character:FindFirstChildOfClass('Humanoid')
		local root = character and character:FindFirstChild('HumanoidRootPart')
		local seat = humanoid and humanoid.SeatPart
		local car = seat and seat:IsA('VehicleSeat') and getCarFromSeat(seat)

		if not targetPlayer or not root or not humanoid or not car or not cacheCar(car) then
			notif('CarFling', 'Select a player and sit in a vehicle first.', 5, 'alert')
			CarFling:Toggle()
			return
		end

		savedX, savedZ = root.Position.X, root.Position.Z
		carModel = car
		waitingForDeath = true
		CarFling:Clean(humanoid.Died:Connect(function()
			if waitingForDeath then
				waitingForDeath = false
				startFling(targetPlayer)
			end
		end))
		CarFling:Clean(runService.Heartbeat:Connect(function()
			if not waitingForDeath or not entitylib.isAlive then return end
			local currentRoot = entitylib.character.RootPart
			local currentHumanoid = entitylib.character.Humanoid
			local targetY = Mode.Value == 'New' and newTargetY or oldTargetY
			local highCFrame = CFrame.new(savedX, targetY, savedZ) * CFrame.Angles(0, math.rad(currentRoot.Orientation.Y), 0)
			moveCar(highCFrame, false, Vector3.new(savedX, targetY, savedZ))
			currentHumanoid.Sit = true
			currentRoot.CFrame = highCFrame * CFrame.new(0, 2, 0)
			currentRoot.AssemblyLinearVelocity = Vector3.zero
		end))
	end,
	Tooltip = 'Flicker and fling a vehicle after you die.'
})

Mode = CarFling:CreateDropdown({
	Name = 'Mode',
	List = {'Old', 'New'}
})

GuardTarget = CarFling:CreateDropdown({
	Name = 'Guard',
	List = playerNames('Guards')
})
InmateTarget = CarFling:CreateDropdown({
	Name = 'Inmates',
	List = playerNames('Inmates')
})
CriminalTarget = CarFling:CreateDropdown({
	Name = 'Criminals',
	List = playerNames('Criminals')
})
FlingPower = CarFling:CreateSlider({
	Name = 'Fling Power',
	Min = 0,
	Max = 9999,
	Default = 200,
	Darker = true
})
FlickerSpeed = CarFling:CreateSlider({
	Name = 'Flicker Speed',
	Min = 1,
	Max = 50,
	Default = 4,
	Darker = true
})

playersService.PlayerAdded:Connect(function(player)
	player:GetPropertyChangedSignal('Team'):Connect(refreshTargets)
	refreshTargets()
end)
playersService.PlayerRemoving:Connect(function()
	refreshTargets()
end)
for _, player in playersService:GetPlayers() do
	if player ~= lplr then
		player:GetPropertyChangedSignal('Team'):Connect(refreshTargets)
	end
end
