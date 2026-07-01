-- =====================================================================
-- 🌟 NEBULA UI LIBRARY v2.0
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
local TWEEN_SPEED = 0.2
local CORNER_RADIUS = 8
local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold

-- =====================================================================
-- THEME SYSTEM
-- =====================================================================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 28),
        Background2 = Color3.fromRGB(12, 12, 20),
        Surface = Color3.fromRGB(28, 28, 40),
        Surface2 = Color3.fromRGB(22, 22, 34),
        Text = Color3.fromRGB(220, 220, 225),
        TextDim = Color3.fromRGB(140, 140, 155),
        Accent = Color3.fromRGB(80, 140, 255),
        AccentHover = Color3.fromRGB(100, 160, 255),
        Danger = Color3.fromRGB(220, 60, 60),
        Success = Color3.fromRGB(50, 180, 80),
        Warning = Color3.fromRGB(255, 180, 50),
        Border = Color3.fromRGB(50, 50, 65),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 245),
        Background2 = Color3.fromRGB(255, 255, 255),
        Surface = Color3.fromRGB(230, 230, 238),
        Surface2 = Color3.fromRGB(235, 235, 242),
        Text = Color3.fromRGB(30, 30, 35),
        TextDim = Color3.fromRGB(120, 120, 130),
        Accent = Color3.fromRGB(60, 120, 240),
        AccentHover = Color3.fromRGB(80, 140, 255),
        Danger = Color3.fromRGB(200, 50, 50),
        Success = Color3.fromRGB(40, 160, 70),
        Warning = Color3.fromRGB(240, 160, 40),
        Border = Color3.fromRGB(200, 200, 210),
        Shadow = Color3.fromRGB(100, 100, 100),
    },
    Midnight = {
        Background = Color3.fromRGB(8, 8, 20),
        Background2 = Color3.fromRGB(4, 4, 12),
        Surface = Color3.fromRGB(16, 16, 32),
        Surface2 = Color3.fromRGB(12, 12, 26),
        Text = Color3.fromRGB(200, 210, 255),
        TextDim = Color3.fromRGB(120, 130, 180),
        Accent = Color3.fromRGB(100, 80, 255),
        AccentHover = Color3.fromRGB(130, 110, 255),
        Danger = Color3.fromRGB(255, 70, 70),
        Success = Color3.fromRGB(60, 200, 100),
        Warning = Color3.fromRGB(255, 200, 60),
        Border = Color3.fromRGB(40, 40, 70),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
    Ocean = {
        Background = Color3.fromRGB(10, 25, 35),
        Background2 = Color3.fromRGB(5, 18, 25),
        Surface = Color3.fromRGB(16, 35, 48),
        Surface2 = Color3.fromRGB(12, 30, 42),
        Text = Color3.fromRGB(200, 230, 245),
        TextDim = Color3.fromRGB(130, 170, 190),
        Accent = Color3.fromRGB(0, 200, 200),
        AccentHover = Color3.fromRGB(30, 230, 230),
        Danger = Color3.fromRGB(255, 80, 80),
        Success = Color3.fromRGB(50, 200, 130),
        Warning = Color3.fromRGB(255, 190, 50),
        Border = Color3.fromRGB(30, 60, 75),
        Shadow = Color3.fromRGB(0, 0, 0),
    },
}

local CurrentTheme = Themes.Dark

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
    local t = TweenService:Create(obj, TweenInfo.new(duration or TWEEN_SPEED, easing or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function AddCorner(obj, radius)
    return Create("UICorner", {Parent = obj, CornerRadius = UDim.new(0, radius or CORNER_RADIUS)})
end

local function AddStroke(obj, color, thickness)
    return Create("UIStroke", {Parent = obj, Color = color or CurrentTheme.Border, Thickness = thickness or 1, Transparency = 0.5})
end

local function AddShadow(obj, transparency, size)
    local shadow = Create("ImageLabel", {
        Parent = obj,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = CurrentTheme.Shadow,
        ImageTransparency = transparency or 0.6,
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

function ConfigManager:Export(name)
    local data = self:Load(name)
    return data and HttpService:JSONEncode(data) or "{}"
end

function ConfigManager:Import(name, json)
    pcall(function()
        local data = HttpService:JSONDecode(json)
        self:Save(name, data)
    end)
end

-- =====================================================================
-- NOTIFICATION SYSTEM
-- =====================================================================
local NotificationManager = {}
NotificationManager.activeNotifications = {}

function NotificationManager:Show(window, config)
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
    
    local iconLabel = Create("TextLabel", {
        Parent = notif,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Font = FONT_BOLD,
        Text = icon,
        TextSize = 16,
        ZIndex = 1001,
    })
    
    local titleLabel = Create("TextLabel", {
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
    
    local contentLabel = Create("TextLabel", {
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
    
    -- Animate in
    Tween(notif, {Position = UDim2.new(1, -10, 0.85, -10), Size = UDim2.new(0, 300, 0, 50)}, 0.3, Enum.EasingStyle.Back)
    
    -- Remove after duration
    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 10, 0.85, -10), Size = UDim2.new(0, 300, 0, 0)}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.2)
        notif:Destroy()
    end)
    
    return notif
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
    self.Theme = config.Theme or Themes.Dark
    self.ConfigName = config.ConfigName or "default"
    self.Minimized = false
    
    -- Create ScreenGui
    self.SG = Create("ScreenGui", {
        Name = "NebulaUI_" .. self.Title,
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Main Frame
    self.Main = Create("Frame", {
        Parent = self.SG,
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -275, 0.5, -200),
        Size = UDim2.new(0, 550, 0, 400),
        ClipsDescendants = true,
        ZIndex = 1,
    })
    AddCorner(self.Main, 12)
    AddShadow(self.Main, 0.5, 10)
    
    -- Title Bar
    self.TitleBar = Create("Frame", {
        Parent = self.Main,
        BackgroundColor3 = self.Theme.Background2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 2,
    })
    AddCorner(self.TitleBar, 12)
    
    -- Title Accent
    Create("Frame", {
        Parent = self.TitleBar,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, 0),
        ZIndex = 3,
    })
    
    -- Title Label
    self.TitleLabel = Create("TextLabel", {
        Parent = self.TitleBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -120, 1, 0),
        Font = FONT_BOLD,
        Text = self.Title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    })
    
    -- Control Buttons
    local function createControlBtn(text, color, position, callback)
        local btn = Create("TextButton", {
            Parent = self.TitleBar,
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            Position = UDim2.new(1, position, 0, 8),
            Size = UDim2.new(0, 26, 0, 26),
            Font = FONT_BOLD,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            AutoButtonColor = false,
            ZIndex = 3,
        })
        AddCorner(btn, 6)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    createControlBtn("✕", Color3.fromRGB(200, 50, 50), -34, function()
        self:Destroy()
    end)
    
    createControlBtn("−", Color3.fromRGB(60, 60, 70), -66, function()
        self:Minimize()
    end)
    
    -- Make draggable
    MakeDraggable(self.Main, self.TitleBar)
    
    -- Tab Container (Sidebar)
    self.TabContainer = Create("Frame", {
        Parent = self.Main,
        BackgroundColor3 = self.Theme.Background2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 140, 1, -42),
        ZIndex = 1,
    })
    
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
    
    -- Content Area
    self.ContentArea = Create("Frame", {
        Parent = self.Main,
        BackgroundColor3 = self.Theme.Background,
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
    
    -- Storage
    self.Tabs = {}
    self.Pages = {}
    self.Config = ConfigManager:Load(self.ConfigName) or {}
    self.Events = {
        OnOpen = Event.new(),
        OnClose = Event.new(),
    }
    
    -- Animate in
    self.Main.Size = UDim2.new(0, 0, 0, 0)
    Tween(self.Main, {Size = UDim2.new(0, 550, 0, 400)}, 0.35, Enum.EasingStyle.Back)
    
    self.Events.OnOpen:Fire()
    
    return self
end

function Window:Destroy()
    self.Events.OnClose:Fire()
    Tween(self.Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    task.wait(0.15)
    self.SG:Destroy()
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    local targetSize = self.Minimized and UDim2.new(0, 550, 0, 42) or UDim2.new(0, 550, 0, 400)
    Tween(self.Main, {Size = targetSize}, 0.25)
end

function Window:SetTheme(theme)
    self.Theme = theme
end

function Window:Notify(config)
    NotificationManager:Show(self, config)
end

function Window:SaveConfig()
    ConfigManager:Save(self.ConfigName, self.Config)
end

function Window:LoadConfig()
    local data = ConfigManager:Load(self.ConfigName)
    if data then self.Config = data end
    return data
end

-- =====================================================================
-- TAB CLASS
-- =====================================================================
function Window:CreateTab(name, icon)
    icon = icon or ""
    
    local tabBtn = Create("TextButton", {
        Parent = self.TabContainer,
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 34),
        Font = FONT_BOLD,
        Text = icon .. "  " .. name,
        TextColor3 = self.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(tabBtn, 8)
    
    -- Tab Hover
    tabBtn.MouseEnter:Connect(function()
        if self.currentTab ~= name then
            Tween(tabBtn, {BackgroundColor3 = self.Theme.Surface2}, 0.1)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.currentTab ~= name then
            Tween(tabBtn, {BackgroundColor3 = self.Theme.Surface}, 0.1)
        end
    end)
    
    -- Page
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
    
    -- Click handler
    tabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(self.Pages) do p.Visible = false end
        for _, t in pairs(self.Tabs) do Tween(t, {BackgroundColor3 = self.Theme.Surface}, 0.15) end
        page.Visible = true
        Tween(tabBtn, {BackgroundColor3 = self.Theme.Accent}, 0.15)
        self.currentTab = name
    end)
    
    -- First tab
    if #self.Tabs == 0 then
        page.Visible = true
        Tween(tabBtn, {BackgroundColor3 = self.Theme.Accent}, 0.1)
        self.currentTab = name
    end
    
    table.insert(self.Tabs, tabBtn)
    table.insert(self.Pages, page)
    
    -- Return a Tab object
    local TabObj = {Window = self, Page = page, Name = name}
    return TabObj
end

-- =====================================================================
-- SECTION
-- =====================================================================
function Nebula.CreateSection(tab, config)
    config = config or {}
    local name = config.Name or ""
    local window = tab.Window
    local page = tab.Page
    
    local section = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Background2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, name ~= "" and 28 or 0),
        ZIndex = 1,
    })
    if name ~= "" then AddCorner(section, 8) end
    
    if name ~= "" then
        Create("Frame", {
            Parent = section,
            BackgroundColor3 = window.Theme.Accent,
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
            TextColor3 = window.Theme.Accent,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
        })
    end
    
    return {
        Section = section,
        Page = page,
        Window = window,
        -- Toggle
        CreateToggle = function(cfg) return Nebula.CreateToggle({Page = page, Window = window}, cfg) end,
        -- Button
        CreateButton = function(cfg) return Nebula.CreateButton({Page = page, Window = window}, cfg) end,
        -- Slider
        CreateSlider = function(cfg) return Nebula.CreateSlider({Page = page, Window = window}, cfg) end,
        -- Dropdown
        CreateDropdown = function(cfg) return Nebula.CreateDropdown({Page = page, Window = window}, cfg) end,
        -- Label
        CreateLabel = function(cfg) return Nebula.CreateLabel({Page = page, Window = window}, cfg) end,
        -- TextBox
        CreateTextBox = function(cfg) return Nebula.CreateTextBox({Page = page, Window = window}, cfg) end,
        -- Keybind
        CreateKeybind = function(cfg) return Nebula.CreateKeybind({Page = page, Window = window}, cfg) end,
        -- Checkbox
        CreateCheckbox = function(cfg) return Nebula.CreateCheckbox({Page = page, Window = window}, cfg) end,
        -- ColorPicker
        CreateColorPicker = function(cfg) return Nebula.CreateColorPicker({Page = page, Window = window}, cfg) end,
        -- ProgressBar
        CreateProgressBar = function(cfg) return Nebula.CreateProgressBar({Page = page, Window = window}, cfg) end,
    }
end

-- =====================================================================
-- TOGGLE
-- =====================================================================
function Nebula.CreateToggle(self, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local window = self.Window
    local page = self.Page
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = FONT_BOLD,
        Text = name,
        TextColor3 = window.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local toggleBg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = default and window.Theme.Success or Color3.fromRGB(60, 60, 70),
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
    local events = {OnChanged = Event.new()}
    
    local function update()
        if state then
            Tween(toggleBg, {BackgroundColor3 = window.Theme.Success}, 0.15)
            Tween(toggleDot, {Position = UDim2.new(1, -17, 0.5, -7)}, 0.15)
        else
            Tween(toggleBg, {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}, 0.15)
            Tween(toggleDot, {Position = UDim2.new(0, 3, 0.5, -7)}, 0.15)
        end
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            update()
            callback(state)
            events.OnChanged:Fire(state)
        end
    end)
    
    return {
        Set = function(v) state = v; update() end,
        Get = function() return state end,
        Value = state,
        Events = events,
    }
end

-- =====================================================================
-- BUTTON
-- =====================================================================
function Nebula.CreateButton(self, config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end
    local color = config.Color or self.Window.Theme.Accent
    local page = self.Page
    
    local btn = Create("TextButton", {
        Parent = page,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        Font = FONT_BOLD,
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 1,
    })
    AddCorner(btn, 8)
    
    -- Hover
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
        Tween(btn, {Size = UDim2.new(0.95, 0, 0, 32)}, 0.05)
        task.wait(0.05)
        Tween(btn, {Size = UDim2.new(1, 0, 0, 36)}, 0.05)
        callback()
    end)
    
    return {Button = btn}
end

-- =====================================================================
-- SLIDER
-- =====================================================================
function Nebula.CreateSlider(self, config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or 50
    local callback = config.Callback or function() end
    local suffix = config.Suffix or ""
    local window = self.Window
    local page = self.Page
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 52),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -24, 0, 16),
        Font = FONT_BOLD,
        Text = name .. ": " .. default .. suffix,
        TextColor3 = window.Theme.Text,
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
        BackgroundColor3 = window.Theme.Accent,
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
    
    local currentValue = default
    local events = {OnChanged = Event.new()}
    
    local function update(val)
        val = math.clamp(tonumber(val) or min, min, max)
        currentValue = val
        sliderFill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
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
                update(val)
                input.Text = tostring(val)
            end)
            UserInputService.InputEnded:Connect(function(ie)
                if ie.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
            end)
        end
    end)
    
    return {
        Set = function(v) update(v); input.Text = tostring(v) end,
        Get = function() return currentValue end,
        Value = currentValue,
        Events = events,
    }
end

-- =====================================================================
-- DROPDOWN
-- =====================================================================
function Nebula.CreateDropdown(self, config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {}
    local callback = config.Callback or function() end
    local default = config.Default or ""
    local window = self.Window
    local page = self.Page
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        ClipsDescendants = false,
        ZIndex = 5,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 140, 1, 0),
        Font = FONT_BOLD,
        Text = name,
        TextColor3 = window.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })
    
    local dropBtn = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -130, 0.5, -11),
        Size = UDim2.new(0, 118, 0, 22),
        Font = FONT_BOLD,
        Text = default ~= "" and default or "Select...",
        TextColor3 = window.Theme.Text,
        TextSize = 10,
        AutoButtonColor = false,
        ZIndex = 6,
    })
    AddCorner(dropBtn, 6)
    
    local dropList = Create("ScrollingFrame", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(20, 20, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -130, 0, 0),
        Size = UDim2.new(0, 118, 0, 0),
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 10,
    })
    AddCorner(dropList, 6)
    
    Create("UIListLayout", {
        Parent = dropList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 1),
    })
    
    local currentValue = default
    local events = {OnChanged = Event.new()}
    
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
                Font = FONT,
                Text = opt,
                TextColor3 = window.Theme.Text,
                TextSize = 10,
                AutoButtonColor = false,
                ZIndex = 11,
            })
            AddCorner(optBtn, 4)
            
            optBtn.MouseEnter:Connect(function()
                Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, 0.1)
            end)
            optBtn.MouseLeave:Connect(function()
                Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}, 0.1)
            end)
            
            optBtn.MouseButton1Click:Connect(function()
                currentValue = opt
                dropBtn.Text = opt
                dropList.Visible = false
                callback(opt)
                events.OnChanged:Fire(opt)
            end)
        end
    end
    
    refreshOptions(options)
    
    dropBtn.MouseButton1Click:Connect(function()
        dropList.Visible = not dropList.Visible
        if dropList.Visible then
            dropList.Position = UDim2.new(1, -130, 0, 38)
        end
    end)
    
    return {
        Set = function(v) currentValue = v; dropBtn.Text = v end,
        Get = function() return currentValue end,
        Refresh = refreshOptions,
        Value = currentValue,
        Events = events,
    }
end

-- =====================================================================
-- LABEL
-- =====================================================================
function Nebula.CreateLabel(self, config)
    config = config or {}
    local text = config.Text or ""
    local color = config.Color or self.Window.Theme.Text
    local size = config.Size or 11
    
    return Create("TextLabel", {
        Parent = self.Page,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18),
        Font = FONT,
        Text = text,
        TextColor3 = color,
        TextSize = size,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
    })
end

-- =====================================================================
-- TEXTBOX
-- =====================================================================
function Nebula.CreateTextBox(self, config)
    config = config or {}
    local placeholder = config.Placeholder or "Enter text..."
    local callback = config.Callback or function() end
    local default = config.Default or ""
    local window = self.Window
    local page = self.Page
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local input = Create("TextBox", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(20, 20, 28),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -10),
        Size = UDim2.new(1, -20, 0, 20),
        Font = FONT,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Color3.fromRGB(100, 100, 110),
        Text = default,
        TextColor3 = window.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 2,
    })
    AddCorner(input, 6)
    
    local events = {OnChanged = Event.new(), OnFocus = Event.new(), OnBlur = Event.new()}
    
    input:GetPropertyChangedSignal("Text"):Connect(function()
        events.OnChanged:Fire(input.Text)
    end)
    
    input.Focused:Connect(function() events.OnFocus:Fire() end)
    input.FocusLost:Connect(function(ep)
        events.OnBlur:Fire()
        if ep then callback(input.Text) end
    end)
    
    return {
        Set = function(v) input.Text = v end,
        Get = function() return input.Text end,
        Input = input,
        Events = events,
    }
end

-- =====================================================================
-- KEYBIND
-- =====================================================================
function Nebula.CreateKeybind(self, config)
    config = config or {}
    local name = config.Name or "Keybind"
    local default = config.Default or "None"
    local callback = config.Callback or function() end
    local window = self.Window
    local page = self.Page
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 200, 1, 0),
        Font = FONT_BOLD,
        Text = name,
        TextColor3 = window.Theme.Text,
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
        Font = FONT_BOLD,
        Text = "[" .. default .. "]",
        TextColor3 = window.Theme.Text,
        TextSize = 10,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(keyBtn, 6)
    
    local currentKey = default
    local binding = false
    local events = {OnChanged = Event.new()}
    
    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "[...]"
        
        local conn = UserInputService.InputBegan:Connect(function(input)
            if binding and input.KeyCode ~= Enum.KeyCode.Unknown then
                binding = false
                currentKey = input.KeyCode.Name
                keyBtn.Text = "[" .. currentKey .. "]"
                callback(currentKey)
                events.OnChanged:Fire(currentKey)
                conn:Disconnect()
            end
        end)
    end)
    
    return {
        Set = function(k) currentKey = k; keyBtn.Text = "[" .. k .. "]" end,
        Get = function() return currentKey end,
        Value = currentKey,
        Events = events,
    }
end

-- =====================================================================
-- CHECKBOX
-- =====================================================================
function Nebula.CreateCheckbox(self, config)
    config = config or {}
    local name = config.Name or "Checkbox"
    local default = config.Default or false
    local callback = config.Callback or function() end
    local window = self.Window
    local page = self.Page
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local checkbox = Create("TextButton", {
        Parent = frame,
        BackgroundColor3 = default and window.Theme.Accent or Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Font = FONT_BOLD,
        Text = default and "✓" or "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 2,
    })
    AddCorner(checkbox, 4)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 38, 0, 0),
        Size = UDim2.new(1, -50, 1, 0),
        Font = FONT,
        Text = name,
        TextColor3 = window.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local state = default
    local events = {OnChanged = Event.new()}
    
    local function update()
        checkbox.BackgroundColor3 = state and window.Theme.Accent or Color3.fromRGB(40, 40, 50)
        checkbox.Text = state and "✓" or ""
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            update()
            callback(state)
            events.OnChanged:Fire(state)
        end
    end)
    
    return {
        Set = function(v) state = v; update() end,
        Get = function() return state end,
        Value = state,
        Events = events,
    }
end

-- =====================================================================
-- COLOR PICKER
-- =====================================================================
function Nebula.CreateColorPicker(self, config)
    config = config or {}
    local name = config.Name or "Color"
    local default = config.Default or Color3.fromRGB(255, 0, 0)
    local callback = config.Callback or function() end
    local window = self.Window
    local page = self.Page
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(0, 140, 1, 0),
        Font = FONT_BOLD,
        Text = name,
        TextColor3 = window.Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local colorPreview = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -44, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = 2,
    })
    AddCorner(colorPreview, 10)
    
    local currentColor = default
    local events = {OnChanged = Event.new()}
    
    local popup = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(20, 20, 30),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 4),
        Size = UDim2.new(1, 0, 0, 0),
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 20,
    })
    AddCorner(popup, 8)
    
    -- Simple RGB sliders
    local colors = {"R", "G", "B"}
    local values = {math.floor(default.R * 255), math.floor(default.G * 255), math.floor(default.B * 255)}
    
    for i, c in pairs(colors) do
        local row = Create("Frame", {
            Parent = popup,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
        })
        
        local lbl = Create("TextLabel", {
            Parent = row,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 6, 0, 0),
            Size = UDim2.new(0, 16, 1, 0),
            Font = FONT_BOLD,
            Text = c,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            ZIndex = 21,
        })
        
        local bg = Create("Frame", {
            Parent = row,
            BackgroundColor3 = Color3.fromRGB(40, 40, 50),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 26, 0.5, -3),
            Size = UDim2.new(1, -70, 0, 6),
            ZIndex = 21,
        })
        
        local fill = Create("Frame", {
            Parent = bg,
            BackgroundColor3 = i == 1 and Color3.fromRGB(255,0,0) or i == 2 and Color3.fromRGB(0,255,0) or Color3.fromRGB(0,0,255),
            BorderSizePixel = 0,
            Size = UDim2.new(values[i] / 255, 0, 1, 0),
            ZIndex = 22,
        })
        
        local inp = Create("TextBox", {
            Parent = row,
            BackgroundColor3 = Color3.fromRGB(25, 25, 35),
            BorderSizePixel = 0,
            Position = UDim2.new(1, -40, 0.5, -8),
            Size = UDim2.new(0, 34, 0, 16),
            Font = Enum.Font.Code,
            Text = tostring(values[i]),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 9,
            ZIndex = 21,
        })
        
        bg.InputBegan:Connect(function(ib)
            if ib.UserInputType == Enum.UserInputType.MouseButton1 then
                local conn = RunService.RenderStepped:Connect(function()
                    local mouse = UserInputService:GetMouseLocation()
                    local perc = math.clamp((mouse.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
                    values[i] = math.floor(perc * 255)
                    fill.Size = UDim2.new(perc, 0, 1, 0)
                    inp.Text = tostring(values[i])
                    currentColor = Color3.fromRGB(values[1]/255, values[2]/255, values[3]/255)
                    colorPreview.BackgroundColor3 = currentColor
                    callback(currentColor)
                    events.OnChanged:Fire(currentColor)
                end)
                UserInputService.InputEnded:Connect(function(ie)
                    if ie.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
                end)
            end
        end)
        
        inp.FocusLost:Connect(function()
            values[i] = math.clamp(tonumber(inp.Text) or 0, 0, 255)
            fill.Size = UDim2.new(values[i] / 255, 0, 1, 0)
            currentColor = Color3.fromRGB(values[1]/255, values[2]/255, values[3]/255)
            colorPreview.BackgroundColor3 = currentColor
            callback(currentColor)
            events.OnChanged:Fire(currentColor)
        end)
    end
    
    colorPreview.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            popup.Visible = not popup.Visible
            if popup.Visible then
                Tween(popup, {Size = UDim2.new(1, 0, 0, 75)}, 0.2)
            else
                Tween(popup, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            end
        end
    end)
    
    return {
        Set = function(c) currentColor = c; colorPreview.BackgroundColor3 = c; callback(c); events.OnChanged:Fire(c) end,
        Get = function() return currentColor end,
        Value = currentColor,
        Events = events,
    }
end

-- =====================================================================
-- PROGRESS BAR
-- =====================================================================
function Nebula.CreateProgressBar(self, config)
    config = config or {}
    local name = config.Name or "Progress"
    local value = config.Value or 0
    local max = config.Max or 100
    local color = config.Color or self.Window.Theme.Accent
    local window = self.Window
    local page = self.Page
    
    local frame = Create("Frame", {
        Parent = page,
        BackgroundColor3 = window.Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 1,
    })
    AddCorner(frame, 8)
    
    local label = Create("TextLabel", {
        Parent = frame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 2),
        Size = UDim2.new(1, -24, 0, 14),
        Font = FONT_BOLD,
        Text = name .. ": " .. math.floor(value / max * 100) .. "%",
        TextColor3 = window.Theme.Text,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
    })
    
    local bg = Create("Frame", {
        Parent = frame,
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0, 20),
        Size = UDim2.new(1, -24, 0, 10),
        ZIndex = 2,
    })
    AddCorner(bg, 5)
    
    local fill = Create("Frame", {
        Parent = bg,
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(value / max, 0, 1, 0),
        ZIndex = 3,
    })
    AddCorner(fill, 5)
    
    local currentValue = value
    
    return {
        Set = function(v)
            currentValue = v
            Tween(fill, {Size = UDim2.new(v / max, 0, 1, 0)}, 0.3)
            label.Text = name .. ": " .. math.floor(v / max * 100) .. "%"
        end,
        Get = function() return currentValue end,
        Value = currentValue,
    }
end

-- =====================================================================
-- CREATE WINDOW FUNCTION
-- =====================================================================
function Nebula.CreateWindow(config)
    return Window.new(config)
end

return Nebula
