local eggs = workspace.Eggs
-- local hatchRemote = game.ReplicatedStorage.Events.Gameplay.HatchEgg
local equipPetRemote = game.ReplicatedStorage.Events.Gameplay.EquipPet
local http = game:GetService("HttpService")

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

equipPetRemote.OnServerEvent:Connect(function(player, petName, equip)
	local plrPets = player.GameData.Pets.Value
	plrPets = http:JSONDecode(plrPets)

	local success = false
	local result

	if plrPets and plrPets[petName] then 
		if equip then 
			result = hatchingMod.EquipPet(player, petName)
		else
			result = hatchingMod.UnequipPet(player, petName)
		end

		if result then 
			success = result
		end
	end

	equipPetRemote:FireClient(player, success)
end)