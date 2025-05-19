--[[
PlayerService.luau 2025/05/13

Handling player data, badges(welcome badge), timed spin reward, codes, kills and automatic 
gamepass/swords/dances indexing
]]
local BadgeService = game:GetService("BadgeService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Future = require(ReplicatedStorage.Packages.Future)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)
local IDs = require(ReplicatedStorage.Shared.Data.IDs)
local Settings = require(ReplicatedStorage.Shared.Data.Settings)

local WelcomeBadgeId = IDs.Badges.Welcome

local Source = ServerStorage.Source
local Modules = Source.Modules

local Codes = require(Modules.Codes)
local ProfileStore = require(Modules.ProfileStore)
local ReplicaServer = require(Modules.ReplicaServer)

local Template = require(Modules.ProfileTemplate)

local PlayerStore

if Settings.MOCK_DATA_STORE_ENABLED and RunService:IsStudio() then
	PlayerStore = ProfileStore.New("MockData", Template).Mock
else
	PlayerStore = ProfileStore.New("PickaSideGameDataIndex", Template)
end

local PlayerDataReplicaToken = ReplicaServer.Token("PlayerData")
local LocalDataReplicaToken = ReplicaServer.Token("LocalData")

local Shared = ReplicatedStorage.Shared
local Data = Shared.Data
local Events = Shared.Events

local Dances = require(Data.Dances)
local Swords = require(Data.Swords)

local CodeRedeem = require(Events.Codes):Server()
local Notify = require(Events.Notify):Server()

local SpinDebounce = {} --Debonce for the timed spin reward

local Service = {
	Name = script.Name,
	Players = {} :: { [Player]: PlayerData },
	PlayerJoinSignal = Signal.new(),
	PlayerLeaveSignal = Signal.new(),
}

export type PlayerData = {
	Player: Player,
	Connections: { RBXScriptConnection },
	Profile: ProfileStore.Profile<any>,
	Replica: ReplicaServer.Replica,
	LocalData: ReplicaServer.Replica,
}

function characterSpawn(Character)
	local Player = Players:GetPlayerFromCharacter(Character)
	local PlayerData = Service:GetPlayer(Player)

	local LocalData = PlayerData.LocalData.Data
	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

	Humanoid.MaxHealth *= LocalData.HealthMultiplier
	Humanoid.Health = Humanoid.MaxHealth

	Humanoid.Died:Once(function()
		local KillerTag: ObjectValue? = Character:FindFirstChild("KillerTag")
		if not KillerTag then
			return
		end

		if not KillerTag.Value then
			return
		end

		local KillerData = Service:GetPlayer(KillerTag.Value)
		if not KillerData then
			return
		end

		local AwardedCoins = 100 * KillerData.LocalData.Data.CoinsMultiplier
		local AwardedKills = 1 * KillerData.LocalData.Data.KillsMultipler

		KillerData.Replica:Set({"Kills"}, KillerData.Replica.Data.Kills + AwardedKills)
		KillerData.Replica:Set({"Coins"}, KillerData.Replica.Data.Coins + AwardedCoins)

		Notify:Fire(KillerTag.Value, "You have eleminated "..Player.Name.."! +"..AwardedKills.."Kills")
		Notify:Fire(KillerTag.Value, "+"..AwardedCoins.."Coins")
	end)
end

function Service:GetAllPlayers(): { [Player]: PlayerData }
	return self.Players
end

function Service:GetPlayer(Player): PlayerData?
	if self:CheckPlayer(Player) then
		return self.Players[Player]
	end

	return nil
end

function Service:CheckPlayer(Player)
	return self.Players[Player] and true or false
end

function Service:PlayerJoin(Player: Player)
	Player:SetAttribute("JoinTime", workspace:GetServerTimeNow())
	Player:SetAttribute("SpinTime", workspace:GetServerTimeNow())

	local Connections = {}

	local Profile = PlayerStore:StartSessionAsync(`{Player.UserId}`, {
		Cancel = function()
			return Player.Parent ~= Players
		end,
	})

	if not Profile then
		Player:Kick("Profile not loaded, please rejoin later.")
		warn(`{Player.Name}'s profile was not loaded.`)
		return
	end

	Profile:AddUserId(Player.UserId)
	Profile:Reconcile()

	Profile.OnSessionEnd:Connect(function()
		self.Players[Player].Profile = nil
		Player:Kick("Data possibly loaded in another server. (102)")
	end)

	if not Player:IsDescendantOf(Players) then
		Profile:EndSession()
		return
	end

	local Data = {
		Player = Player,
		Connections = Connections,
		Profile = Profile,

		Replica = ReplicaServer.New({
			Token = PlayerDataReplicaToken,
			Tags = {
				Player = Player,
			},
			Data = Profile.Data,
		}),

		LocalData = ReplicaServer.New({
			Token = LocalDataReplicaToken,
			Tags = {
				Player = Player,
			},
			Data = {
				Gifts = {},
				SpinHistory = {},

				WinsMultiplier = 1,
				CoinsMultiplier = 1,
				KillsMultipler = 1,
				HealthMultiplier = 1,
				SpinDebounce = true,
			},
		}),
	}

	Data.Replica:Replicate()
	Data.LocalData:Replicate()

	self.Players[Player] = Data

	task.spawn(function()
		for i, v in Dances do
			if Data.Replica.Data.Emotes[v.Name] then
				continue
			end

			if v.Currency == "Robux" then
				if Data.Replica.Data.Gamepasses[v.ID] then
					Data.Replica:Set({ "Emotes", v.Name }, true)
				end
			end
			Data.Replica:Set({ "Emotes", v.Name }, false)
		end
	end)

	task.spawn(function()
		for i, v in Swords do
			if Data.Replica.Data.Swords[i] then
				continue
			end

			if v.Gamepass then
				if Data.Replica.Data.Gamepasses[v.ID] then
					Data.Replica:Set({ "Swords", i }, true)
				end
			end
			Data.Replica:Set({ "Swords", i }, false)
		end
	end)

	task.spawn(function()
		local Replica = Data.Replica
		local ReplicaData = Replica.Data
		local Gamepasses = ReplicaData.Gamepasses
		for ID, Gamepass in IDs.Gamepasses do
			local Success, Owns = Future.Try(function()
				return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, tonumber(ID))
			end):Await()

			if not Success then
				Owns = false
			end

			local CurrentState = Gamepasses[ID]

			if Owns then
				if not CurrentState then
					Replica:Set({ "Gamepasses", ID }, true)
				end

				if Gamepass.OnJoin then
					Gamepass.Callback(Player, Data)
				end
			elseif CurrentState == nil then
				Replica:Set({ "Gamepasses", ID }, false)
			end
		end
	end)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Wins = Instance.new("IntValue")
	Wins.Name = "Wins"
	Wins.Value = Profile.Data.Wins or 0
	Wins.Parent = leaderstats

	if Data.Replica.Data.FirstLogin == 0 then
		Data.Replica:Set({ "FirstLogin" }, workspace:GetServerTimeNow())
	end

	if Player.Character then
		characterSpawn(Player.Character)
	end

	Connections.Character = Player.CharacterAdded:Connect(characterSpawn)

	print(Profile)
	self.PlayerJoinSignal:Fire(Player)
end

for i, Player in Players:GetPlayers() do
	if Player:IsDescendantOf(Players) then
		Service:PlayerJoin(Player)
	end
end

Players.PlayerAdded:Connect(function(Player)
	task.spawn(function()
		local _, OwnWelcomeBadge = Future.Try(function()
			return BadgeService:UserHasBadgeAsync(Player.UserId, WelcomeBadgeId)
		end):Await()
		print(OwnWelcomeBadge, 1)
		if not OwnWelcomeBadge then
			print(2)
			BadgeService:AwardBadge(Player.UserId, WelcomeBadgeId)
		end
	end)
	Service:PlayerJoin(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
	if Service.Players[Player] then
		Service.Players[Player].Profile:EndSession()

		if Service.Players[Player].Connections then
			for i, v in Service.Players[Player].Connections do
				v:Disconnect()
				v = nil
			end
			Service.Players[Player] = nil
		end
	end

	Service.PlayerLeaveSignal:Fire(Player)
end)

local PlaytimeClock = Timer.new(1)

PlaytimeClock.Tick:Connect(function()
	for i, v in Service.Players do
		if v.Profile then
			v.Replica:Set({ "PlayTime" }, v.Replica.Data.PlayTime + 1)
		end
	end
end)

RunService.Heartbeat:Connect(function()
	local now = workspace:GetServerTimeNow()

	for Player, PlayerData in Service.Players do
		if SpinDebounce[Player] then
			continue
		end

		local SpinTime = Player:GetAttribute("SpinTime")
		local Time = math.clamp(Settings.SPIN_TIME_REWARD - (now - SpinTime), 0, Settings.SPIN_TIME_REWARD)

		if Time <= 0 then
			SpinDebounce[Player] = true
			task.delay(1, function()
				SpinDebounce[Player] = false
			end)

			Player:SetAttribute("SpinTime", now)
			PlayerData.Replica:Set({ "Spins" }, PlayerData.Replica.Data.Spins + 1)
			Notify:Fire(Player, "You got a spin!")
		end
	end
end)

PlaytimeClock:Start()

CodeRedeem:On(function(Player: Player, Code: string)
	local PlayerData = Service:GetPlayer(Player)
	if not PlayerData then
		return
	end

	local Replica = PlayerData.Replica
	local Data = Replica.Data

	if not Codes[Code] then
		Notify:Fire(Player, "Invalid code!")
		return
	end

	if Data.Codes[Code] then
		Notify:Fire(Player, "Code already redeemed!")
		return
	end

	Data.Codes[Code] = true
	Notify:Fire(Player, "Successfuly redeemed " .. Code .. "!")
	Codes[Code](Player, PlayerData)
end)

return Service
