local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Sounds = SoundService.UI

local Fusion = require(ReplicatedStorage.Packages.Fusion)

local scoped = Fusion.scoped
local OnEvent = Fusion.OnEvent

local module = {Tag = script.Name}
module.__index = module

local FusionSpringSpeed = 20
local Damp = .3

function module.new(Instance : Instance)
	local self = setmetatable({
		Instance = Instance :: GuiButton,
		scope = scoped(Fusion)
	}, module)
	
	self:init()
	
	return self
end

function module:init()
	
	local HoverScale = 1.1
	local ClickScale = 0.9
	local NormalScale = 1
	
	local Scale = self.scope:Value(NormalScale)
	
	local UIScale = self.Instance:FindFirstChild("UIScale") or Instance.new("UIScale", self.Instance)
	
	self.scope:Hydrate(UIScale) {
		Scale = self.scope:Spring(Scale, FusionSpringSpeed, Damp)
	}
	
	self.scope:Hydrate(self.Instance) {
		[OnEvent "MouseEnter"] = function()
			Scale:set(HoverScale)
			Sounds.Hover:Play()
		end,
		[OnEvent "MouseLeave"] = function()
			Scale:set(NormalScale)			
		end,
		[OnEvent "MouseButton1Down"] = function()
			Scale:set(ClickScale)
			Sounds.Click:Play()
		end,
		[OnEvent "MouseButton1Up"] = function()
			Scale:set(NormalScale)
		end,
	}
end

function module:_cleanup()
	self.scope:doCleanup()
	
	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

return module
