local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Source = ServerStorage.Source
local Services = Source.Services

local PlayerService = require(Services.PlayerService)

local Packages = ReplicatedStorage.Packages
local Assets = ReplicatedStorage.Assets

local Gui = Assets.Gui

local LeaderboardTemplate = Gui.LeaderboardTemplate

local StoresEnabled = not RunService:IsStudio() or true
local KeySuffix = "Leaderboard"

local DEBOUNCE_LIMIT = 60
local MIN_VALUE_DISPLAY = 1
local MAX_VALUE_DISPLAY = 99999999999999

local Janitor = require(Packages.Janitor)
local Future = require(Packages.Future)

local module = { Tag = script.Name }
module.__index = module

local Components = {}

function getLenght(t)
	local s = 0
	for i, v in t do
		s += 1
	end
	return s
end

function module.new(Instance: Model)
	local self = setmetatable({
		Instance = Instance :: Model,
		Janitor = Janitor.new(),
		Debounce = 0 :: number,
		OrderedDatastore = nil :: OrderedDataStore?,
		Cache = nil :: DataStorePages?,
	}, module)

	self:init()

	return self
end

function module:init()
	table.insert(Components, self)
	local Board = self.Instance.Board :: BasePart
	local SurfaceGui = Board.SurfaceGui :: ScreenGui
	local ListFrame = SurfaceGui.List :: ScrollingFrame

	if not StoresEnabled then
		warn("Leaderboards will not run during studio testing")
		return
	end

	local StoreItem = self.Instance:GetAttribute("StoreItem")
	if not StoreItem then
		return
	end

	self.OrderedDatastore = DataStoreService:GetOrderedDataStore(StoreItem .. KeySuffix)

	self.Janitor:Add(RunService.Heartbeat:Connect(function(dt)
		if tick() - self.Debounce < DEBOUNCE_LIMIT then
			return
		end

		self.Debounce = tick()

		local Players = PlayerService:GetAllPlayers()

		for Player, PlayerData in Players do
			local Replica = PlayerData.Replica
			local Data = Replica.Data

			local Stats = Data[StoreItem]

			if typeof(Stats) == "table" then
				error("Stat type cannot be table")
			end

			Future.Try(function()
				self.OrderedDatastore:SetAsync(tostring(Player.UserId), Stats)
			end):Await()
		end

		for i, v in ListFrame:GetChildren() do
			if v:IsA("UIListLayout") then
				continue
			end

			v:Destroy()
		end

		local Success, Top100 = Future.Try(function()
			return self.OrderedDatastore:GetSortedAsync(false, 100):GetCurrentPage()
		end):Await()

		if not Success then
			if self.Cache then
				Top100 = self.Cache
			end

			return
		end

		self.Cache = Top100

		for i, v in ipairs(self.Cache) do
			local UserId = v.key
			local Value = v.value

			local Username = "N/A"
			local Color = Color3.fromRGB(38, 50, 56)

			if Value < MIN_VALUE_DISPLAY or Value > MAX_VALUE_DISPLAY then
				continue
			end

			Future.Try(function()
				Username = game.Players:GetNameFromUserIdAsync(UserId)
			end)

			if Username == "EpicBlacklistedUser" then
				continue -- Skip blacklisted users
			end

			if i == 1 then
				Color = Color3.fromRGB(255, 215, 0)
			elseif i == 2 then
				Color = Color3.fromRGB(192, 192, 192)
			elseif i == 3 then
				Color = Color3.fromRGB(205, 127, 50)
			end

			local Item = LeaderboardTemplate:Clone()

			Item.Name = Username
			Item.LayoutOrder = i
			Item.Rank.TextColor3 = Color
			Item.Rank.Text = "#" .. tostring(i)
			Item.Username.Text = Username
			Item.Amount.Text = tostring(Value)

			Item.Parent = ListFrame
		end
	end))
end

function module:_cleanup()
	if table.find(Components, self) then
		table.remove(Components, table.find(Components, self))
	end

	self.Janitor:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

game:BindToClose(function()
	if not StoresEnabled then
		return
	end

	local Datastores: { [string]: OrderedDataStore } = {}

	for index, self in Components do
		local Datastore = self.OrderedDatastore
		local StoreItem = self.StoreItem
		if not StoreItem then
			continue
		end

		if not Datastore then
			continue
		end

		Datastores[StoreItem] = Datastore
	end

	local Count = getLenght(PlayerService:GetAllPlayers())

	for Player, PlayerData in PlayerService:GetAllPlayers() do
		local Data = PlayerData.Replica.Data

		Future.Try(function()
			for i, v in Datastores do
				v:SetAsync(tostring(Player.UserId), Data[i])
			end
		end):After(function()
			Count -= 1
		end)

		while Count > 0 do
			task.wait()
		end
	end
end)

return module
