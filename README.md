# 🌟 Nebula UI Library v3.0

A modern, customizable Roblox UI Library with a glossy purple theme, smooth animations, notifications, loading screens, and many built-in UI components.

---

## ✨ Features

- 🎨 Multiple Themes (Amethyst, Dark, Light)
- 🌟 Glossy Modern Design
- 📂 Tab System
- 📦 Sections
- 🔘 Toggle
- 🔲 Button
- 🎚 Slider
- 📋 Dropdown
- 📝 Label
- ⌨ TextBox
- 🔑 Keybind
- ☑ Checkbox
- 🎨 RGB Color Picker
- 📊 Progress Bar
- 🔔 Notifications
- ⏳ Loading Screen
- 💾 Config System
- 🎬 Smooth Tween Animations
- 🖱 Draggable Window

---

# 📥 Installation

Load the library.

```lua
local Nebula = loadstring(game:HttpGet("YOUR_RAW_URL"))()
```

Replace:

```
YOUR_RAW_URL
```

with your Raw GitHub URL.

---

# 🚀 Creating a Window

```lua
local Window = Nebula.CreateWindow({
    Title = "Nebula Demo",
    ConfigName = "MyConfig",

    ShowLoading = true,

    LoadingDuration = 3,

    LoadingSteps = {
        "Loading...",
        "Creating UI...",
        "Almost Done...",
        "Ready!"
    }
})
```

---

# 📁 Creating Tabs

```lua
local MainTab = Window:CreateTab("Main", "🏠")
local SettingsTab = Window:CreateTab("Settings", "⚙")
```

Parameters:

| Parameter | Description |
|-----------|-------------|
| Name | Tab name |
| Icon | Emoji or icon |

---

# 📦 Creating Sections

```lua
local Main = Nebula.CreateSection(MainTab,{
    Name = "Main Features"
})
```

Or without a title:

```lua
local Main = Nebula.CreateSection(MainTab)
```

---

# 🔘 Button

```lua
Main:CreateButton({
    Name = "Click Me",

    Callback = function()
        print("Clicked!")
    end
})
```

Optional:

```lua
Color = Color3.fromRGB(255,0,0)
```

---

# ☑ Toggle

```lua
local Toggle = Main:CreateToggle({

    Name = "Auto Farm",

    Default = false,

    Callback = function(Value)
        print(Value)
    end

})
```

Functions

```lua
Toggle:Set(true)

print(Toggle:Get())
```

Events

```lua
Toggle.Events.OnChanged:Connect(function(Value)

end)
```

---

# 🎚 Slider

```lua
local Slider = Main:CreateSlider({

    Name = "WalkSpeed",

    Min = 16,

    Max = 100,

    Default = 16,

    Suffix = " Studs",

    Callback = function(Value)

    end

})
```

Functions

```lua
Slider:Set(50)

print(Slider:Get())
```

---

# 📋 Dropdown

```lua
local Dropdown = Main:CreateDropdown({

    Name = "Select Team",

    Options = {
        "Red",
        "Blue",
        "Green"
    },

    Default = "Red",

    Callback = function(Value)

    end

})
```

Refresh Options

```lua
Dropdown:Refresh({
    "Option 1",
    "Option 2",
    "Option 3"
})
```

Set Value

```lua
Dropdown:Set("Blue")
```

---

# 📝 Label

```lua
Main:CreateLabel({

    Text = "Hello World"

})
```

Optional

```lua
Color = Color3.fromRGB(255,255,255)

Size = 14
```

---

# ⌨ TextBox

```lua
local Box = Main:CreateTextBox({

    Placeholder = "Type here...",

    Default = "",

    Callback = function(Text)

    end

})
```

Functions

```lua
Box:Set("Hello")

print(Box:Get())
```

Events

```lua
Box.Events.OnChanged:Connect(function(Text)

end)
```

---

# 🔑 Keybind

```lua
local Keybind = Main:CreateKeybind({

    Name = "Open UI",

    Default = "RightShift",

    Callback = function(Key)

    end

})
```

Functions

```lua
Keybind:Set("F")

print(Keybind:Get())
```

---

# ☑ Checkbox

```lua
local Checkbox = Main:CreateCheckbox({

    Name = "ESP",

    Default = false,

    Callback = function(Value)

    end

})
```

Functions

```lua
Checkbox:Set(true)

print(Checkbox:Get())
```

---

# 🎨 Color Picker

```lua
local Picker = Main:CreateColorPicker({

    Name = "Accent",

    Default = Color3.fromRGB(140,80,255),

    Callback = function(Color)

    end

})
```

Functions

```lua
Picker:Set(Color3.fromRGB(255,0,0))

print(Picker:Get())
```

---

# 📊 Progress Bar

```lua
local Progress = Main:CreateProgressBar({

    Name = "Loading",

    Value = 30,

    Max = 100

})
```

Update

```lua
Progress:Set(75)
```

---

# 🔔 Notifications

```lua
Window:Notify({

    Title = "Success",

    Content = "Everything loaded!",

    Type = "success",

    Duration = 5,

    Icon = "✅"

})
```

Notification Types

- info
- success
- warning
- error

---

# 📂 Config System

Save

```lua
ConfigManager:Save("MyConfig",Data)
```

Load

```lua
ConfigManager:Load("MyConfig")
```

Delete

```lua
ConfigManager:Delete("MyConfig")
```

---

# 🎨 Themes

Built-in Themes

- Amethyst
- Dark
- Light

Current default:

```lua
Amethyst
```

---

# 🛠 Window Functions

Destroy

```lua
Window:Destroy()
```

Minimize

```lua
Window:Minimize()
```

Notification

```lua
Window:Notify({...})
```

---

# 📚 Complete Example

```lua
local Nebula = loadstring(game:HttpGet("YOUR_RAW_URL"))()

local Window = Nebula.CreateWindow({
    Title = "Nebula Demo",
    ConfigName = "Example"
})

local MainTab = Window:CreateTab("Main","🏠")

local Main = Nebula.CreateSection(MainTab,{
    Name = "Example"
})

Main:CreateButton({
    Name = "Hello",
    Callback = function()
        print("Hello!")
    end
})

Main:CreateToggle({
    Name = "Toggle",
    Callback = function(Value)
        print(Value)
    end
})

Main:CreateSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(Value)
        print(Value)
    end
})

Window:Notify({
    Title = "Nebula",
    Content = "Library Loaded!",
    Type = "success"
})
```

---

# 📄 License

This project is free to use and modify.

Please keep credits if you redistribute the library.

---

# ⭐ Nebula UI v3.0

Made with ❤️ for the Roblox scripting community.
