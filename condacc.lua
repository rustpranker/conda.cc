-- CONDA.CC - Universal Script for Solara
if _G.CondaCC then return end
_G.CondaCC = true

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GS = game:GetService("GuiService")
local SG = game:GetService("StarterGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Settings
local Settings = {
    ESP = {
        Hitbox = false,
        Username = false,
        Healthbar = false,
        Glow = false,
        Color = Color3.fromRGB(0, 100, 255)
    },
    Rage = {
        SilentAim = false,
        FOV = 55,
        ShowCircle = false,
        CameraLock = false,
        CameraLockKey = Enum.KeyCode.Z,
        DisableKey = Enum.KeyCode.P,
        AimPart = "HumanoidRootPart",
        Prediction = 0.15038,
        AimlockState = true
    },
    Macro = {
        SpeedEnabled = false,
        Speed = 50,
        OriginalSpeed = 16,
        SpeedKey = nil,
        
        FlyEnabled = false,
        FlySpeed = 3,
        FlyKey = nil,
        Flying = false,
        
        JumpEnabled = false,
        JumpPower = 50,
        OriginalJump = 50
    },
    UI = {
        Color = Color3.fromRGB(0, 100, 255)
    }
}

-- ESP Storage
local ESPObjects = {}

-- SPOILEDROTTEN CAMERA LOCK SYSTEM (СТАБИЛЬНАЯ ВЕРСИЯ)
local Camera = workspace.CurrentCamera
local GetGuiInset = GS.GetGuiInset

local Locked = false
local Victim = nil
local LastTargetCheck = 0

-- FOV Circle
local fov = Drawing.new("Circle")
fov.Filled = false
fov.Transparency = 1
fov.Thickness = 1
fov.Color = Color3.fromRGB(255, 255, 0)
fov.NumSides = 1000

function update()
    if fov then
        fov.Radius = Settings.Rage.FOV * 2
        fov.Visible = Settings.Rage.ShowCircle
        fov.Position = Vector2.new(mouse.X, mouse.Y + GetGuiInset(GS).Y)
        return fov
    end
end

function getClosest()
    local closestPlayer
    local shortestDistance = math.huge

    for i, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild(Settings.Rage.AimPart) then
            local pos = Camera:WorldToViewportPoint(v.Character.PrimaryPart.Position)
            local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).magnitude
            
            if (Settings.Rage.ShowCircle) then
                if (fov.Radius > magnitude and magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            else
                if (magnitude < shortestDistance) then
                    closestPlayer = v
                    shortestDistance = magnitude
                end
            end
        end
    end
    return closestPlayer
end

function Notify(message)
    SG:SetCore("SendNotification", {
        Title = "CONDA.CC",
        Text = message,
        Duration = 3
    })
end

-- Create main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CondaCCUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 500, 0, 400)

-- Rounded corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Header with logo
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Header.BorderSizePixel = 0
Header.Position = UDim2.new(0, 0, 0, 0)
Header.Size = UDim2.new(1, 0, 0, 50)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "CONDA.CC"
Title.TextColor3 = Settings.UI.Color
Title.TextSize = 24
Title.TextStrokeTransparency = 0.7
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tabs container
local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Parent = MainFrame
TabsContainer.BackgroundTransparency = 1
TabsContainer.Position = UDim2.new(0, 0, 0, 50)
TabsContainer.Size = UDim2.new(0, 100, 0, 350)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabsContainer

-- Content container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ContentContainer.BorderSizePixel = 0
ContentContainer.Position = UDim2.new(0, 100, 0, 50)
ContentContainer.Size = UDim2.new(0, 400, 0, 350)

local ContentScrolling = Instance.new("ScrollingFrame")
ContentScrolling.Size = UDim2.new(1, 0, 1, 0)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.ScrollBarThickness = 3
ContentScrolling.ScrollBarImageColor3 = Settings.UI.Color
ContentScrolling.Parent = ContentContainer

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.Parent = ContentScrolling

-- Создание вкладок
local tabs = {"ESP", "RAGE", "MACRO", "MISC", "README"}
local tabButtons = {}
local tabFrames = {}
local currentTab = "ESP"

-- Функция создания кнопки вкладки
local function createTabButton(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    TabButton.BorderSizePixel = 0
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabButton.TextSize = 12
    TabButton.Font = Enum.Font.Gotham
    TabButton.Parent = TabsContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = TabButton
    
    -- Создаем фрейм для контента вкладки
    local TabContentFrame = Instance.new("Frame")
    TabContentFrame.Size = UDim2.new(1, 0, 1, 0)
    TabContentFrame.BackgroundTransparency = 1
    TabContentFrame.Visible = false
    TabContentFrame.Parent = ContentScrolling
    
    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.Padding = UDim.new(0, 8)
    TabContentLayout.Parent = TabContentFrame
    
    tabFrames[tabName] = TabContentFrame
    
    TabButton.MouseButton1Click:Connect(function()
        currentTab = tabName
        -- Скрываем все фреймы
        for name, frame in pairs(tabFrames) do
            frame.Visible = (name == tabName)
        end
        
        -- Обновляем цвета всех кнопок
        for name, button in pairs(tabButtons) do
            if name == tabName then
                button.BackgroundColor3 = Settings.UI.Color
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end)
    
    tabButtons[tabName] = TabButton
    return TabContentFrame
end

-- Создаем все вкладки
for _, tabName in pairs(tabs) do
    createTabButton(tabName)
end

-- Функция создания слайдера
local function createSlider(parent, name, defaultValue, minValue, maxValue, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 60)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 14
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 80, 0, 20)
    ValueLabel.Position = UDim2.new(1, -80, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = "Q:"..tostring(defaultValue)
    ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.Gotham
    ValueLabel.Parent = SliderFrame
    
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Size = UDim2.new(1, 0, 0, 20)
    SliderBackground.Position = UDim2.new(0, 0, 0, 25)
    SliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    SliderBackground.BorderSizePixel = 0
    SliderBackground.Parent = SliderFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 4)
    SliderCorner.Parent = SliderBackground
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    SliderFill.BackgroundColor3 = Settings.UI.Color
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBackground
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = SliderFill
    
    -- Бегунок
    local SliderHandle = Instance.new("Frame")
    SliderHandle.Size = UDim2.new(0, 6, 0, 24)
    SliderHandle.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -3, 0, -2)
    SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderHandle.BorderSizePixel = 0
    SliderHandle.Parent = SliderBackground
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(0, 2)
    HandleCorner.Parent = SliderHandle
    
    local isDragging = false
    
    -- Функция обновления слайдера
    local function updateSlider(value)
        value = math.clamp(value, minValue, maxValue)
        local fillWidth = (value - minValue) / (maxValue - minValue)
        SliderFill.Size = UDim2.new(fillWidth, 0, 1, 0)
        SliderHandle.Position = UDim2.new(fillWidth, -3, 0, -2)
        ValueLabel.Text = "Q:"..math.floor(value)
        
        if callback then
            callback(value)
        end
    end
    
    -- Обработка dragging
    local function onInputChanged(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sliderAbsolutePos = SliderBackground.AbsolutePosition
            local sliderAbsoluteSize = SliderBackground.AbsoluteSize
            local mouseX = mouse.X
            
            local relativeX = (mouseX - sliderAbsolutePos.X) / sliderAbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            local newValue = minValue + (relativeX * (maxValue - minValue))
            updateSlider(newValue)
        end
    end
    
    SliderHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
        end
    end)
    
    SliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local sliderAbsolutePos = SliderBackground.AbsolutePosition
            local sliderAbsoluteSize = SliderBackground.AbsoluteSize
            local mouseX = mouse.X
            
            local relativeX = (mouseX - sliderAbsolutePos.X) / sliderAbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            local newValue = minValue + (relativeX * (maxValue - minValue))
            updateSlider(newValue)
        end
    end)
    
    UserInputService.InputChanged:Connect(onInputChanged)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    return {update = updateSlider, value = defaultValue}
end

-- Функция создания кнопки
local function createButton(parent, name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 35)
    Button.BackgroundColor3 = Settings.UI.Color
    Button.BorderSizePixel = 0
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

-- Функция создания переключателя
local function createToggle(parent, name, defaultValue, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 30, 0, 30)
    ToggleButton.Position = UDim2.new(1, -30, 0, 0)
    ToggleButton.BackgroundColor3 = defaultValue and Settings.UI.Color or Color3.fromRGB(60, 60, 65)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        ToggleButton.BackgroundColor3 = defaultValue and Settings.UI.Color or Color3.fromRGB(60, 60, 65)
        if callback then
            callback(defaultValue)
        end
    end)
    
    return {frame = ToggleFrame, button = ToggleButton, value = defaultValue}
end

-- Функция создания keybind кнопки
local function createKeybind(parent, name, currentKey, callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Size = UDim2.new(1, -20, 0, 30)
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.Parent = parent
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(0, 120, 1, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = name
    KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindLabel.TextSize = 14
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = KeybindFrame
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0, 100, 1, 0)
    KeybindButton.Position = UDim2.new(0, 130, 0, 0)
    KeybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    KeybindButton.BorderSizePixel = 0
    KeybindButton.Text = currentKey and currentKey.Name or "Click to bind"
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.TextSize = 12
    KeybindButton.Font = Enum.Font.Gotham
    KeybindButton.Parent = KeybindFrame
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 4)
    KeybindCorner.Parent = KeybindButton
    
    local binding = false
    
    KeybindButton.MouseButton1Click:Connect(function()
        if not binding then
            binding = true
            KeybindButton.Text = "Press any key..."
            KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 0)
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    KeybindButton.Text = input.KeyCode.Name
                    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                    binding = false
                    if callback then
                        callback(input.KeyCode)
                    end
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    return KeybindButton
end

-- Функция создания цветового пикера с preset цветами
local function createColorPicker(parent, name, currentColor, callback)
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, -20, 0, 80)
    ColorFrame.BackgroundTransparency = 1
    ColorFrame.Parent = parent
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(1, 0, 0, 20)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = name
    ColorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ColorLabel.TextSize = 14
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Parent = ColorFrame
    
    -- Preset цвета
    local presetColors = {
        {Name = "Зеленый", Color = Color3.fromRGB(0, 255, 0)},
        {Name = "Желтый", Color = Color3.fromRGB(255, 255, 0)},
        {Name = "Красный", Color = Color3.fromRGB(255, 0, 0)},
        {Name = "Синий", Color = Color3.fromRGB(0, 100, 255)},
        {Name = "Белый", Color = Color3.fromRGB(255, 255, 255)},
        {Name = "Фиолетовый", Color = Color3.fromRGB(128, 0, 128)},
        {Name = "Розовый", Color = Color3.fromRGB(255, 105, 180)},
        {Name = "Оранжевый", Color = Color3.fromRGB(255, 165, 0)}
    }
    
    local colorButtons = {}
    for i, colorData in ipairs(presetColors) do
        local row = math.floor((i-1)/4)
        local col = (i-1) % 4
        
        local ColorButton = Instance.new("TextButton")
        ColorButton.Size = UDim2.new(0, 40, 0, 20)
        ColorButton.Position = UDim2.new(0, col * 45, 0, 25 + row * 25)
        ColorButton.BackgroundColor3 = colorData.Color
        ColorButton.BorderSizePixel = 1
        ColorButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
        ColorButton.Text = ""
        ColorButton.Parent = ColorFrame
        
        local ColorCorner = Instance.new("UICorner")
        ColorCorner.CornerRadius = UDim.new(0, 4)
        ColorCorner.Parent = ColorButton
        
        ColorButton.MouseButton1Click:Connect(function()
            if callback then
                callback(colorData.Color)
            end
        end)
        
        colorButtons[colorData.Name] = ColorButton
    end
    
    return ColorFrame
end

-- Функция обновления цветов UI
local function UpdateUIColors()
    Title.TextColor3 = Settings.UI.Color
    ContentScrolling.ScrollBarImageColor3 = Settings.UI.Color
    
    for name, button in pairs(tabButtons) do
        if name == currentTab then
            button.BackgroundColor3 = Settings.UI.Color
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end

-- СИСТЕМА СПИД-БУСТА
local SpeedConnection = nil

local function ApplySpeedBoost()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.WalkSpeed = Settings.Macro.Speed
            end)
        end
    end
end

local function ActivateSpeedBoost()
    if not Settings.Macro.SpeedEnabled then return end
    
    -- Сохраняем оригинальную скорость
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Settings.Macro.OriginalSpeed = humanoid.WalkSpeed
        end
    end
    
    -- Применяем скорость
    ApplySpeedBoost()
    
    -- Создаем постоянное обновление
    if SpeedConnection then
        SpeedConnection:Disconnect()
    end
    
    SpeedConnection = RunService.Heartbeat:Connect(function()
        ApplySpeedBoost()
    end)
end

local function DeactivateSpeedBoost()
    Settings.Macro.SpeedEnabled = false
    
    if SpeedConnection then
        SpeedConnection:Disconnect()
        SpeedConnection = nil
    end
    
    -- Возвращаем оригинальную скорость
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.WalkSpeed = Settings.Macro.OriginalSpeed
            end)
        end
    end
end

-- FLY SYSTEM
local FlyConnection = nil
local BodyVelocity = nil

local function StartFlying()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not root then return end
    
    Settings.Macro.Flying = true
    
    -- Create BodyVelocity for flying
    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
    BodyVelocity.Parent = root
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Settings.Macro.Flying or not BodyVelocity then
            if FlyConnection then
                FlyConnection:Disconnect()
            end
            return
        end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            BodyVelocity.Velocity = moveDirection.Unit * (Settings.Macro.FlySpeed * 50)
        else
            BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function StopFlying()
    Settings.Macro.Flying = false
    
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    if BodyVelocity then
        BodyVelocity:Destroy()
        BodyVelocity = nil
    end
end

-- JUMP BOOST SYSTEM (ИСПРАВЛЕННАЯ)
local JumpConnection = nil

local function ApplyJumpBoost()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.JumpPower = Settings.Macro.JumpPower
            end)
        end
    end
end

local function ActivateJumpBoost()
    if not Settings.Macro.JumpEnabled then return end
    
    -- Сохраняем оригинальную силу прыжка
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Settings.Macro.OriginalJump = humanoid.JumpPower
        end
    end
    
    -- Применяем силу прыжка
    ApplyJumpBoost()
    
    -- Создаем постоянное обновление
    if JumpConnection then
        JumpConnection:Disconnect()
    end
    
    JumpConnection = RunService.Heartbeat:Connect(function()
        ApplyJumpBoost()
    end)
end

local function RemoveJumpBoost()
    Settings.Macro.JumpEnabled = false
    
    if JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
    
    -- Возвращаем оригинальную силу прыжка
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.JumpPower = Settings.Macro.OriginalJump
            end)
        end
    end
end

-- ESP SYSTEM (ПЕРЕРАБОТАННАЯ - ТОЧЬ В ТОЧЬ КАК НА ФОТО)
function CreateESP(targetPlayer)
    if not targetPlayer.Character then return end
    
    local esp = {}
    
    -- Hitbox
    esp.Hitbox = Instance.new("BoxHandleAdornment")
    esp.Hitbox.Name = "HitboxESP"
    esp.Hitbox.Adornee = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    esp.Hitbox.AlwaysOnTop = true
    esp.Hitbox.ZIndex = 10
    esp.Hitbox.Size = Vector3.new(4, 6, 4)
    esp.Hitbox.Transparency = 0.7
    esp.Hitbox.Color3 = Settings.ESP.Color
    esp.Hitbox.Visible = Settings.ESP.Hitbox
    if targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        esp.Hitbox.Parent = targetPlayer.Character.HumanoidRootPart
    end
    
    -- Username (ТОЧЬ В ТОЧЬ КАК НА ФОТО)
    esp.Username = Instance.new("BillboardGui")
    esp.Username.Name = "UsernameESP"
    esp.Username.Size = UDim2.new(0, 200, 0, 30)
    esp.Username.StudsOffset = Vector3.new(0, 2.5, 0) -- Снизу игрока
    esp.Username.AlwaysOnTop = true
    esp.Username.Enabled = Settings.ESP.Username
    
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Parent = esp.Username
    UsernameLabel.Size = UDim2.new(1, 0, 1, 0)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = targetPlayer.Name
    UsernameLabel.TextColor3 = Settings.ESP.Color
    UsernameLabel.TextSize = 14
    UsernameLabel.Font = Enum.Font.SourceSansBold -- Шрифт как на фото
    UsernameLabel.TextStrokeTransparency = 0.5
    UsernameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    if targetPlayer.Character:FindFirstChild("Head") then
        esp.Username.Adornee = targetPlayer.Character.Head
        esp.Username.Parent = targetPlayer.Character.Head
    end
    
    -- Healthbar (ТОЧЬ В ТОЧЬ КАК НА ФОТО)
    esp.Healthbar = Instance.new("BillboardGui")
    esp.Healthbar.Name = "HealthbarESP"
    esp.Healthbar.Size = UDim2.new(0, 60, 0, 6) -- Широкая полоска как на фото
    esp.Healthbar.StudsOffset = Vector3.new(0, 3.2, 0) -- Позиция над юзернеймом
    esp.Healthbar.AlwaysOnTop = true
    esp.Healthbar.Enabled = Settings.ESP.Healthbar
    
    local HealthbarBackground = Instance.new("Frame")
    HealthbarBackground.Parent = esp.Healthbar
    HealthbarBackground.Size = UDim2.new(1, 0, 1, 0)
    HealthbarBackground.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    HealthbarBackground.BorderSizePixel = 1
    HealthbarBackground.BorderColor3 = Color3.new(1, 1, 1)
    HealthbarBackground.BackgroundTransparency = 0.3
    
    local HealthbarFill = Instance.new("Frame")
    HealthbarFill.Parent = HealthbarBackground
    HealthbarFill.Size = UDim2.new(1, 0, 1, 0) -- Полная ширина
    HealthbarFill.BackgroundColor3 = Color3.new(0, 1, 0)
    HealthbarFill.BorderSizePixel = 0
    HealthbarFill.AnchorPoint = Vector2.new(0, 0)
    HealthbarFill.Position = UDim2.new(0, 0, 0, 0)
    
    esp.HealthbarFill = HealthbarFill
    
    if targetPlayer.Character:FindFirstChild("Head") then
        esp.Healthbar.Adornee = targetPlayer.Character.Head
        esp.Healthbar.Parent = targetPlayer.Character.Head
    end
    
    -- Glow
    esp.Glow = Instance.new("Highlight")
    esp.Glow.Name = "GlowESP"
    esp.Glow.FillColor = Settings.ESP.Color
    esp.Glow.OutlineColor = Settings.ESP.Color
    esp.Glow.FillTransparency = 0.5
    esp.Glow.OutlineTransparency = 0
    esp.Glow.Enabled = Settings.ESP.Glow
    esp.Glow.Parent = targetPlayer.Character
    
    ESPObjects[targetPlayer] = esp
    
    -- Update healthbar
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.HealthChanged:Connect(function()
            UpdateHealthbar(targetPlayer)
        end)
        UpdateHealthbar(targetPlayer)
    end
end

function UpdateHealthbar(player)
    local esp = ESPObjects[player]
    if not esp or not esp.HealthbarFill or not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local health = humanoid.Health
    local maxHealth = humanoid.MaxHealth
    local healthPercent = health / maxHealth
    
    -- Обновляем ширину полоски здоровья (не высоту)
    esp.HealthbarFill.Size = UDim2.new(healthPercent, 0, 1, 0)
    
    -- Изменяем цвет в зависимости от здоровья (как на фото)
    if healthPercent > 0.7 then
        esp.HealthbarFill.BackgroundColor3 = Color3.new(0, 1, 0) -- Зеленый
    elseif healthPercent > 0.3 then
        esp.HealthbarFill.BackgroundColor3 = Color3.new(1, 1, 0) -- Желтый
    else
        esp.HealthbarFill.BackgroundColor3 = Color3.new(1, 0, 0) -- Красный
    end
end

function UpdateAllESP()
    for player, esp in pairs(ESPObjects) do
        if esp.Hitbox then
            esp.Hitbox.Visible = Settings.ESP.Hitbox
            esp.Hitbox.Color3 = Settings.ESP.Color
        end
        if esp.Username then
            esp.Username.Enabled = Settings.ESP.Username
            if esp.Username:FindFirstChildWhichIsA("TextLabel") then
                esp.Username:FindFirstChildWhichIsA("TextLabel").TextColor3 = Settings.ESP.Color
            end
        end
        if esp.Healthbar then
            esp.Healthbar.Enabled = Settings.ESP.Healthbar
        end
        if esp.Glow then
            esp.Glow.Enabled = Settings.ESP.Glow
            esp.Glow.FillColor = Settings.ESP.Color
            esp.Glow.OutlineColor = Settings.ESP.Color
        end
    end
end

function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        ESPObjects[player] = nil
    end
end

function ClearAllESP()
    for player, esp in pairs(ESPObjects) do
        RemoveESP(player)
    end
end

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    -- Speed Boost Toggle
    if input.KeyCode == Settings.Macro.SpeedKey then
        Settings.Macro.SpeedEnabled = not Settings.Macro.SpeedEnabled
        if Settings.Macro.SpeedEnabled then
            ActivateSpeedBoost()
            Notify("Speed Boost: ON")
        else
            DeactivateSpeedBoost()
            Notify("Speed Boost: OFF")
        end
    end
    
    -- Fly Toggle
    if input.KeyCode == Settings.Macro.FlyKey and Settings.Macro.FlyEnabled then
        if Settings.Macro.Flying then
            StopFlying()
            Notify("Fly: OFF")
        else
            StartFlying()
            Notify("Fly: ON")
        end
    end
    
    -- Camera Lock Toggle
    if input.KeyCode == Settings.Rage.CameraLockKey then
        if Settings.Rage.AimlockState == true and Settings.Rage.CameraLock then
            Locked = not Locked
            if Locked then
                Victim = getClosest()
                if Victim then
                    Notify("Locked onto: "..tostring(Victim.Character.Humanoid.DisplayName))
                else
                    Locked = false
                    Notify("No target found!")
                end
            else
                if Victim ~= nil then
                    Victim = nil
                    Notify("Unlocked!")
                end
            end
        else
            Notify("Camera Lock is not enabled!")
        end
    end
    
    -- Disable Aimlock
    if input.KeyCode == Settings.Rage.DisableKey then
        Settings.Rage.AimlockState = not Settings.Rage.AimlockState
        if Settings.Rage.AimlockState then
            Notify("Aimlock: ENABLED")
        else
            Notify("Aimlock: DISABLED")
            Locked = false
            Victim = nil
        end
    end
    
    -- Toggle UI with DEL key
    if input.KeyCode == Enum.KeyCode.Delete then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Camera Lock System (СТАБИЛЬНАЯ ВЕРСИЯ)
RunService.RenderStepped:Connect(function()
    update()
    
    if Settings.Rage.AimlockState == true and Settings.Rage.CameraLock then
        if Locked then
            -- Проверяем цель каждые 0.1 секунды для стабильности
            if tick() - LastTargetCheck > 0.1 then
                LastTargetCheck = tick()
                
                -- Если цель не существует или умерла, ищем новую
                if not Victim or not Victim.Character or not Victim.Character:FindFirstChild(Settings.Rage.AimPart) or Victim.Character.Humanoid.Health <= 0 then
                    Victim = getClosest()
                    if not Victim then
                        Locked = false
                        return
                    end
                end
            end
            
            -- Если цель существует, следим за ней
            if Victim and Victim.Character and Victim.Character:FindFirstChild(Settings.Rage.AimPart) then
                local targetPart = Victim.Character:FindFirstChild(Settings.Rage.AimPart)
                local humanoid = Victim.Character:FindFirstChildOfClass("Humanoid")
                
                if targetPart and humanoid and humanoid.Health > 0 then
                    Camera.CFrame = CFrame.new(Camera.CFrame.p, targetPart.Position + targetPart.Velocity * Settings.Rage.Prediction)
                else
                    Locked = false
                    Victim = nil
                end
            else
                Locked = false
                Victim = nil
            end
        end
    end
end)

-- Player connection handling
Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= player then
        if newPlayer.Character then
            CreateESP(newPlayer)
        end
        newPlayer.CharacterAdded:Connect(function(character)
            wait(1)
            CreateESP(newPlayer)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(leftPlayer)
    RemoveESP(leftPlayer)
end)

-- Initialize ESP for all existing players
for _, existingPlayer in pairs(Players:GetPlayers()) do
    if existingPlayer ~= player then
        if existingPlayer.Character then
            CreateESP(existingPlayer)
        end
        existingPlayer.CharacterAdded:Connect(function(character)
            wait(1)
            CreateESP(existingPlayer)
        end)
    end
end

-- Auto-apply features when character respawns
player.CharacterAdded:Connect(function(character)
    wait(1)
    
    if Settings.Macro.SpeedEnabled then
        ApplySpeedBoost()
    end
    
    if Settings.Macro.JumpEnabled then
        ApplyJumpBoost()
    end
    
    if Settings.Macro.Flying then
        StopFlying()
        StartFlying()
    end
end)

-- Make draggable
local dragging = false
local dragInput, dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Создаем контент для всех вкладок
local function createESPTab()
    local espFrame = tabFrames["ESP"]
    
    -- ESP Toggles
    local hitboxToggle = createToggle(espFrame, "Hitbox ESP", Settings.ESP.Hitbox, function(value)
        Settings.ESP.Hitbox = value
        UpdateAllESP()
    end)
    
    local usernameToggle = createToggle(espFrame, "Username ESP", Settings.ESP.Username, function(value)
        Settings.ESP.Username = value
        UpdateAllESP()
    end)
    
    local healthbarToggle = createToggle(espFrame, "Healthbar ESP", Settings.ESP.Healthbar, function(value)
        Settings.ESP.Healthbar = value
        UpdateAllESP()
    end)
    
    local glowToggle = createToggle(espFrame, "Glow ESP", Settings.ESP.Glow, function(value)
        Settings.ESP.Glow = value
        UpdateAllESP()
    end)
    
    -- ESP Color Picker
    createColorPicker(espFrame, "ESP Color", Settings.ESP.Color, function(color)
        Settings.ESP.Color = color
        UpdateAllESP()
    end)
    
    -- Refresh ESP Button
    createButton(espFrame, "Refresh ESP", function()
        ClearAllESP()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character then
                CreateESP(player)
            end
        end
        Notify("ESP Refreshed!")
    end)
end

local function createRageTab()
    local rageFrame = tabFrames["RAGE"]
    
    -- Camera Lock Section
    createToggle(rageFrame, "Camera Lock", Settings.Rage.CameraLock, function(value)
        Settings.Rage.CameraLock = value
        if not value then
            Locked = false
            Victim = nil
            Notify("Camera Lock: OFF")
        else
            Notify("Camera Lock: ON - Press "..Settings.Rage.CameraLockKey.Name.." to lock")
        end
    end)
    
    -- Camera Lock Keybind
    createKeybind(rageFrame, "Camera Lock Key", Settings.Rage.CameraLockKey, function(key)
        Settings.Rage.CameraLockKey = key
        Notify("Camera Lock key set to: "..key.Name)
    end)
    
    -- Disable Keybind
    createKeybind(rageFrame, "Disable Key", Settings.Rage.DisableKey, function(key)
        Settings.Rage.DisableKey = key
        Notify("Disable key set to: "..key.Name)
    end)
    
    -- FOV Settings
    createSlider(rageFrame, "FOV Value", Settings.Rage.FOV, 10, 200, function(value)
        Settings.Rage.FOV = value
    end)
    
    createToggle(rageFrame, "Show FOV Circle", Settings.Rage.ShowCircle, function(value)
        Settings.Rage.ShowCircle = value
    end)
    
    -- Prediction Slider
    createSlider(rageFrame, "Prediction", Settings.Rage.Prediction, 0.1, 2.0, function(value)
        Settings.Rage.Prediction = value
    end)
end

local function createMacroTab()
    local macroFrame = tabFrames["MACRO"]
    
    -- Speed Boost Section
    createToggle(macroFrame, "Speed Boost", Settings.Macro.SpeedEnabled, function(value)
        Settings.Macro.SpeedEnabled = value
        if value then
            ActivateSpeedBoost()
            Notify("Speed Boost: ON")
        else
            DeactivateSpeedBoost()
            Notify("Speed Boost: OFF")
        end
    end)
    
    createSlider(macroFrame, "Speed Value", Settings.Macro.Speed, 16, 150, function(value)
        Settings.Macro.Speed = value
        if Settings.Macro.SpeedEnabled then
            ApplySpeedBoost()
        end
    end)
    
    createKeybind(macroFrame, "Speed Toggle Key", Settings.Macro.SpeedKey, function(key)
        Settings.Macro.SpeedKey = key
        Notify("Speed key set to: "..key.Name)
    end)
    
    -- Fly Section
    createToggle(macroFrame, "Fly", Settings.Macro.FlyEnabled, function(value)
        Settings.Macro.FlyEnabled = value
        if not value and Settings.Macro.Flying then
            StopFlying()
            Notify("Fly: OFF")
        else
            Notify("Fly: ON - Press "..(Settings.Macro.FlyKey and Settings.Macro.FlyKey.Name or "bind key").." to toggle")
        end
    end)
    
    createSlider(macroFrame, "Fly Speed", Settings.Macro.FlySpeed, 1, 10, function(value)
        Settings.Macro.FlySpeed = value
    end)
    
    createKeybind(macroFrame, "Fly Toggle Key", Settings.Macro.FlyKey, function(key)
        Settings.Macro.FlyKey = key
        Notify("Fly key set to: "..key.Name)
    end)
    
    -- Jump Boost Section (ИСПРАВЛЕННАЯ)
    createToggle(macroFrame, "Jump Boost", Settings.Macro.JumpEnabled, function(value)
        Settings.Macro.JumpEnabled = value
        if value then
            ActivateJumpBoost()
            Notify("Jump Boost: ON")
        else
            RemoveJumpBoost()
            Notify("Jump Boost: OFF")
        end
    end)
    
    createSlider(macroFrame, "Jump Power", Settings.Macro.JumpPower, 50, 200, function(value)
        Settings.Macro.JumpPower = value
        if Settings.Macro.JumpEnabled then
            ApplyJumpBoost()
        end
    end)
end

local function createMiscTab()
    local miscFrame = tabFrames["MISC"]
    
    -- UI Customization
    createColorPicker(miscFrame, "UI Color", Settings.UI.Color, function(color)
        Settings.UI.Color = color
        UpdateUIColors()
        Notify("UI Color Updated!")
    end)
    
    -- Reset Settings
    createButton(miscFrame, "Reset All Settings", function()
        Settings = {
            ESP = {
                Hitbox = false,
                Username = false,
                Healthbar = false,
                Glow = false,
                Color = Color3.fromRGB(0, 100, 255)
            },
            Rage = {
                SilentAim = false,
                FOV = 55,
                ShowCircle = false,
                CameraLock = false,
                CameraLockKey = Enum.KeyCode.Z,
                DisableKey = Enum.KeyCode.P,
                AimPart = "HumanoidRootPart",
                Prediction = 0.15038,
                AimlockState = true
            },
            Macro = {
                SpeedEnabled = false,
                Speed = 50,
                OriginalSpeed = 16,
                SpeedKey = nil,
                
                FlyEnabled = false,
                FlySpeed = 3,
                FlyKey = nil,
                Flying = false,
                
                JumpEnabled = false,
                JumpPower = 50,
                OriginalJump = 50
            },
            UI = {
                Color = Color3.fromRGB(0, 100, 255)
            }
        }
        UpdateUIColors()
        UpdateAllESP()
        DeactivateSpeedBoost()
        RemoveJumpBoost()
        StopFlying()
        Locked = false
        Victim = nil
        Notify("All settings reset!")
    end)
    
    -- Hide UI
    createButton(miscFrame, "Hide UI", function()
        MainFrame.Visible = false
        Notify("UI Hidden - Press DEL to show")
    end)
    
    -- Show UI
    createButton(miscFrame, "Show UI", function()
        MainFrame.Visible = true
        Notify("UI Shown")
    end)
    
    -- Unload Script
    createButton(miscFrame, "Unload Script", function()
        _G.CondaCC = false
        ScreenGui:Destroy()
        if SpeedConnection then
            SpeedConnection:Disconnect()
        end
        if FlyConnection then
            FlyConnection:Disconnect()
        end
        if JumpConnection then
            JumpConnection:Disconnect()
        end
        if BodyVelocity then
            BodyVelocity:Destroy()
        end
        ClearAllESP()
        if fov then
            fov:Remove()
        end
        Notify("CONDA.CC Unloaded!")
    end)
end

local function createReadmeTab()
    local readmeFrame = tabFrames["README"]
    
    local ReadmeText = [[
CONDA.CC - Universal Script

ESP FEATURES:
• Hitbox - Shows damage hitbox rectangle
• Username - Shows player username above head  
• Healthbar - Shows health bar with color changing
• Glow - Adds glow effect to players

RAGE FEATURES:
• Camera Lock - Advanced camera lock with prediction
• FOV Circle - Visual aiming circle
• Customizable keybinds

MACRO FEATURES:
• Speed Boost - Adjustable speed (16-150) with keybind
• Fly - Flight system with speed control
• Jump Boost - Enhanced jumping (50-200)

CONTROLS:
• DEL - Toggle UI visibility
• Custom keybinds for Camera Lock, Speed, Fly
• Disable key to turn off aimlock

USAGE:
1. Enable features in respective tabs
2. Set keybinds in RAGE and MACRO tabs
3. Adjust sliders for customization
4. Use keybinds for quick toggling

NOTES:
• Works in ALL Roblox games
• ESP applies to ALL players instantly
• All changes take effect immediately
• Camera Lock now stable and reliable

Created for legit gameplay
Not for HvH!

Contacts:
Discord: jwke
Roblox: dgdhdhdqoqpwjd

CONDA.CC - Universal Script
]]
    
    local ReadmeLabel = Instance.new("TextLabel")
    ReadmeLabel.Size = UDim2.new(1, -20, 0, 600)
    ReadmeLabel.BackgroundTransparency = 1
    ReadmeLabel.Text = ReadmeText
    ReadmeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReadmeLabel.TextSize = 12
    ReadmeLabel.Font = Enum.Font.Gotham
    ReadmeLabel.TextXAlignment = Enum.TextXAlignment.Left
    ReadmeLabel.TextYAlignment = Enum.TextYAlignment.Top
    ReadmeLabel.TextWrapped = true
    ReadmeLabel.Parent = readmeFrame
end

-- Создаем контент для всех вкладок
createESPTab()
createRageTab()
createMacroTab()
createMiscTab()
createReadmeTab()

-- Initialization
-- Активируем первую вкладку
currentTab = "ESP"
tabFrames["ESP"].Visible = true
tabButtons["ESP"].BackgroundColor3 = Settings.UI.Color
tabButtons["ESP"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- Apply initial settings
if Settings.Macro.SpeedEnabled then
    ActivateSpeedBoost()
end

if Settings.Macro.JumpEnabled then
    ActivateJumpBoost()
end

-- Load notification
local function ShowNotification()
    local NotifGui = Instance.new("ScreenGui")
    local NotifFrame = Instance.new("Frame")
    local NotifLabel = Instance.new("TextLabel")
    local NotifCorner = Instance.new("UICorner")
    
    NotifGui.Parent = CoreGui
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    NotifFrame.Parent = NotifGui
    NotifFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    NotifFrame.Size = UDim2.new(0, 300, 0, 60)
    NotifFrame.Position = UDim2.new(1, 0, 1, 0)
    NotifFrame.AnchorPoint = Vector2.new(1, 1)
    
    NotifCorner.Parent = NotifFrame
    NotifCorner.CornerRadius = UDim.new(0, 8)
    
    NotifLabel.Parent = NotifFrame
    NotifLabel.Size = UDim2.new(1, 0, 1, 0)
    NotifLabel.BackgroundTransparency = 1
    NotifLabel.Text = "CONDA.CC loaded successfully!\nSet keybinds in RAGE/MACRO tabs"
    NotifLabel.TextColor3 = Settings.UI.Color
    NotifLabel.Font = Enum.Font.GothamBold
    NotifLabel.TextScaled = true
    
    -- Animate notification
    NotifFrame:TweenPosition(UDim2.new(1, -20, 1, -20), "Out", "Quad", 0.5, true)
    
    wait(3)
    
    NotifFrame:TweenPosition(UDim2.new(1, 0, 1, 0), "In", "Quad", 0.5, true)
    wait(0.5)
    NotifGui:Destroy()
end

ShowNotification()

warn("CONDA.CC loaded successfully! Set keybinds in RAGE/MACRO tabs")

-- Auto-update ESP for new players
spawn(function()
    while wait(1) do
        for _, existingPlayer in pairs(Players:GetPlayers()) do
            if existingPlayer ~= player and not ESPObjects[existingPlayer] then
                if existingPlayer.Character then
                    CreateESP(existingPlayer)
                end
            end
        end
    end
end)

