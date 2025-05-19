--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CmdrConfig = require(ReplicatedStorage.Shared.Config.Cmdr)

return function(registry)
    registry:RegisterHook("BeforeRun", function(context)
        local UserId: number = context.Executor.UserId
        local IsAdmin = table.find(CmdrConfig.Admins, UserId)
        local isAdminCommand = context.Group == "Admin"

        if isAdminCommand and not IsAdmin then
            return "Permission not granted"
        end

        if not IsAdmin then
            return "Permission not granted"
        end

        return
    end)
end
