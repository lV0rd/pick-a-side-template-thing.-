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
local Top = Right.Top

local SpinButton = Top.Spin
local SpinMenu = Menus.Spin
local CloseButton = SpinMenu.Close

local Wheel = SpinMenu.Wheel.Wheel

local Info = SpinMenu.Info
local AmountText = Info.Amount.Amount

local SpinActivate = Info.Main.Spin

local DataReplication = require(Signals.Data)
local SpinFuncion = require(Shared.Functions.Spin)
local Rewards = require(Shared.Data.Rewards)
local SpinRewards = Rewards.Spin

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek
local OnEvent = Fusion.OnEvent

local IsSpinning = false

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)
	local SpinsValue = LocalPlayer:WaitForChild("Spins")

	local Spins = scope:Value(SpinsValue.Value)

	SpinsValue.Changed:Connect(function()
		Spins:set(SpinsValue.Value)
	end)

	scope:Hydrate(SpinButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(SpinMenu)
		end,
	})

	scope:Hydrate(CloseButton) {
		[OnEvent("Activated")] = function()
			GuiController:Toggle(SpinMenu)
		end,
	}

	scope:Hydrate(AmountText)({
		Text = Spins,
	})

	scope:Hydrate(SpinActivate)({
		[OnEvent("Activated")] = function()
			if IsSpinning then
				return
			end

			IsSpinning = true

			local Success, Index = SpinFuncion:Call():Await()

			if not Success then
				IsSpinning = false
				return
			end

			local Reward = SpinRewards[Index]
			local amo = 0
			for i, v in SpinRewards do
				amo += 1
			end

			local Angle = (Index / amo) * 360
			local Spins = math.random(8, 10) * 360
			Angle += (Spins + math.random(-20, 20))

			local Tween = TweenService:Create(Wheel, TweenInfo.new(5, Enum.EasingStyle.Quint) , { Rotation = Angle })

			Tween:Play()
			Tween.Completed:Wait()
			
			--play sound
			--Notifications.ClientNotify(RootGui, "You got : " .. RewardTitles[Index])
--[[
			if RewardTitles[Index]:lower():match("coins") then
				print("yes")
				local c = game.SoundService.Coin:Clone()
				c.Parent = game.SoundService
				c.Volume = 0.8
				c:Play()
				c.Ended:Once(function()
					c:Destroy()
				end)
			end]]

			task.wait(2)

			Wheel.Rotation = 0

			IsSpinning = false
		end,
	})
end

return Controller
