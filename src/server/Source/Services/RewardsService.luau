--[[
RewardsService.luau 2025/05/13

Handling playtime and daily rewards, follow rewards and spin the wheel rewards
]]
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Source = ServerStorage.Source
local Services = Source.Services

local Shared = ReplicatedStorage.Shared
local Events = Shared.Events
local Functions = Shared.Functions

local Notify = require(Events.Notify):Server()

local Future = require(ReplicatedStorage.Packages.Future)
local Rewards = require(Shared.Data.Rewards)

local Spin = require(Functions.Spin)
local Follow = require(Functions.Follow)
local Gifts = require(Functions.Gifts)
local Daily = require(Functions.Daily)

local Service = {
	Name = script.Name,
}

local HOURS_24 = 60 * 60 * 24
local HOURS_48 = HOURS_24 * 2

local function pickWeighted(array: { any })
	local weight = 0

	for _, v in array do
		weight += (v.Chance * 100)
	end

	local ran = math.random(1, weight)

	weight = 0
	for i, v in array do
		weight += (v.Chance * 100)
		if weight >= ran then
			return i
		end
	end

	return nil
end

function getCurrentDay(Data)
	local CurrentDay = Data.DayStreak

	local now = workspace:GetServerTimeNow()
	local timeDifference = now - Data.LastDay

	if timeDifference >= HOURS_48 then
		CurrentDay = 1
	end

	if CurrentDay + 1 > #Rewards.Daily then
		CurrentDay = 1
	end

	return CurrentDay
end

function Service.Start()
	local PlayerService = require(Services.PlayerService)

	Spin:SetCallback(function(Player: Player)
		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			return nil
		end

		if PlayerData.Replica.Data.Spins <= 0 then
			return nil
		end

		local Index = pickWeighted(Rewards.Spin)

		local Reward = Rewards.Spin[Index]

		if not Reward then
			return nil
		end

		PlayerData.Replica:Set({ "Spins" }, PlayerData.Replica.Data.Spins - 1)

		Reward.Callback(Player, PlayerData)

		return Index
	end)

	Follow:SetCallback(function(Player: Player)
		local Success, Result = Future.Try(function()
			local PlayerData = PlayerService:GetPlayer(Player)
			if not PlayerData then
				return { false, "Data not found" }
			end

			if PlayerData.Replica.Data.Followed then
				return { false, "Already followed" }
			end

			local Id = Player.UserId
			local Api = "https://friends.roproxy.com/v1/users/" .. Id .. "/followings?sortOrder=Desc&limit=100"

			local ApiResponse = HttpService:RequestAsync({
				Url = Api,
				Method = "GET",
			})

			local FollowCount = {}

			if ApiResponse.Success then
				local tabBody = HttpService:JSONDecode(ApiResponse.Body)

				for _, v in tabBody.data do
					if table.find(Rewards.Follow.List, v.id) then
						table.insert(FollowCount, v.id)
					end
				end
			end

			if #FollowCount >= #Rewards.Follow.List then
				Rewards.Follow.Callback(Player, PlayerData)
				PlayerData.Replica:Set({ "Followed" }, true)
				return { true, "Followed" }
			end

			return { false, "Missing people", FollowCount }
		end):Await()

		return Success, Result
	end)

	Gifts:SetCallback(function(Player: Player, Index: number)
		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			return false
		end

		local Info = Rewards.Gifts[Index]

		if not Info then
			return false
		end

		local now = workspace:GetServerTimeNow()
		local StartTime = Player:GetAttribute("JoinTime")

		if not StartTime then
			Player:Kick("Please rejoin, data not loaded.")
			return false
		end

		local Time = math.clamp(Info.Time - (now - StartTime), 0, Info.Time)

		if Time > 0 then
			return false
		end

		local Gifts = PlayerData.LocalData.Data.Gifts
		local Name = tostring(Index)

		if Gifts[Name] == true then
			return false
		end

		Notify:Fire(Player, "Claimed gift! Thanks for playing!")
		PlayerData.LocalData:Set({ "Gifts", Name }, true)
		Info.Reward(Player, PlayerData)

		return true
	end)

	Daily:SetCallback(function(Player: Player)
		local PlayerData = PlayerService:GetPlayer(Player)
		if not PlayerData then
			return
		end

		local Replica = PlayerData.Replica
		local Data = Replica.Data

		local now = workspace:GetServerTimeNow()
		local timeDifference = now - Data.LastDay

		if timeDifference < HOURS_24 then
			return false
		end

		local RewardDay = getCurrentDay(Data)
		local NewDay = RewardDay + 1

		if NewDay > #Rewards.Daily then
			NewDay = 1
		end

		Rewards.Daily[RewardDay].Function(Player)
		Replica:Set({ "LastDay" }, now)
		Replica:Set({ "DayStreak" }, NewDay)

		return true
	end)
end

return Service
