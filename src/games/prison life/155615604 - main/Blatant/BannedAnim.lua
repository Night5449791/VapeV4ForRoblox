local BannedAnim

local function playAnimation(char)
    local animcheck = anim
    if animcheck then
        anim = nil
        animcheck:Stop()
    end

    local suc, res = pcall(function()
        anim = char.Humanoid.Animator:LoadAnimation(animobject)
    end)

    if suc then
        local currentanim = anim
        anim:Play()

        BannedAnim:Clean(anim.Stopped:Connect(function()
            
        end))
    else
        notif('AnimationPlayer', 'failed to load anim : '..(res or 'invalid animation id'), 5, 'warning')
    end
end

BannedAnim = vape.Categories.Blatant:CreateModule({
    Name = 'BannedAnim',
    Function = function(callback)
        if callback then
            BannedAnim:Toggle()

            animobject = Instance.new('Animation')
            animobject.AnimationId = 'rbxassetid://148840371' or "rbxassetid://5918726674"

            if entitylib.isAlive then
                playAnimation(entitylib.character)
            end

            BannedAnim:Clean(entitylib.Events.LocalAdded:Connect(playAnimation))
            BannedAnim:Clean(animobject)
        else
            if anim then
                anim:Stop()
            end
        end
    end,
    Tooltip = 'Plays a specific animation of your choosing at a certain speed'
})