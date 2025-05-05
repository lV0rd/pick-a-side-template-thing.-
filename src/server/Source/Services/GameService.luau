local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Teams = game:GetService("Teams")

local Source = ServerStorage.Source
local Services = Source.Services

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Settings = require(Shared.Data.Settings)
local Brainrots = require(Shared.Data.Brainrots)

local Signal = require(Packages.Signal)
local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)

local VotingPlatforms = workspace.Selections

local Params = RaycastParams.new()
Params.FilterType = Enum.RaycastFilterType.Include
Params.FilterDescendantsInstances = { VotingPlatforms }

local BlueTeam : Team = Teams.Blue
local RedTeam : Team = Teams.Red

local Barrier = workspace.Barrier

local Items = ReplicatedStorage.Assets.Items
local Animations = ReplicatedStorage.Assets.Animations

local Service = {
	Name = script.Name,

	GameData = {
		Started = false,
		Players = {},

		IntermissionTime = 0,
		VotingTime = 0,
		RoundTime = 0,

		Thread = {},

		BlueOption = nil,
		RedOption = nil,

		Status = scope:Value("n/a"),
	},
}

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

		StartIntermission()
		return
	end

	GameData.IntermissionTime = Settings.INTERMISSION_TIME

	while GameData.IntermissionTime > 0 do
		task.wait(1)
		GameData.IntermissionTime -= 1
		GameData.Status:set("Intermission: " .. GameData.IntermissionTime .. " seconds left")

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

	local BrainrotsLenght = #Brainrots

	GameData.BlueOption = math.random(BrainrotsLenght)
	GameData.RedOption = math.random(BrainrotsLenght)

	while GameData.BlueOption == GameData.RedOption do
		GameData.RedOption = math.random(BrainrotsLenght)
	end

	local RedIndex = Brainrots[GameData.RedOption]
	local BlueIndex = Brainrots[GameData.BlueOption]

	GameData.Status:set(BlueIndex.Name)
	VotingPlatforms.Blue.Preview.Picture.Texture = BlueIndex.Image

	task.wait(Settings.TIME_BETWEEN_PREVIEW)
	VotingPlatforms.Blue.Preview.Picture.Transparency = 1

	GameData.Status:set(RedIndex.Name)
	VotingPlatforms.Red.Preview.Picture.Texture = RedIndex.Image

	task.wait(Settings.TIME_BETWEEN_PREVIEW)
	VotingPlatforms.Blue.Preview.Picture.Transparency = 0

	GameData.Status:set("Select a meme!")
	Barrier.CanCollide = false

	local voting_conn

	voting_conn = RunService.PostSimulation:Connect(function()
		for player : Player, playerData in GameData.Players do
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

			local hit = workspace:Raycast(character:GetPivot().Position, Vector3.yAxis * -10, Params)

			if hit ~= nil then
				player:SetAttribute("OptionSelected", hit.Instance.Parent.Name)
				character.HumanoidRootPart.Anchored = true
				character.HumanoidRootPart.CFrame = CFrame.new(
					hit.Position.X + math.random(-3, 3),
					character:GetPivot().Position.Y,
					hit.Position.Z + math.random(-3, 3)
				)
			end
		end
	end)

	for i = Settings.VOTING_TIME, 0, -1 do
		GameData.Status:set("Select a meme! " .. i .. " seconds left")
		task.wait(1)
	end

	voting_conn:Disconnect()
	Barrier.CanCollide = true

	GameData.Status:set("Fight!")

	local option_a_players = 0
	local option_b_players = 0

	-- count votes, create teams
	for player : Player, playerData in GameData.Players do
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
			local humanoid = player.Character:FindFirstChild("Humanoid") :: Humanoid
			if not humanoid then
				return
			end

			local Weapon = playerData.EquippedWeapon

			if Weapon == "" then
				Weapon = "ClassicSword"
			end

			local Tool = Items:FindFirstChild(Weapon)
			if Tool == nil then
				Tool = Items.ClassicSword
			end

			humanoid.RootPart.Anchored = false

			Tool:Clone().Parent = player.Backpack

			humanoid.Died:Once(function()
				player.Team = Teams.Lobby
				player.TeamColor = BrickColor.White()
			end)
		end
	end

	if option_a_players > 0 and option_b_players > 0 then
		workspace:SetAttribute("RoundStatus", "Fight the other side!!")

		for i = Settings.FIGHTING_TIME, 0, -1 do
			-- end game once other team is eliminated
			if #BlueTeam:GetPlayers() == 0 or #RedTeam:GetPlayers() == 0 then
				break
			end

			GameData.Status:set("Fight! " .. i .. " seconds left")
			task.wait(1)
		end
	end

	for v : Player, playerData in GameData.Players do
		v.Backpack:ClearAllChildren()

		if v.Character and v.Character:FindFirstAncestorOfClass("Tool") then
			v.Character:FindFirstAncestorOfClass("Tool"):Destroy()
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
	GameData.Status:set(winner and winner.Name .. " Team Wins!" or "No winner!")

	if winner then
		for i, player in winner:GetPlayers() do
			print("e")
			local Data = GameData.Players[player]
			if not Data then
				continue
			end
	
			local EquippedEmote = Data.EquippedEmote

			if EquippedEmote == "" then
				EquippedEmote = "Default"
			end
			
			Data.Wins += 1
			Data.Coins += 500
			player.leaderstats.Wins.Value = Data.Wins
	
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
		workspace:SetAttribute("Countdown", i)
		task.wait(1)
	end

	-- cleanup players
	for player : Player, playerData in GameData.Players do
		player:SetAttribute("OptionSelected", nil)
		player.Team = Teams.Lobby
		player.TeamColor = BrickColor.White()

		player:LoadCharacter()
	end

	VotingPlatforms.Red.Preview.Picture.Texture = "rbxassetid://109014405058927"
	VotingPlatforms.Blue.Preview.Picture.Texture = "rbxassetid://109014405058927"

	StartIntermission()
end

function Service.Start()
	local PlayerService = require(Services.PlayerService)
	PlayerService.PlayerJoinSignal:Connect(function(Player: Player)
		Service.GameData.Players[Player] = PlayerService:GetPlayer(Player).Profile.Data
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
