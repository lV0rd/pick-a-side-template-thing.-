local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
    ["Default"] = {
        Instance = ReplicatedStorage.Assets.Animations.Default,
        Currency = "Free",
        Name = "Default",

        Order = 1
    },
    
    ["Money"] = {
        Instance = ReplicatedStorage.Assets.Animations.Money,
        Currency = "Coins",
        Name = "Money",
        Price = 1000,

        Order = 2
    },

    ["Special"] = {
        Instance = ReplicatedStorage.Assets.Animations.Special,
        Currency = "Robux",
        Name = "Special",
        ID = "1000",

        Order = 3
    },
}