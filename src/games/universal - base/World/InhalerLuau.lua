local InhalerLuau
local TextBox

InhalerLuau = vape.Categories.World:CreateModule({
	Name = 'InhalerLuau',
	Function = function(callback)
		if callback then
			local success, err = pcall(function()
				loadstring(TextBox.Value)()
			end)
			if not success then
				vape:CreateNotification('InhalerLuau', 'Error executing code: ' .. err, 30, 'alert')
			end
		end
	end,
	Tooltip = 'Execute custom Luau code from textbox.'
})

TextBox = InhalerLuau:CreateTextList({
	Name = 'Code',
	Function = function(enter)
		if enter then
			if InhalerLuau.Enabled then
				InhalerLuau:Toggle()
				InhalerLuau:Toggle()
			else
				InhalerLuau:Toggle()
			end
		end
	end,
	Default = '-- Enter your Luau code here'
})