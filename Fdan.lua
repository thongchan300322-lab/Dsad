local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerPanel"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 300, 0, 250)  -- Increased height for new button
Panel.Position = UDim2.new(0.5, -150, 0.5, -125)
Panel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Panel.BorderSizePixel = 2
Panel.Active = true
Panel.Draggable = true
Panel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "Hacker Panel"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = Panel

-- Buttons
local AimbotButton = Instance.new("TextButton")
AimbotButton.Text = "Aimbot: OFF"
AimbotButton.Size = UDim2.new(0.8, 0, 0, 30)
AimbotButton.Position = UDim2.new(0.1, 0, 0.15, 0)
AimbotButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
AimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AimbotButton.Parent = Panel

local HighlightButton = Instance.new("TextButton")  -- Renamed for clarity (ESP/Highlight)
HighlightButton.Text = "Highlight (ESP): OFF"
HighlightButton.Size = UDim2.new(0.8, 0, 0, 30)
HighlightButton.Position = UDim2.new(0.1, 0, 0.35, 0)
HighlightButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
HighlightButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HighlightButton.Parent = Panel

local FlyButton = Instance.new("TextButton")
FlyButton.Text = "Fly Mode: OFF"
FlyButton.Size = UDim2.new(0.8, 0, 0, 30)
FlyButton.Position = UDim2.new(0.1, 0, 0.55, 0)
FlyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
FlyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FlyButton.Parent = Panel

-- Variables for features
local AimbotEnabled = false
local HighlightEnabled = false
local FlyEnabled = false
local AimKey = Enum.UserInputType.MouseButton2  -- Right mouse for aimbot
local FlySpeed = 50  -- Speed while flying

-- Aimbot Functions
local function GetClosestEnemy()
    local ClosestPlayer = nil
    local ShortestDistance = math.huge
    
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local IsEnemy = true  -- Adjust for teams if needed
            if IsEnemy then
                local Distance = (Player.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if Distance < ShortestDistance then
                    local Ray = Ray.new(Camera.CFrame.Position, (Player.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * Distance)
                    local Hit = workspace:FindPartOnRay(Ray, LocalPlayer.Character)
                    if not Hit or Hit:IsDescendantOf(Player.Character) then
                        ClosestPlayer = Player
                        ShortestDistance = Distance
                    end
                end
            end
        end
    end
    return ClosestPlayer
end

local function AimAt(Target)
    if Target and Target.Character then
        local TargetPart = Target.Character:FindFirstChild("Head") or Target.Character:FindFirstChild("HumanoidRootPart")
        if TargetPart then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPart.Position)
        end
    end
end

-- Highlight (ESP) Function
local function ToggleHighlight()
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Highlight = Player.Character:FindFirstChild("ESPHighlight")
            if HighlightEnabled then
                if not Highlight then
                    Highlight = Instance.new("Highlight")
                    Highlight.Name = "ESPHighlight"
                    Highlight.FillColor = Color3.fromRGB(255, 0, 0)  -- Red glow for enemies
                    Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    Highlight.Parent = Player.Character
                end
            else
                if Highlight then
                    Highlight:Destroy()
                end
            end
        end
    end
end

-- Fly Mode Function
local function StartFly()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.PlatformStand = true  -- Disables default movement
            local BodyVelocity = Instance.new("BodyVelocity")
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            BodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
        end
    end
end

local function StopFly()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if Humanoid then
            Humanoid.PlatformStand = false
            local BodyVelocity = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            if BodyVelocity then
                BodyVelocity:Destroy()
            end
        end
    end
end

local function FlyMovement()
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local BodyVelocity = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
        if BodyVelocity then
            local MoveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then MoveDirection = MoveDirection + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then MoveDirection = MoveDirection - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then MoveDirection = MoveDirection - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then MoveDirection = MoveDirection + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then MoveDirection = MoveDirection + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then MoveDirection = MoveDirection - Vector3.new(0, 1, 0) end
            BodyVelocity.Velocity = MoveDirection * FlySpeed
        end
    end
end

-- Button Events
AimbotButton.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    AimbotButton.Text = "Aimbot: " .. (AimbotEnabled and "ON" or "OFF")
end)

HighlightButton.MouseButton1Click:Connect(function()
    HighlightEnabled = not HighlightEnabled
    HighlightButton.Text = "Highlight (ESP): " .. (HighlightEnabled and "ON" or "OFF")
    ToggleHighlight()
end)

FlyButton.MouseButton1Click:Connect(function()
    FlyEnabled = not FlyEnabled
    FlyButton.Text = "Fly Mode: " .. (FlyEnabled and "ON" or "OFF")
    if FlyEnabled then
        StartFly()
    else
        StopFly()
    end
end)

-- Toggle Panel Visibility
local PanelVisible = true
UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if not GameProcessed and Input.KeyCode == Enum.KeyCode.Insert then
        PanelVisible = not PanelVisible
        Panel.Visible = PanelVisible
    end
    if not GameProcessed and Input.UserInputType == AimKey then
        AimbotEnabled = true
    end
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessed)
    if Input.UserInputType == AimKey then
        AimbotEnabled = false
    end
end)

-- Main Loops
RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local Target = GetClosestEnemy()
        AimAt(Target)
    end
    FlyMovement()  -- Handle fly controls every frame
end)

-- Update Highlight on player changes
Players.PlayerAdded:Connect(ToggleHighlight)
Players.PlayerRemoving:Connect(ToggleHighlight)
