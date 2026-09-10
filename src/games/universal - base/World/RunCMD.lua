local RunCMD
local luaucode

RunCMD = vape.Categories.World:CreateModule({
	Name = 'RunCMD',
	Function = function(callback)
		if callback then
			loadstring(luaucode.Value)()
		end
	end,
	Tooltip = 'runs luau directly in vape'
})

luaucode = RunCMD:CreateTextBox({
    Name = 'Code',
    Function = function(enter)
        if enter and AnimationPlayer.Enabled then
			RunCMD:Toggle()
			RunCMD:Toggle()
		end
    end,
})