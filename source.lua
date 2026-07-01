-- =====================================================================
-- 🌟 NEBULA UI LIBRARY v1.0
-- Modern, Smooth, Bug-Free UI Library
-- =====================================================================

local Nebula = {}
Nebula.__index = Nebula

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")

-- Settings
local Settings = {
    AnimationSpeed = 0.2,
    CornerRadius = 8,
    AccentColor = Color3.fromRGB(100, 150, 255),
    DarkColor = Color3.fromRGB(18, 18, 28),
    DarkerColor = Color3.fromRGB(12, 12, 20),
    LighterColor = Color3.fromRGB(30, 30, 42),
    TextColor = Color3.fromRGB(220, 220, 220),
    DimTextColor = Color3.fromRGB(140, 140, 150),
}

-- =====================================================================
-- UTILITY FUNCTIONS
-- =====================================================================
local function Create(className, properties)
    local obj = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        pcall(function() obj[prop] = value end)
    end
    return obj
end

local function Tween(obj, props, duration, easing, direction)
    duration = duration or Settings.AnimationSpeed
    easing = easing or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration, easing, direction), props)
    tween:Play()
    return tween
end

local function AddCorner(obj, radius)
    radius = radius or Settings.CornerRadius
    local corner = Create("UICorner", {CornerRadius = UDim.new(0, radius), Parent = obj})
    return corner
end

local function AddStroke(obj, color, thickness)
    local stroke = Create("UIStroke", {
        Color = color or Settings.AccentColor,
        Thickness = thickness or 1,
        Transparency = 0.7,
        Parent = obj
    })
    return stroke
end

-- =====================================================================
-- DRAG SYSTEM
-- =====================================================================
local function MakeDraggable(frame, dragBar)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil
    
    dragBar = dragBar or frame
    
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- =====================================================================
-- WINDOW CLASS
-- =====================================================================
function Nebula.CreateWindow(config)
    config = config or {}
    local title = config.Title or "Nebula UI"
    local subtitle = config.Subtitle or ""
    
    -- Destroy existing
    if CoreGui:FindFirstChild("NebulaUI") then
        CoreGui.NebulaUI:Destroy()
    end
    
    local window = {}
    setmetatable(window, Nebula)
    
    -- Main ScreenGui
    local SG = Create("ScreenGui", {
        Name = "NebulaUI",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Main Frame
    local Main = Create("Frame", {
        Parent = SG,
        BackgroundColor3 = Settings.DarkColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -250, 0.5, -175),
        Size = UDim2.new(0, 500, 0, 350),
        Active = true,
        ClipsDescendants = true,
    })
    AddCorner(Main, 12)
    
    -- Shadow effect
    local Shadow = Create("Frame", {
        Parent = SG,
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -248, 0.5, -173),
        Size = UDim2.new(0, 500, 0, 350),
        ZIndex = -1,
    })
    AddCorner(Shadow, 12)
    
    -- Title Bar
    local TitleBar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Settings.DarkerColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 2,
    })
    AddCorner(TitleBar, 12)
    
    -- Title Bar Accent Line
    Create("Frame", {
        Parent = TitleBar,
        BackgroundColor3 = Settings.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 0),
        ZIndex = 3,
    })
    
    -- Title Text
    local TitleLabel = Create("TextLabel", {
        Parent = TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    
    -- Close Button
    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundColor3 = Color3.fromRGB(60, 30, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -34, 0, 7),
        Size = UDim2.new(0, 26, 0, 26),
        Font = Enum.Font.GothamBold,
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 14,
        ZIndex = 3,
        AutoButtonColor = false,
    })
    AddCorner(CloseBtn, 6)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.15)
        SG:Destroy()
    end)
    
    -- Minimize Button
    local minimized = false
    local MinBtn = Create("TextButton", {
        Parent = TitleBar,
        BackgroundColor3 = Color3.fromRGB(40, 40, 55),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -66, 0, 7),
        Size = UDim2.new(0, 26, 0, 26),
        Font = Enum.Font.GothamBold,
        Text = "−",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        ZIndex = 3,
        AutoButtonColor = false,
    })
    AddCorner(MinBtn, 6)
    
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(Main, {Size = UDim2.new(0, 500, 0, 40)})
            Tween(Shadow, {Size = UDim2.new(0, 500, 0, 40)})
            MinBtn.Text = "+"
        else
            Tween(Main, {Size = UDim2.new(0, 500, 0, 350)})
            Tween(Shadow, {Size = UDim2.new(0, 500, 0, 350)})
            MinBtn.Text = "−"
        end
    end)
    
    -- Make draggable
    MakeDraggable(Main, TitleBar)
    MakeDraggable(Shadow, TitleBar)
    
    -- Tab Container
    local TabContainer = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Settings.DarkerColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 40),
        Size = UDim2.new(0, 120, 1, -40),
        ZIndex = 1,
    })
    
    local TabList = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })
    
    local TabPadding = Create("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
    })
    
    -- Content Area
    local ContentArea = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Settings.DarkColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 120, 0, 40),
        Size = UDim2.new(1, -120, 1, -40),
        ZIndex = 1,
    })
    
    -- Content Pages Container
    local PageContainer = Create("Frame", {
        Parent = ContentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
    })
    
    -- Store references
    window.SG = SG
    window.Main = Main
    window.TabContainer = TabContainer
    window.PageContainer = PageContainer
    window.Tabs = {}
    window.Pages = {}
    window.currentTab = nil
    
    -- =====================================================================
    -- ANIMATE IN
    -- =====================================================================
    Main.Size = UDim2.new(0, 0, 0, 0)
    Shadow.Size = UDim2.new(0, 0, 0, 0)
    Tween(Main, {Size = UDim2.new(0, 500, 0, 350)}, 0.35, Enum.EasingStyle.Back)
    Tween(Shadow, {Size = UDim2.new(0, 500, 0, 350)}, 0.35, Enum.EasingStyle.Back)
    
    return window
end

-- =====================================================================
-- CREATE TAB
-- =====================================================================
function Nebula:CreateTab(name, icon)
    icon = icon or ""
    
    local tabBtn = Create("TextButton", {
        Parent = self.TabContainer,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 32),
        Font = Enum.Font.GothamBold,
        Text = icon .. "  " .. name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(tabBtn, 6)
    
    -- Create page
    local page = Create("ScrollingFrame", {
        Parent = self.PageContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 1,
    })
    
    local pageList = Create("UIListLayout", {
        Parent = page,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })
    
    local pagePad = Create("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    })
    
    -- Tab click
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages) do p.Visible = false end
        for _, t in pairs(self.Tabs) do
            Tween(t, {BackgroundColor3 = Settings.LighterColor}, 0.15)
        end
        page.Visible = true
        Tween(tabBtn, {BackgroundColor3 = Settings.AccentColor}, 0.15)
        self.currentTab = name
    end)
    
    -- Select first tab
    if #self.Tabs == 0 then
        page.Visible = true
        Tween(tabBtn, {BackgroundColor3 = Settings.AccentColor}, 0.1)
        self.currentTab = name
    end
    
    table.insert(self.Tabs, tabBtn)
    table.insert(self.Pages, page)
    
    return page
end

-- =====================================================================
-- SECTIONS
-- =====================================================================
function Nebula:CreateSection(page, name)
    local section = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.DarkerColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 28),
        ZIndex = 1,
    })
    AddCorner(section, 6)
    
    local accent = Create("Frame", {
        Parent = section,
        BackgroundColor3 = Settings.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        ZIndex = 2,
    })
    AddCorner(accent, 6)
    
    local label = Create("TextLabel", {
        Parent = section,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.AccentColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    return section
end

-- =====================================================================
-- TOGGLE
-- =====================================================================
function Nebula:CreateToggle(page, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local toggleBg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = default and Color3.fromRGB(50, 150, 80) or Color3.fromRGB(60, 60, 70),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -44, 0.5, -10),
        Size = UDim2.new(0, 36, 0, 20),
        ZIndex = 2,
    })
    AddCorner(toggleBg, 10)
    
    local toggleDot = Create("Frame", {
        Parent = toggleBg,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
        ZIndex = 3,
    })
    AddCorner(toggleDot, 7)
    
    local state = default
    
    local function updateToggle()
        if state then
            Tween(toggleBg, {BackgroundColor3 = Color3.fromRGB(50, 150, 80)}, 0.15)
            Tween(toggleDot, {Position = UDim2.new(1, -17, 0.5, -7)}, 0.15)
        else
            Tween(toggleBg, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}, 0.15)
            Tween(toggleDot, {Position = UDim2.new(0, 3, 0.5, -7)}, 0.15)
        end
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateToggle()
            callback(state)
        end
    end)
    
    return {Set = function(v) state = v; updateToggle() end, Value = state}
end

-- =====================================================================
-- BUTTON
-- =====================================================================
function Nebula:CreateButton(page, config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end
    local color = config.Color or Settings.AccentColor
    
    local btn = Create("TextButton", {
        Parent = page,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 1,
    })
    AddCorner(btn, 8)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(
            math.min(color.R * 255 + 30, 255) / 255,
            math.min(color.G * 255 + 30, 255) / 255,
            math.min(color.B * 255 + 30, 255) / 255
        )}, 0.1)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = color}, 0.1)
    end)
    
    -- Click animation
    btn.MouseButton1Click:Connect(function()
        Tween(btn, {Size = UDim2.new(0.95, 0, 0, 30)}, 0.05)
        task.wait(0.05)
        Tween(btn, {Size = UDim2.new(1, 0, 0, 34)}, 0.05)
        callback()
    end)
    
    return btn
end

-- =====================================================================
-- SLIDER
-- =====================================================================
function Nebula:CreateSlider(page, config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end
    local suffix = config.Suffix or ""
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = name .. ": " .. default .. suffix,
        TextColor3 = Settings.TextColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local sliderBg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 24),
        Size = UDim2.new(1, -70, 0, 6),
        ZIndex = 2,
    })
    AddCorner(sliderBg, 3)
    
    local sliderFill = Create("Frame", {
        Parent = sliderBg,
        BackgroundColor3 = Settings.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        ZIndex = 3,
    })
    AddCorner(sliderFill, 3)
    
    local input = Create("TextBox", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -54, 0, 26),
        Size = UDim2.new(0, 44, 0, 18),
        Font = Enum.Font.Code,
        Text = tostring(default),
        TextColor3 = Color3.fromRGB(200, 255, 200),
        TextSize = 10,
        ZIndex = 2,
    })
    AddCorner(input, 4)
    
    local function update(val)
        val = math.clamp(tonumber(val) or min, min, max)
        sliderFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        label.Text = name .. ": " .. val .. suffix
        callback(val)
    end
    
    input.FocusLost:Connect(function() update(input.Text) end)
    
    sliderBg.InputBegan:Connect(function(ib)
        if ib.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn = RunService.RenderStepped:Connect(function()
                local mouse = UserInputService:GetMouseLocation()
                local perc = math.clamp((mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * perc)
                update(val)
                input.Text = tostring(val)
            end)
            UserInputService.InputEnded:Connect(function(ie)
                if ie.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
            end)
        end
    end)
    
    return {Set = update, Value = default}
end

-- =====================================================================
-- DROPDOWN
-- =====================================================================
function Nebula:CreateDropdown(page, config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {}
    local callback = config.Callback or function() end
    local default = config.Default or ""
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        ClipsDescendants = false,
        ZIndex = 5,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 120, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local dropBtn = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -120, 0.5, -11),
        Size = UDim2.new(0, 110, 0, 22),
        Font = Enum.Font.GothamBold,
        Text = default ~= "" and default or "Select...",
        TextColor3 = Settings.TextColor,
        TextSize = 10,
        AutoButtonColor = false,
        ZIndex = 6,
    })
    AddCorner(dropBtn, 6)
    
    local dropList = Create("ScrollingFrame", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(20, 20, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -120, 0, 0),
        Size = UDim2.new(0, 110, 0, 0),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 10,
    })
    AddCorner(dropList, 6)
    
    local dropListLayout = Create("UIListLayout", {
        Parent = dropList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
    })
    
    local function refreshOptions(newOptions)
        for _, child in pairs(dropList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        for _, opt in pairs(newOptions) do
            local optBtn = Create("TextButton", {
                Parent = dropList,
                BackgroundColor3 = Color3.fromRGB(25, 25, 35),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24),
                Font = Enum.Font.Gotham,
                Text = opt,
                TextColor3 = Settings.TextColor,
                TextSize = 10,
                AutoButtonColor = false,
                ZIndex = 11,
            })
            AddCorner(optBtn, 4)
            
            optBtn.MouseButton1Click:Connect(function()
                dropBtn.Text = opt
                dropList.Visible = false
                callback(opt)
            end)
            
            optBtn.MouseEnter:Connect(function()
                Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.1)
            end)
            optBtn.MouseLeave:Connect(function()
                Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}, 0.1)
            end)
        end
    end
    
    refreshOptions(options)
    
    dropBtn.MouseButton1Click:Connect(function()
        dropList.Visible = not dropList.Visible
        if dropList.Visible then
            dropList.Position = UDim2.new(1, -120, 0, 36)
        end
    end)
    
    return {Refresh = refreshOptions, Value = default}
end

-- =====================================================================
-- LABEL
-- =====================================================================
function Nebula:CreateLabel(page, config)
    config = config or {}
    local text = config.Text or "Label"
    local color = config.Color or Settings.TextColor
    local size = config.Size or 11
    
    local label = Create("TextLabel", {
        Parent = page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = color,
        TextSize = size,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = config.Wrap or false,
    })
    
    return label
end

-- =====================================================================
-- TEXTBOX (INPUT)
-- =====================================================================
function Nebula:CreateTextBox(page, config)
    config = config or {}
    local placeholder = config.Placeholder or "Enter text..."
    local callback = config.Callback or function() end
    local default = config.Default or ""
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local input = Create("TextBox", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.Gotham,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(100, 100, 110),
        Text = default,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 2,
    })
    AddCorner(input, 6)
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(input.Text)
        end
    end)
    
    return input
end

-- =====================================================================
-- KEYBIND
-- =====================================================================
function Nebula:CreateKeybind(page, config)
    config = config or {}
    local name = config.Name or "Keybind"
    local default = config.Default or "None"
    local callback = config.Callback or function() end
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = Settings.LighterColor,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 180, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Settings.TextColor,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local keyBtn = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -80, 0.5, -10),
        Size = UDim2.new(0, 70, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "[" .. default .. "]",
        TextColor3 = Settings.TextColor,
        TextSize = 10,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(keyBtn, 6)
    
    local currentKey = default
    local binding = false
    
    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "[...]"
        
        local conn = UserInputService.InputBegan:Connect(function(input)
            if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
                binding = false
                currentKey = input.KeyCode.Name
                keyBtn.Text = "[" .. currentKey .. "]"
                callback(currentKey)
                conn:Disconnect()
            end
        end)
    end)
    
    return {Set = function(k) currentKey = k; keyBtn.Text = "[" .. k .. "]" end, Value = currentKey}
end

-- =====================================================================
-- NOTIFICATION
-- =====================================================================
function Nebula:Notify(config)
    config = config or {}
    local title = config.Title or "Nebula"
    local content = config.Content or ""
    local duration = config.Duration or 4
    
    local notif = Create("Frame", {
        Parent = self.SG,
        BackgroundColor3 = Settings.DarkColor,
        BorderColor3 = Settings.AccentColor,
        BorderSizePixel = 1,
        Position = UDim2.new(1, 0, 0.8, 0),
        Size = UDim2.new(0, 280, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        ClipsDescendants = true,
        ZIndex = 100,
    })
    AddCorner(notif, 10)
    
    local titleLabel = Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 6),
        Size = UDim2.new(1, -24, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Settings.AccentColor,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    })
    
    local contentLabel = Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 26),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.Gotham,
        Text = content,
        TextColor3 = Settings.DimTextColor,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    })
    
    -- Animate in
    notif.Size = UDim2.new(0, 0, 0, 0)
    Tween(notif, {Position = UDim2.new(1, -10, 0.8, -50), Size = UDim2.new(0, 280, 0, 50)}, 0.3, Enum.EasingStyle.Back)
    
    -- Animate out
    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 0, 0.8, 0), Size = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.2)
        notif:Destroy()
    end)
end

return Nebula
