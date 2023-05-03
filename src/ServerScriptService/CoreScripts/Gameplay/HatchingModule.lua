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

	for _, Weight in pairs(weightsTable) do
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

local playerPetsFolder = workspace.PlayerPets

function module.EquipPet(player, petName, isLoading)
	local foundPet = petsFolder:FindFirstChild(petName, true)

	if foundPet then 
		print("sdhfusdfh")
		local character = player.character

		if character and character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
			print("sdjfosd")
			local pet = foundPet:Clone()
			local playerFolder = playerPetsFolder:FindFirstChild(player.Name) or Instance.new("Folder", playerPetsFolder)
			playerFolder.Name = player.Name
			print(playerFolder, playerFolder.Name, playerFolder.Parent)

			local alignPos : AlignPosition, alignOrient : AlignOrientation = pet.PrimaryPart.AlignPosition, pet.PrimaryPart.AlignOrientation

			pet.Parent = playerFolder
			alignPos.Attachment1 = character.HumanoidRootPart.RootAttachment
			alignOrient.Attachment1 = character.HumanoidRootPart.RootAttachment 
			pet:PivotTo(character:GetPivot() * CFrame.new(0,0,-4))

			local petsTable
			local s, _ = pcall(function()
				petsTable = http:JSONDecode(player.GameData.EquippedPets.Value)
			end)

			if not s then 
				petsTable = {}
			end

			print(petsTable)
			
			if not isLoading then
				table.insert(petsTable, petName)
				player.GameData.EquippedPets.Value = http:JSONEncode(petsTable)
			end
			
			return foundPet.Name
		end
	end
end

local workspacePets = workspace.PlayerPets

function module.UnequipPet(player, petName)
	local gameData = player.GameData
	local equippedPets = gameData.EquippedPets
	local decoded = http:JSONDecode(equippedPets.Value)
	local foundPet = workspacePets[player.Name]:FindFirstChild(petName)

	if table.find(decoded, petName) and foundPet then 
		table.remove(decoded, table.find(decoded, petName))
		equippedPets.Value = http:JSONEncode(decoded)
		foundPet:Destroy()
		return true
	end
end

return module