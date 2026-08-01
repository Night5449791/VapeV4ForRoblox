local NoRender

NoRender = vape.Categories.Render:CreateModule({
	Name = 'NoRender',
	Function = function(callback)
		if callback then
            game.RunService:Set3dRenderingEnabled(false)
		end
	end,
	Tooltip = 'disable rendering'
})