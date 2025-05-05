local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Events = ReplicatedStorage.Shared.Events

local DataReplicate = require(Events.DataReplication):Server()

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)

local Source = ServerStorage.Source
local Modules = Source.Modules

local ProfileStore = require(Modules.ProfileStore)

local Template = require(Modules.ProfileTemplate)

local IDs = require(ReplicatedStorage.Shared.Data.IDs)

local PlayerStore = ProfileStore.New(
	"TT"..tostring(tick())
	,
	Template
)

local LocalDataTemplate = {
	Gifts = {},
}

local Service = {
	Name = script.Name,
	Players = {},
	PlayerJoinSignal = Signal.new(),
	PlayerLeaveSignal = Signal.new(),
}

function Service:GetAllPlayers()
	return self.Players
end

function Service:GetPlayer(Player)
	if self:CheckPlayer(Player) then
		return self.Players[Player]
	end
end

function Service:CheckPlayer(Player)
	return self.Players[Player] and true or false
end

function Service:PlayerJoin(Player: Player)
	Player:SetAttribute("JoinTime", workspace:GetServerTimeNow())

	local Connections = Janitor.new()

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

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Wins = Instance.new("IntValue")
	Wins.Name = "Wins"
	Wins.Value = Profile.Data.Wins or 0
	Wins.Parent = leaderstats

	local Spins = Instance.new("IntValue")
	Spins.Name = "Spins"
	Spins.Value = Profile.Data.Spins or 0
	Spins.Parent = Player

	local LocalData = table.clone(LocalDataTemplate)

	task.spawn(function()
		for id, gamepass in IDs.Gamepasses do
			if Profile.Data.Gamepasses[id] == true then
				continue
			end

			if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, tonumber(id)) then
				Profile.Data.Gamepasses[id] = true
			else
				Profile.Data.Gamepasses[id] = false
			end
		end
	end)

	self.Players[Player] = {
		Player = Player,
		Connections = Connections,
		Profile = Profile,
		LocalData = LocalData,
	}

	if Profile.Data.FirstLogin == 0 then
		Profile.Data.FirstLogin = os.time()
	end

	print(Profile)

	self.PlayerJoinSignal:Fire(Player)
end

function Service.Start()
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
				Service.Players[Player].Connections:Destroy()
				Service.Players[Player] = nil
			end
		end

		Service.PlayerLeaveSignal:Fire(Player)
	end)

	local Timer = Timer.new(1)

	Timer.Tick:Connect(function()
		for i, v in Service.Players do
			if v.Profile then
				v.Profile.Data.PlayTime += 1
			end
		end
	end)

	Timer:Start()
end

return Service
