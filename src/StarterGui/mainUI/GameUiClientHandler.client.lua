local ui = script.Parent
local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local shopBuyRemote = events:WaitForChild("Gameplay"):WaitForChild("ItemShopPurchase")
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid : Humanoid = character:WaitForChild("Humanoid")

local tweenService = game:GetService("TweenService")
local content = game:GetService("ContentProvider")

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
	if shopFrame.Visible and cantween then
		openUi(shopOriginalPos, shopFrame)

		for _, con in shopButtonConnections do
			con:Disconnect()
		end
	end
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