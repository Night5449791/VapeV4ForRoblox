local AntiCarFling
AntiCarFling = vape.Categories.Blatant:CreateModule({
	Name = 'AntiCarFling',
	Function = function(callback)
		if callback then
			if workspace:FindFirstChild('CarContainer') then
				game.Workspace.CarContainer:Destroy()
			end
            notif('AntiCarFling', 'Deleted all cars, reinject will cause bugs.', 5, 'alert')
			AntiCarFling:Toggle()
		end
	end,
	Tooltip = 'just prevents u getting fucked by cars'
})