local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Controller = {
	Name = script.Name,

	States = {
		CurrentOpenMenu = nil,
	},
}

local Sounds = SoundService.UI

local Camera = workspace.CurrentCamera
local Blur = Lighting:FindFirstChild("Blur") or Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local Notify = require(Events.Notify):Client()

local Spr = require(Packages.spr)

local Assets = ReplicatedStorage:WaitForChild("Assets")
local Gui = Assets.Gui
local NotificationTemplate = Gui.Notification :: TextLabel

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local RootGui = PlayerGui.RootGui

local Notifications = RootGui.Notifications :: Frame

function open(Frame: Frame)
	Spr.stop(Frame)
	Frame.Position = UDim2.fromScale(0.5, 0.55)
	Frame.Visible = true

	Spr.target(Frame, 1, 4, {
		Position = UDim2.fromScale(0.5, 0.5),
	})
	Spr.target(Camera, 0.7, 4, {
		FieldOfView = 63,
	})
	Spr.target(Blur, 0.7, 4, {
		Size = 24,
	})
end

function close(Frame: Frame)
	Frame.Visible = false

	Spr.target(Camera, 0.7, 4, {
		FieldOfView = 70,
	})
	Spr.target(Blur, 0.7, 4, {
		Size = 0,
	})
end

function Controller:Toggle(Frame)
	if Controller.States.CurrentOpenMenu == nil then
		Controller.States.CurrentOpenMenu = Frame
		open(Frame)
	else
		if Controller.States.CurrentOpenMenu == Frame then
			close(Controller.States.CurrentOpenMenu)
			Controller.States.CurrentOpenMenu = nil
			return
		end
		close(Controller.States.CurrentOpenMenu)
		Controller.States.CurrentOpenMenu = Frame
		open(Frame)
	end
end

function Controller:Notify(Message, WaitTime)
	local New = NotificationTemplate:Clone()
	local OldSize = New.Size

	New.Text = Message
	New.Size = UDim2.fromScale(1, 0)
	New.Parent = Notifications
	Sounds.Notification:Play()

	Spr.target(New, 0.5, 5, { Size = OldSize })
	Spr.completed(New, function()
		Debris:AddItem(New, WaitTime or 5)
	end)
end

function Controller.Start()
	if Controller.States.CurrentOpenMenu then
		close(Controller.States.CurrentOpenMenu)
	end

	Notify:On(function(Message)
		Controller:Notify(Message)
	end)
end

return Controller
