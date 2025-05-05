local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Controller = {
	Name = script.Name,

	States = {
		CurrentOpenMenu = nil,
	},
}

local Camera = workspace.CurrentCamera
local Blur = Lighting:FindFirstChild("Blur") or Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Spr = require(Packages.spr)

function open(Frame: Frame)
	Spr.stop(Frame)
	Frame.Position = UDim2.fromScale(0.5, 0.55)
	Frame.Visible = true

	Spr.target(Frame, 1, 4, {
		Position = UDim2.fromScale(0.5, 0.5),
	})
	Spr.target(Camera, 0.7, 4, {
		FieldOfView = 63,
	})
	Spr.target(Blur, 0.7, 4, {
		Size = 24,
	})
end

function close(Frame: Frame)
	Frame.Visible = false

	Spr.target(Camera, 0.7, 4, {
		FieldOfView = 70,
	})
	Spr.target(Blur, 0.7, 4, {
		Size = 0,
	})
end

function Controller:Toggle(Frame)
	if Controller.States.CurrentOpenMenu == nil then
		Controller.States.CurrentOpenMenu = Frame
		open(Frame)
	else
		if Controller.States.CurrentOpenMenu == Frame then
			close(Controller.States.CurrentOpenMenu)
			Controller.States.CurrentOpenMenu = nil
			return
		end
		close(Controller.States.CurrentOpenMenu)
		Controller.States.CurrentOpenMenu = Frame
		open(Frame)
	end
end

function Controller.Start()
	if Controller.States.CurrentOpenMenu then
		close(Controller.States.CurrentOpenMenu)
	end
end

return Controller
