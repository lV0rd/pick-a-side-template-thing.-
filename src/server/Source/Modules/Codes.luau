return {
    ["RELEASE"] = function(Player : Player, Profile)
        local Replica = Profile.Replica
        local Data = Replica.Data

        Replica:Set({"Coins"}, Data.Coins + 2000)
    end
}