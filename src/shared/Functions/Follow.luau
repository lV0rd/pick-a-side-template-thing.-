local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("Follow", function()
    return nil
end, function(Success, List)
    return Success, List
end)