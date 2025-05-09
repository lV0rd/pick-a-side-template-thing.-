local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")
local Modules = Source:WaitForChild("Modules")

local DataController = require(Controllers.DataController)
local ReplicaClient = require(Modules.ReplicaClient)

local Packages = ReplicatedStorage:WaitForChild("Packages")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local ShopMenu = Canvas.Menus.Shop

local CoinsButton = Frames.Left.Coins.Button

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek
local OnEvent = Fusion.OnEvent

function Controller.Start()
	local GuiController = require(Controllers.GuiController)
	local ReplicaData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
	local CoinsValue = scope:Value(ReplicaData.Data.Coins)

	local Swing = scope:Value(false)

	ReplicaData:OnSet({ "Coins" }, function(new, old)
		CoinsValue:set(new)
		if new > old then
			if peek(Swing) then
				return
			end

			Swing:set(true)
			task.delay(.1, function()
				Swing:set(false)
			end)
		end
	end)

	scope:Hydrate(CoinsButton.Amount)({
		Text = CoinsValue,
	})

	scope:Hydrate(CoinsButton)({
		Rotation = scope:Spring(scope:Computed(function(use)
			return use(Swing) and -10 or 0
		end), 50, .4),

		[OnEvent("MouseButton1Click")] = function()
			GuiController:Toggle(ShopMenu)
		end,
	})
end

return Controller
