local ReplicatedStorage = game:GetService("ReplicatedStorage")

return {
    ["Default"] = {
        Instance = ReplicatedStorage.Assets.Animations.Default,
        Currency = "Free",
        Name = "Default",
    },
    
    ["Money"] = {
        Instance = ReplicatedStorage.Assets.Animations.Money,
        Currency = "Coins",
        Name = "Money",
        Price = 1000,
    },

    ["Special"] = {
        Instance = ReplicatedStorage.Assets.Animations.Special,
        Currency = "Robux",
        Name = "Special",
        ID = "1000",
    },
}