local ServerStorage = game:GetService("ServerStorage")
local Source = ServerStorage.Source
local Services = Source.Services

local PlayerService = require(Services.PlayerService)

return function(context, stat: string, amount: number, player: Player?)
    local Player = if player then player else context.Executor

    local PlayerData = PlayerService:GetPlayer(Player)
    if not PlayerData then
        return "Player data not found."
    end

    if not PlayerData.Replica.Data[stat] then
        return "Invalid stat"
    end

    PlayerData.Replica:Set({stat}, PlayerData.Replica.Data[stat] + amount)
    
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        local statValue = leaderstats:FindFirstChild(stat)
        if statValue then
            statValue.Value = PlayerData.Replica.Data[stat]
        end
    end

    return "Success!"
end
