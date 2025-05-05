local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Source = ServerStorage.Source
local Services = Source.Services

local Shared = ReplicatedStorage.Shared

local IDs = require(Shared.Data.IDs)

local Products = IDs.Products
local Gamepasses = IDs.Gamepasses

local Service = {
	Name = script.Name,
}

local PURCHASE_ID_CACHE_SIZE = 100

local function PurchaseIdCheckAsync(profile, purchase_id, grant_product): Enum.ProductPurchaseDecision
	profile = profile.Profile
	if profile:IsActive() == true then
		local purchase_id_cache = profile.Data.PurchaseIdCache
		if purchase_id_cache == nil then
			purchase_id_cache = {}
			profile.Data.PurchaseIdCache = purchase_id_cache
		end

		if table.find(purchase_id_cache, purchase_id) == nil then
			local success, result = pcall(grant_product)
			if success ~= true then
				warn(`Failed to process receipt:`, profile.Key, purchase_id, result)
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end

			while #purchase_id_cache >= PURCHASE_ID_CACHE_SIZE do
				table.remove(purchase_id_cache, 1)
			end

			table.insert(purchase_id_cache, purchase_id)
		end

		local function is_purchase_saved()
			local saved_cache = profile.LastSavedData.PurchaseIdCache
			return if saved_cache ~= nil then table.find(saved_cache, purchase_id) ~= nil else false
		end

		if is_purchase_saved() == true then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		while profile:IsActive() == true do
			local last_saved_data = profile.LastSavedData

			profile:Save()

			if profile.LastSavedData == last_saved_data then
				profile.OnAfterSave:Wait()
			end

			if is_purchase_saved() == true then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end

			if profile:IsActive() == true then
				task.wait(10)
			end
		end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end

function Service.Start()
	local PlayerService = require(Services.PlayerService)

	local function Handle(ReceiptInfo)
		local player = Players:GetPlayerByUserId(ReceiptInfo.PlayerId)

		if player ~= nil then
			local profile = PlayerService:GetPlayer(player)

			while profile == nil and player.Parent == Players do
				profile = PlayerService:GetPlayer(player)
				if profile ~= nil then
					break
				end
				task.wait()
			end

			if not profile then
				return
			end

			if Products[tostring(ReceiptInfo.ProductId)] == nil then
				warn(`No product function defined for ProductId {ReceiptInfo.ProductId}; Player: {player.Name}`)
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end

			return PurchaseIdCheckAsync(profile, ReceiptInfo.PurchaseId, function()
				Products[tostring(ReceiptInfo.ProductId)].Callback(ReceiptInfo, profile)
			end)
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local function GamepassHandle(Player: Player, GamepassId: number, Purchased: boolean)
		if Purchased == true then
			local profile = PlayerService:GetPlayer(Player)

			while profile == nil and Player.Parent == Players do
				profile = PlayerService:GetPlayer(Player)
				if profile ~= nil then
					break
				end
				task.wait()
			end

			if not profile then
				return
			end

			for id, gamepass in IDs.Gamepasses do
				if profile.Data.Gamepasses[id] ~= nil then
					continue
				end

				if id == tostring(GamepassId) then
					profile.Data.Gamepasses[id] = true
					continue
				end

				profile.Data.Gamepasses[id] = false
			end

			if not profile.Data.Gamepasses[tostring(GamepassId)] then
				profile.Data.Gamepasses[tostring(GamepassId)] = true
			else
				return
			end

			if Gamepasses[tostring(GamepassId)] == nil then
				warn(`No gamepass function defined for GamepassId {GamepassId}; Player: {Player.Name}`)
				return
			end

			Gamepasses[tostring(GamepassId)].Callback(Player, profile)()
		end
	end

	MarketplaceService.ProcessReceipt = Handle
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(GamepassHandle)
end

return Service
