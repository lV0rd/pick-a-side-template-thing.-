local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,
}

local Source = ReplicatedStorage:WaitForChild("Source")
local Controllers = Source:WaitForChild("Controllers")
local Modules = Source:WaitForChild("Modules")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Shared = ReplicatedStorage:WaitForChild("Shared")

local Future = require(ReplicatedStorage.Packages.Future)
local DataController = require(Controllers.DataController)
local ReplicaClient = require(Modules.ReplicaClient)

local Functions = Shared.Functions

local LocalPlayer = Players.LocalPlayer

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RootGui = PlayerGui:WaitForChild("RootGui")

local Canvas = RootGui.Canvas
local Frames = Canvas.Frames
local FollowMenu = Canvas.Menus.Follow

local CloseButton = FollowMenu.Close
local FollowButton = Frames.Left.Buttons.Follow :: TextButton
local Redeem = FollowMenu.Redeem :: TextButton

local CheckFrame = FollowMenu.Check :: Frame
local RequirementText = FollowMenu.Requirement :: TextLabel

local Fusion = require(Packages.Fusion)

local FollowFunction = require(Functions.Follow)
local IDs = require(Shared.Data.Rewards)

local scope = Fusion.scoped(Fusion)
local OnEvent = Fusion.OnEvent

local Debounce = false
local BlueColor = "rgb(0, 170, 255)"

function buildText()
	local usernames = {}

	for _, userId in ipairs(IDs.Follow.List) do
		local success, username = Future.Try(function()
			return Players:GetNameFromUserIdAsync(userId)
		end):Await()

		if success and username then
			table.insert(usernames, string.format('<font color="%s">@%s</font>', BlueColor, username))
		else
			table.insert(usernames, '<font color="red">@Unknown</font>')
		end
	end

	-- Build sentence depending on number of usernames
	local followText = "Follow "
	if #usernames == 1 then
		followText ..= usernames[1]
	elseif #usernames == 2 then
		followText ..= usernames[1] .. " and " .. usernames[2]
	else
		for i = 1, #usernames do
			if i == #usernames then
				followText ..= "and " .. usernames[i]
			else
				followText ..= usernames[i] .. ", "
			end
		end
	end
	followText ..= " on Roblox for free rewards!"

	return followText
end

function Controller.Start()
	local GuiController = require(Controllers.GuiController)
	local Data = DataController:GetPlayerDataAsync() :: ReplicaClient.Replica

	local IsFollowing = scope:Value(Data.Data.Followed)

	Data:OnSet({ "Followed" }, function()
		IsFollowing:set(Data.Data.Followed)
	end)

	scope:Hydrate(FollowButton)({
		[OnEvent("MouseButton1Click")] = function()
			GuiController:Toggle(FollowMenu)
		end,
	})

	scope:Hydrate(CloseButton)({
		[OnEvent("MouseButton1Click")] = function()
			GuiController:Toggle(FollowMenu)
		end,
	})

	scope:Hydrate(CheckFrame)({
		Visible = scope:Computed(function(use)
			if use(IsFollowing) then
				return true
			else
				return false
			end
		end),
	})

	RequirementText.Text = buildText()

	scope:Hydrate(Redeem)({
		Visible = scope:Computed(function(use)
			if use(IsFollowing) then
				return false
			else
				return true
			end
		end),

		[OnEvent("MouseButton1Click")] = function()
			if Debounce then
				return
			end

			Debounce = true

			local _, Success, Following = FollowFunction:Call():Await()

			if Success then
				if Following[1] == true then
					GuiController:Notify("Thanks for following!")
				else
					GuiController:Notify(Following[2])
					task.delay(2, function()
						Debounce = false
					end)
				end
			else
				task.delay(2, function()
					Debounce = false
				end)
			end
		end,
	})
end

return Controller
