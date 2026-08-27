local BannedAnim

local function playAnimation(char)
    anim = char.Humanoid:LoadAnimation(animobject)
end

BannedAnim = vape.Categories.Blatant:CreateModule({
    Name = 'BannedAnim',
    Function = function(callback)
        if callback then

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