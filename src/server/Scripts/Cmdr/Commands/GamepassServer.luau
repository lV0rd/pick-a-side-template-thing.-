local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Source = ServerStorage.Source
local Services = Source.Services

local PlayerService = require(Services.PlayerService)
local IDs = require(ReplicatedStorage.Shared.Data.IDs)

return function(context, Gamepass: number, player: Player?)
    local Player = if player then player else context.Executor

    local PlayerData = PlayerService:GetPlayer(Player)
    if not PlayerData then
        return "Player data not found."
    end

    if not IDs.Gamepasses[tostring(Gamepass)] then
        return "Invalid ID!"
    end

    if not PlayerData.Replica.Data.Gamepasses[tostring(Gamepass)] then
        return "Already owned."
    end

    PlayerData.Replica:Set({"Gamepasses", tostring(Gamepass)}, true)

    return "Gamepass granted!"
end
