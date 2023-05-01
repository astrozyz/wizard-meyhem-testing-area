local events = game.ReplicatedStorage.Events.Weapons
local swingEvent = events.SwingEvent
local useAbility = events.UseAbility

local abilities = require(script.Parent.Abilities)
local weapons = game.ReplicatedStorage.Models.Weapons

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

useAbility.OnServerEvent:Connect(function(player)
	local character = player.Character
	
	if character and character.Humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		local staff = character:FindFirstChildOfClass("Tool")
		
		if staff then 
			local func = abilities[staff.Name]
			
			if func then
				func(player, character, staff)
			end
		end
	end
end)