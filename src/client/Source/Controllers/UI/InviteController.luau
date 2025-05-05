local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
local Top = Right.Top

local InviteButton = Frames.Left.Buttons.Invite

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek
local OnEvent = Fusion.OnEvent

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)

	scope:Hydrate(InviteButton)({
		[OnEvent("Activated")] = function()
			SocialService:PromptGameInvite(LocalPlayer)
		end,
	})
end

return Controller
