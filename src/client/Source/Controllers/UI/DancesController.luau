local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Dances = require(Shared.Data.Dances)

local DataController = require(Source.Controllers.DataController)
local ReplicaClient = require(Source.Modules.ReplicaClient)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local Menus = Canvas.Menus

local Left = Frames.Left

local DanceButton = Left.Buttons.Dances
local DanceMenu = Menus.Dances
local CloseButton = DanceMenu.Close

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

local Values = {}
local Equipped = scope:Value("")
local Coins = scope:Value(0)

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)
	local PlayerData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica

	for i, v in PlayerData.Data.Emotes do
		Values[i] = scope:Value(v)
	end

	Equipped:set(PlayerData.Data.EquippedEmote)
	Coins:set(PlayerData.Data.Coins)

	PlayerData:OnSet({ "Coins" }, function()
		Coins:set(PlayerData.Data.Coins)
	end)

	PlayerData:OnSet({ "Emotes" }, function()
		for i, v in PlayerData.Data.Emotes do
			Values[i] = scope:Value(v)
		end
	end)

	PlayerData:OnSet({ "EquippedEmote" }, function()
		Equipped:set(PlayerData.Data.EquippedEmote)
	end)

	scope:Hydrate(DanceButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(DanceMenu)
		end,
	})

	scope:Hydrate(CloseButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(DanceMenu)
		end,
	})

	scope:Hydrate(DanceMenu.Elements)({

		[Children] = {

			scope:ForPairs(Dances, function(use, scope, ind, DanceData)
				return scope:New("TextButton")({
					Parent = DanceMenu.Elements,
					Name = DanceData.Name,
					Size = UDim2.fromScale(0.2, 0.15),
					Position = UDim2.fromScale(0, 0),
					BackgroundColor3 = Color3.fromRGB(32, 212, 101),
					Text = DanceData.Name,

					[Children] = {
						scope:New "UICorner" {
							CornerRadius = UDim.new(.2, 0)
						},

						scope:New("TextLabel")({
							Name = "DanceName",
							Text = DanceData.Name,
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
						}),

						scope:New("TextLabel")({
							Name = "DancePrice",
							Text = scope:Computed(function(use)
								local Index = Values[DanceData.Name]

								if not Index then
									return "NaN"
								end

								if use(Equipped) == DanceData.Name then
									return "Equipped"
								else
									if DanceData.Currency == "Robux" then
										if use(Index) then
											return "Equip"
										else
											local Success, Info = pcall(function()
												return MarketplaceService:GetProductInfo(DanceData.ID)
											end)

											if Success then
												return "Buy " .. Info.PriceInRobux .. "\u{E002}"
											else
												return "Buy"
											end
										end
									elseif DanceData.Currency == "Coins" then
										if use(Index) then
											return "Equip"
										else
											return "Buy: " .. DanceData.Price
										end
									else
										if use(Index) then
											return "Equip"
										end
									end
								end

								return "NaN"
							end),

							Size = UDim2.fromScale(1, 0.3),
							Position = UDim2.fromScale(0, 0.7),
							BackgroundTransparency = 1,
						}),
					},

					[OnEvent("MouseButton1Click")] = function()
						print("Click")
					end,
				})
			end),
		},
	})
end

return Controller
