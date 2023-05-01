local module = {}

local useAbility = game.ReplicatedStorage.Events.Weapons.UseAbility
local zoneModule = require(game.ServerScriptService.CoreScripts.Zone)

local runService = game:GetService("RunService")

function module.StarterStaff(player, character, staff)
	local gameData = player.GameData
		if os.clock() - player:GetAttribute("LastAbility") >= staff:GetAttribute("AbilitySpeed") and not player:GetAttribute("CanAbility") then
		print("is running")
		useAbility:FireClient(player, true)
		player:SetAttribute("CanAbility", true)

		local hbPart = Instance.new("Part")
		hbPart.Size = Vector3.new(32, 10, 32)
		hbPart.Transparency = 1
		hbPart.CastShadow = false
		hbPart:PivotTo(character:GetPivot())
		hbPart.CanCollide = false

		local weldConst = Instance.new("WeldConstraint")
		weldConst.Part0 = character.HumanoidRootPart
		weldConst.Part1 = hbPart

		hbPart.Parent = character
		weldConst.Parent = weldConst.Part0

		game.Debris:AddItem(hbPart, 8.07)
		game.Debris:AddItem(weldConst, 8.07)

		local hb = zoneModule.new(hbPart)

		local partsInside = hb:getParts()
		local toAttack = {}

		for _, part : BasePart in partsInside do 
			local possibleCharacter = part:FindFirstAncestorOfClass("Model")

			if possibleCharacter and not table.find(toAttack, possibleCharacter) then
				local possibleHum = possibleCharacter:FindFirstChildOfClass("Humanoid") 

				if possibleHum and possibleHum ~= character.Humanoid then 
					table.insert(toAttack, possibleCharacter)
				end
			end
		end

		local entered

		entered = hb.partEntered:Connect(function(part)
			local possibleCharacter = part:FindFirstAncestorOfClass("Model")

			if possibleCharacter and not table.find(toAttack, possibleCharacter) then
				local possibleHum = possibleCharacter:FindFirstChildOfClass("Humanoid") 

				if possibleHum and possibleHum ~= character.Humanoid then 
					table.insert(toAttack, possibleCharacter)
				end
			end
		end)
		
		local exited
		
		exited = hb.partExited:Connect(function(part)
			local possibleCharacter = part:FindFirstAncestorOfClass("Model")
			if possibleCharacter and table.find(toAttack, possibleCharacter) then
				local possibleHum = possibleCharacter:FindFirstChildOfClass("Humanoid") 

				if possibleHum and possibleHum ~= character.Humanoid then
					table.remove(toAttack, table.find(toAttack, possibleCharacter))
				end
			end
		end)

		local lastAttacked = 0
		local renderstepped

		renderstepped = runService.Heartbeat:Connect(function()
			if os.clock() - lastAttacked >= 1 then 
				lastAttacked = os.clock()
				for i, char in toAttack do
					if char.Humanoid then 
						char.Humanoid:TakeDamage(10)
					else
						table.remove(toAttack, i)
					end
				end
			end
		end)
		
		task.delay(8, function()
			renderstepped:Disconnect()
			exited:Disconnect()
			entered:Disconnect()
			toAttack = {}
			hb:Destroy()
			
			player:SetAttribute("LastAbility", os.clock())
			player:SetAttribute("CanAbility", nil)
		end)
	end
end

return module
