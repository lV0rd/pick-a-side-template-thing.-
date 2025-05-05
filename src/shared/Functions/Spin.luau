local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("Spin", function()
    return nil
end, function(Reward : number?)
    return Reward
end)