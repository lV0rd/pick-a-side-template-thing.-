local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Cmdr = require(ReplicatedStorage.Packages.cmdr)
 
Cmdr:RegisterDefaultCommands()

Cmdr:RegisterCommandsIn(script.Parent.Commands)
Cmdr:RegisterTypesIn(script.Parent.Types)
Cmdr:RegisterHooksIn(script.Parent.Hooks)