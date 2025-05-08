return {
    Spin = {
        [1] = {
            Name = "+1 Spin",
            Image = "rbxassetid://16344379912",
            Chance = .2,
            
            Callback = function(Player : Player, Profile)
                Profile.Replica:Set({"Spins"}, Profile.Replica.Data.Spins + 2)
            end,
        },

        [2] = {
            Name = "+100 Coins",
            Image = "rbxassetid://17860306578",
            Chance = .1,
            
            Callback = function(Player : Player, Profile)
                Profile.Replica:Set({"Coins"}, Profile.Replica.Data.Coins + 100)
            end,
        },

        [3] = {
            Name = "+1000 Coins",
            Image = "rbxassetid://17860306578",
            Chance = .2,
            
            Callback = function(Player : Player, Profile)
                Profile.Replica:Set({"Coins"}, Profile.Replica.Data.Coins + 1000)
            end,
        },

        [4] = {
            Name = "+2 Spins",
            Image = "rbxassetid://16344379912",
            Chance = .1,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                Profile.Replica:Set({"Spins"}, Profile.Replica.Data.Spins + 2)
            end,
        },

        [5] = {
            Name = "+4000 Coins",
            Image = "rbxassetid://17860306578",
            Chance = .1,
            
            Callback = function(Player : Player, Profile)
                Profile.Replica:Set({"Coins"}, Profile.Replica.Data.Coins + 4000)
            end,
        },

        [6] = {
            Name = "+2000 Coins",
            Image = "rbxassetid://17860306578",
            Chance = .1,
            
            Callback = function(Player : Player, Profile)
                Profile.Replica:Set({"Coins"}, Profile.Replica.Data.Coins + 2000)
            end,
        },

        [7] = {
            Name = "+5 Spins",
            Image = "rbxassetid://16344379912",
            Chance = .1,
            
            Callback = function(Player : Player, Profile)
                Profile.Replica:Set({"Spins"}, Profile.Replica.Data.Spins + 5)
            end,
        },

        [8] = {
            Name = "Nothing!",
            Image = "rbxassetid://0",
            Chance = .1,
            
            Callback = function(Player : Player, Profile)
                print("Nothing!")
            end,
        },
    },

    Follow = {
        List = {1795023834},

        Callback = function(Player : Player, Profile)
            
        end
    },

    Gifts = {
        {
            Time = 60 * .1,
            Title = "+100 Coins",

            Reward = function(Player : Player, Profile)
                if not Profile then
                    return
                end
                
                Profile.Replica:Set({"Coins"}, Profile.Replica.Data.Coins + 100)
            end,

            Image = "rbxassetid://17613785372"
        };

        {
            Time = 60 * .15,
            Title = "+300 Coins",

            Reward = function(Player : Player, Profile)
                if not Profile then
                    return
                end
                
                Profile.Replica:Set({"Coins"}, Profile.Replica.Data.Coins + 300)
            end,

            Image = "rbxassetid://17613785372"
        };

        {
            Time = 60 * .3,
            Title = "+500 Coins",

            Reward = function(Player : Player, Profile)
                if not Profile then
                    return
                end
                
                Profile.Replica:Set({"Coins"}, Profile.Replica.Data.Coins + 500)
            end,

            Image = "rbxassetid://17613785372"
        };
    },

    Daily = {

    }
}