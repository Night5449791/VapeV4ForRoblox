local AutoToxic
local Toggles, Lists, Cloned, Presets = {}, {Kicked = {}}, {Kicked = {}}, {}

local function sendMessage(name, obj, default)
	local message = default
	if #Lists[name] > 0 then
		if #Cloned[name] <= 0 then
			Cloned[name] = table.clone(Lists[name])
		end

		local entry = Random.new():NextInteger(1, #Cloned[name])
		message = Cloned[name][entry]
		table.remove(Cloned[name], entry)
	end

	if not message then return end

	message = message and message:gsub('<obj>', obj or '') or ''
	if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
		if textChatService:CanUserChatAsync(lplr.UserId) then
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendPresetAsync(Presets['So close'])
		else
			textChatService.ChatInputBarConfiguration.TargetTextChannel:SendPresetAsync(Presets[message] or Presets['So close'])
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
                    sendMessage('Kicked', plr, lines.Kicked[Random.new():NextInteger(1, #lines.Kicked)])
            end))
        end
    end,
    Tooltip = 'Says a message after a cheater gets kicked with CheatDetector enabled.'
})
Toggles.Kicked = AutoToxic:CreateToggle({
	Name = 'Kicked',
	Default = true
})

local lines = {
	Kicked = {
		'hey anticheat kick me | kicked <obj>',
		'gg freaking ez | kicked <obj>',
		'prison life moment | kicked <obj>',
		'i wonder why you got kicked | kicked <obj>',
		'do you also want an antifling? | kicked <obj>',
	}
}

pcall(function()
	for _, group in textChatService:GetPresetsAsync().categoryGroups do
		for _, category in group.categories do
			for _, message in category.messages do
				Presets[message.value] = message.presetId
				table.insert(Lists.Kicked, message.value)
			end
		end
	end
end)