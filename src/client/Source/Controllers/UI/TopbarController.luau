local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Functions = Shared.Functions

local Controllers = Source.Controllers
local Modules = Source.Modules

local peek = require(ReplicatedStorage.Packages.Fusion.State.peek)
local DataController = require(Controllers.DataController)
local ReplicaClient = require(Modules.ReplicaClient)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RootGui = PlayerGui.RootGui
local Canvas = RootGui.Canvas

local Menus = Canvas.Menus
local DailyMenu = Menus.Daily

local Elements = DailyMenu.Main
local CloseButton = DailyMenu.Close
local TimerFrame = DailyMenu.Timer
local ClaimButton = DailyMenu.Claim

local Icon = require(Packages.Icon)
local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local Rewards = require(Shared.Data.Rewards)

local Claim = require(Functions.Daily)

local HOURS_24 = 3600 * 24

function format(int)
	return string.format("%02i", int)
end

function toDHMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60

	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60

	local Days = (Hours - Hours % 24) / 24
	Hours = Hours - Days * 24

	return format(Days) .. ":" .. format(Hours) .. ":" .. format(Minutes) .. ":" .. format(Seconds)
end

function Controller.Start()
	local GuiController = require(Controllers.GuiController)

	local PlayerData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
	local Data = PlayerData.Data

	local DayStreak = scope:Value(Data.DayStreak)
	local LastDay = scope:Value(Data.LastDay)

	local TimeLeft = scope:Value(0)

	PlayerData:OnSet({ "DayStreak" }, function()
		DayStreak:set(Data.DayStreak)
	end)

	PlayerData:OnSet({ "LastDay" }, function()
		LastDay:set(Data.LastDay)
	end)

	local DailyButton = Icon.new()

	DailyButton:setImage(17101746619)

	DailyButton:bindEvent("selected", function()
		GuiController:Toggle(DailyMenu)
	end)

	scope:Hydrate(ClaimButton)({
		[OnEvent("MouseButton1Click")] = function()
			Claim:Call()
		end,

		Visible = scope:Computed(function(use)
			local now = workspace:GetServerTimeNow()
			local TimeDiffirence = now - use(LastDay)

			return TimeDiffirence > HOURS_24
		end),
	})

	scope:Hydrate(CloseButton)({
		[OnEvent("MouseButton1Click")] = function()
			GuiController:Toggle(DailyMenu)
		end,
	})

	scope:Hydrate(TimerFrame)({
		Visible = scope:Computed(function(use)
			local now = workspace:GetServerTimeNow()
			local TimeDiffirence = now - use(LastDay)

			return TimeDiffirence <= HOURS_24
		end),
	})

	scope:Hydrate(TimerFrame.Time)({
		Text = TimeLeft,
	})

	scope:Hydrate(Elements)({
		[Children] = {
			scope:ForPairs(Rewards.Daily, function(use, scope, ind, RewardData)
				return scope:New("Frame")({
					LayoutOrder = ind,
					Parent = Elements,
					Name = RewardData.Name,
					BackgroundColor3 = Color3.fromRGB(32, 212, 101),

					[Children] = {
						scope:New("UICorner")({
							CornerRadius = UDim.new(0.2, 0),
						}),

						scope:New("ImageLabel")({
							Name = "DanceName",
							Image = RewardData.Image,
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
						}),

						scope:New("TextLabel")({
							Name = "Title",
							TextScaled = true,
							Text = RewardData.Title,
							Size = UDim2.fromScale(1, 0.3),
							Position = UDim2.fromScale(0, 0.7),
							BackgroundTransparency = 1,
						}),

						scope:New("Frame")({
							Name = "Claimed",
							Size = UDim2.fromScale(1, 1),
							BackgroundColor3 = Color3.new(0, 0, 0),
							BackgroundTransparency = scope:Computed(function(use)
								if ind < use(DayStreak) then
									return 0.5
								else
									return 1
								end
							end),
						}),
					},
				})
			end),
		},
	})

	RunService.PostSimulation:Connect(function()
		local now = workspace:GetServerTimeNow()

		TimeLeft:set(toDHMS(HOURS_24 - (now - peek(LastDay))))
	end)

	GuiController:Toggle(DailyMenu)
end

return Controller
