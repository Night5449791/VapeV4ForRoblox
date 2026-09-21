local ToolGrip
local DefaultGrip = Vector3.new(1, 2, 0)
local SpecialGrips = {
	['Remington 870'] = Vector3.new(1, 2, 1.5),
	['AK-47'] = Vector3.new(1, 2, 1.5)
}

local function ApplyGrip(tool)
	if tool:IsA('Tool') then
		local grip = SpecialGrips[tool.Name] or DefaultGrip
		if tool.GripPos ~= grip then
			tool.GripPos = grip
		end
	end
end

local function ResetGrip(tool)
	if tool:IsA('Tool') then
		if tool.GripPos ~= Vector3.new(0, 0, 0) then
			tool.GripPos = Vector3.new(0, 0, 0)
		end
	end
end

local function EntityAdded()
	local backpack = lplr:FindFirstChildWhichIsA('Backpack')
	if not backpack then
		return
	end

	ToolGrip:Clean(backpack.ChildAdded:Connect(ApplyGrip))
	for _, tool in backpack:GetChildren() do
		ApplyGrip(tool)
	end
end

ToolGrip = vape.Categories.Blatant:CreateModule({
	Name = 'ToolGrip',
	Function = function(callback)
		if callback then
			ToolGrip:Clean(entitylib.Events.LocalAdded:Connect(EntityAdded))
			if entitylib.isAlive then
				task.spawn(EntityAdded)
			end
		else
			local backpack = lplr:FindFirstChildWhichIsA('Backpack')
			if backpack then
				for _, tool in backpack:GetChildren() do
					ResetGrip(tool)
				end
			end
		end
	end,
	Tooltip = 'applies tool grip pos'
})