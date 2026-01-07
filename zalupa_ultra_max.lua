-- ESP скрипт для Roblox
-- Работает всегда, даже для новых игроков и после смерти

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки
local espEnabled = false
local legitAimEnabled = false
local triggerbotEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)

-- Переменные
local espConnections = {}
local espLabels = {}
local legitAimConnection
local triggerbotConnection
local lockedTarget = nil

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Главная панель
local mainPanel = Instance.new("Frame")
mainPanel.Size = UDim2.new(0, 180, 0, 220)
mainPanel.Position = UDim2.new(1, -200, 0, 20)
mainPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainPanel.BorderSizePixel = 0
mainPanel.Active = true
mainPanel.Draggable = true
mainPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = mainPanel

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleLabel.Text = "🎯 Cheats Panel"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainPanel

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleLabel

-- Функция создания кнопки
local function createToggleButton(name, text, yPos, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 45)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = mainPanel
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 55, 0, 28)
    status.Position = UDim2.new(1, -60, 0.5, -14)
    status.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    status.Text = "OFF"
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 12
    status.Font = Enum.Font.GothamBold
    status.Parent = btn
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = status
    
    btn.MouseButton1Click:Connect(function()
        callback(status)
    end)
    
    return btn, status
end

-- Функция добавления ESP к персонажу
local function addESP(character, targetPlayer)
    if not espEnabled then return end
    if not character or character == player.Character then return end
    
    pcall(function()
        -- Удаление старого ESP если есть
        if character:FindFirstChild("AdminESP") then
            character.AdminESP:Destroy()
        end
        
        local head = character:FindFirstChild("Head")
        if head and head:FindFirstChild("ESPLabel") then
            head.ESPLabel:Destroy()
        end
        
        task.wait(0.1) -- Небольшая задержка для загрузки персонажа
        
        -- Создание Highlight (подсветка через стены)
        local highlight = Instance.new("Highlight")
        highlight.Name = "AdminESP"
        highlight.FillColor = espColor
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        
        -- Создание текста над головой
        head = character:FindFirstChild("Head")
        if head then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "ESPLabel"
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 80)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head
            
            -- Имя игрока
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0, 20)
            nameLabel.Position = UDim2.new(0, 0, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = targetPlayer.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 16
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.Parent = billboard
            
            -- HP игрока
            local hpLabel = Instance.new("TextLabel")
            hpLabel.Size = UDim2.new(1, 0, 0, 18)
            hpLabel.Position = UDim2.new(0, 0, 0, 20)
            hpLabel.BackgroundTransparency = 1
            hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            hpLabel.TextSize = 14
            hpLabel.Font = Enum.Font.GothamBold
            hpLabel.TextStrokeTransparency = 0.5
            hpLabel.Parent = billboard
            
            -- Расстояние
            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(1, 0, 0, 16)
            distLabel.Position = UDim2.new(0, 0, 0, 38)
            distLabel.BackgroundTransparency = 1
            distLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            distLabel.TextSize = 13
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextStrokeTransparency = 0.5
            distLabel.Parent = billboard
            
            -- Статус (перезарядка/оружие)
            local statusLabel = Instance.new("TextLabel")
            statusLabel.Size = UDim2.new(1, 0, 0, 16)
            statusLabel.Position = UDim2.new(0, 0, 0, 54)
            statusLabel.BackgroundTransparency = 1
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            statusLabel.TextSize = 13
            statusLabel.Font = Enum.Font.GothamBold
            statusLabel.TextStrokeTransparency = 0.5
            statusLabel.Text = ""
            statusLabel.Parent = billboard
            
            table.insert(espLabels, billboard)
            
            -- Обновление информации в реальном времени
            local updateConnection = RunService.RenderStepped:Connect(function()
                if not espEnabled then
                    updateConnection:Disconnect()
                    return
                end
                
                pcall(function()
                    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not head then
                        return
                    end
                    
                    local myRoot = player.Character.HumanoidRootPart
                    local targetRoot = character:FindFirstChild("HumanoidRootPart")
                    
                    if targetRoot then
                        -- Расстояние
                        local distance = (myRoot.Position - head.Position).Magnitude
                        distLabel.Text = string.format("%.1f studs", distance)
                        
                        -- Проверка видимости (в поле зрения)
                        local camera = workspace.CurrentCamera
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {player.Character}
                        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                        
                        local rayResult = workspace:Raycast(myRoot.Position, (head.Position - myRoot.Position).Unit * distance, rayParams)
                        
                        -- Если враг в прямой видимости - ЯРКО КРАСНЫЙ
                        if rayResult and rayResult.Instance:IsDescendantOf(character) then
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            highlight.FillTransparency = 0.2
                            highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                        else
                            -- Если за стеной - обычный цвет
                            highlight.FillColor = espColor
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        end
                        
                        -- HP
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            local hp = math.floor(humanoid.Health)
                            local maxHp = math.floor(humanoid.MaxHealth)
                            local hpPercent = (hp / maxHp) * 100
                            
                            hpLabel.Text = string.format("❤️ %d/%d HP", hp, maxHp)
                            
                            -- Цвет HP в зависимости от количества
                            if hpPercent > 70 then
                                hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                            elseif hpPercent > 30 then
                                hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                            else
                                hpLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                            end
                        end
                        
                        -- Проверка оружия и перезарядки
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then
                            -- Ищем скрипты с информацией о перезарядке
                            local isReloading = false
                            
                            -- Проверка анимаций на перезарядку
                            local animTracks = humanoid:GetPlayingAnimationTracks()
                            for _, track in pairs(animTracks) do
                                local animName = track.Animation.AnimationId:lower()
                                if animName:find("reload") then
                                    isReloading = true
                                    break
                                end
                            end
                            
                            -- Проверка названия инструмента
                            if tool.Name:lower():find("reload") then
                                isReloading = true
                            end
                            
                            if isReloading then
                                statusLabel.Text = "🔄 ПЕРЕЗАРЯДКА"
                                statusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                            else
                                statusLabel.Text = "🔫 " .. tool.Name
                                statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                            end
                        else
                            statusLabel.Text = ""
                        end
                    end
                end)
            end)
            
            table.insert(espConnections, updateConnection)
        end
    end)
end

-- Legit Aim функция
local function toggleLegitAim(enabled)
    legitAimEnabled = enabled
    
    if legitAimConnection then
        legitAimConnection:Disconnect()
        legitAimConnection = nil
    end
    
    lockedTarget = nil
    
    if not enabled then
        print("❌ Legit Aim выключен")
        return
    end
    
    print("✅ Legit Aim включен")
    
    legitAimConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            local camera = workspace.CurrentCamera
            local char = player.Character
            if not char then return end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            
            -- Поиск ближайшей цели в прицеле
            local closest = nil
            local closestDist = math.huge
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local targetChar = p.Character
                    local hum = targetChar:FindFirstChildOfClass("Humanoid")
                    
                    if hum and hum.Health > 0 then
                        -- Случайный выбор части тела (легит-аим)
                        local targetPart
                        local rand = math.random(1, 100)
                        
                        if rand <= 40 then -- 40% - торс
                            targetPart = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso")
                        elseif rand <= 70 then -- 30% - голова
                            targetPart = targetChar:FindFirstChild("Head")
                        else -- 30% - случайная часть
                            local parts = {"LeftUpperArm", "RightUpperArm", "UpperTorso", "Head"}
                            local partName = parts[math.random(1, #parts)]
                            targetPart = targetChar:FindFirstChild(partName) or targetChar:FindFirstChild("Head")
                        end
                        
                        if targetPart then
                            local dist = (root.Position - targetPart.Position).Magnitude
                            if dist < 300 then -- Ограничение дистанции
                                local rayParams = RaycastParams.new()
                                rayParams.FilterDescendantsInstances = {char}
                                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                                
                                local rayResult = workspace:Raycast(root.Position, (targetPart.Position - root.Position).Unit * dist, rayParams)
                                if rayResult and rayResult.Instance:IsDescendantOf(targetChar) then
                                    local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                                    
                                    if onScreen then
                                        local mousePos = UserInputService:GetMouseLocation()
                                        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                                        
                                        if screenDist < 150 and dist < closestDist then
                                            closest = targetPart
                                            closestDist = dist
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Плавное легит наведение
            if closest then
                -- Добавление случайного смещения для легитности
                local randomOffset = Vector3.new(
                    math.random(-10, 10) / 100,
                    math.random(-10, 10) / 100,
                    0
                )
                
                local targetPos = closest.Position + randomOffset
                local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)
                
                -- Очень плавная интерполяция (легит)
                local smoothness = math.random(8, 15) / 100 -- 0.08-0.15
                camera.CFrame = camera.CFrame:Lerp(targetCFrame, smoothness)
            end
        end)
    end)
end

-- Triggerbot функция
local function toggleTriggerbot(enabled)
    triggerbotEnabled = enabled
    
    if triggerbotConnection then
        triggerbotConnection:Disconnect()
        triggerbotConnection = nil
    end
    
    if not enabled then
        print("❌ Triggerbot выключен")
        return
    end
    
    print("✅ Triggerbot включен")
    
    local mouse = player:GetMouse()
    
    triggerbotConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            local target = mouse.Target
            if not target then return end
            
            -- Проверка что это персонаж игрока
            local targetChar = target.Parent
            if not targetChar or not targetChar:FindFirstChildOfClass("Humanoid") then
                targetChar = target.Parent.Parent
            end
            
            if targetChar and targetChar:FindFirstChildOfClass("Humanoid") then
                local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
                
                if targetPlayer and targetPlayer ~= player then
                    local hum = targetChar:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        -- Проверка что у игрока есть оружие
                        local tool = player.Character:FindFirstChildOfClass("Tool")
                        if tool then
                            -- Небольшая случайная задержка для легитности
                            local delay = math.random(50, 150) / 1000 -- 50-150ms
                            task.wait(delay)
                            
                            -- Поиск RemoteEvent для стрельбы
                            for _, obj in pairs(tool:GetDescendants()) do
                                if obj:IsA("RemoteEvent") and (obj.Name:lower():find("fire") or obj.Name:lower():find("shoot")) then
                                    obj:FireServer()
                                    break
                                end
                            end
                            
                            -- Альтернативный метод - активация инструмента
                            if tool:FindFirstChild("Handle") then
                                tool:Activate()
                            end
                        end
                    end
                end
            end
        end)
    end)
end
-- Функция включения/выключения ESP
local function toggleESP(enabled)
    espEnabled = enabled
    
    -- Очистка всех соединений
    for _, conn in pairs(espConnections) do
        pcall(function() conn:Disconnect() end)
    end
    espConnections = {}
    
    -- Удаление всех ESP меток
    for _, label in pairs(espLabels) do
        pcall(function() label:Destroy() end)
    end
    espLabels = {}
    
    -- Удаление всех Highlight
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Highlight") and obj.Name == "AdminESP" then
            pcall(function() obj:Destroy() end)
        end
        if obj:IsA("BillboardGui") and obj.Name == "ESPLabel" then
            pcall(function() obj:Destroy() end)
        end
    end
    
    if not enabled then
        print("❌ ESP выключен")
        return
    end
    
    print("✅ ESP включен")
    
-- Добавление ESP для всех существующих игроков
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            -- Если персонаж уже есть
            if otherPlayer.Character then
                addESP(otherPlayer.Character, otherPlayer)
            end
            
            -- Отслеживание появления персонажа (возрождение)
            local charConnection = otherPlayer.CharacterAdded:Connect(function(character)
                if espEnabled then
                    addESP(character, otherPlayer)
                end
            end)
            table.insert(espConnections, charConnection)
        end
    end
    
    -- Отслеживание новых игроков
    local playerAddedConnection = Players.PlayerAdded:Connect(function(newPlayer)
        if not espEnabled then return end
        
        -- ESP при появлении персонажа нового игрока
        local charConnection = newPlayer.CharacterAdded:Connect(function(character)
            if espEnabled then
                addESP(character, newPlayer)
            end
        end)
        table.insert(espConnections, charConnection)
        
        -- Если персонаж уже загружен
        if newPlayer.Character then
            addESP(newPlayer.Character, newPlayer)
        end
    end)
    table.insert(espConnections, playerAddedConnection)
    
    -- Автоматическая проверка каждую секунду
    -- Если ESP пропал или игрок возродился - добавляем заново
    local autoCheckConnection = RunService.Heartbeat:Connect(function()
        if not espEnabled then
            autoCheckConnection:Disconnect()
            return
        end
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local character = otherPlayer.Character
                -- Если ESP отсутствует - добавляем
                if not character:FindFirstChild("AdminESP") then
                    addESP(character, otherPlayer)
                end
            end
        end
    end)
    table.insert(espConnections, autoCheckConnection)
end

-- Создание кнопок
createToggleButton("ESP", "👁️ ESP", 45, function(status)
    espEnabled = not espEnabled
    status.Text = espEnabled and "ON" or "OFF"
    status.BackgroundColor3 = espEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    toggleESP(espEnabled)
end)

createToggleButton("LegitAim", "🎯 Legit Aim", 100, function(status)
    legitAimEnabled = not legitAimEnabled
    status.Text = legitAimEnabled and "ON" or "OFF"
    status.BackgroundColor3 = legitAimEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    toggleLegitAim(legitAimEnabled)
end)

createToggleButton("Triggerbot", "🔫 Triggerbot", 155, function(status)
    triggerbotEnabled = not triggerbotEnabled
    status.Text = triggerbotEnabled and "ON" or "OFF"
    status.BackgroundColor3 = triggerbotEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    toggleTriggerbot(triggerbotEnabled)
end)

print("🎮 Cheats Panel загружен!")
print("💡 Доступно:")
print("  👁️ ESP - подсветка игроков")
print("  🎯 Legit Aim - плавное наведение")
print("  🔫 Triggerbot - автострельба")