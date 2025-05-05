local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Red = require(ReplicatedStorage.Packages.Red)

return Red.Function("Gifts", function(Index : number?)
    return Index
end, function(Success : boolean, message: string?)
    return Success, message
end)