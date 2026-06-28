-- CONDA.CC - Universal Script for Solara (SKEET STYLE - ORIGINAL STRUCTURE)
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
        Color = Color3.fromRGB(0, 150, 255)
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
        AimlockState = true,
        
        HitboxExpander = {
            Enabled = false,
            HeadSize = 50,
            Visible = true,
            Color = Color3.fromRGB(255, 0, 0),
            Transparency = 0.7
        }
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
        Color = Color3.fromRGB(0, 150, 255)
    }
}

-- ESP Storage
local ESPObjects = {}

-- SPOILEDROTTEN CAMERA LOCK SYSTEM
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
fov.Color = Color3.fromRGB(0, 150, 255)
fov.NumSides = 1000

function UpdateHitboxes()
    if Settings.Rage.HitboxExpander.Enabled then
        for i, v in next, Players:GetPlayers() do
            if v.Name ~= player.Name and v.Character then
                pcall(function()
                    local root = v.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Size = Vector3.new(Settings.Rage.HitboxExpander.HeadSize, Settings.Rage.HitboxExpander.HeadSize, Settings.Rage.HitboxExpander.HeadSize)
                        root.Transparency = Settings.Rage.HitboxExpander.Visible and Settings.Rage.HitboxExpander.Transparency or 1
                        root.BrickColor = BrickColor.new(Settings.Rage.HitboxExpander.Color)
                        root.Material = "Neon"
                        root.CanCollide = false
                    end
                end)
            end
        end
    else
        for i, v in next, Players:GetPlayers() do
            if v.Name ~= player.Name and v.Character then
                pcall(function()
                    local root = v.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Size = Vector3.new(2, 2, 1)
                        root.Transparency = 0
                        root.BrickColor = BrickColor.new("Medium stone grey")
                        root.Material = "Plastic"
                        root.CanCollide = true
                    end
                end)
            end
        end
    end
end

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

-- ============================================
-- GUI - ORIGINAL STRUCTURE, SKEET COLORS
-- ============================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CondaCCUI"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main frame (SKEET STYLE - dark)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)  -- Тёмный
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)      -- Тонкая рамка
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 500, 0, 400)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 4)  -- Скругление
UICorner.Parent = MainFrame

-- Header (SKEET STYLE)
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)  -- Тёмный
Header.BorderSizePixel = 0
Header.Position = UDim2.new(0, 0, 0, 0)
Header.Size = UDim2.new(1, 0, 0, 35)

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 4)
HeaderCorner.Parent = Header

-- Title (SKEET STYLE - акцентный цвет)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = Header
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "CONDA.CC"
Title.TextColor3 = Settings.UI.Color
Title.TextSize = 20
Title.TextStrokeTransparency = 0.7
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Tabs container (ORIGINAL - слева, но цвета скеет)
local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Parent = MainFrame
TabsContainer.BackgroundTransparency = 1
TabsContainer.Position = UDim2.new(0, 0, 0, 35)
TabsContainer.Size = UDim2.new(0, 100, 0, 365)

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 4)
TabListLayout.Parent = TabsContainer

-- Content container (ORIGINAL)
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ContentContainer.BorderSizePixel = 0
ContentContainer.Position = UDim2.new(0, 100, 0, 35)
ContentContainer.Size = UDim2.new(0, 400, 0, 365)

local ContentScrolling = Instance.new("ScrollingFrame")
ContentScrolling.Size = UDim2.new(1, 0, 1, 0)
ContentScrolling.BackgroundTransparency = 1
ContentScrolling.BorderSizePixel = 0
ContentScrolling.ScrollBarThickness = 3
ContentScrolling.ScrollBarImageColor3 = Settings.UI.Color
ContentScrolling.Parent = ContentContainer

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 8)
ContentLayout.Parent = ContentScrolling

-- Tabs
local tabs = {"ESP", "RAGE", "MACRO", "MISC", "README"}
local tabButtons = {}
local tabFrames = {}
local currentTab = "ESP"

-- Create tab buttons (SKEET STYLE)
local function createTabButton(tabName)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(1, -10, 0, 30)
    TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)  -- Тёмный
    TabButton.BorderSizePixel = 0
    TabButton.Text = tabName
    TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)     -- Серый
    TabButton.TextSize = 12
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Parent = TabsContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = TabButton
    
    -- Tab content frame
    local TabContentFrame = Instance.new("Frame")
    TabContentFrame.Size = UDim2.new(1, 0, 1, 0)
    TabContentFrame.BackgroundTransparency = 1
    TabContentFrame.Visible = false
    TabContentFrame.Parent = ContentScrolling
    
    local TabContentLayout = Instance.new("UIListLayout")
    TabContentLayout.Padding = UDim.new(0, 6)
    TabContentLayout.Parent = TabContentFrame
    
    tabFrames[tabName] = TabContentFrame
    
    TabButton.MouseButton1Click:Connect(function()
        currentTab = tabName
        for name, frame in pairs(tabFrames) do
            frame.Visible = (name == tabName)
        end
        for name, button in pairs(tabButtons) do
            if name == tabName then
                button.BackgroundColor3 = Settings.UI.Color
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                button.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
    end)
    
    tabButtons[tabName] = TabButton
    return TabContentFrame
end

for _, tabName in pairs(tabs) do
    createTabButton(tabName)
end

-- ============================================
-- UI ELEMENTS (SKEET STYLE)
-- ============================================

function createSlider(parent, name, defaultValue, minValue, maxValue, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -20, 0, 55)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, -60, 0, 18)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name
    SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SliderLabel.TextSize = 13
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 18)
    ValueLabel.Position = UDim2.new(1, -50, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(defaultValue)
    ValueLabel.TextColor3 = Settings.UI.Color
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Size = UDim2.new(1, 0, 0, 4)
    SliderBackground.Position = UDim2.new(0, 0, 0, 24)
    SliderBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SliderBackground.BorderSizePixel = 0
    SliderBackground.Parent = SliderFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 2)
    SliderCorner.Parent = SliderBackground
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    SliderFill.BackgroundColor3 = Settings.UI.Color
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBackground
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 2)
    FillCorner.Parent = SliderFill
    
    local SliderHandle = Instance.new("Frame")
    SliderHandle.Size = UDim2.new(0, 12, 0, 12)
    SliderHandle.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -6, 0, -4)
    SliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderHandle.BorderSizePixel = 0
    SliderHandle.Parent = SliderBackground
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(0, 6)
    HandleCorner.Parent = SliderHandle
    
    local isDragging = false
    
    local function updateSlider(value)
        value = math.clamp(value, minValue, maxValue)
        local fillWidth = (value - minValue) / (maxValue - minValue)
        SliderFill.Size = UDim2.new(fillWidth, 0, 1, 0)
        SliderHandle.Position = UDim2.new(fillWidth, -6, 0, -4)
        ValueLabel.Text = tostring(math.floor(value))
        if callback then callback(value) end
    end
    
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

function createButton(parent, name, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -20, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Button.BorderSizePixel = 1
    Button.BorderColor3 = Color3.fromRGB(50, 50, 50)
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 4)
    ButtonCorner.Parent = Button
    
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Settings.UI.Color
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
    
    Button.MouseButton1Click:Connect(callback)
    return Button
end

function createToggle(parent, name, defaultValue, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -20, 0, 28)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -40, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 30, 0, 26)
    ToggleButton.Position = UDim2.new(1, -30, 0, 1)
    ToggleButton.BackgroundColor3 = defaultValue and Settings.UI.Color or Color3.fromRGB(40, 40, 40)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 4)
    ToggleCorner.Parent = ToggleButton
    
    ToggleButton.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        ToggleButton.BackgroundColor3 = defaultValue and Settings.UI.Color or Color3.fromRGB(40, 40, 40)
        if callback then callback(defaultValue) end
    end)
    
    return {frame = ToggleFrame, button = ToggleButton, value = defaultValue}
end

function createKeybind(parent, name, currentKey, callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Size = UDim2.new(1, -20, 0, 28)
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.Parent = parent
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(0, 120, 1, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = name
    KeybindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    KeybindLabel.TextSize = 13
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = KeybindFrame
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0, 100, 1, 0)
    KeybindButton.Position = UDim2.new(0, 130, 0, 0)
    KeybindButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeybindButton.BorderSizePixel = 1
    KeybindButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
    KeybindButton.Text = currentKey and currentKey.Name or "None"
    KeybindButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    KeybindButton.TextSize = 11
    KeybindButton.Font = Enum.Font.GothamBold
    KeybindButton.Parent = KeybindFrame
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 4)
    KeybindCorner.Parent = KeybindButton
    
    local binding = false
    
    KeybindButton.MouseButton1Click:Connect(function()
        if not binding then
            binding = true
            KeybindButton.Text = "..."
            KeybindButton.TextColor3 = Settings.UI.Color
            
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    KeybindButton.Text = input.KeyCode.Name
                    KeybindButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    binding = false
                    if callback then callback(input.KeyCode) end
                    connection:Disconnect()
                end
            end)
        end
    end)
    
    return KeybindButton
end

function createColorPicker(parent, name, currentColor, callback)
    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, -20, 0, 75)
    ColorFrame.BackgroundTransparency = 1
    ColorFrame.Parent = parent
    
    local ColorLabel = Instance.new("TextLabel")
    ColorLabel.Size = UDim2.new(1, 0, 0, 18)
    ColorLabel.BackgroundTransparency = 1
    ColorLabel.Text = name
    ColorLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ColorLabel.TextSize = 13
    ColorLabel.Font = Enum.Font.Gotham
    ColorLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorLabel.Parent = ColorFrame
    
    local presetColors = {
        {Name = "Blue", Color = Color3.fromRGB(0, 150, 255)},
        {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
        {Name = "Yellow", Color = Color3.fromRGB(255, 255, 0)},
        {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
        {Name = "White", Color = Color3.fromRGB(255, 255, 255)},
        {Name = "Purple", Color = Color3.fromRGB(128, 0, 128)},
        {Name = "Pink", Color = Color3.fromRGB(255, 105, 180)},
        {Name = "Orange", Color = Color3.fromRGB(255, 165, 0)}
    }
    
    for i, colorData in ipairs(presetColors) do
        local row = math.floor((i-1)/4)
        local col = (i-1) % 4
        
        local ColorButton = Instance.new("TextButton")
        ColorButton.Size = UDim2.new(0, 38, 0, 18)
        ColorButton.Position = UDim2.new(0, col * 42, 0, 22 + row * 24)
        ColorButton.BackgroundColor3 = colorData.Color
        ColorButton.BorderSizePixel = 1
        ColorButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
        ColorButton.Text = ""
        ColorButton.Parent = ColorFrame
        
        local ColorCorner = Instance.new("UICorner")
        ColorCorner.CornerRadius = UDim.new(0, 3)
        ColorCorner.Parent = ColorButton
        
        ColorButton.MouseButton1Click:Connect(function()
            if callback then callback(colorData.Color) end
        end)
    end
end

function UpdateUIColors()
    Title.TextColor3 = Settings.UI.Color
    ContentScrolling.ScrollBarImageColor3 = Settings.UI.Color
    
    for name, button in pairs(tabButtons) do
        if name == currentTab then
            button.BackgroundColor3 = Settings.UI.Color
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            button.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

-- ============================================
-- SPEED SYSTEM
-- ============================================

local SpeedConnection = nil

function ApplySpeedBoost()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.WalkSpeed = Settings.Macro.Speed
            end)
        end
    end
end

function ActivateSpeedBoost()
    if not Settings.Macro.SpeedEnabled then return end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Settings.Macro.OriginalSpeed = humanoid.WalkSpeed
        end
    end
    
    ApplySpeedBoost()
    
    if SpeedConnection then
        SpeedConnection:Disconnect()
    end
    
    SpeedConnection = RunService.Heartbeat:Connect(function()
        ApplySpeedBoost()
    end)
end

function DeactivateSpeedBoost()
    Settings.Macro.SpeedEnabled = false
    
    if SpeedConnection then
        SpeedConnection:Disconnect()
        SpeedConnection = nil
    end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.WalkSpeed = Settings.Macro.OriginalSpeed
            end)
        end
    end
end

-- ============================================
-- FLY SYSTEM
-- ============================================

local FlyConnection = nil
local BodyVelocity = nil

function StartFlying()
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    local root = player.Character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not root then return end
    
    Settings.Macro.Flying = true
    
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

function StopFlying()
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

-- ============================================
-- JUMP BOOST SYSTEM
-- ============================================

local JumpConnection = nil

function ApplyJumpBoost()
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.JumpPower = Settings.Macro.JumpPower
            end)
        end
    end
end

function ActivateJumpBoost()
    if not Settings.Macro.JumpEnabled then return end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            Settings.Macro.OriginalJump = humanoid.JumpPower
        end
    end
    
    ApplyJumpBoost()
    
    if JumpConnection then
        JumpConnection:Disconnect()
    end
    
    JumpConnection = RunService.Heartbeat:Connect(function()
        ApplyJumpBoost()
    end)
end

function RemoveJumpBoost()
    Settings.Macro.JumpEnabled = false
    
    if JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
    
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid.JumpPower = Settings.Macro.OriginalJump
            end)
        end
    end
end

-- ============================================
-- ESP SYSTEM
-- ============================================

function CreateESP(targetPlayer)
    if not targetPlayer.Character then return end
    
    local esp = {}
    
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
    
    esp.Username = Instance.new("BillboardGui")
    esp.Username.Name = "UsernameESP"
    esp.Username.Size = UDim2.new(0, 200, 0, 30)
    esp.Username.StudsOffset = Vector3.new(0, 2.5, 0)
    esp.Username.AlwaysOnTop = true
    esp.Username.Enabled = Settings.ESP.Username
    
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Parent = esp.Username
    UsernameLabel.Size = UDim2.new(1, 0, 1, 0)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Text = targetPlayer.Name
    UsernameLabel.TextColor3 = Settings.ESP.Color
    UsernameLabel.TextSize = 14
    UsernameLabel.Font = Enum.Font.GothamBold
    UsernameLabel.TextStrokeTransparency = 0.5
    UsernameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    if targetPlayer.Character:FindFirstChild("Head") then
        esp.Username.Adornee = targetPlayer.Character.Head
        esp.Username.Parent = targetPlayer.Character.Head
    end
    
    esp.Healthbar = Instance.new("BillboardGui")
    esp.Healthbar.Name = "HealthbarESP"
    esp.Healthbar.Size = UDim2.new(0, 4, 0, 100)
    esp.Healthbar.StudsOffset = Vector3.new(-2.5, 0, 0)
    esp.Healthbar.AlwaysOnTop = true
    esp.Healthbar.Enabled = Settings.ESP.Healthbar
    
    local HealthbarBackground = Instance.new("Frame")
    HealthbarBackground.Parent = esp.Healthbar
    HealthbarBackground.Size = UDim2.new(1, 0, 1, 0)
    HealthbarBackground.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    HealthbarBackground.BorderSizePixel = 1
    HealthbarBackground.BorderColor3 = Color3.new(0.2, 0.2, 0.2)
    HealthbarBackground.BackgroundTransparency = 0.2
    
    local HealthbarFill = Instance.new("Frame")
    HealthbarFill.Parent = HealthbarBackground
    HealthbarFill.Size = UDim2.new(1, 0, 1, 0)
    HealthbarFill.BackgroundColor3 = Color3.new(0, 0.4, 0)
    HealthbarFill.BorderSizePixel = 0
    HealthbarFill.AnchorPoint = Vector2.new(0, 1)
    HealthbarFill.Position = UDim2.new(0, 0, 1, 0)
    
    esp.HealthbarFill = HealthbarFill
    
    if targetPlayer.Character:FindFirstChild("Head") then
        esp.Healthbar.Adornee = targetPlayer.Character.Head
        esp.Healthbar.Parent = targetPlayer.Character.Head
    end
    
    esp.Glow = Instance.new("Highlight")
    esp.Glow.Name = "GlowESP"
    esp.Glow.FillColor = Settings.ESP.Color
    esp.Glow.OutlineColor = Settings.ESP.Color
    esp.Glow.FillTransparency = 0.5
    esp.Glow.OutlineTransparency = 0
    esp.Glow.Enabled = Settings.ESP.Glow
    esp.Glow.Parent = targetPlayer.Character
    
    ESPObjects[targetPlayer] = esp
    
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
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    esp.HealthbarFill.Size = UDim2.new(1, 0, healthPercent, 0)
    
    if healthPercent > 0.7 then
        esp.HealthbarFill.BackgroundColor3 = Color3.new(0, 0.4, 0)
    elseif healthPercent > 0.3 then
        esp.HealthbarFill.BackgroundColor3 = Color3.new(0.4, 0.4, 0)
    else
        esp.HealthbarFill.BackgroundColor3 = Color3.new(0.4, 0, 0)
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

-- ============================================
-- INPUT HANDLING
-- ============================================

UserInputService.InputBegan:Connect(function(input)
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
    
    if input.KeyCode == Settings.Macro.FlyKey and Settings.Macro.FlyEnabled then
        if Settings.Macro.Flying then
            StopFlying()
            Notify("Fly: OFF")
        else
            StartFlying()
            Notify("Fly: ON")
        end
    end
    
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
    
    if input.KeyCode == Enum.KeyCode.Delete then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ============================================
-- RENDER LOOP
-- ============================================

RunService.RenderStepped:Connect(function()
    update()
    
    if Settings.Rage.AimlockState == true and Settings.Rage.CameraLock then
        if Locked then
            if tick() - LastTargetCheck > 0.1 then
                LastTargetCheck = tick()
                
                if not Victim or not Victim.Character or not Victim.Character:FindFirstChild(Settings.Rage.AimPart) or Victim.Character.Humanoid.Health <= 0 then
                    Victim = getClosest()
                    if not Victim then
                        Locked = false
                        return
                    end
                end
            end
            
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

RunService.RenderStepped:Connect(function()
    UpdateHitboxes()
end)

-- ============================================
-- PLAYER CONNECTIONS
-- ============================================

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

-- ============================================
-- DRAGGABLE
-- ============================================

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

-- ============================================
-- CREATE TAB CONTENTS
-- ============================================

function createESPTab()
    local espFrame = tabFrames["ESP"]
    
    createToggle(espFrame, "Hitbox ESP", Settings.ESP.Hitbox, function(value)
        Settings.ESP.Hitbox = value
        UpdateAllESP()
    end)
    
    createToggle(espFrame, "Username ESP", Settings.ESP.Username, function(value)
        Settings.ESP.Username = value
        UpdateAllESP()
    end)
    
    createToggle(espFrame, "Healthbar ESP", Settings.ESP.Healthbar, function(value)
        Settings.ESP.Healthbar = value
        UpdateAllESP()
    end)
    
    createToggle(espFrame, "Glow ESP", Settings.ESP.Glow, function(value)
        Settings.ESP.Glow = value
        UpdateAllESP()
    end)
    
    createColorPicker(espFrame, "ESP Color", Settings.ESP.Color, function(color)
        Settings.ESP.Color = color
        UpdateAllESP()
    end)
    
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

function createRageTab()
    local rageFrame = tabFrames["RAGE"]
    
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
    
    createKeybind(rageFrame, "Camera Lock Key", Settings.Rage.CameraLockKey, function(key)
        Settings.Rage.CameraLockKey = key
        Notify("Camera Lock key set to: "..key.Name)
    end)
    
    createKeybind(rageFrame, "Disable Key", Settings.Rage.DisableKey, function(key)
        Settings.Rage.DisableKey = key
        Notify("Disable key set to: "..key.Name)
    end)
    
    createSlider(rageFrame, "FOV Value", Settings.Rage.FOV, 10, 200, function(value)
        Settings.Rage.FOV = value
    end)
    
    createToggle(rageFrame, "Show FOV Circle", Settings.Rage.ShowCircle, function(value)
        Settings.Rage.ShowCircle = value
    end)
    
    createSlider(rageFrame, "Prediction", Settings.Rage.Prediction, 0.1, 2.0, function(value)
        Settings.Rage.Prediction = value
    end)
    
    -- HITBOX EXPANDER
    createToggle(rageFrame, "Hitbox Expander", Settings.Rage.HitboxExpander.Enabled, function(value)
        Settings.Rage.HitboxExpander.Enabled = value
        UpdateHitboxes()
        Notify("Hitbox Expander: " .. (value and "ON" or "OFF"))
    end)
    
    createToggle(rageFrame, "Show Hitboxes", Settings.Rage.HitboxExpander.Visible, function(value)
        Settings.Rage.HitboxExpander.Visible = value
        UpdateHitboxes()
        Notify("Hitboxes: " .. (value and "VISIBLE" or "INVISIBLE"))
    end)
    
    createSlider(rageFrame, "Hitbox Size", Settings.Rage.HitboxExpander.HeadSize, 10, 200, function(value)
        Settings.Rage.HitboxExpander.HeadSize = value
        UpdateHitboxes()
    end)
    
    createSlider(rageFrame, "Hitbox Transparency", Settings.Rage.HitboxExpander.Transparency * 100, 0, 100, function(value)
        Settings.Rage.HitboxExpander.Transparency = value / 100
        UpdateHitboxes()
    end)
    
    createColorPicker(rageFrame, "Hitbox Color", Settings.Rage.HitboxExpander.Color, function(color)
        Settings.Rage.HitboxExpander.Color = color
        UpdateHitboxes()
    end)
    
    createButton(rageFrame, "Update All Hitboxes", function()
        UpdateHitboxes()
        Notify("Hitboxes updated for all players!")
    end)
end

function createMacroTab()
    local macroFrame = tabFrames["MACRO"]
    
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

function createMiscTab()
    local miscFrame = tabFrames["MISC"]
    
    createColorPicker(miscFrame, "UI Color", Settings.UI.Color, function(color)
        Settings.UI.Color = color
        UpdateUIColors()
        Notify("UI Color Updated!")
    end)
    
    createButton(miscFrame, "Reset All Settings", function()
        Settings = {
            ESP = {
                Hitbox = false,
                Username = false,
                Healthbar = false,
                Glow = false,
                Color = Color3.fromRGB(0, 150, 255)
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
                AimlockState = true,
                HitboxExpander = {
                    Enabled = false,
                    HeadSize = 50,
                    Visible = true,
                    Color = Color3.fromRGB(255, 0, 0),
                    Transparency = 0.7
                }
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
                Color = Color3.fromRGB(0, 150, 255)
            }
        }
        UpdateUIColors()
        UpdateAllESP()
        UpdateHitboxes()
        DeactivateSpeedBoost()
        RemoveJumpBoost()
        StopFlying()
        Locked = false
        Victim = nil
        Notify("All settings reset!")
    end)
    
    createButton(miscFrame, "Hide UI", function()
        MainFrame.Visible = false
        Notify("UI Hidden - Press DEL to show")
    end)
    
    createButton(miscFrame, "Show UI", function()
        MainFrame.Visible = true
        Notify("UI Shown")
    end)
    
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

function createReadmeTab()
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
• Hitbox Expander - Expand hitboxes for easy hits
• Customizable keybinds

HITBOX EXPANDER:
• Expand hitboxes up to 200 size
• Toggle visibility on/off
• Change colors like ESP
• Adjust transparency

MACRO FEATURES:
• Speed Boost - Adjustable speed (16-150)
• Fly - Flight system with speed control
• Jump Boost - Enhanced jumping (50-200)

CONTROLS:
• DEL - Toggle UI visibility
• Custom keybinds for Camera Lock, Speed, Fly
• Disable key to turn off aimlock

Press DEL to toggle UI
]]
    
    local ReadmeLabel = Instance.new("TextLabel")
    ReadmeLabel.Size = UDim2.new(1, -20, 0, 500)
    ReadmeLabel.BackgroundTransparency = 1
    ReadmeLabel.Text = ReadmeText
    ReadmeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ReadmeLabel.TextSize = 12
    ReadmeLabel.Font = Enum.Font.Gotham
    ReadmeLabel.TextXAlignment = Enum.TextXAlignment.Left
    ReadmeLabel.TextYAlignment = Enum.TextYAlignment.Top
    ReadmeLabel.TextWrapped = true
    ReadmeLabel.Parent = readmeFrame
end

-- ============================================
-- INITIALIZATION
-- ============================================

createESPTab()
createRageTab()
createMacroTab()
createMiscTab()
createReadmeTab()

currentTab = "ESP"
tabFrames["ESP"].Visible = true
tabButtons["ESP"].BackgroundColor3 = Settings.UI.Color
tabButtons["ESP"].TextColor3 = Color3.fromRGB(255, 255, 255)

if Settings.Macro.SpeedEnabled then
    ActivateSpeedBoost()
end

if Settings.Macro.JumpEnabled then
    ActivateJumpBoost()
end

local function ShowNotification()
    local NotifGui = Instance.new("ScreenGui")
    local NotifFrame = Instance.new("Frame")
    local NotifLabel = Instance.new("TextLabel")
    local NotifCorner = Instance.new("UICorner")
    
    NotifGui.Parent = CoreGui
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    NotifFrame.Parent = NotifGui
    NotifFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    NotifFrame.Size = UDim2.new(0, 300, 0, 50)
    NotifFrame.Position = UDim2.new(1, 0, 1, 0)
    NotifFrame.AnchorPoint = Vector2.new(1, 1)
    
    NotifCorner.Parent = NotifFrame
    NotifCorner.CornerRadius = UDim.new(0, 4)
    
    NotifLabel.Parent = NotifFrame
    NotifLabel.Size = UDim2.new(1, 0, 1, 0)
    NotifLabel.BackgroundTransparency = 1
    NotifLabel.Text = "CONDA.CC loaded! Press DEL to toggle"
    NotifLabel.TextColor3 = Settings.UI.Color
    NotifLabel.Font = Enum.Font.GothamBold
    NotifLabel.TextScaled = true
    
    NotifFrame:TweenPosition(UDim2.new(1, -20, 1, -20), "Out", "Quad", 0.5, true)
    wait(3)
    NotifFrame:TweenPosition(UDim2.new(1, 0, 1, 0), "In", "Quad", 0.5, true)
    wait(0.5)
    NotifGui:Destroy()
end

ShowNotification()
warn("CONDA.CC loaded successfully! (Skeet Style)")

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
