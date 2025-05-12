local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)
local IDs = require(ReplicatedStorage.Shared.Data.IDs)

local Source = ServerStorage.Source
local Modules = Source.Modules

local Codes = require(Modules.Codes)
local ProfileStore = require(Modules.ProfileStore)
local ReplicaServer = require(Modules.ReplicaServer)

local Template = require(Modules.ProfileTemplate)

local PlayerStore = ProfileStore.New("GameTestingDataStudio" .. tostring(tick()), Template)

local PlayerDataReplicaToken = ReplicaServer.Token("PlayerData")
local LocalDataReplicaToken = ReplicaServer.Token("LocalData")

local Shared = ReplicatedStorage.Shared
local Data = Shared.Data
local Events = Shared.Events

local Dances = require(Data.Dances)
local Swords = require(Data.Swords)

local CodeRedeem = require(Events.Codes):Server()
local Notify = require(Events.Notify):Server()

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
		local Data = Replica.Data
		local Gamepasses = Data.Gamepasses
		for ID, Gamepass in IDs.Gamepasses do
			local Owns = MarketplaceService:UserOwnsGamePassAsync(Player.UserId, tonumber(ID))

			local CurrentState = Gamepasses[ID]

			if Owns and not CurrentState then
				Replica:Set({ "Gamepasses", ID }, true)
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

	print(Profile)
	self.PlayerJoinSignal:Fire(Player)
end

for i, Player in Players:GetPlayers() do
	if Player:IsDescendantOf(Players) then
		Service:PlayerJoin(Player)
	end
end

Players.PlayerAdded:Connect(function(Player)
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

local Clock = Timer.new(1)

Clock.Tick:Connect(function()
	for i, v in Service.Players do
		if v.Profile then
			v.Replica:Set({ "PlayTime" }, v.Replica.Data.PlayTime + 1)
		end
	end
end)

Clock:Start()

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
