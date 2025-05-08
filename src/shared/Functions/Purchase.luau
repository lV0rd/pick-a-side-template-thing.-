local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("Purchase", function(Type, Item)
    return Type, Item
end, function(Success)
    return Success
end)