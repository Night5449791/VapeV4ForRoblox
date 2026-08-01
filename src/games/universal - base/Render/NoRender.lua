local NoRender

NoRender = vape.Categories.Render:CreateModule({
	Name = 'NoRender',
	Function = function(callback)
		if callback then
			if callback == true then
				game.RunService:Set3dRenderingEnabled(false)
			else
            	game.RunService:Set3dRenderingEnabled(callback)
			end
		end
	end,
	Tooltip = 'disable rendering'
})