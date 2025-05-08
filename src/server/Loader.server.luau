local ServerStorage = game:GetService("ServerStorage")

local Source = ServerStorage.Source

local Services = Source.Services
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