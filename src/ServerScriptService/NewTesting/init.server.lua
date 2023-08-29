local DataStoreService = game:GetService("DataStoreService") -- Datastore service for data saving 
local HttpService = game:GetService("HttpService") -- HTTP service for handling JSON Tables
local Players = game:GetService("Players") -- Players service to detect when a player joins/leaves
local ReplicatedStorage = game:GetService("ReplicatedStorage") -- Replicated storage for loading player items 

local playerTemplate = script.PlayerSetup -- A folder in the script that has the outline for the leaderstats and the game data
local staffHandler = script.StaffHandler -- A script for staff tools 

local datastores = {} -- Table for all datastores

for _, item in playerTemplate:GetDescendants() do
    if item:IsA("ValueBase") then
        datastores[item.Name] = DataStoreService:GetDataStore(item.Name) -- Grabbing a datastore relative to the name of the objects in the playersetup folder
    end
end


local function onPlayerRemoving(player) -- When the player leaves
    print(datastores)
    for _, v in player:GetDescendants() do --Getting both gamedata and leaderstats in the player 
        if v:IsA("ValueBase") and v.Parent:IsA("Folder") and v.Parent.Name ~= "Cooldowns" then --Making sure the object is data
            print(v.Name)
            local succ, err = pcall(function()
                datastores[v.Name]:SetAsync(player.UserId, v.Value) -- Saving the data to a datastore
            end)
            
            if not succ then warn(err) end -- Warning if an error occured when saving data
        end
    end
end

local dailyRewards = {10, 20, 30, 40, 50, 60, 125} -- Daily reward values, Day 1 = 10, Day 2 = 20, etc

local function dailyLoginReward(player)
    local currentLogin, lastLogin = os.date("*t"), player.GameData.LastLogin.Value --Getting the time the player last logged in 
    currentLogin = currentLogin.yday
    local loginStreak = player.GameData.LoginStreak -- The streak the player has when collecting their dailies (to give the player the correct days reward)
    local mana = player.leaderstats.Mana -- The players mana amount

    if not lastLogin then -- If the player hasnt played the game before
        loginStreak = 1
        mana.Value += dailyRewards[1]
    elseif currentLogin - lastLogin == 1 then -- If a day has passed
        if loginStreak == 7 then --It will reset the streak back to day 1 if the player has played for a week straight
            mana.Value += dailyRewards[7]
            loginStreak = 1
        else -- It will add 1 to the streak to give the correct reward tomorrow 
            loginStreak += 1
            mana.Value += dailyRewards[loginStreak]
        end
    elseif currentLogin - lastLogin > 1 then --The player waited longer than a day 
        loginStreak = 1
        mana.Value += dailyRewards[1]
    else
        print("Todays daily has already been claimed") -- The player has played the game earlier today or returned before a day has passed
    end
end

local function onPlayerAdded(player) -- When a player joins 
    local playerData = playerTemplate:Clone() --Grabbing the players data setup 
    print(datastores)

    for _, item in playerData:GetDescendants() do --Getting all data objects
        if item:IsA("ValueBase") then
            local data
            local succ, err = pcall(function()
                data = datastores[item.Name]:GetAsync(player.UserId) or item.Value -- loading the players saved data or leaving the value the same (if the data has default values set for it)
            end)

            if succ then
                item.Value = data -- Setting loaded data to objects data
            else
                warn(err) -- Continuing the loop but voiding this specific data load, not stopping the rest
            end
        end
    end

    for _, a in playerData:GetChildren() do
        a.Parent = player -- Parenting the player data to the player
    end 

    playerData:Destroy() --Deleting the original folder that the data was held inside of 
    dailyLoginReward(player) -- Giving the player their daily reward AFTER data has been loaded

    if player.Character then -- If the player has already loaded by the time this line runs 
        local staff = ReplicatedStorage.Models.Weapons:FindFirstChild(player.GameData.Staff.Value) --Finding the correct staff the player has equipped

        if staff then
            staff = staff:Clone()
            staffHandler:Clone().Parent = staff --Giving the staff its scripts

            staff.Parent = player.Character -- Giving the player their staff and equipping it
        end

        local armor = ReplicatedStorage.Models.Armor:FindFirstChild(player.GameData.Armor.Value) --Findind the armor the player has equipped
        if armor then -- If the player has equipped armor 
            for _, v in player.Character:GetChildren() do
                if v:IsA("Clothing") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") or v:IsA("Accessory") then
                    v:Destroy() --Preparing the character to have armor applied to them by deleting any accessories, clothing, meshes, etc
                end
            end
            
            for _, v in armor:GetChildren() do --Looping through the armor pieces, each armor piece is named the corresponding limb it will attach to 
                if v:IsA("BasePart") then --if its not an accessory 
                    local foundPart = player.Character:FindFirstChild(v.Name)
                    if foundPart then --Finding the corresponding limb
                        if foundPart.Name == "UpperTorso" then -- If its the upper torso it will align its position with the lower torso
                            local weld = Instance.new("WeldConstraint") --New weld
                            v = v:Clone()
                            
                            --Getting the armor piece attached to the character via welds.
                            v.Name = armor.Name.. " ".. v.Name 
                            v.Parent = player.Character 
                            v.CFrame = player.Character.LowerTorso.CFrame 
                            weld.Part0 = foundPart
                            weld.Part1 = v
                            weld.Parent = v
                            weld.Name = "ArmorWeld"
                        else
                            local weld = Instance.new("Weld") -- New weld
                            v = v:Clone()
                            
                            --Getting the armor piece attached to the correct limb
                            v.Name = armor.Name.. " ".. v.Name
                            v.Parent = player.Character 
                            weld.Part0 = foundPart
                            weld.Part1 = v
                            weld.Parent = v
                            weld.Name = "ArmorWeld"
                        end
                    end
                elseif v:IsA("Accessory") then --If the item is an accessory
                    v = v:Clone()
                    player.Character.Humanoid:AddAccessory(v); -- Adding the accessory to the character 
                end
            end
        end
    end

    player.CharacterAdded:Connect(function(character) --If the character doesnt exist/player dies 

        --EXACT SAME STEPS FROM EARLIER, ALL COMMENTS FROM EARLIER APPLY HERE
        local staff = ReplicatedStorage.Models.Weapons:FindFirstChild(player.GameData.Staff.Value)

        if staff then
            staff = staff:Clone()
            staffHandler:Clone().Parent = staff 

            staff.Parent = character
        end

        local armor = ReplicatedStorage.Models.Armor:FindFirstChild(player.GameData.Armor.Value)
        if armor then
            for _, v in character:GetChildren() do
                if v:IsA("Clothing") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") or v:IsA("Accessory") then
                    v:Destroy()
                end
            end

            for _, v in armor:GetChildren() do
                if v:IsA("BasePart") then
                    local foundPart = player.Character:FindFirstChild(v.Name)
                    if foundPart then
                        if foundPart.Name == "UpperTorso" then
                            local weld = Instance.new("WeldConstraint")
                            v = v:Clone()
                            
                            v.Name = "Armor"
                            v.CanCollide = false 
                            v.Parent = player.Character 
                            v.CFrame = player.Character.LowerTorso.CFrame 
                            weld.Part0 = foundPart
                            weld.Part1 = v
                            weld.Parent = v
                            weld.Name = "ArmorWeld"
                        else
                            local weld = Instance.new("Weld")
                            v = v:Clone()
                            
                            v.Name = "Armor"
                            v.CanCollide = false 
                            v.Parent = player.Character 
                            weld.Part0 = foundPart
                            weld.Part1 = v
                            weld.Parent = v
                            weld.Name = "ArmorWeld"
                        end
                    end
                elseif v:IsA("Accessory") then
                    v = v:Clone()
                    player.Character.Humanoid:AddAccessory(v);
                end
            end
        end
    end)
end

for _, player in Players:GetPlayers() do
    onPlayerAdded(player) -- If players joined before the code is ran it will run the player added event 
end

Players.PlayerAdded:Connect(onPlayerAdded) -- When players join they will get their data
Players.PlayerRemoving:Connect(onPlayerRemoving) -- When players leave their data will be saved

game:BindToClose(function() --If the game shuts down
    for _, player in Players:GetPlayers() do
        onPlayerRemoving(player) -- All players will have their data saved
    end
end)