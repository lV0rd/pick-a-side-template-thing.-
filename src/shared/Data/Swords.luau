local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
    ["ClassicSword"] = {
        Instance = ReplicatedStorage.Assets.Items.ClassicSword,
        Name = "Sword",
        Damage = 10,

        Order = 1,
    },
    ["Bat"] = {
        Instance = ReplicatedStorage.Assets.Items.Bat,
        Name = "Bat",
        Damage = 20,

        Order = 2,
    },
    ["AdminStick"] = {
        Instance = ReplicatedStorage.Assets.Items.AdminStick,
        Name = "OP Admin Sword",
        Damage = 100,

        Order = 3,
    },
}