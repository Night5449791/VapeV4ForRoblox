local AnimationPlayer
local IDBox
local Priority
local Speed
local anim, animobject

BannedAnim = vape.Categories.Blatant:CreateModule({
	Name = 'BannedAnim',
	Function = function(callback)
		if callback then
			BannedAnim:Toggle()

			animobject = Instance.new('Animation')
			animobject.AnimationId = 'rbxassetid://148840371' or "rbxassetid://5918726674"

			if entitylib.isAlive then
				lplr.Character:FindFirstChildWhichIsA("Humanoid"):LoadAnimation(animobject)
			end
		end
	end,
	Tooltip = 'Plays a specific animation of your choosing at a certain speed'
})