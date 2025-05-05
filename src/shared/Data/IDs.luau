local RunService = game:GetService("RunService")

return {
    Gamepasses = {
        ["1000"] = {
            Name = "hello",
            Callback = if RunService:IsServer() then function(Player : Player, Profile)
                
            end else nil,
        }
    },

    Products = {
        ["1000"] = {
            Name = "hello",
            Callback = if RunService:IsServer() then function(Player : Player, Profile)
                
            end else nil,
        }
    }
}