local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ===
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50
local JUMP_POWER = 100
local FLY_SPEED = 50

-- === ПЕРЕМЕННЫЕ ===
local currentMode = nil
local isNoclip = false
local isInvisible = false
local isFlyOn = false
local isMinimized = false
local menuVisible = true
local isGodModeOn = false
local isSpeedMorph = false
local visualClone = nil
local flyConnection = nil
local bodyGyro = nil
local bodyVelocity = nil

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaUltraMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Loading Frame
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 300, 0, 100)
loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
loadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
loadingFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
loadingFrame.Parent = screenGui

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 1, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "DELTA ULTRA v2.8\nЗагрузка..."
loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
loadingText.Font = Enum.Font.GothamBlack
loadingText.TextScaled = true
loadingText.Parent = loadingFrame

-- === ОСНОВНОЕ МЕНЮ ===
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(0, 300, 0, 340)
modeFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
modeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
modeFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
modeFrame.Visible = false
modeFrame.Parent = screenGui

local modeTitle = Instance.new("TextLabel")
modeTitle.Size = UDim2.new(1, 0, 0, 50)
modeTitle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
modeTitle.Text = "DELTA ULTRA v2.8"
modeTitle.TextColor3 = Color3.new(1,1,1)
modeTitle.Font = Enum.Font.GothamBlack
modeTitle.Parent = modeFrame

-- Кнопки
local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.Parent = modeFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("FLY: OFF", 60, function()
    isFlyOn = not isFlyOn
    local btn = modeFrame:FindFirstChildWhichIsA("TextButton", true)
    for _, b in pairs(modeFrame:GetChildren()) do
v2.8 — РАБОЧИЙ ДЛЯ ТЕЛЕФОНА
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ===
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50
local JUMP_POWER = 100
local FLY_SPEED = 50

-- === ПЕРЕМЕННЫЕ ===
local currentMode = nil
local isNoclip = false
local isInvisible = false
local isFlyOn = false
local isMinimized = false
local menuVisible = true
local isGodModeOn = false
local isSpeedMorph = false
local visualClone = nil
local flyConnection = nil
local bodyGyro = nil
local bodyVelocity = nil

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaUltraMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Loading Frame
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 300, 0, 100)
loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
loadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
loadingFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
loadingFrame.Parent = screenGui

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 1, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "DELTA ULTRA v2.8\nЗагрузка..."
loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
loadingText.Font = Enum.Font.GothamBlack
loadingText.TextScaled = true
loadingText.Parent = loadingFrame

-- === ОСНОВНОЕ МЕНЮ ===
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(0, 300, 0, 340)
modeFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
modeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
modeFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
modeFrame.Visible = false
modeFrame.Parent = screenGui

local modeTitle = Instance.new("TextLabel")
modeTitle.Size = UDim2.new(1, 0, 0, 50)
modeTitle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
modeTitle.Text = "DELTA ULTRA v2.8"
modeTitle.TextColor3 = Color3.new(1,1,1)
modeTitle.Font = Enum.Font.GothamBlack
modeTitle.Parent = modeFrame

-- Кнопки
local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.Parent = modeFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("FLY: OFF", 60, function()
    isFlyOn = not isFlyOn
    local btn = modeFrame:FindFirstChildWhichIsA("TextButton", true)
v2.8 — РАБОЧИЙ ДЛЯ ТЕЛЕФОНА
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- === НАСТРОЙКИ ===
local DEFAULT_SPEED = 16
local DEFAULT_JUMP = 50
local JUMP_POWER = 100
local FLY_SPEED = 50

-- === ПЕРЕМЕННЫЕ ===
local currentMode = nil
local isNoclip = false
local isInvisible = false
local isFlyOn = false
local isMinimized = false
local menuVisible = true
local isGodModeOn = false
local isSpeedMorph = false
local visualClone = nil
local flyConnection = nil
local bodyGyro = nil
local bodyVelocity = nil

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaUltraMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Loading Frame
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(0, 300, 0, 100)
loadingFrame.Position = UDim2.new(0.5, -150, 0.5, -50)
loadingFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
loadingFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
loadingFrame.Parent = screenGui

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 1, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "DELTA ULTRA v2.8\nЗагрузка..."
loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
loadingText.Font = Enum.Font.GothamBlack
loadingText.TextScaled = true
loadingText.Parent = loadingFrame

-- === ОСНОВНОЕ МЕНЮ ===
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(0, 300, 0, 340)
modeFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
modeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
modeFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
modeFrame.Visible = false
modeFrame.Parent = screenGui

local modeTitle = Instance.new("TextLabel")
modeTitle.Size = UDim2.new(1, 0, 0, 50)
modeTitle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
modeTitle.Text = "DELTA ULTRA v2.8"
modeTitle.TextColor3 = Color3.new(1,1,1)
modeTitle.Font = Enum.Font.GothamBlack
modeTitle.Parent = modeFrame

-- Кнопки
local function createButton(text, posY, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.Parent = modeFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createButton("FLY: OFF", 60, function()
    isFlyOn = not isFlyOn
    local btn = modeFrame:FindFirstChildWhichIsA("TextButton", true)
    for _, b in pairs(modeFrame:GetChildren()) do
        if b:IsA("TextButton") and b.Text:find("FLY") then
            b.Text = "FLY: " .. (isFlyOn and "ON" or "OFF")
            b.BackgroundColor3 = isFlyOn and Color3.fromRGB(0,255,0) or Color3.fromRGB(50,50,50)
        end
    end

    if isFlyOn then
        bodyGyro = Instance.new("BodyGyro")
        bodyGyro.P = 9000
        bodyGyro.maxTorque = Vector3.new(9000,9000,9000)
        bodyGyro.Parent = rootPart

        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(9000,9000,9000)
        bodyVelocity.Parent = rootPart

        flyConnection = UserInputService.TouchMoved:Connect(function(input)
            if not isFlyOn then return end
            local cam = Workspace.CurrentCamera
            local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
            local dir = Vector2.new(input.Position.X - center.X, center.Y - input.Position.Y)
            local move = Vector3.new(dir.X, dir.Y, 0).Unit * FLY_SPEED
            bodyVelocity.Velocity = cam.CFrame:VectorToWorldSpace(move)
            bodyGyro.CFrame = cam.CFrame
        end)
    else
        if bodyGyro then bodyGyro:Destroy() end
        if bodyVelocity then bodyVelocity:Destroy() end
        if flyConnection then flyConnection:Disconnect() end
    end
end)

createButton("Noclip: OFF", 110, function()
    isNoclip = not isNoclip
    local btn = modeFrame:FindFirstChildWhichIsA("TextButton", true)
    for _, b in pairs(modeFrame:GetChildren()) do
        if b:IsA("TextButton") and b.Text:find("Noclip") then
            b.Text = "Noclip: " .. (isNoclip and "ON" or "OFF")
            b.BackgroundColor3 = isNoclip and Color3.fromRGB(255,0,0) or Color3.fromRGB(50,50,50)
        end
    end

    if isNoclip then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end)

createButton("Speed: 16", 160, function()
    local speeds = {16, 30, 50, 100}
    local current = humanoid.WalkSpeed
    local index = table.find(speeds, current) or 1
    index = index % #speeds + 1
    humanoid.WalkSpeed = speeds[index]
    for _, b in pairs(modeFrame:GetChildren()) do
        if b:IsA("TextButton") and b.Text:find("Speed") then
            b.Text = "Speed: " .. speeds[index]
        end
    end
end)

createButton("Jump x2", 210, function()
    humanoid.JumpPower = humanoid.JumpPower == DEFAULT_JUMP and JUMP_POWER or DEFAULT_JUMP
    for _, b in pairs(modeFrame:GetChildren()) do
        if b:IsA("TextButton") and b.Text:find("Jump") then
            b.Text = "Jump x" .. (humanoid.JumpPower == JUMP_POWER and "2" or "1")
        end
    end
end)

createButton("Morph (visual)", 260, function()
    local targetName = "PlayerName" -- Замени на нужный ник
    local target = Players:FindFirstChild(targetName)
    if target and target.Character then
        if visualClone then visualClone:Destroy() end
        visualClone = target.Character:Clone
        visualClone.Parent = Workspace
        for _, part in pairs(visualClone:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0.5
                part.CanCollide = false
            elseif part:IsA("Decal") then
                part.Transparency = 0.5
            end
        end
        visualClone.HumanoidRootPart.CFrame = rootPart.CFrame
        visualClone.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
end)

-- === ЗАГРУЗКА ===
task.wait(2)
loadingFrame:Destroy()
modeFrame.Visible = true

print("DELTA ULTRA v2.8 ЗАГРУЖЕН! FLY — тапай и держи!")ЕТИ ТАПАМИ!")

