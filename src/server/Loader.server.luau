local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Source = ServerStorage.Source

local Services = Source.Services:GetChildren()
local CachedServices = {}

for i, v in Services do
    if v:IsA("ModuleScript") then
        local Service = require(v)
        CachedServices[v.Name] = Service
    end
end

for i, v in CachedServices do
    if v.Start then
        v.Start()
    end
end