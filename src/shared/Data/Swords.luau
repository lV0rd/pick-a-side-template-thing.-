local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
    ["ClassicSword"] = {
        Instance = ReplicatedStorage.Assets.Items.ClassicSword,
        Name = "Sword",
        Damage = 10,
    },
    ["Bat"] = {
        Instance = ReplicatedStorage.Assets.Items.Bat,
        Name = "Bat",
        Damage = 20,
    },
    ["AdminStick"] = {
        Instance = ReplicatedStorage.Assets.Items.AdminStick,
        Name = "OP Admin Sword",
        Damage = 100,
    },
}