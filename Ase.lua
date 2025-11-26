local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local gui = script.Parent
local frame = gui:WaitForChild("MainFrame")

local flyButton = frame:WaitForChild("FlyButton")
local highlightButton = frame:WaitForChild("HighlightButton")
local aimbotButton = frame:WaitForChild("AimbotButton")

---------------------------------------------------------
-- 🧈 BUTTER HIGHLIGHT
---------------------------------------------------------
local highlight = Instance.new("Highlight")
highlight.FillColor = Color3.fromRGB(255, 230, 100)
highlight.OutlineColor = Color3.fromRGB(255, 200, 50)
highlight.FillTransparency = 0.3
highlight.OutlineTransparency = 0.1
highlight.Parent = nil

local highlightEnabled = false

highlightButton.Text = "Highlight: OFF"

highlightButton.MouseButton1Click:Connect(function()
	highlightEnabled = not highlightEnabled
	
	if highlightEnabled then
		highlight.Parent = character
		highlightButton.Text = "Highlight: ON"
	else
		highlight.Parent = nil
		highlightButton.Text = "Highlight: OFF"
	end
end)

---------------------------------------------------------
-- ✈️ FLY MODE
---------------------------------------------------------
local flying = false
local flySpeed = 50

local keys = {
	W=false, A=false, S=false, D=false,
	Space=false, LeftShift=false
}

flyButton.Text = "Fly: OFF"

flyButton.MouseButton1Click:Connect(function()
	flying = not flying
	
	if flying then
		flyButton.Text = "Fly: ON"
		humanoid.PlatformStand = true
	else
		flyButton.Text = "Fly: OFF"
		humanoid.PlatformStand = false
		root.Velocity = Vector3.zero
	end
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.W then keys.W = true end
	if input.KeyCode == Enum.KeyCode.A then keys.A = true end
	if input.KeyCode == Enum.KeyCode.S then keys.S = true end
	if input.KeyCode == Enum.KeyCode.D then keys.D = true end
	if input.KeyCode == Enum.KeyCode.Space then keys.Space = true end
	if input.KeyCode == Enum.KeyCode.LeftShift then keys.LeftShift = true end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then keys.W = false end
	if input.KeyCode == Enum.KeyCode.A then keys.A = false end
	if input.KeyCode == Enum.KeyCode.S then keys.S = false end
	if input.KeyCode == Enum.KeyCode.D then keys.D = false end
	if input.KeyCode == Enum.KeyCode.Space then keys.Space = false end
	if input.KeyCode == Enum.KeyCode.LeftShift then keys.LeftShift = false end
end)

RunService.RenderStepped:Connect(function(deltaTime)
	if not flying then return end

	local cam = workspace.CurrentCamera
	local dir = Vector3.zero

	if keys.W then dir += cam.CFrame.LookVector end
	if keys.S then dir -= cam.CFrame.LookVector end
	if keys.A then dir -= cam.CFrame.RightVector end
	if keys.D then dir += cam.CFrame.RightVector end
	if keys.Space then dir += Vector3.new(0,1,0) end
	if keys.LeftShift then dir -= Vector3.new(0,1,0) end

	if dir.Magnitude > 0 then
		dir = dir.Unit
	end

	root.Velocity = dir * flySpeed * deltaTime * 60  -- 60 FPS基準で調整（必要に応じて調整）
end)

---------------------------------------------------------
-- 🎯 AIMBOT / AIM ASSIST (ONLY FOR YOUR GAME)
---------------------------------------------------------
local camera = workspace.CurrentCamera
local aimbotEnabled = false
local aimStrength = 0.14

-- NPC enemies MUST be inside workspace.Enemies
local enemiesFolder = workspace:WaitForChild("Enemies")

aimbotButton.Text = "Aimbot: OFF"

aimbotButton.MouseButton1Click:Connect(function()
	aimbotEnabled = not aimbotEnabled
	
	if aimbotEnabled then
		aimbotButton.Text = "Aimbot: ON"
	else
		aimbotButton.Text = "Aimbot: OFF"
	end
end)

local function getClosestEnemy()
	local closest = nil
	local closestDist = math.huge
	local mousePos = UserInputService:GetMouseLocation()

	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		local head = enemy:FindFirstChild("Head")
		if head then
			local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closest = head
				end
			end
		end
	end

	return closest
end)

RunService.RenderStepped:Connect(function(deltaTime)
	if not aimbotEnabled then return end
	
	local target = getClosestEnemy()
	if not target then return end

	local desired = (target.Position - camera.CFrame.Position).Unit
	local current = camera.CFrame.LookVector
	local lerpDir = current:Lerp(desired, aimStrength * deltaTime * 60)  -- 60 FPS基準で調整（必要に応じて調整）

	camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + lerpDir)
end)
