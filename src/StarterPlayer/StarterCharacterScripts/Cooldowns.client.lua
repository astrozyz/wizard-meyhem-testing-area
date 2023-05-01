local runService = game:GetService("RunService")
_G.Cooldowns = {}
-- 1 = timeStarted, 2 = timeToWait, 3 = functionToRun

runService.Heartbeat:Connect(function()
	for i, cd in _G.Cooldowns do 
		if os.clock() - cd[1] >= cd[2] then
			cd[3]()
			table.remove(_G.Cooldowns, i)
		end
	end
end)