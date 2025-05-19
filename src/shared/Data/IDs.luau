local RunService = game:GetService("RunService")

return {
	Gamepasses = {
		["1213310679"] = {
			Name = "Double Wins",
			Description = "Earn double the wins!",
			OnJoin = true,
			Callback = if RunService:IsServer()
				then function(Player: Player, PlayerData)
					local LocalData = PlayerData.LocalData
					LocalData:Set({ "WinsMultiplier" }, 2)
				end
				else nil,
		},

		["1214504658"] = {
			Name = "Double Coins",
			Description = "Earn double the coins!",
			OnJoin = true,
			Callback = if RunService:IsServer()
				then function(Player: Player, PlayerData)
					local LocalData = PlayerData.LocalData
					LocalData:Set({ "CoinsMultiplier" }, 2)
				end
				else nil,
		},

		["1218319054"] = {
			Name = "Double Health",
			Description = "Get stronger with double health!",
			OnJoin = true,
			Callback = if RunService:IsServer()
				then function(Player: Player, PlayerData)
					local LocalData = PlayerData.LocalData
					LocalData:Set({ "HealthMultiplier" }, 2)
				end
				else nil,
		},

		["1225617247"] = {
			Name = "Double Kills",
			Description = "Earn double the kills!",
			OnJoin = true,
			Callback = if RunService:IsServer()
				then function(Player: Player, PlayerData)
					local LocalData = PlayerData.LocalData
					LocalData:Set({ "KillsMultiplier" }, 2)
				end
				else nil,
		},

		["1215086673"] = {
			Name = "Instant Spin",
			Description = "No waiting for the spin wheel to finish!",
			OnJoin = true,
			Callback = if RunService:IsServer()
				then function(Player: Player, PlayerData)
					local LocalData = PlayerData.LocalData
					LocalData:Set({ "SpinDebounce" }, false)
				end
				else nil,
		},

        ["1221624083"] = {
            Name = "Special Emotes",
			Description = "Get cool emotes!",
			OnJoin = true,
			Callback = if RunService:IsServer()
				then function(Player: Player, PlayerData)
					local ReplicaData = PlayerData.Replica
					ReplicaData:Set({ "Emotes", "Special" }, true)
				end
				else nil,
        }
	},

	Products = {
		["3285669245"] = {
			Name = "+1000 Coins",
			Callback = if RunService:IsServer()
				then function(ReceiptInfo: any, PlayerData)
					local ReplicaData = PlayerData.Replica
					ReplicaData:Set({ "Coins" }, ReplicaData.Data.Coins + 1000)
				end
				else nil,
		},

		["3285669246"] = {
			Name = "+5000 Coins",
			Callback = if RunService:IsServer()
				then function(ReceiptInfo: any, PlayerData)
					local ReplicaData = PlayerData.Replica
					ReplicaData:Set({ "Coins" }, ReplicaData.Data.Coins + 5000)
				end
				else nil,
		},
		
		["3285669262"] = {
			Name = "+15000 Coins",
			Callback = if RunService:IsServer()
				then function(ReceiptInfo: any, PlayerData)
					local ReplicaData = PlayerData.Replica
					ReplicaData:Set({ "Coins" }, ReplicaData.Data.Coins + 15000)
				end
				else nil,
		},
	},

	Badges = {
		Welcome = 3367923520368207,
		Victory = 2117913310368126,
	}
}
