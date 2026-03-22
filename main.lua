--[[
╔══════════════════════════════════════════════════════════════╗
║  GooBlox UI  —  Complete UI Library  v2.0                    ║
║                                                              ║
║  SIZE SYSTEM   sm · md (default) · lg · xl                   ║
║  THEMES        light · dark · ocean                          ║
║                amber-light · amber-dark                      ║
║                stone-light · stone-dark                      ║
║                warm-light  · warm-dark                       ║
║                blue-light  · blue-dark                       ║
║                                                              ║
║  COMPONENTS    Toggle · Slider · Dropdown · MultiSelect      ║
║                Button · Input · Keybind · ColorPicker        ║
║                Label · Paragraph · Divider · Badge           ║
║                Separator · ProgressBar                       ║
║                                                              ║
║  EXTRAS        Notify · SaveConfig · LoadConfig              ║
║                SetTheme · SetSize · SetFont                  ║
║                Settings tab (built-in, optional)             ║
╚══════════════════════════════════════════════════════════════╝
--]]

local UI = {}
UI.Flags = {}
UI.Version = "2.0"

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")

-- ─── FONT ─────────────────────────────────────────────────────────────────────
local FONT_ALIASES = {
	gotham = "Gotham",
	gothamBold = "GothamBold",
	gothamSemibold = "GothamSemibold",
	arial = "Arial",
	arialBold = "ArialBold",
	roboto = "Roboto",
	code = "Code",
	ubuntu = "Ubuntu",
	sourceSans = "SourceSans",
	serif = "Merriweather",
}
local _fontBase = Enum.Font.Gotham
local _fontBold = Enum.Font.GothamSemibold

local function resolveFont(f)
	if not f then
		return Enum.Font.Gotham
	end
	if type(f) == "string" then
		return Enum.Font[FONT_ALIASES[f] or f] or Enum.Font.Gotham
	end
	return f
end
function UI:SetFont(base, bold)
	_fontBase = resolveFont(base)
	_fontBold = resolveFont(bold) or _fontBase
end

-- ─── SIZE ─────────────────────────────────────────────────────────────────────
local _scale = 1.0
local function s(n)
	return math.floor(n * _scale + 0.5)
end
local SZ = {}
local function buildSZ()
	SZ = {
		W = s(520),
		H = s(400),
		TH = s(38),
		SW = s(118),
		SBH = s(22),
		txtXS = s(9),
		txtSM = s(11),
		txtMD = s(12),
		txtLG = s(14),
		txtXL = s(16),
		rowSM = s(28),
		rowMD = s(36),
		rowLG = s(42),
		rowXL = s(52),
		rowSlider = s(46),
		pillW = s(36),
		pillH = s(20),
		thumbSz = s(14),
		trackH = s(5),
		handleSz = s(14),
		btnH = s(26),
		inputH = s(24),
		dotSz = s(13),
		tabH = s(30),
		tabPad = s(8),
		tabGap = s(2),
		secHdrH = s(28),
		iconSz = s(22),
		notifW = s(250),
		notifH = s(54),
	}
	SZ.CW = SZ.W - SZ.SW
	SZ.CH = SZ.H - SZ.TH - SZ.SBH
end
buildSZ()

function UI:SetSize(p)
	local m = ({ sm = 0.82, md = 1.00, lg = 1.18, xl = 1.38 })[p]
	if not m then
		warn("GooBloxUI: unknown size '" .. tostring(p) .. "'")
		return
	end
	_scale = m
	buildSZ()
end

-- ─── THEMES ───────────────────────────────────────────────────────────────────
-- Each theme has these semantic keys:
--   Base      = window background
--   Surface   = titlebar/sidebar background
--   Panel     = subtle borders, section headers
--   Border    = UI strokes
--   Card      = row / section card background  ← NOT always white
--   Dark      = button fill (default style)
--   Accent    = primary color
--   Danger    = destructive actions
--   Text      = primary text
--   Muted     = secondary/hint text
--   White     = always literal white (for icon letters, toggle thumb)
--   Green     = success
--   Amber     = warning
--   TagBg     = multi-select/badge background
--   TagText   = multi-select/badge text
--   Hover     = row hover state

local THEMES = {
	-- ── LIGHT (original, confirmed working) ──────────────────────────────────
	light = {
		Base = Color3.fromRGB(245, 245, 245),
		Surface = Color3.fromRGB(236, 236, 236),
		Panel = Color3.fromRGB(224, 224, 224),
		Border = Color3.fromRGB(200, 200, 200),
		Card = Color3.fromRGB(255, 255, 255),
		Dark = Color3.fromRGB(58, 58, 58),
		Accent = Color3.fromRGB(92, 107, 192),
		Danger = Color3.fromRGB(239, 83, 80),
		Text = Color3.fromRGB(26, 26, 26),
		Muted = Color3.fromRGB(120, 120, 120),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(99, 153, 34),
		Amber = Color3.fromRGB(186, 117, 23),
		TagBg = Color3.fromRGB(232, 233, 245),
		TagText = Color3.fromRGB(57, 73, 171),
		Hover = Color3.fromRGB(238, 238, 245),
	},
	-- ── DARK (fixed: Card ≠ White) ────────────────────────────────────────────
	dark = {
		Base = Color3.fromRGB(22, 22, 26),
		Surface = Color3.fromRGB(30, 30, 36),
		Panel = Color3.fromRGB(42, 42, 50),
		Border = Color3.fromRGB(58, 58, 68),
		Card = Color3.fromRGB(34, 34, 40),
		Dark = Color3.fromRGB(200, 200, 210),
		Accent = Color3.fromRGB(110, 130, 220),
		Danger = Color3.fromRGB(239, 83, 80),
		Text = Color3.fromRGB(225, 225, 232),
		Muted = Color3.fromRGB(110, 110, 128),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(100, 175, 45),
		Amber = Color3.fromRGB(210, 150, 40),
		TagBg = Color3.fromRGB(44, 48, 85),
		TagText = Color3.fromRGB(140, 160, 255),
		Hover = Color3.fromRGB(42, 42, 52),
	},
	-- ── OCEAN (fixed: Card ≠ White) ───────────────────────────────────────────
	ocean = {
		Base = Color3.fromRGB(10, 20, 36),
		Surface = Color3.fromRGB(14, 28, 50),
		Panel = Color3.fromRGB(20, 40, 68),
		Border = Color3.fromRGB(28, 56, 90),
		Card = Color3.fromRGB(15, 32, 55),
		Dark = Color3.fromRGB(175, 210, 245),
		Accent = Color3.fromRGB(0, 170, 255),
		Danger = Color3.fromRGB(239, 83, 80),
		Text = Color3.fromRGB(195, 225, 255),
		Muted = Color3.fromRGB(80, 125, 170),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(35, 210, 140),
		Amber = Color3.fromRGB(255, 180, 40),
		TagBg = Color3.fromRGB(0, 44, 75),
		TagText = Color3.fromRGB(0, 200, 255),
		Hover = Color3.fromRGB(18, 38, 65),
	},
	-- ── AMBER LIGHT (doc 5 light — warm neutral, amber primary) ──────────────
	-- primary: oklch(0.77 0.16 70) ≈ RGB(219,172,90)
	-- background: oklch(0.98 0 0) ≈ white
	["amber-light"] = {
		Base = Color3.fromRGB(250, 249, 246),
		Surface = Color3.fromRGB(242, 241, 237),
		Panel = Color3.fromRGB(230, 228, 220),
		Border = Color3.fromRGB(210, 208, 198),
		Card = Color3.fromRGB(255, 255, 253),
		Dark = Color3.fromRGB(55, 48, 38),
		Accent = Color3.fromRGB(210, 162, 72),
		Danger = Color3.fromRGB(210, 70, 60),
		Text = Color3.fromRGB(40, 35, 25),
		Muted = Color3.fromRGB(115, 108, 92),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(95, 150, 30),
		Amber = Color3.fromRGB(185, 115, 20),
		TagBg = Color3.fromRGB(252, 244, 220),
		TagText = Color3.fromRGB(140, 90, 20),
		Hover = Color3.fromRGB(244, 242, 234),
	},
	-- ── AMBER DARK (doc 5 dark) ───────────────────────────────────────────────
	-- background: oklch(0.20 0 0) ≈ RGB(42,42,42)
	-- card: oklch(0.27 0 0) ≈ RGB(62,62,62)
	-- primary: oklch(0.77 0.16 70) ≈ same amber
	["amber-dark"] = {
		Base = Color3.fromRGB(30, 28, 24),
		Surface = Color3.fromRGB(38, 36, 30),
		Panel = Color3.fromRGB(52, 50, 42),
		Border = Color3.fromRGB(70, 66, 54),
		Card = Color3.fromRGB(40, 38, 32),
		Dark = Color3.fromRGB(215, 205, 185),
		Accent = Color3.fromRGB(215, 172, 80),
		Danger = Color3.fromRGB(239, 83, 80),
		Text = Color3.fromRGB(232, 222, 198),
		Muted = Color3.fromRGB(140, 130, 108),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(105, 175, 45),
		Amber = Color3.fromRGB(215, 155, 42),
		TagBg = Color3.fromRGB(60, 52, 32),
		TagText = Color3.fromRGB(220, 175, 80),
		Hover = Color3.fromRGB(48, 46, 38),
	},
	-- ── STONE LIGHT (doc 6 light — cool stone/slate) ─────────────────────────
	-- primary: oklch(0.43 0.04 42) ≈ RGB(100,85,70)
	-- background: oklch(0.98 0 0) ≈ near white
	["stone-light"] = {
		Base = Color3.fromRGB(249, 248, 248),
		Surface = Color3.fromRGB(241, 240, 239),
		Panel = Color3.fromRGB(228, 226, 224),
		Border = Color3.fromRGB(210, 207, 203),
		Card = Color3.fromRGB(255, 254, 254),
		Dark = Color3.fromRGB(58, 54, 50),
		Accent = Color3.fromRGB(100, 84, 68),
		Danger = Color3.fromRGB(185, 75, 60),
		Text = Color3.fromRGB(34, 30, 26),
		Muted = Color3.fromRGB(118, 112, 105),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(90, 145, 30),
		Amber = Color3.fromRGB(175, 118, 20),
		TagBg = Color3.fromRGB(240, 234, 228),
		TagText = Color3.fromRGB(100, 84, 68),
		Hover = Color3.fromRGB(242, 240, 237),
	},
	-- ── STONE DARK (doc 6 dark) ───────────────────────────────────────────────
	-- background: oklch(0.18 0 0) ≈ RGB(38,38,38)
	-- card: oklch(0.21 0 0) ≈ RGB(46,46,46)
	-- primary dark: oklch(0.92 0.05 66) ≈ RGB(242,222,188)
	["stone-dark"] = {
		Base = Color3.fromRGB(30, 28, 26),
		Surface = Color3.fromRGB(38, 36, 33),
		Panel = Color3.fromRGB(50, 47, 44),
		Border = Color3.fromRGB(66, 62, 57),
		Card = Color3.fromRGB(40, 38, 35),
		Dark = Color3.fromRGB(212, 205, 195),
		Accent = Color3.fromRGB(235, 215, 182),
		Danger = Color3.fromRGB(185, 75, 60),
		Text = Color3.fromRGB(228, 222, 214),
		Muted = Color3.fromRGB(135, 128, 118),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(100, 175, 45),
		Amber = Color3.fromRGB(212, 155, 42),
		TagBg = Color3.fromRGB(58, 50, 42),
		TagText = Color3.fromRGB(235, 215, 182),
		Hover = Color3.fromRGB(48, 46, 42),
	},
	-- ── WARM LIGHT (doc 7 light — warm gray, orange accent) ──────────────────
	-- primary: oklch(0.62 0.14 39) ≈ RGB(182,108,70)
	-- background: oklch(0.98 0.005 95) ≈ very warm white
	["warm-light"] = {
		Base = Color3.fromRGB(251, 249, 244),
		Surface = Color3.fromRGB(242, 238, 230),
		Panel = Color3.fromRGB(228, 222, 210),
		Border = Color3.fromRGB(208, 200, 185),
		Card = Color3.fromRGB(255, 253, 248),
		Dark = Color3.fromRGB(55, 46, 34),
		Accent = Color3.fromRGB(175, 102, 62),
		Danger = Color3.fromRGB(195, 72, 60),
		Text = Color3.fromRGB(42, 35, 22),
		Muted = Color3.fromRGB(120, 110, 90),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(90, 148, 30),
		Amber = Color3.fromRGB(178, 115, 20),
		TagBg = Color3.fromRGB(248, 238, 225),
		TagText = Color3.fromRGB(150, 88, 45),
		Hover = Color3.fromRGB(244, 240, 230),
	},
	-- ── WARM DARK (doc 7 dark) ────────────────────────────────────────────────
	-- background: oklch(0.27 0.004 107) ≈ RGB(58,55,48)
	-- card: same range
	-- primary dark: oklch(0.67 0.13 39) ≈ RGB(195,120,75)
	["warm-dark"] = {
		Base = Color3.fromRGB(36, 33, 28),
		Surface = Color3.fromRGB(45, 41, 35),
		Panel = Color3.fromRGB(58, 54, 46),
		Border = Color3.fromRGB(76, 70, 58),
		Card = Color3.fromRGB(44, 40, 34),
		Dark = Color3.fromRGB(210, 200, 182),
		Accent = Color3.fromRGB(188, 116, 72),
		Danger = Color3.fromRGB(185, 75, 60),
		Text = Color3.fromRGB(225, 215, 196),
		Muted = Color3.fromRGB(138, 128, 108),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(100, 172, 45),
		Amber = Color3.fromRGB(210, 152, 40),
		TagBg = Color3.fromRGB(62, 52, 38),
		TagText = Color3.fromRGB(195, 148, 88),
		Hover = Color3.fromRGB(52, 48, 40),
	},
	-- ── BLUE LIGHT (doc 8 light — blue/violet, Inter font) ───────────────────
	-- primary: oklch(0.59 0.20 277) ≈ RGB(88,100,220)
	-- background: oklch(0.984 0.003 248) ≈ very light blue-tinted white
	["blue-light"] = {
		Base = Color3.fromRGB(245, 246, 251),
		Surface = Color3.fromRGB(235, 237, 247),
		Panel = Color3.fromRGB(220, 223, 240),
		Border = Color3.fromRGB(200, 204, 228),
		Card = Color3.fromRGB(255, 255, 255),
		Dark = Color3.fromRGB(40, 44, 68),
		Accent = Color3.fromRGB(88, 102, 220),
		Danger = Color3.fromRGB(200, 68, 60),
		Text = Color3.fromRGB(30, 34, 58),
		Muted = Color3.fromRGB(100, 108, 148),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(40, 175, 100),
		Amber = Color3.fromRGB(195, 145, 30),
		TagBg = Color3.fromRGB(230, 233, 250),
		TagText = Color3.fromRGB(55, 70, 185),
		Hover = Color3.fromRGB(238, 240, 252),
	},
	-- ── BLUE DARK (doc 8 dark) ────────────────────────────────────────────────
	-- background: oklch(0.21 0.04 266) ≈ RGB(28,30,58)
	-- card: oklch(0.28 0.037 260) ≈ RGB(40,44,78)
	-- primary dark: oklch(0.68 0.16 277) ≈ RGB(108,128,230)
	["blue-dark"] = {
		Base = Color3.fromRGB(22, 25, 50),
		Surface = Color3.fromRGB(30, 34, 65),
		Panel = Color3.fromRGB(42, 48, 85),
		Border = Color3.fromRGB(58, 65, 108),
		Card = Color3.fromRGB(32, 36, 68),
		Dark = Color3.fromRGB(185, 195, 235),
		Accent = Color3.fromRGB(108, 128, 230),
		Danger = Color3.fromRGB(200, 68, 60),
		Text = Color3.fromRGB(200, 210, 245),
		Muted = Color3.fromRGB(100, 112, 160),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(40, 195, 110),
		Amber = Color3.fromRGB(210, 158, 42),
		TagBg = Color3.fromRGB(42, 50, 95),
		TagText = Color3.fromRGB(140, 165, 255),
		Hover = Color3.fromRGB(38, 44, 80),
	},
}

local C = THEMES.light
local _themed = {}
local _currentThemeName = "light"

local function reg(obj, prop, key)
	table.insert(_themed, { obj = obj, prop = prop, key = key })
	obj[prop] = C[key]
	return obj
end

function UI:SetTheme(name)
	local t = THEMES[name]
	if not t then
		warn("GooBloxUI: unknown theme '" .. tostring(name) .. "'")
		return
	end
	C = t
	_currentThemeName = name
	for _, e in pairs(_themed) do
		pcall(function()
			e.obj[e.prop] = C[e.key]
		end)
	end
end

function UI:GetTheme()
	return _currentThemeName
end
function UI:GetThemeList()
	local list = {}
	for k in pairs(THEMES) do
		table.insert(list, k)
	end
	table.sort(list)
	return list
end
function UI:AddTheme(name, tbl)
	THEMES[name] = tbl
end

-- ─── LOW-LEVEL HELPERS ────────────────────────────────────────────────────────
local function tw(o, p, t)
	TS:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), p):Play()
end

local function rnd(o, r)
	local u = Instance.new("UICorner", o)
	u.CornerRadius = UDim.new(0, r or s(6))
end

local function stroke(o, key, th)
	local st = Instance.new("UIStroke", o)
	st.Thickness = th or 1
	table.insert(_themed, { obj = st, prop = "Color", key = key or "Border" })
	st.Color = C[key or "Border"]
	return st
end

local function mkframe(parent, x, y, w, h, colorKey, z)
	local f = Instance.new("Frame", parent)
	f.Position = UDim2.new(0, x, 0, y)
	f.Size = UDim2.new(0, w, 0, h)
	f.BorderSizePixel = 0
	f.ZIndex = z or 5
	reg(f, "BackgroundColor3", colorKey or "Card")
	return f
end

local function mklabel(parent, text, x, y, w, h, colorKey, sz, bold, z)
	local l = Instance.new("TextLabel", parent)
	l.Position = UDim2.new(0, x, 0, y)
	l.Size = UDim2.new(0, w, 0, h)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = bold and _fontBold or _fontBase
	l.TextSize = sz or SZ.txtMD
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.ZIndex = z or 5
	l.ClipsDescendants = false
	reg(l, "TextColor3", colorKey or "Text")
	return l
end

-- ─── NOTIFY ───────────────────────────────────────────────────────────────────
local _notifStack = {}
local function _restack()
	local gap = s(6)
	local y = -(s(10))
	for i = #_notifStack, 1, -1 do
		local n = _notifStack[i]
		if n and n.Parent then
			y = y - SZ.notifH - gap
			tw(n, { Position = UDim2.new(1, -(SZ.notifW + s(12)), 1, y) }, 0.2)
		else
			table.remove(_notifStack, i)
		end
	end
end

function UI:Notify(text, duration, kind)
	duration = duration or 3
	local gui = game:GetService("CoreGui"):FindFirstChild("FlatGrayUI")
	if not gui then
		return
	end
	local kinds = {
		info = { bg = Color3.fromRGB(32, 38, 65), bar = C.Accent, tc = Color3.fromRGB(175, 200, 255) },
		success = { bg = Color3.fromRGB(22, 48, 28), bar = Color3.fromRGB(80, 175, 80), tc = Color3.fromRGB(
			155,
			228,
			155
		) },
		warn = { bg = Color3.fromRGB(52, 40, 18), bar = Color3.fromRGB(210, 150, 40), tc = Color3.fromRGB(238, 195, 98) },
		error = { bg = Color3.fromRGB(58, 20, 20), bar = Color3.fromRGB(220, 70, 70), tc = Color3.fromRGB(
			255,
			155,
			155
		) },
	}
	local k = kinds[kind] or kinds.info
	local nW, nH = SZ.notifW, SZ.notifH
	local n = Instance.new("Frame", gui)
	n.Size = UDim2.new(0, nW, 0, nH)
	n.Position = UDim2.new(1, s(20), 1, -(nH + s(10))) -- off-screen right
	n.BackgroundColor3 = k.bg
	n.BorderSizePixel = 0
	n.ZIndex = 200
	rnd(n, s(8))
	local ns = Instance.new("UIStroke", n)
	ns.Color = k.bar
	ns.Thickness = 1
	ns.Transparency = 0.5
	local bar = Instance.new("Frame", n)
	bar.Size = UDim2.new(0, s(4), 1, -s(14))
	bar.Position = UDim2.new(0, s(8), 0, s(7))
	bar.BackgroundColor3 = k.bar
	bar.BorderSizePixel = 0
	bar.ZIndex = 201
	rnd(bar, s(3))
	local tl = Instance.new("TextLabel", n)
	tl.Size = UDim2.new(1, -s(22), 1, 0)
	tl.Position = UDim2.new(0, s(18), 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = text
	tl.TextColor3 = k.tc
	tl.Font = _fontBase
	tl.TextSize = SZ.txtSM
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.TextWrapped = true
	tl.ZIndex = 201
	table.insert(_notifStack, n)
	_restack()
	task.delay(duration, function()
		tw(n, { Position = UDim2.new(1, s(20), 1, n.Position.Y.Offset) }, 0.2)
		task.wait(0.22)
		n:Destroy()
		for i, v in ipairs(_notifStack) do
			if v == n then
				table.remove(_notifStack, i)
				break
			end
		end
		_restack()
	end)
end

-- ─── CONFIG ───────────────────────────────────────────────────────────────────
local function encodeV(v)
	local t = type(v)
	if t == "boolean" or t == "number" or t == "string" then
		return v
	end
	if t == "table" then
		local out = {}
		for k, val in pairs(v) do
			out[tostring(k)] = encodeV(val)
		end
		return out
	end
	if typeof and typeof(v) == "Color3" then
		return { __t = "c3", r = v.R, g = v.G, b = v.B }
	end
	if typeof and typeof(v) == "EnumItem" then
		return { __t = "ei", et = tostring(v.EnumType), n = v.Name }
	end
	return nil
end
local function decodeV(v)
	if type(v) ~= "table" then
		return v
	end
	if v.__t == "c3" then
		return Color3.new(v.r, v.g, v.b)
	end
	if v.__t == "ei" then
		local ok, r = pcall(function()
			return Enum[v.et][v.n]
		end)
		return ok and r or nil
	end
	local out = {}
	for k, val in pairs(v) do
		if k ~= "__t" then
			out[k] = decodeV(val)
		end
	end
	return out
end

function UI:SaveConfig(name)
	local enc = {}
	for k, v in pairs(UI.Flags) do
		local e = encodeV(v)
		if e ~= nil then
			enc[k] = e
		end
	end
	-- also save theme + size
	enc["__theme"] = _currentThemeName
	enc["__scale"] = _scale
	pcall(function()
		writefile((name or "GooBloxUI") .. ".json", HS:JSONEncode(enc))
	end)
end

function UI:LoadConfig(name)
	local ok, data = pcall(function()
		if not isfile((name or "GooBloxUI") .. ".json") then
			return nil
		end
		return HS:JSONDecode(readfile((name or "GooBloxUI") .. ".json"))
	end)
	if not ok or not data then
		return
	end
	for k, v in pairs(data) do
		if k == "__theme" then
			UI:SetTheme(v)
		elseif k == "__scale" then
			_scale = v
			buildSZ()
		else
			UI.Flags[k] = decodeV(v)
		end
	end
end

-- ─── CREATE WINDOW ────────────────────────────────────────────────────────────
-- opts = { Title, Subtitle, ShowSettings, AutoSave, ConfigName }
function UI:CreateWindow(title, subtitleOrOpts)
	local subtitle, showSettings, autoSaveName
	if type(subtitleOrOpts) == "table" then
		subtitle = subtitleOrOpts.Subtitle
		showSettings = subtitleOrOpts.ShowSettings ~= false -- default true
		autoSaveName = subtitleOrOpts.AutoSave -- string = config name, nil = off
	else
		subtitle = subtitleOrOpts
		showSettings = true
		autoSaveName = nil
	end

	local cg = game:GetService("CoreGui")
	local old = cg:FindFirstChild("FlatGrayUI")
	if old then
		old:Destroy()
	end
	_themed = {}
	_notifStack = {}

	local W, H, TH, SW, SBH = SZ.W, SZ.H, SZ.TH, SZ.SW, SZ.SBH
	local CW, CH = SZ.CW, SZ.CH

	local gui = Instance.new("ScreenGui")
	gui.Name = "FlatGrayUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.IgnoreGuiInset = true
	gui.Parent = cg

	-- Main frame
	local main = Instance.new("Frame", gui)
	main.Name = "Main"
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = UDim2.new(0, W, 0, 0)
	main.BorderSizePixel = 0
	main.Active = true
	main.ClipsDescendants = true
	main.ZIndex = 10
	reg(main, "BackgroundColor3", "Base")
	rnd(main, s(10))
	stroke(main, "Border", 1)
	tw(main, { Size = UDim2.new(0, W, 0, H) }, 0.22)

	-- Titlebar
	local tb = mkframe(main, 0, 0, W, TH, "Surface", 11)
	mkframe(tb, 0, TH - 1, W, 1, "Border", 12)
	-- Icon circle (always accent bg, always white letter)
	local ic = Instance.new("Frame", tb)
	ic.Position = UDim2.new(0, s(10), 0, s(8))
	ic.Size = UDim2.new(0, SZ.iconSz, 0, SZ.iconSz)
	ic.BorderSizePixel = 0
	ic.ZIndex = 12
	reg(ic, "BackgroundColor3", "Accent")
	rnd(ic, SZ.iconSz)
	local icl = Instance.new("TextLabel", ic)
	icl.Size = UDim2.new(1, 0, 1, 0)
	icl.BackgroundTransparency = 1
	icl.Text = string.upper(string.sub(title, 1, 1))
	icl.TextColor3 = Color3.new(1, 1, 1) -- literal white always
	icl.Font = _fontBold
	icl.TextSize = SZ.txtSM
	icl.TextXAlignment = Enum.TextXAlignment.Center
	icl.ZIndex = 13
	mklabel(tb, title, SZ.iconSz + s(16), 0, s(200), TH, "Text", SZ.txtMD, true, 12)
	if subtitle then
		local sbg = Instance.new("Frame", tb)
		sbg.Position = UDim2.new(0, SZ.iconSz + s(145), 0, s(10))
		sbg.Size = UDim2.new(0, s(52), 0, s(18))
		sbg.BorderSizePixel = 0
		sbg.ZIndex = 12
		reg(sbg, "BackgroundColor3", "TagBg")
		rnd(sbg, 99)
		local sl = mklabel(sbg, subtitle, 0, 0, s(52), s(18), "TagText", SZ.txtXS, true, 13)
		sl.TextXAlignment = Enum.TextXAlignment.Center
	end
	-- Dots
	local dotDefs = {
		{ "Danger", Color3.fromRGB(195, 55, 50) },
		{ "Border", Color3.fromRGB(148, 148, 148) },
		{ "Panel", Color3.fromRGB(168, 168, 168) },
	}
	local dots = {}
	for i, d in ipairs(dotDefs) do
		local dot = Instance.new("TextButton", tb)
		dot.Size = UDim2.new(0, SZ.dotSz, 0, SZ.dotSz)
		dot.Position = UDim2.new(1, -(i * (SZ.dotSz + s(5)) + s(4)), 0, math.floor((TH - SZ.dotSz) / 2))
		dot.BorderSizePixel = 0
		dot.Text = ""
		dot.AutoButtonColor = false
		dot.ZIndex = 12
		reg(dot, "BackgroundColor3", d[1])
		rnd(dot, 99)
		dot.MouseEnter:Connect(function()
			tw(dot, { BackgroundColor3 = d[2] }, 0.1)
		end)
		dot.MouseLeave:Connect(function()
			tw(dot, { BackgroundColor3 = C[d[1]] }, 0.1)
		end)
		dots[i] = dot
	end
	dots[1].MouseButton1Click:Connect(function()
		tw(main, { Size = UDim2.new(0, W, 0, 0) }, 0.18)
		task.wait(0.2)
		gui:Destroy()
	end)
	local minimized = false
	dots[2].MouseButton1Click:Connect(function()
		minimized = not minimized
		tw(main, { Size = minimized and UDim2.new(0, W, 0, TH) or UDim2.new(0, W, 0, H) }, 0.2)
	end)
	UIS.InputBegan:Connect(function(inp, gp)
		if gp then
			return
		end
		if inp.KeyCode == Enum.KeyCode.RightControl then
			gui.Enabled = not gui.Enabled
		end
	end)
	-- Drag
	do
		local drag, ds, sp = false, nil, nil
		tb.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				drag = true
				ds = i.Position
				sp = main.Position
			end
		end)
		UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				drag = false
			end
		end)
		UIS.InputChanged:Connect(function(i)
			if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
				local d = i.Position - ds
				main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
			end
		end)
	end
	-- Sidebar
	local sidebar = mkframe(main, 0, TH, SW, CH, "Surface", 11)
	sidebar.ClipsDescendants = true
	mkframe(sidebar, SW - 1, 0, 1, CH, "Border", 12)
	-- Content
	local contentArea = Instance.new("Frame", main)
	contentArea.Position = UDim2.new(0, SW, 0, TH)
	contentArea.Size = UDim2.new(0, CW, 0, CH)
	contentArea.BackgroundTransparency = 1
	contentArea.ClipsDescendants = true
	contentArea.ZIndex = 11
	-- Statusbar
	local sb = mkframe(main, 0, H - SBH, W, SBH, "Surface", 11)
	mkframe(sb, 0, 0, W, 1, "Border", 12)
	local sbDot = mkframe(sb, s(10), math.floor((SBH - s(7)) / 2), s(7), s(7), "Green", 12)
	rnd(sbDot, 99)
	local sbTxt = mklabel(sb, "Ready", s(22), 0, W - s(110), SBH, "Text", SZ.txtXS, false, 12)
	local sbVer = mklabel(sb, subtitle or "v2.0", W - s(96), 0, s(90), SBH, "Muted", SZ.txtXS, false, 12)
	sbVer.TextXAlignment = Enum.TextXAlignment.Right

	-- Window API
	local window = {}
	local pages, tabBtns, tabCount = {}, {}, 0

	function window:SetStatus(text, kind)
		sbTxt.Text = text or "Ready"
		local col = ({ ok = C.Green, running = C.Amber, error = C.Danger, idle = C.Border })[kind or "ok"] or C.Green
		tw(sbDot, { BackgroundColor3 = col }, 0.2)
	end
	function window:Notify(opts)
		UI:Notify(opts.Content or opts.Title or "", opts.Duration or 3, opts.kind)
	end

	-- ── CREATE TAB ────────────────────────────────────────────────────────────
	function window:CreateTab(name)
		tabCount = tabCount + 1
		local idx = tabCount
		local isFirst = (idx == 1)
		local yPos = SZ.tabPad + (idx - 1) * (SZ.tabH + SZ.tabGap)
		local btn = Instance.new("TextButton", sidebar)
		btn.Size = UDim2.new(0, SW - s(12), 0, SZ.tabH)
		btn.Position = UDim2.new(0, s(6), 0, yPos)
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 13
		reg(btn, "BackgroundColor3", isFirst and "Card" or "Surface")
		rnd(btn, s(5))
		local bar = mkframe(btn, 0, s(4), s(3), SZ.tabH - s(8), "Accent", 14)
		bar.Visible = isFirst
		local btnLbl =
			mklabel(btn, name, s(10), 0, SW - s(26), SZ.tabH, isFirst and "Text" or "Muted", SZ.txtSM, isFirst, 14)
		local page = Instance.new("ScrollingFrame", contentArea)
		page.Size = UDim2.new(0, CW, 0, CH)
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = s(4)
		page.BorderSizePixel = 0
		page.BackgroundTransparency = 1
		page.Visible = isFirst
		page.ZIndex = 12
		table.insert(_themed, { obj = page, prop = "ScrollBarImageColor3", key = "Border" })
		page.ScrollBarImageColor3 = C.Border
		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0, s(6))
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		local pad = Instance.new("UIPadding", page)
		pad.PaddingTop = UDim.new(0, s(10))
		pad.PaddingLeft = UDim.new(0, s(10))
		pad.PaddingRight = UDim.new(0, s(10))
		pad.PaddingBottom = UDim.new(0, s(10))
		table.insert(pages, page)
		table.insert(tabBtns, { btn = btn, bar = bar, lbl = btnLbl })
		btn.MouseButton1Click:Connect(function()
			for _, p in pairs(pages) do
				p.Visible = false
			end
			for _, t in pairs(tabBtns) do
				t.bar.Visible = false
				t.btn.BackgroundColor3 = C.Surface
				t.lbl.TextColor3 = C.Muted
				t.lbl.Font = _fontBase
			end
			page.Visible = true
			bar.Visible = true
			btn.BackgroundColor3 = C.Card
			btnLbl.TextColor3 = C.Text
			btnLbl.Font = _fontBold
		end)
		btn.MouseEnter:Connect(function()
			if not page.Visible then
				tw(btn, { BackgroundColor3 = C.Panel }, 0.1)
			end
		end)
		btn.MouseLeave:Connect(function()
			if not page.Visible then
				tw(btn, { BackgroundColor3 = C.Surface }, 0.1)
			end
		end)

		-- ── CREATE SECTION ────────────────────────────────────────────────────
		local tab = {}
		local RW = CW - s(20)

		function tab:CreateSection(secName)
			local sec = Instance.new("Frame", page)
			sec.Size = UDim2.new(0, RW, 0, 0)
			sec.AutomaticSize = Enum.AutomaticSize.Y
			sec.BorderSizePixel = 0
			sec.ZIndex = 13
			reg(sec, "BackgroundColor3", "Card")
			rnd(sec, s(8))
			stroke(sec, "Panel", 1)
			local hdr = mkframe(sec, 0, 0, RW, SZ.secHdrH, "Surface", 14)
			rnd(hdr, s(8))
			mkframe(hdr, 0, SZ.secHdrH - s(8), RW, s(8), "Surface", 14)
			mkframe(hdr, 0, SZ.secHdrH - 1, RW, 1, "Panel", 15)
			local ad = mkframe(hdr, s(9), math.floor((SZ.secHdrH - s(4)) / 2), s(4), s(4), "Accent", 15)
			rnd(ad, 99)
			mklabel(hdr, secName, s(18), 0, RW - s(24), SZ.secHdrH, "Muted", SZ.txtXS, true, 15)
			local holder = Instance.new("Frame", sec)
			holder.Size = UDim2.new(0, RW, 0, 0)
			holder.Position = UDim2.new(0, 0, 0, SZ.secHdrH)
			holder.AutomaticSize = Enum.AutomaticSize.Y
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = 13
			local hl = Instance.new("UIListLayout", holder)
			hl.Padding = UDim.new(0, 0)
			hl.SortOrder = Enum.SortOrder.LayoutOrder
			local hp = Instance.new("UIPadding", holder)
			hp.PaddingBottom = UDim.new(0, s(6))

			local api = {}

			-- row factory
			local function row(h, autoSize)
				local r = Instance.new("Frame", holder)
				if autoSize then
					r.Size = UDim2.new(0, RW, 0, 0)
					r.AutomaticSize = Enum.AutomaticSize.Y
				else
					r.Size = UDim2.new(0, RW, 0, h)
				end
				r.BorderSizePixel = 0
				r.ZIndex = 14
				r.ClipsDescendants = false
				reg(r, "BackgroundColor3", "Card")
				mkframe(r, s(10), h and (h - 1) or 0, RW - s(20), 1, "Panel", 14)
				r.MouseEnter:Connect(function()
					tw(r, { BackgroundColor3 = C.Hover }, 0.08)
				end)
				r.MouseLeave:Connect(function()
					tw(r, { BackgroundColor3 = C.Card }, 0.08)
				end)
				return r
			end

			-- ── TOGGLE ──────────────────────────────────────────────────────
			function api:CreateToggle(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local r = row(rh)
				local state = opts.CurrentValue or false
				local nameY = math.floor((rh - s(14)) / 2)
				mklabel(r, opts.Name, s(12), nameY, RW - s(60), s(14), "Text", SZ.txtMD, false, 15)
				if opts.Description then
					mklabel(r, opts.Description, s(12), nameY + s(16), RW - s(60), s(12), "Muted", SZ.txtXS, false, 15)
				end
				local pill = mkframe(
					r,
					RW - s(46),
					math.floor((rh - SZ.pillH) / 2),
					SZ.pillW,
					SZ.pillH,
					state and "Accent" or "Panel",
					15
				)
				rnd(pill, 99)
				local thumb = Instance.new("Frame", pill)
				thumb.Size = UDim2.new(0, SZ.thumbSz, 0, SZ.thumbSz)
				thumb.Position = UDim2.new(
					0,
					state and (SZ.pillW - SZ.thumbSz - s(3)) or s(3),
					0,
					math.floor((SZ.pillH - SZ.thumbSz) / 2)
				)
				thumb.BorderSizePixel = 0
				thumb.ZIndex = 16
				thumb.BackgroundColor3 = Color3.new(1, 1, 1)
				rnd(thumb, 99)
				stroke(thumb, "Border", 1)
				local function refresh()
					UI.Flags[opts.Flag] = state
					tw(pill, { BackgroundColor3 = state and C.Accent or C.Panel }, 0.15)
					tw(
						thumb,
						{
							Position = UDim2.new(
								0,
								state and (SZ.pillW - SZ.thumbSz - s(3)) or s(3),
								0,
								math.floor((SZ.pillH - SZ.thumbSz) / 2)
							),
						},
						0.15
					)
					if opts.Callback then
						opts.Callback(state)
					end
					if autoSaveName then
						UI:SaveConfig(autoSaveName)
					end
				end
				local hit = Instance.new("TextButton", r)
				hit.Size = UDim2.new(0, RW, 0, rh)
				hit.BackgroundTransparency = 1
				hit.Text = ""
				hit.ZIndex = 17
				hit.MouseButton1Click:Connect(function()
					state = not state
					refresh()
				end)
				return {
					SetValue = function(_, v)
						state = v
						refresh()
					end,
					GetValue = function(_)
						return state
					end,
				}
			end

			-- ── SLIDER ──────────────────────────────────────────────────────
			function api:CreateSlider(opts)
				local rh = ({ sm = s(38), md = SZ.rowSlider, lg = s(54), xl = s(62) })[opts.Size] or SZ.rowSlider
				local r = row(rh)
				local trkY = rh - s(13)
				local nl = mklabel(
					r,
					opts.Name .. ": " .. (opts.CurrentValue or opts.Min),
					s(12),
					s(4),
					RW - s(20),
					s(14),
					"Text",
					SZ.txtMD,
					false,
					15
				)
				local track = mkframe(r, s(12), trkY, RW - s(24), SZ.trackH, "Panel", 15)
				rnd(track, 99)
				local fill = mkframe(track, 0, 0, 0, SZ.trackH, "Accent", 16)
				rnd(fill, 99)
				local handle = Instance.new("Frame", track)
				handle.Size = UDim2.new(0, SZ.handleSz, 0, SZ.handleSz)
				handle.AnchorPoint = Vector2.new(0.5, 0.5)
				handle.Position = UDim2.new(0, 0, 0.5, 0)
				handle.BorderSizePixel = 0
				handle.ZIndex = 17
				handle.BackgroundColor3 = Color3.new(1, 1, 1)
				rnd(handle, 99)
				stroke(handle, "Accent", 2)
				local val = math.clamp(opts.CurrentValue or opts.Min, opts.Min, opts.Max)
				local dragging = false
				local function upd(v)
					v = math.clamp(math.floor(v + 0.5), opts.Min, opts.Max)
					val = v
					local pct = (v - opts.Min) / (opts.Max - opts.Min)
					fill.Size = UDim2.new(pct, 0, 1, 0)
					handle.Position = UDim2.new(pct, 0, 0.5, 0)
					nl.Text = opts.Name .. ": " .. v
					UI.Flags[opts.Flag] = v
					if opts.Callback then
						opts.Callback(v)
					end
					if autoSaveName then
						UI:SaveConfig(autoSaveName)
					end
				end
				upd(val)
				track.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						upd(
							opts.Min
								+ (opts.Max - opts.Min)
									* math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						)
					end
				end)
				UIS.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				UIS.InputChanged:Connect(function(i)
					if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						upd(
							opts.Min
								+ (opts.Max - opts.Min)
									* math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						)
					end
				end)
				return {
					SetValue = function(_, v)
						upd(v)
					end,
					GetValue = function(_)
						return val
					end,
				}
			end

			-- ── DROPDOWN ────────────────────────────────────────────────────
			-- Fully scrollable: shows up to 8 items then scrolls
			function api:CreateDropdown(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local r = row(rh)
				mklabel(r, opts.Name, s(12), 0, RW / 2 - s(20), rh, "Text", SZ.txtMD, false, 15)
				local selW = math.floor(RW / 2) - s(8)
				local selH = math.min(SZ.inputH, rh - s(12))
				local selBtn = Instance.new("TextButton", r)
				selBtn.Size = UDim2.new(0, selW, 0, selH)
				selBtn.Position = UDim2.new(0, RW - selW - s(10), 0, math.floor((rh - selH) / 2))
				selBtn.BorderSizePixel = 0
				selBtn.Text = ""
				selBtn.AutoButtonColor = false
				selBtn.ZIndex = 15
				reg(selBtn, "BackgroundColor3", "Base")
				rnd(selBtn, s(5))
				stroke(selBtn, "Border", 1)
				local selected = opts.Default or (opts.Options and opts.Options[1]) or "None"
				UI.Flags[opts.Flag] = selected
				local selLbl =
					mklabel(selBtn, tostring(selected), s(6), 0, selW - s(22), selH, "Text", SZ.txtSM, false, 16)
				selLbl.TextTruncate = Enum.TextTruncate.AtEnd
				local chev = mklabel(selBtn, "▾", selW - s(16), 0, s(14), selH, "Muted", SZ.txtSM, false, 16)
				chev.TextXAlignment = Enum.TextXAlignment.Center
				local OPH = s(28)
				local MAX_VIS = 8
				local function calcH(n)
					return math.min(n, MAX_VIS) * OPH
				end
				-- Outer clip + inner scroll
				local listOuter = Instance.new("Frame", gui)
				listOuter.BorderSizePixel = 0
				listOuter.ZIndex = 200
				listOuter.Visible = false
				listOuter.ClipsDescendants = true
				reg(listOuter, "BackgroundColor3", "Card")
				rnd(listOuter, s(5))
				stroke(listOuter, "Border", 1)
				local list = Instance.new("ScrollingFrame", listOuter)
				list.Size = UDim2.new(1, 0, 1, 0)
				list.CanvasSize = UDim2.new(0, 0, 0, 0)
				list.AutomaticCanvasSize = Enum.AutomaticSize.Y
				list.ScrollBarThickness = s(3)
				list.BorderSizePixel = 0
				list.BackgroundTransparency = 1
				list.ZIndex = 201
				table.insert(_themed, { obj = list, prop = "ScrollBarImageColor3", key = "Border" })
				list.ScrollBarImageColor3 = C.Border
				local ll = Instance.new("UIListLayout", list)
				ll.SortOrder = Enum.SortOrder.LayoutOrder
				local open = false
				local function close()
					open = false
					tw(chev, { Rotation = 0 }, 0.12)
					tw(listOuter, { Size = UDim2.new(0, selW, 0, 0) }, 0.12)
					task.delay(0.13, function()
						if listOuter then
							listOuter.Visible = false
						end
					end)
				end
				selBtn.MouseButton1Click:Connect(function()
					if open then
						close()
						return
					end
					open = true
					local ap = selBtn.AbsolutePosition
					local as = selBtn.AbsoluteSize
					local lh = calcH(#opts.Options)
					listOuter.Size = UDim2.new(0, selW, 0, 0)
					listOuter.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + s(2))
					listOuter.Visible = true
					tw(chev, { Rotation = 180 }, 0.12)
					tw(listOuter, { Size = UDim2.new(0, selW, 0, lh) }, 0.15)
				end)
				local function addOpt(opt)
					local ob = Instance.new("TextButton", list)
					ob.Size = UDim2.new(1, -s(3), 0, OPH)
					ob.BorderSizePixel = 0
					ob.Text = ""
					ob.AutoButtonColor = false
					ob.ZIndex = 202
					reg(ob, "BackgroundColor3", "Card")
					local ol = mklabel(
						ob,
						opt,
						s(8),
						0,
						selW - s(16),
						OPH,
						opt == selected and "Accent" or "Text",
						SZ.txtSM,
						false,
						203
					)
					ob.MouseEnter:Connect(function()
						tw(ob, { BackgroundColor3 = C.Hover }, 0.08)
					end)
					ob.MouseLeave:Connect(function()
						tw(ob, { BackgroundColor3 = C.Card }, 0.08)
					end)
					ob.MouseButton1Click:Connect(function()
						selected = opt
						selLbl.Text = opt
						UI.Flags[opts.Flag] = opt
						for _, ch in pairs(list:GetChildren()) do
							if ch:IsA("TextButton") then
								local tl = ch:FindFirstChildOfClass("TextLabel")
								if tl then
									tl.TextColor3 = tl.Text == opt and C.Accent or C.Text
								end
							end
						end
						close()
						if opts.Callback then
							opts.Callback(opt)
						end
						if autoSaveName then
							UI:SaveConfig(autoSaveName)
						end
					end)
				end
				if opts.Options then
					for _, opt in ipairs(opts.Options) do
						addOpt(opt)
					end
				end
				return {
					SetValue = function(_, v)
						selected = v
						selLbl.Text = v
						UI.Flags[opts.Flag] = v
					end,
					GetValue = function(_)
						return selected
					end,
					Refresh = function(_, newOpts)
						opts.Options = newOpts
						for _, ch in pairs(list:GetChildren()) do
							if ch:IsA("TextButton") then
								ch:Destroy()
							end
						end
						selected = newOpts[1] or "None"
						selLbl.Text = selected
						UI.Flags[opts.Flag] = selected
						for _, opt in ipairs(newOpts) do
							addOpt(opt)
						end
					end,
				}
			end

			-- ── MULTI SELECT ─────────────────────────────────────────────────
			function api:CreateMultiSelect(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local hdrRow = row(rh)
				local selected = {}
				if opts.Default then
					for _, v in ipairs(opts.Default) do
						selected[v] = true
					end
				end
				UI.Flags[opts.Flag] = selected
				mklabel(hdrRow, opts.Name, s(12), 0, RW - s(80), rh, "Text", SZ.txtMD, false, 15)
				local bw = s(32)
				local badge = mkframe(hdrRow, RW - bw - s(28), math.floor((rh - s(18)) / 2), bw, s(18), "TagBg", 15)
				rnd(badge, 99)
				local cntLbl = mklabel(badge, "0", 0, 0, bw, s(18), "TagText", SZ.txtXS, true, 16)
				cntLbl.TextXAlignment = Enum.TextXAlignment.Center
				local chev = mklabel(hdrRow, "▾", RW - s(22), 0, s(16), rh, "Muted", SZ.txtSM, false, 15)
				chev.TextXAlignment = Enum.TextXAlignment.Center
				local hdrHit = Instance.new("TextButton", hdrRow)
				hdrHit.Size = UDim2.new(0, RW, 0, rh)
				hdrHit.BackgroundTransparency = 1
				hdrHit.Text = ""
				hdrHit.ZIndex = 17
				local OPH = s(30)
				local listPanel = Instance.new("Frame", holder)
				listPanel.Size = UDim2.new(0, RW, 0, 0)
				listPanel.BackgroundTransparency = 1
				listPanel.BorderSizePixel = 0
				listPanel.ZIndex = 14
				listPanel.ClipsDescendants = true
				local listLL = Instance.new("UIListLayout", listPanel)
				listLL.Padding = UDim.new(0, 0)
				listLL.SortOrder = Enum.SortOrder.LayoutOrder
				local ctrlRow = Instance.new("Frame", listPanel)
				ctrlRow.Size = UDim2.new(0, RW, 0, s(26))
				ctrlRow.BackgroundTransparency = 1
				ctrlRow.BorderSizePixel = 0
				ctrlRow.ZIndex = 14
				local function countSel()
					local n = 0
					for _ in pairs(selected) do
						n = n + 1
					end
					return n
				end
				local function refreshCnt()
					cntLbl.Text = tostring(countSel())
				end
				local function fireCallback()
					local t = {}
					for k in pairs(selected) do
						table.insert(t, k)
					end
					UI.Flags[opts.Flag] = selected
					if opts.Callback then
						opts.Callback(t)
					end
					if autoSaveName then
						UI:SaveConfig(autoSaveName)
					end
				end
				local optFrames = {}
				local function rebuildColors()
					for _, of in pairs(optFrames) do
						local on = selected[of.opt] == true
						tw(of.bg, { BackgroundColor3 = on and C.TagBg or C.Card }, 0.1)
						of.lbl.TextColor3 = on and C.Accent or C.Text
						of.chk.Text = on and "✓" or ""
					end
				end
				local function mkCtrlBtn(txt2, col, xpos)
					local b = Instance.new("TextButton", ctrlRow)
					b.Size = UDim2.new(0, math.floor(RW / 2) - s(14), 0, s(22))
					b.Position = UDim2.new(0, xpos, 0, s(2))
					b.BackgroundTransparency = 1
					b.Text = txt2
					b.TextColor3 = col
					b.Font = _fontBase
					b.TextSize = SZ.txtXS
					b.TextXAlignment = Enum.TextXAlignment.Left
					b.BorderSizePixel = 0
					b.ZIndex = 15
					return b
				end
				local saBtn = mkCtrlBtn("Select all", C.Accent, s(12))
				saBtn.MouseButton1Click:Connect(function()
					for _, opt in ipairs(opts.Options) do
						selected[opt] = true
					end
					rebuildColors()
					refreshCnt()
					fireCallback()
				end)
				local clrBtn = mkCtrlBtn("Clear", C.Danger, math.floor(RW / 2) + s(2))
				clrBtn.MouseButton1Click:Connect(function()
					for k in pairs(selected) do
						selected[k] = nil
					end
					rebuildColors()
					refreshCnt()
					fireCallback()
				end)
				for _, opt in ipairs(opts.Options) do
					local or2 = Instance.new("Frame", listPanel)
					or2.Size = UDim2.new(0, RW, 0, OPH)
					or2.BorderSizePixel = 0
					or2.ZIndex = 14
					reg(or2, "BackgroundColor3", "Card")
					local acBar = mkframe(or2, 0, s(4), s(3), OPH - s(8), "Accent", 15)
					acBar.Visible = selected[opt] == true
					local opBg = Instance.new("Frame", or2)
					opBg.Size = UDim2.new(1, 0, 1, 0)
					opBg.BorderSizePixel = 0
					opBg.ZIndex = 15
					opBg.BackgroundColor3 = selected[opt] and C.TagBg or C.Card
					local chk = Instance.new("TextLabel", or2)
					chk.Size = UDim2.new(0, s(22), 0, OPH)
					chk.Position = UDim2.new(0, s(10), 0, 0)
					chk.BackgroundTransparency = 1
					chk.Text = selected[opt] and "✓" or ""
					chk.TextColor3 = C.Accent
					chk.Font = _fontBold
					chk.TextSize = SZ.txtSM
					chk.TextXAlignment = Enum.TextXAlignment.Center
					chk.ZIndex = 16
					local ol = mklabel(
						or2,
						opt,
						s(34),
						0,
						RW - s(46),
						OPH,
						selected[opt] and "Accent" or "Text",
						SZ.txtSM,
						false,
						16
					)
					mkframe(or2, s(34), OPH - 1, RW - s(46), 1, "Panel", 14)
					or2.MouseEnter:Connect(function()
						if not selected[opt] then
							tw(opBg, { BackgroundColor3 = C.Hover }, 0.08)
						end
					end)
					or2.MouseLeave:Connect(function()
						if not selected[opt] then
							tw(opBg, { BackgroundColor3 = C.Card }, 0.08)
						end
					end)
					local hit2 = Instance.new("TextButton", or2)
					hit2.Size = UDim2.new(0, RW, 0, OPH)
					hit2.BackgroundTransparency = 1
					hit2.Text = ""
					hit2.ZIndex = 17
					hit2.MouseButton1Click:Connect(function()
						if selected[opt] then
							selected[opt] = nil
						else
							selected[opt] = true
						end
						local on = selected[opt] == true
						acBar.Visible = on
						tw(opBg, { BackgroundColor3 = on and C.TagBg or C.Card }, 0.1)
						ol.TextColor3 = on and C.Accent or C.Text
						chk.Text = on and "✓" or ""
						refreshCnt()
						fireCallback()
					end)
					table.insert(optFrames, { opt = opt, bg = opBg, lbl = ol, chk = chk, bar = acBar })
				end
				refreshCnt()
				local collapsed = true
				local totalH = s(26) + #opts.Options * OPH
				hdrHit.MouseButton1Click:Connect(function()
					collapsed = not collapsed
					tw(chev, { Rotation = collapsed and 0 or 180 }, 0.15)
					tw(listPanel, { Size = UDim2.new(0, RW, 0, collapsed and 0 or totalH) }, 0.18)
				end)
				return {
					GetSelected = function(_)
						local t = {}
						for k in pairs(selected) do
							table.insert(t, k)
						end
						return t
					end,
					SetSelected = function(_, arr)
						for k in pairs(selected) do
							selected[k] = nil
						end
						for _, v in ipairs(arr) do
							selected[v] = true
						end
						rebuildColors()
						refreshCnt()
						fireCallback()
					end,
				}
			end

			-- ── BUTTON ───────────────────────────────────────────────────────
			function api:CreateButton(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local bh = math.floor(rh * 0.70)
				local r = row(rh)
				local colorKey = opts.Style == "accent" and "Accent" or opts.Style == "danger" and "Danger" or "Dark"
				local isGhost = (opts.Style == "ghost")
				local btn = Instance.new("TextButton", r)
				btn.Size = UDim2.new(0, RW - s(24), 0, bh)
				btn.Position = UDim2.new(0, s(12), 0, math.floor((rh - bh) / 2))
				btn.BorderSizePixel = 0
				btn.Text = opts.Name
				btn.Font = _fontBold
				btn.TextSize = SZ.txtMD
				btn.AutoButtonColor = false
				btn.ZIndex = 15
				rnd(btn, s(6))
				if isGhost then
					btn.BackgroundTransparency = 1
					btn.TextColor3 = C.Accent
					stroke(btn, "Accent", 1)
					btn.MouseEnter:Connect(function()
						tw(
							btn,
							{ BackgroundColor3 = C.Accent, BackgroundTransparency = 0.82, TextColor3 = Color3.new(
								1,
								1,
								1
							) },
							0.1
						)
					end)
					btn.MouseLeave:Connect(function()
						tw(btn, { BackgroundTransparency = 1, TextColor3 = C.Accent }, 0.1)
					end)
				else
					reg(btn, "BackgroundColor3", colorKey)
					btn.TextColor3 = Color3.new(1, 1, 1)
					btn.MouseEnter:Connect(function()
						tw(btn, { BackgroundColor3 = C[colorKey]:Lerp(Color3.new(0, 0, 0), 0.18) }, 0.1)
					end)
					btn.MouseLeave:Connect(function()
						tw(btn, { BackgroundColor3 = C[colorKey] }, 0.1)
					end)
				end
				btn.MouseButton1Down:Connect(function()
					tw(
						btn,
						{ Size = UDim2.new(0, RW - s(28), 0, bh - s(2)), Position = UDim2.new(
							0,
							s(14),
							0,
							math.floor((rh - bh) / 2) + s(1)
						) },
						0.06
					)
				end)
				btn.MouseButton1Up:Connect(function()
					tw(
						btn,
						{ Size = UDim2.new(0, RW - s(24), 0, bh), Position = UDim2.new(
							0,
							s(12),
							0,
							math.floor((rh - bh) / 2)
						) },
						0.06
					)
				end)
				btn.MouseButton1Click:Connect(function()
					if opts.Callback then
						opts.Callback()
					end
				end)
			end

			-- ── INPUT ────────────────────────────────────────────────────────
			function api:CreateInput(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local ih = math.min(SZ.inputH, rh - s(12))
				local r = row(rh)
				mklabel(r, opts.Name, s(12), 0, RW / 2 - s(20), rh, "Text", SZ.txtMD, false, 15)
				local bxW = math.floor(RW / 2) - s(8)
				local bx = Instance.new("TextBox", r)
				bx.Size = UDim2.new(0, bxW, 0, ih)
				bx.Position = UDim2.new(0, RW - bxW - s(10), 0, math.floor((rh - ih) / 2))
				bx.BorderSizePixel = 0
				bx.Text = opts.Default or ""
				bx.PlaceholderText = opts.Placeholder or "Type here..."
				bx.Font = _fontBase
				bx.TextSize = SZ.txtSM
				bx.ClearTextOnFocus = opts.ClearOnFocus ~= false
				bx.ZIndex = 15
				reg(bx, "BackgroundColor3", "Base")
				reg(bx, "TextColor3", "Text")
				reg(bx, "PlaceholderColor3", "Muted")
				rnd(bx, s(5))
				local bs = stroke(bx, "Border", 1)
				bx.Focused:Connect(function()
					tw(bs, { Color = C.Accent }, 0.12)
				end)
				bx.FocusLost:Connect(function(enter)
					tw(bs, { Color = C.Border }, 0.12)
					UI.Flags[opts.Flag] = bx.Text
					if opts.Callback then
						opts.Callback(bx.Text, enter)
					end
					if autoSaveName then
						UI:SaveConfig(autoSaveName)
					end
				end)
				return {
					SetValue = function(_, v)
						bx.Text = v
						UI.Flags[opts.Flag] = v
					end,
					GetValue = function(_)
						return bx.Text
					end,
				}
			end

			-- ── KEYBIND ──────────────────────────────────────────────────────
			function api:CreateKeybind(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local ih = math.min(SZ.inputH, rh - s(12))
				local r = row(rh)
				mklabel(r, opts.Name, s(12), 0, RW / 2 - s(20), rh, "Text", SZ.txtMD, false, 15)
				local current = opts.Default or Enum.KeyCode.Unknown
				UI.Flags[opts.Flag] = current
				local kbW = math.floor(RW / 2) - s(8)
				local kbBtn = Instance.new("TextButton", r)
				kbBtn.Size = UDim2.new(0, kbW, 0, ih)
				kbBtn.Position = UDim2.new(0, RW - kbW - s(10), 0, math.floor((rh - ih) / 2))
				kbBtn.BorderSizePixel = 0
				kbBtn.Text = tostring(current.Name)
				kbBtn.Font = _fontBase
				kbBtn.TextSize = SZ.txtSM
				kbBtn.AutoButtonColor = false
				kbBtn.ZIndex = 15
				reg(kbBtn, "BackgroundColor3", "Base")
				reg(kbBtn, "TextColor3", "Text")
				rnd(kbBtn, s(5))
				local kbs = stroke(kbBtn, "Border", 1)
				local listening = false
				kbBtn.MouseButton1Click:Connect(function()
					listening = true
					kbBtn.Text = "..."
					tw(kbs, { Color = C.Accent }, 0.12)
				end)
				UIS.InputBegan:Connect(function(inp, gp)
					if not listening then
						return
					end
					if inp.UserInputType ~= Enum.UserInputType.Keyboard then
						return
					end
					if inp.KeyCode == Enum.KeyCode.Escape then
						listening = false
						kbBtn.Text = tostring(current.Name)
						tw(kbs, { Color = C.Border }, 0.12)
						return
					end
					listening = false
					current = inp.KeyCode
					UI.Flags[opts.Flag] = current
					kbBtn.Text = tostring(current.Name)
					tw(kbs, { Color = C.Border }, 0.12)
					if opts.Callback then
						opts.Callback(current)
					end
				end)
				UIS.InputBegan:Connect(function(inp, gp)
					if gp or listening then
						return
					end
					if inp.KeyCode == current and opts.OnFire then
						opts.OnFire()
					end
				end)
				return {
					SetValue = function(_, kc)
						current = kc
						UI.Flags[opts.Flag] = kc
						kbBtn.Text = tostring(kc.Name)
					end,
					GetValue = function(_)
						return current
					end,
				}
			end

			-- ── LABEL ────────────────────────────────────────────────────────
			function api:CreateLabel(opts)
				local text, colorKey, sz
				if type(opts) == "string" then
					text = opts
					colorKey = "Muted"
					sz = SZ.txtSM
				else
					text = opts.Text or ""
					sz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtSM
					colorKey = ({
						default = "Muted",
						info = "Accent",
						success = "Green",
						warn = "Amber",
						error = "Danger",
						header = "Text",
					})[opts.Style or "default"] or "Muted"
				end
				local rh = sz + s(14)
				local r = row(rh)
				local nl = mklabel(r, text, s(12), 0, RW - s(24), rh, colorKey, sz, false, 15)
				return {
					SetText = function(_, t)
						nl.Text = t
					end,
					GetText = function(_)
						return nl.Text
					end,
				}
			end

			-- ── PARAGRAPH ────────────────────────────────────────────────────
			-- AutomaticSize so SetBody with dynamic content always fits
			function api:CreateParagraph(opts)
				local titleTxt = opts.Title or ""
				local bodyTxt = opts.Body or opts.Text or opts.Content or ""
				local sz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtSM
				local r = Instance.new("Frame", holder)
				r.Size = UDim2.new(0, RW, 0, 0)
				r.AutomaticSize = Enum.AutomaticSize.Y
				r.BorderSizePixel = 0
				r.ZIndex = 14
				r.ClipsDescendants = false
				reg(r, "BackgroundColor3", "Card")
				local inner = Instance.new("Frame", r)
				inner.Size = UDim2.new(1, 0, 0, 0)
				inner.AutomaticSize = Enum.AutomaticSize.Y
				inner.BackgroundTransparency = 1
				inner.BorderSizePixel = 0
				inner.ZIndex = 14
				local il = Instance.new("UIListLayout", inner)
				il.Padding = UDim.new(0, s(2))
				il.SortOrder = Enum.SortOrder.LayoutOrder
				local ip = Instance.new("UIPadding", inner)
				ip.PaddingTop = UDim.new(0, s(7))
				ip.PaddingBottom = UDim.new(0, s(7))
				ip.PaddingLeft = UDim.new(0, s(12))
				ip.PaddingRight = UDim.new(0, s(12))
				local titleLbl = nil
				if titleTxt ~= "" then
					titleLbl = Instance.new("TextLabel", inner)
					titleLbl.Size = UDim2.new(1, 0, 0, s(16))
					titleLbl.BackgroundTransparency = 1
					titleLbl.Text = titleTxt
					titleLbl.TextWrapped = true
					titleLbl.Font = _fontBold
					titleLbl.TextSize = sz
					titleLbl.TextXAlignment = Enum.TextXAlignment.Left
					titleLbl.TextYAlignment = Enum.TextYAlignment.Center
					titleLbl.ZIndex = 15
					titleLbl.LayoutOrder = 1
					reg(titleLbl, "TextColor3", "Text")
				end
				local bl = Instance.new("TextLabel", inner)
				bl.Size = UDim2.new(1, 0, 0, 0)
				bl.AutomaticSize = Enum.AutomaticSize.Y
				bl.BackgroundTransparency = 1
				bl.Text = bodyTxt
				bl.TextWrapped = true
				bl.Font = _fontBase
				bl.TextSize = sz
				bl.TextXAlignment = Enum.TextXAlignment.Left
				bl.TextYAlignment = Enum.TextYAlignment.Top
				bl.ZIndex = 15
				bl.LayoutOrder = 2
				reg(bl, "TextColor3", "Muted")
				mkframe(r, s(10), 0, RW - s(20), 1, "Panel", 14).Position = UDim2.new(0, s(10), 1, -1)
				return {
					SetBody = function(_, t)
						bl.Text = tostring(t)
					end,
					SetTitle = function(_, t)
						if titleLbl then
							titleLbl.Text = tostring(t)
						end
					end,
					Set = function(_, newOpts)
						if type(newOpts) == "table" then
							if newOpts.Content ~= nil then
								bl.Text = tostring(newOpts.Content)
							end
							if newOpts.Body ~= nil then
								bl.Text = tostring(newOpts.Body)
							end
							if newOpts.Title ~= nil and titleLbl then
								titleLbl.Text = tostring(newOpts.Title)
							end
						else
							bl.Text = tostring(newOpts)
						end
					end,
				}
			end

			-- ── BADGE ────────────────────────────────────────────────────────
			-- Inline status chip, useful for showing live status
			function api:CreateBadge(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local r = row(rh)
				mklabel(r, opts.Name, s(12), 0, RW / 2 - s(20), rh, "Text", SZ.txtMD, false, 15)
				local bw = s(72)
				local bh2 = s(20)
				local bg = mkframe(r, RW - bw - s(10), math.floor((rh - bh2) / 2), bw, bh2, "TagBg", 15)
				rnd(bg, 99)
				local lbl = mklabel(bg, opts.Value or "–", 0, 0, bw, bh2, "TagText", SZ.txtXS, true, 16)
				lbl.TextXAlignment = Enum.TextXAlignment.Center
				return {
					SetValue = function(_, v, style)
						lbl.Text = tostring(v)
						if style then
							local colorKey = ({ ok = "Green", warn = "Amber", error = "Danger", info = "Accent" })[style]
								or "TagText"
							lbl.TextColor3 = C[colorKey]
							bg.BackgroundColor3 = C.TagBg
						end
					end,
				}
			end

			-- ── PROGRESS BAR ─────────────────────────────────────────────────
			-- Shows a labelled fill bar (0-100)
			function api:CreateProgressBar(opts)
				local rh = SZ.rowSlider
				local r = row(rh)
				local trkY = rh - s(13)
				local nl = mklabel(
					r,
					opts.Name .. ": " .. (opts.Value or 0) .. "%",
					s(12),
					s(4),
					RW - s(20),
					s(14),
					"Text",
					SZ.txtMD,
					false,
					15
				)
				local track = mkframe(r, s(12), trkY, RW - s(24), s(8), "Panel", 15)
				rnd(track, s(4))
				local fill = mkframe(track, 0, 0, 0, s(8), opts.Color or "Accent", 16)
				rnd(fill, s(4))
				local val = math.clamp(opts.Value or 0, 0, 100)
				local function upd(v)
					v = math.clamp(v, 0, 100)
					val = v
					fill.Size = UDim2.new(v / 100, 0, 1, 0)
					nl.Text = opts.Name .. ": " .. math.floor(v) .. "%"
				end
				upd(val)
				return {
					SetValue = function(_, v)
						upd(v)
					end,
					GetValue = function(_)
						return val
					end,
				}
			end

			-- ── SEPARATOR (visible divider with optional label) ───────────────
			function api:CreateDivider(label_text)
				local dh = s(22)
				local r = row(dh)
				r.BackgroundTransparency = 1
				if label_text and label_text ~= "" then
					local lw = math.min(#label_text * s(7) + s(8), math.floor(RW / 2))
					local lnW = math.floor((RW - lw - s(24)) / 2)
					mkframe(r, s(12), s(10), lnW, 1, "Panel", 15)
					local dl = mklabel(r, label_text, s(12) + lnW + s(4), s(4), lw, s(14), "Muted", SZ.txtXS, false, 15)
					dl.TextXAlignment = Enum.TextXAlignment.Center
					mkframe(r, s(12) + lnW + s(4) + lw + s(4), s(10), lnW, 1, "Panel", 15)
				else
					mkframe(r, s(12), s(10), RW - s(24), 1, "Panel", 15)
				end
			end

			-- COLOR PICKER (kept from original)
			function api:CreateColorPicker(opts)
				local current = opts.Default or Color3.fromRGB(255, 80, 80)
				UI.Flags[opts.Flag] = current
				local collapsed = true
				local headerRow = row(SZ.rowMD)
				mklabel(headerRow, opts.Name, s(12), 0, RW / 2 - s(20), SZ.rowMD, "Text", SZ.txtMD, false, 15)
				local swatch = mkframe(headerRow, RW - s(48), s(8), s(30), s(20), "Base", 15)
				swatch.BackgroundColor3 = current
				rnd(swatch, s(4))
				stroke(swatch, "Border", 1)
				local swBtn = Instance.new("TextButton", headerRow)
				swBtn.Size = UDim2.new(0, RW, 0, SZ.rowMD)
				swBtn.BackgroundTransparency = 1
				swBtn.Text = ""
				swBtn.ZIndex = 17
				local pickerRow = Instance.new("Frame", holder)
				pickerRow.Size = UDim2.new(0, RW, 0, 0)
				pickerRow.BackgroundTransparency = 1
				pickerRow.BorderSizePixel = 0
				pickerRow.ZIndex = 14
				pickerRow.ClipsDescendants = true
				local svW = RW - s(40)
				local svH = math.floor(svW * 0.42)
				local svBox = mkframe(pickerRow, s(12), s(8), svW, svH, "Card", 15)
				rnd(svBox, s(4))
				local svWG = Instance.new("UIGradient", svBox)
				svWG.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
				})
				svWG.Transparency =
					NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
				local svBk = Instance.new("Frame", svBox)
				svBk.Size = UDim2.new(1, 0, 1, 0)
				svBk.BackgroundTransparency = 0
				svBk.BorderSizePixel = 0
				svBk.ZIndex = 16
				local svBG = Instance.new("UIGradient", svBk)
				svBG.Rotation = 90
				svBG.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
				})
				svBG.Transparency =
					NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
				local svCursor = mkframe(svBox, 0, 0, s(10), s(10), "Card", 20)
				rnd(svCursor, 99)
				svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
				stroke(svCursor, "Border", 1)
				local hueY = s(8) + svH + s(8)
				local hueBar = mkframe(pickerRow, s(12), hueY, svW, s(12), "Card", 15)
				rnd(hueBar, s(4))
				local hueG = Instance.new("UIGradient", hueBar)
				hueG.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
					ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
					ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
					ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
					ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
				})
				local hueCursor = mkframe(hueBar, 0, 0, s(6), s(12), "Card", 20)
				rnd(hueCursor, s(2))
				stroke(hueCursor, "Border", 1)
				local hexY = hueY + s(12) + s(6)
				local hexLbl = mklabel(pickerRow, "#FFFFFF", s(12), hexY, svW, s(14), "Muted", SZ.txtXS, false, 15)
				local H, S, V = Color3.toHSV(current)
				local function applyColor()
					current = Color3.fromHSV(H, S, V)
					UI.Flags[opts.Flag] = current
					swatch.BackgroundColor3 = current
					svBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
					svCursor.Position = UDim2.new(
						0,
						math.clamp(S * (svW - s(10)), 0, svW - s(10)),
						0,
						math.clamp((1 - V) * (svH - s(10)), 0, svH - s(10))
					)
					hueCursor.Position = UDim2.new(0, math.clamp(H * (svW - s(6)), 0, svW - s(6)), 0, 0)
					hexLbl.Text = "#"
						.. string.format(
							"%02X%02X%02X",
							math.floor(current.R * 255),
							math.floor(current.G * 255),
							math.floor(current.B * 255)
						)
					if opts.Callback then
						opts.Callback(current)
					end
				end
				applyColor()
				local svD, hueD = false, false
				svBox.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						svD = true
						S = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
						V = 1 - math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
						applyColor()
					end
				end)
				hueBar.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						hueD = true
						H = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
						applyColor()
					end
				end)
				UIS.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						svD = false
						hueD = false
					end
				end)
				UIS.InputChanged:Connect(function(i)
					if i.UserInputType ~= Enum.UserInputType.MouseMovement then
						return
					end
					if svD then
						S = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
						V = 1 - math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
						applyColor()
					end
					if hueD then
						H = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
						applyColor()
					end
				end)
				local totalPickerH = hexY + s(14) + s(8)
				swBtn.MouseButton1Click:Connect(function()
					collapsed = not collapsed
					tw(pickerRow, { Size = UDim2.new(0, RW, 0, collapsed and 0 or totalPickerH) }, 0.18)
				end)
				return {
					SetValue = function(_, col)
						current = col
						H, S, V = Color3.toHSV(col)
						applyColor()
					end,
					GetValue = function(_)
						return current
					end,
				}
			end

			return api
		end -- CreateSection
		return tab
	end -- CreateTab

	-- ── BUILT-IN SETTINGS TAB ─────────────────────────────────────────────────
	if showSettings then
		local SettTab = window:CreateTab("Settings")
		local ThemeSec = SettTab:CreateSection("Theme")

		-- Theme buttons — group by light/dark pairs
		local themeGroups = {
			{ "Default", "light", "dark" },
			{ "Ocean", nil, "ocean" },
			{ "Amber", "amber-light", "amber-dark" },
			{ "Stone", "stone-light", "stone-dark" },
			{ "Warm", "warm-light", "warm-dark" },
			{ "Blue", "blue-light", "blue-dark" },
		}
		for _, g in ipairs(themeGroups) do
			local label, light, dark2 = g[1], g[2], g[3]
			if light and dark2 then
				ThemeSec:CreateButton({
					Name = "☀️ " .. label .. " Light",
					Callback = function()
						UI:SetTheme(light)
						UI:Notify("Theme: " .. light, 2, "info")
					end,
				})
				ThemeSec:CreateButton({
					Name = "🌑 " .. label .. " Dark",
					Callback = function()
						UI:SetTheme(dark2)
						UI:Notify("Theme: " .. dark2, 2, "info")
					end,
				})
			else
				-- Ocean has no light variant
				ThemeSec:CreateButton({
					Name = "🌊 " .. label,
					Callback = function()
						UI:SetTheme(dark2)
						UI:Notify("Theme: " .. dark2, 2, "info")
					end,
				})
			end
			ThemeSec:CreateDivider()
		end

		local SizeSec = SettTab:CreateSection("UI Size")
		SizeSec:CreateParagraph({ Title = "Note", Content = "Size changes apply on next script run." })
		for _, p in ipairs({ "sm", "md", "lg", "xl" }) do
			local labels = { sm = "Small", md = "Medium (Default)", lg = "Large", xl = "Extra Large" }
			SizeSec:CreateButton({
				Name = labels[p],
				Callback = function()
					UI:SetSize(p)
					UI:Notify("Size: " .. p .. " — re-run to fully apply", 3, "warn")
				end,
			})
		end

		local FontSec = SettTab:CreateSection("Font")
		local fonts = {
			{ "Gotham", "gotham", "gothamSemibold" },
			{ "Roboto", "roboto", "gothamSemibold" },
			{ "Ubuntu", "ubuntu", "gothamSemibold" },
			{ "Source Sans", "sourceSans", "gothamSemibold" },
		}
		for _, f in ipairs(fonts) do
			FontSec:CreateButton({
				Name = f[1],
				Callback = function()
					UI:SetFont(f[2], f[3])
					UI:Notify("Font: " .. f[1], 2, "info")
				end,
			})
		end

		if autoSaveName then
			local SaveSec = SettTab:CreateSection("Config")
			SaveSec:CreateButton({
				Name = "💾 Save Config",
				Style = "accent",
				Callback = function()
					UI:SaveConfig(autoSaveName)
					UI:Notify("Config saved!", 2, "success")
				end,
			})
			SaveSec:CreateButton({
				Name = "📂 Load Config",
				Callback = function()
					UI:LoadConfig(autoSaveName)
					UI:Notify("Config loaded!", 2, "success")
				end,
			})
			SaveSec:CreateParagraph({
				Title = "Auto Save",
				Content = "Config auto-saves on every toggle/slider/dropdown change.",
			})
		end

		local InfoSec = SettTab:CreateSection("About")
		InfoSec:CreateParagraph({
			Title = "GooBlox UI v" .. UI.Version,
			Content = "RightCtrl to toggle visibility.\nTheme, size, and config settings above.",
		})
		InfoSec:CreateButton({
			Name = "Unload",
			Style = "danger",
			Callback = function()
				UI:Notify("Unloading...", 2, "warn")
				task.wait(0.4)
				gui:Destroy()
			end,
		})
	end

	-- Auto-load config on start if autoSaveName set
	if autoSaveName then
		task.defer(function()
			UI:LoadConfig(autoSaveName)
		end)
	end

	return window
end -- CreateWindow

return UI
