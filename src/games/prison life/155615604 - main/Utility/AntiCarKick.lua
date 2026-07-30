local AntiCarKick

AntiCarKick = vape.Categories.Utility:CreateModule({
	Name = 'AntiCarKick',
	Function = function(callback)
		if callback then
			if game.CarContainers then
                game.CarContainers:Destroy()
            else
                return nil
            end
		end
	end,
	Tooltip = 'prevent those niggas from kicking u',
})