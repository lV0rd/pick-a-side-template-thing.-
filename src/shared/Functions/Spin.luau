local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guard = require(ReplicatedStorage.Packages.Guard)
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("Spin", function()
    return
end, function(Reward)
    return Guard.Number(Reward)
end)