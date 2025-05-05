local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
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
local Middle = Right.Middle

local GiftsButton = Middle.Rewards
local GiftsMenu = Menus.Gifts
local GiftsClose = GiftsMenu.Close

local GiftNotification
local GiftTimer

local Elements = GiftsMenu.Gifts.Elements.Frame

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek
local OnEvent = Fusion.OnEvent

local Start = workspace:GetServerTimeNow()

local IDs = require(Shared.Data.IDs)
local Rewards = require(Shared.Data.Rewards)

local GiftsFunction = require(Shared.Functions.Gifts)

local Template = ReplicatedStorage.Assets.Gui.GiftFrame

local Claimed = {}
local Claimable = {}

local function toMS(s)
	return string.format("%02i:%02i", s / 60, s % 60)
end

function ClaimReward(Name, Button)
	local Index = tonumber(Name)
	local RewardInfo = Rewards.Gifts[Index]

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

	Button.Claimed.Visible = true
	Claimed[Index] = true
end

function InitRewards()
	for i, v in Rewards.Gifts do
		local newFrame = Template:Clone()
		newFrame.Name = i
		local Button = newFrame.TextButton
		local Claimed = Button.Claimed
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
		Timer.Text = toMS(TimeLeft)

		if TimeLeft <= 0 then
			Claimable[Index] = true
		end
	end
end

function NotifyUi()
	--wip
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
	RunService.PostSimulation:Connect(UpdateUi)
end

return Controller
