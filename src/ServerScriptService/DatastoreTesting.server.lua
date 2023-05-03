local datastoreService = game:GetService("DataStoreService")
local http = game:GetService("HttpService")

local datastores = {
    Leaderstats = {datastoreService:GetDataStore("Leaderstats"), {Mana = 0, Money = 10000}},
    Inventory = {datastoreService:GetDataStore("Inventory"), {Weapons = {}, Potions = {}, Armor = {}}},
    EquippedPets = {datastoreService:GetDataStore("EquippedPets"), {}},
    Pets = {datastoreService:GetDataStore("Pets"), {}},
    DailyRewards = {datastoreService:GetDataStore("DailyRewards"), {CurrentLogin = 0, LoginStreak = 0}},
    Levels = {datastoreService:GetDataStore("Levels"), {Level = 1, XP = 0}}
}

local playerTemplate = game:GetService("ServerStorage").PlayerTemplate
local dailyRewards = {10, 20, 30, 40, 50, 60, 125}
local characterAddedCons = {} 
local eggModule = require(game:GetService("ServerScriptService").CoreScripts.Gameplay.HatchingModule)
local equipPetRemote = game.ReplicatedStorage.Events.Gameplay.EquipPet

local function convertToTable(data, defaultData)
    local tempData

    local success, _ = pcall(function()
        tempData = http:JSONDecode(data)
    end)

    if not success then 
        tempData = defaultData
    end

    return tempData
end

local function convertToJSON(data, defaultData)
    local tempData

    local success, _ = pcall(function()
        tempData = http:JSONEncode(data)
    end)

    if not success then 
        tempData = http:JSONEncode(defaultData)
    end

    return tempData
end

local function loadPets(player)
	if workspace.PlayerPets:FindFirstChild(player.Name) then 
		for _, pet in workspace.PlayerPets[player.Name]:GetChildren() do 
			pet:Destroy()
		end
	end

	local gameData = player.GameData

	local equippedPets
	
	equippedPets = convertToTable(gameData.EquippedPets.Value, {})

	print(equippedPets)
	if #equippedPets > 0 then 
		for _, petName in equippedPets do 
			local result = eggModule.EquipPet(player, petName, true)
			equipPetRemote:FireClient(player, result)
		end
	end
end

local function dailyLoginReward(player, loadedData, plrFolder)
    local currentLogin, lastLogin = os.date("*t"), loadedData.DailyRewards.CurrentLogin
    currentLogin = currentLogin.yday
    local loginStreak = loadedData.DailyRewards.LoginStreak
    local mana = plrFolder.leaderstats.Mana

    if not lastLogin then
        loginStreak = 1
        mana.Value += dailyRewards[1]
    elseif currentLogin - lastLogin == 1 then
        if loginStreak == 7 then
            mana.Value += dailyRewards[7]
            loginStreak = 1
        else
            loginStreak += 1
            mana.Value += dailyRewards[loginStreak]
        end
    elseif currentLogin - lastLogin > 1 then 
        loginStreak = 1
        mana.Value += dailyRewards[1]
    else
        print("Todays daily has already been claimed")
    end
end

game.Players.PlayerAdded:Connect(function(player)
    local plrFolder = {}
    for _, v in playerTemplate:GetChildren() do 
        v = v:Clone()
        plrFolder[v.Name] = v
    end 

    local gameData = plrFolder.GameData
    local leaderstats = plrFolder.leaderstats
    
    local loadedData = {}

    for name, ds in datastores do
        loadedData[name] = convertToTable(ds[1]:GetAsync(player.UserId), ds[2])
    end

    leaderstats.Money.Value = loadedData.Leaderstats.Money
    leaderstats.Mana.Value = loadedData.Leaderstats.Mana
    gameData.EquippedPets.Value = convertToJSON(loadedData.EquippedPets, datastores.EquippedPets[2])
    gameData.Inventory.Value = convertToJSON(loadedData.Inventory, datastores.Inventory[2])
    gameData.Pets.Value = convertToJSON(loadedData.Pets, datastores.Pets[2])

    dailyLoginReward(player, loadedData, plrFolder)

    player:SetAttribute("LastAbility", 0)
	player:SetAttribute("LastSwung", 0)
    player:SetAttribute("XP", loadedData.Levels.XP or 0)
	player:SetAttribute("Level", loadedData.Levels.Level or 1)
	player:SetAttribute("LastLogin", loadedData.DailyRewards.CurrentLogin)
	player:SetAttribute("LoginStreak", loadedData.DailyRewards.LoginStreak)

    for _, v in plrFolder do
        v.Parent = player
    end

    if player.Character then
        loadPets(player)
    end

    characterAddedCons[player.Name] = player.CharacterAdded:Connect(function()
        loadPets(player)
    end)
end)

local function saveData(player)
    local gameData = player.GameData
    local leaderstats = player.leaderstats

    local dataTable = {
        Leaderstats = {Mana = leaderstats.Mana.Value, Money = leaderstats.Money.Value},
        Inventory = convertToTable(gameData.Inventory.Value, datastores.Inventory[2]),
        EquippedPets = convertToTable(gameData.EquippedPets.Value, datastores.EquippedPets[2]),
        Pets = convertToTable(gameData.Pets.Value, datastores.Pets[2]),
        DailyRewards = {CurrentLogin = player:GetAttribute("LastLogin"), LoginStreak = player:GetAttribute("LoginStreak")},
        Levels = {Level = player:GetAttribute("Level"), XP = player:GetAttribute("LoginStreak")}
    }

    for name, data in dataTable do
        local datastoreEntry = datastores[name]
        local ds = datastoreEntry[1]
        local default = datastoreEntry[2]

        local toSave = convertToJSON(data, default)
        ds:SetAsync(player.UserId, toSave)
    end
end

game.Players.PlayerRemoving:Connect(function(player)
    characterAddedCons[player.Name]:Disconnect()

    saveData(player)
end)

game:BindToClose(function()
    for _, player in game.Players:GetPlayers() do
        characterAddedCons[player.Name]:Disconnect()
        saveData(player)
    end
end)