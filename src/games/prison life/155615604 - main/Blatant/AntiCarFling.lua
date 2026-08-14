local AntiCarFling

AntiCarFling = vape.Categories.Blatant:CreateModule({
	Name = 'AntiCarFling',
	Function = function(callback)
		if callback then
			game.Workspace.CarContainer:Destroy()
            AntiCarFling:Toggle()
		end
	end,
	Tooltip = 'just prevents u getting fucked by cars'
})