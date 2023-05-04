local zoneModule = require(script.Parent.Parent.Zone)
local sellFolder = workspace.Zones.Sell

local http = game:GetService("HttpService")
local zone = zoneModule.new(sellFolder)

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

				if decoded[foundItem.Parent.Name] and decoded[foundItem.Parent.Name][itemName] then 
					decoded[foundItem.Parent.Name][itemName] += 1
				else
					decoded[foundItem.Parent.Name][itemName] = 1
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
		local playerInventory = http:JSONDecode(player.GameData.Inventory.Value)

		if playerInventory[foundItem.Parent.Name][foundItem.Name] > 0 then
			if foundItem:IsA("Tool") then 
				local old = player.Character:FindFirstChildOfClass("Tool")
				if old then old:Destroy() end
				foundItem:Clone().Parent = player.Character
				success = true
			end
		end
	end
	equipItemEvent:FireClient(player, success)
end)