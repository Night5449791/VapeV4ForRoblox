local AntiHeadFling,Threshold
local triggered = false
local allowedParts = {Head=true,HumanoidRootPart=true,['Left Arm']=true,['Right Arm']=true,['Left Leg']=true,['Right Leg']=true,Torso=true}
local function trigger(part,speed)
	if triggered then return end
	triggered=true
	local placeId,jobId=game.PlaceId,game.JobId
	local alone=#playersService:GetPlayers()<=1
	lplr:Kick(string.format('Kill fling: %s at %.1f studs/s. rejoining...',part.Name,speed))
	task.spawn(function()
		local ok,err=pcall(function()
			local ts=game:GetService('TeleportService')
			if alone or jobId=='' then ts:Teleport(placeId,lplr) else ts:TeleportToPlaceInstance(placeId,jobId,lplr) end
		end)
		if not ok then warn('Rejoin failed: '..tostring(err)) end
	end)
end
local function check()
	if triggered then return end
	local character=lplr.Character
	local humanoid=character and character:FindFirstChildOfClass('Humanoid')
	if not humanoid or (humanoid.Health>0 and humanoid:GetState()~=Enum.HumanoidStateType.Dead) then return end
	for _,part in character:GetChildren() do
		if part:IsA('BasePart') and allowedParts[part.Name] then
			local speed=part:GetVelocityAtPosition(part.Position).Magnitude
			if speed>Threshold.Value then trigger(part,speed) return end
		end
	end
end
AntiHeadFling=vape.Categories.World:CreateModule({Name='AntiHeadFling',Function=function(callback)
	triggered=false
	if callback then
		AntiHeadFling:Clean(runService.PreSimulation:Connect(check))
		AntiHeadFling:Clean(runService.PostSimulation:Connect(check))
	end
end,Tooltip='Rejoin when your character is flung after dying.'})
Threshold=AntiHeadFling:CreateSlider({Name='Threshold',Min=100,Max=1000,Default=300,Suffix=' studs/s',Darker=true})
