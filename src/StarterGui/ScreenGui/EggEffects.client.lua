local viewportCam = Instance.new("Camera")
viewportCam.CFrame = CFrame.new(0.000444412231, 0.18522644, -12.3822832, -1, 0, -0, -0, 1, -0, -0, 0, -1)

local view = script.Parent:WaitForChild("ViewportFrame")
local egg = view:WaitForChild("WorldModel"):WaitForChild("Egg")
task.wait()
view.CurrentCamera = viewportCam

local hatchAnim = egg:WaitForChild("AnimationController"):WaitForChild("Animator"):LoadAnimation(script:WaitForChild("HatchAnim"))
local hatchRemote = game.ReplicatedStorage:WaitForChild("Events"):WaitForChild("Gameplay"):WaitForChild("HatchEgg")

local tweenService = game:GetService("TweenService")
local runservice = game:GetService("RunService")

local petName, starLevel, rarity = script.Parent:WaitForChild("PetName"), script.Parent:WaitForChild("StarLevel"), script.Parent:WaitForChild("Rarity")

hatchRemote.OnClientEvent:Connect(function(pet, rare)
	egg.Egg.Transparency = 0
	view.Position = UDim2.fromScale(0,-1)
	local tweenOnScreen = tweenService:Create(view, TweenInfo.new(
		1, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out
		), {Position = UDim2.fromScale(0,0)})

	tweenOnScreen:Play()
	tweenOnScreen.Completed:Wait()

	hatchAnim:Play()

	hatchAnim.Stopped:Wait()

	task.wait(.2)
	hatchRemote:FireServer()

	local startTime, totalTime = os.clock(), 1
	local originalEggLocation = egg:GetPivot()
	local tweenCam

	tweenCam = runservice.Heartbeat:Connect(function()
		local currentPos = egg:GetPivot()
		local alpha = tweenService:GetValue(math.clamp((os.clock()-startTime)/totalTime,0,1),Enum.EasingStyle.Back, Enum.EasingDirection.In)

		egg:PivotTo(originalEggLocation:Lerp(currentPos * CFrame.new(0,-10,0), alpha))

		if os.clock() - startTime >= totalTime and tweenCam then
			egg.Egg.Transparency = 1
			egg:PivotTo(originalEggLocation)
			tweenCam:Disconnect()
			tweenCam = nil
		end
	end)

	local petModel : Model = view:WaitForChild(pet)
	local starAmt = petModel:GetAttribute("StarRating")

	petName.Text = pet
	
	if starAmt == 1 then
		starLevel.Text = tostring(starAmt.. " Star")
	else
		starLevel.Text = tostring(starAmt.. " Stars")
	end
	
	rarity.Text = rare
	
	tweenService:Create(petName, TweenInfo.new(.8), {MaxVisibleGraphemes = petName.Text:len()}):Play()
	tweenService:Create(starLevel, TweenInfo.new(.8), {MaxVisibleGraphemes = starLevel.Text:len()}):Play()
	tweenService:Create(rarity, TweenInfo.new(.8), {MaxVisibleGraphemes = rarity.Text:len()}):Play()

	repeat task.wait() until tweenCam == nil
	task.wait(4)
	local done = tweenService:Create(view, TweenInfo.new(
		1, Enum.EasingStyle.Back, Enum.EasingDirection.In
		), {Position = UDim2.fromScale(0,1)})
	
	done:Play()
	
	tweenService:Create(petName, TweenInfo.new(.8), {MaxVisibleGraphemes = 0}):Play()
	tweenService:Create(starLevel, TweenInfo.new(.8), {MaxVisibleGraphemes = 0}):Play()
	tweenService:Create(rarity, TweenInfo.new(.8), {MaxVisibleGraphemes = 0}):Play()
	
	done.Completed:Once(function()
		petModel:Destroy()
	end)
end)