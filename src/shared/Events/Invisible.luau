local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Event("Invisible", function(Toggle)
    return Toggle
end)