local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui

repeat
    task.wait()
    RootGui = PlayerGui:FindFirstChild("RootGui")
until RootGui

local Source = ReplicatedStorage:WaitForChild("Source")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Component = require(Packages.Component)

local Controllers = Source:WaitForChild("Controllers"):GetDescendants()
local Components = Source:WaitForChild("Components")
local CachedControllers = {}

for i, v in Controllers do
    if v:IsA("ModuleScript") then
        local Controller = require(v)
        CachedControllers[v.Name] = Controller
    end
end

for i, v in CachedControllers do
    if v.Start then
        task.defer(v.Start)
    end
end

Component.Load(Components)