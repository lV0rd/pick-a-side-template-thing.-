local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local Source = ServerStorage.Source
local Services = Source.Services
local Modules = Source.Modules

local ReplicaServer = require(Modules.ReplicaServer)

local PlayerService = require(Services.PlayerService)

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared
local Events = Shared.Events

local Invisible = require(Events.Invisible):Server()

local Settings = require(Shared.Data.Settings)
local Brainrots = require(Shared.Data.Brainrots)

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)

local VotingPlatforms = workspace.Selections

local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Include
Params.FilterDescendantsInstances = { VotingPlatforms }

local BlueTeam: Team = Teams.Blue
local RedTeam: Team = Teams.Red

local Barrier = workspace.Barrier

local Items = ReplicatedStorage.Assets.Items
local Animations = ReplicatedStorage.Assets.Animations

local GameDataReplica = ReplicaServer.New({
	Token = ReplicaServer.Token("GameData"),
	Data = {
		Status = "Intermission",
		Time = 0,
		Visible = false,
		BarVisible = false,
	},
})

GameDataReplica:Replicate()

local Service = {
	Name = script.Name,

	GameData = {
		Started = false,
		Players = {} :: { [Player]: PlayerService.PlayerData },

		Thread = {},

		BlueOption = nil,
		RedOption = nil,

		Status = scope:Value("n/a"),
	},
}

local function getTriangularGridOffset(index: number): Vector3
	local row = math.floor((math.sqrt(8 * index + 1) - 1) / 2)
	local posInRow = index - row * (row + 1) // 2
	local xSpacing, zSpacing = 3, 2.5
	local x = (posInRow - row / 2) * xSpacing
	local z = row * zSpacing
	return Vector3.new(x, 0, z) - Vector3.new(2, 0, 0)
end

function GetQueLenght(): number
	local count = 0
	for i, v in Service.GameData.Players do
		count += 1
	end
	return count
end

function StartIntermission()
	local GameData = Service.GameData

	if GetQueLenght() < Settings.REQUIRED_PLAYERS then
		GameData.Status:set("Not enough players!")
		task.wait(0.1)
		StartIntermission()
		return
	end

	local IntermissionTime = Settings.INTERMISSION_TIME

	GameDataReplica:Set({ "Status" }, "Intermission")
	GameDataReplica:Set({ "Visible" }, true)
	GameDataReplica:Set({ "BarVisible" }, true)

	GameDataReplica:Set({ "Time" }, workspace:GetServerTimeNow())

	while IntermissionTime > 0 do
		IntermissionTime -= 1
		GameData.Status:set("Intermission: " .. IntermissionTime .. " seconds left")
		task.wait(1)

		if GetQueLenght() < Settings.REQUIRED_PLAYERS then
			task.wait(1)
			StartIntermission()
			return
		end
	end

	--Start
	if GetQueLenght() < Settings.REQUIRED_PLAYERS then
		StartIntermission()
		return
	end

	StartGame()
end

function StartGame()
	local GameData = Service.GameData

	GameData.Started = true
	GameDataReplica:Set({ "Time" }, 0)
	GameDataReplica:Set({ "Visible" }, false)

	local BrainrotsLenght = #Brainrots

	GameData.BlueOption = math.random(BrainrotsLenght)
	GameData.RedOption = math.random(BrainrotsLenght)

	while GameData.BlueOption == GameData.RedOption do
		GameData.RedOption = math.random(BrainrotsLenght)
	end

	local RedIndex = Brainrots[GameData.RedOption]
	local BlueIndex = Brainrots[GameData.BlueOption]

	local BlueSound = Instance.new("Sound")
	local RedSound = Instance.new("Sound")
	BlueSound.SoundId = BlueIndex.Sound
	RedSound.SoundId = RedIndex.Sound

	BlueSound.Parent = VotingPlatforms.Blue.Preview
	RedSound.Parent = VotingPlatforms.Red.Preview

	GameData.Status:set(BlueIndex.Name)
	VotingPlatforms.Blue.Preview.ScreenGui.ImageLabel.Image = BlueIndex.Image
	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Text = BlueIndex.Name
	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Visible = true

	BlueSound:Play()
	task.wait(Settings.TIME_BETWEEN_PREVIEW)
	BlueSound:Stop()

	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Visible = false
	VotingPlatforms.Blue.Preview.ScreenGui.ImageLabel.Visible = false

	task.wait(0.5)
	GameData.Status:set(RedIndex.Name)
	VotingPlatforms.Red.Preview.ScreenGui.ImageLabel.Image = RedIndex.Image
	VotingPlatforms.Red.Preview.ScreenGui.TextLabel.Text = RedIndex.Name
	VotingPlatforms.Red.Preview.ScreenGui.TextLabel.Visible = true

	RedSound:Play()
	task.wait(Settings.TIME_BETWEEN_PREVIEW)
	RedSound:Stop()
	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Visible = true
	VotingPlatforms.Blue.Preview.ScreenGui.ImageLabel.Visible = true

	GameData.Status:set("Select a meme!")
	BlueSound:Destroy()
	RedSound:Destroy()
	Barrier.CanCollide = false
	Invisible:FireAll(true)

	local voting_conn
	local votes = { blue = {}, red = {} }

	voting_conn = RunService.PostSimulation:Connect(function()
		for player: Player, playerData in GameData.Players do
			if player:GetAttribute("OptionSelected") then
				continue
			end

			if not player.Parent then
				continue
			end

			local character = player.Character
			if not character then
				continue
			end

			local humanoid = character.Humanoid :: Humanoid

			local hit = workspace:Raycast(character:GetPivot().Position, Vector3.yAxis * -10, Params)

			if hit ~= nil then
				player:SetAttribute("OptionSelected", hit.Instance.Parent.Name)

				if hit.Instance.Parent.Name == "Blue" then
					table.insert(votes.blue, player)
					local index = #votes.blue - 1
					local offset = getTriangularGridOffset(index)

					local basePosition = hit.Instance.Position
					local newPos = basePosition + offset

					local rootPart = character:FindFirstChild("HumanoidRootPart")
					if rootPart then
						humanoid.WalkSpeed = 0
						humanoid.JumpPower = 0
						rootPart.CFrame = CFrame.new(newPos.X, character:GetPivot().Position.Y, newPos.Z)
					end
				else
					table.insert(votes.red, player)
					local index = #votes.red - 1
					local offset = getTriangularGridOffset(index)

					local basePosition = hit.Instance.Position
					local newPos = basePosition + offset

					local rootPart = character:FindFirstChild("HumanoidRootPart")
					if rootPart then
						humanoid.WalkSpeed = 0
						humanoid.JumpPower = 0
						rootPart.CFrame = CFrame.new(newPos.X, character:GetPivot().Position.Y, newPos.Z)
					end
				end
			end
		end
	end)

	GameDataReplica:Set({ "Time" }, workspace:GetServerTimeNow())
	GameDataReplica:Set({ "Status" }, "Vote for your favourite meme!")
	GameDataReplica:Set({ "Visible" }, true)

	local VotingTime = Settings.VOTING_TIME

	while VotingTime > 0 do
		VotingTime -= 1
		GameData.Status:set("Select a meme! " .. VotingTime .. " seconds left")
		task.wait(1)
	end

	Invisible:FireAll(false)
	voting_conn:Disconnect()
	Barrier.CanCollide = true

	GameData.Status:set("Fight!")
	GameDataReplica:Set({ "Status" }, "Fight!")

	local option_a_players = 0
	local option_b_players = 0

	-- count votes, create teams
	for player: Player, playerData in GameData.Players do
		local option_selected = player:GetAttribute("OptionSelected")

		if option_selected ~= nil then
			if option_selected == "Blue" then
				option_a_players += 1
				player.Team = BlueTeam
			else
				option_b_players += 1
				player.Team = RedTeam
			end

			-- give sword
			local character = player.Character
			if not character then
				continue
			end

			local humanoid = character:FindFirstChild("Humanoid") :: Humanoid

			if not humanoid then
				continue
			end

			local Sword = playerData.Profile.Data.EquippedSword

			if Sword == "" then
				Sword = "ClassicSword"
			end

			local Tool = Items:FindFirstChild(Sword)
			if Tool == nil then
				Tool = Items.ClassicSword
			end

			humanoid.WalkSpeed = 16

			Tool:Clone().Parent = player.Backpack

			humanoid.Died:Once(function()
				player.Team = Teams.Lobby
				player.TeamColor = BrickColor.White()
			end)

			local ColorIndicatorClone = ReplicatedStorage.Assets.Gui.ColorIndicator:Clone()
			ColorIndicatorClone.Frame.BackgroundColor3 = player.TeamColor.Color
			ColorIndicatorClone.Parent = character.Head
		else
			local Character = player.Character
			if not Character then
				continue
			end

			local HumanoidRootPart = Character.HumanoidRootPart :: BasePart
			if not (HumanoidRootPart.Position.X < workspace.CheckPart.Position.X) then
				continue
			end
			task.spawn(player.LoadCharacter, player)
			player.Team = Teams.Lobby
		end
	end

	if option_a_players > 0 and option_b_players > 0 then
		GameDataReplica:Set({ "Time" }, workspace:GetServerTimeNow())

		local FightingTime = Settings.FIGHTING_TIME

		while FightingTime > 0 do
			if #BlueTeam:GetPlayers() == 0 or #RedTeam:GetPlayers() == 0 then
				break
			end
			FightingTime -= 1
			GameData.Status:set("Fight! " .. FightingTime .. " seconds left")
			task.wait(1)
		end
	end

	for v: Player, playerData in GameData.Players do
		v.Backpack:ClearAllChildren()

		if v.Character and v.Character:FindFirstChildOfClass("Tool") then
			local tool = v.Character:FindFirstChildOfClass("Tool")
			tool:Destroy()
		end
	end

	option_a_players = #BlueTeam:GetPlayers()
	option_b_players = #RedTeam:GetPlayers()

	-- no winner if tied
	local winner

	if option_a_players ~= option_b_players then
		if option_a_players == 0 then
			winner = RedTeam
		elseif option_b_players == 0 then
			winner = BlueTeam
		end
	end

	print(winner)
	GameDataReplica:Set({ "BarVisible" }, false)
	GameDataReplica:Set({ "Status" }, winner and winner.Name .. " Team Wins!" or "No winner!")
	GameData.Status:set(winner and winner.Name .. " Team Wins!" or "No winner!")

	if winner then
		for i, player in winner:GetPlayers() do
			print("e")
			local PlayerData = GameData.Players[player]
			if not PlayerData then
				continue
			end

			local EquippedEmote = PlayerData.Replica.Data.EquippedEmote

			if EquippedEmote == "" then
				EquippedEmote = "Default"
			end

			PlayerData.Replica:Set({ "Wins" }, PlayerData.Replica.Data.Wins + 1 * PlayerData.LocalData.Data.WinsMultiplier)
			PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + 500 * PlayerData.LocalData.Data.CoinsMultiplier)

			print(PlayerData.Replica)

			player.leaderstats.Wins.Value = PlayerData.Replica.Data.Wins

			local character = player.Character
			local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
			local animator = humanoid:FindFirstChild("Animator") :: Animator
			local AnimationTrack = animator:LoadAnimation(Animations:FindFirstChild(EquippedEmote))
			AnimationTrack.Priority = Enum.AnimationPriority.Action
			AnimationTrack.Looped = true
			AnimationTrack:Play()
		end
	end

	for i = Settings.CELEBRATE_TIME, 0, -1 do
		if i == math.ceil(Settings.CELEBRATE_TIME / 3) then
			GameDataReplica:Set({ "Visible" }, false)
		end
		task.wait(1)
	end

	-- cleanup players
	for player: Player, playerData in GameData.Players do
		player:SetAttribute("OptionSelected", nil)
		player.Team = Teams.Lobby
		player.TeamColor = BrickColor.White()

		task.spawn(player.LoadCharacter, player)
	end

	VotingPlatforms.Red.Preview.ScreenGui.TextLabel.Visible = false
	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Visible = false

	VotingPlatforms.Red.Preview.ScreenGui.ImageLabel.Image = "rbxassetid://109014405058927"
	VotingPlatforms.Blue.Preview.ScreenGui.ImageLabel.Image = "rbxassetid://109014405058927"

	table.clear(votes.red)
	table.clear(votes.blue)

	StartIntermission()
end

function Service.Start()
	PlayerService.PlayerJoinSignal:Connect(function(Player: Player)
		local PlayerData = PlayerService:GetPlayer(Player)
		Service.GameData.Players[Player] = PlayerData
	end)

	PlayerService.PlayerLeaveSignal:Connect(function(Player: Player)
		if not Service.GameData.Players[Player] then
			return
		end

		Service.GameData.Players[Player] = nil
	end)

	for Player, PlayerData in PlayerService.Players do
		if not Service.GameData.Players[Player] then
			Service.GameData.Players[Player] = PlayerData
		end
	end

	scope:Hydrate(workspace.Screen.SurfaceGui.TextLabel)({
		Text = Service.GameData.Status,
		TextColor3 = scope:Computed(function()
			return Color3.fromRGB(255, 255, 255)
		end),
	})

	StartIntermission()
end

return Service
