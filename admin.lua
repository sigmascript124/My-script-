-- Административная панель с ESP, Aimbot и Bunny Hop
-- Вставьте этот скрипт в LocalScript в StarterPlayerScripts или StarterGui

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Конфигурация
local ESP_ENABLED = false
local AIMBOT_ENABLED = false
local BUNNYHOP_ENABLED = false
local ESP_COLOR = Color3.fromRGB(255, 50, 50)
local AIMBOT_KEY = Enum.KeyCode.E
local AIMBOT_RANGE = 100
local AIMBOT_FOV = 60 -- градусы
local BUNNYHOP_SPEED = 1.5
local ESP_UPDATE_INTERVAL = 0.1 -- обновление ESP каждые 0.1 секунды

-- Переменные
local localPlayer = Players.LocalPlayer
local character = nil
local humanoid = nil
local espObjects = {}
local currentTarget = nil
local connections = {}
local lastEspUpdate = 0
local camera = Workspace.CurrentCamera
local adminPanel = nil
local targetLabel = nil
local isDragging = false
local dragStart = nil
local panelStart = nil

-- Создаем GUI для админ панели
local function createAdminPanel()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminPanelGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "AdminPanel"
    mainFrame.Size = UDim2.new(0, 320, 0, 420)
    mainFrame.Position = UDim2.new(0, 10, 0, 10)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(70, 70, 100)
    mainFrame.Active = true
    mainFrame.Draggable = false -- Управляем перетаскиванием самостоятельно
    mainFrame.Parent = screenGui
    
    -- Заголовок с возможностью перетаскивания
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    titleBar.BorderSizePixel = 0
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.8, 0, 1, 0)
    title.Position = UDim2.new(0.1, 0, 0, 0)
    title.Text = "🔥 АДМИН ПАНЕЛЬ 🔥"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 18
    title.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    closeButton.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.TextSize = 16
    closeButton.Parent = titleBar
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -40)
    contentFrame.Position = UDim2.new(0, 10, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- ESP переключатель
    local espButton = Instance.new("TextButton")
    espButton.Size = UDim2.new(1, 0, 0, 45)
    espButton.Position = UDim2.new(0, 0, 0, 0)
    espButton.Text = "👁️ ESP: ВЫКЛ"
    espButton.Name = "ESPButton"
    espButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    espButton.BorderColor3 = Color3.fromRGB(100, 100, 120)
    espButton.BorderSizePixel = 2
    espButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    espButton.Font = Enum.Font.SourceSansSemibold
    espButton.TextSize = 16
    espButton.Parent = contentFrame
    
    -- Aimbot переключатель
    local aimbotButton = Instance.new("TextButton")
    aimbotButton.Size = UDim2.new(1, 0, 0, 45)
    aimbotButton.Position = UDim2.new(0, 0, 0, 55)
    aimbotButton.Text = "🎯 AIMBOT: ВЫКЛ (Клавиша E)"
    aimbotButton.Name = "AimbotButton"
    aimbotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    aimbotButton.BorderColor3 = Color3.fromRGB(100, 100, 120)
    aimbotButton.BorderSizePixel = 2
    aimbotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimbotButton.Font = Enum.Font.SourceSansSemibold
    aimbotButton.TextSize = 16
    aimbotButton.Parent = contentFrame
    
    -- Bunny Hop переключатель
    local bhopButton = Instance.new("TextButton")
    bhopButton.Size = UDim2.new(1, 0, 0, 45)
    bhopButton.Position = UDim2.new(0, 0, 0, 110)
    bhopButton.Text = "🐰 BUNNY HOP: ВЫКЛ"
    bhopButton.Name = "BHopButton"
    bhopButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    bhopButton.BorderColor3 = Color3.fromRGB(100, 100, 120)
    bhopButton.BorderSizePixel = 2
    bhopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    bhopButton.Font = Enum.Font.SourceSansSemibold
    bhopButton.TextSize = 16
    bhopButton.Parent = contentFrame
    
    -- Настройки дистанции аимбота
    local settingsFrame = Instance.new("Frame")
    settingsFrame.Size = UDim2.new(1, 0, 0, 90)
    settingsFrame.Position = UDim2.new(0, 0, 0, 165)
    settingsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    settingsFrame.BorderSizePixel = 2
    settingsFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
    settingsFrame.Parent = contentFrame
    
    local settingsTitle = Instance.new("TextLabel")
    settingsTitle.Size = UDim2.new(1, 0, 0, 25)
    settingsTitle.Position = UDim2.new(0, 0, 0, 0)
    settingsTitle.Text = "Настройки Aimbot"
    settingsTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    settingsTitle.BackgroundTransparency = 1
    settingsTitle.Font = Enum.Font.SourceSansSemibold
    settingsTitle.TextSize = 14
    settingsTitle.Parent = settingsFrame
    
    local rangeLabel = Instance.new("TextLabel")
    rangeLabel.Size = UDim2.new(0.6, 0, 0, 25)
    rangeLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
    rangeLabel.Text = "Дистанция: " .. AIMBOT_RANGE
    rangeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    rangeLabel.BackgroundTransparency = 1
    rangeLabel.Font = Enum.Font.SourceSans
    rangeLabel.TextSize = 14
    rangeLabel.TextXAlignment = Enum.TextXAlignment.Left
    rangeLabel.Parent = settingsFrame
    
    local rangeSlider = Instance.new("TextBox")
    rangeSlider.Size = UDim2.new(0.3, 0, 0, 25)
    rangeSlider.Position = UDim2.new(0.65, 0, 0.35, 0)
    rangeSlider.Text = tostring(AIMBOT_RANGE)
    rangeSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
    rangeSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rangeSlider.BorderSizePixel = 1
    rangeSlider.BorderColor3 = Color3.fromRGB(100, 100, 100)
    rangeSlider.Font = Enum.Font.SourceSans
    rangeSlider.TextSize = 14
    rangeSlider.PlaceholderText = "Дистанция..."
    rangeSlider.Parent = settingsFrame
    
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(0.6, 0, 0, 25)
    fovLabel.Position = UDim2.new(0.05, 0, 0.7, 0)
    fovLabel.Text = "Поле зрения: " .. AIMBOT_FOV
    fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Font = Enum.Font.SourceSans
    fovLabel.TextSize = 14
    fovLabel.TextXAlignment = Enum.TextXAlignment.Left
    fovLabel.Parent = settingsFrame
    
    local fovSlider = Instance.new("TextBox")
    fovSlider.Size = UDim2.new(0.3, 0, 0, 25)
    fovSlider.Position = UDim2.new(0.65, 0, 0.7, 0)
    fovSlider.Text = tostring(AIMBOT_FOV)
    fovSlider.TextColor3 = Color3.fromRGB(0, 0, 0)
    fovSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fovSlider.BorderSizePixel = 1
    fovSlider.BorderColor3 = Color3.fromRGB(100, 100, 100)
    fovSlider.Font = Enum.Font.SourceSans
    fovSlider.TextSize = 14
    fovSlider.PlaceholderText = "FOV..."
    fovSlider.Parent = settingsFrame
    
    -- Информация о цели
    local targetFrame = Instance.new("Frame")
    targetFrame.Size = UDim2.new(1, 0, 0, 80)
    targetFrame.Position = UDim2.new(0, 0, 0, 265)
    targetFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    targetFrame.BorderSizePixel = 2
    targetFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
    targetFrame.Parent = contentFrame
    
    local targetTitle = Instance.new("TextLabel")
    targetTitle.Size = UDim2.new(1, 0, 0, 25)
    targetTitle.Position = UDim2.new(0, 0, 0, 0)
    targetTitle.Text = "Информация о цели"
    targetTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    targetTitle.BackgroundTransparency = 1
    targetTitle.Font = Enum.Font.SourceSansSemibold
    targetTitle.TextSize = 14
    targetTitle.Parent = targetFrame
    
    targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, -10, 0.7, -5)
    targetLabel.Position = UDim2.new(0, 5, 0, 30)
    targetLabel.Text = "Цель: Нет\nДистанция: -"
    targetLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Font = Enum.Font.SourceSans
    targetLabel.TextSize = 14
    targetLabel.TextWrapped = true
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.TextYAlignment = Enum.TextYAlignment.Top
    targetLabel.Parent = targetFrame
    
    -- Функции для кнопок
    espButton.MouseButton1Click:Connect(function()
        ESP_ENABLED = not ESP_ENABLED
        espButton.Text = "👁️ ESP: " .. (ESP_ENABLED and "ВКЛ" or "ВЫКЛ")
        espButton.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(60, 60, 80)
        updateESP()
    end)
    
    aimbotButton.MouseButton1Click:Connect(function()
        AIMBOT_ENABLED = not AIMBOT_ENABLED
        aimbotButton.Text = "🎯 AIMBOT: " .. (AIMBOT_ENABLED and "ВКЛ" or "ВЫКЛ") .. " (Клавиша E)"
        aimbotButton.BackgroundColor3 = AIMBOT_ENABLED and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(60, 60, 80)
    end)
    
    bhopButton.MouseButton1Click:Connect(function()
        BUNNYHOP_ENABLED = not BUNNYHOP_ENABLED
        bhopButton.Text = "🐰 BUNNY HOP: " .. (BUNNYHOP_ENABLED and "ВКЛ" or "ВЫКЛ")
        bhopButton.BackgroundColor3 = BUNNYHOP_ENABLED and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(60, 60, 80)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        adminPanel = nil
    end)
    
    rangeSlider.FocusLost:Connect(function()
        local newRange = tonumber(rangeSlider.Text)
        if newRange and newRange > 0 and newRange <= 500 then
            AIMBOT_RANGE = math.floor(newRange)
            rangeLabel.Text = "Дистанция: " .. AIMBOT_RANGE
        else
            rangeSlider.Text = tostring(AIMBOT_RANGE)
        end
    end)
    
    fovSlider.FocusLost:Connect(function()
        local newFov = tonumber(fovSlider.Text)
        if newFov and newFov > 0 and newFov <= 180 then
            AIMBOT_FOV = math.floor(newFov)
            fovLabel.Text = "Поле зрения: " .. AIMBOT_FOV
        else
            fovSlider.Text = tostring(AIMBOT_FOV)
        end
    end)
    
    -- Функции для перетаскивания панели
    local function startDrag()
        isDragging = true
        dragStart = UserInputService:GetMouseLocation()
        panelStart = mainFrame.Position
    end
    
    local function endDrag()
        isDragging = false
        dragStart = nil
        panelStart = nil
    end
    
    local function updateDrag()
        if isDragging and dragStart and panelStart then
            local mousePos = UserInputService:GetMouseLocation()
            local delta = mousePos - dragStart
            mainFrame.Position = UDim2.new(
                panelStart.X.Scale, 
                panelStart.X.Offset + delta.X,
                panelStart.Y.Scale, 
                panelStart.Y.Offset + delta.Y
            )
        end
    end
    
    -- Подключаем события перетаскивания
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateDrag()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            endDrag()
        end
    end)
    
    return screenGui, targetLabel
end

-- Функция для создания ESP (подсветки игроков через стены)
local function createESP(player)
    if not player.Character then return nil end
    
    local character = player.Character
    local espFolder = Instance.new("Folder")
    espFolder.Name = player.Name .. "_ESP"
    
    -- Создаем Highlight для всего тела
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = ESP_COLOR
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    highlight.Parent = espFolder
    
    -- Создаем метку с именем игрока
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Name"
    billboard.Adornee = character:WaitForChild("Head") or character:WaitForChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = true
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = ESP_COLOR
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 18
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Parent = billboard
    
    -- Добавляем дистанцию
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distanceLabel.Text = "Дистанция: -"
    distanceLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextSize = 14
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distanceLabel.Parent = billboard
    
    billboard.Parent = espFolder
    
    -- Помещаем в мировое пространство
    espFolder.Parent = Workspace
    
    return espFolder
end

-- Обновление ESP
local function updateESP()
    -- Очищаем старые ESP объекты
    for player, espFolder in pairs(espObjects) do
        if espFolder and espFolder.Parent then
            espFolder:Destroy()
        end
    end
    espObjects = {}
    
    -- Создаем новые ESP объекты если включено
    if ESP_ENABLED then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character then
                espObjects[player] = createESP(player)
            end
        end
    end
end

-- Обновление позиций ESP
local function updateESPDisplay()
    if not ESP_ENABLED then return end
    
    local currentTime = tick()
    if currentTime - lastEspUpdate < ESP_UPDATE_INTERVAL then return end
    lastEspUpdate = currentTime
    
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    for player, espFolder in pairs(espObjects) do
        if player and player.Character and espFolder and espFolder.Parent then
            local targetCharacter = player.Character
            local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
            local targetHead = targetCharacter:FindFirstChild("Head")
            
            if targetRoot then
                -- Обновляем дистанцию
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                local billboard = espFolder:FindFirstChild("ESP_Name")
                if billboard then
                    local distanceLabel = billboard:FindFirstChild("DistanceLabel") or billboard:FindFirstChildOfClass("TextLabel")
                    if distanceLabel and distanceLabel.Name == "TextLabel" and distanceLabel.Text ~= player.Name then
                        distanceLabel.Text = "Дистанция: " .. math.floor(distance) .. " studs"
                    end
                end
                
                -- Обновляем цвет в зависимости от расстояния
                local highlight = espFolder:FindFirstChild("ESP_Highlight")
                if highlight then
                    local alpha = math.clamp(1 - (distance / 200), 0.3, 0.7)
                    highlight.FillTransparency = 1 - alpha
                    
                    -- Меняем цвет если цель в прицеле
                    if currentTarget and currentTarget == targetCharacter then
                        highlight.FillColor = Color3.fromRGB(0, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                    else
                        highlight.FillColor = ESP_COLOR
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
    end
end

-- Поиск ближайшей цели для аимбота
local function findClosestTarget()
    if not character then return nil end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end
    
    local closestTarget = nil
    local closestDistance = AIMBOT_RANGE
    local closestScreenDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local targetCharacter = player.Character
            local targetRoot = targetCharacter:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
            
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local distance = (rootPart.Position - targetRoot.Position).Magnitude
                
                -- Проверка поля зрения (FOV)
                local screenPoint, onScreen = camera:WorldToViewportPoint(targetRoot.Position)
                if onScreen then
                    local viewportSize = camera.ViewportSize
                    local center = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
                    local screenPos = Vector2.new(screenPoint.X, screenPoint.Y)
                    local screenDistance = (center - screenPos).Magnitude
                    
                    -- Расчет FOV в пикселях (упрощенный)
                    local fovRadius = (AIMBOT_FOV / 2) * (viewportSize.Y / 60)
                    
                    if screenDistance <= fovRadius and distance < closestDistance then
                        closestDistance = distance
                        closestScreenDistance = screenDistance
                        closestTarget = targetCharacter
                    end
                end
            end
        end
    end
    
    return closestTarget, closestDistance
end

-- Активация аимбота
local function aimAtTarget(target)
    if not target or not character then return false end
    
    local targetRoot = target:FindFirstChild("HumanoidRootPart")
    local targetHead = target:FindFirstChild("Head")
    local localRoot = character:FindFirstChild("HumanoidRootPart")
    
    if targetRoot and localRoot and camera then
        -- Вычисляем направление к цели
        local targetPosition = targetHead and targetHead.Position or targetRoot.Position + Vector3.new(0, 2, 0)
        local direction = (targetPosition - camera.CFrame.Position).Unit
        
        -- Плавное наведение камеры
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
        
        -- Плавное перемещение (твининг)
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(camera, tweenInfo, {CFrame = targetCF})
        tween:Play()
        
        return true
    end
    
    return false
end

-- Bunny Hop функция
local function applyBunnyHop()
    if not character or not humanoid then return end
    
    -- Автоматический прыжок при касании земли
    if humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.JumpPower > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    -- Увеличиваем скорость при Bunny Hop
    if humanoid.MoveDirection.Magnitude > 0 then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local velocity = rootPart.Velocity
            local moveDir = humanoid.MoveDirection
            
            -- Увеличиваем горизонтальную скорость
            local horizontalSpeed = math.max(velocity.X * velocity.X + velocity.Z * velocity.Z, 0.1)
            local speedMultiplier = BUNNYHOP_SPEED
            
            local newVelocity = Vector3.new(
                moveDir.X * math.sqrt(horizontalSpeed) * speedMultiplier,
                velocity.Y,
                moveDir.Z * math.sqrt(horizontalSpeed) * speedMultiplier
            )
            
            -- Применяем скорость
            rootPart.Velocity = newVelocity
        end
    end
end

-- Основной цикл
local function mainLoop()
    -- Получаем ссылку на персонажа
    if not character or not character.Parent then
        character = localPlayer.Character
        if character then
            humanoid = character:WaitForChild("Humanoid")
        end
    end
    
    -- Обновляем ESP отображение
    updateESPDisplay()
    
    -- Bunny Hop
    if BUNNYHOP_ENABLED and character and humanoid and humanoid.Health > 0 then
        applyBunnyHop()
    end
    
    -- Aimbot
    if AIMBOT_ENABLED then
        -- Проверяем, нажата ли клавиша аимбота
        if UserInputService:IsKeyDown(AIMBOT_KEY) then
            local target, distance = findClosestTarget()
            if target then
                currentTarget = target
                aimAtTarget(target)
                
                -- Обновляем информацию в GUI
                if targetLabel then
                    local player = Players:GetPlayerFromCharacter(target)
                    if player then
                        targetLabel.Text = "Цель: " .. player.Name .. "\nДистанция: " .. math.floor(distance) .. " studs\nЗдоровье: " .. math.floor(target.Humanoid.Health)
                        targetLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                    end
                end
            else
                currentTarget = nil
                if targetLabel then
                    targetLabel.Text = "Цель: Нет\nДистанция: -\nАктивация: Клавиша E"
                    targetLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
                end
            end
        else
            currentTarget = nil
            if targetLabel and not isDragging then
                targetLabel.Text = "Цель: Нет\nДистанция: -\nАктивация: Клавиша E"
                targetLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
            end
        end
    else
        currentTarget = nil
    end
end

-- Инициализация
local function initialize()
    -- Создаем GUI
    adminPanel, targetLabel = createAdminPanel()
    
    -- Получаем камеру
    camera = Workspace.CurrentCamera
    
    -- Обновляем ESP при появлении новых игроков
    Players.PlayerAdded:Connect(function(player)
        if ESP_ENABLED and player ~= localPlayer then
            espObjects[player] = createESP(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            espObjects[player]:Destroy()
            espObjects[player] = nil
        end
    end)
    
    -- Обновляем ESP при смерти/возрождении персонажей
    local function setupCharacterListeners(player)
        if player.Character then
            player.CharacterAdded:Connect(function()
                if ESP_ENABLED and player ~= localPlayer and espObjects[player] then
                    wait(0.5) -- Ждем появления персонажа
                    espObjects[player]:Destroy()
                    espObjects[player] = createESP(player)
                end
            end)
            
            player.CharacterRemoving:Connect(function()
                if espObjects[player] then
                    espObjects[player]:Destroy()
                end
            end)
        end
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            setupCharacterListeners(player)
        end
    end
    
    Players.PlayerAdded:Connect(setupCharacterListeners)
    
    -- Основной цикл обновления
    local mainConnection = RunService.RenderStepped:Connect(function()
        mainLoop()
    end)
    
    table.insert(connections, mainConnection)
    
    -- Обработка удаления персонажа
    localPlayer.CharacterAdded:Connect(function(newChar)
        character = newChar
        wait(0.5)
        humanoid = newChar:WaitForChild("Humanoid")
    end)
    
    -- Первоначальное создание ESP
    if ESP_ENABLED then
        wait(1) -- Ждем загрузки всех персонажей
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer then
                espObjects[player] = createESP(player)
            end
        end
    end
    
    print("✅ Админ панель загружена!")
    print("📋 Функции:")
    print("  👁️ ESP - Подсветка игроков через стены")
    print("  🎯 Aimbot - Автоматическое прицеливание (клавиша E)")
    print("  🐰 Bunny Hop - Автоматическое прыганье для скорости")
    print("  📌 Панель можно перемещать, зажав заголовок")
end

-- Запуск админ панели
if localPlayer then
    -- Ждем загрузки игры
    wait(2)
    initialize()
else
    Players.PlayerAdded:Connect(function(player)
        if player == localPlayer then
            wait(2)
            initialize()
        end
    end)
end

-- Очистка при отключении
game:BindToClose(function()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    
    for _, espFolder in pairs(espObjects) do
        if espFolder then
            espFolder:Destroy()
        end
    end
    
    if adminPanel then
        adminPanel:Destroy()
    end
end)

-- Горячая клавиша для показа/скрытия панели (F5)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F5 then
        if adminPanel and adminPanel.Parent then
            adminPanel:Destroy()
            adminPanel = nil
        else
            initialize()
        end
    end
end)