local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

return Red.Event("Invisible", function(Toggle)
    return Guard.Boolean(Toggle)
end)