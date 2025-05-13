local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guard = require(ReplicatedStorage.Packages.Guard)
local Red = require(ReplicatedStorage.Packages.Red)


return Red.Function("Crate", function(Instance)
    return Guard.Instance(Instance)
end, function(Index)
    return Guard.Any(Index)
end)
