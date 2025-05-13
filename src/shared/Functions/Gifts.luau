local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

return Red.Function("Gifts", function(Index)
    return Guard.Number(Index)
end, function(Success)
    return Guard.Boolean(Success)
end)