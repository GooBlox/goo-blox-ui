--[[
    FlatGrayUI — Size & Font Example
    ══════════════════════════════════════════════════════════
    SIZE SYSTEM
      Set globally before CreateWindow:
        UI:SetSize("sm")   -- compact
        UI:SetSize("md")   -- default
        UI:SetSize("lg")   -- comfortable
        UI:SetSize("xl")   -- large / accessibility

      Or per-component via opts.Size = "sm"|"md"|"lg"|"xl"

    FONT SUPPORT
      Set globally before CreateWindow:
        UI:SetFont("gotham")            -- base only, auto bold
        UI:SetFont("gotham", "gothamBold")  -- base + bold
        UI:SetFont(Enum.Font.Arial)     -- raw Enum.Font also works

      Font aliases you can use as strings:
        "gotham"          "gothamBold"     "gothamSemibold"
        "arial"           "arialBold"
        "roboto"          "robotoBold"
        "code"            "serif"
        "ubuntu"          "sourceSans"

      Or per-component via opts.Font = "code" (Button, Input, Label, Paragraph)
    ══════════════════════════════════════════════════════════
--]]

local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/GooBlox/goo-blox-ui/refs/heads/main/main.lua"))()

-- ── GLOBAL SETUP (call BEFORE CreateWindow) ─────────────────────────────────

-- Choose window size:  "sm" | "md" | "lg" | "xl"
UI:SetSize("md")

-- Choose global font (base text + bold/header text)
UI:SetFont("gotham", "gothamSemibold")

-- Choose color theme:  "light" | "dark" | "ocean"
-- UI:SetTheme("dark")

-- ── WINDOW ──────────────────────────────────────────────────────────────────
local Window = UI:CreateWindow("Goo Blox", "v2.0")

-- ============================================================================
-- TAB 1 — SIZE SHOWCASE
-- Demonstrates every component at every size
-- ============================================================================
local SizeTab = Window:CreateTab("Sizes")

-- ── TOGGLE at each size ────────────────────────────────────────────────────
local togSection = SizeTab:CreateSection("Toggle — all sizes")

togSection:CreateToggle({
	Name = "Toggle sm",
	Flag = "tog_sm",
	Size = "sm",
	CurrentValue = false,
	Callback = function(v)
		print("tog_sm:", v)
	end,
})

togSection:CreateToggle({
	Name = "Toggle md",
	Flag = "tog_md",
	Size = "md",
	Description = "Default size with description",
	CurrentValue = true,
	Callback = function(v)
		print("tog_md:", v)
	end,
})

togSection:CreateToggle({
	Name = "Toggle lg",
	Flag = "tog_lg",
	Size = "lg",
	Description = "Large — easier to tap on screen",
	CurrentValue = false,
	Callback = function(v)
		print("tog_lg:", v)
	end,
})

togSection:CreateToggle({
	Name = "Toggle xl",
	Flag = "tog_xl",
	Size = "xl",
	Description = "Extra large — accessibility mode",
	CurrentValue = false,
	Callback = function(v)
		print("tog_xl:", v)
	end,
})

-- ── SLIDER at each size ────────────────────────────────────────────────────
local sliderSection = SizeTab:CreateSection("Slider — all sizes")

sliderSection:CreateSlider({
	Name = "Slider sm",
	Flag = "sl_sm",
	Min = 0,
	Max = 100,
	CurrentValue = 25,
	Size = "sm",
})
sliderSection:CreateSlider({
	Name = "Slider md",
	Flag = "sl_md",
	Min = 0,
	Max = 100,
	CurrentValue = 50,
	Size = "md",
})
sliderSection:CreateSlider({
	Name = "Slider lg",
	Flag = "sl_lg",
	Min = 0,
	Max = 100,
	CurrentValue = 75,
	Size = "lg",
})
sliderSection:CreateSlider({
	Name = "Slider xl",
	Flag = "sl_xl",
	Min = 0,
	Max = 100,
	CurrentValue = 90,
	Size = "xl",
})

-- ── DROPDOWN at each size ──────────────────────────────────────────────────
local dropSection = SizeTab:CreateSection("Dropdown — all sizes")

dropSection:CreateDropdown({
	Name = "Enemy sm",
	Flag = "dd_sm",
	Size = "sm",
	Options = { "RockEnemies", "MagmaEnemies" },
	Default = "RockEnemies",
})
dropSection:CreateDropdown({
	Name = "Enemy md",
	Flag = "dd_md",
	Size = "md",
	Options = { "RockEnemies", "MagmaEnemies" },
	Default = "RockEnemies",
})
dropSection:CreateDropdown({
	Name = "Enemy lg",
	Flag = "dd_lg",
	Size = "lg",
	Options = { "RockEnemies", "MagmaEnemies" },
	Default = "MagmaEnemies",
})
dropSection:CreateDropdown({
	Name = "Enemy xl",
	Flag = "dd_xl",
	Size = "xl",
	Options = { "RockEnemies", "MagmaEnemies" },
	Default = "RockEnemies",
})

-- ── BUTTON at each size + all styles ──────────────────────────────────────
local btnSection = SizeTab:CreateSection("Button — sizes & styles")

btnSection:CreateButton({
	Name = "Button sm",
	Size = "sm",
	Style = "accent",
	Callback = function()
		UI:Notify("sm accent", 2, "info")
	end,
})
btnSection:CreateButton({
	Name = "Button md (default)",
	Size = "md",
	Callback = function()
		UI:Notify("md default", 2, "info")
	end,
})
btnSection:CreateButton({
	Name = "Button lg accent",
	Size = "lg",
	Style = "accent",
	Callback = function()
		UI:Notify("lg accent", 2, "success")
	end,
})
btnSection:CreateButton({
	Name = "Button lg danger",
	Size = "lg",
	Style = "danger",
	Callback = function()
		UI:Notify("lg danger", 2, "error")
	end,
})
btnSection:CreateButton({
	Name = "Button xl ghost",
	Size = "xl",
	Style = "ghost",
	Callback = function()
		UI:Notify("xl ghost", 2, "warn")
	end,
})

-- ── INPUT at each size ─────────────────────────────────────────────────────
local inputSection = SizeTab:CreateSection("Input — all sizes")

inputSection:CreateInput({ Name = "Input sm", Flag = "in_sm", Size = "sm", Placeholder = "small..." })
inputSection:CreateInput({ Name = "Input md", Flag = "in_md", Size = "md", Placeholder = "medium..." })
inputSection:CreateInput({ Name = "Input lg", Flag = "in_lg", Size = "lg", Placeholder = "large..." })
inputSection:CreateInput({ Name = "Input xl", Flag = "in_xl", Size = "xl", Placeholder = "extra large..." })

-- ── KEYBIND at each size ───────────────────────────────────────────────────
local keySection = SizeTab:CreateSection("Keybind — all sizes")

keySection:CreateKeybind({ Name = "Keybind sm", Flag = "kb_sm", Size = "sm", Default = Enum.KeyCode.Q })
keySection:CreateKeybind({ Name = "Keybind md", Flag = "kb_md", Size = "md", Default = Enum.KeyCode.E })
keySection:CreateKeybind({ Name = "Keybind lg", Flag = "kb_lg", Size = "lg", Default = Enum.KeyCode.R })
keySection:CreateKeybind({ Name = "Keybind xl", Flag = "kb_xl", Size = "xl", Default = Enum.KeyCode.F })

-- ── LABEL styles + sizes ──────────────────────────────────────────────────
local lblSection = SizeTab:CreateSection("Label — styles & sizes")

lblSection:CreateLabel({ Text = "Label default sm", Style = "default", Size = "sm" })
lblSection:CreateLabel({ Text = "Label header md", Style = "header", Size = "md" })
lblSection:CreateLabel({ Text = "Label info lg", Style = "info", Size = "lg" })
lblSection:CreateLabel({ Text = "Label success md", Style = "success", Size = "md" })
lblSection:CreateLabel({ Text = "Label warn sm", Style = "warn", Size = "sm" })
lblSection:CreateLabel({ Text = "Label error sm", Style = "error", Size = "sm" })
lblSection:CreateLabel({ Text = "Label xl header", Style = "header", Size = "xl" })

-- ── DIVIDER ───────────────────────────────────────────────────────────────
lblSection:CreateDivider()
lblSection:CreateDivider("with label")

-- ── PARAGRAPH at each size ────────────────────────────────────────────────
local paraSection = SizeTab:CreateSection("Paragraph — sizes")

paraSection:CreateParagraph({
	Title = "Small paragraph",
	Body = "This is a small paragraph. Great for tooltips and hints.",
	Size = "sm",
})
paraSection:CreateParagraph({
	Title = "Medium paragraph",
	Body = "This is the default paragraph size. Use it for general descriptions inside your sections.",
	Size = "md",
})
paraSection:CreateParagraph({
	Title = "Large paragraph",
	Body = "This is a large paragraph. Easier to read on bigger screens or when used as help text.",
	Size = "lg",
})

-- ============================================================================
-- TAB 2 — FONT SHOWCASE
-- Every font alias on real components, not just text
-- ============================================================================
local FontTab = Window:CreateTab("Fonts")

local fontSection = FontTab:CreateSection("Per-component font override")

-- BUTTON — each one uses a different font via opts.Font
-- Works on: Button, Input, Label, Paragraph
fontSection:CreateButton({
	Name = "Gotham (default)",
	Style = "accent",
	Size = "md",
	Font = "gotham",
	Callback = function() end,
})
fontSection:CreateButton({
	Name = "Gotham Bold",
	Style = "accent",
	Size = "md",
	Font = "gothamBold",
	Callback = function() end,
})
fontSection:CreateButton({
	Name = "Arial",
	Style = "accent",
	Size = "md",
	Font = "arial",
	Callback = function() end,
})
fontSection:CreateButton({
	Name = "Source Sans",
	Style = "accent",
	Size = "md",
	Font = "sourceSans",
	Callback = function() end,
})
fontSection:CreateButton({
	Name = "Ubuntu",
	Style = "accent",
	Size = "md",
	Font = "ubuntu",
	Callback = function() end,
})

fontSection:CreateDivider("Input fonts")

fontSection:CreateInput({
	Name = "Gotham input",
	Flag = "fi_gotham",
	Font = "gotham",
	Placeholder = "gotham font...",
})
fontSection:CreateInput({
	Name = "Code input",
	Flag = "fi_code",
	Font = "code",
	Placeholder = "monospace code...",
})
fontSection:CreateInput({
	Name = "Serif input",
	Flag = "fi_serif",
	Font = "serif",
	Placeholder = "serif style...",
})

fontSection:CreateDivider("Label fonts")

fontSection:CreateLabel({ Text = "Label in Gotham (default)", Font = "gotham", Style = "header", Size = "md" })
fontSection:CreateLabel({ Text = "Label in Arial", Font = "arial", Style = "info", Size = "md" })
fontSection:CreateLabel({ Text = "Label in Code (mono)", Font = "code", Style = "default", Size = "md" })
fontSection:CreateLabel({ Text = "Label in Serif", Font = "serif", Style = "default", Size = "md" })
fontSection:CreateLabel({ Text = "Label in Ubuntu", Font = "ubuntu", Style = "success", Size = "md" })

fontSection:CreateDivider("Paragraph fonts")

fontSection:CreateParagraph({
	Title = "Paragraph in Code font",
	Body = "loadstring(game:HttpGet(url))()\n-- monospace looks great for code snippets",
	Font = "code",
	Size = "sm",
})
fontSection:CreateParagraph({
	Title = "Paragraph in Serif font",
	Body = "This body uses a serif typeface. Great for longer help text or notes that need a softer reading feel.",
	Font = "serif",
	Size = "sm",
})

-- ============================================================================
-- TAB 3 — SETTINGS  (practical use with real flags)
-- ============================================================================
local SettingsTab = Window:CreateTab("Settings")

local appearSection = SettingsTab:CreateSection("Appearance")

appearSection:CreateDropdown({
	Name = "Window Size",
	Flag = "WindowSize",
	Options = { "sm", "md", "lg", "xl" },
	Default = "md",
	Size = "md",
	Callback = function(v)
		-- NOTE: SetSize + SetFont must be called BEFORE CreateWindow.
		-- At runtime, use them to inform the user they need to reload.
		UI:Notify("Reload script to apply size: " .. v, 3, "warn")
	end,
})

appearSection:CreateDropdown({
	Name = "Font",
	Flag = "FontChoice",
	Options = { "gotham", "gothamBold", "arial", "roboto", "code", "serif", "ubuntu", "sourceSans" },
	Default = "gotham",
	Size = "md",
	Callback = function(v)
		UI:Notify("Reload script to apply font: " .. v, 3, "warn")
	end,
})

appearSection:CreateDropdown({
	Name = "Theme",
	Flag = "Theme",
	Options = { "light", "dark", "ocean" },
	Default = "light",
	Size = "md",
	Callback = function(v)
		UI:SetTheme(v)
		UI:Notify("Theme: " .. v, 2, "info")
	end,
})

local configSection = SettingsTab:CreateSection("Config")

configSection:CreateInput({
	Name = "Config Name",
	Flag = "ConfigName",
	Default = "myconfig",
	Placeholder = "e.g. myconfig",
	Size = "md",
	ClearOnFocus = false,
})

configSection:CreateButton({
	Name = "Save Config",
	Style = "accent",
	Size = "md",
	Callback = function()
		UI:SaveConfig(UI.Flags.ConfigName or "myconfig")
		UI:Notify("Saved!", 2, "success")
	end,
})
configSection:CreateButton({
	Name = "Load Config",
	Style = "default",
	Size = "md",
	Callback = function()
		UI:LoadConfig(UI.Flags.ConfigName or "myconfig")
		UI:Notify("Loaded!", 2, "info")
	end,
})
configSection:CreateButton({
	Name = "Reset Flags",
	Style = "danger",
	Size = "sm",
	Callback = function()
		UI.Flags = {}
		UI:Notify("All flags cleared", 2, "warn")
		Window:SetStatus("Flags reset", "idle")
	end,
})

-- ============================================================================
-- PROGRAMMATIC API REFERENCE
-- ============================================================================

--[[ GLOBAL SETUP (before CreateWindow):

    UI:SetSize("sm"|"md"|"lg"|"xl")
    UI:SetFont(baseFont, boldFont?)   -- string alias or Enum.Font
    UI:SetTheme("light"|"dark"|"ocean")

    COMPONENT opts.Size   = "sm"|"md"|"lg"|"xl"   -- overrides global for that one row
    COMPONENT opts.Font   = "code"|"serif"|...     -- overrides font for Button/Input/Label/Paragraph

    WINDOW:
        Window:SetStatus(text, "ok"|"running"|"error"|"idle")

    NOTIFY:
        UI:Notify(text, duration, "info"|"success"|"warn"|"error")

    COMPONENT RETURN HANDLES:
        toggle:SetValue(bool)          toggle:GetValue() → bool
        slider:SetValue(number)        slider:GetValue() → number
        dropdown:SetValue(string)      dropdown:GetValue() → string
        colorPicker:SetValue(Color3)   colorPicker:GetValue() → Color3
        input:SetValue(string)         input:GetValue() → string
        keybind:SetValue(Enum.KeyCode) keybind:GetValue() → KeyCode
        label:SetText(string)          label:GetText() → string
        paragraph:SetBody(string)
--]]

task.delay(1, function()
	UI:Notify("UI loaded! Try the Sizes and Fonts tabs.", 4, "success")
end)
