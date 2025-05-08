local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,

	States = {PlayerData = nil, LocalData = nil},
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Modules = Source:WaitForChild("Modules")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages.Signal)

Controller.Signals = {
	PlayerDataChanged = Signal.new(),
	LocalDataChanged = Signal.new(),
}

local LocalPlayer = Players.LocalPlayer

local ReplicaClient = require(Modules.ReplicaClient)

ReplicaClient.OnNew("PlayerData", function(replica: ReplicaClient.Replica)
    local is_local = replica.Tags.Player == LocalPlayer
	if not is_local then
        return
	end

	Controller.States.PlayerData = replica
end)

ReplicaClient.OnNew("LocalData", function(replica: ReplicaClient.Replica)
	local is_local = replica.Tags.Player == LocalPlayer
	if not is_local then
        return
	end

	Controller.States.LocalData = replica
end)

ReplicaClient.RequestData()

function Controller:GetPlayerDataAsync()
	while Controller.States.PlayerData == nil do
		task.wait()
	end

    return Controller.States.PlayerData
end

function Controller:GetLocalDataAsync()
	while Controller.States.LocalData == nil do
		task.wait()
	end

	return Controller.States.LocalData
end

return Controller
