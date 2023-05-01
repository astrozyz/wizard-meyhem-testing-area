local zoneModule = require(script.Parent.Parent.Zone)
local sellFolder = workspace.Zones.Sell

local zone = zoneModule.new(sellFolder)

zone.playerEntered:Connect(function(player)
	local leaderstats = player.leaderstats
	local manaAmount = leaderstats.Mana
	local money = leaderstats.Money
	
	money.Value += manaAmount.Value
	manaAmount.Value = 0
end)