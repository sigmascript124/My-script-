-- ESP скрипт для Roblox
-- Работает всегда, даже для новых игроков и после смерти

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Настройки
local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0)

-- Переменные
local espConnections = {}
local espLabels = {}

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Кнопка ESP
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 150, 0, 60)
espButton.Position = UDim2.new(1, -170, 0, 20)
espButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
espButton.BorderSizePixel = 0
espButton.Text = ""
espButton.Parent = screenGui

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = espButton

local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(1, -70, 1, 0)
espLabel.Position = UDim2.new(0, 10, 0, 0)
espLabel.BackgroundTransparency = 1
espLabel.Text = "👁️ ESP"
espLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
espLabel.TextSize = 18
espLabel.Font = Enum.Font.GothamBold
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Parent = espButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 60, 0, 35)
statusLabel.Position = UDim2.new(1, -65, 0.5, -17.5)
statusLabel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
statusLabel.Text = "OFF"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Parent = espButton

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

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
            billboard.Size = UDim2.new(0, 200, 0, 50)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.Parent = head
            
            -- Имя игрока
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = targetPlayer.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 16
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextStrokeTransparency = 0.5
            nameLabel.Parent = billboard
            
            -- Расстояние
            local distLabel = Instance.new("TextLabel")
            distLabel.Size = UDim2.new(1, 0, 0.5, 0)
            distLabel.Position = UDim2.new(0, 0, 0.5, 0)
            distLabel.BackgroundTransparency = 1
            distLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            distLabel.TextSize = 14
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextStrokeTransparency = 0.5
            distLabel.Parent = billboard
            
            table.insert(espLabels, billboard)
            
            -- Обновление расстояния в реальном времени
            local distConnection = RunService.RenderStepped:Connect(function()
                if not espEnabled then
                    distConnection:Disconnect()
                    return
                end
                
                pcall(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and head then
                        local distance = (player.Character.HumanoidRootPart.Position - head.Position).Magnitude
                        distLabel.Text = string.format("%.1f studs", distance)
                    end
                end)
            end)
            
            table.insert(espConnections, distConnection)
        end
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

-- Кнопка переключения ESP
espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    
    if espEnabled then
        statusLabel.Text = "ON"
        statusLabel.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        statusLabel.Text = "OFF"
        statusLabel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    toggleESP(espEnabled)
end)

print("🎮 ESP скрипт загружен!")
print("💡 Нажми кнопку ESP чтобы включить/выключить")