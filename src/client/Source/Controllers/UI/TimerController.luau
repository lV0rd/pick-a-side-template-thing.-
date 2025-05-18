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
local TimeFinal = scope:Value(0)

function Controller.Start()
	local GameData = DataController:GetGameDataAsync() :: ReplicaClient.Replica

	local Time = 0

	GameData:OnSet({ "Status" }, function()
		Status:set(GameData.Data.Status)
		BarFrame.Size = UDim2.fromScale(0, 0)
	end)

	GameData:OnSet({ "Time" }, function()
		Time = GameData.Data.Time
	end)

	GameData:OnSet({ "Visible" }, function()
		Visible:set(GameData.Data.Visible)
	end)

	GameData:OnSet({ "TimeFinal" }, function()
		TimeFinal:set(GameData.Data.TimeFinal)
	end)

	scope:Hydrate(StatusText)({
		Text = Status,
	})

	scope:Hydrate(BarFrame)({
		Size = scope:Computed(function(use)
			if use(CalculatedTime) >= 0 then
				return UDim2.fromScale(use(CalculatedTime), 1)
			end

			return UDim2.fromScale(0, 0)
		end),
	})

	scope:Hydrate(TimerFrame)({
		Visible = scope:Computed(function(use)
			if use(CalculatedTime) <= 0 then
				return false
			else
				return true
			end
		end),
	})

	scope:Hydrate(Timer)({
		Visible = Visible,
	})

	RunService.RenderStepped:Connect(function()
		if peek(TimeFinal) and Time > 0 then
			local currentTime = workspace:GetServerTimeNow()
			local remainingDuration = peek(TimeFinal) - Time

			if remainingDuration > 0  then
				local elapsed = currentTime - Time
				local progress = math.clamp(elapsed / remainingDuration, 0, 1)
				CalculatedTime:set(progress < 1 and progress or -1)
			else
				CalculatedTime:set(-1)
			end
		else
			CalculatedTime:set(-1)
		end
	end)
end

return Controller
