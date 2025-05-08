local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared
local Packages = ReplicatedStorage.Packages

local Events = Shared.Events

local Janitor = require(Packages.Janitor)
local Attack = require(Events.Attack):Client()

local module = {Tag = script.Name}
module.__index = module

function module.new(Instance : Tool)
	local self = setmetatable({
		Instance = Instance :: Tool,
		Janitor = Janitor.new(),
	}, module)
	
	self:init()
	
	return self
end

function module:init()
	self.Janitor:Add(self.Instance.Activated:Connect(function()
		Attack:Fire()
	end), "Disconnect")
end

function module:_cleanup()
	self.Janitor:Cleanup()
	table.clear(self)
	setmetatable(self, nil)
end

module.Destroy = module._cleanup

return module
