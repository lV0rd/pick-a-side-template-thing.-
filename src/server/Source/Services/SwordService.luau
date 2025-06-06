--[[
SwordService.luau 2025/05/13

Handling weapons, and tagging
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = {
	Name = script.Name,
}

local Shared = ReplicatedStorage.Shared
local Swords = require(Shared.Data.Swords)

local Events = Shared.Events
local Attack = require(Events.Attack):Server()

local Debounces = {}

local Ragdoll = require(Shared.Utils.Ragdoll)

function Tag(Tagged, Tagger: Player)
	if Tagged:FindFirstChild("KillerTag") then
		Tagged:FindFirstChild("KillerTag").Value = Tagger
		return
	end

	local TagInstance = Instance.new("ObjectValue")
	TagInstance.Name = "KillerTag"
	TagInstance.Value = Tagger
	TagInstance.Parent = Tagged
end

function Service.Start()
	Attack:On(function(Player: Player, HitHumanoid: Humanoid)
		print("Fired")
		local UserId = Player.UserId
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?

		if Debounces[UserId] then
			return
		end
		print("Not in debounce")

		Debounces[UserId] = true

		task.delay(0.6, function()
			Debounces[UserId] = nil
		end)

		local Tool = Character:FindFirstChildOfClass("Tool")
		if not Tool then
			return
		end
		print("Found tool")

		local ToolData = Swords[Tool.Name]
		if not ToolData then
			return
		end
		print("Found tool data")

		if Humanoid.Health <= 0 then
			return
		end
		print("Attacker alive")

		local HitCharacter = HitHumanoid.Parent
		local HitPlayer = Players:GetPlayerFromCharacter(HitCharacter)

		if not HitCharacter then
			return
		end
		print("Target character found")
		
		if not HitPlayer then
			return
		end
		print("Target player found")

		if HitPlayer == Player then
			return
		end
		print("Target isnt attacker")

		if HitPlayer.Team == Player.Team then
			return
		end
		print("Not same team")

		if not (Humanoid.RootPart and HitHumanoid.RootPart) then
			return
		end

		local Distance = (Humanoid.RootPart.Position - HitHumanoid.RootPart.Position)
		if Distance.Magnitude > 10 then
			return
		end
		print("Within distance")

		Tag(HitCharacter, Player)
		print("Tagged")

		HitHumanoid:TakeDamage(ToolData.Damage)
		print("Damaged")

		if HitHumanoid.RootPart and Humanoid.RootPart then
			local direction = Distance.Unit
			local knockbackVelocity = (direction * 50) + Vector3.new(0, 60, 0) -- adjust power as needed
			HitHumanoid.RootPart.AssemblyLinearVelocity = knockbackVelocity
		end

		Ragdoll.TimedRagdoll(HitCharacter, 0.2)
	end)
end

return Service