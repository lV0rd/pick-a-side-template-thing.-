local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Events = Shared.Events

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local CodesMenu = Canvas.Menus.Codes

local CloseButton = CodesMenu.Close
local CodesButton = Frames.Right.Top.Codes :: TextButton
local Redeem = CodesMenu.Redeem :: TextBox

local Fusion = require(Packages.Fusion)

local CodeRedeem = require(Events.Codes):Client()

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

function Controller.Start()
    local GuiController = require(Controllers.GuiController)

    scope:Hydrate(CodesButton) {
        [OnEvent "MouseButton1Click"] = function()
            GuiController:Toggle(CodesMenu)
        end,
    }

    scope:Hydrate(CloseButton) {
        [OnEvent "MouseButton1Click"] = function()
            GuiController:Toggle(CodesMenu)
        end
    }

    scope:Hydrate(Redeem) {
        [OnEvent "FocusLost"] = function(EnterPressed)
            if not EnterPressed then
                return
            end

            CodeRedeem:Fire(Redeem.Text)
        end
    }
end

return Controller
