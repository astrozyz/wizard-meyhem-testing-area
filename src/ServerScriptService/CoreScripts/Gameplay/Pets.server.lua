local eggs = workspace.Eggs
local hatchRemote = game.ReplicatedStorage.Events.Gameplay.HatchEgg

local hatchingMod = require(script.Parent.HatchingModule)

for _, egg in eggs:GetChildren() do 
	local prompt : ProximityPrompt = egg.ProximityPrompt
	local cost = egg:GetAttribute("Cost")

	prompt.Triggered:Connect(function(player) 
		local leaderstats = player.leaderstats
		local money = leaderstats.Money 

		if money.Value >= cost then 
			money.Value -= cost
			hatchingMod.HatchEgg(player, egg.Name)
		end
	end)
end