local zoneModule = require(script.Parent.Parent.Zone)
local sellFolder = workspace.Zones.Sell

local http = game:GetService("HttpService")
local zone = zoneModule.new(sellFolder)
local Players = game:GetService("Players")

local purchaseEvent = game:GetService("ReplicatedStorage").Events.Gameplay.ItemShopPurchase
local equipItemEvent = game:GetService("ReplicatedStorage").Events.Gameplay.EquipItem

zone.playerEntered:Connect(function(player)
	local leaderstats = player.leaderstats
	local manaAmount = leaderstats.Mana
	local money = leaderstats.Money
	
	money.Value += manaAmount.Value
	manaAmount.Value = 0
end)

local models = game:GetService("ReplicatedStorage").Models
local ServerScriptService = game:GetService("ServerScriptService")

purchaseEvent.OnServerEvent:Connect(function(player, itemName)
	local foundItem = models:FindFirstChild(itemName, true)
	local result

	if foundItem then
		local plrMoney = player.leaderstats.Money
		local price = foundItem:GetAttribute("ShopPrice")

		if price and plrMoney.Value >= tonumber(price) then 
			plrMoney.Value -= tonumber(price)
			if foundItem:IsA("Tool") then 
				local playerInv = player.GameData.Inventory
				local decoded

				local s, _ = pcall(function()
					decoded = http:JSONDecode(playerInv.Value)
				end)

				if not s then
					decoded = {}
				end

				if decoded.Staffs then
					table.insert(decoded.Staffs, foundItem.Name)
				else
					decoded.Staffs = {foundItem.Name}
				end

				playerInv.Value = http:JSONEncode(decoded)
			elseif foundItem:IsA("Model") and foundItem.Parent.Name == "Armor" then
				local playerInv = player.GameData.Inventory
				local decoded

				local s, _ = pcall(function()
					decoded = http:JSONDecode(playerInv.Value)
				end)

				if not s then
					decoded = {}
				end

				if decoded.Armor then
					table.insert(decoded.Armor, foundItem.Name)
				else
					decoded.Armor = {foundItem.Name}
				end

				playerInv.Value = http:JSONEncode(decoded)
			end
		else
			result = "Insufficient Funds"
		end
	else
		result = "Invalid Item Name"
	end

	purchaseEvent:FireClient(player, result)
end)

equipItemEvent.OnServerEvent:Connect(function(player, itemName)
	local foundItem = models:FindFirstChild(itemName, true)
	local success

	if foundItem then 
		local playerInventory = player.GameData.Inventory

		if playerInventory.Value:match(itemName) then
			if foundItem:IsA("Tool") then 
				local old = player.Character:FindFirstChildOfClass("Tool")
				if old then old:Destroy() end
				foundItem = foundItem:Clone()
				local s = ServerScriptService.NewTesting.StaffHandler:Clone()
				s.Parent = foundItem
				foundItem.Parent = player.Character
				player.GameData.Staff.Value = foundItem.Name
				success = true
			elseif foundItem:IsA("Model") and foundItem.Parent.Name == "Armor" then
				local character = player.Character 

				if character then 
					for _, v in character:GetChildren() do
						if v:IsA("Clothing") or v:IsA("CharacterMesh") or v:IsA("ShirtGraphic") or v:IsA("Accessory") then
							v:Destroy()
						end
					end

					for _, v in foundItem:GetChildren() do
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

					player.GameData.Armor.Value = foundItem.Name
					success = true 
				end
			end
		end
	end

	equipItemEvent:FireClient(player, success)
end)