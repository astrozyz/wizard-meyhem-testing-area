local player = game:GetService("Players").LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")

local money = leaderstats:WaitForChild("Money")
local mana = leaderstats:WaitForChild("Mana")

local coinsUi = script.Parent:WaitForChild("Coins"):WaitForChild("TextLabel")
local manaUi = script.Parent:WaitForChild("Mana"):WaitForChild("TextLabel")

coinsUi.Text = money.Value
manaUi.Text = mana.Value

money.Changed:Connect(function()
	coinsUi.Text = money.Value
end)

mana.Changed:Connect(function()
	manaUi.Text = mana.Value
end)