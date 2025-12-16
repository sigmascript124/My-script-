-- Демонстрационная админ панель для Roblox Studio
-- Только для образовательных целей

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки
local settings = {
    esp = false,
    aimbot = false,
    bunnyHop = false,
    noFlashSmoke = false,
    noClip = false,
    noRecoil = false,
    speedMultiplier = 1,
    aimbotFOV = 200,
    espColor = Color3.fromRGB(255, 0, 0)
}

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Главная панель
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 460)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Скругление углов
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Заголовок
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🎮 Admin Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 16
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Контейнер для кнопок
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -60)
contentFrame.Position = UDim2.new(0, 10, 0, 50)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Добавление скроллинга
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 540)
scrollFrame.Parent = contentFrame

-- Функция создания кнопки-переключателя
local function createToggleButton(name, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, -10, 0, 50)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = ""
    button.Parent = scrollFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button
    
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(0, 60, 0, 30)
    status.Position = UDim2.new(1, -65, 0.5, -15)
    status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    status.Text = "OFF"
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 14
    status.Font = Enum.Font.GothamBold
    status.Parent = button
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = status
    
    button.MouseButton1Click:Connect(function()
        callback(button, status)
    end)
    
    return button, status
end

-- ESP функция
local espConnections = {}
local function toggleESP(enabled)
    -- Очистка старых ESP
    for _, conn in pairs(espConnections) do
        conn:Disconnect()
    end
    espConnections = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "AdminESP" then
            obj:Destroy()
        end
    end
    
    if not enabled then return end
    
    -- Создание ESP для всех игроков
    local function addESP(character)
        if character and character ~= player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Name = "AdminESP"
            highlight.FillColor = settings.espColor
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = character
        end
    end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            addESP(otherPlayer.Character)
        end
        
        table.insert(espConnections, otherPlayer.CharacterAdded:Connect(addESP))
    end
    
    table.insert(espConnections, Players.PlayerAdded:Connect(function(newPlayer)
        table.insert(espConnections, newPlayer.CharacterAdded:Connect(addESP))
    end))
end

-- Aimbot функция
local aimbotConnection
local lockedTarget = nil
local lockDistance = 500 -- Максимальная дистанция для удержания цели

local function toggleAimbot(enabled)
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    lockedTarget = nil
    
    if not enabled then return end
    
    local mouse = player:GetMouse()
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        local camera = workspace.CurrentCamera
        local character = player.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        -- Проверка текущей захваченной цели
        if lockedTarget then
            local targetChar = lockedTarget.Parent
            local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
            local distance = (humanoidRootPart.Position - lockedTarget.Position).Magnitude
            
            -- Проверка: цель жива, в пределах дистанции и видима
            if not targetHumanoid or targetHumanoid.Health <= 0 or distance > lockDistance then
                lockedTarget = nil -- Сброс цели
            else
                -- Проверка видимости
                local ray = Ray.new(humanoidRootPart.Position, (lockedTarget.Position - humanoidRootPart.Position).Unit * 1000)
                local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {character})
                
                if not hitPart or not hitPart:IsDescendantOf(targetChar) then
                    lockedTarget = nil -- Цель скрылась
                end
            end
        end
        
        -- Если нет захваченной цели - поиск новой
        if not lockedTarget then
            local closestPlayer = nil
            local closestDistance = math.huge
            
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local targetChar = otherPlayer.Character
                    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                    local targetHead = targetChar:FindFirstChild("Head")
                    
                    if targetHead and targetHumanoid and targetHumanoid.Health > 0 then
                        local ray = Ray.new(humanoidRootPart.Position, (targetHead.Position - humanoidRootPart.Position).Unit * 1000)
                        local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {character})
                        
                        if hitPart and hitPart:IsDescendantOf(targetChar) then
                            local distance = (humanoidRootPart.Position - targetHead.Position).Magnitude
                            local screenPos, onScreen = camera:WorldToViewportPoint(targetHead.Position)
                            
                            if onScreen and distance < closestDistance and distance < lockDistance then
                                local mousePos = UserInputService:GetMouseLocation()
                                local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                
                                if screenDistance < settings.aimbotFOV then
                                    closestPlayer = targetHead
                                    closestDistance = distance
                                end
                            end
                        end
                    end
                end
            end
            
            -- Захват новой цели
            if closestPlayer then
                lockedTarget = closestPlayer
            end
        end
        
        -- Наведение на захваченную цель
        if lockedTarget then
            local targetPosition = lockedTarget.Position
            local currentCFrame = camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
            
            -- Более агрессивная интерполяция для захваченной цели
            local smoothFactor = 0.5
            camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
        end
    end)
end

-- Bunny Hop функция
local bunnyHopConnection
local function toggleBunnyHop(enabled)
    if bunnyHopConnection then
        bunnyHopConnection:Disconnect()
        bunnyHopConnection = nil
    end
    
    if not enabled then return end
    
    bunnyHopConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.Space then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end)
end

-- No Flash/Smoke функция
local noFlashSmokeConnection
local removedEffects = {}

local function toggleNoFlashSmoke(enabled)
    if noFlashSmokeConnection then
        noFlashSmokeConnection:Disconnect()
        noFlashSmokeConnection = nil
    end
    
    -- Восстановление эффектов
    for _, effect in pairs(removedEffects) do
        if effect and effect.Parent then
            effect.Enabled = true
        end
    end
    removedEffects = {}
    
    if not enabled then return end
    
    local function removeEffect(obj)
        -- Удаление дыма
        if obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
            table.insert(removedEffects, obj)
        end
        
        -- Удаление партиклов (дым, вспышки)
        if obj:IsA("ParticleEmitter") then
            local name = obj.Name:lower()
            if name:find("smoke") or name:find("flash") or name:find("fog") or name:find("mist") then
                obj.Enabled = false
                table.insert(removedEffects, obj)
            end
        end
        
        -- Удаление световых эффектов (флэшки)
        if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            local name = obj.Name:lower()
            if name:find("flash") or name:find("bang") or name:find("blind") then
                obj.Enabled = false
                table.insert(removedEffects, obj)
            end
        end
        
        -- Удаление эффектов размытия/затемнения
        if obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") then
            obj.Enabled = false
            table.insert(removedEffects, obj)
        end
        
        -- Удаление атмосферных эффектов
        if obj:IsA("Atmosphere") then
            obj.Density = 0
            obj.Offset = 0
            table.insert(removedEffects, obj)
        end
    end
    
    -- Сканирование существующих эффектов
    for _, obj in pairs(workspace:GetDescendants()) do
        removeEffect(obj)
    end
    
    -- Также проверяем камеру и Lighting
    if workspace.CurrentCamera then
        for _, obj in pairs(workspace.CurrentCamera:GetDescendants()) do
            removeEffect(obj)
        end
    end
    
    for _, obj in pairs(game.Lighting:GetDescendants()) do
        removeEffect(obj)
    end
    
    -- Отслеживание новых эффектов
    noFlashSmokeConnection = workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.05) -- Небольшая задержка
        removeEffect(obj)
    end)
    
    -- Дополнительная защита от флэш эффектов в камере
    local cameraConnection = workspace.CurrentCamera.DescendantAdded:Connect(function(obj)
        task.wait(0.05)
        removeEffect(obj)
    end)
    
    -- Защита от изменений в Lighting
    local lightingConnection = game.Lighting.DescendantAdded:Connect(function(obj)
        task.wait(0.05)
        removeEffect(obj)
    end)
end

-- NoClip функция
local noClipConnection
local originalWalkSpeed = 16

local function toggleNoClip(enabled)
    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end
    
    local character = player.Character
    if not character then return end
    
    if not enabled then
        -- Восстановление коллизий
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        return
    end
    
    -- Отключение коллизий
    noClipConnection = RunService.Stepped:Connect(function()
        local char = player.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- Speed функция
local speedConnection
local function setSpeed(multiplier)
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    -- Сохранение оригинальной скорости
    if multiplier == 1 then
        originalWalkSpeed = humanoid.WalkSpeed
    end
    
    humanoid.WalkSpeed = originalWalkSpeed * multiplier
    
    -- Отслеживание изменений скорости
    speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if settings.speedMultiplier ~= 1 then
            humanoid.WalkSpeed = originalWalkSpeed * settings.speedMultiplier
        end
    end)
end

-- No Recoil функция
local noRecoilConnection
local originalCameraCFrame

local function toggleNoRecoil(enabled)
    if noRecoilConnection then
        noRecoilConnection:Disconnect()
        noRecoilConnection = nil
    end
    
    if not enabled then return end
    
    local camera = workspace.CurrentCamera
    
    noRecoilConnection = RunService.RenderStepped:Connect(function()
        local character = player.Character
        if not character then return end
        
        -- Сохранение позиции камеры перед отдачей
        if not originalCameraCFrame then
            originalCameraCFrame = camera.CFrame
        end
        
        -- Обнаружение и компенсация отдачи
        local currentCFrame = camera.CFrame
        
        -- Проверка на резкое изменение угла (отдача)
        if originalCameraCFrame then
            local angularChange = currentCFrame.LookVector:Dot(originalCameraCFrame.LookVector)
            
            -- Если угол изменился незначительно (может быть отдача)
            if angularChange < 0.999 and angularChange > 0.95 then
                -- Стабилизация камеры
                local stabilized = originalCameraCFrame:Lerp(currentCFrame, 0.3)
                camera.CFrame = stabilized
            end
        end
        
        -- Обновление базовой позиции
        task.wait(0.1)
        originalCameraCFrame = camera.CFrame
        
        -- Компенсация вертикальной отдачи
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool then
                -- Блокировка вертикального движения камеры при стрельбе
                local lookVector = camera.CFrame.LookVector
                local newLookVector = Vector3.new(lookVector.X, lookVector.Y * 0.5, lookVector.Z)
                
                -- Небольшая компенсация для плавности
                camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + newLookVector)
            end
        end
    end)
end

-- Создание кнопок
local espButton, espStatus = createToggleButton(
    "ESPButton",
    "👁️ ESP (Wallhack)",
    UDim2.new(0, 0, 0, 0),
    function(btn, status)
        settings.esp = not settings.esp
        if settings.esp then
            status.Text = "ON"
            status.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            status.Text = "OFF"
            status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        toggleESP(settings.esp)
    end
)

local aimbotButton, aimbotStatus = createToggleButton(
    "AimbotButton",
    "🎯 Aimbot",
    UDim2.new(0, 0, 0, 60),
    function(btn, status)
        settings.aimbot = not settings.aimbot
        if settings.aimbot then
            status.Text = "ON"
            status.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            status.Text = "OFF"
            status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        toggleAimbot(settings.aimbot)
    end
)

local bhopButton, bhopStatus = createToggleButton(
    "BHopButton",
    "🐰 Bunny Hop",
    UDim2.new(0, 0, 0, 120),
    function(btn, status)
        settings.bunnyHop = not settings.bunnyHop
        if settings.bunnyHop then
            status.Text = "ON"
            status.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            status.Text = "OFF"
            status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        toggleBunnyHop(settings.bunnyHop)
    end
)

local noFlashButton, noFlashStatus = createToggleButton(
    "NoFlashButton",
    "🚫 No Flash/Smoke",
    UDim2.new(0, 5, 0, 180),
    function(btn, status)
        settings.noFlashSmoke = not settings.noFlashSmoke
        if settings.noFlashSmoke then
            status.Text = "ON"
            status.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            status.Text = "OFF"
            status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        toggleNoFlashSmoke(settings.noFlashSmoke)
    end
)

local noClipButton, noClipStatus = createToggleButton(
    "NoClipButton",
    "👻 NoClip",
    UDim2.new(0, 5, 0, 240),
    function(btn, status)
        settings.noClip = not settings.noClip
        if settings.noClip then
            status.Text = "ON"
            status.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            status.Text = "OFF"
            status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        toggleNoClip(settings.noClip)
    end
)

local noRecoilButton, noRecoilStatus = createToggleButton(
    "NoRecoilButton",
    "🎯 No Recoil",
    UDim2.new(0, 5, 0, 300),
    function(btn, status)
        settings.noRecoil = not settings.noRecoil
        if settings.noRecoil then
            status.Text = "ON"
            status.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            status.Text = "OFF"
            status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        toggleNoRecoil(settings.noRecoil)
    end
)

-- Секция скорости
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -10, 0, 35)
speedLabel.Position = UDim2.new(0, 5, 0, 360)
speedLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
speedLabel.Text = "⚡ Speed Multiplier"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Parent = scrollFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedLabel

-- Кнопки скорости
local speedButtons = {
    {text = "1x", value = 1},
    {text = "10x", value = 10},
    {text = "20x", value = 20},
    {text = "30x", value = 30},
    {text = "50x", value = 50},
    {text = "100x", value = 100}
}

local buttonWidth = (1 / #speedButtons)
for i, data in ipairs(speedButtons) do
    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(buttonWidth, -8, 0, 40)
    speedBtn.Position = UDim2.new(buttonWidth * (i - 1), 5 + (i - 1) * 4, 0, 405)
    speedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    speedBtn.Text = data.text
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.TextSize = 14
    speedBtn.Font = Enum.Font.GothamBold
    speedBtn.Parent = scrollFrame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = speedBtn
    
    speedBtn.MouseButton1Click:Connect(function()
        settings.speedMultiplier = data.value
        setSpeed(data.value)
        
        -- Обновление визуального состояния кнопок
        for _, btn in pairs(scrollFrame:GetChildren()) do
            if btn:IsA("TextButton") and btn.Text:find("x") then
                if btn == speedBtn then
                    btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
            end
        end
    end)
    
    -- Первая кнопка активна по умолчанию
    if i == 1 then
        speedBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    end
end

-- Информационная метка
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -10, 0, 60)
infoLabel.Position = UDim2.new(0, 5, 0, 460)
infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
infoLabel.Text = "⚠️ Демо панель\nТолько для обучения"
infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
infoLabel.TextSize = 14
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.Parent = scrollFrame

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoLabel

-- Кнопка закрытия
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    -- Отключение всех функций
    toggleESP(false)
    toggleAimbot(false)
    toggleBunnyHop(false)
    toggleNoFlashSmoke(false)
    toggleNoClip(false)
    toggleNoRecoil(false)
    setSpeed(1)
end)

print("✅ Админ панель загружена")