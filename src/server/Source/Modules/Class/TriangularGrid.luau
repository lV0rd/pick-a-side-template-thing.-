local TrianglePlacer = {}
TrianglePlacer.__index = TrianglePlacer

-- Constructor
function TrianglePlacer.new(gridPart: BasePart, maxRowLength: number)
	local self = setmetatable({}, TrianglePlacer)

	self.GridPart = gridPart
	self.MaxRowLength = maxRowLength or 4
	self.PlacedCount = 0

	self.GridWidth = gridPart.Size.X
	self.GridDepth = gridPart.Size.Z

	return self
end

function TrianglePlacer:PlaceCharacter(character: Model)
	self.PlacedCount += 1
	local index = self.PlacedCount

	local count = 0
	for row = 0, self.MaxRowLength - 1 do
		local itemsInRow = self.MaxRowLength - row
		if index <= count + itemsInRow then
			local rowIndex = index - count

			local part = character:FindFirstChild("HumanoidRootPart")
			if not part then
				return
			end

			local partSize = part.Size
			local spacingX = self.GridWidth
			local spacingZ = self.GridDepth

			local totalWidth = (itemsInRow - 1) * spacingX
			local rowZ = self.GridPart.Position.Z + row * spacingZ
			local xOffset = -totalWidth / 2 + (rowIndex - 1) * spacingX
			local position = Vector3.new(self.GridPart.Position.X + xOffset, self.GridPart.Position.Y + partSize.Y / 2, rowZ)

			local root = character:FindFirstChild("HumanoidRootPart")

			if root then
				root.CFrame = CFrame.new(position)
			end

			return
		end
		count += itemsInRow
	end
end

function TrianglePlacer:Destroy()
    setmetatable(self, nil)
end

return TrianglePlacer
