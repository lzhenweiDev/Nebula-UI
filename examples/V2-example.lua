-- UI Library Demo Script
-- Zeigt alle Funktionen und Komponenten der Bibliothek

local UILibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/lzhenweiDev/Nebula-UI/refs/heads/main/V2.lua"))()

-- Hauptfenster erstellen
local Window = UILibrary:CreateWindow({
    Title = "UI Library Demo",
    Subtitle = "Version 1.0 - Alle Features"
})

-- Theme-Auswahl Tab
local ThemeTab = Window:CreateTab("🎨 Themes")

-- Theme Section
local ThemeSection = ThemeTab:CreateSection("Theme Einstellungen")

ThemeSection:CreateButton({
    Name = "Dark Theme",
    Callback = function()
        Window:SetTheme("Dark")
    end
})

ThemeSection:CreateButton({
    Name = "Light Theme",
    Callback = function()
        Window:SetTheme("Light")
    end
})

ThemeSection:CreateButton({
    Name = "Custom Purple Theme",
    Callback = function()
        Window:CreateCustomTheme("Purple", {
            Name = "Purple",
            Background = Color3.fromRGB(20, 5, 30),
            SecondaryBackground = Color3.fromRGB(30, 10, 45),
            TertiaryBackground = Color3.fromRGB(40, 15, 60),
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(180, 170, 200),
            Accent = Color3.fromRGB(150, 50, 255),
            AccentHover = Color3.fromRGB(120, 30, 230),
            Border = Color3.fromRGB(60, 30, 90),
            Shadow = Color3.fromRGB(0, 0, 0),
            Success = Color3.fromRGB(100, 255, 100),
            Warning = Color3.fromRGB(255, 255, 0),
            Error = Color3.fromRGB(255, 50, 50),
            Transparency = 0.95,
            BlurEnabled = false,
            Font = Enum.Font.Gotham,
            Rounding = 12,
            StrokeThickness = 1,
            AcrylicStrength = 0
        })
        Window:SetTheme("Purple")
    end
})

ThemeSection:CreateLabel({
    Text = "💡 Tipp: Themes können live gewechselt werden!",
    Size = 12
})

-- Grundlegende UI-Elemente Tab
local BasicTab = Window:CreateTab("🔧 Basic UI")

-- Buttons Section
local ButtonSection = BasicTab:CreateSection("Buttons")

ButtonSection:CreateButton({
    Name = "Einfacher Button",
    Callback = function()
        Window:SendNotification({
            Title = "Button geklickt",
            Message = "Du hast den einfachen Button geklickt!",
            Duration = 2
        })
    end
})

ButtonSection:CreateButton({
    Name = "Button mit Confirmation",
    Callback = function()
        Window:SendNotification({
            Title = "Bestätigung",
            Message = "Aktion wurde ausgeführt!",
            Duration = 3
        })
    end
})

-- Toggle Section
local ToggleSection = BasicTab:CreateSection("Toggles")

local godModeToggle = ToggleSection:CreateToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(Value)
        print("God Mode:", Value)
        Window:SendNotification({
            Title = "God Mode",
            Message = Value and "Aktiviert! Du bist unsterblich!" or "Deaktiviert!",
            Duration = 2
        })
    end
})

local autoFarmToggle = ToggleSection:CreateToggle({
    Name = "Auto Farm",
    Default = true,
    Callback = function(Value)
        print("Auto Farm:", Value)
    end
})

local invisibilityToggle = ToggleSection:CreateToggle({
    Name = "Invisibility",
    Default = false,
    Callback = function(Value)
        print("Invisibility:", Value)
    end
})

-- Toggle Steuerung
ToggleSection:CreateButton({
    Name = "God Mode Status abfragen",
    Callback = function()
        local status = godModeToggle:Get()
        Window:SendNotification({
            Title = "God Mode Status",
            Message = "God Mode ist: " .. (status and "AN" or "AUS"),
            Duration = 2
        })
    end
})

ToggleSection:CreateButton({
    Name = "God Mode auf AN setzen",
    Callback = function()
        godModeToggle:Set(true)
    end
})

-- Sliders Section
local SliderSection = BasicTab:CreateSection("Sliders")

local speedSlider = SliderSection:CreateSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Step = 1,
    Callback = function(Value)
        print("Walk Speed:", Value)
    end
})

local jumpSlider = SliderSection:CreateSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 500,
    Default = 50,
    Step = 10,
    Callback = function(Value)
        print("Jump Power:", Value)
    end
})

local fovSlider = SliderSection:CreateSlider({
    Name = "Field of View",
    Min = 30,
    Max = 120,
    Default = 70,
    Step = 5,
    Callback = function(Value)
        print("FOV:", Value)
    end
})

-- Slider Kontrollen
SliderSection:CreateButton({
    Name = "Speed auf 100 setzen",
    Callback = function()
        speedSlider:Set(100)
    end
})

SliderSection:CreateButton({
    Name = "Aktuelle Speed abfragen",
    Callback = function()
        local speed = speedSlider:Get()
        Window:SendNotification({
            Title = "Walk Speed",
            Message = "Aktuelle Geschwindigkeit: " .. speed,
            Duration = 2
        })
    end
})

-- Eingabe-Elemente Tab
local InputTab = Window:CreateTab("⌨️ Eingaben")

-- Textbox Section
local TextboxSection = InputTab:CreateSection("Text Eingaben")

local nameTextbox = TextboxSection:CreateTextbox({
    Name = "Spieler Name",
    Default = "",
    Placeholder = "Gib deinen Namen ein...",
    Callback = function(Text, EnterPressed)
        print("Name eingegeben:", Text)
        if EnterPressed then
            Window:SendNotification({
                Title = "Name gespeichert",
                Message = "Dein Name: " .. Text,
                Duration = 2
            })
        end
    end
})

local chatTextbox = TextboxSection:CreateTextbox({
    Name = "Chat Nachricht",
    Default = "",
    Placeholder = "Schreibe eine Nachricht...",
    Callback = function(Text, EnterPressed)
        if EnterPressed and Text ~= "" then
            Window:SendNotification({
                Title = "Nachricht gesendet",
                Message = '"' .. Text .. '"',
                Duration = 2
            })
        end
    end
})

-- Textbox Steuerung
TextboxSection:CreateButton({
    Name = "Name auf 'Player1' setzen",
    Callback = function()
        nameTextbox:Set("Player1")
    end
})

TextboxSection:CreateButton({
    Name = "Aktuellen Namen abfragen",
    Callback = function()
        local name = nameTextbox:Get()
        Window:SendNotification({
            Title = "Spieler Name",
            Message = "Aktueller Name: " .. name,
            Duration = 2
        })
    end
})

-- Dropdown Section
local DropdownSection = InputTab:CreateSection("Dropdowns")

local weaponDropdown = DropdownSection:CreateDropdown({
    Name = "Waffe auswählen",
    Options = {"Sword", "Pistol", "Shotgun", "Rifle", "Rocket Launcher", "Sniper"},
    Default = "Sword",
    Callback = function(Value)
        print("Waffe ausgewählt:", Value)
        Window:SendNotification({
            Title = "Waffe gewechselt",
            Message = "Aktuelle Waffe: " .. Value,
            Duration = 2
        })
    end
})

local mapDropdown = DropdownSection:CreateDropdown({
    Name = "Map auswählen",
    Options = {"Forest", "Desert", "City", "Space Station", "Underwater"},
    Default = "Forest",
    Callback = function(Value)
        print("Map:", Value)
    end
})

-- Dropdown Steuerung
DropdownSection:CreateButton({
    Name = "Waffe auf 'Rifle' setzen",
    Callback = function()
        weaponDropdown:Set("Rifle")
    end
})

DropdownSection:CreateButton({
    Name = "Waffen-Optionen ändern",
    Callback = function()
        weaponDropdown:SetOptions({"Katana", "Bow", "Magic Wand", "Light Saber"})
    end
})

-- Color Picker Section
local ColorSection = InputTab:CreateSection("Farben")

local primaryColorPicker = ColorSection:CreateColorPicker({
    Name = "Primärfarbe",
    Default = Color3.fromRGB(0, 120, 255),
    Callback = function(Color)
        print("Farbe gewählt:", Color)
    end
})

local secondaryColorPicker = ColorSection:CreateColorPicker({
    Name = "Sekundärfarbe",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        print("Sekundärfarbe:", Color)
    end
})

-- Labels Section
local LabelSection = InputTab:CreateSection("Labels")

local statusLabel = LabelSection:CreateLabel({
    Text = "Status: Bereit",
    Size = 14
})

local infoLabel = LabelSection:CreateLabel({
    Text = "Alle Systeme funktionieren einwandfrei.",
    Size = 12
})

LabelSection:CreateButton({
    Name = "Status Label ändern",
    Callback = function()
        statusLabel:SetText("Status: Wurde aktualisiert!")
        Window:SendNotification({
            Title = "Label Update",
            Message = "Status-Label wurde geändert",
            Duration = 2
        })
    end
})

LabelSection:CreateButton({
    Name = "Label Text abfragen",
    Callback = function()
        local text = statusLabel:GetText()
        print("Label Text:", text)
    end
})

-- Config Tab
local ConfigTab = Window:CreateTab("💾 Config")

-- Config Section
local ConfigSection = ConfigTab:CreateSection("Configuration")

ConfigSection:CreateButton({
    Name = "Config Speichern",
    Callback = function()
        -- Werte in Config speichern
        local config = UILibrary:GetConfigSystem()
        config:SetValue("godMode", godModeToggle:Get())
        config:SetValue("walkSpeed", speedSlider:Get())
        config:SetValue("jumpPower", jumpSlider:Get())
        config:SetValue("fov", fovSlider:Get())
        config:SetValue("playerName", nameTextbox:Get())
        config:SetValue("weapon", weaponDropdown:Get())
        config:SaveConfig()
        
        Window:SendNotification({
            Title = "Config",
            Message = "Einstellungen wurden gespeichert!",
            Duration = 3
        })
    end
})

ConfigSection:CreateButton({
    Name = "Config Laden",
    Callback = function()
        local config = UILibrary:GetConfigSystem()
        if config:LoadConfig() then
            -- Geladene Werte anwenden
            if config:GetValue("godMode") ~= nil then
                godModeToggle:Set(config:GetValue("godMode"))
            end
            if config:GetValue("walkSpeed") ~= nil then
                speedSlider:Set(config:GetValue("walkSpeed"))
            end
            if config:GetValue("jumpPower") ~= nil then
                jumpSlider:Set(config:GetValue("jumpPower"))
            end
            if config:GetValue("fov") ~= nil then
                fovSlider:Set(config:GetValue("fov"))
            end
            if config:GetValue("playerName") ~= nil then
                nameTextbox:Set(config:GetValue("playerName"))
            end
            if config:GetValue("weapon") ~= nil then
                weaponDropdown:Set(config:GetValue("weapon"))
            end
            
            Window:SendNotification({
                Title = "Config",
                Message = "Einstellungen wurden geladen!",
                Duration = 3
            })
        else
            Window:SendNotification({
                Title = "Config",
                Message = "Keine gespeicherte Config gefunden!",
                Duration = 3
            })
        end
    end
})

ConfigSection:CreateButton({
    Name = "Config Löschen",
    Callback = function()
        UILibrary:GetConfigSystem():DeleteConfig()
        Window:SendNotification({
            Title = "Config",
            Message = "Gespeicherte Config wurde gelöscht!",
            Duration = 3
        })
    end
})

ConfigSection:CreateButton({
    Name = "Config Exportieren",
    Callback = function()
        local json = UILibrary:GetConfigSystem():ExportConfig()
        print("Exported Config:", json)
        Window:SendNotification({
            Title = "Config Export",
            Message = "Config wurde in Konsole exportiert!",
            Duration = 3
        })
    end
})

ConfigSection:CreateButton({
    Name = "Config Importieren (Demo)",
    Callback = function()
        local demoConfig = '{"godMode":true,"walkSpeed":100,"weapon":"Rifle"}'
        UILibrary:GetConfigSystem():ImportConfig(demoConfig)
        Window:SendNotification({
            Title = "Config Import",
            Message = "Demo-Config wurde importiert!",
            Duration = 3
        })
    end
})

-- Fenster Steuerung Tab
local WindowTab = Window:CreateTab("🪟 Fenster")

-- Window Controls Section
local WindowSection = WindowTab:CreateSection("Fenster Steuerung")

WindowSection:CreateButton({
    Name = "Fenster Minimieren",
    Callback = function()
        Window:Minimize()
    end
})

WindowSection:CreateButton({
    Name = "Fenster Maximieren",
    Callback = function()
        Window:Maximize()
    end
})

WindowSection:CreateButton({
    Name = "Größe ändern (800x600)",
    Callback = function()
        Window:Resize(800, 600)
    end
})

WindowSection:CreateButton({
    Name = "Größe ändern (400x300)",
    Callback = function()
        Window:Resize(400, 300)
    end
})

-- Notifications Section
local NotificationSection = WindowTab:CreateSection("Benachrichtigungen")

NotificationSection:CreateButton({
    Name = "Info Notification",
    Callback = function()
        Window:SendNotification({
            Title = "Information",
            Message = "Dies ist eine Info-Benachrichtigung!",
            Duration = 3
        })
    end
})

NotificationSection:CreateButton({
    Name = "Erfolg Notification",
    Callback = function()
        Window:SendNotification({
            Title = "✅ Erfolg",
            Message = "Aktion erfolgreich ausgeführt!",
            Duration = 4
        })
    end
})

NotificationSection:CreateButton({
    Name = "Warnung Notification",
    Callback = function()
        Window:SendNotification({
            Title = "⚠️ Warnung",
            Message = "Diese Aktion könnte gefährlich sein!",
            Duration = 5
        })
    end
})

NotificationSection:CreateButton({
    Name = "Fehler Notification",
    Callback = function()
        Window:SendNotification({
            Title = "❌ Fehler",
            Message = "Ein unerwarteter Fehler ist aufgetreten!",
            Duration = 5
        })
    end
})

NotificationSection:CreateButton({
    Name = "Lange Notification",
    Callback = function()
        Window:SendNotification({
            Title = "Lange Nachricht",
            Message = "Diese Benachrichtigung hat einen sehr langen Text, um zu zeigen wie die UI mit längeren Nachrichten umgeht.",
            Duration = 6
        })
    end
})

-- Zweites Fenster Demo
local SecondWindowSection = WindowTab:CreateSection("Mehrere Fenster")

SecondWindowSection:CreateButton({
    Name = "Zweites Fenster öffnen",
    Callback = function()
        local Window2 = UILibrary:CreateWindow({
            Title = "Zweites Fenster",
            Subtitle = "Multi-Window Demo"
        })
        
        local Tab2 = Window2:CreateTab("Info")
        local Section2 = Tab2:CreateSection("Info")
        
        Section2:CreateLabel({
            Text = "Dies ist ein zweites Fenster!",
            Size = 16
        })
        
        Section2:CreateLabel({
            Text = "Du kannst mehrere Fenster gleichzeitig öffnen.",
            Size = 14
        })
        
        Section2:CreateButton({
            Name = "Fenster schließen",
            Callback = function()
                Window2:Destroy()
                Window:SendNotification({
                    Title = "Fenster",
                    Message = "Zweites Fenster wurde geschlossen!",
                    Duration = 2
                })
            end
        })
        
        Section2:CreateButton({
            Name = "Notification senden",
            Callback = function()
                Window2:SendNotification({
                    Title = "Fenster 2",
                    Message = "Nachricht von Fenster 2!",
                    Duration = 2
                })
            end
        })
    end
})

-- Demo Tab - Alle Funktionen auf einmal
local DemoSection = WindowTab:CreateSection("Demo Ablauf")

DemoSection:CreateButton({
    Name = "🚀 Alle Features demonstrieren",
    Callback = function()
        print("=== UI Library Demo Start ===")
        
        -- Toggles testen
        godModeToggle:Set(true)
        wait(0.5)
        autoFarmToggle:Set(false)
        wait(0.5)
        
        -- Sliders testen
        speedSlider:Set(150)
        wait(0.3)
        jumpSlider:Set(200)
        wait(0.3)
        fovSlider:Set(100)
        wait(0.3)
        
        -- Textboxen setzen
        nameTextbox:Set("DemoUser")
        wait(0.3)
        
        -- Dropdown ändern
        weaponDropdown:Set("Rocket Launcher")
        wait(0.3)
        
        -- Theme wechseln
        Window:SetTheme("Light")
        wait(0.5)
        Window:SetTheme("Dark")
        wait(0.5)
        
        -- Notification Spam
        for i = 1, 3 do
            Window:SendNotification({
                Title = "Demo Notification #" .. i,
                Message = "Dies ist die " .. i .. ". Demo-Nachricht!",
                Duration = 2
            })
            wait(0.3)
        end
        
        -- Label ändern
        statusLabel:SetText("Status: Demo läuft...")
        wait(1)
        statusLabel:SetText("Status: Demo abgeschlossen! ✓")
        
        print("=== UI Library Demo Ende ===")
        
        Window:SendNotification({
            Title = "✅ Demo abgeschlossen",
            Message = "Alle Features wurden demonstriert! Überprüfe die Konsole für Details.",
            Duration = 5
        })
    end
})

print("=== UI Library vollständig geladen ===")
print("Alle Tabs:")
print("- 🎨 Themes (Dark, Light, Custom)")
print("- 🔧 Basic UI (Buttons, Toggles, Sliders)")
print("- ⌨️ Eingaben (Textboxen, Dropdowns, ColorPicker, Labels)")
print("- 💾 Config (Speichern, Laden, Export, Import)")
print("- 🪟 Fenster (Steuerung, Notifications, Multi-Window)")
print("")
print("Alle Komponenten mit Set/Get-Methoden verfügbar!")
print("Rechtsklick auf das Fenster zum Verschieben")
