local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

return Red.Function("Daily", function()
    return
end, function(Success)
    return Guard.Boolean(Success)
end)