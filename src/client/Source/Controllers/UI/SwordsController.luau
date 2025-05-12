local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Source = ReplicatedStorage:WaitForChild("Source")

local Events = Shared.Events

local DataController = require(Source.Controllers.DataController)
local ReplicaClient = require(Source.Modules.ReplicaClient)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local Menus = Canvas.Menus

local Left = Frames.Left

local SwordsButton = Left.Buttons.Swords
local SwordsMenu = Menus.Swords
local CloseButton = SwordsMenu.Close

local Equip = require(Events.Equip):Client()

local Swords = require(Shared.Data.Swords)
local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)
	local PlayerData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica

	local Values = {}
	local Equipped = scope:Value("")
	local Coins = scope:Value(0)

	for i, v in PlayerData.Data.Swords do
		Values[i] = scope:Value(v)
	end

	Equipped:set(PlayerData.Data.EquippedSword)
	Coins:set(PlayerData.Data.Coins)

	PlayerData:OnSet({ "Coins" }, function(new, old)
		Coins:set(PlayerData.Data.Coins)
	end)

	PlayerData:OnChange(function(type, path, index: number, id: string)
		if path[1] == "Swords" then
			if type == "Set" then
				for i, v in PlayerData.Data.Swords do
					if Values[i] then
						Values[i]:set(v)
					else
						Values[i] = scope:Value(v)
					end
				end
			end
		end
	end)

	PlayerData:OnSet({ "EquippedSword" }, function(new, old)
		Equipped:set(PlayerData.Data.EquippedSword)
	end)

	scope:Hydrate(SwordsButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(SwordsMenu)
		end,
	})

	scope:Hydrate(CloseButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(SwordsMenu)
		end,
	})

	scope:Hydrate(SwordsMenu.Elements)({

		[Children] = {
			scope:ForPairs(Swords, function(use, scope, ind, SwordData)
				return scope:New("TextButton")({
					Parent = SwordsMenu.Elements,
					Name = SwordData.Name,
					Size = UDim2.fromScale(0.2, 0.15),
					Position = UDim2.fromScale(0, 0),
					BackgroundColor3 = Color3.fromRGB(32, 212, 101),
					Text = "",

					LayoutOrder = SwordData.Order,

					[Children] = {
						scope:New("UICorner")({
							CornerRadius = UDim.new(0.2, 0),
						}),

						scope:New("TextLabel")({
							Name = "SwordName",
							Text = SwordData.Name,
							Size = UDim2.fromScale(1, 0.6),
							BackgroundTransparency = 1,
							TextScaled = true,
						}),

						scope:New("TextLabel")({
							Name = "SwordPrice",
							TextScaled = true,
							Text = scope:Computed(function(use)
								local Index = use(Values[ind])

								if Index == nil then
									return "NaN"
								end

								if use(Equipped) == ind then
									return "Equipped"
								elseif Index == true then
									return "Equip"
								else
									return "Not Owned"
								end
							end),

							Size = UDim2.fromScale(1, 0.3),
							Position = UDim2.fromScale(0, 0.7),
							BackgroundTransparency = 1,
						}),
					},

					[OnEvent("MouseButton1Click")] = function()
						if PlayerData.Data.Swords[ind] then
							Equip:Fire("Sword", ind)
						end
					end,
				})
			end),
		},
	})
end

return Controller
