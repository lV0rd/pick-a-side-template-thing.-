local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fusion = require(game.ReplicatedStorage.Packages.Fusion)
type UsedAs<T> = Fusion.UsedAs<T>

local Children = Fusion.Children
local OnEvent = Fusion.OnEvent

local function Button(
	scope: Fusion.Scope,
	props: {
		Parent: any?,
		Position: UsedAs<UDim2>?,
		AnchorPoint: UsedAs<Vector2>?,
		Size: UsedAs<UDim2>?,
		LayoutOrder: UsedAs<number>?,
		ButtonText: UsedAs<string>?,
		OnClick: () -> ()?,
		
		Children: {any},
	}
)
	
	
	local Hover = scope:Value(false)
	local Hold = scope:Value(false)
	
	local NewCamera = Instance.new("Camera")
	NewCamera.CFrame = CFrame.new(Vector3.new(0, 0, -5), Vector3.zero)
	
	for i, instance in props.Children do
		instance.Parent = workspace
		
		if instance:IsA("Model") and instance:GetAttribute("Dance") then

			local humanoid = instance:FindFirstChildOfClass("Humanoid")
			if not humanoid then
				return
			end

			local animator = humanoid:FindFirstChildOfClass("Animator")
			local animationid = instance:GetAttribute("Dance")
			local animation = ReplicatedStorage.animations:FindFirstChild(animationid)
			local track = animator:LoadAnimation(animation)
			track.Priority = Enum.AnimationPriority.Action
			track.Looped = true
			track:Play()
		end
	end
	
	return scope:New "TextButton" {
		Parent = props.Parent,
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.5,
		Visible = true,
		Position = props.Position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5),
		Size = props.Size or UDim2.fromOffset(100,100),
		LayoutOrder = props.LayoutOrder or 0,

		Text = "",
		TextSize = 28,
		TextColor3 = Color3.new(1, 1, 1),

		[Children] = {			
			scope:New "UICorner" { CornerRadius = UDim.new(1, 0) },
			scope:New "UIAspectRatioConstraint" {AspectRatio = 1},
			
			scope:New "UIScale" {
				Scale = scope:Spring(scope:Computed(function(use)
					local s = 1
					if use(Hover) then
						s = 1.12
					end
					if use(Hold)  then
						s = .9
					end
					
					return s
				end), 25, .42)

			},
			
			scope:New "ViewportFrame" {
				CurrentCamera = NewCamera,
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				Name = "ViewportFrame",
				
				[Children] = {
					NewCamera,

					scope:New("WorldModel") {
						[Children] = props.Children
					},					
				}
			}
		},

		[OnEvent "MouseEnter"] = function()
			Hover:set(true)
		end,
		
		[OnEvent "MouseLeave"] = function()
			Hover:set(false)
		end,
		
		[OnEvent "MouseButton1Down"] = function()
			Hold:set(true)
		end,
		
		[OnEvent "MouseButton1Up"] = function()
			Hold:set(false)
			Hover:set(false)
		end,
		
		[OnEvent "MouseButton1Click"] = props.OnClick
	}
end

return Button