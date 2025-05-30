--[[
SwordService.luau 2025/05/13

Handling weapons, and tagging
]]
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
	TagInstance.Value = Tagger
	TagInstance.Parent = Tagged
end

function Service.Start()
	Attack:On(function(Player: Player, HitPlayer: Player)
		local UserId = Player.UserId
		local Character = Player.Character
		local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?

		if Debounces[UserId] then
			return
		end

		Debounces[UserId] = true

		task.delay(0.6, function()
			Debounces[UserId] = nil
		end)

		local Tool = Character:FindFirstChildOfClass("Tool")
		if not Tool then
			return
		end

		local ToolData = Swords[Tool.Name]

		if Humanoid.Health <= 0 then
			return
		end

		local OtherCharacter = HitPlayer.Character
		local OtherHumanoid = OtherCharacter:FindFirstChild("Humanoid") :: Humanoid?

		if not OtherHumanoid then
			return
		end

		if not HitPlayer then
			return
		end

		if HitPlayer == Player then
			return
		end

		if HitPlayer.Team == Player.Team then
			return
		end

		local Distance = (Humanoid.RootPart.Position - OtherHumanoid.RootPart.Position)
		if Distance.Magnitude > 10 then
			return
		end

		Tag(OtherCharacter, Player)

		OtherHumanoid:TakeDamage(ToolData.Damage)

		if OtherHumanoid.RootPart and Humanoid.RootPart then
			local direction = Distance.Unit
			local knockbackVelocity = (direction * 50) + Vector3.new(0, 60, 0) -- adjust power as needed
			OtherHumanoid.RootPart.AssemblyLinearVelocity = knockbackVelocity
		end

		Ragdoll.TimedRagdoll(OtherCharacter, 0.2)
	end)
end

return Service
