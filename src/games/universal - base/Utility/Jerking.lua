local Jerking
local anim
local track

Jerking = vape.Categories.Utility:CreateModule({
	Name = "Jerking",
	Function = function(callback)
		active = callback
		if callback then
			local char = game.Players.LocalPlayer.Character
			local hum = char and char:FindFirstChildWhichIsA("Humanoid")
			if not hum then return end
			task.spawn(function()
				while active do
					local r = hum.RigType == Enum.HumanoidRigType.R15
					anim = Instance.new("Animation")
					anim.AnimationId = r and "rbxassetid://698251653" or "rbxassetid://72042024"
					track = hum:LoadAnimation(anim)
					track:Play()
					track:AdjustSpeed(r and 0.7 or 0.65)
					track.TimePosition = 0.6
					task.wait(0.1)
					while active and track.TimePosition < (r and 0.7 or 0.65) do
						task.wait(0.1)
					end
					track:Stop()
					anim:Destroy()
					track = nil
				end
			end)
		elseif track then
			track:Stop()
			anim:Destroy()
			track = nil
		end
	end,
	Tooltip = "we all know this lol",
})