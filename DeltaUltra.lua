-- // GodMode v2.9 — \\
-- LocalScript → StarterPlayerScripts
-- Автор: uotyfhs | KZ Edition | 10.11.2025 14:05

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- === НАСТРОЙКИ ===
local REQUIRED_MODE = "Default"
local GOD_WALKSPEED = 1000
local DEFAULT_WALKSPEED = 16
local MAX_HEALTH = 999999999
local CORNER_RADIUS = UDim.new(0, 18)
local TWEEN_TIME = 0.3

-- === ЭКРАН ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GodModeV29_KZ"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- === ОСНОВНОЙ ФРЕЙМ ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 110)
mainFrame.Position = UDim2.new(0.5, -125, 0.07, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = CORNER_RADIUS
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 2.5
mainStroke.Color = Color3.fromRGB(80, 220, 140)
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "GOD MODE v2.9"
titleLabel.TextColor3 = Color3.fromRGB(200, 255, 220)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Parent = mainFrame

-- Статус режима
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.3, 0)
statusLabel.Position = UDim2.new(0, 0, 0.4, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Mode: Loading..."
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.Parent = mainFrame

-- Кнопка включения
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.85, 0, 0.35, 0)
toggleBtn.Position = UDim2.new(0.075, 0, 0.58, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 17
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 14)
btnCorner.Parent = toggleBtn

-- === GUI ТЕЛЕПОРТА ===
local tpGui = Instance.new("Frame")
tpGui.Size = UDim2.new(0, 90, 0, 90)
tpGui.BackgroundColor3 = Color3.fromRGB(32, 32, 48)
tpGui.BorderSizePixel = 0
tpGui.Visible = false
tpGui.Active = false
tpGui.ZIndex = 10
tpGui.Parent = screenGui

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = CORNER_RADIUS
tpCorner.Parent = tpGui

local tpStroke = Instance.new("UIStroke")
tpStroke.Thickness = 2
tpStroke.Color = Color3.fromRGB(100, 180, 255)
tpStroke.Parent = tpGui

local tpIcon = Instance.new("ImageLabel")
tpIcon.Size = UDim2.new(0.6, 0, 0.6, 0)
tpIcon.Position = UDim2.new(0.2, 0, 0.2, 0)
tpIcon.BackgroundTransparency = 1
tpIcon.Image = "rbxassetid://6031094678" -- Портал
tpIcon.Parent = tpGui

local tpLabel = Instance.new("TextLabel")
tpLabel.Size = UDim2.new(1, 0, 0.3, 0)
tpLabel.Position = UDim2.new(0, 0, 0.7, 0)
tpLabel.BackgroundTransparency = 1
tpLabel.Text = "TAP TO TP"
tpLabel.TextColor3 = Color3.fromRGB(180, 230, 255)
tpLabel.Font = Enum.Font.GothamBold
tpLabel.TextSize = 13
tpLabel.Parent = tpGui

-- === ПЕРЕМЕННЫЕ ===
local isEnabled = false
local healthConn = nil
local tpConn = nil
local originalSpeed = 16
local character, humanoid, rootPart
-- // GodMode v2.9 — ЧАСТЬ 2/3 \\

-- === ПОЛУЧЕНИЕ ПЕРСОНАЖА ===
local function getCharacter()
    if not player.Character then return false end
    character = player.Character
    humanoid = character:FindFirstChild("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart")
    return humanoid and rootPart
end

-- === ОБНОВЛЕНИЕ СТАТУСА РЕЖИМА ===
local function updateModeStatus()
    local leaderstats = player:FindFirstChild("leaderstats")
    local modeValue = leaderstats and leaderstats:FindFirstChild("Mode")
    local mode = modeValue and modeValue.Value or "Unknown"
    
    statusLabel.Text = "Mode: " .. mode
    statusLabel.TextColor3 = (mode == REQUIRED_MODE) 
        and Color3.fromRGB(100, 255, 150) 
        or Color3.fromRGB(255, 100, 100)
end

-- === ПОЗИЦИЯ ТЕЛЕПОРТ GUI ===
local function updateTeleportPosition()
    if not Workspace.CurrentCamera then return end
    tpGui.Position = UDim2.new(1, -110, 1, -170) -- Над прыжком
end

-- === ВКЛЮЧЕНИЕ GOD MODE ===
local function enableGodMode()
    if not getCharacter() then return end

    originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = GOD_WALKSPEED
    humanoid.MaxHealth = MAX_HEALTH
    humanoid.Health = MAX_HEALTH

    -- Мгновенное восстановление HP
    if healthConn then healthConn:Disconnect() end
    healthConn = humanoid.HealthChanged:Connect(function(health)
        if health < MAX_HEALTH then
            humanoid.Health = MAX_HEALTH
        end
    end)

    -- Показать GUI телепорта
    tpGui.Visible = true
    updateTeleportPosition()

    -- Телепортация по клику (1 раз)
    if tpConn then tpConn:Disconnect() end
    tpConn = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 
            or input.UserInputType == Enum.UserInputType.Touch then
            
            local mouse = player:GetMouse()
            local hit = mouse.Hit
            if hit then
                rootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 5, 0))
                tpGui.Visible = false
                if tpConn then tpConn:Disconnect() end
            end
        end
    end)

    -- Анимация кнопки
    TweenService:Create(toggleBtn, TweenInfo.new(TWEEN_TIME), {
        BackgroundColor3 = Color3.fromRGB(60, 200, 100)
    }):Play()
    toggleBtn.Text = "ON"
end

-- === ВЫКЛЮЧЕНИЕ GOD MODE ===
local function disableGodMode()
    if healthConn then healthConn:Disconnect(); healthConn = nil end
    if tpConn then tpConn:Disconnect(); tpConn = nil end
    tpGui.Visible = false

    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = DEFAULT_WALKSPEED
    end

    TweenService:Create(toggleBtn, TweenInfo.new(TWEEN_TIME), {
        BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    }):Play()
    toggleBtn.Text = "OFF"
end
-- // GodMode v2.9 — ЧАСТЬ 3/3 \\

-- === КНОПКА ВКЛ/ВЫКЛ ===
toggleBtn.MouseButton1Click:Connect(function()
    updateModeStatus()
    task.wait(0.1)

    local leaderstats = player:FindFirstChild("leaderstats")
    local modeValue = leaderstats and leaderstats:FindFirstChild("Mode")
    
    if not modeValue or modeValue.Value ~= REQUIRED_MODE then
        toggleBtn.Text = "ONLY DEFAULT"
        task.wait(1.5)
        toggleBtn.Text = "OFF"
        return
    end

    if not getCharacter() then return end

    isEnabled = not isEnabled
    if isEnabled then
        enableGodMode()
    else
        disableGodMode()
    end
end)

-- === РЕСПАВН ===
player.CharacterAdded:Connect(function()
    task.wait(1)
    getCharacter()
    updateModeStatus()
    if isEnabled then
        task.spawn(enableGodMode)
    end
end)

-- === АВТООБНОВЛЕНИЕ ===
RunService.Heartbeat:Connect(function()
    if tpGui.Visible then
        updateTeleportPosition()
    end
end)

-- === ПРОВЕРКА РЕЖИМА КАЖДУЮ СЕКУНДУ ===
task.spawn(function()
    while task.wait(1) do
        updateModeStatus()
    end
end)

-- === ИНИЦИАЛИЗАЦИЯ ===
updateModeStatus()
print("GodMode v2.9 KZ Edition загружен! Только для Default.")