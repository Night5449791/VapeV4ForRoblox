local CopyJobid
local userjobid
local userplid

CopyJobid = vape.Categories.Utility:CreateModule({
	Name = 'CopyJobid',
	Function = function(callback)
		if callback then
			setclipboard(game.JobId)
			CopyJobid:Toggle()
		end
	end,
	Tooltip = 'Copies jobid to clipboard'
})

userjobid = CopyJobid:CreateTextBox({
    Name = 'Job Id to join (Same PlaceId)',
    Function = function(enter)
        serverHop(game.PlaceId, enter)
    end,
    Placeholder = 'insert jobid',
    Tooltip = 'Joins jobid'
})

