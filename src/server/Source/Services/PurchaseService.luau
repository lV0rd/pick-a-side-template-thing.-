local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Service = {
    Name = script.Name,
}

local Source = ServerStorage.Source
local Services = Source.Services

local Shared = ReplicatedStorage.Shared
local Functions = Shared.Functions

local Dances = Shared.Data.Dances
local Swords = Shared.Data.Swords

local Purchase = require(Functions.Purchase)

function Service.Start()
    local PlayerService = require(Services.PlayerService)

    Purchase:SetCallback(function(Player: Player, Type: string, Item: string)
        local Success = false

        local PlayerData = PlayerService:GetPlayer(Player)
        if not PlayerData then
            Player:Kick("Data no loaded, please rejoin, and contact our devs about this.")
            return Success
        end

        local Replica = PlayerData.Replica
        local Data = Replica.Data

        if Type == "Emote" then
            local DancaData = Dances[Item]
            if not DancaData then
                return Success
            end

            if DancaData.Currency ~= "Coins" then
                return Success
            end

            if Data.Coins < DancaData.Price then
                return Success
            end

            if Data.Emotes[Item] then
                return Success
            else
                Replica:Set({"Coins", Data.Coins - DancaData.Price})
                Replica:Set({"Emotes", Item}, true)
                
                Data.Emotes[Item] = true
                Success = true
            end
        end

        return Success
    end)
end

return Service