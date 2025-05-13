local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)
local Guard = require(ReplicatedStorage.Packages.Guard)

return Red.Event("Equip", function(Type, Item)
    return Guard.String(Type), Guard.String(Item)
end)