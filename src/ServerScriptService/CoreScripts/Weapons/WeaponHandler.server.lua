local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local events = game.ReplicatedStorage.Events.Weapons
local swingEvent = events.SwingEvent
local useAbility = events.UseAbility

local abilities = require(script.Parent.Abilities)
local weapons = game.ReplicatedStorage.Models.Weapons

local abilityAssets = ServerStorage.AbilityAssets
local hitEffect = abilityAssets.Attack.Zap

swingEvent.OnServerEvent:Connect(function(player, mouseTarget : Part)
	local character = player.Character or nil
	
	if character then 
		local foundStaff = character:FindFirstChildOfClass("Tool")
		
		if foundStaff and weapons:FindFirstChild(foundStaff.Name) then
			local damage, attackSpeed, range = foundStaff:GetAttribute('Damage'), foundStaff:GetAttribute("AttackSpeed"), foundStaff:GetAttribute("Range")
			local characterPos = character:GetPivot().Position
			local hitChar = mouseTarget:FindFirstAncestorOfClass("Model")
			
			if hitChar and hitChar:FindFirstChild("Humanoid") and (characterPos - hitChar:GetPivot().Position).Magnitude <= range then
				local hitHumanoid = hitChar.Humanoid
				
				local lastSwung = player:GetAttribute("LastSwung")
				local currentTime = os.clock()

				if currentTime - lastSwung >= attackSpeed then 
					player:SetAttribute("LastSwung", os.clock())

					hitHumanoid:TakeDamage(damage)
					swingEvent:FireClient(player, true)

					local zap = hitEffect:Clone()
					zap.Parent = workspace

					local enemyPos = hitChar.PrimaryPart.Position
					characterPos = character.HumanoidRootPart.Position
					local midPoint = Vector3.new((enemyPos.X + characterPos.X) / 2, (enemyPos.Y + characterPos.Y) / 2, (enemyPos.Z + characterPos.Z) / 2)
					local size = Vector3.new(zap.Size.X, zap.Size.Y, (characterPos - enemyPos).Magnitude)

					zap.CFrame = CFrame.lookAt(midPoint, enemyPos)
					Debris:AddItem(zap, .3)

					TweenService:Create(zap, TweenInfo.new(.05), {Size = size}):Play()
				end
			else
				swingEvent:FireClient(player, false)
			end
		else
			swingEvent:FireClient(player, false)
		end
	else
		swingEvent:FireClient(player, false)
	end
end)

useAbility.OnServerEvent:Connect(function(player, abilityName, abilityNum, mousePos)
	local character = player.Character
	local success
	
	if character and character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		local staff = character:FindFirstChildOfClass("Tool")
		
		if staff then 
			local func = abilities[abilityName]
			
			if func then
				local plrSetup = player.GameData.PlayerSetup.Value

				if plrSetup:match(abilityName) then 
					func(player, character, staff, abilityNum, mousePos)
					success = abilityName
				end
			end
		end
	end
	useAbility:FireClient(player, nil, success)
end)