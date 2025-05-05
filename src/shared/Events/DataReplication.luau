local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("Replicate", function(Data: {Profile: {}, LocalData: {}}?): {any}?
    return Data
end)