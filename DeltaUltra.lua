-- DELTA ULTRA MENU v2.8
-- ДЕФОЛТ (скорость + FLY) + 9нвл + fan(visual) [морф в игрока]
-- Только для Delta (Android)

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
-- =================

-- Переменные
local currentMode = nil
local isNoclip = false
local isInvisible = false
local isFlyOn = false
local isMinimized = false
local menuVisible = true
local isMapRevealed = false
local isDeerMorph = false
local visualClone = nil
local flyConnection = nil
local bodyGyro = nil
local bodyVelocity = nil

-- Создаём GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaUltraMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- === LOADING ЭКРАН ===
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingFrame.BackgroundTransparency = 0.3
loadingFrame.Parent = screenGui

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(0.5, 0, 0.2, 0)
loadingText.Position = UDim2.new(0.25, 0, 0.4, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "ЗАГРУЗКА..."
loadingText.TextColor3 = Color3.fromRGB(0, 255, 255)
loadingText.Font = Enum.Font.GothamBlack
loadingText.TextScaled = true
loadingText.Parent = loadingFrame

-- === ВЫБОР РЕЖИМА ===
local modeFrame = Instance.new("Frame")
modeFrame.Size = UDim2.new(0, 300, 0, 340)
modeFrame.Position = UDim2.new(0.5, -150, 0.5, -170)
modeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
modeFrame.BorderSizePixel = 3
modeFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
modeFrame.Visible = false
modeFrame.Parent = screenGui

local modeTitle = Instance.new("TextLabel")
modeTitle.Size = UDim2.new(1, 0, 0, 60)
modeTitle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
modeTitle.Text = "ВЫБЕРИ РЕЖИМ"
modeTitle.TextColor3 = Color3.new(1,1,1)
modeTitle.Font = Enum.Font.GothamBlack
modeTitle.TextScaled = true
modeTitle.Parent = modeFrame

local defaultBtn = Instance.new("TextButton")
defaultBtn.Size = UDim2.new(0.9, 0, 0, 70)
defaultBtn.Position = UDim2.new(0.05, 0, 0, 80)
defaultBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
defaultBtn.Text = "ДЕФОЛТ\n(скорость + fly)"
defaultBtn.TextColor3 = Color3.new(1,1,1)
defaultBtn.Font = Enum.Font.GothamBold
defaultBtn.TextScaled = true
defaultBtn.Parent = modeFrame

local ninetynineBtn = Instance.new("TextButton")
ninetynineBtn.Size = UDim2.new(0.9, 0, 0, 70)
ninetynineBtn.Position = UDim2.new(0.05, 0, 0, 160)
ninetynineBtn.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
ninetynineBtn.Text = "9нвл\n(99 ночей в лесу)"
ninetynineBtn.TextColor3 = Color3.new(1,1,1)
ninetyniyneBtn.Font = Enum.Font.GothamBold
ninetynineBtn.TextScaled = true
ninetynineBtn.Parent = modeFrame

local fanBtn = Instance.new("TextButton")
fanBtn.Size = UDim2.new(0.9, 0, 0, 70)
fanBtn.Position = UDim2.new(0.05, 0, 0, 240)
fanBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
fanBtn.Text = "fan(visual)\n(морф в игрока)"
fanBtn.TextColor3 = Color3.new(1,1,1)
fanBtn.Font = Enum.Font.GothamBold
fanBtn.TextScaled = true
fanBtn.Parent = modeFrame

-- === ГЛАВНОЕ МЕНЮ ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 480)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(1, 0, 0, 40)
titleFrame.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
titleFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "DELTA ULTRA v2.8"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleFrame

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(0.75, 0, 0.05, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.new(0,0,0)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextScaled = true
minimizeBtn.Parent = titleFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.Parent = titleFrame

local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40)
contentFrame.Position = UDim2.new(0, 0, 0, 40)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Функция кнопки
local function createButton(text, posY, onColor, offColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 50)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = offColor
    btn.Text = "OFF " .. text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.Parent = contentFrame
    return btn
end

local function updateButton(btn, state, text, onColor, offColor)
    btn.Text = (state and "ON " or "OFF ") .. text
    btn.BackgroundColor3 = state and onColor or offColor
end

-- === РЕЖИМ: ДЕФОЛТ ===
local function loadDefaultMode()
    title.Text = "ДЕФОЛТ"
    
    -- СКОРОСТЬ
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Size = UDim2.new(0.9, 0, 0, 40)
    speedLabel.Position = UDim2.new(0.05, 0, 0, 10)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "СКОРОСТЬ:"
    speedLabel.TextColor3 = Color3.new(1,1,1)
    speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextScaled = true
    speedLabel.Parent = contentFrame

    local speeds = {10, 20, 30, 50, 100}
    local speedBtns = {}
    for i, speed in ipairs(speeds) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.18, 0, 0, 40)
        btn.Position = UDim2.new(0.05 + (i-1)*0.19, 0, 0, 60)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.Text = tostring(speed)
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamBold
        btn.TextScaled = true
        btn.Parent = contentFrame
        table.insert(speedBtns, btn)

        btn.MouseButton1Click:Connect(function()
            humanoid.WalkSpeed = speed
            for _, b in pairs(speedBtns) do b.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
            btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        end)
    end

    local jumpBtn = createButton("JUMP x50", 110, Color3.fromRGB(255,165,0), Color3.fromRGB(50,50,50))
    local noclipBtn = createButton("NOCLIP", 170, Color3.fromRGB(255,255,0), Color3.fromRGB(50,50,50))
    local invisibleBtn = createButton("INVISIBLE", 230, Color3.fromRGB(150,0,255), Color3.fromRGB(50,50,50))
    local flyBtn = createButton("FLY", 290, Color3.fromRGB(0, 255, 255), Color3.fromRGB(50,50,50))

    jumpBtn.MouseButton1Click:Connect(function()
        local on = not (humanoid.JumpPower == JUMP_POWER)
        humanoid.JumpPower = on and JUMP_POWER or DEFAULT_JUMP
        updateButton(jumpBtn, on, "JUMP x50", Color3.fromRGB(255,165,0), Color3.fromRGB(50,50,50))
    end)

    noclipBtn.MouseButton1Click:Connect(function()
        isNoclip = not isNoclip
        updateButton(noclipBtn, isNoclip, "NOCLIP", Color3.fromRGB(255,255,0), Color3.fromRGB(50,50,50))
    end)

    invisibleBtn.MouseButton1Click:Connect(function()
        isInvisible = not isInvisible
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = isInvisible and 1 or 0
            elseif part:IsA("Accessory") then
                local h = part:FindFirstChild("Handle")
                if h then h.Transparency = isInvisible and 1 or 0 end
            end
        end
        updateButton(invisibleBtn, isInvisible, "INVISIBLE", Color3.fromRGB(150,0,255), Color3.fromRGB(50,50,50))
    end)

    -- FLY (ТАПЫ ПО ЭКРАНУ)
    flyBtn.MouseButton1Click:Connect(function()
        isFlyOn = not isFlyOn
        updateButton(flyBtn, isFlyOn, "FLY", Color3.fromRGB(0,255,255), Color3.fromRGB(50,50,50))

        if isFlyOn then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.P = 9000
            bodyGyro.maxTorque = Vector3.new(9000,9000,9000)
            bodyGyro.Parent = rootPart

            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0,0,0)
            bodyVelocity.MaxForce = Vector3.new(9000,9000,9000)
            bodyVelocity.Parent = rootPart

            flyConnection = UserInputService.TouchMoved:Connect(function(input)
                if not isFlyOn then return end
                local cam = Workspace.CurrentCamera
                local pos = input.Position
                local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
                local dir = Vector2.new(pos.X - center.X, center.Y - pos.Y)
                local move = Vector3.new(dir.X, dir.Y, 0).Unit * FLY_SPEED
                bodyVelocity.Velocity = cam.CFrame:VectorToWorldSpace(move)
                bodyGyro.CFrame = cam.CFrame
            end)
        else
            if flyConnection then flyConnection:Disconnect() end
            if bodyGyro then bodyGyro:Destroy() end
            if bodyVelocity then bodyVelocity:Destroy() end
        end
    end)
end

-- === РЕЖИМ: 9нвл ===
local function load99nlMode()
    title.Text = "9нвл"
    local mapBtn = createButton("КАРТА", 10, Color3.fromRGB(0,200,255), Color3.fromRGB(50,50,50))
    local tpBtn = createButton("К КОСТРУ", 70, Color3.fromRGB(255,100,0), Color3.fromRGB(50,50,50))
    local deerBtn = createButton("ОЛЕНЬ", 130, Color3.fromRGB(139,69,19), Color3.fromRGB(50,50,50))

    mapBtn.MouseButton1Click:Connect(function()
        isMapRevealed = not isMapRevealed
        updateButton(mapBtn, isMapRevealed, "КАРТА", Color3.fromRGB(0,200,255), Color3.fromRGB(50,50,50))
        if isMapRevealed then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name == "MapPart" or obj.Name:find("Door") or obj.Name:find("Key") then
                    local h = Instance.new("Highlight")
                    h.FillColor = Color3.fromRGB(255,255,0)
                    h.OutlineColor = Color3.fromRGB(255,0,0)
                    h.Parent = obj
                end
            end
        else
            for _, h in pairs(Workspace:GetDescendants()) do
                if h:IsA("Highlight") then h:Destroy() end
            end
        end
    end)

    tpBtn.MouseButton1Click:Connect(function()
        local fire = Workspace:FindFirstChild("Campfire") or Workspace:FindFirstChild("Fire")
        if fire then rootPart.CFrame = fire:GetPivot() + Vector3.new(0,3,0) end
    end)

    deerBtn.MouseButton1Click:Connect(function()
        isDeerMorph = not isDeerMorph
        updateButton(deerBtn, isDeerMorph, "ОЛЕНЬ", Color3.fromRGB(139,69,19), Color3.fromRGB(50,50,50))
        -- (остальная логика оленья)
    end)
end

-- === РЕЖИМ: fan(visual) ===
local function loadFanVisualMode()
    title.Text = "fan(visual)"
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.9, 0, 0, 50)
    inputBox.Position = UDim2.new(0.05, 0, 0, 10)
    inputBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
    inputBox.PlaceholderText = "Ник игрока..."
    inputBox.TextColor3 = Color3.new(1,1,1)
    inputBox.Font = Enum.Font.GothamBold
    inputBox.TextScaled = trulocal currentMode = nil
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


local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaUltraMenu"
screenGui.Parent = player:WaitForChild("PlayerGui")


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


task.wait(2)
loadingFrame:Destroy()
modeFrame.Visible = true

print("DELTA ULTRA v2.8 ЗАГРУЖЕН! FLY — тапай и держи!")ЕТИ ТАПАМИ!")


