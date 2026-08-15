local AntiCarFling
AntiCarFling = vape.Categories.Blatant:CreateModule({
	Name = 'AntiCarFling',
	Function = function(callback)
		if callback then
			game.Workspace.CarContainer:Destroy()
            notif('AntiCarFling', 'Deleted all cars, reinject will cause bugs.', 5, 'alert')
			AntiCarFling:Toggle()
		end
	end,
	Tooltip = 'just prevents u getting fucked by cars'
})