local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Controller = {
	Name = script.Name,
}

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Events = Shared:WaitForChild("Events")

local Invisible = require(Events.Invisible):Client()

local isInvisible = false
local characterConnections = {}

local LocalPlayer = Players.LocalPlayer

local function setCharacterVisibility(character: Model)
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") or part:IsA("Decal") then
			if part.Name == "HumanoidRootPart" then
				continue
			end

			part.Transparency = isInvisible and 1 or 0
		end
	end
end

local function handleCharacter(player: Player, character: Model)
	setCharacterVisibility(character)
end

local function setupCharacterListener(player: Player)
	if player == LocalPlayer then
		--Local Player Stuff
		return
	end

	local conn = player.CharacterAdded:Connect(function(character)
		handleCharacter(player, character)
	end)

	characterConnections[player] = conn

	if player.Character then
		handleCharacter(player, player.Character)
	end
end

local function cleanupCharacterListener(player: Player)
	local conn = characterConnections[player]
	if conn then
		conn:Disconnect()
		characterConnections[player] = nil
	end
end

function Controller.Start()
	for _, player in ipairs(Players:GetPlayers()) do
		setupCharacterListener(player)
	end

	Players.PlayerAdded:Connect(function(player)
		setupCharacterListener(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		cleanupCharacterListener(player)
	end)

	Invisible:On(function(toggle: boolean)
		isInvisible = toggle

		for _, player in ipairs(Players:GetPlayers()) do
			if player == LocalPlayer then
				continue
			end

			if player.Character then
				handleCharacter(player, player.Character)
			end
		end
	end)
end

return Controller
