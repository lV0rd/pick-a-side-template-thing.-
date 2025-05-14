local RunService = game:GetService("RunService")

return {
    Gamepasses = {
        ["1213310679"] = {
            Name = "Double Wins",
            OnJoin = true,
            Callback = if RunService:IsServer() then function(Player : Player, PlayerData)
                local LocalData = PlayerData.LocalData
                LocalData:Set({"WinsMultiplier"}, 2)
            end else nil,
        },
        ["1214504658"] = {
            Name = "Double Coins",
            OnJoin = true,
            Callback = if RunService:IsServer() then function(Player : Player, PlayerData)
                local LocalData = PlayerData.LocalData
                LocalData:Set({"CoinsMultiplier"}, 2)
            end else nil,
        },
        ["1000"] = {
            Name = "Double Kills",
            OnJoin = true,
            Callback = if RunService:IsServer() then function(Player : Player, PlayerData)
                local LocalData = PlayerData.LocalData
                LocalData:Set({"KillsMultiplier"}, 2)
            end else nil,
        },
        ["1218319054"] = {
            Name = "Double Health",
            OnJoin = true,
            Callback = if RunService:IsServer() then function(Player : Player, PlayerData)
                local LocalData = PlayerData.LocalData
                LocalData:Set({"HealthMultiplier"}, 2)
            end else nil,
        },
        ["1215086673"] = {
            Name = "Instant Spin",
            OnJoin = true,
            Callback = if RunService:IsServer() then function(Player : Player, PlayerData)
                local LocalData = PlayerData.LocalData
                LocalData:Set({"SpinDebounce"}, false)
            end else nil,
        }
    },

    Products = {
        ["3285669245"] = {
            Name = "+1000 Coins",
            Callback = if RunService:IsServer() then function(ReceiptInfo : any, PlayerData)
                local ReplicaData = PlayerData.Replica
                ReplicaData:Set({"Coins"}, ReplicaData.Data.Coins + 1000)
            end else nil,
        },
        ["3285669246"] = {
            Name = "+5000 Coins",
            Callback = if RunService:IsServer() then function(ReceiptInfo : any, PlayerData)
                local ReplicaData = PlayerData.Replica
                ReplicaData:Set({"Coins"}, ReplicaData.Data.Coins + 5000)
            end else nil,
        },
        ["3285669262"] = {
            Name = "+15000 Coins",
            Callback = if RunService:IsServer() then function(ReceiptInfo : any, PlayerData)
                local ReplicaData = PlayerData.Replica
                ReplicaData:Set({"Coins"}, ReplicaData.Data.Coins + 15000)
            end else nil,
        },
    }
}