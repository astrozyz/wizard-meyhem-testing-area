local datastore = game:GetService("DataStoreService")
local playerData = datastore:GetDataStore("PlayerData")
local http = game:GetService("HttpService")

local template = game.ServerStorage.PlayerTemplate:GetChildren()

local dailyRewards = {
	10, 20, 30, 40, 50, 60, 125
}

game.Players.PlayerAdded:Connect(function(player)
	for _, v in template do 
		v = v:Clone()
		v.Parent = player
	end
	
	local gameData = player.GameData
	local leaderboard = player.leaderstats
	local mana = leaderboard.Mana
	local money = leaderboard.Money 
	
	local loadedData = playerData:GetAsync(player.UserId)

	if loadedData then 
		loadedData = http:JSONDecode(loadedData)
		money.Value = loadedData.Money
		mana.Value = loadedData.Mana
	else
		loadedData = {}
	end

	local currentLogin, lastLogin = os.date("*t"), loadedData.LastLogin
	currentLogin = currentLogin.yday

	local loginStreak = loadedData.LoginStreak

	if  not lastLogin then
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

	player:SetAttribute("LastLogin", currentLogin)
	player:SetAttribute("LoginStreak", loginStreak)
	player:SetAttribute("XP", loadedData.XP or 0)
	player:SetAttribute("Level", loadedData.Level or 1)
	player:SetAttribute("LastAbility", 0)
	player:SetAttribute("LastSwung", 0)
	
	player.GameData.Pets.Value = loadedData.Pets or "[]"

	leaderboard.Parent = player
end)

local function saveData(player)
	local leaderboard = player.leaderstats
	local petsVal = player.GameData.Pets.Value or "[]"
	local data = {
		LastLogin = player:GetAttribute("LastLogin"),
		XP = player:GetAttribute("XP"),
		Level = player:GetAttribute("Level"),
		LoginStreak = player:GetAttribute("LoginStreak"),
		Pets = player.GameData.Pets.Value
	}

	for _, stat in leaderboard:GetChildren() do 
		data[stat.Name] = stat.Value
	end

	playerData:SetAsync(player.UserId, http:JSONEncode(data))
end

game.Players.PlayerRemoving:Connect(function(player)
	saveData(player)
end)

game:BindToClose(function()
	for _, player in game.Players:GetPlayers() do
		saveData(player) 
	end
end)