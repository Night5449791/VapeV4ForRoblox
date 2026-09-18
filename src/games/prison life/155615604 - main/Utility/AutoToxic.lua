local AutoToxic
local Toggles = {}
local lines = {
	Kicked = {
		'hey anticheat kick me | kicked <obj>',
		'prison life moment | kicked <obj>',
		'i wonder why you got kicked | kicked <obj>',
		'do you also want an antifling? | kicked <obj>',
		'bro really thought he was getting away with it | kicked <obj>',
		'anticheat finally caught up | kicked <obj>',
	}
}

local function sendMessage(name, obj)
	if #lines[name] <= 0 then return end

	local message = lines[name][Random.new():NextInteger(1, #lines[name])]
	message = message:gsub('<obj>', obj or '')
	if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		if textChatService:CanUserChatAsync(lplr.UserId) then
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
		end
	else
		replicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, 'All')
	end
end

AutoToxic = vape.Categories.Utility:CreateModule({
    Name = 'AutoToxic',
    Function = function(callback)
        if callback then
            AutoToxic:Clean(vapeEvents.CheaterKicked.Event:Connect(function(plr)
                if Toggles.Kicked.Enabled then
                    sendMessage('Kicked', plr)
                end
            end))
        end
    end,
    Tooltip = 'Says a message after a cheater gets kicked with CheatDetector enabled.'
})
Toggles.Kicked = AutoToxic:CreateToggle({
	Name = 'Kicked',
	Default = true
})
