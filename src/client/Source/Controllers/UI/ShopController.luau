local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")

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

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

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
end

return Controller
