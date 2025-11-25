-- Roblox Aimbot & Fly-to-Target Script
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local highlight = Instance.new("Highlight")
highlight.Parent = workspace

local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                if dist < shortestDistance then
                    closestPlayer = player
                    shortestDistance = dist
                end
            end
        end
    end
    return closestPlayer
end

-- Highlight the closest target every frame
RunService.RenderStepped:Connect(function()
    local target = getClosestPlayer()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        highlight.Adornee = target.Character
        highlight.Enabled = true
    else
        highlight.Enabled = false
    end
end)

-- Fly-to function when "F" is pressed
UserInputService.InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Tween to fly toward the player
                local TweenService = game:GetService("TweenService")
                local info = TweenInfo.new(1, Enum.EasingStyle.Linear)
                local goal = {CFrame = CFrame.new(target.Character.HumanoidRootPart.Position + Vector3.new(0,5,0))}
                TweenService:Create(hrp, info, goal):Play()
            end
        end
    end
end)
