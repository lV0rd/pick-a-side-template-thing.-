local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RootGui = PlayerGui.RootGui
local Canvas = RootGui.Canvas

local Frames = Canvas.Frames
local Timer = Frames.Timer

local StatusText = Timer.Status :: TextLabel
local TimerFrame = Timer.Timer :: Frame
local BarFrame = TimerFrame.Bar :: Frame

local DataController = require(Source.Controllers.DataController)
local ReplicaClient = require(Source.Modules.ReplicaClient)

local Settings = require(Shared.Data.Settings)

local Fusion = require(Packages.Fusion)
local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek

local Status = scope:Value("Intermission")
local CalculatedTime = scope:Value(0)
local Visible = scope:Value(false)
local BarVisible = scope:Value(true)

local CurrentStatusTime

function Controller.Start()
	local GameData = DataController:GetGameDataAsync() :: ReplicaClient.Replica

	local Time = 0

	GameData:OnSet({ "Status" }, function()
		Status:set(GameData.Data.Status)
		if string.match(peek(Status), "Intermission") then
			CurrentStatusTime = Settings.INTERMISSION_TIME
		elseif string.match(peek(Status), "Vote") then
			CurrentStatusTime = Settings.VOTING_TIME
		elseif string.match(peek(Status), "Fight") then
			CurrentStatusTime = Settings.FIGHTING_TIME
		else
			CurrentStatusTime = nil
		end

		BarFrame.Size = UDim2.fromScale(1, 1)
	end)

	GameData:OnSet({ "Time" }, function()
		Time = GameData.Data.Time
	end)

	GameData:OnSet({ "Visible" }, function()
		Visible:set(GameData.Data.Visible)
	end)

	GameData:OnSet({ "BarVisible" }, function()
		BarVisible:set(GameData.Data.BarVisible)
	end)

	scope:Hydrate(StatusText)({
		Text = Status,
	})

	scope:Hydrate(BarFrame)({
		Size = scope:Tween(
			scope:Computed(function(use)
				if use(CalculatedTime) >= 0 then
					return UDim2.fromScale(use(CalculatedTime), 1)
				end

				return UDim2.fromScale(1, 1)
			end),
			TweenInfo.new(0.05)
		),
	})

	scope:Hydrate(TimerFrame)({
		Visible = BarVisible,
	})

	scope:Hydrate(Timer)({
		Visible = Visible,
	})

	RunService.PreRender:Connect(function()
		if CurrentStatusTime and Time > 0 then
			local currentTime = workspace:GetServerTimeNow()
			local elapsed = currentTime - Time
			CalculatedTime:set(math.clamp(elapsed / CurrentStatusTime, 0, 1))
		else
			CalculatedTime:set(-1)
		end
	end)
end

return Controller
