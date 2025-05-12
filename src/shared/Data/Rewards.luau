return {
	Spin = {
		[1] = {
			Name = "+1 Spin",
			Image = "rbxassetid://16344379912",
			Chance = 0.2,

			Callback = function(Player: Player, PlayerData)
				PlayerData.Replica:Set({ "Spins" }, PlayerData.Replica.Data.Spins + 2)
			end,
		},

		[2] = {
			Name = "+100 Coins",
			Image = "rbxassetid://17860306578",
			Chance = 0.1,

			Callback = function(Player: Player, PlayerData)
				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 100)
			end,
		},

		[3] = {
			Name = "+1000 Coins",
			Image = "rbxassetid://17860306578",
			Chance = 0.2,

			Callback = function(Player: Player, PlayerData)
				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 1000)
			end,
		},

		[4] = {
			Name = "+2 Spins",
			Image = "rbxassetid://16344379912",
			Chance = 0.1,
			Description = "Get an extra spin!",

			Callback = function(Player: Player, PlayerData)
				PlayerData.Replica:Set({ "Spins" }, PlayerData.Replica.Data.Spins + 2)
			end,
		},

		[5] = {
			Name = "+4000 Coins",
			Image = "rbxassetid://17860306578",
			Chance = 0.1,

			Callback = function(Player: Player, PlayerData)
				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 4000)
			end,
		},

		[6] = {
			Name = "+2000 Coins",
			Image = "rbxassetid://17860306578",
			Chance = 0.1,

			Callback = function(Player: Player, PlayerData)
				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 2000)
			end,
		},

		[7] = {
			Name = "+5 Spins",
			Image = "rbxassetid://16344379912",
			Chance = 0.1,

			Callback = function(Player: Player, PlayerData)
				PlayerData.Replica:Set({ "Spins" }, PlayerData.Replica.Data.Spins + 5)
			end,
		},

		[8] = {
			Name = "Nothing!",
			Image = "rbxassetid://0",
			Chance = 0.1,

			Callback = function(Player: Player, PlayerData)
				print("Nothing!")
			end,
		},
	},

	Follow = {
		List = { 1795023834 },

		Callback = function(Player: Player, PlayerData) end,
	},

	Gifts = {
		{
			Time = 60 * 0.1,
			Title = "+100 Coins",

			Reward = function(Player: Player, PlayerData)
				if not PlayerData then
					return
				end

				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 100)
			end,

			Image = "rbxassetid://17613785372",
		},

		{
			Time = 60 * 0.15,
			Title = "+300 Coins",

			Reward = function(Player: Player, PlayerData)
				if not PlayerData then
					return
				end

				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 300)
			end,

			Image = "rbxassetid://17613785372",
		},

		{
			Time = 60 * 0.3,
			Title = "+500 Coins",

			Reward = function(Player: Player, PlayerData)
				if not PlayerData then
					return
				end

				PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 500)
			end,

			Image = "rbxassetid://17613785372",
		},
	},

	Daily = {
		[1] = {
			Image = "rbxassetid://17613785372",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "100 Coins",
		},
		[2] = {
			Image = "rbxassetid://17613785372",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "200 Coins",
		},
		[3] = {
			Image = "rbxassetid://17735357315",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "Free Gear",
		},
		[4] = {
			Image = "rbxassetid://17610981792",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "10 Spins",
		},
		[5] = {
			Image = "rbxassetid://17613785372",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "500 Coins",
		},
		[6] = {
			Image = "rbxassetid://17613785372",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "600 Coins",
		},
		[7] = {
			Image = "rbxassetid://17735357315",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "3 Free Gear",
		},
		[8] = {
			Image = "rbxassetid://17613785372",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "800 Coins",
		},
		[9] = {
			Image = "rbxassetid://17610981792",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "20 Spins",
		},
		[10] = {
			Image = "rbxassetid://17613785372",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "1000 Coins",
		},
		[11] = {
			Image = "rbxassetid://17613785372",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "10000 Coins",
		},
		[12] = {
			Image = "rbxassetid://17610934034",
			Function = function(Player: Player, PlayerData)
				
			end,
			Title = "Big Surprise",
		},
	},
}
