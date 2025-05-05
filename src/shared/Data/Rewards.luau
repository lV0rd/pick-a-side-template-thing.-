return {
    Spin = {
        [1] = {
            Name = "+1 Spin",
            Image = "rbxassetid://1234567890",
            Chance = .2,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                
            end,
        },

        [2] = {
            Name = "+100 Coins",
            Image = "rbxassetid://1234567890",
            Chance = .1,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                
            end,
        },

        [3] = {
            Name = "+1000 Coins",
            Image = "rbxassetid://1234567890",
            Chance = .2,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                
            end,
        },

        [4] = {
            Name = "+2 Spins",
            Image = "rbxassetid://1234567890",
            Chance = .1,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                
            end,
        },

        [5] = {
            Name = "+4000 Coins",
            Image = "rbxassetid://1234567890",
            Chance = .1,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                
            end,
        },

        [6] = {
            Name = "+2000 Coins",
            Image = "rbxassetid://1234567890",
            Chance = .1,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                
            end,
        },

        [7] = {
            Name = "+5 Spins",
            Image = "rbxassetid://1234567890",
            Chance = .1,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                
            end,
        },

        [8] = {
            Name = "Nothing!",
            Image = "rbxassetid://1234567890",
            Chance = .1,
            Description = "Get an extra spin!",
            
            Callback = function(Player : Player, Profile)
                
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
                
                
            end,

            Image = "rbxassetid://17613785372"
        };
    },

    Daily = {

    }
}