-- lol

local alluserspermittedforvaping = [
    ''
]

if not alluserspermittedforvaping[game.Players.LocalPlayer.Name] then
    game.Players.LocalPlayer:Kick("You are not permitted to vape.")
end