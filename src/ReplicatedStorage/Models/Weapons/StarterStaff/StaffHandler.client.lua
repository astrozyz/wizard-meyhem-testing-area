repeat task.wait() until _G.Cooldowns
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local context = game:GetService("ContextActionService")

local swingAnimation = character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script:WaitForChild("AttackAnimation"))
local abilityAnimation = character.Humanoid.Animator:LoadAnimation(script:WaitForChild("AbilityAnimation"))

local mouse = player:GetMouse()
local staff = script.Parent

local attackSpeed = staff:GetAttribute("AttackSpeed")
local canAttack = true

local events = game.ReplicatedStorage:WaitForChild("Events")
local weaponEvents = events:WaitForChild("Weapons")
local swingEvent = weaponEvents:WaitForChild("SwingEvent")
local useAbility = weaponEvents:WaitForChild("UseAbility")

local function attack(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		if canAttack then
			swingEvent:FireServer(mouse.Target)
			
			swingEvent.OnClientEvent:Once(function(result)
				if result == true then 
					canAttack = false
					table.insert(_G.Cooldowns, {os.clock(), attackSpeed, function() canAttack = true end})
					swingAnimation:Play()
				end
			end)
		end
	end
end

local function abilityFunc(name, inputState)
	if inputState == Enum.UserInputState.Begin then
		useAbility:FireServer()
	end
end

staff.Equipped:Connect(function()
	context:BindAction("Ability", abilityFunc, false, Enum.KeyCode.E)
	context:SetTitle("Ability", "Ability")
	context:BindAction("Attack", attack, false, Enum.KeyCode.F)
end)

staff.Unequipped:Connect(function()
	context:UnbindAction("Ability")
	context:UnbindAction("Attack")
end)

useAbility.OnClientEvent:Connect(function(result)
	if result then
		abilityAnimation:Play()
	end
end)