е
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
infoLabel.Size = UDim2.new(1, -10, 0, 80)
infoLabel.Position = UDim2.new(0, 5, 0, 460)
infoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
infoLabel.Text = settings.isMobile and 
    "⚠️ Демо панель\nТолько для обучения\n\n📱 Aimbot: Нажми и держи кнопку 🎯" or
    "⚠️ Демо панель\nТолько для обучения\n\n💡 Aimbot: Зажми ПКМ и наведи на врага"
infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
infoLabel.TextSize = 12
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


print("✅ Админ панель загружена.")-- Демонстрационная админ панель для Roblox Studio
-- Только для образовательных целей

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Определение платформы
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

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
    isMobile = isMobile,
    espColor = Color3.fromRGB(255, 0, 0)
}

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
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
titleLabel.Text = isMobile and "🎮 Admin Panel 📱" or "🎮 Admin Panel 🖥️"
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

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 560)
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
local espLabels = {}
local espEnabled = false

local function toggleESP(enabled)
    espEnabled = enabled
    
    for _, conn in pairs(espConnections) do
        pcall(function() conn:Disconnect() end)
    end
    espConnections = {}
    
    for _, label in pairs(espLabels) do
        pcall(function() label:Destroy() end)
    end
    espLabels = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "AdminESP" then
            pcall(function() obj:Destroy() end)
        end
        if obj:IsA("BillboardGui") and obj.Name == "ESPLabel" then
            pcall(function() obj:Destroy() end)
        end
    end
    
    if not enabled then return end
    
    local function addESP(character, targetPlayer)
        if not espEnabled then return end
        if not character or character == player.Character then return end
        
        pcall(function()
            if character:FindFirstChild("AdminESP") then
                character.AdminESP:Destroy()
            end
        end)
        
        task.wait(0.1)
        
        pcall(function()
            local highlight = Instance.new("Highlight")
            highlight.Name = "AdminESP"
            highlight.FillColor = settings.espColor
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Parent = character
            
            local head = character:FindFirstChild("Head")
            if head then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ESPLabel"
                billboard.Adornee = head
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.StudsOffset = Vector3.new(0, 2, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = head
                
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = targetPlayer.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextSize = 16
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextStrokeTransparency = 0.5
                nameLabel.Parent = billboard
                
                local distanceLabel = Instance.new("TextLabel")
                distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                distanceLabel.BackgroundTransparency = 1
                distanceLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                distanceLabel.TextSize = 14
                distanceLabel.Font = Enum.Font.Gotham
                distanceLabel.TextStrokeTransparency = 0.5
                distanceLabel.Parent = billboard
                
                table.insert(espLabels, billboard)
                
                local updateConnection = RunService.RenderStepped:Connect(function()
                    if not espEnabled then
                        updateConnection:Disconnect()
                        return
                    end
                    
                    pcall(function()
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and head then
                            local distance = (player.Character.HumanoidRootPart.Position - head.Position).Magnitude
                            distanceLabel.Text = string.format("%.1f studs", distance)
                        end
                    end)
                end)
                
                table.insert(espConnections, updateConnection)
            end
        end)
    end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            if otherPlayer.Character then
                addESP(otherPlayer.Character, otherPlayer)
            end
            
            local charConn = otherPlayer.CharacterAdded:Connect(function(char)
                if espEnabled then
                    addESP(char, otherPlayer)
                end
            end)
            table.insert(espConnections, charConn)
        end
    end
    
    local playerConn = Players.PlayerAdded:Connect(function(newPlayer)
        if not espEnabled then return end
        
        local charConn = newPlayer.CharacterAdded:Connect(function(char)
            if espEnabled then
                addESP(char, newPlayer)
            end
        end)
        table.insert(espConnections, charConn)
    end)
    table.insert(espConnections, playerConn)
    
    local checkConn = RunService.Heartbeat:Connect(function()
        if not espEnabled then
            checkConn:Disconnect()
            return
        end
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                if not otherPlayer.Character:FindFirstChild("AdminESP") then
                    addESP(otherPlayer.Character, otherPlayer)
                end
            end
        end
    end)
    table.insert(espConnections, checkConn)
end

-- Aimbot функция
local aimbotConnection
local aimbotInputs = {}
local lockedTarget = nil
local aimbotActive = false
local mobileButton

local function toggleAimbot(enabled)
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    for _, conn in pairs(aimbotInputs) do
        pcall(function() conn:Disconnect() end)
    end
    aimbotInputs = {}
    
    if mobileButton then
        pcall(function() mobileButton.Parent:Destroy() end)
        mobileButton = nil
    end
    
    lockedTarget = nil
    aimbotActive = false
    
    if not enabled then return end
    
    if settings.isMobile then
        local mobileGui = Instance.new("ScreenGui")
        mobileGui.Name = "AimbotMobile"
        mobileGui.ResetOnSpawn = false
        mobileGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        mobileGui.Parent = playerGui
        
        mobileButton = Instance.new("TextButton")
        mobileButton.Size = UDim2.new(0, 80, 0, 80)
        mobileButton.Position = UDim2.new(1, -100, 0.5, -40)
        mobileButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        mobileButton.Text = "🎯"
        mobileButton.TextSize = 32
        mobileButton.Font = Enum.Font.GothamBold
        mobileButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        mobileButton.Parent = mobileGui
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = mobileButton
        
        table.insert(aimbotInputs, mobileButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                aimbotActive = true
                mobileButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
            end
        end))
        
        table.insert(aimbotInputs, mobileButton.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                aimbotActive = false
                lockedTarget = nil
                mobileButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            end
        end))
    else
        table.insert(aimbotInputs, UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                aimbotActive = true
            end
        end))
        
        table.insert(aimbotInputs, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                aimbotActive = false
                lockedTarget = nil
            end
        end))
    end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not aimbotActive then
            lockedTarget = nil
            return
        end
        
        pcall(function()
            local camera = workspace.CurrentCamera
            local character = player.Character
            if not character then return end
            
            local root = character:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            if lockedTarget then
                local targetChar = lockedTarget.Parent
                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
                
                if not targetHum or targetHum.Health <= 0 or (root.Position - lockedTarget.Position).Magnitude > 500 then
                    lockedTarget = nil
                    return
                end
                
                local rayResult = workspace:Raycast(root.Position, (lockedTarget.Position - root.Position).Unit * 1000, RaycastParams.new())
                if rayResult and not rayResult.Instance:IsDescendantOf(targetChar) then
                    lockedTarget = nil
                    return
                end
            end
            
            if not lockedTarget then
                local closest = nil
                local closestDist = math.huge
                
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local head = p.Character:FindFirstChild("Head")
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        
                        if head and hum and hum.Health > 0 then
                            local dist = (root.Position - head.Position).Magnitude
                            if dist < 500 then
                                local rayResult = workspace:Raycast(root.Position, (head.Position - root.Position).Unit * 1000, RaycastParams.new())
                                if rayResult and rayResult.Instance:IsDescendantOf(p.Character) then
                                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                                    
                                    if onScreen then
                                        if settings.isMobile then
                                            if dist < closestDist then
                                                closest = head
                                                closestDist = dist
                                            end
                                        else
                                            local mousePos = UserInputService:GetMouseLocation()
                                            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                            
                                            if screenDist < settings.aimbotFOV and dist < closestDist then
                                                closest = head
                                                closestDist = dist
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                lockedTarget = closest
            end
            
            if lockedTarget then
                local targetCFrame = CFrame.new(camera.CFrame.Position, lockedTarget.Position)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, settings.isMobile and 0.3 or 0.5)
            end
        end)
    end)
end

-- Bunny Hop
local bhopConnection
local function toggleBunnyHop(enabled)
    if bhopConnection then
        bhopConnection:Disconnect()
        bhopConnection = nil
    end
    
    if not enabled then return end
    
    bhopConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Space then
            pcall(function()
                local char = player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end)
end

-- No Flash/Smoke
local noFlashConns = {}
local function toggleNoFlashSmoke(enabled)
    for _, conn in pairs(noFlashConns) do
        pcall(function() conn:Disconnect() end)
    end
    noFlashConns = {}
    
    if not enabled then return end
    
    local function removeEffect(obj)
        pcall(function()
            if obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("ParticleEmitter") then
                obj.Enabled = false
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj.Enabled = false
            elseif obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") then
                obj.Enabled = false
            elseif obj:IsA("Atmosphere") then
                obj.Density = 0
            end
        end)
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        removeEffect(obj)
    end
    
    table.insert(noFlashConns, workspace.DescendantAdded:Connect(function(obj)
        task.wait(0.05)
        removeEffect(obj)
    end))
end

-- NoClip
local noClipConnection
local function toggleNoClip(enabled)
    if noClipConnection then
        noClipConnection:Disconnect()
        noClipConnection = nil
    end
    
    if not enabled then
        pcall(function()
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
        return
    end
    
    noClipConnection = RunService.Stepped:Connect(function()
        pcall(function()
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end)
end

-- No Recoil
local noRecoilConnection
local function toggleNoRecoil(enabled)
    if noRecoilConnection then
        noRecoilConnection:Disconnect()
        noRecoilConnection = nil
    end
    
    if not enabled then return end
    
    local camera = workspace.CurrentCamera
    local lastCFrame = camera.CFrame
    
    noRecoilConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            local current = camera.CFrame
            local change = current.LookVector:Dot(lastCFrame.LookVector)
            
            if change < 0.999 and change > 0.95 then
                camera.CFrame = lastCFrame:Lerp(current, 0.3)
            end
            
            lastCFrame = camera.CFrame
        end)
    end)
end

-- Speed
local speedConnection
local originalSpeed = 16
local function setSpeed(mult)
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    
    pcall(function()
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if mult == 1 then
                    originalSpeed = hum.WalkSpeed
                end
                hum.WalkSpeed = originalSpeed * mult
                
                speedConnection = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
                    if settings.speedMultiplier ~= 1 then
                        hum.WalkSpeed = originalSpeed * settings.speedMultiplier
                    end
                end)
            end
        end
    end)
end
