local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local Events = Shared.Events

local Janitor = require(Packages.Janitor)
local Attack = require(Events.Attack):Client()

local LocalPlayer = Players.LocalPlayer

local module = { Tag = script.Name }
module.__index = module

function weld(p1, p2)
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Part0 = p1
	weldConstraint.Part1 = p2
	weldConstraint.Parent = p1
end

function module.new(Instance: Tool)
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
		local connection
		local Hitbox

		if self.debounce then
			return
		end
		self.debounce = true

		task.delay(0.7, function()
			self.debounce = nil
		end)

		local Character = LocalPlayer.Character
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if not Humanoid then
			return
		end

		local Animator = Humanoid:FindFirstChildOfClass("Animator")
		local Animation = Animator and Animator:LoadAnimation(ReplicatedStorage.Assets.Animations.Swing)
		if Animation then
			Animation:Play()
		end

		if self.Instance.Parent ~= Character then
			return
		end

		local RootPart = Humanoid.RootPart

		Hitbox = Instance.new("Part")
		Hitbox.Size = Vector3.new(8, 5, 9)
		Hitbox.Transparency = 1
		Hitbox.CanCollide = false
		Hitbox.Anchored = false
		Hitbox.Massless = true

		Hitbox.CFrame = CFrame.new(RootPart.Position + RootPart.CFrame.LookVector * (Hitbox.Size.Z / 2))
			* CFrame.Angles(0, RootPart.Orientation.Y * math.pi / 180, 0)

		Hitbox.Parent = workspace

		weld(Hitbox, RootPart)

		task.delay(0.4, function()
			if connection then
				connection:Disconnect()
				connection = nil
			end

			if Hitbox then
				Hitbox:Destroy()
				Hitbox = nil
			end
		end)

		local parts = workspace:GetPartBoundsInBox(Hitbox.CFrame, Hitbox.Size, nil)

		connection = RunService.Heartbeat:Connect(function()
			for _, part in ipairs(parts) do
				local char = part:FindFirstAncestorOfClass("Model")
				local hum = char and char:FindFirstChildOfClass("Humanoid")

				if hum and char ~= Character then
					local hitPlayer = Players:GetPlayerFromCharacter(char)
					if hitPlayer and hitPlayer.Team ~= LocalPlayer.Team then
						if connection then
							connection:Disconnect()
							connection = nil
						end
						if Hitbox then
							Hitbox:Destroy()
						end

						Attack:Fire(hum)
						break
					end
				end
			end
		end)
	end))
end

function module:_cleanup()
	self.Janitor:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

return module
