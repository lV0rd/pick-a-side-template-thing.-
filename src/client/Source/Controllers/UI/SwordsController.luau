local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Source = ReplicatedStorage:WaitForChild("Source")

local DataController = require(Source.Controllers.DataController)
local ReplicaClient = require(Source.Modules.ReplicaClient)

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local Menus = Canvas.Menus

local Left = Frames.Left

local SwordsButton = Left.Buttons.Swords
local SwordsMenu = Menus.Swords
local CloseButton = SwordsMenu.Close

local Swords = require(Shared.Data.Swords)
local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

function InitButtons()
	for Name, SwordData in Swords do
		local Button = Instance.new("TextButton")
		Button.Name = Name
		Button.Text = Name

		Button.Parent = SwordsMenu.Elements

		scope:Hydrate(Button) {
			[OnEvent("Activated")] = function()
				
			end,
		}
	end
end

function UpdateButtons(PlayerData: ReplicaClient.Replica)
	local SwordsData = PlayerData.Data.Emotes

	for _, Button in SwordsMenu.Elements:GetChildren() do
		if not Button:IsA("GuiButton") then
			continue
		end

		local SwordName = Button.Name
		local SwordData = SwordsData[SwordName]

		if SwordData then
			Button.Visible = true
		else
			Button.Visible = false
		end
	end
end

function Controller.Start()
	local GuiController = require(Source.Controllers.GuiController)
	local PlayerData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
	InitButtons()

	PlayerData:OnSet({ "Swords" }, UpdateButtons(PlayerData))
	UpdateButtons(PlayerData)

	scope:Hydrate(SwordsButton)({
		[OnEvent("Activated")] = function()
			GuiController:Toggle(SwordsMenu)
		end,
	})

	scope:Hydrate(CloseButton) {
		[OnEvent("Activated")] = function()
			GuiController:Toggle(SwordsMenu)
		end,
	}
end

return Controller
