--[[
InventoryService.luau 2025/05/12

This module is responsible for handling player inventory data
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Service = {
	Name = script.Name,
}

local Source = ServerStorage.Source
local Services = Source.Services
--Server module scripts

local Shared = ReplicatedStorage.Shared

local Events = Shared.Events
local Functions = Shared.Functions
--Remote events and functions with Red

local Dances = require(Shared.Data.Dances)
local Swords = require(Shared.Data.Swords)
--Data for dances and swords

local Purchase = require(Events.Purchase):Server()
local Equip = require(Events.Equip):Server()
local Notify = require(Events.Notify):Server()
--Events

local Crate = require(Functions.Crate)
--Functions

local Debounces = {}
--Player debounces for equipping dances/swords

--Function to pick a random index based on chance
local function pickWeighted(array: { any })
	local weight = 0

	for _, v in array do
		weight += (v[2] * 100)
	end

	local ran = math.random(1, weight)

	weight = 0
	for i, v in array do
		weight += (v[2] * 100)
		if weight >= ran then
			return i
		end
	end

	return nil
end

--Main function
function Service.Start()
	local PlayerService = require(Services.PlayerService)

	--Crate opening (for swords)
	Crate:SetCallback(function(Player: Player, CrateInstance : Instance)
		if CrateInstance.Parent ~= workspace.Map.Crates then
			Player:Kick("Remote exploitation")
			return
		end

		--Get sword indexes of crates ({"Name", Chance})
		local Indexes = require(CrateInstance:FindFirstChild("Indexes"))

		--Check if player data loaded
		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			Player:Kick("Data not loaded, please rejoin, and contact our devs about this.")
			return
		end

		local Replica = PlayerData.Replica
		local Data = Replica.Data

		--If player is in debounce, dont continue
		if Debounces[Player] then
			return
		end

		--If player does not have enough coins, dont continue
        if Data.Coins < CrateInstance:GetAttribute("Price") then
            Notify:Fire(Player, '<font color="#FF0000">Can\'t afford!</font>')
            return
        end

		--Pick a sword from the loot table at random
		local PickedSword = Indexes[pickWeighted(Indexes)][1]
		if not PickedSword then
			return
		end

		--If the sword picked is not in the database, dont continue
		local SwordData = Swords[PickedSword]

		if not SwordData then
			return
		end

		--Add player to debounces table
		Debounces[Player] = true
		task.delay(0.5, function()
			Debounces[Player] = nil
		end)

		local Price = CrateInstance:GetAttribute("Price") or 1200

		--Give sword to player, and remove 1200 coins
		Replica:Set({ "Swords", PickedSword }, true)
		Replica:Set({ "Coins" }, Data.Coins - Price)

		--Notify player (makes a gui pop up)
		Notify:Fire(Player, `<font color="#FFFF00">You have obtained the sword: '{SwordData.Name}'!</font>`)

        return SwordData
	end)

	--Purchasing and equipping
	Purchase:On(function(Player: Player, Type: string, Item: string)
		--Check if player data loaded
		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			Player:Kick("Data not loaded, please rejoin, and contact our devs about this.")
			return
		end

		local Replica = PlayerData.Replica
		local Data = Replica.Data

		--If Player is in debounce, dont continue
		if Debounces[Player] then
			return
		end

		--Check item type (only for emotes now cuz i might add something else)
		if Type == "Emote" then
			local DancaData = Dances[Item]
			if not DancaData then
				return
			end

			--If the item is not something purchasable with coins, dont continue
			if DancaData.Currency ~= "Coins" then
				return
			end

			--If player doesnt have enough coins, dont continue
			if Data.Coins < DancaData.Price then
				Notify:Fire(Player, "Can't afford!")
				return
			end

			if Data.Emotes[Item] then
				--If not a valid item, dont continue
				return
			else
				--Add player to debounce table
				Debounces[Player] = true
				task.delay(0.5, function()
					Debounces[Player] = nil
				end)

				--Give player emote and substract price
				Replica:Set({ "Emotes", Item }, true)
				Replica:Set({ "Coins" }, Data.Coins - DancaData.Price)

				--Notify player
				Notify:Fire(Player, `<font color="#FFFF00">Successfully bought '{DancaData.Name}'!</font>`)
				
			end
		end
	end)

	Equip:On(function(Player: Player, Type: string, Item: string)
		--Check if player data loaded
		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			Player:Kick("Data no loaded, please rejoin, and contact our devs about this.")
			return
		end

		local Replica = PlayerData.Replica
		local Data = Replica.Data

		--If player is in debounce, dont continue
		if Debounces[Player] then
			return
		end

		if Type == "Sword" then
			--If item is not owned, dont continue
			if Data.Swords[Item] then
				--Add player to debounce table
				Debounces[Player] = true
				task.delay(0.5, function()
					Debounces[Player] = nil
				end)

				--Set equipped sword to item and notify player
				Replica:Set({ "EquippedSword" }, Item)
				Notify:Fire(Player, `<font color="#FFFF00">Equipped '{Item}'!</font>`)
			end
		elseif Type == "Emote" then
			--If item is not owned, dont continue
			if Data.Emotes[Item] then
				--Add player to debounce table
				Debounces[Player] = true
				task.delay(0.5, function()
					Debounces[Player] = nil
				end)

				--Set equipped emote to item and notify player
				Replica:Set({ "EquippedEmote" }, Item)
				Notify:Fire(Player, `<font color="#FFFF00">Equipped '{Item}'!</font>`)
			end
		end
	end)
end

return Service