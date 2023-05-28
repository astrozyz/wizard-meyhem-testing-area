local module = {}

local useAbility = game.ReplicatedStorage.Events.Weapons.UseAbility
local zoneModule = require(game.ServerScriptService.CoreScripts.Zone)

local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")

local abilityItems = game:GetService("ReplicatedStorage").Models.Abilities

local fastCast = require(script.Parent.FastCastRedux)

function module.Ability1(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
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

			player:SetAttribute("LastAbility".. abilityNum, os.clock())
			player:SetAttribute("CanAbility", nil)

			useAbility:FireClient(player, "Ability".. abilityNum)
		end)
	end
end

function module.Ability2(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)
		local abilityAssets = abilityItems.TestAbility1

		local firstVisual = abilityAssets.Visual:Clone()
		local firstHbPart = abilityAssets.Hitbox:Clone()

		firstVisual.Beam.Attachment1 = character.HumanoidRootPart.RootAttachment
		firstVisual:PivotTo(character:GetPivot())
		firstVisual.Parent = workspace

		local visualPosition = character:GetPivot() * CFrame.new(0,10,-10)

		local visualTweenUp = tweenService:Create(firstVisual, TweenInfo.new(1.5), {CFrame = visualPosition})
		visualTweenUp:Play()

		visualTweenUp.Completed:Once(function()
			firstVisual.Beam.Attachment1 = nil
			firstHbPart.Parent = workspace
			firstHbPart:PivotTo(visualPosition)

			local firstDetection = zoneModule.new(firstHbPart)

			local allParts = firstDetection:getParts()
			local toAttack = {}
			local renderstepped

			for _, part in allParts do 
				local foundCharacter = part:FindFirstAncestorOfClass("Model")

				if foundCharacter and foundCharacter:FindFirstChildOfClass("Humanoid") and foundCharacter ~= character and not table.find(toAttack, foundCharacter) then
					table.insert(toAttack, foundCharacter)
				end
			end

			local entered, exited

			entered = firstDetection.partEntered:Connect(function(part)
				local foundCharacter = part:FindFirstAncestorOfClass("Model")

				if foundCharacter and foundCharacter:FindFirstChildOfClass("Humanoid") and foundCharacter ~= character and not table.find(toAttack, foundCharacter) then 
					table.insert(toAttack, foundCharacter)
				end
			end)

			exited = firstDetection.partExited:Connect(function(part)
				local foundCharacter = part:FindFirstAncestorOfClass("Model")

				if foundCharacter and foundCharacter:FindFirstChildOfClass("Humanoid") and foundCharacter ~= character and table.find(toAttack, foundCharacter) then 
					table.remove(toAttack, table.find(toAttack, foundCharacter))
				end
			end)

			local lastTime = 0
			renderstepped = runService.Heartbeat:Connect(function()
				if os.clock() - lastTime >= 1 then
					lastTime = os.clock()

					for _, model in toAttack do
						model.Humanoid:TakeDamage(15)

						local newBeam = firstVisual.Beam:Clone()
						newBeam.Attachment1 = model.HumanoidRootPart.RootRigAttachment
						newBeam.Attachment0 = firstVisual.Attachment
						debris:AddItem(newBeam, .5)
						newBeam.Parent = firstVisual
					end
				end
			end)

			task.delay(5, function()
				renderstepped:Disconnect()
				entered:Disconnect()
				exited:Disconnect()
				firstVisual:Destroy()
				firstDetection:destroy()
				firstHbPart:Destroy()
				toAttack = {}

				player:SetAttribute("LastAbility".. abilityNum, os.clock())
				player:SetAttribute("CanAbility", nil)

				useAbility:FireClient(player, "Ability".. abilityNum)
			end)
		end)
	end
end

fastCast.VisualizeCasts = true

-- function module.IceMeteor(player, character, staff, abilityNum, mousePos)
-- 	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
-- 		player:SetAttribute("CanAbility", true)

-- 		local iceMeteorEffect = game.ServerStorage.AbilityAssets.IceMeteor.Hitbox

-- 		local rayParams = RaycastParams.new()
-- 		rayParams.FilterDescendantsInstances = {character}
-- 		rayParams.FilterType = Enum.RaycastFilterType.Blacklist

-- 		local behavior = fastCast.newBehavior()
-- 		behavior.RaycastParams = rayParams
-- 		behavior.MaxDistance = 500
-- 		behavior.Acceleration = Vector3.new(0,196.2, 500)
-- 		behavior.CosmeticBulletTemplate = iceMeteorEffect

-- 		local cons = {}

-- 		for i = 1, 2, 1 do
-- 			local caster = fastCast.new()
-- 			caster:Fire(character.Head.Position, (mousePos - character.Head.Position).Unit, 400, behavior)

-- 			table.insert(cons, caster.LengthChanged:Connect(function(_, lastPoint, rayDir, displacement, _, cosmeticBulletObject)
-- 				cosmeticBulletObject.Parent = workspace
-- 				local blength = cosmeticBulletObject.Size.Z/2
-- 				local offset = CFrame.new(0,0,-(displacement-blength))
-- 				cosmeticBulletObject.CFrame = CFrame.lookAt(lastPoint, lastPoint+rayDir):ToWorldSpace(offset)
-- 			end))

-- 			local hitCon
-- 			hitCon = caster.RayHit:Connect(function(_, result, _, cosmeticBulletObject)
-- 				cosmeticBulletObject:Destroy()
				
-- 				if result and result.Instance then 
-- 					local model = result.Instance:FindFirstAncestorOfClass("Model")
					
-- 					if model and model:FindFirstChildOfClass("Humanoid") then 
-- 						local hitHum = model.Humanoid
-- 						hitHum:TakeDamage(35)
-- 					end
-- 				end
	
-- 				local foundIndex = table.find(cons, hitCon)
-- 				if foundIndex then
-- 					table.remove(cons, foundIndex)
-- 				end

-- 				hitCon:Disconnect()
-- 			end)

-- 			task.wait(1)
-- 		end

-- 		player:SetAttribute("LastAbility".. abilityNum, os.clock())
-- 		player:SetAttribute("CanAbility", nil)

-- 		useAbility:FireClient(player, "Ability".. abilityNum)
		
-- 	end
-- end

function module.IceMeteor(player, character, staff, abilityNum, mousePos)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)

		local iceMeteorEffect = game.ServerStorage.AbilityAssets.IceMeteor.Hitbox

		local cons = {}
		local zones = {}

		for i = 1, 2, 1 do
			local hitbox = iceMeteorEffect:Clone()
			hitbox.Parent = workspace
			
			local zoneHb = zoneModule.new(hitbox)
			table.insert(zones, zoneHb)

			local onHit

			onHit = zoneHb.itemEntered:Conncet(function(item)
				local enemy = item:FindFirstAncestorOfClass("Model")

				if enemy and enemy:FindFirstChildOfClass("Humanoid") then
					local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")

					if enemyHumanoid:GetState() ~= Enum.HumanoidStateType.Dead and enemyHumanoid ~= character.Humanoid then
						enemyHumanoid:TakeDamage(35)
						onHit:Disconnect()
						zoneHb:destroy()
						hitbox:Destroy()
					end
				end
			end)

			hitbox.CFrame = character.HumanoidRootPart.CFrame
			runService:BindToRenderStep("IceMeteor".. i, Enum.RenderPriority.Last, function()
				hitbox.CFrame = hitbox.CFrame * CFrame.new(0,0,0.3)
			end)

			task.wait(1)
		end

		player:SetAttribute("LastAbility".. abilityNum, os.clock())
		player:SetAttribute("CanAbility", nil)

		useAbility:FireClient(player, "Ability".. abilityNum)
		
	end
end

return module
