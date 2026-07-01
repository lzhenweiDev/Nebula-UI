--[[
	Modern Roblox UI Library
	Version: 1.0.0
	Author: UI Library System
	Description: A comprehensive, modular UI library for Roblox with modern design
	License: MIT
	
	Usage:
	local UILibrary = loadstring(game:HttpGet("URL"))()
	local Window = UILibrary:CreateWindow({Title = "My UI"})
]]--

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

-- Constants
local DEFAULT_THEME = {
	Name = "Dark",
	Background = Color3.fromRGB(30, 30, 30),
	SecondaryBackground = Color3.fromRGB(40, 40, 40),
	TertiaryBackground = Color3.fromRGB(50, 50, 50),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(180, 180, 180),
	Accent = Color3.fromRGB(0, 120, 255),
	AccentHover = Color3.fromRGB(0, 100, 220),
	Border = Color3.fromRGB(60, 60, 60),
	Shadow = Color3.fromRGB(0, 0, 0),
	Success = Color3.fromRGB(0, 200, 80),
	Warning = Color3.fromRGB(255, 180, 0),
	Error = Color3.fromRGB(255, 60, 60),
	Transparency = 0.95,
	BlurEnabled = false,
	Font = Enum.Font.Gotham,
	Rounding = 8,
	StrokeThickness = 0,
	AcrylicStrength = 0
}

local LIGHT_THEME = {
	Name = "Light",
	Background = Color3.fromRGB(240, 240, 240),
	SecondaryBackground = Color3.fromRGB(255, 255, 255),
	TertiaryBackground = Color3.fromRGB(230, 230, 230),
	Text = Color3.fromRGB(30, 30, 30),
	SubText = Color3.fromRGB(100, 100, 100),
	Accent = Color3.fromRGB(0, 120, 255),
	AccentHover = Color3.fromRGB(0, 100, 220),
	Border = Color3.fromRGB(200, 200, 200),
	Shadow = Color3.fromRGB(0, 0, 0),
	Success = Color3.fromRGB(0, 180, 70),
	Warning = Color3.fromRGB(240, 160, 0),
	Error = Color3.fromRGB(230, 50, 50),
	Transparency = 0.98,
	BlurEnabled = false,
	Font = Enum.Font.Gotham,
	Rounding = 8,
	StrokeThickness = 0,
	AcrylicStrength = 0
}

-- Utility Functions
local Utility = {}

function Utility:CreateInstance(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		instance[prop] = value
	end
	return instance
end

function Utility:Tween(instance, properties, duration, easingStyle, easingDirection)
	easingStyle = easingStyle or Enum.EasingStyle.Quad
	easingDirection = easingDirection or Enum.EasingDirection.Out
	
	local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle, easingDirection)
	local tween = TweenService:Create(instance, tweenInfo, properties)
	tween:Play()
	return tween
end

function Utility:DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = Utility:DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

function Utility:MergeTables(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" and type(t1[k]) == "table" then
			t1[k] = Utility:MergeTables(t1[k], v)
		else
			t1[k] = v
		end
	end
	return t1
end

-- Event System
local Event = {}
Event.__index = Event

function Event.new()
	local self = setmetatable({}, Event)
	self._listeners = {}
	self._onceListeners = {}
	return self
end

function Event:Connect(callback)
	table.insert(self._listeners, callback)
	local connection = {
		Disconnect = function()
			for i, listener in ipairs(self._listeners) do
				if listener == callback then
					table.remove(self._listeners, i)
					break
				end
			end
		end
	}
	return connection
end

function Event:Once(callback)
	table.insert(self._onceListeners, callback)
end

function Event:Fire(...)
	for _, listener in ipairs(self._listeners) do
		coroutine.wrap(listener)(...)
	end
	
	for i = #self._onceListeners, 1, -1 do
		coroutine.wrap(self._onceListeners[i])(...)
		table.remove(self._onceListeners, i)
	end
end

function Event:DisconnectAll()
	self._listeners = {}
	self._onceListeners = {}
end

-- Config System
local ConfigSystem = {}
ConfigSystem.__index = ConfigSystem

function ConfigSystem.new()
	local self = setmetatable({}, ConfigSystem)
	self._data = {}
	self._fileName = "ui_config.json"
	return self
end

function ConfigSystem:SetValue(key, value)
	self._data[key] = value
end

function ConfigSystem:GetValue(key)
	return self._data[key]
end

function ConfigSystem:SaveConfig(fileName)
	fileName = fileName or self._fileName
	local json = HttpService:JSONEncode(self._data)
	if writefile then
		writefile(fileName, json)
	else
		warn("writefile is not available")
	end
end

function ConfigSystem:LoadConfig(fileName)
	fileName = fileName or self._fileName
	if readfile and isfile and isfile(fileName) then
		local success, data = pcall(function()
			return HttpService:JSONDecode(readfile(fileName))
		end)
		if success and data then
			self._data = data
			return true
		end
	end
	return false
end

function ConfigSystem:DeleteConfig(fileName)
	fileName = fileName or self._fileName
	if isfile and isfile(fileName) then
		delfile(fileName)
	end
end

function ConfigSystem:ExportConfig()
	return HttpService:JSONEncode(self._data)
end

function ConfigSystem:ImportConfig(jsonData)
	local success, data = pcall(function()
		return HttpService:JSONDecode(jsonData)
	end)
	if success and data then
		self._data = data
		return true
	end
	return false
end

-- Theme System
local ThemeSystem = {}
ThemeSystem.__index = ThemeSystem

function ThemeSystem.new(defaultTheme)
	local self = setmetatable({}, ThemeSystem)
	self._themes = {
		Dark = Utility:DeepCopy(DEFAULT_THEME),
		Light = Utility:DeepCopy(LIGHT_THEME)
	}
	self._currentTheme = Utility:DeepCopy(defaultTheme or DEFAULT_THEME)
	self.OnThemeChanged = Event.new()
	return self
end

function ThemeSystem:GetCurrentTheme()
	return self._currentTheme
end

function ThemeSystem:SetTheme(themeName)
	if self._themes[themeName] then
		self._currentTheme = Utility:DeepCopy(self._themes[themeName])
		self.OnThemeChanged:Fire(self._currentTheme)
	end
end

function ThemeSystem:CreateCustomTheme(themeName, themeConfig)
	self._themes[themeName] = Utility:DeepCopy(themeConfig)
end

function ThemeSystem:ApplyCustomTheme(themeConfig)
	self._currentTheme = Utility:DeepCopy(themeConfig)
	self.OnThemeChanged:Fire(self._currentTheme)
end

-- Animation System
local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

function AnimationSystem.new()
	local self = setmetatable({}, AnimationSystem)
	self._animations = {}
	return self
end

function AnimationSystem:CreateHoverAnimation(guiObject)
	local originalSize = guiObject.Size
	local originalColor = guiObject.BackgroundColor3
	
	local hoverConnection = guiObject.MouseEnter:Connect(function()
		Utility:Tween(guiObject, {
			BackgroundColor3 = guiObject.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.1)
		}, 0.2)
	end)
	
	local leaveConnection = guiObject.MouseLeave:Connect(function()
		Utility:Tween(guiObject, {
			BackgroundColor3 = originalColor
		}, 0.2)
	end)
	
	table.insert(self._animations, hoverConnection)
	table.insert(self._animations, leaveConnection)
end

function AnimationSystem:CreateRippleEffect(button)
	local rippleConnection = button.MouseButton1Click:Connect(function()
		local mousePos = UserInputService:GetMouseLocation()
		local ripple = Utility:CreateInstance("Frame", {
			Parent = button,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.7,
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0, mousePos.X - button.AbsolutePosition.X, 0, mousePos.Y - button.AbsolutePosition.Y),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 10
		})
		Utility:CreateInstance("UICorner", {
			Parent = ripple,
			CornerRadius = UDim.new(1, 0)
		})
		
		local targetSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
		Utility:Tween(ripple, {
			Size = UDim2.new(0, targetSize, 0, targetSize),
			BackgroundTransparency = 1
		}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		game.Debris:AddItem(ripple, 0.5)
	end)
	
	table.insert(self._animations, rippleConnection)
end

function AnimationSystem:Cleanup()
	for _, connection in ipairs(self._animations) do
		connection:Disconnect()
	end
	self._animations = {}
end

-- Component Base Class
local Component = {}
Component.__index = Component

function Component.new(themeSystem, animationSystem)
	local self = setmetatable({}, Component)
	self._themeSystem = themeSystem
	self._animationSystem = animationSystem
	self._events = {
		OnClick = Event.new(),
		OnChanged = Event.new(),
		OnHover = Event.new(),
		OnFocus = Event.new(),
		OnBlur = Event.new()
	}
	self._connections = {}
	self._instances = {}
	return self
end

function Component:AddConnection(connection)
	table.insert(self._connections, connection)
end

function Component:AddInstance(instance)
	table.insert(self._instances, instance)
end

function Component:ApplyTheme(theme)
	-- Override in subclasses
end

function Component:Destroy()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	for _, instance in ipairs(self._instances) do
		instance:Destroy()
	end
	self._connections = {}
	self._instances = {}
end

-- Notification System
local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(parent)
	local self = setmetatable({}, NotificationSystem)
	self._parent = parent
	self._notifications = {}
	self._container = nil
	return self
end

function NotificationSystem:CreateContainer()
	if not self._container then
		self._container = Utility:CreateInstance("Frame", {
			Parent = self._parent,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 300, 1, 0),
			Position = UDim2.new(1, -320, 0, 20),
			ZIndex = 1000
		})
		
		local uiListLayout = Utility:CreateInstance("UIListLayout", {
			Parent = self._container,
			Padding = UDim.new(0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	end
end

function NotificationSystem:Send(options)
	self:CreateContainer()
	
	local notification = Utility:CreateInstance("Frame", {
		Parent = self._container,
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		ZIndex = 1000
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = notification,
		CornerRadius = UDim.new(0, 8)
	})
	
	Utility:CreateInstance("UIStroke", {
		Parent = notification,
		Color = Color3.fromRGB(60, 60, 60),
		Thickness = 1
	})
	
	local titleLabel = Utility:CreateInstance("TextLabel", {
		Parent = notification,
		BackgroundTransparency = 1,
		Text = options.Title or "Notification",
		TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 10),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local messageLabel = Utility:CreateInstance("TextLabel", {
		Parent = notification,
		BackgroundTransparency = 1,
		Text = options.Message or "",
		TextColor3 = Color3.fromRGB(200, 200, 200),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		Size = UDim2.new(1, -20, 0, 0),
		Position = UDim2.new(0, 10, 0, 35),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.Y
	})
	
	local duration = options.Duration or 3
	
	-- Entrance animation
	notification.Size = UDim2.new(1, 0, 0, 0)
	notification.BackgroundTransparency = 1
	Utility:Tween(notification, {
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 0, 0)
	}, 0.3)
	
	-- Exit after duration
	delay(duration, function()
		Utility:Tween(notification, {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}, 0.3)
		game.Debris:AddItem(notification, 0.3)
	end)
	
	return notification
end

-- Create individual UI elements
local Elements = {}

function Elements:CreateButton(parent, options, themeSystem, animationSystem)
	local component = Component.new(themeSystem, animationSystem)
	local theme = themeSystem:GetCurrentTheme()
	
	local button = Utility:CreateInstance("TextButton", {
		Parent = parent,
		BackgroundColor3 = theme.Accent,
		Text = options.Name or "Button",
		TextColor3 = theme.Text,
		Font = theme.Font,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, 36),
		AutoButtonColor = false
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = button,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	if theme.StrokeThickness > 0 then
		Utility:CreateInstance("UIStroke", {
			Parent = button,
			Color = theme.Border,
			Thickness = theme.StrokeThickness
		})
	end
	
	component:AddInstance(button)
	
	animationSystem:CreateHoverAnimation(button)
	animationSystem:CreateRippleEffect(button)
	
	local clickConnection = button.MouseButton1Click:Connect(function()
		if options.Callback then
			options.Callback()
		end
		component._events.OnClick:Fire()
	end)
	component:AddConnection(clickConnection)
	
	local themeConnection = themeSystem.OnThemeChanged:Connect(function(newTheme)
		button.BackgroundColor3 = newTheme.Accent
		button.TextColor3 = newTheme.Text
		button.Font = newTheme.Font
		if button:FindFirstChild("UICorner") then
			button.UICorner.CornerRadius = UDim.new(0, newTheme.Rounding)
		end
		if newTheme.StrokeThickness > 0 and not button:FindFirstChild("UIStroke") then
			Utility:CreateInstance("UIStroke", {
				Parent = button,
				Color = newTheme.Border,
				Thickness = newTheme.StrokeThickness
			})
		end
	end)
	component:AddConnection(themeConnection)
	
	return component
end

function Elements:CreateToggle(parent, options, themeSystem, animationSystem)
	local component = Component.new(themeSystem, animationSystem)
	local theme = themeSystem:GetCurrentTheme()
	local toggled = options.Default or false
	
	local container = Utility:CreateInstance("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40)
	})
	
	local label = Utility:CreateInstance("TextLabel", {
		Parent = container,
		BackgroundTransparency = 1,
		Text = options.Name or "Toggle",
		TextColor3 = theme.Text,
		Font = theme.Font,
		TextSize = 14,
		Size = UDim2.new(0.7, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local toggleFrame = Utility:CreateInstance("Frame", {
		Parent = container,
		BackgroundColor3 = toggled and theme.Accent or theme.TertiaryBackground,
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(1, -40, 0.5, -10),
		ZIndex = 2
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = toggleFrame,
		CornerRadius = UDim.new(1, 0)
	})
	
	local toggleKnob = Utility:CreateInstance("Frame", {
		Parent = toggleFrame,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, toggled and 20 or 2, 0.5, -8),
		ZIndex = 3
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = toggleKnob,
		CornerRadius = UDim.new(1, 0)
	})
	
	local toggleButton = Utility:CreateInstance("TextButton", {
		Parent = container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		ZIndex = 4
	})
	
	local function updateToggle()
		local targetColor = toggled and theme.Accent or theme.TertiaryBackground
		local targetPos = toggled and 20 or 2
		
		Utility:Tween(toggleFrame, { BackgroundColor3 = targetColor }, 0.2)
		Utility:Tween(toggleKnob, { Position = UDim2.new(0, targetPos, 0.5, -8) }, 0.2)
	end
	
	component:AddInstance(container)
	
	local clickConnection = toggleButton.MouseButton1Click:Connect(function()
		toggled = not toggled
		updateToggle()
		if options.Callback then
			options.Callback(toggled)
		end
		component._events.OnChanged:Fire(toggled)
	end)
	component:AddConnection(clickConnection)
	
	local themeConnection = themeSystem.OnThemeChanged:Connect(function(newTheme)
		theme = newTheme
		label.TextColor3 = theme.Text
		label.Font = theme.Font
		updateToggle()
	end)
	component:AddConnection(themeConnection)
	
	-- Methoden
	local api = {
		Set = function(self, value)
			toggled = value
			updateToggle()
		end,
		Get = function(self)
			return toggled
		end,
		Destroy = function(self)
			component:Destroy()
		end
	}
	
	return setmetatable(api, { __index = component })
end

function Elements:CreateSlider(parent, options, themeSystem, animationSystem)
	local component = Component.new(themeSystem, animationSystem)
	local theme = themeSystem:GetCurrentTheme()
	local min = options.Min or 0
	local max = options.Max or 100
	local current = options.Default or min
	local step = options.Step or 1
	
	local container = Utility:CreateInstance("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 50)
	})
	
	local label = Utility:CreateInstance("TextLabel", {
		Parent = container,
		BackgroundTransparency = 1,
		Text = (options.Name or "Slider") .. ": " .. current,
		TextColor3 = theme.Text,
		Font = theme.Font,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local sliderBg = Utility:CreateInstance("Frame", {
		Parent = container,
		BackgroundColor3 = theme.TertiaryBackground,
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 1, -12)
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = sliderBg,
		CornerRadius = UDim.new(1, 0)
	})
	
	local fill = Utility:CreateInstance("Frame", {
		Parent = sliderBg,
		BackgroundColor3 = theme.Accent,
		Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = fill,
		CornerRadius = UDim.new(1, 0)
	})
	
	local knob = Utility:CreateInstance("Frame", {
		Parent = sliderBg,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(0, 14, 0, 14),
		Position = UDim2.new((current - min) / (max - min), -7, 0.5, -7),
		ZIndex = 2
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = knob,
		CornerRadius = UDim.new(1, 0)
	})
	
	local slideButton = Utility:CreateInstance("TextButton", {
		Parent = container,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = ""
	})
	
	local dragging = false
	
	local function updateFromPosition(xPos)
		local relativeX = math.clamp((xPos - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		local rawValue = min + (max - min) * relativeX
		current = math.floor(rawValue / step + 0.5) * step
		current = math.clamp(current, min, max)
		
		Utility:Tween(fill, { Size = UDim2.new((current - min) / (max - min), 0, 1, 0) }, 0.1)
		Utility:Tween(knob, { Position = UDim2.new((current - min) / (max - min), -7, 0.5, -7) }, 0.1)
		
		label.Text = (options.Name or "Slider") .. ": " .. current
		
		if options.Callback then
			options.Callback(current)
		end
		component._events.OnChanged:Fire(current)
	end
	
	local inputBeganConnection = slideButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateFromPosition(input.Position.X)
		end
	end)
	component:AddConnection(inputBeganConnection)
	
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateFromPosition(input.Position.X)
		end
	end)
	component:AddConnection(inputChangedConnection)
	
	local inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	component:AddConnection(inputEndedConnection)
	
	component:AddInstance(container)
	
	local themeConnection = themeSystem.OnThemeChanged:Connect(function(newTheme)
		theme = newTheme
		label.TextColor3 = theme.Text
		label.Font = theme.Font
		sliderBg.BackgroundColor3 = theme.TertiaryBackground
		fill.BackgroundColor3 = theme.Accent
	end)
	component:AddConnection(themeConnection)
	
	local api = {
		Set = function(self, value)
			current = math.clamp(value, min, max)
			fill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
			knob.Position = UDim2.new((current - min) / (max - min), -7, 0.5, -7)
			label.Text = (options.Name or "Slider") .. ": " .. current
		end,
		Get = function(self)
			return current
		end,
		Destroy = function(self)
			component:Destroy()
		end
	}
	
	return setmetatable(api, { __index = component })
end

function Elements:CreateTextbox(parent, options, themeSystem, animationSystem)
	local component = Component.new(themeSystem, animationSystem)
	local theme = themeSystem:GetCurrentTheme()
	
	local container = Utility:CreateInstance("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 60)
	})
	
	local label = Utility:CreateInstance("TextLabel", {
		Parent = container,
		BackgroundTransparency = 1,
		Text = options.Name or "Textbox",
		TextColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local inputBg = Utility:CreateInstance("Frame", {
		Parent = container,
		BackgroundColor3 = theme.SecondaryBackground,
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 24)
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = inputBg,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	if theme.StrokeThickness > 0 then
		Utility:CreateInstance("UIStroke", {
			Parent = inputBg,
			Color = theme.Border,
			Thickness = theme.StrokeThickness
		})
	end
	
	local input = Utility:CreateInstance("TextBox", {
		Parent = inputBg,
		BackgroundTransparency = 1,
		Text = options.Default or "",
		PlaceholderText = options.Placeholder or "Enter text...",
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 14,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false
	})
	
	component:AddInstance(container)
	
	local focusConnection = input.Focused:Connect(function()
		component._events.OnFocus:Fire()
		Utility:Tween(inputBg, { BackgroundColor3 = theme.TertiaryBackground }, 0.2)
	end)
	component:AddConnection(focusConnection)
	
	local focusLostConnection = input.FocusLost:Connect(function(enterPressed)
		component._events.OnBlur:Fire()
		Utility:Tween(inputBg, { BackgroundColor3 = theme.SecondaryBackground }, 0.2)
		if options.Callback then
			options.Callback(input.Text, enterPressed)
		end
		component._events.OnChanged:Fire(input.Text)
	end)
	component:AddConnection(focusLostConnection)
	
	local themeConnection = themeSystem.OnThemeChanged:Connect(function(newTheme)
		theme = newTheme
		label.TextColor3 = theme.SubText
		label.Font = theme.Font
		inputBg.BackgroundColor3 = theme.SecondaryBackground
		input.TextColor3 = theme.Text
		input.PlaceholderColor3 = theme.SubText
		input.Font = theme.Font
		if inputBg:FindFirstChild("UICorner") then
			inputBg.UICorner.CornerRadius = UDim.new(0, theme.Rounding)
		end
	end)
	component:AddConnection(themeConnection)
	
	local api = {
		Set = function(self, value)
			input.Text = value or ""
		end,
		Get = function(self)
			return input.Text
		end,
		Destroy = function(self)
			component:Destroy()
		end
	}
	
	return setmetatable(api, { __index = component })
end

function Elements:CreateDropdown(parent, options, themeSystem, animationSystem)
	local component = Component.new(themeSystem, animationSystem)
	local theme = themeSystem:GetCurrentTheme()
	local options_list = options.Options or {}
	local selected = options.Default or (options_list[1] or "")
	local isOpen = false
	
	local container = Utility:CreateInstance("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		ClipsDescendants = false
	})
	
	local label = Utility:CreateInstance("TextLabel", {
		Parent = container,
		BackgroundTransparency = 1,
		Text = options.Name or "Dropdown",
		TextColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local dropdownButton = Utility:CreateInstance("TextButton", {
		Parent = container,
		BackgroundColor3 = theme.SecondaryBackground,
		Text = selected,
		TextColor3 = theme.Text,
		Font = theme.Font,
		TextSize = 14,
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 24),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = dropdownButton,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	local dropIcon = Utility:CreateInstance("TextLabel", {
		Parent = dropdownButton,
		BackgroundTransparency = 1,
		Text = "▼",
		TextColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 12,
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -30, 0, 0)
	})
	
	local optionsFrame = Utility:CreateInstance("Frame", {
		Parent = container,
		BackgroundColor3 = theme.SecondaryBackground,
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 1, 0),
		ClipsDescendants = true,
		ZIndex = 10
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = optionsFrame,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	if theme.StrokeThickness > 0 then
		Utility:CreateInstance("UIStroke", {
			Parent = optionsFrame,
			Color = theme.Border,
			Thickness = theme.StrokeThickness
		})
	end
	
	local scrollingFrame = Utility:CreateInstance("ScrollingFrame", {
		Parent = optionsFrame,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ZIndex = 10
	})
	
	local uiListLayout = Utility:CreateInstance("UIListLayout", {
		Parent = scrollingFrame,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	local optionFrames = {}
	
	local function updateOptions()
		for _, optionFrame in ipairs(optionFrames) do
			optionFrame:Destroy()
		end
		optionFrames = {}
		
		for i, option in ipairs(options_list) do
			local optionButton = Utility:CreateInstance("TextButton", {
				Parent = scrollingFrame,
				BackgroundColor3 = theme.SecondaryBackground,
				Text = option,
				TextColor3 = theme.Text,
				Font = theme.Font,
				TextSize = 14,
				Size = UDim2.new(1, 0, 0, 30),
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 10
			})
			
			local optionClickConnection = optionButton.MouseButton1Click:Connect(function()
				selected = option
				dropdownButton.Text = option
				CloseDropdown()
				if options.Callback then
					options.Callback(option)
				end
				component._events.OnChanged:Fire(option)
			end)
			component:AddConnection(optionClickConnection)
			
			table.insert(optionFrames, optionButton)
		end
		
		scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #options_list * 32)
	end
	
	function CloseDropdown()
		isOpen = false
		Utility:Tween(optionsFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
		dropIcon.Text = "▼"
	end
	
	function OpenDropdown()
		isOpen = true
		local maxHeight = math.min(#options_list * 32, 150)
		Utility:Tween(optionsFrame, { Size = UDim2.new(1, 0, 0, maxHeight) }, 0.2)
		dropIcon.Text = "▲"
	end
	
	local clickConnection = dropdownButton.MouseButton1Click:Connect(function()
		if isOpen then
			CloseDropdown()
		else
			OpenDropdown()
		end
	end)
	component:AddConnection(clickConnection)
	
	updateOptions()
	component:AddInstance(container)
	
	local themeConnection = themeSystem.OnThemeChanged:Connect(function(newTheme)
		theme = newTheme
		label.TextColor3 = theme.SubText
		label.Font = theme.Font
		dropdownButton.BackgroundColor3 = theme.SecondaryBackground
		dropdownButton.TextColor3 = theme.Text
		dropdownButton.Font = theme.Font
		dropIcon.TextColor3 = theme.SubText
		optionsFrame.BackgroundColor3 = theme.SecondaryBackground
		updateOptions()
	end)
	component:AddConnection(themeConnection)
	
	local api = {
		Set = function(self, value)
			selected = value
			dropdownButton.Text = value
		end,
		Get = function(self)
			return selected
		end,
		SetOptions = function(self, newOptions)
			options_list = newOptions
			updateOptions()
		end,
		Destroy = function(self)
			component:Destroy()
		end
	}
	
	return setmetatable(api, { __index = component })
end

function Elements:CreateLabel(parent, options, themeSystem, animationSystem)
	local component = Component.new(themeSystem, animationSystem)
	local theme = themeSystem:GetCurrentTheme()
	
	local label = Utility:CreateInstance("TextLabel", {
		Parent = parent,
		BackgroundTransparency = 1,
		Text = options.Text or "Label",
		TextColor3 = theme.Text,
		Font = theme.Font,
		TextSize = options.Size or 14,
		Size = UDim2.new(1, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = options.Wrapped or false
	})
	
	component:AddInstance(label)
	
	local themeConnection = themeSystem.OnThemeChanged:Connect(function(newTheme)
		label.TextColor3 = newTheme.Text
		label.Font = newTheme.Font
	end)
	component:AddConnection(themeConnection)
	
	local api = {
		SetText = function(self, text)
			label.Text = text
		end,
		GetText = function(self)
			return label.Text
		end,
		Destroy = function(self)
			component:Destroy()
		end
	}
	
	return setmetatable(api, { __index = component })
end

function Elements:CreateColorPicker(parent, options, themeSystem, animationSystem)
	local component = Component.new(themeSystem, animationSystem)
	local theme = themeSystem:GetCurrentTheme()
	local currentColor = options.Default or Color3.new(1, 0, 0)
	local isOpen = false
	
	local container = Utility:CreateInstance("Frame", {
		Parent = parent,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 40),
		ClipsDescendants = false
	})
	
	local label = Utility:CreateInstance("TextLabel", {
		Parent = container,
		BackgroundTransparency = 1,
		Text = options.Name or "Color Picker",
		TextColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 12,
		Size = UDim2.new(1, 0, 0, 20),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local colorButton = Utility:CreateInstance("TextButton", {
		Parent = container,
		BackgroundColor3 = currentColor,
		Text = "",
		Size = UDim2.new(1, 0, 0, 36),
		Position = UDim2.new(0, 0, 0, 24)
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = colorButton,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	if theme.StrokeThickness > 0 then
		Utility:CreateInstance("UIStroke", {
			Parent = colorButton,
			Color = theme.Border,
			Thickness = theme.StrokeThickness
		})
	end
	
	local pickerFrame = Utility:CreateInstance("Frame", {
		Parent = container,
		BackgroundColor3 = theme.SecondaryBackground,
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 1, 0),
		ClipsDescendants = true,
		ZIndex = 10
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = pickerFrame,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	-- Hue, Saturation, Value sliders
	local hueSlider = Utility:CreateInstance("Frame", {
		Parent = pickerFrame,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, -20, 0, 15),
		Position = UDim2.new(0, 10, 0, 10)
	})
	
	local satSlider = Utility:CreateInstance("Frame", {
		Parent = pickerFrame,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, -20, 0, 15),
		Position = UDim2.new(0, 10, 0, 35)
	})
	
	local valSlider = Utility:CreateInstance("Frame", {
		Parent = pickerFrame,
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, -20, 0, 15),
		Position = UDim2.new(0, 10, 0, 60)
	})
	
	function OpenPicker()
		isOpen = true
		Utility:Tween(pickerFrame, { Size = UDim2.new(1, 0, 0, 90) }, 0.2)
	end
	
	function ClosePicker()
		isOpen = false
		Utility:Tween(pickerFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2)
	end
	
	local clickConnection = colorButton.MouseButton1Click:Connect(function()
		if isOpen then
			ClosePicker()
		else
			OpenPicker()
		end
	end)
	component:AddConnection(clickConnection)
	
	component:AddInstance(container)
	
	-- Simplified implementation - in a full version, you'd add actual color picker functionality
	
	local api = {
		Set = function(self, color)
			currentColor = color
			colorButton.BackgroundColor3 = color
			if options.Callback then
				options.Callback(color)
			end
		end,
		Get = function(self)
			return currentColor
		end,
		Destroy = function(self)
			component:Destroy()
		end
	}
	
	return setmetatable(api, { __index = component })
end

-- Window System
local Window = {}
Window.__index = Window

function Window.new(uiLibrary, options)
	local self = setmetatable({}, Window)
	self._uiLibrary = uiLibrary
	self._options = options
	self._themeSystem = uiLibrary._themeSystem
	self._animationSystem = uiLibrary._animationSystem
	self._configSystem = uiLibrary._configSystem
	self._notificationSystem = uiLibrary._notificationSystem
	self._tabs = {}
	self._currentTab = nil
	self._destroyed = false
	self._minimized = false
	self._dragging = false
	self._dragStart = nil
	self._startPos = nil
	
	self:_build(options)
	return self
end

function Window:_build(options)
	local theme = self._themeSystem:GetCurrentTheme()
	
	-- Main container
	self._gui = Utility:CreateInstance("ScreenGui", {
		Parent = CoreGui,
		Name = options.Title or "UI Window",
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	})
	
	-- Window background with blur effect
	self._windowFrame = Utility:CreateInstance("Frame", {
		Parent = self._gui,
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 1 - theme.Transparency,
		Size = UDim2.new(0, 600, 0, 400),
		Position = UDim2.new(0.5, -300, 0.5, -200),
		ClipsDescendants = true
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = self._windowFrame,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	if theme.StrokeThickness > 0 then
		Utility:CreateInstance("UIStroke", {
			Parent = self._windowFrame,
			Color = theme.Border,
			Thickness = theme.StrokeThickness
		})
	end
	
	-- Shadow
	local shadow = Utility:CreateInstance("Frame", {
		Parent = self._windowFrame,
		BackgroundColor3 = theme.Shadow,
		BackgroundTransparency = 0.5,
		Size = UDim2.new(1, 20, 1, 20),
		Position = UDim2.new(0, -10, 0, -10),
		ZIndex = -1
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = shadow,
		CornerRadius = UDim.new(0, theme.Rounding + 10)
	})
	
	-- Title bar
	self._titleBar = Utility:CreateInstance("Frame", {
		Parent = self._windowFrame,
		BackgroundColor3 = theme.SecondaryBackground,
		Size = UDim2.new(1, 0, 0, 40)
	})
	
	local titleLabel = Utility:CreateInstance("TextLabel", {
		Parent = self._titleBar,
		BackgroundTransparency = 1,
		Text = options.Title or "Window",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		Size = UDim2.new(0.8, 0, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	local subtitleLabel = Utility:CreateInstance("TextLabel", {
		Parent = self._titleBar,
		BackgroundTransparency = 1,
		Text = options.Subtitle or "",
		TextColor3 = theme.SubText,
		Font = theme.Font,
		TextSize = 11,
		Size = UDim2.new(0.8, 0, 0.5, 0),
		Position = UDim2.new(0, 10, 0.5, 0),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Minimize button
	local minimizeBtn = Utility:CreateInstance("TextButton", {
		Parent = self._titleBar,
		BackgroundColor3 = theme.TertiaryBackground,
		Text = "-",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -70, 0.5, -15)
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = minimizeBtn,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	-- Close button
	local closeBtn = Utility:CreateInstance("TextButton", {
		Parent = self._titleBar,
		BackgroundColor3 = theme.Error,
		Text = "×",
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0.5, -15)
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = closeBtn,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	-- Tab container
	self._tabContainer = Utility:CreateInstance("Frame", {
		Parent = self._windowFrame,
		BackgroundColor3 = theme.SecondaryBackground,
		Size = UDim2.new(0, 150, 1, -40),
		Position = UDim2.new(0, 0, 0, 40)
	})
	
	self._tabList = Utility:CreateInstance("UIListLayout", {
		Parent = self._tabContainer,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	-- Content area
	self._contentArea = Utility:CreateInstance("Frame", {
		Parent = self._windowFrame,
		BackgroundColor3 = theme.Background,
		Size = UDim2.new(1, -150, 1, -40),
		Position = UDim2.new(0, 150, 0, 40)
	})
	
	self._contentPadding = Utility:CreateInstance("UIPadding", {
		Parent = self._contentArea,
		PaddingLeft = UDim.new(0, 15),
		PaddingRight = UDim.new(0, 15),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10)
	})
	
	-- Section container
	self._sectionContainer = Utility:CreateInstance("ScrollingFrame", {
		Parent = self._contentArea,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = theme.Accent
	})
	
	self._sectionList = Utility:CreateInstance("UIListLayout", {
		Parent = self._sectionContainer,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	-- Make window draggable
	local dragConnection = self._titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self._dragging = true
			self._dragStart = input.Position
			self._startPos = self._windowFrame.Position
		end
	end)
	
	local moveConnection = UserInputService.InputChanged:Connect(function(input)
		if self._dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - self._dragStart
			self._windowFrame.Position = UDim2.new(
				self._startPos.X.Scale,
				self._startPos.X.Offset + delta.X,
				self._startPos.Y.Scale,
				self._startPos.Y.Offset + delta.Y
			)
		end
	end)
	
	local endConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self._dragging = false
		end
	end)
	
	-- Button actions
	minimizeBtn.MouseButton1Click:Connect(function()
		self:Minimize()
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end)
	
	-- Theme connection
	self._themeConnection = self._themeSystem.OnThemeChanged:Connect(function(newTheme)
		self._windowFrame.BackgroundColor3 = newTheme.Background
		self._titleBar.BackgroundColor3 = newTheme.SecondaryBackground
		self._tabContainer.BackgroundColor3 = newTheme.SecondaryBackground
		self._contentArea.BackgroundColor3 = newTheme.Background
		titleLabel.TextColor3 = newTheme.Text
		subtitleLabel.TextColor3 = newTheme.SubText
		if self._sectionContainer then
			self._sectionContainer.ScrollBarImageColor3 = newTheme.Accent
		end
	end)
	
	-- Add close connection to cleanup
	self._connections = {
		dragConnection,
		moveConnection,
		endConnection,
		self._themeConnection
	}
end

function Window:CreateTab(name)
	local theme = self._themeSystem:GetCurrentTheme()
	
	local tabButton = Utility:CreateInstance("TextButton", {
		Parent = self._tabContainer,
		BackgroundColor3 = theme.TertiaryBackground,
		Text = name,
		TextColor3 = theme.Text,
		Font = theme.Font,
		TextSize = 14,
		Size = UDim2.new(1, -20, 0, 35),
		Position = UDim2.new(0, 10, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	Utility:CreateInstance("UICorner", {
		Parent = tabButton,
		CornerRadius = UDim.new(0, theme.Rounding)
	})
	
	if not self._currentTab then
		self._currentTab = name
		tabButton.BackgroundColor3 = theme.Accent
	end
	
	local tab = {
		Name = name,
		Button = tabButton,
		Sections = {},
		Window = self
	}
	
	function tab:CreateSection(sectionName)
		local section = {
			Name = sectionName,
			Window = self.Window,
			Tab = self
		}
		
		-- Section header
		local sectionFrame = Utility:CreateInstance("Frame", {
			Parent = self.Window._sectionContainer,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.Y
		})
		
		local sectionLabel = Utility:CreateInstance("TextLabel", {
			Parent = sectionFrame,
			BackgroundTransparency = 1,
			Text = sectionName,
			TextColor3 = theme.SubText,
			Font = Enum.Font.GothamBold,
			TextSize = 12,
			Size = UDim2.new(1, 0, 0, 20),
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local elementsContainer = Utility:CreateInstance("Frame", {
			Parent = sectionFrame,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 0, 0, 25),
			AutomaticSize = Enum.AutomaticSize.Y
		})
		
		local elementsList = Utility:CreateInstance("UIListLayout", {
			Parent = elementsContainer,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		
		section._elementsContainer = elementsContainer
		section._elements = {}
		
		-- Element creation methods
		function section:CreateButton(options)
			local button = Elements:CreateButton(elementsContainer, options, self.Window._themeSystem, self.Window._animationSystem)
			table.insert(self._elements, button)
			self.Window._sectionContainer.CanvasSize = UDim2.new(0, 0, 0, self.Window._sectionList.AbsoluteContentSize.Y + 10)
			return button
		end
		
		function section:CreateToggle(options)
			local toggle = Elements:CreateToggle(elementsContainer, options, self.Window._themeSystem, self.Window._animationSystem)
			table.insert(self._elements, toggle)
			self.Window._sectionContainer.CanvasSize = UDim2.new(0, 0, 0, self.Window._sectionList.AbsoluteContentSize.Y + 10)
			return toggle
		end
		
		function section:CreateSlider(options)
			local slider = Elements:CreateSlider(elementsContainer, options, self.Window._themeSystem, self.Window._animationSystem)
			table.insert(self._elements, slider)
			self.Window._sectionContainer.CanvasSize = UDim2.new(0, 0, 0, self.Window._sectionList.AbsoluteContentSize.Y + 10)
			return slider
		end
		
		function section:CreateTextbox(options)
			local textbox = Elements:CreateTextbox(elementsContainer, options, self.Window._themeSystem, self.Window._animationSystem)
			table.insert(self._elements, textbox)
			self.Window._sectionContainer.CanvasSize = UDim2.new(0, 0, 0, self.Window._sectionList.AbsoluteContentSize.Y + 10)
			return textbox
		end
		
		function section:CreateDropdown(options)
			local dropdown = Elements:CreateDropdown(elementsContainer, options, self.Window._themeSystem, self.Window._animationSystem)
			table.insert(self._elements, dropdown)
			self.Window._sectionContainer.CanvasSize = UDim2.new(0, 0, 0, self.Window._sectionList.AbsoluteContentSize.Y + 10)
			return dropdown
		end
		
		function section:CreateLabel(options)
			local label = Elements:CreateLabel(elementsContainer, options, self.Window._themeSystem, self.Window._animationSystem)
			table.insert(self._elements, label)
			self.Window._sectionContainer.CanvasSize = UDim2.new(0, 0, 0, self.Window._sectionList.AbsoluteContentSize.Y + 10)
			return label
		end
		
		function section:CreateColorPicker(options)
			local colorPicker = Elements:CreateColorPicker(elementsContainer, options, self.Window._themeSystem, self.Window._animationSystem)
			table.insert(self._elements, colorPicker)
			self.Window._sectionContainer.CanvasSize = UDim2.new(0, 0, 0, self.Window._sectionList.AbsoluteContentSize.Y + 10)
			return colorPicker
		end
		
		-- Hide section if not on current tab
		sectionFrame.Visible = (self.Window._currentTab == self.Name)
		
		table.insert(self.Sections, section)
		return section
	end
	
	local clickConnection = tabButton.MouseButton1Click:Connect(function()
		self:_switchTab(name)
	end)
	
	table.insert(self._connections, clickConnection)
	table.insert(self._tabs, tab)
	
	return tab
end

function Window:_switchTab(tabName)
	self._currentTab = tabName
	local theme = self._themeSystem:GetCurrentTheme()
	
	-- Update tab buttons
	for _, tab in ipairs(self._tabs) do
		if tab.Name == tabName then
			tab.Button.BackgroundColor3 = theme.Accent
		else
			tab.Button.BackgroundColor3 = theme.TertiaryBackground
		end
	end
	
	-- Show/hide sections
	for _, tab in ipairs(self._tabs) do
		for _, section in ipairs(tab.Sections) do
			if section.Name then
				for _, child in ipairs(self._sectionContainer:GetChildren()) do
					if child:IsA("Frame") and child:FindFirstChild("TextLabel") and child.TextLabel.Text == section.Name then
						child.Visible = (tab.Name == tabName)
					end
				end
			end
		end
	end
end

function Window:Minimize()
	self._minimized = not self._minimized
	if self._minimized then
		self._originalSize = self._windowFrame.Size
		Utility:Tween(self._windowFrame, { Size = UDim2.new(self._originalSize.X.Scale, self._originalSize.X.Offset, 0, 40) }, 0.3)
	else
		Utility:Tween(self._windowFrame, { Size = self._originalSize }, 0.3)
	end
end

function Window:Maximize()
	if self._minimized then
		self:Minimize()
	end
end

function Window:Resize(width, height)
	Utility:Tween(self._windowFrame, { Size = UDim2.new(0, width, 0, height) }, 0.3)
end

function Window:Destroy()
	self._destroyed = true
	
	-- Clean up connections
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end
	
	-- Clean up tabs and sections
	for _, tab in ipairs(self._tabs) do
		for _, section in ipairs(tab.Sections) do
			for _, element in ipairs(section._elements or {}) do
				if element.Destroy then
					element:Destroy()
				end
			end
		end
	end
	
	-- Remove GUI
	if self._gui then
		self._gui:Destroy()
	end
end

-- Main UILibrary
local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary.new()
	local self = setmetatable({}, UILibrary)
	self._themeSystem = ThemeSystem.new(DEFAULT_THEME)
	self._animationSystem = AnimationSystem.new()
	self._configSystem = ConfigSystem.new()
	self._windows = {}
	self._notificationSystem = nil
	
	return self
end

function UILibrary:CreateWindow(options)
	local window = Window.new(self, options)
	
	-- Create notification system (shared across windows)
	if not self._notificationSystem then
		self._notificationSystem = NotificationSystem.new(window._gui)
	end
	window._notificationSystem = self._notificationSystem
	
	-- Add notification methods to window
	function window:SendNotification(options)
		self._notificationSystem:Send(options)
	end
	
	-- Add config methods to window
	function window:SaveConfig(fileName)
		self._configSystem:SaveConfig(fileName)
	end
	
	function window:LoadConfig(fileName)
		return self._configSystem:LoadConfig(fileName)
	end
	
	function window:DeleteConfig(fileName)
		self._configSystem:DeleteConfig(fileName)
	end
	
	function window:ExportConfig()
		return self._configSystem:ExportConfig()
	end
	
	function window:ImportConfig(jsonData)
		return self._configSystem:ImportConfig(jsonData)
	end
	
	-- Theme methods
	function window:SetTheme(themeName)
		self._themeSystem:SetTheme(themeName)
	end
	
	function window:CreateCustomTheme(themeName, themeConfig)
		self._themeSystem:CreateCustomTheme(themeName, themeConfig)
	end
	
	function window:GetCurrentTheme()
		return self._themeSystem:GetCurrentTheme()
	end
	
	table.insert(self._windows, window)
	return window
end

function UILibrary:SetTheme(themeName)
	self._themeSystem:SetTheme(themeName)
end

function UILibrary:CreateCustomTheme(themeName, themeConfig)
	self._themeSystem:CreateCustomTheme(themeName, themeConfig)
end

function UILibrary:GetConfigSystem()
	return self._configSystem
end

-- Create the library instance
local Library = UILibrary.new()

return Library
