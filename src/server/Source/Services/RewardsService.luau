local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local Source = ServerStorage.Source
local Services = Source.Services

local Packages = ReplicatedStorage.Packages
local Shared = ReplicatedStorage.Shared

local Events = Shared.Events
local Functions = Shared.Functions

local Settings = require(Shared.Data.Settings)
local IDs = require(Shared.Data.IDs)
local Rewards = require(Shared.Data.Rewards)

local Spin = require(Functions.Spin)
local Follow = require(Functions.Follow)
local Gifts = require(Functions.Gifts)

local Service = {
	Name = script.Name,
}

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
end

function Service.Start()
	local PlayerService = require(Services.PlayerService)

	Spin:SetCallback(function(Player: Player)
		local Profile = PlayerService:GetPlayer(Player)
		if not Profile then
			return nil
		end

		if Profile.Profile.Data.Spins <= 0 then
			return nil
		end

		local Index = pickWeighted(Rewards.Spin)

		local Reward = Rewards.Spin[Index]

		if not Reward then
			return nil
		end

		Profile.Profile.Data.Spins -= 1
		Player.Spins.Value -= 1
		
		Reward.Callback(Player, Profile.Profile)

		return Index
	end)

	Follow:SetCallback(function(Player: Player)
		local success, result, result2 = pcall(function()
			local Profile = PlayerService:GetPlayer(Player)
			if not Profile then
				return false, "Data not found"
			end

            if Profile.Profile.Data.Followed then
                return false, "Already followed"
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
				Rewards.Follow.Callback(Player, Profile.Profile)
				return true, "Followed"
			end

			return false, FollowCount
		end)

		if success then
			return result, result2
		else
			return false, "Error with fetching follow data"
		end
	end)
	
	Gifts:SetCallback(function(Player: Player, Index: number)
		local Profile = PlayerService:GetPlayer(Player)
		if not Profile then
			return false, "Data not found"
		end

		local Info = Rewards.Gifts[Index]

		if not Info then
			return false, "Gift not found"
		end

		local now = workspace:GetServerTimeNow()
		local StartTime = Player:GetAttribute("JoinTime")

		if not StartTime then
			Player:Kick("Please rejoin, data not loaded.")
			return false
		end

		local Time = math.clamp(Info.Time - (now - StartTime), 0, Info.Time)

		if Time > 0 then
			return false, "Not reached yet/server didnt reach yet"
		end

		local Gifts = Profile.LocalData.Gifts
		local Name = tostring(Index)

		if Gifts[Name] == true then
			return false, "Already claimed gift."
		end

		Gifts[Name] = true
		Info.Reward(Player)

		return true, "Claimed gift! : " .. Info.Title .. ""
	end)
end

return Service
