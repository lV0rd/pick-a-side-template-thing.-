--!nocheck
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient")) --this is ass :sob:
local CmdrConfig = require(ReplicatedStorage.Shared.Config.Cmdr) 

if not table.find(CmdrConfig.Admins, LocalPlayer.UserId) then
    return
end --Admins only!

Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })