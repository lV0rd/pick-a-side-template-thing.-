local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

--local SFX = SoundService.SFX

local Component = require(ReplicatedStorage.Packages.Component)
local Fusion = require(ReplicatedStorage.Packages.Fusion)

local scoped = Fusion.scoped
local OnEvent = Fusion.OnEvent

local module = {Tag = script.Name}
module.__index = module

local Speed = 4
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
			--spr.target(UIScale, Damp, Speed, {Scale = HoverScale})
		end,
		[OnEvent "MouseLeave"] = function()
			Scale:set(NormalScale)			
			--spr.target(UIScale, Damp, Speed, {Scale = NormalScale})
		end,
		[OnEvent "MouseButton1Down"] = function()
			Scale:set(ClickScale)
			--spr.target(UIScale, Damp, Speed, {Scale = ClickScale})
		end,
		[OnEvent "MouseButton1Up"] = function()
			Scale:set(NormalScale)
			--spr.target(UIScale, Damp, Speed, {Scale = NormalScale})
		end,
	}
end

function module:_cleanup()
	self._Trove:Destroy()
	self.scope:doCleanup()
	
	table.clear(self)
	setmetatable(self, nil)
end

return module
