local module = {}

local petsFolder = game.ReplicatedStorage.Pets
local hatchEvent = game.ReplicatedStorage.Events.Gameplay.HatchEgg
local http = game:GetService("HttpService")
local pets = {
	["Common"] = petsFolder.Common:GetChildren(),
	["Uncommon"] = petsFolder.Uncommon:GetChildren(),
	["Rare"] = petsFolder.Rare:GetChildren(),
	["Legendary"] = petsFolder.Legendary:GetChildren(),
	["Mythical"] = petsFolder.Mythical:GetChildren()
}

local eggWeights = {
	Common = {
		Common = 70,
		Uncommon =  25,
		Rare = 5
	},
	Uncommon = {
		Common = 35,
		Uncommon =  50,
		Rare = 15
	},
	Rare = {
		Uncommon =  40,
		Rare = 56,
		Legendary = 6
	},
	Legendary = {
		Rare = 39,
		Legendary = 60,
		Mythical = 1
	},
	Mythical = {
		Mythical = 75,
		Legendary = 25
	},
}

function module.GetRandom(t)
	local TotalWeight = 0
	local weightsTable = t

	for Piece, Weight in pairs(weightsTable) do
		TotalWeight = TotalWeight + Weight
	end

	local Chance = math.random(1, TotalWeight)
	local Counter = 0
	for Piece, Weight in pairs(weightsTable) do
		Counter = Counter + Weight
		if Chance <= Counter then
			print(Piece)
			return Piece
		end
	end
end

function module.GetRandomPet(eggType)
	local rarity = module.GetRandom(eggWeights[eggType])
	local randomPet 
	
	local petWeights = {}
	
	for _, pet in pets[rarity] do 
		local starRating = pet:GetAttribute("StarRating")
		
		if starRating == 3 then 
			petWeights[pet.Name] = 1
		elseif starRating == 2 then 
			petWeights[pet.Name] = 2
		else
			petWeights[pet.Name] = 3
		end
	end
	
	local petName = module.GetRandom(petWeights)
	randomPet = petsFolder[rarity][petName]
	return randomPet, rarity
end

function module.HatchEgg(player, requestedEggType)
	local pet, rarirty = module.GetRandomPet(requestedEggType)
	local plrPets = player.GameData.Pets
	local rarityFolder = game.ServerStorage.Pets:FindFirstChild(rarirty)
	
	local decode
	
	local decodeSuccess, decErr = pcall(function()
		decode = http:JSONDecode(plrPets.Value)
	end)
	
	if not decodeSuccess then 
		decode = {}
	end
	
	if decode[pet.Name] == nil then 
		decode[pet.Name] = 1
	else
		decode[pet.Name] += 1
	end
	
	plrPets.Value = http:JSONEncode(decode)
	
	hatchEvent:FireClient(player, pet.Name, rarirty)
	
	local con
	con = hatchEvent.OnServerEvent:Connect(function(p)
		if p == player then 
			con:Disconnect()
			local petClone = pet:Clone()
			petClone.Parent = player.PlayerGui.ScreenGui.ViewportFrame
			petClone:PivotTo(CFrame.new(0,0,-7))
			game.Debris:AddItem(petClone, 10)
		end
	end)
end

function module.EquipPet(player, petName)
	local foundPet = petsFolder:FindFirstChild(petName, true)

	if foundPet then 
		local character = player.character

		if character and character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			--spawn alighposition and set up pet equips
		end
	end
end

function module.UnequipPet(player, petName)

end

return module