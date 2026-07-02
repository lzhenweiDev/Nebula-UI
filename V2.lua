-- =====================================================================
-- 🌟 NEBULA UI LIBRARY v3.0 - Purple Glossy Theme + Loading Screen
-- Professional Roblox UI Library
-- =====================================================================

local Nebula = {}
Nebula.__index = Nebula

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- =====================================================================
-- CONSTANTS
-- =====================================================================
local TWEEN_SPEED = 0.16
local HOVER_SPEED = 0.12
local CLICK_SPEED = 0.08
local CORNER_RADIUS = 8
local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold

-- =====================================================================
-- THEMES (Purple/Violet Default)
-- =====================================================================
local Themes = {
    Amethyst = {
        Background = Color3.fromRGB(24, 10, 80),
        Background2 = Color3.fromRGB(35, 14, 110),
        Surface = Color3.fromRGB(65, 35, 170),
        Surface2 = Color3.fromRGB(95, 60, 220),
        Text = Color3.fromRGB(245, 245, 255),
        TextDim = Color3.fromRGB(210, 200, 235),
        Accent = Color3.fromRGB(180, 120, 255),
        AccentHover = Color3.fromRGB(235, 190, 255),
        AccentGlow = Color3.fromRGB(250, 230, 255),
        Danger = Color3.fromRGB(225, 90, 110),
        Success = Color3.fromRGB(115, 235, 160),
        Warning = Color3.fromRGB(255, 205, 95),
        Border = Color3.fromRGB(145, 105, 215),
        Shadow = Color3.fromRGB(8, 4, 30),
        Gloss = true,
    },
    Dark = {
        Background = Color3.fromRGB(18, 18, 28),
        Background2 = Color3.fromRGB(12, 12, 20),
        Surface = Color3.fromRGB(28, 28, 40),
        Surface2 = Color3.fromRGB(22, 22, 34),
        Text = Color3.fromRGB(220, 220, 225),
        TextDim = Color3.fromRGB(140, 140, 155),
        Accent = Color3.fromRGB(80, 140, 255),
        AccentHover = Color3.fromRGB(100, 160, 255),
        AccentGlow = Color3.fromRGB(120, 170, 255),
        Danger = Color3.fromRGB(220, 60, 60),
        Success = Color3.fromRGB(50, 180, 80),
        Warning = Color3.fromRGB(255, 180, 50),
        Border = Color3.fromRGB(50, 50, 65),
        Shadow = Color3.fromRGB(0, 0, 0),
        Gloss = false,
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Background2 = Color3.fromRGB(255, 255, 255),
        Surface = Color3.fromRGB(230, 230, 238),
        Surface2 = Color3.fromRGB(235, 235, 242),
        Text = Color3.fromRGB(30, 30, 35),
        TextDim = Color3.fromRGB(120, 120, 130),
        Accent = Color3.fromRGB(120, 70, 240),
        AccentHover = Color3.fromRGB(140, 90, 255),
        AccentGlow = Color3.fromRGB(160, 120, 255),
        Danger = Color3.fromRGB(200, 50, 50),
        Success = Color3.fromRGB(40, 160, 70),
        Warning = Color3.fromRGB(240, 160, 40),
        Border = Color3.fromRGB(200, 200, 210),
        Shadow = Color3.fromRGB(100, 100, 100),
        Gloss = false,
    },
}

local CurrentTheme = Themes.Amethyst

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

local function Tween(obj, props, duration, easing, dir)
    local t = TweenService:Create(obj, TweenInfo.new(duration or TWEEN_SPEED, easing or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function AddCorner(obj, radius)
    return Create("UICorner", {Parent = obj, CornerRadius = UDim.new(0, radius or CORNER_RADIUS)})
end

local function AddGloss(obj)
    local gloss = Create("Frame", {
        Parent = obj,
        BackgroundColor3 = CurrentTheme.AccentGlow,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0.18, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 99,
    })
    AddCorner(gloss, CORNER_RADIUS)
    Create("UIGradient", {
        Parent = gloss,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, CurrentTheme.AccentGlow),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.78),
            NumberSequenceKeypoint.new(0.4, 0.9),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Rotation = 0,
    })
    return gloss
end

local function AddShadow(obj, transparency, size)
    local shadow = Create("ImageLabel", {
        Parent = obj,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = transparency or 0.78,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Size = UDim2.new(1, size or 8, 1, size or 8),
        Position = UDim2.new(0, -(size or 8)/2, 0, -(size or 8)/2),
        ZIndex = -1,
    })
    return shadow
end

local function MakeDraggable(frame, dragBar)
    local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
    dragBar = dragBar or frame
    
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- =====================================================================
-- EVENT SYSTEM
-- =====================================================================
local Event = {}
Event.__index = Event

function Event.new()
    local self = setmetatable({}, Event)
    self._listeners = {}
    return self
end

function Event:Connect(callback)
    table.insert(self._listeners, callback)
    return {
        Disconnect = function()
            for i, cb in pairs(self._listeners) do
                if cb == callback then
                    table.remove(self._listeners, i)
                    break
                end
            end
        end
    }
end

function Event:Fire(...)
    for _, cb in pairs(self._listeners) do
        pcall(cb, ...)
    end
end

-- =====================================================================
-- CONFIG SYSTEM
-- =====================================================================
local ConfigManager = {}

function ConfigManager:Save(name, data)
    pcall(function()
        if writefile then
            writefile("Nebula_" .. name .. ".json", HttpService:JSONEncode(data))
        end
    end)
end

function ConfigManager:Load(name)
    local success, result = pcall(function()
        if readfile and isfile and isfile("Nebula_" .. name .. ".json") then
            return HttpService:JSONDecode(readfile("Nebula_" .. name .. ".json"))
        end
        return nil
    end)
    return success and result or nil
end

function ConfigManager:Delete(name)
    pcall(function()
        if delfile and isfile and isfile("Nebula_" .. name .. ".json") then
            delfile("Nebula_" .. name .. ".json")
        end
    end)
end

-- =====================================================================
-- LOADING SCREEN
-- =====================================================================
local function ShowLoadingScreen(config)
    local steps = config.Steps or {"Loading UI...", "Initializing...", "Ready!"}
    local callback = config.Callback or function() end
    local duration = config.Duration or 3
    
    local SG = Create("ScreenGui", {
        Name = "NebulaLoading",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Background
    local bg = Create("Frame", {
        Parent = SG,
        BackgroundColor3 = CurrentTheme.Shadow,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 999,
    })
    
    -- Center container
    local container = Create("Frame", {
        Parent = bg,
        BackgroundColor3 = CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -150, 0.5, -80),
        Size = UDim2.new(0, 300, 0, 160),
        ZIndex = 1000,
        BackgroundTransparency = 1,
    })
    AddCorner(container, 14)
    AddShadow(container, 0.4, 10)
    if CurrentTheme.Gloss then AddGloss(container) end
    
    -- Title
    local title = Create("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 12),
        Size = UDim2.new(1, 0, 0, 24),
        Font = FONT_BOLD,
        Text = "🌟 Nebula UI",
        TextColor3 = CurrentTheme.Accent,
        TextSize = 20,
        ZIndex = 1001,
    })
    
    -- Subtitle
    local subtitle = Create("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 38),
        Size = UDim2.new(1, 0, 0, 16),
        Font = FONT,
        Text = config.Title or "Loading...",
        TextColor3 = CurrentTheme.TextDim,
        TextSize = 11,
        ZIndex = 1001,
    })
    
    -- Step label
    local stepLabel = Create("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 62),
        Size = UDim2.new(1, 0, 0, 16),
        Font = FONT_BOLD,
        Text = steps[1],
        TextColor3 = CurrentTheme.Text,
        TextSize = 11,
        ZIndex = 1001,
    })
    
    -- Progress bar background
    local barBg = Create("Frame", {
        Parent = container,
        BackgroundColor3 = CurrentTheme.Surface2,
        BorderColor3 = CurrentTheme.Border,
        BorderSizePixel = 1,
        Position = UDim2.new(0.1, 0, 0, 88),
        Size = UDim2.new(0.8, 0, 0, 8),
        ZIndex = 1001,
    })
    AddCorner(barBg, 4)
    
    -- Progress bar fill
    local barFill = Create("Frame", {
        Parent = barBg,
        BackgroundColor3 = CurrentTheme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 1002,
    })
    AddCorner(barFill, 4)
    
    -- Percentage
    local pctLabel = Create("TextLabel", {
        Parent = container,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 105),
        Size = UDim2.new(1, 0, 0, 16),
        Font = FONT_BOLD,
        Text = "0%",
        TextColor3 = CurrentTheme.Accent,
        TextSize = 11,
        ZIndex = 1001,
    })
    
    -- Animate
    Tween(bg, {BackgroundTransparency = 0.55}, 0.25)
    Tween(container, {BackgroundTransparency = 0}, 0.25)
    local stepTime = duration / #steps
    for i = 1, #steps do
        task.delay((i - 1) * stepTime, function()
            stepLabel.Text = steps[i]
            local targetPct = (i / #steps)
            Tween(barFill, {Size = UDim2.new(targetPct, 0, 1, 0)}, stepTime * 0.8)
        end)
    end
    
    -- Animate percentage
    task.spawn(function()
        for i = 1, 100 do
            task.wait(duration / 100)
            pctLabel.Text = i .. "%"
        end
    end)
    
    -- Fade out
    task.delay(duration, function()
        Tween(bg, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        SG:Destroy()
        callback()
    end)
end

-- =====================================================================
-- NOTIFICATION SYSTEM
-- =====================================================================
local function ShowNotification(window, config)
    local title = config.Title or "Nebula"
    local content = config.Content or ""
    local duration = config.Duration or 4
    local icon = config.Icon or "ℹ️"
    local notifType = config.Type or "info"
    
    local colors = {
        info = CurrentTheme.Accent,
        success = CurrentTheme.Success,
        warning = CurrentTheme.Warning,
        error = CurrentTheme.Danger,
    }
    
    local notif = Create("Frame", {
        Parent = window.SG,
        BackgroundColor3 = CurrentTheme.Surface,
        BorderColor3 = colors[notifType] or CurrentTheme.Border,
        BorderSizePixel = 1,
        Position = UDim2.new(1, 10, 0.85, -10),
        Size = UDim2.new(0, 300, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        ClipsDescendants = true,
        ZIndex = 1000,
    })
    AddCorner(notif, 10)
    if CurrentTheme.Gloss then AddGloss(notif) end
    
    Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Font = FONT_BOLD,
        Text = icon,
        TextSize = 16,
        ZIndex = 1001,
    })
    
    Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 6),
        Size = UDim2.new(1, -50, 0, 16),
        Font = FONT_BOLD,
        Text = title,
        TextColor3 = CurrentTheme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 1001,
    })
    
    Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 24),
        Size = UDim2.new(1, -50, 0, 14),
        Font = FONT,
        Text = content,
        TextColor3 = CurrentTheme.TextDim,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 1001,
    })
    
    notif.Position = UDim2.new(1, 30, 0.85, -10)
    notif.BackgroundTransparency = 1
    Tween(notif, {Position = UDim2.new(1, -10, 0.85, -10), BackgroundTransparency = 0}, 0.34, Enum.EasingStyle.Back)
    Tween(notif, {Size = UDim2.new(0, 300, 0, 50)}, 0.28, Enum.EasingStyle.Back)
    
    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 30, 0.85, -10), BackgroundTransparency = 1}, 0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Tween(notif, {Size = UDim2.new(0, 300, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.22)
        notif:Destroy()
    end)
end

-- =====================================================================
-- WINDOW CLASS
-- =====================================================================
local Window = {}
Window.__index = Window

function Window.new(config)
    config = config or {}
    local self = setmetatable({}, Window)
    
    self.Title = config.Title or "Nebula UI"
    self.ConfigName = config.ConfigName or "default"
    self.Minimized = false
    
    self.SG = Create("ScreenGui", {
        Name = "NebulaUI_" .. self.Title,
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Main Frame
    self.Main = Create("Frame", {
        Parent = self.SG,
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Size = UDim2.new(0, 550, 0, 400),
        ClipsDescendants = true,
        ZIndex = 1,
    })
    AddCorner(self.Main, 12)
    AddShadow(self.Main, 0.45, 12)
    Create("UIStroke", {Parent = self.Main, Color = CurrentTheme.Border, Thickness = 2, Transparency = 0.6})
    if CurrentTheme.Gloss then AddGloss(self.Main) end
    Create("UIGradient", {Parent = self.Main, Color = ColorSequence.new({CurrentTheme.Background, CurrentTheme.Surface2}), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.55, 0.14), NumberSequenceKeypoint.new(1, 0.35)}), Rotation = 90})
    
    -- Title Bar
    self.TitleBar = Create("Frame", {
        Parent = self.Main,
        BackgroundColor3 = CurrentTheme.Surface2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 2,
    })
    AddCorner(self.TitleBar, 12)
    Create("UIStroke", {Parent = self.TitleBar, Color = CurrentTheme.Border, Thickness = 1, Transparency = 0.8})
    if CurrentTheme.Gloss then AddGloss(self.TitleBar) end
    
    -- Glow line
    Create("Frame", {
        Parent = self.TitleBar,
        BackgroundColor3 = CurrentTheme.AccentGlow,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 0),
        ZIndex = 3,
    })
    
    self.TitleLabel = Create("TextLabel", {
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Font = FONT_BOLD,
        Text = self.Title,
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    
    -- Close button
    local closeBtn = Create("TextButton", {
        Parent = self.TitleBar,
        BackgroundColor3 = CurrentTheme.Danger,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -34, 0, 8),
        Size = UDim2.new(0, 26, 0, 26),
        Font = FONT_BOLD,
        Text = "✕",
        TextColor3 = CurrentTheme.Text,
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 3,
    })
    AddCorner(closeBtn, 6)
    closeBtn.MouseButton1Click:Connect(function() self:Destroy() end)
    
    -- Minimize button
    local minBtn = Create("TextButton", {
        Parent = self.TitleBar,
        BackgroundColor3 = CurrentTheme.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -66, 0, 8),
        Size = UDim2.new(0, 26, 0, 26),
        Font = FONT_BOLD,
        Text = "−",
        TextColor3 = CurrentTheme.Text,
        TextSize = 16,
        AutoButtonColor = false,
        ZIndex = 3,
    })
    AddCorner(minBtn, 6)
    minBtn.MouseButton1Click:Connect(function() self:Minimize() end)
    
    MakeDraggable(self.Main, self.TitleBar)
    
    -- Sidebar
    self.TabContainer = Create("Frame", {
        Parent = self.Main,
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 140, 1, -42),
        ZIndex = 1,
    })
    Create("UIStroke", {Parent = self.TabContainer, Color = CurrentTheme.Border, Thickness = 1, Transparency = 0.65})
    
    Create("UIListLayout", {
        Parent = self.TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    })
    
    Create("UIPadding", {
        Parent = self.TabContainer,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    })
    
    -- Content
    self.ContentArea = Create("Frame", {
        Parent = self.Main,
        BackgroundColor3 = CurrentTheme.Background2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 140, 0, 42),
        Size = UDim2.new(1, -140, 1, -42),
        ZIndex = 1,
    })
    
    self.PageContainer = Create("Frame", {
        Parent = self.ContentArea,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ClipsDescendants = true,
    })
    self.TabFlash = Create("Frame", {
        Parent = self.ContentArea,
        BackgroundColor3 = CurrentTheme.Accent,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 4),
        ZIndex = 4,
        Visible = false,
    })
    AddCorner(self.TabFlash, 4)
    
    self.Tabs = {}
    self.Pages = {}
    self.currentTab = nil
    
    -- Animate in
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Main, {Size = UDim2.new(0, 550, 0, 400), BackgroundTransparency = 0}, 0.35, Enum.EasingStyle.Back)
    
    return self
end

function Window:Destroy()
    Tween(self.Main, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.wait(0.18)
    self.SG:Destroy()
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    local targetSize = self.Minimized and UDim2.new(0, 550, 0, 42) or UDim2.new(0, 550, 0, 400)
    Tween(self.Main, {Size = targetSize}, 0.25)
end

function Window:Notify(config)
    ShowNotification(self, config)
end

function Window:CreateTab(name, icon)
    icon = icon or ""
    
    local tabBtn = Create("TextButton", {
        Parent = self.TabContainer,
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Font = FONT_BOLD,
        Text = icon .. "  " .. name,
        TextColor3 = CurrentTheme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(tabBtn, 8)
    if CurrentTheme.Gloss then AddGloss(tabBtn) end
    
    tabBtn.MouseEnter:Connect(function()
        if self.currentTab ~= name then Tween(tabBtn, {BackgroundColor3 = CurrentTheme.Surface2}, HOVER_SPEED) end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.currentTab ~= name then Tween(tabBtn, {BackgroundColor3 = CurrentTheme.Surface}, HOVER_SPEED) end
    end)
    
    local page = Create("ScrollingFrame", {
        Parent = self.PageContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = CurrentTheme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 1,
    })
    
    Create("UIListLayout", {
        Parent = page,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
    })
    
    Create("UIPadding", {
        Parent = page,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    })
    
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages) do p.Visible = false end
        for _, t in pairs(self.Tabs) do
            Tween(t, {BackgroundColor3 = CurrentTheme.Surface, TextColor3 = CurrentTheme.TextDim}, HOVER_SPEED)
        end
        page.BackgroundTransparency = 1
        page.Visible = true
        Tween(page, {BackgroundTransparency = 0}, 0.2)
        Tween(tabBtn, {BackgroundColor3 = CurrentTheme.Accent, TextColor3 = CurrentTheme.Text}, HOVER_SPEED)
        self.TabFlash.Visible = true
        self.TabFlash.Size = UDim2.new(0, 0, 0, 4)
        Tween(self.TabFlash, {Size = UDim2.new(1, 0, 0, 4)}, 0.25, Enum.EasingStyle.Quart)
        task.delay(0.25, function()
            Tween(self.TabFlash, {BackgroundTransparency = 1}, 0.18)
            task.delay(0.18, function() self.TabFlash.Visible = false end)
        end)
        self.currentTab = name
    end)
    
    if #self.Tabs == 0 then
        page.BackgroundTransparency = 0
        page.Visible = true
        Tween(tabBtn, {BackgroundColor3 = CurrentTheme.Accent, TextColor3 = CurrentTheme.Text}, 0.1)
        self.currentTab = name
    end
    
    table.insert(self.Tabs, tabBtn)
    table.insert(self.Pages, page)
    
    return {Window = self, Page = page, Name = name}
end

-- =====================================================================
-- SECTION
-- =====================================================================
function Nebula.CreateSection(tab, config)
    config = config or {}
    local name = config.Name or ""
    local page = tab.Page
    
    local section = Create("Frame", {
        Parent = page,
        BackgroundColor3 = CurrentTheme.Background,
        BorderColor3 = CurrentTheme.Border,
        BorderSizePixel = 1,
        Size = UDim2.new(1, 0, 0, name ~= "" and 28 or 0),
        ZIndex = 1,
    })
    if name ~= "" then AddCorner(section, 8); if CurrentTheme.Gloss then AddGloss(section) end end
    
    if name ~= "" then
        Create("Frame", {
            Parent = section,
            BackgroundColor3 = CurrentTheme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, 0),
            ZIndex = 2,
        })
        
        Create("TextLabel", {
            Parent = section,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = FONT_BOLD,
            Text = name,
            TextColor3 = CurrentTheme.AccentGlow,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
        })
    end
    
    local self = {Page = page}
    
    function self:CreateToggle(cfg) return Nebula.CreateToggle(page, cfg) end
    function self:CreateButton(cfg) return Nebula.CreateButton(page, cfg) end
    function self:CreateSlider(cfg) return Nebula.CreateSlider(page, cfg) end
    function self:CreateDropdown(cfg) return Nebula.CreateDropdown(page, cfg) end
    function self:CreateLabel(cfg) return Nebula.CreateLabel(page, cfg) end
    function self:CreateTextBox(cfg) return Nebula.CreateTextBox(page, cfg) end
    function self:CreateKeybind(cfg) return Nebula.CreateKeybind(page, cfg) end
    function self:CreateCheckbox(cfg) return Nebula.CreateCheckbox(page, cfg) end
    function self:CreateColorPicker(cfg) return Nebula.CreateColorPicker(page, cfg) end
    function self:CreateProgressBar(cfg) return Nebula.CreateProgressBar(page, cfg) end
    
    return self
end

-- =====================================================================
-- ALL COMPONENTS (TOGGLE, BUTTON, SLIDER, DROPDOWN, LABEL, TEXTBOX, KEYBIND, CHECKBOX, COLORPICKER, PROGRESSBAR)
-- =====================================================================

function Nebula.CreateToggle(page, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    if CurrentTheme.Gloss then AddGloss(frame) end
    
    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 220, 1, 0),
        Font = FONT_BOLD,
        Text = name,
        TextColor3 = CurrentTheme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local toggleBg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = default and CurrentTheme.Success or CurrentTheme.Surface2,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -44, 0.5, -10),
        Size = UDim2.new(0, 36, 0, 20),
        ZIndex = 2,
    })
    AddCorner(toggleBg, 10)
    
    local toggleDot = Create("Frame", {
        Parent = toggleBg,
        BackgroundColor3 = CurrentTheme.Text,
        BorderSizePixel = 0,
        Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        Size = UDim2.new(0, 14, 0, 14),
        ZIndex = 3,
    })
    AddCorner(toggleDot, 7)
    
    local state = default
    local events = {OnChanged = Event.new()}
    
    local function update()
        if state then
            Tween(toggleBg, {BackgroundColor3 = CurrentTheme.Success}, HOVER_SPEED)
            Tween(toggleDot, {Position = UDim2.new(1, -17, 0.5, -7)}, HOVER_SPEED)
        else
            Tween(toggleBg, {BackgroundColor3 = CurrentTheme.Surface2}, HOVER_SPEED)
            Tween(toggleDot, {Position = UDim2.new(0, 3, 0.5, -7)}, HOVER_SPEED)
        end
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state; update(); callback(state); events.OnChanged:Fire(state)
        end
    end)
    
    return {Set = function(v) state = v; update() end, Get = function() return state end, Value = state, Events = events}
end

function Nebula.CreateButton(page, config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end
    local color = config.Color or CurrentTheme.Accent
    
    local btn = Create("TextButton", {
        Parent = page,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Font = FONT_BOLD,
        Text = name,
        TextColor3 = CurrentTheme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 1,
    })
    AddCorner(btn, 8)
    if CurrentTheme.Gloss then AddGloss(btn) end
    
    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = color:Lerp(CurrentTheme.AccentHover, 0.18)}, 0.12)
    end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = color}, 0.12) end)
    
    btn.MouseButton1Click:Connect(function()
        Tween(btn, {Size = UDim2.new(0.98, 0, 0, 34)}, CLICK_SPEED, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        task.wait(CLICK_SPEED)
        Tween(btn, {Size = UDim2.new(1, 0, 0, 36)}, CLICK_SPEED, Enum.EasingStyle.Sine)
        callback()
    end)
    
    return {Button = btn}
end

function Nebula.CreateSlider(page, config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end
    local suffix = config.Suffix or ""
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 52),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    if CurrentTheme.Gloss then AddGloss(frame) end
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -24, 0, 16),
        Font = FONT_BOLD,
        Text = name .. ": " .. default .. suffix,
        TextColor3 = CurrentTheme.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local sliderBg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = CurrentTheme.Surface2,
        BorderColor3 = CurrentTheme.Border,
        BorderSizePixel = 1,
        Position = UDim2.new(0, 12, 0, 24),
        Size = UDim2.new(1, -70, 0, 6),
        ZIndex = 2,
    })
    AddCorner(sliderBg, 3)
    
    local sliderFill = Create("Frame", {
        Parent = sliderBg,
        BackgroundColor3 = CurrentTheme.AccentGlow,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        ZIndex = 3,
    })
    AddCorner(sliderFill, 3)
    
    local input = Create("TextBox", {
        Parent = frame,
        BackgroundColor3 = CurrentTheme.Background2,
        BorderColor3 = CurrentTheme.Border,
        BorderSizePixel = 1,
        Position = UDim2.new(1, -54, 0, 26),
        Size = UDim2.new(0, 44, 0, 18),
        Font = Enum.Font.Code,
        Text = tostring(default),
        TextColor3 = CurrentTheme.Text,
        TextSize = 10,
        ZIndex = 2,
    })
    AddCorner(input, 4)
    
    local currentValue = default
    local events = {OnChanged = Event.new()}
    
    local function update(val)
        val = math.clamp(tonumber(val) or min, min, max)
        currentValue = val
        Tween(sliderFill, {Size = UDim2.new((val - min) / (max - min), 0, 1, 0)}, HOVER_SPEED)
        label.Text = name .. ": " .. val .. suffix
        callback(val)
        events.OnChanged:Fire(val)
    end
    
    input.FocusLost:Connect(function() update(input.Text) end)
    
    sliderBg.InputBegan:Connect(function(ib)
        if ib.UserInputType == Enum.UserInputType.MouseButton1 then
            local conn = RunService.RenderStepped:Connect(function()
                local mouse = UserInputService:GetMouseLocation()
                local perc = math.clamp((mouse.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * perc)
                update(val); input.Text = tostring(val)
            end)
            UserInputService.InputEnded:Connect(function(ie) if ie.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end end)
        end
    end)
    
    return {Set = function(v) update(v); input.Text = tostring(v) end, Get = function() return currentValue end, Value = currentValue, Events = events}
end

function Nebula.CreateDropdown(page, config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {}
    local callback = config.Callback or function() end
    local default = config.Default or ""
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = CurrentTheme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ClipsDescendants = false,
        ZIndex = 5,
    })
    AddCorner(frame, 8)
    if CurrentTheme.Gloss then AddGloss(frame) end
    
    Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 140, 1, 0),
        Font = FONT_BOLD,
        Text = name,
        TextColor3 = CurrentTheme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local dropBtn = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = CurrentTheme.Background2,
        BorderColor3 = CurrentTheme.Border,
        BorderSizePixel = 1,
        Position = UDim2.new(1, -130, 0.5, -11),
        Size = UDim2.new(0, 118, 0, 22),
        Font = FONT_BOLD,
        Text = default ~= "" and default or "Select...",
        TextColor3 = CurrentTheme.Text,
        TextSize = 10,
        AutoButtonColor = false,
        ZIndex = 6,
    })
    AddCorner(dropBtn, 6)
    
    local dropList = Create("ScrollingFrame", {
        Parent = frame,
        BackgroundColor3 = CurrentTheme.Background2,
        BorderColor3 = CurrentTheme.Border,
        BorderSizePixel = 1,
        Position = UDim2.new(1, -130, 0, 0),
        Size = UDim2.new(0, 118, 0, 0),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 10,
    })
    AddCorner(dropList, 6)
    
    Create("UIListLayout", {Parent = dropList, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1)})
    
    local currentValue = default
    local events = {OnChanged = Event.new()}
    
    local function refreshOptions(newOptions)
        for _, child in pairs(dropList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        for _, opt in pairs(newOptions) do
            local optBtn = Create("TextButton", {
                Parent = dropList, BackgroundColor3 = CurrentTheme.Surface2, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 24), Font = FONT, Text = opt, TextColor3 = CurrentTheme.Text,
                TextSize = 10, AutoButtonColor = false, ZIndex = 11,
            })
            AddCorner(optBtn, 4)
            optBtn.MouseEnter:Connect(function() Tween(optBtn, {BackgroundColor3 = CurrentTheme.Surface}, HOVER_SPEED) end)
            optBtn.MouseLeave:Connect(function() Tween(optBtn, {BackgroundColor3 = CurrentTheme.Surface2}, HOVER_SPEED) end)
            optBtn.MouseButton1Click:Connect(function()
                currentValue = opt; dropBtn.Text = opt; callback(opt); events.OnChanged:Fire(opt)
                Tween(dropList, {Size = UDim2.new(0, 118, 0, 0)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
                task.delay(0.18, function() dropList.Visible = false end)
            end)
        end
    end
    refreshOptions(options)
    
    dropBtn.MouseButton1Click:Connect(function()
        if dropList.Visible then
            Tween(dropList, {Size = UDim2.new(0, 118, 0, 0)}, 0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
            task.delay(0.18, function() dropList.Visible = false end)
        else
            dropList.Visible = true
            dropList.Position = UDim2.new(1, -130, 0, 38)
            Tween(dropList, {Size = UDim2.new(0, 118, 0, math.min(#options * 24 + 4, 150))}, 0.2, Enum.EasingStyle.Sine)
        end
    end)
    
    return {Set = function(v) currentValue = v; dropBtn.Text = v end, Get = function() return currentValue end, Refresh = refreshOptions, Value = currentValue, Events = events}
end

function Nebula.CreateLabel(page, config)
    config = config or {}
    return Create("TextLabel", {
        Parent = page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18),
        Font = FONT, Text = config.Text or "", TextColor3 = config.Color or CurrentTheme.Text,
        TextSize = config.Size or 11, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
    })
end

function Nebula.CreateTextBox(page, config)
    config = config or {}
    local frame = Create("Frame", {
        Parent = page, BackgroundColor3 = CurrentTheme.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38), ZIndex = 1,
    })
    AddCorner(frame, 8)
    if CurrentTheme.Gloss then AddGloss(frame) end
    
    local input = Create("TextBox", {
        Parent = frame, BackgroundColor3 = CurrentTheme.Background2, BorderColor3 = CurrentTheme.Border, BorderSizePixel = 1,
        Position = UDim2.new(0, 10, 0.5, -10), Size = UDim2.new(1, -20, 0, 20),
        Font = FONT, PlaceholderText = config.Placeholder or "Enter text...",
        PlaceholderColor3 = CurrentTheme.TextDim, Text = config.Default or "",
        TextColor3 = CurrentTheme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false, ZIndex = 2,
    })
    AddCorner(input, 6)
    
    local events = {OnChanged = Event.new(), OnFocus = Event.new(), OnBlur = Event.new()}
    input:GetPropertyChangedSignal("Text"):Connect(function() events.OnChanged:Fire(input.Text) end)
    input.Focused:Connect(function() events.OnFocus:Fire() end)
    input.FocusLost:Connect(function(ep) events.OnBlur:Fire(); if ep and config.Callback then config.Callback(input.Text) end end)
    
    return {Set = function(v) input.Text = v end, Get = function() return input.Text end, Input = input, Events = events}
end

function Nebula.CreateKeybind(page, config)
    config = config or {}
    local frame = Create("Frame", {
        Parent = page, BackgroundColor3 = CurrentTheme.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38), ZIndex = 1,
    })
    AddCorner(frame, 8)
    if CurrentTheme.Gloss then AddGloss(frame) end
    
    Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0), Font = FONT_BOLD, Text = config.Name or "Keybind",
        TextColor3 = CurrentTheme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
    })
    
    local keyBtn = Create("TextButton", {
        Parent = frame, BackgroundColor3 = CurrentTheme.Background2, BorderColor3 = CurrentTheme.Border, BorderSizePixel = 1,
        Position = UDim2.new(1, -80, 0.5, -10), Size = UDim2.new(0, 70, 0, 20),
        Font = FONT_BOLD, Text = "[" .. (config.Default or "None") .. "]", TextColor3 = CurrentTheme.Text,
        TextSize = 10, AutoButtonColor = false, ZIndex = 2,
    })
    AddCorner(keyBtn, 6)
    
    local currentKey = config.Default or "None"
    local binding = false
    local events = {OnChanged = Event.new()}
    
    keyBtn.MouseButton1Click:Connect(function()
        binding = true; keyBtn.Text = "[...]"
        local conn = UserInputService.InputBegan:Connect(function(input)
            if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
                binding = false; currentKey = input.KeyCode.Name; keyBtn.Text = "[" .. currentKey .. "]"
                if config.Callback then config.Callback(currentKey) end; events.OnChanged:Fire(currentKey); conn:Disconnect()
            end
        end)
    end)
    
    return {Set = function(k) currentKey = k; keyBtn.Text = "[" .. k .. "]" end, Get = function() return currentKey end, Value = currentKey, Events = events}
end

function Nebula.CreateCheckbox(page, config)
    config = config or {}
    local frame = Create("Frame", {
        Parent = page, BackgroundColor3 = CurrentTheme.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38), ZIndex = 1,
    })
    AddCorner(frame, 8)
    if CurrentTheme.Gloss then AddGloss(frame) end
    
    local checkbox = Create("TextButton", {
        Parent = frame, BackgroundColor3 = (config.Default and CurrentTheme.Accent or CurrentTheme.Surface2),
        BorderColor3 = CurrentTheme.Border, BorderSizePixel = 1, Position = UDim2.new(0, 12, 0.5, -9), Size = UDim2.new(0, 18, 0, 18),
        Font = FONT_BOLD, Text = config.Default and "✓" or "", TextColor3 = CurrentTheme.Text,
        TextSize = 12, AutoButtonColor = false, ZIndex = 2,
    })
    AddCorner(checkbox, 4)
    
    Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1, Position = UDim2.new(0, 38, 0, 0),
        Size = UDim2.new(1, -50, 1, 0), Font = FONT, Text = config.Name or "Checkbox",
        TextColor3 = CurrentTheme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
    })
    
    local state = config.Default or false
    local events = {OnChanged = Event.new()}
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            checkbox.BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Surface2
            checkbox.Text = state and "✓" or ""
            if config.Callback then config.Callback(state) end; events.OnChanged:Fire(state)
        end
    end)
    
    return {Set = function(v) state = v; checkbox.BackgroundColor3 = state and CurrentTheme.Accent or CurrentTheme.Surface2; checkbox.Text = state and "✓" or "" end, Get = function() return state end, Value = state, Events = events}
end

function Nebula.CreateColorPicker(page, config)
    config = config or {}
    local default = config.Default or CurrentTheme.Accent
    local frame = Create("Frame", {
        Parent = page, BackgroundColor3 = CurrentTheme.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38), ZIndex = 1,
    })
    AddCorner(frame, 8)
    if CurrentTheme.Gloss then AddGloss(frame) end
    
    Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 140, 1, 0), Font = FONT_BOLD, Text = config.Name or "Color",
        TextColor3 = CurrentTheme.Text, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
    })
    
    local colorPreview = Create("Frame", {
        Parent = frame, BackgroundColor3 = default, BorderSizePixel = 0,
        Position = UDim2.new(1, -44, 0.5, -10), Size = UDim2.new(0, 20, 0, 20), ZIndex = 2,
    })
    AddCorner(colorPreview, 10)
    
    local currentColor = default
    local values = {math.floor(default.R*255), math.floor(default.G*255), math.floor(default.B*255)}
    local events = {OnChanged = Event.new()}
    
    local popup = Create("Frame", {
        Parent = frame, BackgroundColor3 = CurrentTheme.Background2, BorderColor3 = CurrentTheme.Border, BorderSizePixel = 1,
        Position = UDim2.new(0, 0, 1, 4), Size = UDim2.new(1, 0, 0, 0), Visible = false, ClipsDescendants = true, ZIndex = 20,
    })
    AddCorner(popup, 8)
    
    local colors = {"R", "G", "B"}
    for i, c in pairs(colors) do
        local row = Create("Frame", {Parent = popup, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22)})
        Create("TextLabel", {Parent = row, BackgroundTransparency = 1, Position = UDim2.new(0, 6, 0, 0), Size = UDim2.new(0, 16, 1, 0), Font = FONT_BOLD, Text = c, TextColor3 = CurrentTheme.Text, TextSize = 10, ZIndex = 21})
        local bg = Create("Frame", {Parent = row, BackgroundColor3 = CurrentTheme.Surface2, BorderColor3 = CurrentTheme.Border, BorderSizePixel = 1, Position = UDim2.new(0, 26, 0.5, -3), Size = UDim2.new(1, -70, 0, 6), ZIndex = 21})
        local fill = Create("Frame", {Parent = bg, BackgroundColor3 = i==1 and Color3.fromRGB(255,0,0) or i==2 and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,255), BorderSizePixel = 0, Size = UDim2.new(values[i]/255, 0, 1, 0), ZIndex = 22})
        local inp = Create("TextBox", {Parent = row, BackgroundColor3 = CurrentTheme.Background2, BorderColor3 = CurrentTheme.Border, BorderSizePixel = 1, Position = UDim2.new(1, -40, 0.5, -8), Size = UDim2.new(0, 34, 0, 16), Font = Enum.Font.Code, Text = tostring(values[i]), TextColor3 = CurrentTheme.Text, TextSize = 9, ZIndex = 21})
        
        bg.InputBegan:Connect(function(ib)
            if ib.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn = RunService.RenderStepped:Connect(function()
                    local mouse = UserInputService:GetMouseLocation()
                    local perc = math.clamp((mouse.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    values[i] = math.floor(perc * 255); fill.Size = UDim2.new(perc, 0, 1, 0); inp.Text = tostring(values[i])
                    currentColor = Color3.fromRGB(values[1]/255, values[2]/255, values[3]/255); colorPreview.BackgroundColor3 = currentColor
                    if config.Callback then config.Callback(currentColor) end; events.OnChanged:Fire(currentColor)
                end)
                UserInputService.InputEnded:Connect(function(ie) if ie.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end end)
            end
        end)
        
        inp.FocusLost:Connect(function()
            values[i] = math.clamp(tonumber(inp.Text) or 0, 0, 255); fill.Size = UDim2.new(values[i]/255, 0, 1, 0)
            currentColor = Color3.fromRGB(values[1]/255, values[2]/255, values[3]/255); colorPreview.BackgroundColor3 = currentColor
            if config.Callback then config.Callback(currentColor) end; events.OnChanged:Fire(currentColor)
        end)
    end
    
    colorPreview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if popup.Visible then
                Tween(popup, {Size = UDim2.new(1, 0, 0, 0)}, 0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
                task.delay(0.16, function() popup.Visible = false end)
            else
                popup.Visible = true
                popup.Size = UDim2.new(1, 0, 0, 0)
                Tween(popup, {Size = UDim2.new(1, 0, 0, 75)}, 0.2, Enum.EasingStyle.Sine)
            end
        end
    end)
    
    return {Set = function(c) currentColor = c; colorPreview.BackgroundColor3 = c; if config.Callback then config.Callback(c) end; events.OnChanged:Fire(c) end, Get = function() return currentColor end, Value = currentColor, Events = events}
end

function Nebula.CreateProgressBar(page, config)
    config = config or {}
    local value = config.Value or 0
    local max = config.Max or 100
    local frame = Create("Frame", {
        Parent = page, BackgroundColor3 = CurrentTheme.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42), ZIndex = 1,
    })
    AddCorner(frame, 8)
    if CurrentTheme.Gloss then AddGloss(frame) end
    
    local label = Create("TextLabel", {
        Parent = frame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 2),
        Size = UDim2.new(1, -24, 0, 14), Font = FONT_BOLD,
        Text = (config.Name or "Progress") .. ": " .. math.floor(value/max*100) .. "%",
        TextColor3 = CurrentTheme.Text, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2,
    })
    
    local bg = Create("Frame", {
        Parent = frame, BackgroundColor3 = CurrentTheme.Surface2, BorderColor3 = CurrentTheme.Border, BorderSizePixel = 1,
        Position = UDim2.new(0, 12, 0, 20), Size = UDim2.new(1, -24, 0, 10), ZIndex = 2,
    })
    AddCorner(bg, 5)
    
    local fill = Create("Frame", {
        Parent = bg, BackgroundColor3 = config.Color or CurrentTheme.AccentGlow, BorderSizePixel = 0,
        Size = UDim2.new(value/max, 0, 1, 0), ZIndex = 3,
    })
    AddCorner(fill, 5)
    
    local currentValue = value
    return {
        Set = function(v) currentValue = v; Tween(fill, {Size = UDim2.new(v/max, 0, 1, 0)}, 0.3); label.Text = (config.Name or "Progress") .. ": " .. math.floor(v/max*100) .. "%" end,
        Get = function() return currentValue end, Value = currentValue,
    }
end

-- =====================================================================
-- CREATE WINDOW (with loading screen)
-- =====================================================================
function Nebula.CreateWindow(config)
    local showLoading = config.ShowLoading ~= false
    local loadingSteps = config.LoadingSteps or {"Initializing UI...", "Loading components...", "Applying theme...", "Ready!"}
    local loadingDuration = config.LoadingDuration or 3
    
    if showLoading then
        local windowReady = false
        local win
        
        ShowLoadingScreen({
            Title = config.Title or "Nebula UI",
            Steps = loadingSteps,
            Duration = loadingDuration,
            Callback = function()
                windowReady = true
            end
        })
        
        repeat task.wait() until windowReady
    end
    
    return Window.new(config)
end

return Nebula
