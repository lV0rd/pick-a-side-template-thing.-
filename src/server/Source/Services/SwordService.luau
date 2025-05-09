local Debris = game:GetService("Debris")
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

		Debris:AddItem(Hitbox, 0.2)

		Hitbox.Touched:Connect(function(Hit)
			if Debounce then
				return
			end

			local Character = Hit.Parent
			local Humanoid = Character:FindFirstChild("Humanoid") :: Humanoid?
			if not Humanoid then
				return
			end

			local HitPlayer = Players:GetPlayerFromCharacter(Character)

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

			Humanoid:TakeDamage(ToolData.Damage)

			Hitbox:Destroy()
		end)
	end)
end

return Service
