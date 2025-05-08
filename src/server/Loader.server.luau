local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Source = ServerStorage.Source

local Packages = ReplicatedStorage.Packages
local Component = require(Packages.Component)

local Services = Source.Services
local Components = Source.Components
local CachedServices = {}

local PlayerService = require(Services.PlayerService)
CachedServices["PlayerService"] = PlayerService

for i, v in Services:GetChildren() do
    if v:IsA("ModuleScript") then
        local Service = require(v)
        CachedServices[v.Name] = Service
    end
end

for i, v in CachedServices do
    if v.Start then
        task.defer(v.Start)
    end
end

Component.Load(Components)