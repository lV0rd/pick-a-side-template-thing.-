local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Service = {
	Name = script.Name,
}

local Source = ServerStorage.Source
local Services = Source.Services

local Shared = ReplicatedStorage.Shared
local Events = Shared.Events

local Dances = require(Shared.Data.Dances)

local Purchase = require(Events.Purchase):Server()
local Equip = require(Events.Equip):Server()
local Notify = require(Events.Notify):Server()

local Debounces = {}

function Service.Start()
	local PlayerService = require(Services.PlayerService)

    --Crate opening (swords)

    --Purchasing and equipping
	Purchase:On(function(Player: Player, Type: string, Item: string)
		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			Player:Kick("Data no loaded, please rejoin, and contact our devs about this.")
			return
		end

		local Replica = PlayerData.Replica
		local Data = Replica.Data

        if Debounces[Player] then
            return
        end

		if Type == "Emote" then
			local DancaData = Dances[Item]
			if not DancaData then
				return
			end

			if DancaData.Currency ~= "Coins" then
				return
			end

			if Data.Coins < DancaData.Price then
                Notify:Fire(Player, "Can't afford!")
				return
			end

			if Data.Emotes[Item] then
				return
			else
                Debounces[Player] = true
                task.delay(.5, function()
                    Debounces[Player] = nil
                end)
				Replica:Set({"Emotes", Item}, true)
                Replica:Set({"Coins"}, Data.Coins - DancaData.Price )

                Notify:Fire(Player, "Successfully bought "..DancaData.Name.."!")
			end
		end
	end)

    Equip:On(function(Player : Player, Type : string, Item : string)
        local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			Player:Kick("Data no loaded, please rejoin, and contact our devs about this.")
			return
		end

		local Replica = PlayerData.Replica
		local Data = Replica.Data

        if Debounces[Player] then
            return
        end

        if Type == "Sword" then
            if Data.Swords[Item] then
                Debounces[Player] = true
                task.delay(.5, function()
                    Debounces[Player] = nil
                end)

                Replica:Set({"EquippedSword"}, Item)
                Notify:Fire(Player, "Equipped "..Item)
            end
        elseif Type == "Emote" then
            if Data.Emotes[Item] then
                Debounces[Player] = true
                task.delay(.5, function()
                    Debounces[Player] = nil
                end)

                Replica:Set({"EquippedEmote"}, Item)
                Notify:Fire(Player, "Equipped "..Item)
            end
        end
    end)
end

return Service
