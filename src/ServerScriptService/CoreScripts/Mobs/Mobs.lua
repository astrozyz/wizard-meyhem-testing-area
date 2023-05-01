local module = {}

module.CurrentMobs = workspace.Mobs:GetChildren()
local mobs = game.ServerStorage.Mobs

local runService = game:GetService("RunService")
local pathfindingService = game:GetService("PathfindingService")

local rayHitbox = require(game.ServerScriptService.CoreScripts.RaycastHitboxV4)

local attackAnimations = {}

function module.SpawnInMob(mobType, mobPosition)
	local foundMob = mobs:FindFirstChild(mobType)
	if foundMob then 
		foundMob = foundMob:Clone()
		foundMob.Parent = workspace.Mobs
		foundMob:PivotTo(CFrame.new(mobPosition))
		foundMob:SetAttribute("OriginalPosition", mobPosition)
		table.insert(module.CurrentMobs, foundMob)
	end
end

function module.MobAttacking(player, character, mob)
	local mobHumanoid = mob.Humanoid
	local characterHumanoid = character.Humanoid
	local weapon = mob:FindFirstChild("Weapon")
	local attackRange = mob:GetAttribute("AttackRange")
	
	if not weapon then
		module.SpawnInMob(mob.Name, mob:GetAttribute("OriginalPosition"))
		mob:Destroy()
		return
	end

	local weaponHitbox = rayHitbox.new(weapon)

	local alive = true 

	mobHumanoid.Died:Once(function()
		alive = false
	end)

	local path = pathfindingService:CreatePath()
	local waypoints
	local blockedConnection
	local nextWaypointIndex
	local reachedConnection
	
	local alreadyAttacking = false
	local attackCon
	
	attackCon = weaponHitbox.OnHit:Connect(function(hit, humanoidHit)
		if game.Players:GetPlayerFromCharacter(humanoidHit.Parent) then
			humanoidHit:TakeDamage(mob:GetAttribute("Damage"))
		end
	end)

	while (mobHumanoid:GetState() ~= Enum.HumanoidStateType.Dead and characterHumanoid:GetState() ~= Enum.HumanoidStateType.Dead) and (character:GetPivot().Position - mob:GetPivot().Position).Magnitude <= attackRange and alive do
		local success, errorMessage = pcall(function()
			path:ComputeAsync(mob.PrimaryPart.Position, character:GetPivot().Position)
		end)
		
		if (character:GetPivot().Position - mob:GetPivot().Position).Magnitude <= 5 then
			if not alreadyAttacking then 
				weaponHitbox:HitStart(.5)
				alreadyAttacking = true
				mobHumanoid.WalkSpeed = 4
				attackAnimations[mob]:Play()

				attackAnimations[mob].Stopped:Once(function()
					mobHumanoid.WalkSpeed = 10
				end)
				
				
				task.delay(mob:GetAttribute("AttackSpeed"), function()
					alreadyAttacking = false 
				end)
			end
		end

		if success and path.Status == Enum.PathStatus.Success then
			waypoints = path:GetWaypoints()

			blockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)
				if blockedWaypointIndex >= nextWaypointIndex then
					blockedConnection:Disconnect()
					path:ComputeAsync(character.PrimaryPart.Position, character:GetPivot().Position)
				end
			end)

			if not reachedConnection then

				reachedConnection = mobHumanoid.MoveToFinished:Connect(function(reached)
					
					if reached and nextWaypointIndex < #waypoints then
						nextWaypointIndex += 1
						mobHumanoid:MoveTo(waypoints[nextWaypointIndex].Position)
					else
						reachedConnection:Disconnect()
						blockedConnection:Disconnect()
					end
				end)
			end

			nextWaypointIndex = 2
			
			if not ((character:GetPivot().Position - mob:GetPivot().Position).Magnitude <= 5) then
				mobHumanoid:MoveTo(waypoints[nextWaypointIndex].Position)
			end

		else
			warn("Path not computed!", errorMessage)
		end
	end

	attackCon:Disconnect()
	weaponHitbox:Destroy()

	if mobHumanoid:GetState() == Enum.HumanoidStateType.Dead then
		player.leaderstats.Mana.Value += mob:GetAttribute("ManaDropped")
		
		task.delay(5, function()
			module.SpawnInMob(mob.Name, mob:GetAttribute("OriginalPosition"))
			mob:Destroy()
		end)
		
		local xp = player:GetAttribute("XP")
		local level = player:GetAttribute("Level")
		local maxXP = 750 * (level + 0.5)
		
		local tempXP = xp + mob:GetAttribute("XP")
		
		if tempXP >= maxXP then 
			local remainder = tempXP - maxXP
			
			player:SetAttribute("Level", level + 1)
			player:SetAttribute("XP", math.abs(remainder))
			
			local fx = game.ReplicatedStorage.Models.General.LevelUpFX:GetChildren()
			
			for _, v in fx do 
				v = v:Clone()
				v.Parent = character.UpperTorso
				v.Enabled = true
				
				task.delay(5, function()
					game.Debris:AddItem(v, 2)
					v.Enabled = false
				end)
			end
		else
			player:SetAttribute("XP", tempXP)
		end
	else
		table.insert(module.CurrentMobs, mob)
	end
end

function module.BeginMobDetection()
	
	for _, v in module.CurrentMobs do 
		v:SetAttribute("OriginalPosition", v:GetPivot().Position)
	end
	runService.Heartbeat:Connect(function()
		for i, mob in module.CurrentMobs do
			local position = mob:GetPivot().Position

			for _, player in game.Players:GetPlayers() do 
				local character = player.Character
				if not character or character.Humanoid:GetState() == Enum.HumanoidStateType.Dead then continue end

				if (character:GetPivot().Position - position).Magnitude <= mob:GetAttribute("AttackRange") then 
					attackAnimations[mob] = mob.Humanoid.Animator:LoadAnimation(script.AttackAnimation)
					table.remove(module.CurrentMobs, table.find(module.CurrentMobs, mob))
					coroutine.wrap(module.MobAttacking)(player, character, mob)
				end
			end
		end
	end)
end

return module
