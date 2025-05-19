local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local Menus = Canvas.Menus

local Left = Frames.Left

local ShopButton = Left.Buttons.Shop
local ShopMenu = Menus.Shop
local CloseButton = ShopMenu.Close

local Gamepasses = ShopMenu.Elements.Gamepasses
local Products = ShopMenu.Elements.Products
local Spins = ShopMenu.Elements.Spins

local IDs = require(Shared.Data.IDs)

local Fusion = require(Packages.Fusion)
local Future = require(Packages.Future)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

local function match(t, c)
	for i, v in t do
		if c(i, v) then
			return i, v
		end
	end

	return nil
end

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)

	scope:Hydrate(ShopButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(ShopMenu)
		end,
	})

	scope:Hydrate(CloseButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(ShopMenu)
		end,
	})

	--Gamepasses
	for i, v in Gamepasses.Middle:GetChildren() do
		if not v:IsA("ImageButton") then
			continue
		end

		local ID, GamepassData = match(IDs.Gamepasses, function(ind, val)
			return val.Name == v.Name
		end)

		if not GamepassData then
			warn("No gamepass data found for ", v.Name)
			continue
		end

		local GamepassRobloxInfo = Future.new(function()
			return MarketplaceService:GetProductInfo(tonumber(ID), Enum.InfoType.GamePass)
		end):Await() or "n/a"

		local Price = GamepassRobloxInfo.PriceInRobux
		v.Cost.Text = "R$"..Price
		v.Title.Text = GamepassData.Name
		v.Description.Text = GamepassData.Description

		scope:Hydrate(v) {
			[OnEvent "MouseButton1Click"] = function()
				MarketplaceService:PromptGamePassPurchase(LocalPlayer, tonumber(ID))
			end
		}
	end

	--Coins
	for i, v in Products.Middle:GetChildren() do
		if not v:IsA("ImageButton") then
			continue
		end

		local ID, ProductData = match(IDs.Products, function(ind, val)
			return val.Name == v.Name
		end)

		if not ProductData then
			warn("No product data found for ", v.Name)
			continue
		end

		local GamepassRobloxInfo = Future.new(function()
			return MarketplaceService:GetProductInfo(tonumber(ID), Enum.InfoType.Product)
		end):Await()

		local Price = GamepassRobloxInfo.PriceInRobux or "n/a"
		v.Cost.Text = "R$"..(Price)
		v.Title.Text = ProductData.Name

		scope:Hydrate(v) {
			[OnEvent "MouseButton1Click"] = function()
				MarketplaceService:PromptProductPurchase(LocalPlayer, tonumber(ID))
			end
		}
	end

	--Spins
	for i, v in Spins.Middle:GetChildren() do
		if not v:IsA("ImageButton") then
			continue
		end

		local ID, ProductData = match(IDs.Products, function(ind, val)
			return val.Name == v.Name
		end)

		if not ProductData then
			warn("No product data found for ", v.Name)
			continue
		end

		local GamepassRobloxInfo = Future.new(function()
			return MarketplaceService:GetProductInfo(tonumber(ID), Enum.InfoType.Product)
		end):Await()

		local Price = GamepassRobloxInfo.PriceInRobux or "n/a"
		v.Cost.Text = "R$"..(Price)
		v.Title.Text = ProductData.Name

		scope:Hydrate(v) {
			[OnEvent "MouseButton1Click"] = function()
				MarketplaceService:PromptProductPurchase(LocalPlayer, tonumber(ID))
			end
		}
	end
end

return Controller
