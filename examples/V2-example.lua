local Nebula = loadstring(game:HttpGet("https://raw.githubusercontent.com/lzhenweiDev/Nebula-UI/refs/heads/main/V2.lua"))()

local Window = Nebula.CreateWindow({Title = "My Script"})
local Tab = Window:CreateTab("Main", "🏠")
local Section = Nebula.CreateSection(Tab, {Name = "Features"})

local toggle = Section:CreateToggle({Name = "God Mode", Default = false, Callback = function(v) print(v) end})
Section:CreateButton({Name = "Click Me", Callback = function() print("Clicked!") end})
Section:CreateSlider({Name = "Speed", Min = 16, Max = 200, Default = 50, Callback = function(v) print(v) end})

Window:Notify({Title = "Loaded!", Content = "Ready!", Duration = 3})
