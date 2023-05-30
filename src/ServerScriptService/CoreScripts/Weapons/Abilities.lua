local module = {}

local useAbility = game.ReplicatedStorage.Events.Weapons.UseAbility
local zoneModule = require(game.ServerScriptService.CoreScripts.Zone)

local runService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")

local abilityItems = ServerStorage.AbilityAssets

local fastCast = require(script.Parent.FastCastRedux)

local abilityStats = {
	Ability1 = {
		Damage = 10,
		AttackDelay = 1
	},
	Ability2 = {
		Damage = 15,
		AttackDelay = 1
	},
	IceMeteor = {
		Damage = 35,
		ProjectileSpeed = 120,
		Delay = .5,
		MaxRange = 300
	}
}

function module.Ability1(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)

		local stats = abilityStats.Ability1

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
			if os.clock() - lastAttacked >= stats.AttackDelay then 
				lastAttacked = os.clock()
				for i, char in toAttack do
					if char.Humanoid then 
						char.Humanoid:TakeDamage(stats.Damage)
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
		local stats = abilityStats.Ability2

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
				if os.clock() - lastTime >= stats.AttackDelay then
					lastTime = os.clock()

					for _, model in toAttack do
						model.Humanoid:TakeDamage(stats.Damage)

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

function module.IceMeteor(player, character, staff, abilityNum, mousePos)
	local iceStats = abilityStats.IceMeteor
	local caster = fastCast.new()
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local behavior = fastCast.newBehavior()
	behavior.RaycastParams = rayParams
	behavior.MaxDistance = iceStats.MaxRange
	behavior.Acceleration = Vector3.zero
	behavior.CosmeticBulletTemplate = abilityItems.IceMeteor.Hitbox

	caster:Fire(character.HumanoidRootPart.Position, (mousePos - character.HumanoidRootPart.Position).Unit, iceStats.MaxRange, behavior)

	local bullet
	local first

	caster.LengthChanged:Connect(function(activeCast, lastPoint, rayDir, displacement, _, cosmeticBulletObject)
		if not first then
			first = true
			activeCast:AddVelocity(cosmeticBulletObject.CFrame.LookVector + Vector3.new(0,0, iceStats.ProjectileSpeed))
		end
		
		cosmeticBulletObject.Parent = workspace
		local blength = cosmeticBulletObject.Size.Z/2
		local offset = CFrame.new(0,0,-(displacement-blength))
		cosmeticBulletObject.CFrame = CFrame.lookAt(lastPoint, lastPoint+rayDir):ToWorldSpace(offset)

		bullet = cosmeticBulletObject
	end)

	useAbility:FireClient(player, "IceMeteor")
end

return module
