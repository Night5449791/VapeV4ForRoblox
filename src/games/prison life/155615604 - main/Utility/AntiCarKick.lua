local AntiCarKick
local CarContainer
AntiCarKick = vape.Categories.Utility:CreateModule({
	Name = 'AntiCarKick',
	Function = function(callback)
		if callback then
			if game.Workspace.CarContainer then
                game.Workspace.CarContainer:Destroy()
            end
			notif("Force removed cars, rejoin to see cars again.")
			AntiCarKick:Toggle()
		end
	end,
	Tooltip = '(ONLY USE WHEN TARGETED FLING) prevent those niggas from kicking u',
})