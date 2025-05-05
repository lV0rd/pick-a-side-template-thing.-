local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Source = ReplicatedStorage:WaitForChild("Source")

local Signals = Source:WaitForChild("Events")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local Menus = Canvas.Menus

local Right = Frames.Right
local Left = Frames.Left
local Top = Right.Top

local DanceButton = Left.Buttons.Dances
local DanceMenu = Menus.Dances
local CloseButton = DanceMenu.Close

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek
local OnEvent = Fusion.OnEvent

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)

	scope:Hydrate(DanceButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(DanceMenu)
		end,
	})

	scope:Hydrate(CloseButton) {
		[OnEvent("Activated")] = function()
			GuiController:Toggle(DanceMenu)
		end,
	}
end

return Controller
