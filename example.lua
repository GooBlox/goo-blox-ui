--[[
    FlatGrayUI — Complete Usage Example
    Covers EVERY component:
        Toggle, Slider, Dropdown, Button, Input,
        Keybind, ColorPicker, Label, Paragraph, Divider
    Plus:
        Notify (4 kinds), SaveConfig, LoadConfig, SetTheme
        SetStatus, window:SetStatus
--]]

-- ── LOAD UI ─────────────────────────────────────────────────────────────────
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/GooBlox/goo-blox-ui/refs/heads/main/main.lua"))()

-- ── WINDOW ──────────────────────────────────────────────────────────────────
-- CreateWindow(title, subtitle)
-- subtitle shows as a small badge next to the title
local Window = UI:CreateWindow("Goo Blox", "v2.0")

-- ── OPTIONAL: set theme before building the UI ───────────────────────────────
-- Themes: "light" (default), "dark", "ocean"
-- UI:SetTheme("dark")

-- ============================================================================
-- TAB 1 — FARM
-- ============================================================================
local FarmTab = Window:CreateTab("Farm")

-- ── SECTION: Auto Farm ──────────────────────────────────────────────────────
local FarmSection = FarmTab:CreateSection("Auto Farm")

-- DIVIDER with label — useful to group things inside a section
FarmSection:CreateDivider("Core")

-- TOGGLE  ────────────────────────────────────────────────────────────────────
-- Name        display name
-- Flag        key in UI.Flags (read with UI.Flags.AutoFarm)
-- CurrentValue starting state (true/false)
-- Description optional sub-text under the name
-- Callback    called with (bool) every time state changes
local toggleObj = FarmSection:CreateToggle({
	Name = "Auto Farm",
	Flag = "AutoFarm",
	CurrentValue = false,
	Description = "Fire projectile at nearest target",
	Callback = function(v)
		UI:Notify(v and "Auto Farm ON" or "Auto Farm OFF", 2, v and "success" or "info")
		Window:SetStatus(v and "Auto Farm running" or "Ready", v and "running" or "ok")
	end,
})

FarmSection:CreateToggle({
	Name = "Auto Jump",
	Flag = "AutoJump",
	CurrentValue = false,
	Description = "Teleport on top of the target",
	Callback = function(v)
		UI:Notify(v and "Auto Jump ON" or "Auto Jump OFF", 2, v and "success" or "info")
	end,
})

-- DIVIDER bare — just a horizontal rule
FarmSection:CreateDivider()

-- SLIDER  ─────────────────────────────────────────────────────────────────────
-- Min / Max / CurrentValue   numeric range
-- Callback    called with (number) on every drag tick
local sliderObj = FarmSection:CreateSlider({
	Name = "Range",
	Flag = "Range",
	Min = 10,
	Max = 200,
	CurrentValue = 100,
	Callback = function(v)
		-- UI.Flags.Range is updated automatically
	end,
})

FarmSection:CreateSlider({
	Name = "Attack Speed",
	Flag = "AttackSpeed",
	Min = 1,
	Max = 20,
	CurrentValue = 5,
	Callback = function(v)
		-- v is the ticks-per-second value
	end,
})

-- DROPDOWN  ───────────────────────────────────────────────────────────────────
-- Options   array of strings
-- Default   pre-selected value (optional, falls back to Options[1])
-- Callback  called with (string) when selection changes
local dropObj = FarmSection:CreateDropdown({
	Name = "Enemy Type",
	Flag = "EnemyType",
	Options = { "RockEnemies", "MagmaEnemies", "BossEnemies" },
	Default = "RockEnemies",
	Callback = function(v)
		UI:Notify("Targeting: " .. v, 2, "info")
	end,
})

FarmSection:CreateDropdown({
	Name = "Priority",
	Flag = "Priority",
	Options = { "Closest", "Lowest HP", "Highest HP" },
	Default = "Closest",
	Callback = function(v)
		-- UI.Flags.Priority is updated automatically
	end,
})

-- LABEL  ──────────────────────────────────────────────────────────────────────
-- Pass a plain string for a simple muted hint line
FarmSection:CreateLabel("Tip: use Range to limit target distance.")

-- Labels support styles: "default", "header", "info", "success", "warn", "error"
local statusLbl = FarmSection:CreateLabel({
	Text = "Status: idle",
	Style = "info",
})

-- You can update label text after creation:
-- statusLbl:SetText("Status: farming")

-- PARAGRAPH  ──────────────────────────────────────────────────────────────────
-- Title  bold header line (optional)
-- Body   multi-line wrapped text
FarmSection:CreateParagraph({
	Title = "How it works",
	Body = "Auto Farm fires the remote every 0.2 seconds at the nearest enemy "
		.. "within the chosen Range. Priority controls which enemy is picked "
		.. "when multiple are in range.",
})

-- ============================================================================
-- TAB 2 — VISUAL
-- ============================================================================
local VisualTab = Window:CreateTab("Visual")

local VisualSection = VisualTab:CreateSection("ESP")

VisualSection:CreateToggle({
	Name = "ESP Enabled",
	Flag = "ESP",
	CurrentValue = false,
	Callback = function(v)
		-- your ESP logic here
	end,
})

-- COLOR PICKER  ───────────────────────────────────────────────────────────────
-- Default  starting Color3 value
-- Callback called with (Color3) whenever color changes
-- Click the swatch to expand/collapse the picker panel
local colorObj = VisualSection:CreateColorPicker({
	Name = "ESP Color",
	Flag = "ESPColor",
	Default = Color3.fromRGB(255, 80, 80),
	Callback = function(col)
		-- col is a Color3 — apply it to your ESP boxes
		-- UI.Flags.ESPColor is also updated automatically
	end,
})

-- Read color back at any time:
-- local currentColor = colorObj:GetValue()
-- Set it programmatically:
-- colorObj:SetValue(Color3.fromRGB(0, 200, 255))

VisualSection:CreateSlider({
	Name = "ESP Box Width",
	Flag = "ESPWidth",
	Min = 1,
	Max = 5,
	CurrentValue = 2,
})

VisualSection:CreateDivider("Chams")

VisualSection:CreateToggle({
	Name = "Chams",
	Flag = "Chams",
	CurrentValue = false,
})

VisualSection:CreateColorPicker({
	Name = "Chams Color",
	Flag = "ChamsColor",
	Default = Color3.fromRGB(100, 180, 255),
})

-- ============================================================================
-- TAB 3 — SETTINGS
-- ============================================================================
local SettingsTab = Window:CreateTab("Settings")

-- ── SECTION: Keybinds ───────────────────────────────────────────────────────
local KeySection = SettingsTab:CreateSection("Keybinds")

-- KEYBIND  ────────────────────────────────────────────────────────────────────
-- Default   starting Enum.KeyCode
-- Callback  called with (KeyCode) when key is changed
-- OnFire    called every time the bound key is pressed in-game
-- Click the button, then press any key to rebind (Escape cancels)
FarmSection:CreateKeybind({
	Name = "Toggle UI",
	Flag = "ToggleKey",
	Description = "Press to show/hide",
	Default = Enum.KeyCode.RightControl,
	Callback = function(kc)
		UI:Notify("UI key set to: " .. tostring(kc.Name), 2, "info")
	end,
	OnFire = function()
		-- fires every time the key is pressed
	end,
})

FarmSection:CreateKeybind({
	Name = "Toggle Farm",
	Flag = "FarmKey",
	Default = Enum.KeyCode.F,
	OnFire = function()
		local next = not UI.Flags.AutoFarm
		UI.Flags.AutoFarm = next
		toggleObj:SetValue(next)
		UI:Notify(next and "Farm started" or "Farm stopped", 2, next and "success" or "warn")
	end,
})

-- ── SECTION: Appearance ─────────────────────────────────────────────────────
local AppearSection = SettingsTab:CreateSection("Appearance")

AppearSection:CreateDropdown({
	Name = "Theme",
	Flag = "Theme",
	Options = { "light", "dark", "ocean" },
	Default = "light",
	Callback = function(v)
		UI:SetTheme(v)
		UI:Notify("Theme: " .. v, 2, "info")
	end,
})

-- ── SECTION: Config ─────────────────────────────────────────────────────────
local ConfigSection = SettingsTab:CreateSection("Config")

ConfigSection:CreateParagraph({
	Title = "Auto-save",
	Body = "Configs are saved as JSON files in your executor's workspace folder. "
		.. "Load them on startup to restore your last session.",
})

-- INPUT  ──────────────────────────────────────────────────────────────────────
-- Default       starting text
-- Placeholder   greyed hint text when empty
-- ClearOnFocus  clear box when you click it (default true)
-- Callback      called with (text, pressedEnter) on focus lost
local inputObj = ConfigSection:CreateInput({
	Name = "Config Name",
	Flag = "ConfigName",
	Default = "myconfig",
	Placeholder = "e.g. myconfig",
	ClearOnFocus = false,
	Callback = function(text, entered)
		-- text  = current value
		-- entered = true if user pressed Enter to confirm
	end,
})

-- BUTTON — styles: "accent" (indigo), "danger" (red), or default (dark)
ConfigSection:CreateButton({
	Name = "Save Config",
	Style = "accent",
	Callback = function()
		local name = UI.Flags.ConfigName or "myconfig"
		UI:SaveConfig(name)
		UI:Notify("Saved: " .. name .. ".json", 3, "success")
	end,
})

ConfigSection:CreateButton({
	Name = "Load Config",
	Callback = function()
		local name = UI.Flags.ConfigName or "myconfig"
		UI:LoadConfig(name)
		UI:Notify("Loaded: " .. name .. ".json", 3, "info")
	end,
})

ConfigSection:CreateButton({
	Name = "Reset Flags",
	Style = "danger",
	Callback = function()
		UI.Flags = {}
		UI:Notify("All flags cleared", 2, "warn")
		Window:SetStatus("Flags reset", "idle")
	end,
})

-- ── SECTION: Info ───────────────────────────────────────────────────────────
local InfoSection = SettingsTab:CreateSection("Info")

InfoSection:CreateLabel({ Text = "FlatGrayUI  —  complete component guide", Style = "header" })
InfoSection:CreateDivider()
InfoSection:CreateLabel({ Text = "Toggle        on/off switch with flag", Style = "default" })
InfoSection:CreateLabel({ Text = "Slider         numeric range picker", Style = "default" })
InfoSection:CreateLabel({ Text = "Dropdown    pick from a list", Style = "default" })
InfoSection:CreateLabel({ Text = "Button          click action", Style = "default" })
InfoSection:CreateLabel({ Text = "Input            free-text entry", Style = "default" })
InfoSection:CreateLabel({ Text = "Keybind      bind & fire a key", Style = "default" })
InfoSection:CreateLabel({ Text = "ColorPicker  HSV color selector", Style = "default" })
InfoSection:CreateLabel({ Text = "Label           styled text line", Style = "default" })
InfoSection:CreateLabel({ Text = "Paragraph    wrapped text block", Style = "default" })
InfoSection:CreateLabel({ Text = "Divider        section separator", Style = "default" })
InfoSection:CreateDivider()
InfoSection:CreateLabel({ Text = "Themes: light  /  dark  /  ocean", Style = "info" })

-- ============================================================================
-- NOTIFY EXAMPLES  (all 4 kinds)
-- ============================================================================
-- UI:Notify(text, duration_seconds, kind)
-- kind: "info" | "success" | "warn" | "error"

task.delay(1, function()
	UI:Notify("UI loaded successfully!", 3, "success")
end)

-- ============================================================================
-- PROGRAMMATIC CONTROL EXAMPLES
-- ============================================================================

-- Read any flag value at any time:
--   UI.Flags.AutoFarm      → boolean
--   UI.Flags.Range         → number
--   UI.Flags.EnemyType     → string
--   UI.Flags.ESPColor      → Color3
--   UI.Flags.ToggleKey     → Enum.KeyCode

-- Force-set a component's value from code:
--   toggleObj:SetValue(true)
--   sliderObj:SetValue(150)
--   dropObj:SetValue("MagmaEnemies")
--   colorObj:SetValue(Color3.fromRGB(0,255,128))
--   inputObj:SetValue("newname")

-- Update the status bar:
--   Window:SetStatus("Attacking", "running")
--   Window:SetStatus("Error!", "error")
--   Window:SetStatus("Ready", "ok")
--   Window:SetStatus("Idle", "idle")

-- Switch theme at runtime:
--   UI:SetTheme("dark")
--   UI:SetTheme("ocean")
--   UI:SetTheme("light")

-- ============================================================================
-- GAME LOGIC  (unchanged from original)
-- ============================================================================
local remote = game.ReplicatedStorage:WaitForChild("FireMagicProjectile13")

local function getTarget()
	local player = game.Players.LocalPlayer
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	local best, bestScore = nil, math.huge
	for _, folder in pairs({
		workspace:FindFirstChild(UI.Flags.EnemyType or "RockEnemies"),
	}) do
		if not folder then
			continue
		end
		for _, npc in pairs(folder:GetChildren()) do
			local hum = npc:FindFirstChildOfClass("Humanoid")
			local hrp = npc:FindFirstChild("HumanoidRootPart")
			if not (hum and hrp and hum.Health > 0) then
				continue
			end
			local dist = (hrp.Position - root.Position).Magnitude
			if UI.Flags.Range and dist > UI.Flags.Range then
				continue
			end
			local score = (UI.Flags.Priority == "Lowest HP") and hum.Health or dist
			if score < bestScore then
				bestScore = score
				best = hrp
			end
		end
	end
	return best
end

task.spawn(function()
	while task.wait(0.2) do
		local char = game.Players.LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not root then
			continue
		end

		local target = getTarget()
		if not target then
			continue
		end

		if UI.Flags.AutoFarm then
			remote:FireServer(target.Position)
		end

		if UI.Flags.AutoJump then
			root.CFrame = target.CFrame * CFrame.new(0, 3, 0)
		end
	end
end)
