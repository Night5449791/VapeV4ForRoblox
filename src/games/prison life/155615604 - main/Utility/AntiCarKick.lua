local AntiCarKick

AntiCarKick = vape.Categories.Utility:CreateModule({
	Name = 'AntiCarKick',
	Function = function(callback)
		if callback then
			if game.CarContainer then
                game.CarContainer:Destroy()
            end
		end
	end,
	Tooltip = 'prevent those niggas from kicking u',
})