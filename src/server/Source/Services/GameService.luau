--[[
GameService.luau 2025/05/11

This script is responsible for the main game loop of my pick a side game template
]]

local BadgeService = game:GetService("BadgeService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local SoundService = game:GetService("SoundService")
local Teams = game:GetService("Teams")
--Initiate services

local Source = ServerStorage.Source
local Services = Source.Services
local Modules = Source.Modules
--Source is the container for all the server module scripts

local Future = require(ReplicatedStorage.Packages.Future)
local ReplicaServer = require(Modules.ReplicaServer)
local PlayerService = require(Services.PlayerService)
--Intellisense for replica + PlayerService for managing players and their data

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Events = Shared.Events
--Remote events with Red

local Invisible = require(Events.Invisible):Server()
local Notify = require(Events.Notify):Server()

local Settings = require(Shared.Data.Settings)
local Themes = require(Shared.Data.Themes)
local IDs = require(Shared.Data.IDs)

local VictoryBadge = IDs.Badges.Victory

--I use fusion for its declarative values and scopes
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

--Client replicated data
local GameDataReplica = ReplicaServer.New({
	Token = ReplicaServer.Token("GameData"),
	Data = {
		Status = "Intermission",
		Time = 0,
		Visible = false,
		TimeFinal = false,
	},
})

GameDataReplica:Replicate()

--The service table that the module returns
local Service = {
	Name = script.Name,

	GameData = {
		Started = false, --Game running state
		Players = {} :: { [Player]: PlayerService.PlayerData }, --Loaded players dictionarry

		Thread = {}, --Luau threads incase i need something to do with them

		BlueOption = nil,
		RedOption = nil,

		Status = scope:Value("n/a"), --The serverside game status, used to display on the big tv in the main map
	},
}

--Self explanatory, used during voting
local function getTriangularGridOffset(index: number): Vector3
	local row = math.floor((math.sqrt(8 * index + 1) - 1) / 2)
	local posInRow = index - row * (row + 1) // 2
	local xSpacing, zSpacing = 3, 2.5
	local x = (posInRow - row / 2) * xSpacing
	local z = row * zSpacing
	return Vector3.new(x, 0, z) - Vector3.new(2, 0, 0)
end

--Return the amount of players loaded
function GetQueLenght(): number
	local count = 0
	for i, v in Service.GameData.Players do
		count += 1
	end
	return count
end

function StartIntermission()
	local GameData = Service.GameData

	--If the amount of loaded players are less than whats required, skip the intermission and redo
	if GetQueLenght() < Settings.REQUIRED_PLAYERS then
		GameData.Status:set("Not enough players!")
		task.wait(0.1)
		StartIntermission()
		return
	end

	local IntermissionTime = Settings.INTERMISSION_TIME

	--Tell the client its intermission time
	local ServerTimeNow = workspace:GetServerTimeNow()
	GameDataReplica:Set({ "Time" }, ServerTimeNow)
	GameDataReplica:Set({ "Status" }, "Intermission")
	GameDataReplica:Set({ "Visible" }, true)
	GameDataReplica:Set({ "TimeFinal" }, ServerTimeNow + Settings.INTERMISSION_TIME)

	--Initiate intermission
	while IntermissionTime > 0 do
		IntermissionTime -= 1
		GameData.Status:set("Intermission: " .. IntermissionTime .. " seconds left")
		task.wait(1)

		--Check again if the amount of loaded players are less than whats required, and redo intermission if yes
		if GetQueLenght() < Settings.REQUIRED_PLAYERS then
			task.wait(1)
			StartIntermission()
			return
		end
	end

	--Start (again, we check the amount of loaded players)
	if GetQueLenght() < Settings.REQUIRED_PLAYERS then
		StartIntermission()
		return
	end

	StartGame()
end

function StartGame()
	local GameData = Service.GameData

	--Starting game
	GameData.Started = true
	GameDataReplica:Set({ "Time" }, 0)
	GameDataReplica:Set({ "TimeFinal" }, 0)
	GameDataReplica:Set({ "Visible" }, false)

	--Picking themes for both sides
	local ThemesLenght = #Themes

	GameData.BlueOption = math.random(ThemesLenght)
	GameData.RedOption = math.random(ThemesLenght)

	--If a theme has been selected by both sides, we start a new loop to try and pick a diffirent theme
	while GameData.BlueOption == GameData.RedOption do
		GameData.RedOption = math.random(ThemesLenght)
	end

	local RedIndex = Themes[GameData.RedOption]
	local BlueIndex = Themes[GameData.BlueOption]

	--Sounds of the themes (italian brainrot sounds in this case)
	local BlueSound = Instance.new("Sound")
	local RedSound = Instance.new("Sound")
	BlueSound.SoundId = BlueIndex.Sound
	RedSound.SoundId = RedIndex.Sound

	BlueSound.Parent = VotingPlatforms.Blue.Preview
	RedSound.Parent = VotingPlatforms.Red.Preview

	--Dramatic effect
	SoundService.Preview:Play()
	Lighting.GlobalShadows = true
	VotingPlatforms.Blue.Platform.Material = Enum.Material.Plastic
	VotingPlatforms.Red.Platform.Material = Enum.Material.Plastic

	task.wait(1)

	--Preview blue side theme
	GameData.Status:set(BlueIndex.Name)
	VotingPlatforms.Blue.Preview.ScreenGui.ImageLabel.Image = BlueIndex.Image
	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Text = BlueIndex.Name
	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Visible = true
	VotingPlatforms.Blue.Platform.LightAttachment.Light.Enabled = true
	VotingPlatforms.Blue.Platform.Material = Enum.Material.Neon

	BlueSound:Play()
	task.wait(Settings.TIME_BETWEEN_PREVIEW)
	BlueSound:Stop()

	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Visible = false
	VotingPlatforms.Blue.Preview.ScreenGui.ImageLabel.Visible = false
	VotingPlatforms.Blue.Platform.LightAttachment.Light.Enabled = false
	VotingPlatforms.Blue.Platform.Material = Enum.Material.Plastic

	task.wait(0.5)

	--Preview red side theme
	GameData.Status:set(RedIndex.Name)
	VotingPlatforms.Red.Preview.ScreenGui.ImageLabel.Image = RedIndex.Image
	VotingPlatforms.Red.Preview.ScreenGui.TextLabel.Text = RedIndex.Name
	VotingPlatforms.Red.Preview.ScreenGui.TextLabel.Visible = true
	VotingPlatforms.Red.Platform.LightAttachment.Light.Enabled = true
	VotingPlatforms.Red.Platform.Material = Enum.Material.Neon

	RedSound:Play()
	task.wait(Settings.TIME_BETWEEN_PREVIEW)
	RedSound:Stop()

	--Show both sides
	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Visible = true
	VotingPlatforms.Blue.Preview.ScreenGui.ImageLabel.Visible = true
	VotingPlatforms.Blue.Platform.LightAttachment.Light.Enabled = true
	VotingPlatforms.Blue.Platform.Material = Enum.Material.Neon
	workspace.Screen.LightAttachment.Light.Enabled = true

	--Initiate voting
	GameData.Status:set("Select a meme!")
	BlueSound:Destroy()
	RedSound:Destroy()

	--Disable invisible barrier collision
	Barrier.CanCollide = false

	--Turn other players invisible
	Invisible:FireAll(true)

	--Voting logic
	local voting_conn

	--These are needed for the triangular grid positioning
	local votes = { blue = {}, red = {} }

	--Check every frame wether a player has stepped on the voting pads or no
	--When a player has stepped on one, triangule grid will position them, and then disable their movement
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
				--Set their team to the side they picked
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

	--Tell the client its time to vote
	do
		local ServerTimeNow = workspace:GetServerTimeNow()
		GameDataReplica:Set({ "Visible" }, true)
		GameDataReplica:Set({ "Time" }, ServerTimeNow)
		GameDataReplica:Set({ "Status" }, "Vote for your favourite meme!")
		GameDataReplica:Set({ "TimeFinal" }, ServerTimeNow + Settings.VOTING_TIME)
	end

	--Voting time loop
	local VotingTime = Settings.VOTING_TIME

	while VotingTime > 0 do
		VotingTime -= 1
		GameData.Status:set("Select a meme! " .. VotingTime .. " seconds left")
		task.wait(1)
	end

	--Make players visible again
	Invisible:FireAll(false)

	--Stop the voting logic and make the invisible barrier collidable again
	voting_conn:Disconnect()
	Barrier.CanCollide = true

	--Turn off the lights
	VotingPlatforms.Blue.Platform.LightAttachment.Light.Enabled = false
	VotingPlatforms.Red.Platform.LightAttachment.Light.Enabled = false
	workspace.Screen.LightAttachment.Light.Enabled = false
	Lighting.GlobalShadows = false

	--Tell the client its time to fight
	GameData.Status:set("Fight!")
	GameDataReplica:Set({ "Status" }, "Fight!")

	local option_a_players = 0
	local option_b_players = 0

	--Check votes, create teams
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

			--Give sword
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

			--Make player able to move
			humanoid.WalkSpeed = 16

			--Give weapon to player
			Tool:Clone().Parent = player.Backpack

			--Make team players spectators when they die
			humanoid.Died:Once(function()
				player.Team = Teams.Lobby
				player.TeamColor = BrickColor.White()
			end)

			--Color indicator above player heads
			local ColorIndicatorClone = ReplicatedStorage.Assets.Gui.ColorIndicator:Clone()
			ColorIndicatorClone.Frame.BackgroundColor3 = player.TeamColor.Color
			ColorIndicatorClone.Parent = character.Head
		else
			--If a player has not voted, and are still within the voting zone, they get reset back to the lobby
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

	--If there are players that voted, we initiate fighting
	if option_a_players > 0 and option_b_players > 0 then
		do
			local ServerTimeNow = workspace:GetServerTimeNow()
			GameDataReplica:Set({ "Time" }, ServerTimeNow)
			GameDataReplica:Set({ "TimeFinal" }, ServerTimeNow + Settings.FIGHTING_TIME)
		end

		local FightingTime = Settings.FIGHTING_TIME

		--Start fighting
		while FightingTime > 0 do
			--If one side is empty, stop the fight
			if #BlueTeam:GetPlayers() == 0 or #RedTeam:GetPlayers() == 0 then
				break
			end

			FightingTime -= 1
			GameData.Status:set("Fight! " .. FightingTime .. " seconds left")
			task.wait(1)
		end
	end

	--Remove weapons from player inventory
	for v: Player, playerData in GameData.Players do
		v.Backpack:ClearAllChildren()

		if v.Character and v.Character:FindFirstChildOfClass("Tool") then
			local tool = v.Character:FindFirstChildOfClass("Tool")
			tool:Destroy()
		end
	end

	--Set the winner
	--No winner if tied
	local winner

	if #BlueTeam:GetPlayers() ~= #RedTeam:GetPlayers() then
		winner = if #BlueTeam:GetPlayers() == 0 then RedTeam else BlueTeam
	end

	--Tell the client who won
	GameDataReplica:Set({ "Status" }, winner and winner.Name .. " Team Wins!" or "No winner!")
	GameData.Status:set(winner and winner.Name .. " Team Wins!" or "No winner!")

	--If game isnt tied
	if winner then
		--Play victory sound
		SoundService.Victory:Play()

		--Award winners
		for i, player in winner:GetPlayers() do
			local PlayerData = GameData.Players[player]
			if not PlayerData then
				continue
			end

			--Victory dance
			local EquippedEmote = PlayerData.Replica.Data.EquippedEmote

			--If none, set to default
			if EquippedEmote == "" then
				EquippedEmote = "Default"
			end

			local CoinsAwardedAmount = 500 * PlayerData.LocalData.Data.CoinsMultiplier
			local WinsAwaredAmount = 1 * PlayerData.LocalData.Data.WinsMultiplier

			--Award first victory badge
			task.defer(function()
				local OwnsVictoryBadge = Future.Try(function()
					return BadgeService:UserHasBadgeAsync(player.UserId, VictoryBadge)
				end):Await()

				if not OwnsVictoryBadge then
					if PlayerData.Replica.Data.Wins < 1 then
						BadgeService:AwardBadge(player.UserId, VictoryBadge)
					end
				end
			end)

			--Award players with coins and wins
			PlayerData.Replica:Set({ "Wins" }, PlayerData.Replica.Data.Wins + WinsAwaredAmount)
			PlayerData.Replica:Set({ "Coins" }, PlayerData.Replica.Data.Coins + CoinsAwardedAmount)

			player.leaderstats.Wins.Value = PlayerData.Replica.Data.Wins

			--Notify player rewards
			Notify:Fire(player, `<font color="#00FF00">+{CoinsAwardedAmount} Coins!</font>`)
			Notify:Fire(player, `<font color="#00FF00">+{WinsAwaredAmount} Wins!</font>`)

			--Play victory dance on winners
			local character = player.Character
			local humanoid = character:FindFirstChild("Humanoid") :: Humanoid
			local animator = humanoid:FindFirstChild("Animator") :: Animator
			local AnimationTrack = animator:LoadAnimation(Animations:FindFirstChild(EquippedEmote))
			AnimationTrack.Priority = Enum.AnimationPriority.Action
			AnimationTrack.Looped = true
			AnimationTrack:Play()
		end
	end

	--Let winners celebrate (if its tied itll just wait)
	for i = Settings.CELEBRATE_TIME, 0, -1 do
		if i == math.ceil(Settings.CELEBRATE_TIME / 3) then
			GameDataReplica:Set({ "Visible" }, false)
		end
		task.wait(1)
	end

	-- cleanup players
	for player: Player, playerData in GameData.Players do
		task.defer(function()
			player:SetAttribute("OptionSelected", nil)
			player.Team = Teams.Lobby
			player.TeamColor = BrickColor.White()

			task.spawn(player.LoadCharacter, player)
		end)
	end

	--Make previews invisible
	VotingPlatforms.Red.Preview.ScreenGui.TextLabel.Visible = false
	VotingPlatforms.Blue.Preview.ScreenGui.TextLabel.Visible = false

	--Set preview image back to question mark
	VotingPlatforms.Red.Preview.ScreenGui.ImageLabel.Image = "rbxassetid://109014405058927"
	VotingPlatforms.Blue.Preview.ScreenGui.ImageLabel.Image = "rbxassetid://109014405058927"

	--Clean up votes table
	table.clear(votes)

	--Start intermission
	StartIntermission()
end

function Service.Start()
	--Detect when a player has loaded and insert them into the Players dictionary
	PlayerService.PlayerJoinSignal:Connect(function(Player: Player)
		local PlayerData = PlayerService:GetPlayer(Player)
		Service.GameData.Players[Player] = PlayerData
	end)

	--Detect when a loaded player has left, and remove them from the Players dictionary if they're in it
	PlayerService.PlayerLeaveSignal:Connect(function(Player: Player)
		if not Service.GameData.Players[Player] then
			return
		end

		Service.GameData.Players[Player] = nil
	end)

	--Script may run after a few players have loaded, so we must check for them
	for Player, PlayerData in PlayerService.Players do
		if not Service.GameData.Players[Player] then
			Service.GameData.Players[Player] = PlayerData
		end
	end

	--Set up the big screen
	scope:Hydrate(workspace.Screen.SurfaceGui.TextLabel)({
		Text = Service.GameData.Status,
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})

	--Start intermission
	StartIntermission()
end

return Service
