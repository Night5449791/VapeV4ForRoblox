local Desync
local hook

Desync = vape.Categories.Blatant:CreateModule({
	Name = 'Desync',
	Function = function(callback)
		if callback then
			raknet.desync(true)
		else
			raknet.desync(true)
		end
	end,
	Tooltip = 'Prevent the server from replicating your current position to other players.'
})