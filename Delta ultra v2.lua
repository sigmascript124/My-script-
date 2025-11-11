-- Ultra Delta v2 GUI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Создание основного GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UltraDeltaV2"
ScreenGui.Parent = player.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 400)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок окна
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Ultra Delta v2"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 14
TitleLabel.Parent = TitleBar

-- Кнопки управления окном
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

-- Контейнер для контента
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Вкладки режимов
local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Size = UDim2.new(1, 0, 0, 40)
TabsFrame.BackgroundTransparency = 1
TabsFrame.Parent = ContentFrame

local TabButtons = {}
local CurrentTab = "default"

-- Создание кнопок вкладок
local tabNames = {"default", "99 ночей", "fan(visual)"}
for i, tabName in ipairs(tabNames) do
    local TabButton = Instance.new("TextButton")
    TabButton.Name = tabName
    TabButton.Size = UDim2.new(1/3, -2, 1, 0)
    TabButton.Position = UDim2.new((i-1)/3, 0, 0, 0)
    TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabButton.Font = Enum.Font.Gotham
    TabButton.TextSize = 12
    TabButton.Parent = TabsFrame
    table.insert(TabButtons, TabButton)
end

-- Контейнеры для содержимого вкладок
local TabContents = Instance.new("Frame")
TabContents.Name = "TabContents"
TabContents.Size = UDim2.new(1, -10, 1, -50)
TabContents.Position = UDim2.new(0, 5, 0, 45)
TabContents.BackgroundTransparency = 1
TabContents.Parent = ContentFrame

-- Переменные для функций
local SpeedConnections = {}
local JumpConnections = {}
local RegenConnection = nil
local NoclipConnection = nil
local AimbotConnection = nil
local CurrentSpeed = 0
local CurrentJump = 0
local IsNoclip = false
local IsAimbot = false
local IsInstantAimbot = false
local IsRegeneration = false
local AimbotTarget = nil

-- Таблица для хранения состояний кнопок
local ButtonStates = {
    Noclip = false,
    Aimbot = false,
    InstantAimbot = false,
    Regeneration = false
}

-- Таблица для хранения ссылок на кнопки
local ActiveButtons = {}

-- Функция создания кнопки-переключателя
local function CreateToggleButton(parent, text, position, initialState, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = position
    button.BackgroundColor3 = initialState and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
    button.Text = text .. (initialState and " [ON]" or " [OFF]")
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = parent
    
    button.MouseButton1Click:Connect(function()
        local newState = not initialState
        callback(newState)
        
        -- Обновляем визуальное состояние
        button.BackgroundColor3 = newState and Color3.fromRGB(60, 180, 60) or Color3.fromRGB(180, 60, 60)
        button.Text = text .. (newState and " [ON]" or " [OFF]")
        initialState = newState
    end)
    
    return button
end

-- Функция создания обычной кнопки (для скоростей и прыжков)
local function CreateButton(parent, text, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = parent
    
    button.MouseButton1Click:Connect(callback)
    return button
end

-- Функции модов
local function SetSpeed(multiplier)
    for _, conn in pairs(SpeedConnections) do
        conn:Disconnect()
    end
    SpeedConnections = {}
    
    if multiplier == 0 then
        CurrentSpeed = 0
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
        return
    end
    
    CurrentSpeed = multiplier
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 16 * multiplier
    end
    
    local conn = player.CharacterAdded:Connect(function(char)
        wait(1)
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16 * multiplier
        end
    end)
    table.insert(SpeedConnections, conn)
end

local function SetJump(multiplier)
    for _, conn in pairs(JumpConnections) do
        conn:Disconnect()
    end
    JumpConnections = {}
    
    if multiplier == 0 then
        CurrentJump = 0
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = 50
        end
        return
    end
    
    CurrentJump = multiplier
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = 50 * multiplier
    end
    
    local conn = player.CharacterAdded:Connect(function(char)
        wait(1)
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.JumpPower = 50 * multiplier
        end
    end)
    table.insert(JumpConnections, conn)
end

-- Функция регенерации
local function SetRegeneration(enabled)
    if RegenConnection then
        RegenConnection:Disconnect()
        RegenConnection = nil
    end
    
    IsRegeneration = enabled
    
    if enabled then
        RegenConnection = RunService.Heartbeat:Connect(function()
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end
        end)
    end
end

-- Функция ноуклипа
local function SetNoclip(enabled)
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    
    IsNoclip = enabled
    
    if enabled then
        NoclipConnection = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Функция авто-аима
local function SetAimbot(enabled)
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
        AimbotTarget = nil
    end
    
    IsAimbot = enabled
    IsInstantAimbot = false
    
    if enabled then
        AimbotConnection = RunService.RenderStepped:Connect(function()
            if not player.Character then return end
            
            local camera = workspace.CurrentCamera
            local myHead = player.Character:FindFirstChild("Head")
            if not myHead then return end
            
            local closestPlayer = nil
            local closestDistance = math.huge
            
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local otherHead = otherPlayer.Character:FindFirstChild("Head")
                    if otherHead then
                        local direction = (otherHead.Position - myHead.Position).Unit
                        local lookVector = camera.CFrame.LookVector
                        local dotProduct = direction:Dot(lookVector)
                        
                        if dotProduct > 0.5 then
                            local distance = (otherHead.Position - myHead.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = otherPlayer
                            end
                        end
                    end
                end
            end
            
            if closestPlayer and closestPlayer.Character then
                local targetHead = closestPlayer.Character:FindFirstChild("Head")
                if targetHead then
                    AimbotTarget = closestPlayer
                    local currentCF = camera.CFrame
                    local targetPosition = targetHead.Position
                    local newCF = CFrame.lookAt(currentCF.Position, targetPosition)
                    camera.CFrame = newCF:Lerp(newCF, 0.1)
                end
            else
                AimbotTarget = nil
            end
        end)
    end
end

-- Функция мгновенного авто-аима
local function SetInstantAimbot(enabled)
    if AimbotConnection then
        AimbotConnection:Disconnect()
        AimbotConnection = nil
        AimbotTarget = nil
    end
    
    IsInstantAimbot = enabled
    IsAimbot = false
    
    if enabled then
        AimbotConnection = RunService.RenderStepped:Connect(function()
            if not player.Character then return end
            
            local camera = workspace.CurrentCamera
            local myHead = player.Character:FindFirstChild("Head")
            if not myHead then return end
            
            local closestPlayer = nil
            local closestDistance = math.huge
            
            for _, otherPlayer in pairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local otherHead = otherPlayer.Character:FindFirstChild("Head")
                    if otherHead then
                        local direction = (otherHead.Position - myHead.Position).Unit
                        local lookVector = camera.CFrame.LookVector
                        local dotProduct = direction:Dot(lookVector)
                        
                        if dotProduct > 0.3 then
                            local distance = (otherHead.Position - myHead.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestPlayer = otherPlayer
                            end
                        end
                    end
                end
            end
            
            if closestPlayer and closestPlayer.Character then
                local targetHead = closestPlayer.Character:FindFirstChild("Head")
                if targetHead then
                    AimbotTarget = closestPlayer
                    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHead.Position)
                end
            else
                AimbotTarget = nil
            end
        end)
    end
end

-- Функция сброса всех состояний кнопок
local function ResetAllButtons()
    SetNoclip(false)
    SetAimbot(false)
    SetInstantAimbot(false)
    SetRegeneration(false)
    SetSpeed(0)
    SetJump(0)
    
    -- Обновляем все кнопки в интерфейсе
    for _, button in pairs(ActiveButtons) do
        if button:IsA("TextButton") then
            local text = button.Text:gsub(" %[ON%]", ""):gsub(" %[OFF%]", "")
            button.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            button.Text = text .. " [OFF]"
        end
    end
end

-- Создание вкладки Default
local DefaultTab = Instance.new("ScrollingFrame")
DefaultTab.Name = "default"
DefaultTab.Size = UDim2.new(1, 0, 1, 0)
DefaultTab.BackgroundTransparency = 1
DefaultTab.ScrollingEnabled = true
DefaultTab.Visible = false
DefaultTab.Parent = TabContents

local DefaultLayout = Instance.new("UIListLayout")
DefaultLayout.Parent = DefaultTab
DefaultLayout.Padding = UDim.new(0, 5)

local yPosition = 5

-- Ноуклип
local noclipButton = CreateToggleButton(DefaultTab, "NoClip", UDim2.new(0, 5, 0, yPosition), false, function(state)
    SetNoclip(state)
end)
table.insert(ActiveButtons, noclipButton)
yPosition = yPosition + 35

-- Авто-аим
local aimbotButton = CreateToggleButton(DefaultTab, "Auto Aim", UDim2.new(0, 5, 0, yPosition), false, function(state)
    if state then
        SetAimbot(true)
        SetInstantAimbot(false)
        -- Обновляем кнопку мгновенного аима
        if instantAimbotButton then
            instantAimbotButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            instantAimbotButton.Text = "Instant Aim [OFF]"
        end
    else
        SetAimbot(false)
    end
end)
table.insert(ActiveButtons, aimbotButton)
yPosition = yPosition + 35

local instantAimbotButton = CreateToggleButton(DefaultTab, "Instant Aim", UDim2.new(0, 5, 0, yPosition), false, function(state)
    if state then
        SetInstantAimbot(true)
        SetAimbot(false)
        -- Обновляем кнопку обычного аима
        if aimbotButton then
            aimbotButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            aimbotButton.Text = "Auto Aim [OFF]"
        end
    else
        SetInstantAimbot(false)
    end
end)
table.insert(ActiveButtons, instantAimbotButton)
yPosition = yPosition + 35

-- Регенерация
local regenButton = CreateToggleButton(DefaultTab, "Регенерация", UDim2.new(0, 5, 0, yPosition), false, function(state)
    SetRegeneration(state)
end)
table.insert(ActiveButtons, regenButton)
yPosition = yPosition + 35

-- Разделитель
local separator = Instance.new("TextLabel")
separator.Size = UDim2.new(1, -10, 0, 20)
separator.Position = UDim2.new(0, 5, 0, yPosition)
separator.BackgroundTransparency = 1
separator.Text = "=== СКОРОСТЬ ==="
separator.TextColor3 = Color3.fromRGB(255, 255, 255)
separator.Font = Enum.Font.GothamBold
separator.TextSize = 12
separator.Parent = DefaultTab
yPosition = yPosition + 25

-- Скорость
CreateButton(DefaultTab, "Скорость 10x", UDim2.new(0, 5, 0, yPosition), function()
    SetSpeed(10)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Скорость 20x", UDim2.new(0, 5, 0, yPosition), function()
    SetSpeed(20)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Скорость 30x", UDim2.new(0, 5, 0, yPosition), function()
    SetSpeed(30)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Скорость 50x", UDim2.new(0, 5, 0, yPosition), function()
    SetSpeed(50)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Скорость 100x", UDim2.new(0, 5, 0, yPosition), function()
    SetSpeed(100)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Скорость 500x", UDim2.new(0, 5, 0, yPosition), function()
    SetSpeed(500)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Супер скорость 25000x", UDim2.new(0, 5, 0, yPosition), function()
    SetSpeed(25000)
end)
yPosition = yPosition + 35

-- Разделитель
local separator2 = Instance.new("TextLabel")
separator2.Size = UDim2.new(1, -10, 0, 20)
separator2.Position = UDim2.new(0, 5, 0, yPosition)
separator2.BackgroundTransparency = 1
separator2.Text = "=== ПРЫЖОК ==="
separator2.TextColor3 = Color3.fromRGB(255, 255, 255)
separator2.Font = Enum.Font.GothamBold
separator2.TextSize = 12
separator2.Parent = DefaultTab
yPosition = yPosition + 25

-- Прыжок
CreateButton(DefaultTab, "Прыжок 10x", UDim2.new(0, 5, 0, yPosition), function()
    SetJump(10)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Прыжок 20x", UDim2.new(0, 5, 0, yPosition), function()
    SetJump(20)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Прыжок 30x", UDim2.new(0, 5, 0, yPosition), function()
    SetJump(30)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Прыжок 50x", UDim2.new(0, 5, 0, yPosition), function()
    SetJump(50)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Прыжок 100x", UDim2.new(0, 5, 0, yPosition), function()
    SetJump(100)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Прыжок 500x", UDim2.new(0, 5, 0, yPosition), function()
    SetJump(500)
end)
yPosition = yPosition + 35

CreateButton(DefaultTab, "Супер прыжок 25000x", UDim2.new(0, 5, 0, yPosition), function()
    SetJump(25000)
end)
yPosition = yPosition + 35

-- Кнопка выключения всех модов
local disableAllButton = CreateButton(DefaultTab, "🚫 ВЫКЛЮЧИТЬ ВСЕ МОДЫ", UDim2.new(0, 5, 0, yPosition), function()
    ResetAllButtons()
end)
disableAllButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
yPosition = yPosition + 35

-- Создание других вкладок (заглушки)
local NightTab = Instance.new("Frame")
NightTab.Name = "99 ночей"
NightTab.Size = UDim2.new(1, 0, 1, 0)
NightTab.BackgroundTransparency = 1
NightTab.Visible = false
NightTab.Parent = TabContents

local FanTab = Instance.new("Frame")
FanTab.Name = "fan(visual)"
FanTab.Size = UDim2.new(1, 0, 1, 0)
FanTab.BackgroundTransparency = 1
FanTab.Visible = false
FanTab.Parent = TabContents

-- Функция переключения вкладок
local function SwitchTab(tabName)
    CurrentTab = tabName
    
    for _, tab in pairs(TabContents:GetChildren()) do
        tab.Visible = false
    end
    
    local selectedTab = TabContents:FindFirstChild(tabName)
    if selectedTab then
        selectedTab.Visible = true
    end
    
    for _, button in pairs(TabButtons) do
        if button.Name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
        else
            button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        end
    end
end

-- Создание кнопки для разворачивания
local RestoreButton = Instance.new("TextButton")
RestoreButton.Name = "RestoreButton"
RestoreButton.Size = UDim2.new(0, 100, 0, 40)
RestoreButton.Position = UDim2.new(0, 10, 0, 10)
RestoreButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
RestoreButton.Text = "Ultra Delta v2"
RestoreButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RestoreButton.Font = Enum.Font.GothamBold
Restore RestoreButton.TextSize = 12
RestoreButton.Visible = false
RestoreButton.Parent = ScreenGui

local IsMinimized = false

local function MinimizeWindow()
    MainFrame.Visible = false
    RestoreButton.Visible = true
    IsMinimized = true
end

local function RestoreWindow()
    MainFrame.Visible = true
    RestoreButton.Visible = false
    IsMinimized = false
end

-- Обработчики событий
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    if IsMinimized then
        RestoreWindow()
    else
        MinimizeWindow()
    end
end)

RestoreButton.MouseButton1Click:Connect(function()
    RestoreWindow()
end)

for _, button in pairs(TabButtons) do
    button.MouseButton1Click:Connect(function()
        SwitchTab(button.Name)
    end)
end

-- Активация первой вкладки
SwitchTab("default")

-- Корректировка размера скролл фрейма
DefaultTab.CanvasSize = UDim2.new(0, 0, 0, yPosition + 40)

-- Добавляем UIListLayout для автоматического расположения кнопок
DefaultLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    DefaultTab.CanvasSize = UDim2.new(0, 0, 0, DefaultLayout.AbsoluteContentSize.Y + 10)
end)

-- Функция для защиты от античитов (опционально)
local function SafeExecute(func)
    local success, err = pcall(func)
    if not success then
        warn("Ошибка в выполнении функции: " .. err)
    end
end

-- Защищаем основные функции
SafeExecute(function()
    -- Инициализация завершена
    print("Ultra Delta v2 успешно загружен!")
end)

-- Добавляем горячие клавиши (опционально)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightControl then
        -- Ctrl + RightControl для показа/скрытия GUI
        MainFrame.Visible = not MainFrame.Visible
        RestoreButton.Visible = not MainFrame.Visible
    elseif input.KeyCode == Enum.KeyCode.Insert then
        -- Insert для переключения видимости
        if MainFrame.Visible then
            MinimizeWindow()
        else
            RestoreWindow()
        end
    end
end)

-- Авто-обновление при респавне персонажа
player.CharacterAdded:Connect(function(character)
    -- Восстанавливаем настройки скорости и прыжка после респавна
    wait(1) -- Ждем загрузки персонажа
    
    SafeExecute(function()
        if CurrentSpeed > 0 then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 * CurrentSpeed
            end
        end
        
        if CurrentJump > 0 then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = 50 * CurrentJump
            end
        end
    end)
end)

-- Защита от обнаружения (базовые меры)
local function AntiDetection()
    -- Меняем имена объектов чтобы скрыть от простых детектов
    ScreenGui.Name = "PlayerGui_" .. tostring(math.random(10000, 99999))
    MainFrame.Name = "MainFrame_" .. tostring(math.random(10000, 99999))
end

-- Вызываем защиту после небольшой задержки
delay(2, AntiDetection)

-- Финальное сообщение
print("🎮 Ultra Delta v2 активирован!")
print("📌 Горячие клавиши:")
print("   - RightControl: Показать/скрыть GUI")
print("   - Insert: Свернуть/развернуть")
print("⚠️ Используйте на свой страх и риск!")