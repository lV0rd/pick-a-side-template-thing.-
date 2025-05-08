local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Source = ReplicatedStorage:WaitForChild("Source")

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local Menus = Canvas.Menus

local Right = Frames.Right
local Middle = Right.Middle

local GiftsButton = Middle.Rewards
local GiftsMenu = Menus.Gifts
local GiftsClose = GiftsMenu.Close

local GiftNotification = GiftsButton.Notification
local GiftTimer = GiftsButton.Time

local Elements = GiftsMenu.Gifts.Elements.Frame

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

local Start = workspace:GetServerTimeNow()

local Rewards = require(Shared.Data.Rewards)

local GiftsFunction = require(Shared.Functions.Gifts)

local Template = ReplicatedStorage.Assets.Gui.GiftFrame

local Claimed = {}
local Claimable = {}

local Connection

local function toMS(s)
	return string.format("%02i:%02i", s / 60, s % 60)
end

function ClaimReward(Name, Button)
	local Index = tonumber(Name)

	if not Claimable[Index] then
		return
	end

	if Claimed[Index] then
		return
	end

	local Rewarded, Message = GiftsFunction:Call(Index)

	if not Rewarded then
		print("Error: " .. Message)
		return
	end

	Claimable[Index] = nil

	Button.Claimed.Visible = true
	Claimed[Index] = true
end

function InitRewards()
	for i, v in Rewards.Gifts do
		local newFrame = Template:Clone()
		newFrame.Name = i
		local Button = newFrame.TextButton
		local Image = Button.ImageLabel
		local Timer = Button.Timer
		local Title = Button.Title

		Title.Text = v.Title
		Image.Image = v.Image
		Timer.Text = toMS(v.Time)
		newFrame.Parent = Elements
	end
end

function StartRewards()
	for i, v in Elements:GetChildren() do
		if not v:IsA("Frame") then
			continue
		end
		local Button = v.TextButton

		scope:Hydrate(Button)({
			[OnEvent("Activated")] = function()
				ClaimReward(v.Name, Button)
			end,
		})
	end
end

function UpdateUi()
	local Latest = nil
	for i, v in Elements:GetChildren() do
		if not v:IsA("Frame") then
			continue
		end

		local Index = tonumber(v.Name)

		local Button = v.TextButton
		local Timer = Button.Timer

		

		local Info = Rewards.Gifts[Index]

		if Claimed[Index] then
			Timer.Text = "Claimed!"
			continue
		end

		if Claimable[Index] then
			Timer.Text = "Claim!"
			continue
		end

		local now = workspace:GetServerTimeNow()
		local StartTime = LocalPlayer:GetAttribute("StartTime") or Start
		local TimeLeft = math.clamp(Info.Time - (now - StartTime), 0, Info.Time)
		
		if TimeLeft <= 0 then
			Claimable[Index] = true
		end

		if not Latest then
			if Timer.Text ~= "Claim!" and Timer.Text ~= "Claimed!" and Timer.Text ~= "XX:XX" then
				Latest = TimeLeft
			end
		end
		
		Timer.Text = toMS(TimeLeft)
	end

	NotifyUi(Latest)
end

function NotifyUi(Latest)
	--wip
	local ClaimableSize = 0
	for i, v in Claimable do
		ClaimableSize += 1
	end

	local ClaimedSize = 0
	for i, v in Claimed do
		ClaimedSize += 1
	end

	local RewardsSize = 0
	for i, v in Rewards.Gifts do
		RewardsSize += 1
	end

	GiftNotification.Visible = (ClaimableSize > 0)

	if ClaimedSize == RewardsSize then
		GiftTimer.Text = "Claimed!"
		GiftsButton.Icon.Visible = false
		Connection:Disconnect()
		Connection = nil
	else
		GiftTimer.Text = GiftNotification.Visible and "Claim" or (Latest and Latest > 0) and toMS(Latest) or "Claim!"
	end
end

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)

	scope:Hydrate(GiftsButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(GiftsMenu)
		end,
	})

	scope:Hydrate(GiftsClose)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(GiftsMenu)
		end,
	})

	InitRewards()
	StartRewards()
	Connection = RunService.PostSimulation:Connect(UpdateUi)
end

return Controller
