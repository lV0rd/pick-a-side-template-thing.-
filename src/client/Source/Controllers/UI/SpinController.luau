local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Source = ReplicatedStorage:WaitForChild("Source")

local ReplicaClient = require(Source.Modules.ReplicaClient)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local Menus = Canvas.Menus

local Right = Frames.Right
local Top = Right.Top

local SpinButton = Top.Spin
local SpinMenu = Menus.Spin
local CloseButton = SpinMenu.Close

local Wheel = SpinMenu.Wheel.Wheel

local Info = SpinMenu.Info
local AmountText = Info.Amount.Amount

local SpinActivate = Info.Main.Spin
local ThreeDWheel = workspace.Wheel :: Model

local SpinFuncion = require(Shared.Functions.Spin)
local Rewards = require(Shared.Data.Rewards)
local SpinRewards = Rewards.Spin

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent
local peek = Fusion.peek

local IsSpinning = false

function InitSpinRewards()
	for i, v in Wheel.Slices:GetChildren() do
		if not v:IsA("Frame") then
			continue
		end

		local Reward = SpinRewards[tonumber(v.Name)]

		local Name = Reward.Name
		local Image = Reward.Image

		v.ImageLabel.Image = Image
		v.TextLabel.Text = Name
	end
end

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)
	local DataController = require(Source.Controllers.DataController)

	local ReplicateData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica

	local Spins = scope:Value(ReplicateData.Data.Spins)

	ReplicateData:OnSet({ "Spins" }, function(new, old)
		Spins:set(new)
	end)

	scope:Hydrate(SpinButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(SpinMenu)
		end,
	})

	scope:Hydrate(CloseButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(SpinMenu)
		end,
	})

	scope:Hydrate(AmountText)({
		Text = Spins,
	})

	scope:Hydrate(SpinActivate)({
		[OnEvent("Activated")] = function()
			if peek(Spins) <= 0 then
				return
			end

			if IsSpinning then
				return
			end

			IsSpinning = true

			local Success, Index = SpinFuncion:Call():Await()

			if not Success then
				IsSpinning = false
				return
			end

			local amo = 1
			for i, v in SpinRewards do
				amo += 1
			end
			local segmentAngle = 360 / amo
			local baseAngle = (Index - 1) * segmentAngle
			local centerOffset = segmentAngle / 2
			local Angle = baseAngle + centerOffset

			local Spins = math.random(8, 10) * 360
			Angle += Spins

			local Tween = TweenService:Create(Wheel, TweenInfo.new(6, Enum.EasingStyle.Quint), { Rotation = Angle })

			Tween:Play()
			Tween.Completed:Wait()

			GuiController:Notify(
				"You got : "
					.. SpinRewards[Index].Name
					.. " for a chance of "
					.. (SpinRewards[Index].Chance * 100)
					.. "%!"
			)

			task.wait(2)

			Wheel.Rotation = 0

			IsSpinning = false
		end,
	})

	InitSpinRewards()

	local Debounce = tick()
	local Opened = false

	RunService.PostSimulation:Connect(function()
		if tick() - Debounce < 0.2 then
			return
		end

		Debounce = tick()

		local Character = LocalPlayer.Character
		if not Character then
			if GuiController.States.CurrentOpenMenu == SpinMenu then
				GuiController:Toggle(SpinMenu)
			end
			return
		end

		local Distance = (Character:GetPivot().Position - ThreeDWheel:GetPivot().Position).Magnitude
		if Distance <= 15 then
			if not GuiController.States.CurrentOpenMenu then
				if not Opened then
					Opened = true
					GuiController:Toggle(SpinMenu)
				end
			end
		else
			if Opened then
				Opened = false
				GuiController:Toggle(SpinMenu)
			end
		end
	end)
end

return Controller
