local AnimationPlayer
local IDBox
local Priority
local Speed
local anim, animobject

local function playAnimation(char)
	local animcheck = anim
	if animcheck then
		anim = nil
		animcheck:Stop()
	end

	local suc, res = pcall(function()
		anim = char.Humanoid.Animator:LoadAnimation(animobject)
	end)

	if suc then
		local currentanim = anim
		anim.Priority = Enum.AnimationPriority[Priority.Value]
		anim:Play()
		anim:AdjustSpeed(Speed.Value)

		BannedAnimationPlayer:Clean(anim.Stopped:Connect(function()
			if currentanim == anim then
				anim:Play()
			end
		end))
	else
		notif('AnimationPlayer', 'failed to load anim : '..(res or 'invalid animation id'), 5, 'warning')
	end
end

BannedAnimPlayer = vape.Categories.Blatant:CreateModule({
	Name = 'BannedAnimationPlayer',
	Function = function(callback)
		if callback then
			animobject = Instance.new('Animation')
			animobject.AnimationId = 'rbxassetid://148840371' or "rbxassetid://5918726674"

			if entitylib.isAlive then
				playAnimation(entitylib.character)
			end

			BannedAnimationPlayer:Clean(entitylib.Events.LocalAdded:Connect(playAnimation))
			BannedAnimationPlayer:Clean(animobject)
		else
			if anim then
				anim:Stop()
			end
		end
	end,
	Tooltip = 'Plays a specific animation of your choosing at a certain speed'
})