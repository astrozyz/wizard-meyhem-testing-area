local ui = script.Parent
local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local shopBuyRemote = events:WaitForChild("Gameplay"):WaitForChild("ItemShopPurchase")
local player : Player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid : Humanoid = character:WaitForChild("Humanoid")

local gameData = player:WaitForChild("GameData")
local playerPets = gameData:WaitForChild("Pets")
local playerInv = gameData:WaitForChild("Inventory")

local tweenService = game:GetService("TweenService")
local content = game:GetService("ContentProvider")
local http = game:GetService("HttpService")

local models = game:GetService("ReplicatedStorage"):WaitForChild("Models")
local staffModels = models:WaitForChild("Weapons"):GetChildren()
local armorModels = models:WaitForChild("Armor"):GetChildren()
local potionModels = models:WaitForChild("Potions"):GetChildren()

local toLoad = {table.unpack(staffModels), table.unpack(armorModels), table.unpack(potionModels)}
content:PreloadAsync(toLoad)

local shopTemplate = script:WaitForChild("ShopTemplate")
local shopBtn = ui:WaitForChild("Shop")
local shopFrame = ui:WaitForChild("ItemShop")
local shopBuy = shopFrame:WaitForChild("Buy")
local itemName, itemPrice, itemSelected = shopFrame:WaitForChild("ItemName"), shopFrame:WaitForChild("ItemPrice"), shopFrame:WaitForChild("ItemSelected")
local attackDamage, attackRange, elementLable = shopFrame:WaitForChild("AD"), shopFrame:WaitForChild("AR"), shopFrame:WaitForChild("Element")
local shopClose = shopFrame:WaitForChild("Close")
local shopOriginalPos = shopFrame.Position
local shopScrollBar = shopFrame:WaitForChild('Items')
local armorTab, wandsTab, potionsTab = shopFrame:WaitForChild("Armor"), shopFrame:WaitForChild("Wands"), shopFrame:WaitForChild("Potions")
local shopButtonConnections = {}
shopFrame.Visible = false
local shopCurrentTab = wandsTab
local cantween = true

local xpUi = ui:WaitForChild("XP Bar")
local xpLevelNum = xpUi:WaitForChild("LevelHolder"):WaitForChild("Level")
local xpBar = xpUi:WaitForChild("Bar")
local xpProgress = xpUi:WaitForChild("Progress")

local function openUi(originalPos, tweenUi)
	if not tweenUi.Visible then
		cantween = false
		local uiTweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0)
		tweenUi.Position = UDim2.fromScale(0.229,1)
		tweenUi.Visible = true
		local tweenOnScreen = tweenService:Create(tweenUi, uiTweenInfo, {Position = originalPos})
		tweenOnScreen:Play()

		tweenOnScreen.Completed:Wait()
		cantween = true
	else
		cantween = false
		local uiTweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0, false)
		local tweenOffScreen = tweenService:Create(tweenUi, uiTweenInfo, {Position = UDim2.fromScale(0.229,1)})
		tweenOffScreen:Play()
		tweenOffScreen.Completed:Wait()

		tweenUi.Visible = false
		cantween = true
	end
end

local function closeButton(frame, originalPos, connections)
	if frame.Visible and cantween then
		openUi(originalPos, frame)
	
		if connections then 
			for _, con in connections do
				con:Disconnect()
			end
		end
	end
end

for _, v in staffModels do 
	local t = shopTemplate:Clone()
	t:WaitForChild("ItemName").Text = v.Name
	t.Image = v:GetAttribute("ShopIcon")
	t.Name = tostring(v:GetAttribute("ShopPrice"))
	t:SetAttribute("Element", v:GetAttribute("Element"))
	t:SetAttribute("Damage", v:GetAttribute("Damage"))
	t:SetAttribute("Range", v:GetAttribute("Range"))
	t.Parent = shopScrollBar
end

local function connectShopButtons()
	for _, btn in shopScrollBar:GetChildren() do
		if btn:IsA("ImageButton") then 
			local con = btn.MouseButton1Click:Connect(function()
				itemSelected.Image = btn.Image
				itemPrice.Text = btn.Name
				itemName.Text = btn.ItemName.Text

				if shopCurrentTab == wandsTab then 
					attackDamage.Text = "Damage: ".. tostring(btn:GetAttribute("Damage"))
					attackRange.Text = "Range: ".. tostring(btn:GetAttribute("Range"))
					elementLable.Text = "Element: ".. btn:GetAttribute("Element")
				elseif shopCurrentTab == armorTab then 
					elementLable.Text = "Protection: ".. btn:GetAttribute("Protection")
				else
					elementLable.Text = "Effect: ".. btn:GetAttribute("Effect")
				end
			end)

			table.insert(shopButtonConnections, con)
		end
	end
end

shopBtn.MouseButton1Click:Connect(function()
	if not shopFrame.Visible and cantween then
		print("sdfsdf")

		connectShopButtons()

		local wandsCon = wandsTab.MouseButton1Click:Connect(function()
			for _, v in shopScrollBar:GetChildren() do 
				if v:IsA("ImageButton") then 
					v:Destroy()
				end
			end

			for _, v in staffModels do 
				local t = shopTemplate:Clone()
				t:WaitForChild("ItemName").Text = v.Name
				t.Image = v:GetAttribute("ShopIcon")
				t.Name = tostring(v:GetAttribute("ShopPrice"))
				t:SetAttribute("Element", v:GetAttribute("Element"))
				t:SetAttribute("Damage", v:GetAttribute("Damage"))
				t:SetAttribute("Range", v:GetAttribute("Range"))
				t.Parent = shopScrollBar
			end
			shopCurrentTab = wandsTab

			itemSelected.Image = "rbxassetid://0"
			itemPrice.Text = ""
			itemName.Text = ""

			attackDamage.Text = ""
			attackRange.Text = ""
			elementLable.Text = ""

			connectShopButtons()
		end)

		table.insert(shopButtonConnections, wandsCon)

		local armorCon = armorTab.MouseButton1Click:Connect(function()
			for _, v in shopScrollBar:GetChildren() do 
				if v:IsA("ImageButton") then 
					v:Destroy()
				end
			end

			for _, v in armorModels do 
				local t = shopTemplate:Clone()
				t:WaitForChild("ItemName").Text = v.Name
				t.Image = v:GetAttribute("ShopIcon")
				t.Name = tostring(v:GetAttribute("ShopPrice"))
				t:SetAttribute("Protection", v:GetAttribute("Protection"))
				t.Parent = shopScrollBar
			end
			shopCurrentTab = armorTab

			itemSelected.Image = "rbxassetid://0"
			itemPrice.Text = ""
			itemName.Text = ""

			attackDamage.Text = ""
			attackRange.Text = ""
			elementLable.Text = ""

			connectShopButtons()
		end)

		table.insert(shopButtonConnections, armorCon)

		local potionsCon = potionsTab.MouseButton1Click:Connect(function()
			for _, v in shopScrollBar:GetChildren() do 
				if v:IsA("ImageButton") then 
					v:Destroy()
				end
			end

			for _, v in potionModels do 
				local t = shopTemplate:Clone()
				t:WaitForChild("ItemName").Text = v.Name
				t.Image = v:GetAttribute("ShopIcon")
				t.Name = tostring(v:GetAttribute("ShopPrice"))
				t:SetAttribute("Effect", v:GetAttribute("Effect"))
				t.Parent = shopScrollBar
			end
			shopCurrentTab = potionsTab

			itemSelected.Image = "rbxassetid://0"
			itemPrice.Text = ""
			itemName.Text = ""

			attackDamage.Text = ""
			attackRange.Text = ""
			elementLable.Text = ""

			connectShopButtons()
		end)

		table.insert(shopButtonConnections, potionsCon)

		local buyCon = shopBuy.MouseButton1Click:Connect(function()
			if itemSelected.Image then 
				shopBuyRemote:FireServer(itemName.Text)
			end
		end)
		
		openUi(shopOriginalPos, shopFrame)
	end
end)

shopClose.MouseButton1Click:Connect(function()
	closeButton(shopFrame, shopOriginalPos, shopButtonConnections)
end)

repeat task.wait() until player:GetAttribute("Level") and player:GetAttribute("XP")
xpLevelNum.Text = tostring(player:GetAttribute("Level"))

player:GetAttributeChangedSignal("Level"):Connect(function()
	xpLevelNum.Text = tostring(player:GetAttribute("Level"))
end)

local oldXP = player:GetAttribute("XP")
xpProgress.Text = tostring(oldXP).. "/".. tostring(750 * (player:GetAttribute("Level") + 0.5))
xpBar.Size = UDim2.fromScale(math.clamp(oldXP/(750 * (player:GetAttribute("Level") + 0.5)), 0, 1), 1)

player:GetAttributeChangedSignal("XP"):Connect(function()
	local currentXP = player:GetAttribute("XP")
	local maxLevel = 750 * (player:GetAttribute("Level") + 0.5)

	if currentXP < oldXP then
		local tweenBack = tweenService:Create(xpBar, TweenInfo.new(.2), {Size = UDim2.fromScale(0,1)})
		tweenBack:Play()
		tweenBack.Completed:Wait()

		tweenService:Create(xpBar, TweenInfo.new(.2), {Size = UDim2.fromScale(math.clamp(currentXP/maxLevel, 0, 1),1)}):Play()
	else
		tweenService:Create(xpBar, TweenInfo.new(.2), {Size = UDim2.fromScale(math.clamp(currentXP/maxLevel, 0, 1),1)}):Play()
	end
	oldXP = currentXP
	xpProgress.Text = tostring(currentXP).. "/".. tostring(maxLevel)
end)

local healthUi = ui:WaitForChild("Health")
local healthBar = healthUi:WaitForChild("Bar")

humanoid:GetPropertyChangedSignal("Health"):Connect(function()
	healthBar:TweenSize(UDim2.fromScale(0.816, -(math.clamp(humanoid.Health/humanoid.MaxHealth, 0, 1))), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .2, true)
end)

local pets = game:GetService("ReplicatedStorage").Pets

local petsUi = ui:WaitForChild("PetsFrame")
local petsOriginalPos = UDim2.new(0.223, 0,0.132, 0)
local petsBtn = ui:WaitForChild("Pets")
local petsClose = petsUi:WaitForChild("Close")
local petTemplate = script:WaitForChild("PetTemplate")
local currentPetSelected
local petsConnections = {}

local petInfo : Frame = petsUi:WaitForChild("Info")
local petName : TextLabel = petInfo:WaitForChild("PetName")
local petDesc : TextLabel = petInfo:WaitForChild("PetsDesc")
local petIcon : ImageLabel = petInfo:WaitForChild("Icon")
local petType : TextLabel = petInfo:WaitForChild("Type")
local petRarity : TextLabel = petInfo:WaitForChild("Rarity")
local petLvl : TextLabel = petInfo:WaitForChild("Lvl")
local petEquip : ImageButton = petInfo:WaitForChild("Equip")
local petUnequip :ImageButton = petInfo:WaitForChild("Unequip")

petsBtn.MouseButton1Click:Connect(function()
	if not petsUi.Visible and cantween then
		openUi(petsOriginalPos, petsUi)

		local decode = http:JSONDecode(playerPets.Value)

		if #decode > 0 then 
			for pet, amount in decode do
				local foundPet = pets:FindFirstChild(pet, true)

				if foundPet then 
					local template = petTemplate:Clone()
					template.ImageButton.Image = foundPet:GetAttribute("PetIcon")
					template.Parent = petsUi:WaitForChild("Pets"):WaitForChild("Holder")
					template.Name = foundPet.Name
					template:SetAttribute("Rarity", foundPet.Parent.Name)
					template:SetAttribute("Type", template:GetAttribute("Type"))
					
					local con = template.ImageButton.MouseButton1Click:Connect(function()
						currentPetSelected = template.Name

						petIcon.Image = template.ImageButton.Image
						petName.Text = template.Name
						petDesc.Text = "Test"
						petLvl.Text = "Level 1"
					end) 

					table.insert(petsConnections, con)
				end
			end
		end
	end
end) 

petsClose.MouseButton1Click:Connect(function()
	closeButton(petsUi, petsOriginalPos, petsConnections)
end)