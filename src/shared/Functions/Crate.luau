local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("Crate", function(Instance)
    return Instance
end, function(Index)
    return Index
end)
