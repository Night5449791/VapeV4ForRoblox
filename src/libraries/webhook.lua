local HttpService = game:GetService("HttpService")

function sendwebhook(Webhook, Title, Description)
    local embed = {
        ['title']       = Title,
        ['description'] = Description .. "\n\n" .. tostring(os.date("%m/%d/%y @ %X"))
    }

    local response = http_request({
        Url = Webhook,
        Headers = { ['Content-Type'] = 'application/json' },
        Body = HttpService:JSONEncode({
            ['embeds']  = { embed },
            ['content'] = ''
        }),
        Method  = "POST"
    })

    return response
end