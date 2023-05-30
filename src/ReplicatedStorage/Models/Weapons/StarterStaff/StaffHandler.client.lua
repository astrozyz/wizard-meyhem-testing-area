repeat task.wait() until _G.Cooldowns
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local context = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")

local swingAnimation = character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script:WaitForChild("AttackAnimation"))
local ability1Animation = character.Humanoid.Animator:LoadAnimation(script:WaitForChild("Ability1Animation"))
local ability2Animation = character.Humanoid.Animator:LoadAnimation(script:WaitForChild("Ability2Animation"))

local mouse = player:GetMouse()
local staff = script.Parent

local attackSpeed = staff:GetAttribute("AttackSpeed")
local ability1Speed = staff:GetAttribute("Ability1Speed")
local ability2Speed = staff:GetAttribute("Ability2Speed")
local canAttack = true

local events = game.ReplicatedStorage:WaitForChild("Events")
local weaponEvents = events:WaitForChild("Weapons")
local swingEvent = weaponEvents:WaitForChild("SwingEvent")
local useAbility = weaponEvents:WaitForChild("UseAbility")

local cooldownGoals = {Offset = Vector2.new(0, -1)}
local cooldownBeginning = Vector2.zero

local toolbar = player:WaitForChild("PlayerGui"):WaitForChild("Toolbar"):WaitForChild("Holder")
local autoUi = toolbar:WaitForChild("Auto")
local ability1Ui = toolbar:WaitForChild("Ability1")
local ability2Ui = toolbar:WaitForChild("Ability2")
local canAbility1 = true 
local canAbility2 = true

local ability1Name = "Ability1"
local ability2Name = "IceMeteor"

local function cooldownVisualizer(speed, typ, ui)
	local timeStarted = os.clock()
	table.insert(_G.Cooldowns, {timeStarted, speed, function() if typ then canAttack = true end; ui.CooldownText.Visible = false end, function()
		local elapsedTime = os.clock() - timeStarted
		local timeRemaining = speed - elapsedTime 
		timeRemaining = math.floor(timeRemaining * 100)/100
		ui.CooldownText.Text = timeRemaining
	end})
	ui.UIGradient.Offset = cooldownBeginning
	ui.UIGradient.Enabled = true 
	ui.CooldownText.Visible = true
	local cdTween = TweenService:Create(ui.UIGradient, TweenInfo.new(speed), cooldownGoals)
	cdTween:Play()

	cdTween.Completed:Once(function()
		ui.UIGradient.Enabled = false
	end) 
end

local function attack(_, inputState)
	if inputState == Enum.UserInputState.Begin then
		if canAttack then
			swingEvent:FireServer(mouse.Target)
			
			swingEvent.OnClientEvent:Once(function(result)
				if result == true then 
					canAttack = false
					
					swingAnimation:Play()
					cooldownVisualizer(attackSpeed, true, autoUi)
				end
			end)
		end
	end
end

local function ability1Func(name, inputState)
	if inputState == Enum.UserInputState.Begin then
		if uis.TouchEnabled then 
			if not canAbility1 then return end
		end
			
		useAbility:FireServer(name, 1, mouse.Hit.Position)

		useAbility.OnClientEvent:Connect(function(_, result)
			if result == name then 
				canAbility1 = false
				canAbility2 = false
				ability1Animation:Play()
				ability1Ui.UIGradient.Offset = cooldownBeginning
				ability1Ui.UIGradient.Enabled = true 
				context:UnbindAction(ability1Name)
				context:UnbindAction(ability2Name)
			end
		end)
	end
end

local function ability2Func(name, inputState)
	if inputState == Enum.UserInputState.Begin then
		if uis.TouchEnabled then 
			if not canAbility2 then return end
		end
		useAbility:FireServer(name, 2, mouse.Hit.Position)

		useAbility.OnClientEvent:Connect(function(_, result)
			if result == name then 
				canAbility1 = false
				canAbility2 = false
				ability2Animation:Play()
				ability2Ui.UIGradient.Offset = cooldownBeginning
				ability2Ui.UIGradient.Enabled = true 
				context:UnbindAction(ability1Name)
				context:UnbindAction(ability2Name)
			end
		end)
	end
end

staff.Equipped:Connect(function()
	context:BindAction(ability1Name, ability1Func, false, Enum.KeyCode.E)
	context:BindAction(ability2Name, ability2Func, false, Enum.KeyCode.Q)
	canAbility2 = true 
	canAbility1 = true
	
	context:BindAction("Attack", attack, false, Enum.KeyCode.F)
end)

staff.Unequipped:Connect(function()
	context:UnbindAction(ability1Name)
	context:UnbindAction(ability2Name)
	context:UnbindAction("Attack")
end)

useAbility.OnClientEvent:Connect(function(result)
	if result then
		print(result)
		if result == ability1Name then 
			cooldownVisualizer(staff:GetAttribute("Ability1Speed"), false, ability1Ui)
			context:BindAction(ability2Name, ability2Func, false, Enum.KeyCode.Q)
			canAbility2 = true
			table.insert(_G.Cooldowns, {os.clock(), ability1Speed, function() context:BindAction(ability1Name, ability1Func, false, Enum.KeyCode.E); canAbility1 = true end})
		elseif result == ability2Name then
			cooldownVisualizer(staff:GetAttribute("Ability2Speed"), false, ability2Ui)
			context:BindAction(ability1Name, ability1Func, false, Enum.KeyCode.E)
			canAbility1 = true
			table.insert(_G.Cooldowns, {os.clock(), ability2Speed, function() context:BindAction(ability2Name, ability2Func, false, Enum.KeyCode.Q); canAbility2 = true end})
		end
	end
end)

if uis.TouchEnabled then 
	ability1Ui.Icon.MouseButton1Click:Connect(function()
		ability1Func(ability1Name, Enum.UserInputState.Begin)
	end)

	ability2Ui.Icon.MouseButton1Click:Connect(function()
		ability2Func(ability2Name, Enum.UserInputState.Begin)
	end)

	staff.Activated:Connect(function()
		attack("Attack", Enum.UserInputState.Begin)
	end)
end

--[[
ui.UIGradient.Offset = cooldownBeginning
ui.UIGradient.Enabled = true 
--]]