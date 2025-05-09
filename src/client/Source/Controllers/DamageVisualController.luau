local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Controller = {
	Name = script.Name,
}

local Connections = {} :: { [Player]: { RBXScriptConnection? } }

local TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true)

function InitPlayer(Player: Player)
	Connections[Player] = {}

	local function Spawn(Character)
		if Connections[Player].Health then
			Connections[Player].Health:Disconnect()
			Connections[Player].Health = nil
		end

		local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

		local Highlight = Instance.new("Highlight")
		Highlight.Name = "DamageVisual"
		Highlight.FillTransparency = 1
		Highlight.OutlineTransparency = 1
		Highlight.Parent = Character

		local OldHealth = Humanoid.Health

		Connections[Player].Health = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
			if OldHealth > Humanoid.Health then
				TweenService:Create(Highlight, TweenInfo, {
					FillTransparency = 0,
					OutlineTransparency = 0,
				}):Play()
				OldHealth = Humanoid.Health
			end
		end)
	end

	if Player.Character then
		Spawn(Player.Character)
	end

	Connections[Player].Spawn = Player.CharacterAdded:Connect(Spawn)
end

function Controller.Start()
	for i, Player in pairs(Players:GetPlayers()) do
		InitPlayer(Player)
	end

	Players.PlayerAdded:Connect(function(Player)
		InitPlayer(Player)
	end)

	Players.PlayerRemoving:Connect(function(Player)
		if Connections[Player] then
			for _, Connection in Connections[Player] do
				if Connection then
					Connection:Disconnect()
				end
			end
			Connections[Player] = nil
		end
	end)
end

return Controller
