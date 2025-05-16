local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Events = Shared:WaitForChild("Events")

local Future = require(ReplicatedStorage.Packages.Future)
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

local Purchase = require(Events.Purchase):Client()
local Equip = require(Events.Equip):Client()

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

local Cache = {}

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)
	local PlayerData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica

	local Values = {}
	local Equipped = scope:Value("")
	local Coins = scope:Value(0)

	for i, v in PlayerData.Data.Emotes do
		Values[i] = scope:Value(v)
	end

	Equipped:set(PlayerData.Data.EquippedEmote)
	Coins:set(PlayerData.Data.Coins)

	PlayerData:OnSet({ "Coins" }, function(new, old)
		Coins:set(PlayerData.Data.Coins)
	end)

	PlayerData:OnChange(function(type, path, index: number, id: string)
		if path[1] == "Emotes" then
			if type == "Set" then
				for i, v in PlayerData.Data.Emotes do
					if Values[i] then
						Values[i]:set(v)
					else
						Values[i] = scope:Value(v)
					end
				end
			end
		end
	end)

	PlayerData:OnSet({ "EquippedEmote" }, function(new, old)
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
					Size = UDim2.fromScale(0.2, 0.15),
					Position = UDim2.fromScale(0, 0),
					BackgroundColor3 = Color3.fromRGB(32, 212, 101),
					Text = "",

					LayoutOrder = DanceData.Order,

					[Children] = {
						scope:New("UICorner")({
							CornerRadius = UDim.new(0.2, 0),
						}),

						scope:New("TextLabel")({
							Text = DanceData.Name,
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							TextScaled = true,
						}),

						scope:New("TextLabel")({
							TextScaled = true,
							Text = scope:Computed(function(use)
								local Index = use(Values[DanceData.Name])

								if Index == nil then
									return "NaN"
								end

								if use(Equipped) == DanceData.Name then
									return "Equipped"
								elseif DanceData.Currency == "Robux" then
									if Index then
										return "Equip"
									else
										local Info

										if Cache[Index] then
											Info = Cache[Index]
										else
											Cache[Index] = Future.new(function()
												return MarketplaceService:GetProductInfo(DanceData.ID, Enum.InfoType.GamePass)
											end):Await()

											Info = Cache[Index]
										end
									
										if Info then
											return "Buy " ..( Info.PriceInRobux or "0" ).. "\u{E002}"
										else
											return "Buy"
										end
									end
								elseif DanceData.Currency == "Coins" then
									if Index then
										return "Equip"
									else
										return "Buy: " .. DanceData.Price
									end
								else
									if Index then
										return "Equip"
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
						if PlayerData.Data.Emotes[DanceData.Name] then
							Equip:Fire("Emote", DanceData.Name)
						else
							if DanceData.Currency == "Coins" then
								Purchase:Fire("Emote", DanceData.Name)
							elseif DanceData.Currency == "Robux" then
								MarketplaceService:PromptGamePassPurchase(LocalPlayer, DanceData.ID)
							end
						end
					end,
				})
			end),
		},
	})
end

return Controller
