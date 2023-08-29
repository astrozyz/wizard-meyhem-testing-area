local module = {}

local useAbility = game.ReplicatedStorage.Events.Weapons.UseAbility
local zoneModule = require(game.ServerScriptService.CoreScripts.Zone)

local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local runService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local tweenService = game:GetService("TweenService")
local VFXFolder = workspace.Effects
local abilityItems = ServerStorage.AbilityAssets

local fastCast = require(script.Parent.FastCastRedux)
local raycastHitbox = require(script.Parent.Parent.RaycastHitboxV4)
local grabMousePos = ReplicatedStorage.Events.Weapons.GetMousePos

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
		Cost = 215,
		Damage = 30,
		Cooldown = 10,
		Range = 50,
		Speed = 50
	},
	LightningStrike = {
		Cost = 235,
		Damage = 90,
		Cooldown = 12,
		Range = 40,
		ShockwaveRange = 20,
		ShockDamage = 30
	},
	EletricOrb = {
		Cost = 110,
		Damage = 45,
		Cooldown = 10,
		Range = 20,
		StunLength = 4,
		Speed = 50
	},
	Fireball = {
		Cost = 60,
		Damage = 30,
		Cooldown = 8,
		Range = 50,
		Speed = 50
	},
	Flare = {
		Cost = 60,
		Damage = 25,
		BurnLength = 7,
		Cooldown = 7,
		Range = 15
	},
	MeteorSwarm = {
		Cost = 185,
		MeteorDamage = 50,
		MeteorTime = 3,
		BurningTime = 3,
		BurningDamage = 5,
		Range = 15
	},
	Blizzard = {
		Cost = 200,
		Damage = 65,
		Cooldown = 10,
		SlowTime = 4,
		Range = 25
	}
}

-- function module.LightningStrike(player, character, staff, abilityNum)
-- 	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
-- 		player:SetAttribute("CanAbility", true)
-- 		local stats = abilityStats.Fireball


-- 		task.delay(stats.Cooldown, function()
-- 			player:SetAttribute("LastAbility".. abilityNum, os.clock())
-- 			player:SetAttribute("CanAbility", nil)
-- 			useAbility:FireClient(player, "Ability".. abilityNum)
-- 		end)
-- 	end
-- end

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

fastCast.VisualizeCasts = false

--LightningStrike
function module.LightningStrike(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)
		local strike = abilityStats.LightningStrike

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {character, VFXFolder}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		rayParams.RespectCanCollide = true

		grabMousePos:FireClient(player)
		local mouseCon
		mouseCon = grabMousePos.OnServerEvent:Connect(function(p, mousePos)
			if p == player then
				mouseCon:Disconnect()

				local ray = workspace:Raycast(character.HumanoidRootPart.Position, (mousePos - character.HumanoidRootPart.Position).Unit * strike.Range, rayParams)

				if ray and ray.Instance then
					local hitCharacter = ray.Instance:FindFirstAncestorOfClass("Model")

					if hitCharacter and hitCharacter:FindFirstChild("Humanoid") then
						hitCharacter.Humanoid:TakeDamage(strike.Damage)
						local hitPos = hitCharacter.HumanoidRootPart.Position
						local fx = abilityItems.LightningStrike.FX:Clone()

						for _, toEnable in fx:GetDescendants() do
							if toEnable:IsA("ParticleEmitter") or toEnable:IsA("Beam") and toEnable.Name ~= "FirstBeam" then
								toEnable.Enabled = false
							end
						end

						fx.FirstAttach.Position = Vector3.new(0, 17.75, 0)
						fx.Position = Vector3.new(hitPos.X, fx.Size.Y / 2, hitPos.Z)
						fx.Parent = workspace

						local tweenDown = tweenService:Create(fx.FirstAttach, TweenInfo.new(.5), {Position = Vector3.new(0, -12.25, 0)})
						tweenDown:Play()
						tweenDown.Completed:Once(function()
							for _, emitter in fx.EnableSecond:GetChildren() do
								emitter.Enabled = true
							end

								for _, toEnable in fx:GetDescendants() do
									if toEnable:IsA("ParticleEmitter") or toEnable:IsA("Beam") then
										toEnable.Enabled = true
									end
								end
								local hitbox = Instance.new("Part")
								hitbox.Name = "Hitbox"
								hitbox.Shape = Enum.PartType.Cylinder
								hitbox.Anchored = true 
								hitbox.CanCollide = false
								hitbox.Transparency = 1

								hitbox.Size = Vector3.new(strike.Range, fx.Size.Y, strike.Range)
								hitbox.Position = fx.Position
								hitbox.Parent = workspace 

								local touching = workspace:GetPartsInPart(hitbox)
								local alreadyAttacked = {}
								for _, part in touching do
									local foundChar = part:FindFirstAncestorOfClass("Model")

									if foundChar and foundChar:FindFirstChild("Humanoid") and not table.find(alreadyAttacked, foundChar) and foundChar ~= character and foundChar ~= hitCharacter then
										table.insert(alreadyAttacked, foundChar)
										foundChar.Humanoid:TakeDamage(strike.ShockDamage)
									end
								end

								hitbox:Destroy()

								Debris:AddItem(fx, .5)
							end)

					end
				end

				task.delay(strike.Cooldown, function()
					player:SetAttribute("LastAbility".. abilityNum, os.clock())
					player:SetAttribute("CanAbility", nil)
					useAbility:FireClient(player, "Ability".. abilityNum)
				end)
			end
		end)
	end
end

-- set walkspeed to 0
function module.EletricOrb(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)
		local stats = abilityStats.EletricOrb
		
		grabMousePos:FireClient(player)
		local mouseCon

		mouseCon = grabMousePos.OnServerEvent:Connect(function(p, mousePos)
			if p == player then
				mouseCon:Disconnect()
				local hitbox
				local bullet = abilityItems.ElectricOrb.FX:Clone()
				bullet.Parent = workspace.Effects

				bullet.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)

				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {character, VFXFolder}
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
		
				local caster = fastCast.new()
		
				local behavior = fastCast.newBehavior()
				behavior.RaycastParams = rayParams
				behavior.MaxDistance = stats.Range
		
				caster:Fire(character.HumanoidRootPart.Position, (mousePos - character.HumanoidRootPart.Position), stats.Speed, behavior)
				
				local lengthChanged, termninating, hit, actualHit

				lengthChanged = caster.LengthChanged:Connect(function(activeCast, lastPoint, rayDir, displacement)
					local blength = bullet.Size.Z/2
					local offset = CFrame.new(0,0,-(displacement-blength))
					bullet:PivotTo(CFrame.lookAt(lastPoint, lastPoint+rayDir):ToWorldSpace(offset))
		
					if not hitbox then
						hitbox = raycastHitbox.new(bullet)
						hitbox.RaycastParams = RaycastParams.new()
						hitbox.RaycastParams.FilterDescendantsInstances = {bullet, character, workspace.Effects}
						hitbox.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
		
						hitbox:HitStart()
		
						actualHit = hitbox.OnHit:Connect(function(part)
							local foundModel = part:FindFirstAncestorOfClass("Model")
							if foundModel and foundModel:FindFirstChildOfClass("Humanoid") then
								local hum = foundModel:FindFirstChildOfClass("Humanoid")
								print(part)
								hum:TakeDamage(stats.Damage)

								foundModel.HumanoidRootPart.Anchored = true

								task.delay(stats.StunLength, function()
									foundModel.HumanoidRootPart.Anchored = false
								end)
							end
		
							actualHit:Disconnect()
							hitbox:HitStop()
							hitbox:Destroy()
							activeCast:Terminate()
						end)
					end
				end)

				hit = caster.RayHit:Connect(function()
					-- local impactEffect = slashParticles.Impact:Clone()
					-- impactEffect.Parent = effectsFolder
					-- impactEffect.CFrame = bullet.CFrame
		
					-- for _, effect in impactEffect:GetDescendants() do
					-- 	if effect:IsA("ParticleEmitter") then
					-- 		effect:Emit(5)
					-- 	end
					-- end
					-- Debris:AddItem(impactEffect, 2)
		
					for _, v in bullet:GetDescendants() do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
		
					Debris:AddItem(bullet, 2)
		
					termninating:Disconnect()
					lengthChanged:Disconnect()
					lengthChanged = nil
					hit:Disconnect()
				end)
		
				termninating = caster.CastTerminating:Connect(function()
					termninating:Disconnect()
					lengthChanged:Disconnect()
					lengthChanged = nil
					hit:Disconnect()
					print("Terminating")
		
					for _, v in bullet:GetDescendants() do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
		
					Debris:AddItem(bullet, 2)
					bullet = nil
				end)
		
				task.delay(stats.Cooldown, function()
					player:SetAttribute("LastAbility".. abilityNum, os.clock())
					player:SetAttribute("CanAbility", nil)
					useAbility:FireClient(player, "Ability".. abilityNum)

					if lengthChanged then lengthChanged:Disconnect(); lengthChanged = nil end
					if hit then hit:Disconnect() end
					if actualHit then actualHit:HitStop(); actualHit:Destroy() end
					if termninating then termninating:Disconnect() end
					if bullet then bullet:Destroy() end
				end)
			end
		end)
	end
end

function module.Fireball(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)
		local stats = abilityStats.Fireball
		
		grabMousePos:FireClient(player)
		local mouseCon

		mouseCon = grabMousePos.OnServerEvent:Connect(function(p, mousePos)
			if p == player then
				mouseCon:Disconnect()
				local hitbox
				local bullet = abilityItems.Fireball.FX:Clone()
				bullet.Parent = workspace.Effects

				bullet.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)

				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {character, VFXFolder}
				rayParams.FilterType = Enum.RaycastFilterType.Exclude
		
				local caster = fastCast.new()
		
				local behavior = fastCast.newBehavior()
				behavior.RaycastParams = rayParams
				behavior.MaxDistance = stats.Range
		
				caster:Fire(character.HumanoidRootPart.Position, (mousePos - character.HumanoidRootPart.Position), stats.Speed, behavior)
				
				local lengthChanged, termninating, hit, actualHit

				lengthChanged = caster.LengthChanged:Connect(function(activeCast, lastPoint, rayDir, displacement)
					local blength = bullet.Size.Z/2
					local offset = CFrame.new(0,0,-(displacement-blength))
					bullet:PivotTo(CFrame.lookAt(lastPoint, lastPoint+rayDir):ToWorldSpace(offset))
		
					if not hitbox then
						hitbox = raycastHitbox.new(bullet)
						hitbox.RaycastParams = RaycastParams.new()
						hitbox.RaycastParams.FilterDescendantsInstances = {bullet, character, workspace.Effects}
						hitbox.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
		
						hitbox:HitStart()
		
						actualHit = hitbox.OnHit:Connect(function(part)
							local foundModel = part:FindFirstAncestorOfClass("Model")
							if foundModel and foundModel:FindFirstChildOfClass("Humanoid") then
								local hum = foundModel:FindFirstChildOfClass("Humanoid")
								print(part)
								hum:TakeDamage(stats.Damage)
							end
		
							actualHit:Disconnect()
							hitbox:HitStop()
							hitbox:Destroy()
							activeCast:Terminate()
						end)
					end
				end)

				hit = caster.RayHit:Connect(function()
					-- local impactEffect = slashParticles.Impact:Clone()
					-- impactEffect.Parent = effectsFolder
					-- impactEffect.CFrame = bullet.CFrame
		
					-- for _, effect in impactEffect:GetDescendants() do
					-- 	if effect:IsA("ParticleEmitter") then
					-- 		effect:Emit(5)
					-- 	end
					-- end
					-- Debris:AddItem(impactEffect, 2)
		
					for _, v in bullet:GetDescendants() do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
		
					Debris:AddItem(bullet, 2)
		
					termninating:Disconnect()
					lengthChanged:Disconnect()
					lengthChanged = nil
					hit:Disconnect()
				end)
		
				termninating = caster.CastTerminating:Connect(function()
					termninating:Disconnect()
					lengthChanged:Disconnect()
					lengthChanged = nil
					hit:Disconnect()
					print("Terminating")
		
					for _, v in bullet:GetDescendants() do
						if v:IsA("ParticleEmitter") then
							v.Enabled = false
						end
					end
		
					Debris:AddItem(bullet, 2)
					bullet = nil
				end)
		
				task.delay(stats.Cooldown, function()
					player:SetAttribute("LastAbility".. abilityNum, os.clock())
					player:SetAttribute("CanAbility", nil)
					useAbility:FireClient(player, "Ability".. abilityNum)

					if lengthChanged then lengthChanged:Disconnect(); lengthChanged = nil end
					if hit then hit:Disconnect() end
					if actualHit then actualHit:HitStop(); actualHit:Destroy() end
					if termninating then termninating:Disconnect() end
					if bullet then bullet:Destroy() end
				end)
			end
		end)
	end
end

function module.Flare(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)
		local stats = abilityStats.Flare

		local mouseGrab 

		grabMousePos:FireClient(player)

		mouseGrab = grabMousePos.OnServerEvent:Connect(function(p, mousePos)
			if p == player then
				mouseGrab:Disconnect()

				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {character, VFXFolder}
				rayParams.FilterType = Enum.RaycastFilterType.Exclude

				local ray = workspace:Raycast(character.HumanoidRootPart.Position, (mousePos - character.HumanoidRootPart.Position).Unit * stats.Range, rayParams)

				if ray and ray.Instance then
					local hitChar = ray.Instance:FindFirstAncestorOfClass("Model")

					if hitChar and hitChar:FindFirstChild("Humanoid") then
						local started = os.clock()
						local renderstepped
						local fx = abilityItems.Flare.FX:Clone()

						fx.Parent = VFXFolder
						
						local weld = Instance.new("Weld", fx)
						fx:PivotTo(hitChar.HumanoidRootPart:GetPivot())
						weld.Part0 = hitChar.HumanoidRootPart
						weld.Part1 = fx
						
						local lastChecked = os.clock()

						renderstepped = runService.Heartbeat:Connect(function()
							local elapsedTime = os.clock() - started

							if os.clock() - lastChecked >= 1 then
								lastChecked = os.clock()
								hitChar.Humanoid:TakeDamage(stats.Damage/stats.BurnLength)
							end

							if elapsedTime >= stats.BurnLength then
								renderstepped:Disconnect()
								fx:Destroy()
							end
						end)
					end
				end
			end

			task.delay(stats.Cooldown, function()
				player:SetAttribute("LastAbility".. abilityNum, os.clock())
				player:SetAttribute("CanAbility", nil)
				useAbility:FireClient(player, "Ability".. abilityNum)
			end)
		end)
	end
end

function module.MeteorSwarm(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)
		local stats = abilityStats.MeteorSwarm

		local mouseGrab 

		grabMousePos:FireClient(player)

		mouseGrab = grabMousePos.OnServerEvent:Connect(function(p, mousePos)
			if p == player then
				mouseGrab:Disconnect()

				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {character, VFXFolder}
				rayParams.FilterType = Enum.RaycastFilterType.Exclude

				local ray = workspace:Raycast(character.HumanoidRootPart.Position, (mousePos - character.HumanoidRootPart.Position).Unit * stats.Range, rayParams)

				if ray and ray.Instance then
					local hitChar = ray.Instance:FindFirstAncestorOfClass("Model")

					if hitChar and hitChar:FindFirstChild("Humanoid") then
						local started = os.clock()
						local renderstepped
						local fx = abilityItems.MeteorSwarm.FX:Clone()

						fx.Parent = VFXFolder
						
						local weld = Instance.new("Weld", fx)
						weld.Part0 = hitChar.HumanoidRootPart
						weld.Part1 = fx
						
						local lastChecked = os.clock()

						renderstepped = runService.Heartbeat:Connect(function()
							local elapsedTime = os.clock() - started

							if os.clock() - lastChecked >= 1 then
								lastChecked = os.clock()
								hitChar.Humanoid:TakeDamage(stats.MeteorDamage/stats.MeteorTime)
							end

							if elapsedTime >= stats.MeteorTime then
								renderstepped:Disconnect()
								fx:Destroy()

								lastChecked = os.clock()
								started = os.clock()

								renderstepped = runService.Heartbeat:Connect(function()
									local elapsedTime = os.clock() - started
		
									if os.clock() - lastChecked >= 1 then
										lastChecked = os.clock()
										hitChar.Humanoid:TakeDamage(stats.BurningDamage/stats.BurningTime)
									end
		
									if elapsedTime >= stats.BurningTime then
										renderstepped:Disconnect()
									end
								end)
							end
						end)
					end
				end
			end

			task.delay(stats.Cooldown, function()
				player:SetAttribute("LastAbility".. abilityNum, os.clock())
				player:SetAttribute("CanAbility", nil)
				useAbility:FireClient(player, "Ability".. abilityNum)
			end)
		end)
	end
end

function module.IceMeteor(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)
		local stats = abilityStats.IceMeteor
		
		for i = 1,2,1 do
			grabMousePos:FireClient(player)
			local mouseCon
	
			mouseCon = grabMousePos.OnServerEvent:Connect(function(p, mousePos)
				if p == player then
					mouseCon:Disconnect()
					local hitbox
					local bullet = abilityItems.IceMeteor.FX:Clone()
					bullet.Parent = workspace.Effects
	
					bullet.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
	
					local rayParams = RaycastParams.new()
					rayParams.FilterDescendantsInstances = {character, VFXFolder}
					rayParams.FilterType = Enum.RaycastFilterType.Exclude
			
					local caster = fastCast.new()
			
					local behavior = fastCast.newBehavior()
					behavior.RaycastParams = rayParams
					behavior.MaxDistance = stats.Range
			
					caster:Fire(character.HumanoidRootPart.Position, (mousePos - character.HumanoidRootPart.Position), stats.Speed, behavior)
					
					local lengthChanged, termninating, hit, actualHit
	
					lengthChanged = caster.LengthChanged:Connect(function(activeCast, lastPoint, rayDir, displacement)
						local blength = bullet.Size.Z/2
						local offset = CFrame.new(0,0,-(displacement-blength))
						bullet:PivotTo(CFrame.lookAt(lastPoint, lastPoint+rayDir):ToWorldSpace(offset))
			
						if not hitbox then
							hitbox = raycastHitbox.new(bullet)
							hitbox.RaycastParams = RaycastParams.new()
							hitbox.RaycastParams.FilterDescendantsInstances = {bullet, character, workspace.Effects}
							hitbox.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude
			
							hitbox:HitStart()
			
							actualHit = hitbox.OnHit:Connect(function(part)
								local foundModel = part:FindFirstAncestorOfClass("Model")
								if foundModel and foundModel:FindFirstChildOfClass("Humanoid") then
									local hum = foundModel:FindFirstChildOfClass("Humanoid")
									print(part)
									hum:TakeDamage(stats.Damage)
	
									foundModel.HumanoidRootPart.Anchored = true
	
									task.delay(stats.StunLength, function()
										foundModel.HumanoidRootPart.Anchored = false
									end)
								end
			
								actualHit:Disconnect()
								hitbox:HitStop()
								hitbox:Destroy()
								activeCast:Terminate()
							end)
						end
					end)
	
					hit = caster.RayHit:Connect(function()
						-- local impactEffect = slashParticles.Impact:Clone()
						-- impactEffect.Parent = effectsFolder
						-- impactEffect.CFrame = bullet.CFrame
			
						-- for _, effect in impactEffect:GetDescendants() do
						-- 	if effect:IsA("ParticleEmitter") then
						-- 		effect:Emit(5)
						-- 	end
						-- end
						-- Debris:AddItem(impactEffect, 2)
			
						for _, v in bullet:GetDescendants() do
							if v:IsA("ParticleEmitter") then
								v.Enabled = false
							end
						end
			
						Debris:AddItem(bullet, 2)
			
						termninating:Disconnect()
						lengthChanged:Disconnect()
						lengthChanged = nil
						hit:Disconnect()
					end)
			
					termninating = caster.CastTerminating:Connect(function()
						termninating:Disconnect()
						lengthChanged:Disconnect()
						lengthChanged = nil
						hit:Disconnect()
						print("Terminating")
			
						for _, v in bullet:GetDescendants() do
							if v:IsA("ParticleEmitter") then
								v.Enabled = false
							end
						end
			
						Debris:AddItem(bullet, 2)
						bullet = nil
					end)
			
					task.delay(stats.Cooldown, function()
						player:SetAttribute("LastAbility".. abilityNum, os.clock())
						player:SetAttribute("CanAbility", nil)
						useAbility:FireClient(player, "Ability".. abilityNum)
	
						if lengthChanged then lengthChanged:Disconnect(); lengthChanged = nil end
						if hit then hit:Disconnect() end
						if actualHit then actualHit:HitStop(); actualHit:Destroy() end
						if termninating then termninating:Disconnect() end
						if bullet then bullet:Destroy() end
					end)
				end
			end)

			task.wait(.3)
		end
	end
end

function module.Blizzard(player, character, staff, abilityNum)
	if os.clock() - player:GetAttribute("LastAbility".. abilityNum) >= staff:GetAttribute("Ability"..abilityNum.."Speed") and not player:GetAttribute("CanAbility") then
		player:SetAttribute("CanAbility", true)
		local stats = abilityStats.Blizzard

		local mouseCon
		grabMousePos:FireClient(player)

		mouseCon = grabMousePos.OnServerEvent:Connect(function(p, mousePos)
			if p == player then
				mouseCon:Disconnect()

				local rayParams = RaycastParams.new()
				rayParams.FilterDescendantsInstances = {character, VFXFolder}
				rayParams.FilterType = Enum.RaycastFilterType.Exclude

				local ray = workspace:Raycast(character.HumanoidRootPart.Position, (mousePos - character.HumanoidRootPart.Position).Unit * stats.Range, rayParams)

				if ray and ray.Instance then
					local hitChar = ray.Instance:FindFirstAncestorOfClass("Model")

					if hitChar and hitChar:FindFirstChild("Humanoid") then
						local hitHum = hitChar.Humanoid

						local fx = abilityItems.Blizzard.FX:Clone()

						fx.Parent = VFXFolder
						
						local weld = Instance.new("Weld", fx)
						weld.Part0 = hitChar.HumanoidRootPart
						weld.Part1 = fx


						hitHum:SetAttribute("PreviousWalkspeed", hitHum.WalkSpeed)
						hitHum.WalkSpeed = hitHum.WalkSpeed / 2

						local lastChecked = 0
						local started = os.clock()
						local renderstepped 

						renderstepped = runService.Heartbeat:Connect(function()
							if os.clock() - lastChecked >= 1 then
								lastChecked = os.clock()
								hitHum:TakeDamage(stats.Damage/stats.SlowTime)
							end

							if os.clock() - started >= stats.SlowTime then
								renderstepped:Disconnect()
								hitHum.WalkSpeed = hitHum:GetAttribute("PreviousWalkspeed")
								hitHum:SetAttribute("PreviousWalkspeed", nil)

								for _, particle in fx:GetDescendants() do
									if particle:IsA("Particle") then
										particle.Enabled = false
									end
								end

								Debris:AddItem(fx, 2)
							end
						end)
					end
				end

				task.delay(stats.Cooldown, function()
					player:SetAttribute("LastAbility".. abilityNum, os.clock())
					player:SetAttribute("CanAbility", nil)
					useAbility:FireClient(player, "Ability".. abilityNum)
				end)
			end
		end)
	end
end

return module