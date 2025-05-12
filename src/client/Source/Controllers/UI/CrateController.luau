local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Controller = {
	Name = script.Name,
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")
local Modules = Source:WaitForChild("Modules")

local ExternalDebug = require(ReplicatedStorage.Packages.Fusion.ExternalDebug)
local nameOf = require(ReplicatedStorage.Packages.Fusion.Utility.nameOf)
local Swords = require(ReplicatedStorage.Shared.Data.Swords)
local DataController = require(Controllers.DataController)
local ReplicaClient = require(Modules.ReplicaClient)

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Functions = Shared.Functions

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BillboardTemplate = Assets.Gui.CrateBillboard :: BillboardGui
local IconTemplate = Assets.Gui.CrateTemplate :: Frame

local CrateFunction = require(Functions.Crate)

local Fusion = require(Packages.Fusion)

local scope = Fusion.scoped(Fusion)
local peek = Fusion.peek
local OnEvent = Fusion.OnEvent
local Children = Fusion.Children

function min(t, mapper)
	local bk, bv, bn

	for k, v in pairs(t) do
		local n = mapper(k, v)

		if not bv or n <= bn then
			bk, bv, bn = k, v, n
		end
	end

	return bk, bv, bn
end

local Crates: { [Instance]: BillboardGui } = {}
local Closest = scope:Value("null")

local Debounce = false

function Controller.Start()
	local GuiController = require(Controllers.GuiController)
	local ReplicaData = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica
    local Data = ReplicaData.Data

	local function call(crate)
        if Debounce then
            return
        end

        Debounce = true
        task.delay(.5, function() Debounce = false end)

		local success, result = CrateFunction:Call(crate):Await()
		if not success then
			return
		end

        print(result)
        
		--init animation or sum idk
	end

	for i, Crate in CollectionService:GetTagged("Crate") do
		local Indexes = require(Crate:FindFirstChild("Indexes"))

		local NewBillboard = BillboardTemplate:Clone()

		scope:Hydrate(NewBillboard)({
			Enabled = scope:Computed(function(use)
				if use(Closest) == NewBillboard.Name then
					return true
				else
					return false
				end
			end),

			Size = scope:Spring(
				scope:Computed(function(use)
					if use(Closest) == NewBillboard.Name then
						return UDim2.fromScale(20, 20)
					else
						return UDim2.fromScale(16, 16)
					end
				end),
				40,
				1
			),
		})

		for _, data in Indexes do
			local SwordData = Swords[data[1]]
			local NewIcon = IconTemplate:Clone()
			NewIcon.Chance.Text = (data[2] * 100) .. "%"
			NewIcon.Icon.Image = SwordData.Image
			NewIcon.Item.Text = Swords[data[1]].Name
			NewIcon.Parent = NewBillboard.Main.Frame
		end

		scope:Hydrate(NewBillboard.Main.Open)({
			[OnEvent("MouseButton1Click")] = function()
				call(Crate)
			end,
		})

		NewBillboard.Name = Crate.Name
		NewBillboard.Adornee = Crate
		NewBillboard.Parent = PlayerGui.Billboards
		Crates[Crate] = NewBillboard
	end

	ContextActionService:BindAction(
		"OpenCrate",
		function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)
			if actionName ~= "OpenCrate" then
				return
			end

			if inputState ~= Enum.UserInputState.Begin then
				return
			end

			if peek(Closest) == nil then
				return
			end

			local Instance = PlayerGui.Billboards:FindFirstChild(peek(Closest)).Adornee

			if not Instance then
				return
			end

			call(Instance)
		end,
		false,
		Enum.KeyCode.E
	)

	RunService.PostSimulation:Connect(function()
		local Filtered = {}
		local Character = LocalPlayer.Character
		if Character and Character.HumanoidRootPart then
			for Crate, Billboard in Crates do
				local Distance = (Character.HumanoidRootPart.Position - Crate:GetPivot().Position).Magnitude
				if Distance <= 15 then
					table.insert(Filtered, Billboard)
				end
			end

			if #Filtered == 0 then
				Closest:set(nil)
				return
			end

			local closest = min(Filtered, function(i, v)
				return (LocalPlayer.Character.HumanoidRootPart.Position - v.Adornee:GetPivot().Position).Magnitude <= 15
			end)

			Closest:set(Filtered[closest].Name)
			return
		end
	end)
end

return Controller
