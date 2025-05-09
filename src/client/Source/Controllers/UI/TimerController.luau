local FriendService = game:GetService("FriendService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Source = ReplicatedStorage:WaitForChild("Source")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local RootGui = PlayerGui.RootGui
local Canvas = RootGui.Canvas

local Frames = Canvas.Frames
local Timer = Frames.Timer

local StatusText = Timer.Status :: TextLabel
local TimerFrame = Timer.Timer :: Frame
local BarFrame = TimerFrame.Bar :: Frame

local DataController = require(Source.Controllers.DataController)
local ReplicaClient = require(Source.Modules.ReplicaClient)

local Settings = require(Shared.Data.Settings)

local Fusion = require(Packages.Fusion)
local scope = Fusion.scoped(Fusion)

local Status = scope:Value("Intermission")
local Time = scope:Value(0)
local Visible = scope:Value(false)
local BarVisible = scope:Value(false)

function Controller.Start()
    local GameData = DataController:GetGameDataAsync() :: ReplicaClient.Replica
    GameData:OnSet({"Status"}, function()
        Status:set(GameData.Data.Status)
    end)
    GameData:OnSet({"Time"}, function()
        Time:set(GameData.Data.Time)
    end)
    GameData:OnSet({"Visible"}, function()
        Visible:set(GameData.Data.Visible)
    end)
    GameData:OnSet({"BarVisible"}, function()
        BarVisible:set(GameData.Data.BarVisible)
    end)

    scope:Hydrate(StatusText) {
        Text = Status
    }

    scope:Hydrate(BarFrame) {
        Size = scope:Spring(scope:Computed(function(use)
            if string.match(use(Status), "Intermission") then
                return UDim2.fromScale(use(Time)/Settings.INTERMISSION_TIME, 1)  
            elseif string.match(use(Status), "Vote") then
                return UDim2.fromScale(use(Time)/Settings.VOTING_TIME, 1)  
            elseif string.match(use(Status), "Fight") then
                return UDim2.fromScale(use(Time)/Settings.FIGHTING_TIME, 1)    
            end
            
            return UDim2.fromScale(0, 1)
        end), 40, .5)
    }

    

    scope:Hydrate(TimerFrame) {
        Visible = BarVisible
    }

    scope:Hydrate(Timer) {
        Visible = Visible
    }
end

return Controller