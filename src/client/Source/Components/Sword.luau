local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local Events = Shared.Events

local Janitor = require(Packages.Janitor)
local Attack = require(Events.Attack):Client()

local LocalPlayer = Players.LocalPlayer

local module = {Tag = script.Name}
module.__index = module

function module.new(Instance : Tool)
	local self = setmetatable({
		Instance = Instance :: Tool,
		debounce = false :: boolean,
		Janitor = Janitor.new(),
	}, module)
	
	self:init()
	
	return self
end

function module:init()
	self.Janitor:Add(self.Instance.Activated:Connect(function()

		if self.debounce then
			return
		end

		self.debounce = true

		task.delay(0.7, function()
			self.debounce = nil
		end)

		local Character = LocalPlayer.Character
		local Humanoid = Character.Humanoid :: Humanoid
		local Animator = Humanoid:FindFirstChildOfClass("Animator") :: Animator?
		local Animation = Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Swing)
		Animation:Play()

		local RootPart = Humanoid.RootPart

		if self.Instance.Parent ~= Character then
			return
		end

		local Hitbox = Instance.new("Part")
		Hitbox.Size = Vector3.new(5, 5, 6)
		Hitbox.Transparency = .5
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

			if HitPlayer == LocalPlayer then
				return
			end

			if HitPlayer.Team == LocalPlayer.Team then
				return
			end

			Debounce = true
			Attack:Fire(HitPlayer)
			Hitbox:Destroy()
		end)


	end), "Disconnect")
end

function module:_cleanup()
	self.Janitor:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

return module
