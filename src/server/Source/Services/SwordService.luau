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

function Tag(Tagged, Tagger : Player)
	if Tagged:FindFirstChild("KillerTag") then
		Tagged:FindFirstChild("KillerTag").Value = Tagger
		return
	end

	local TagInstance = Instance.new("ObjectValue")
	TagInstance.Value = Tagger
	TagInstance.Parent = Tagged
end

function Service.Start()
	Attack:On(function(Player)
		local UserId = Player.UserId

		if Debounces[UserId] then
			return
		end

		Debounces[UserId] = true

		task.delay(0.7, function()
			Debounces[UserId] = nil
		end)

		local Character = Player.Character
		local Humanoid = Character.Humanoid :: Humanoid
		local Animator = Humanoid:FindFirstChildOfClass("Animator") :: Animator?
		local Animation = Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Swing)
		Animation:Play()

		local RootPart = Humanoid.RootPart

		local Tool = Character:FindFirstChildOfClass("Tool")
		if not Tool then
			return
		end

		local ToolData = Swords[Tool.Name]

		local Hitbox = Instance.new("Part")
		Hitbox.Size = Vector3.new(5, 5, 6)
		Hitbox.Transparency = 1
		Hitbox.CanCollide = false
		Hitbox.Anchored = true
		Hitbox.CFrame = CFrame.new(RootPart.Position + RootPart.CFrame.LookVector * Hitbox.Size.Z)
			* CFrame.Angles(0, RootPart.Orientation.Y * math.pi / 180, 0)
		Hitbox.Parent = workspace

		local Debounce = false

		local Touched

		task.delay(0.2, function()
			if Touched then
				Touched:Disconnect()
				Touched = nil
			end
			Hitbox:Destroy()
		end)

		Touched = Hitbox.Touched:Connect(function(Hit)
			if Debounce then
				return
			end

			local OtherCharacter = Hit.Parent
			local OtherHumanoid = OtherCharacter:FindFirstChild("Humanoid") :: Humanoid?
			if not OtherHumanoid then
				return
			end

			local HitPlayer = Players:GetPlayerFromCharacter(OtherCharacter)

			if not HitPlayer then
				return
			end

			if HitPlayer == Player then
				return
			end

			if HitPlayer.Team == Player.Team then
				return
			end

			Debounce = true

			Tag(OtherCharacter, Player)

			OtherHumanoid:TakeDamage(ToolData.Damage)
			if OtherHumanoid.RootPart and Humanoid.RootPart then
				local direction = (OtherHumanoid.RootPart.Position - Humanoid.RootPart.Position).Unit
				local knockbackVelocity = (direction * 50) + Vector3.new(0, 60, 0) -- adjust power as needed
				OtherHumanoid.RootPart.AssemblyLinearVelocity = knockbackVelocity
			end
			Ragdoll.TimedRagdoll(OtherCharacter, 0.2)

			Hitbox:Destroy()
		end)
	end)
end

return Service
