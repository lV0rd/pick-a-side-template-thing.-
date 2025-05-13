local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guard = require(ReplicatedStorage.Packages.Guard)
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("Follow", function()
    return
end, function(Success)
    return Guard.Boolean(Success)
end)