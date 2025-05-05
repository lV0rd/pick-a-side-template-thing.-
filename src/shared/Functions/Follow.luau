local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("Follow", function()
    return nil
end, function(Success : boolean, List : {number}?)
    return Success, List
end)