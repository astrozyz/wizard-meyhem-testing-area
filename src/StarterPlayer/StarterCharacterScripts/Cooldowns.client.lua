local runService = game:GetService("RunService")
_G.Cooldowns = {}
-- 1 = timeStarted, 2 = timeToWait, 3 = functionToRun

runService.Heartbeat:Connect(function()
	for i, cd in _G.Cooldowns do 
		if os.clock() - cd[1] >= cd[2] then
			cd[3]()
			table.remove(_G.Cooldowns, i)
		elseif os.clock() - cd[1] <= cd[2] and cd[4] then 
			cd[4]()
		end
	end
end)