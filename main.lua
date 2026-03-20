--[[
╔══════════════════════════════════════════════════════════════╗
║  FlatGrayUI  —  Complete UI Library                          ║
║                                                              ║
║  SIZE SYSTEM   sm · md (default) · lg · xl                   ║
║  FONT SUPPORT  any Enum.Font, or use built-in aliases        ║
║                "gotham" "gothamBold" "gothamSemibold"        ║
║                "arial"  "roboto"     "code" "serif"          ║
║                                                              ║
║  COMPONENTS    Toggle · Slider · Dropdown · Button · Input   ║
║                Keybind · ColorPicker · Label · Paragraph     ║
║                Divider                                       ║
║                                                              ║
║  EXTRAS        Notify · SaveConfig · LoadConfig              ║
║                SetTheme · SetSize · SetFont                  ║
╚══════════════════════════════════════════════════════════════╝
--]]

local UI = {}
UI.Flags = {}

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")

---------------------------------------------------------------------------
-- FONT ALIASES
-- Use a plain string shorthand or pass any Enum.Font directly
---------------------------------------------------------------------------
local FONT_ALIASES = {
	gotham = Enum.Font.Gotham,
	gothamBold = Enum.Font.GothamBold,
	gothamSemibold = Enum.Font.GothamSemibold,
	arial = Enum.Font.Arial,
	arialBold = Enum.Font.ArialBold,
	roboto = Enum.Font.Roboto,
	robotoBold = Enum.Font.RobotoMono,
	code = Enum.Font.Code,
	serif = Enum.Font.Merriweather,
	ubuntu = Enum.Font.Ubuntu,
	sourceSans = Enum.Font.SourceSans,
}

local function resolveFont(f)
	if not f then
		return Enum.Font.Gotham
	end
	if type(f) == "string" then
		return FONT_ALIASES[f] or Enum.Font.Gotham
	end
	return f -- already an Enum.Font
end

-- Active font family (regular + bold variants)
local _fontBase = Enum.Font.Gotham
local _fontBold = Enum.Font.GothamSemibold

function UI:SetFont(base, bold)
	_fontBase = resolveFont(base)
	_fontBold = resolveFont(bold) or _fontBase
end

---------------------------------------------------------------------------
-- SIZE SYSTEM
-- Every pixel dimension in the library derives from one scale multiplier
---------------------------------------------------------------------------
local SIZE_PRESETS = {
	sm = 0.82, -- compact, more content visible
	md = 1.00, -- default
	lg = 1.18, -- comfortable reading
	xl = 1.38, -- accessibility / large screen
}

local _scale = 1.0 -- active multiplier

-- Convenience: scale a raw pixel value
local function s(n)
	return math.floor(n * _scale + 0.5)
end

-- SIZE TOKENS — all derived from _scale, recalculated on SetSize
-- Window geometry
local SZ = {}
local function buildSZ()
	SZ = {
		-- window
		W = s(500), -- window width
		H = s(340), -- window height
		TH = s(36), -- titlebar height
		SW = s(115), -- sidebar width
		SBH = s(22), -- statusbar height
		-- typography
		txtXS = s(9),
		txtSM = s(11),
		txtMD = s(12),
		txtLG = s(14),
		txtXL = s(16),
		-- row heights
		rowSM = s(26),
		rowMD = s(34),
		rowLG = s(40),
		rowXL = s(50),
		rowSlider = s(44),
		-- component internals
		pillW = s(34),
		pillH = s(18),
		thumbSz = s(12),
		trackH = s(5),
		handleSz = s(13),
		btnH = s(24),
		inputH = s(22),
		dotSz = s(12),
		tabH = s(28),
		tabPad = s(8),
		tabGap = s(2),
		secHdrH = s(26),
		iconSz = s(20),
		-- notify
		notifW = s(230),
		notifH = s(46),
	}
	SZ.CW = SZ.W - SZ.SW
	SZ.CH = SZ.H - SZ.TH - SZ.SBH
end
buildSZ()

function UI:SetSize(preset)
	local m = SIZE_PRESETS[preset]
	if not m then
		warn("FlatGrayUI: unknown size '" .. tostring(preset) .. "'. Use sm/md/lg/xl")
		return
	end
	_scale = m
	buildSZ()
end

---------------------------------------------------------------------------
-- THEMES
---------------------------------------------------------------------------
local THEMES = {
	light = {
		Base = Color3.fromRGB(245, 245, 245),
		Surface = Color3.fromRGB(236, 236, 236),
		Panel = Color3.fromRGB(224, 224, 224),
		Border = Color3.fromRGB(200, 200, 200),
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
	},
	dark = {
		Base = Color3.fromRGB(28, 28, 32),
		Surface = Color3.fromRGB(35, 35, 40),
		Panel = Color3.fromRGB(45, 45, 52),
		Border = Color3.fromRGB(60, 60, 68),
		Dark = Color3.fromRGB(200, 200, 200),
		Accent = Color3.fromRGB(110, 130, 220),
		Danger = Color3.fromRGB(239, 83, 80),
		Text = Color3.fromRGB(230, 230, 235),
		Muted = Color3.fromRGB(130, 130, 140),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(110, 180, 50),
		Amber = Color3.fromRGB(210, 150, 40),
		TagBg = Color3.fromRGB(50, 55, 90),
		TagText = Color3.fromRGB(140, 160, 255),
	},
	ocean = {
		Base = Color3.fromRGB(12, 24, 40),
		Surface = Color3.fromRGB(16, 32, 54),
		Panel = Color3.fromRGB(22, 44, 72),
		Border = Color3.fromRGB(30, 60, 95),
		Dark = Color3.fromRGB(180, 210, 240),
		Accent = Color3.fromRGB(0, 170, 255),
		Danger = Color3.fromRGB(239, 83, 80),
		Text = Color3.fromRGB(200, 225, 255),
		Muted = Color3.fromRGB(90, 130, 170),
		White = Color3.fromRGB(255, 255, 255),
		Green = Color3.fromRGB(40, 210, 140),
		Amber = Color3.fromRGB(255, 180, 40),
		TagBg = Color3.fromRGB(0, 50, 80),
		TagText = Color3.fromRGB(0, 200, 255),
	},
}

local C = THEMES.light
local _themed = {}

local function reg(obj, prop, key)
	table.insert(_themed, { obj = obj, prop = prop, key = key })
	obj[prop] = C[key]
	return obj
end

function UI:SetTheme(name)
	local t = THEMES[name]
	if not t then
		warn("FlatGrayUI: unknown theme '" .. tostring(name) .. "'")
		return
	end
	C = t
	for _, e in pairs(_themed) do
		pcall(function()
			e.obj[e.prop] = C[e.key]
		end)
	end
end

---------------------------------------------------------------------------
-- LOW-LEVEL HELPERS
---------------------------------------------------------------------------
local function tw(o, p, t)
	TS:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), p):Play()
end

local function rnd(o, r)
	local u = Instance.new("UICorner", o)
	u.CornerRadius = UDim.new(0, r or s(6))
end

local function bdr(o, key, th)
	local st = Instance.new("UIStroke", o)
	st.Color = C[key] or C.Border
	st.Thickness = th or 1
	table.insert(_themed, { obj = st, prop = "Color", key = key or "Border" })
	return st
end

local function frame(parent, x, y, w, h, colorKey, z)
	local f = Instance.new("Frame", parent)
	f.Position = UDim2.new(0, x, 0, y)
	f.Size = UDim2.new(0, w, 0, h)
	f.BorderSizePixel = 0
	f.ZIndex = z or 5
	reg(f, "BackgroundColor3", colorKey or "White")
	return f
end

-- txt: creates a themed TextLabel using active font + size
local function txt(parent, text, x, y, w, h, colorKey, sz, fontVariant, z)
	local l = Instance.new("TextLabel", parent)
	l.Position = UDim2.new(0, x, 0, y)
	l.Size = UDim2.new(0, w, 0, h)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = (fontVariant == "bold") and _fontBold or _fontBase
	l.TextSize = sz or SZ.txtMD
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.ZIndex = z or 5
	l.ClipsDescendants = false
	reg(l, "TextColor3", colorKey or "Text")
	return l
end

---------------------------------------------------------------------------
-- NOTIFY
---------------------------------------------------------------------------
function UI:Notify(text, duration, kind)
	duration = duration or 3
	local gui = game.CoreGui:FindFirstChild("FlatGrayUI")
	if not gui then
		return
	end

	local BG = {
		info = Color3.fromRGB(240, 244, 255),
		success = Color3.fromRGB(234, 243, 222),
		warn = Color3.fromRGB(250, 238, 218),
		error = Color3.fromRGB(252, 235, 235),
	}
	local TC = {
		info = Color3.fromRGB(57, 73, 171),
		success = Color3.fromRGB(59, 109, 17),
		warn = Color3.fromRGB(133, 79, 11),
		error = Color3.fromRGB(163, 45, 45),
	}
	local bg = BG[kind] or BG.info
	local tc = TC[kind] or TC.info
	local nW, nH = SZ.notifW, SZ.notifH

	local n = Instance.new("Frame", gui)
	n.Size = UDim2.new(0, nW, 0, nH)
	n.Position = UDim2.new(1, -(nW + 20), 1, 10)
	n.BackgroundColor3 = bg
	n.BorderSizePixel = 0
	n.ZIndex = 100
	rnd(n, s(8))
	local ns = Instance.new("UIStroke", n)
	ns.Color = C.Border
	ns.Thickness = 1

	local bar = Instance.new("Frame", n)
	bar.Size = UDim2.new(0, s(4), 1, -s(16))
	bar.Position = UDim2.new(0, s(8), 0, s(8))
	bar.BackgroundColor3 = tc
	bar.BorderSizePixel = 0
	bar.ZIndex = 101
	rnd(bar, s(2))

	local tl = Instance.new("TextLabel", n)
	tl.Size = UDim2.new(1, -s(26), 1, 0)
	tl.Position = UDim2.new(0, s(22), 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = text
	tl.TextColor3 = tc
	tl.Font = _fontBase
	tl.TextSize = SZ.txtSM
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.TextWrapped = true
	tl.ZIndex = 101

	tw(n, { Position = UDim2.new(1, -(nW + 20), 1, -(nH + 12)) }, 0.25)
	task.delay(duration, function()
		tw(n, { Position = UDim2.new(1, -(nW + 20), 1, 10) }, 0.25)
		task.wait(0.3)
		n:Destroy()
	end)
end

---------------------------------------------------------------------------
-- CONFIG
---------------------------------------------------------------------------
function UI:SaveConfig(name)
	writefile(name .. ".json", HS:JSONEncode(UI.Flags))
end

function UI:LoadConfig(name)
	if isfile(name .. ".json") then
		local d = HS:JSONDecode(readfile(name .. ".json"))
		for k, v in pairs(d) do
			UI.Flags[k] = v
		end
	end
end

---------------------------------------------------------------------------
-- CREATE WINDOW
---------------------------------------------------------------------------
function UI:CreateWindow(title, subtitle)
	if game.CoreGui:FindFirstChild("FlatGrayUI") then
		game.CoreGui.FlatGrayUI:Destroy()
	end
	_themed = {}

	local W, H, TH, SW, SBH = SZ.W, SZ.H, SZ.TH, SZ.SW, SZ.SBH
	local CW, CH = SZ.CW, SZ.CH

	local gui = Instance.new("ScreenGui")
	gui.Name = "FlatGrayUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.Parent = game.CoreGui

	-----------------------------------------------------------------------
	-- MAIN FRAME
	-----------------------------------------------------------------------
	local main = Instance.new("Frame", gui)
	main.Name = "Main"
	main.Size = UDim2.new(0, W, 0, H)
	main.Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = false
	main.ClipsDescendants = true
	main.ZIndex = 1
	reg(main, "BackgroundColor3", "Base")
	rnd(main, s(10))
	local ms = Instance.new("UIStroke", main)
	ms.Thickness = 1
	table.insert(_themed, { obj = ms, prop = "Color", key = "Border" })

	main.Size = UDim2.new(0, W, 0, 0)
	tw(main, { Size = UDim2.new(0, W, 0, H) }, 0.22)

	-----------------------------------------------------------------------
	-- TITLEBAR
	-----------------------------------------------------------------------
	local tb = frame(main, 0, 0, W, TH, "Surface", 2)

	frame(tb, 0, TH - 1, W, 1, "Border", 3) -- bottom line

	-- icon circle
	local ic = frame(tb, s(10), s(8), SZ.iconSz, SZ.iconSz, "Accent", 3)
	rnd(ic, SZ.iconSz)
	local icl = txt(ic, string.upper(string.sub(title, 1, 1)), 0, 0, SZ.iconSz, SZ.iconSz, "White", SZ.txtSM, "bold", 4)
	icl.TextXAlignment = Enum.TextXAlignment.Center

	txt(tb, title, SZ.iconSz + s(16), 0, s(120), TH, "Text", SZ.txtMD, "bold", 3)

	if subtitle then
		local sbg = frame(tb, SZ.iconSz + s(140), s(9), s(48), s(18), "TagBg", 3)
		rnd(sbg, 99)
		local sl = txt(sbg, subtitle, 0, 0, s(48), s(18), "TagText", SZ.txtXS, "bold", 4)
		sl.TextXAlignment = Enum.TextXAlignment.Center
	end

	-- window dots: close · minimize · help
	local dotDefs = {
		{ "Danger", Color3.fromRGB(180, 60, 60) },
		{ "Border", Color3.fromRGB(150, 150, 150) },
		{ "Panel", Color3.fromRGB(170, 170, 170) },
	}
	local dots = {}
	for i, d in ipairs(dotDefs) do
		local dot = Instance.new("TextButton", tb)
		dot.Size = UDim2.new(0, SZ.dotSz, 0, SZ.dotSz)
		dot.Position = UDim2.new(0, W - (i * (SZ.dotSz + s(6))), 0, math.floor((TH - SZ.dotSz) / 2))
		dot.BorderSizePixel = 0
		dot.Text = ""
		dot.AutoButtonColor = false
		dot.ZIndex = 3
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

	-- titlebar-only drag
	do
		local dragging, dragStart, startPos = false, nil, nil
		tb.InputBegan:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = inp.Position
				startPos = main.Position
			end
		end)
		UIS.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
		UIS.InputChanged:Connect(function(inp)
			if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
				local d = inp.Position - dragStart
				main.Position =
					UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end)
	end

	-----------------------------------------------------------------------
	-- SIDEBAR
	-----------------------------------------------------------------------
	local sidebar = frame(main, 0, TH, SW, CH, "Surface", 2)
	sidebar.ClipsDescendants = true
	frame(sidebar, SW - 1, 0, 1, CH, "Border", 3)

	-----------------------------------------------------------------------
	-- CONTENT
	-----------------------------------------------------------------------
	local contentArea = Instance.new("Frame", main)
	contentArea.Size = UDim2.new(0, CW, 0, CH)
	contentArea.Position = UDim2.new(0, SW, 0, TH)
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.ClipsDescendants = true
	contentArea.ZIndex = 2

	-----------------------------------------------------------------------
	-- STATUS BAR
	-----------------------------------------------------------------------
	local sb = frame(main, 0, H - SBH, W, SBH, "Surface", 2)
	frame(sb, 0, 0, W, 1, "Border", 3)

	local sbDot = frame(sb, s(10), math.floor((SBH - s(7)) / 2), s(7), s(7), "Green", 3)
	rnd(sbDot, 99)

	local sbTxt = txt(sb, "Ready", s(22), 0, W - s(110), SBH, "Text", SZ.txtXS, "base", 3)
	local sbVer = txt(sb, subtitle or "v1.0", W - s(96), 0, s(90), SBH, "Muted", SZ.txtXS, "base", 3)
	sbVer.TextXAlignment = Enum.TextXAlignment.Right

	-----------------------------------------------------------------------
	-- WINDOW OBJECT
	-----------------------------------------------------------------------
	local window = {}
	local pages = {}
	local tabBtns = {}
	local tabCount = 0

	function window:SetStatus(text, kind)
		sbTxt.Text = text or "Ready"
		local col = ({ ok = C.Green, running = C.Amber, error = C.Danger, idle = C.Border })[kind or "ok"] or C.Green
		tw(sbDot, { BackgroundColor3 = col }, 0.2)
	end

	-----------------------------------------------------------------------
	-- CREATE TAB
	-----------------------------------------------------------------------
	function window:CreateTab(name)
		tabCount = tabCount + 1
		local idx = tabCount
		local isFirst = idx == 1
		local yPos = SZ.tabPad + (idx - 1) * (SZ.tabH + SZ.tabGap)

		local btn = Instance.new("TextButton", sidebar)
		btn.Size = UDim2.new(0, SW - s(12), 0, SZ.tabH)
		btn.Position = UDim2.new(0, s(6), 0, yPos)
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 4
		reg(btn, "BackgroundColor3", isFirst and "White" or "Surface")
		rnd(btn, s(6))

		local bar = frame(btn, 0, s(4), s(3), SZ.tabH - s(8), "Accent", 5)
		bar.Visible = isFirst

		local btnLbl = txt(
			btn,
			name,
			s(10),
			0,
			SW - s(26),
			SZ.tabH,
			isFirst and "Text" or "Muted",
			SZ.txtSM,
			isFirst and "bold" or "base",
			5
		)

		local page = Instance.new("ScrollingFrame", contentArea)
		page.Size = UDim2.new(0, CW, 0, CH)
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = s(3)
		page.ScrollBarImageColor3 = C.Border
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Visible = isFirst
		page.ZIndex = 3

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
			btn.BackgroundColor3 = C.White
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

		-----------------------------------------------------------------------
		-- SECTION
		-----------------------------------------------------------------------
		local tab = {}
		local RW = CW - s(20)

		function tab:CreateSection(secName)
			local section = Instance.new("Frame", page)
			section.Size = UDim2.new(0, RW, 0, 0)
			section.AutomaticSize = Enum.AutomaticSize.Y
			section.BorderSizePixel = 0
			section.ZIndex = 4
			reg(section, "BackgroundColor3", "White")
			rnd(section, s(8))
			bdr(section, "Panel", 1)

			-- header
			local hdr = frame(section, 0, 0, RW, SZ.secHdrH, "Surface", 5)
			rnd(hdr, s(8))
			frame(hdr, 0, SZ.secHdrH - s(8), RW, s(8), "Surface", 5) -- square corners
			frame(hdr, 0, SZ.secHdrH - 1, RW, 1, "Panel", 6) -- bottom line
			local ad = frame(hdr, s(9), math.floor((SZ.secHdrH - s(4)) / 2), s(4), s(4), "Accent", 6)
			rnd(ad, 99)
			txt(hdr, secName, s(18), 0, RW - s(24), SZ.secHdrH, "Muted", SZ.txtXS, "bold", 6)

			-- rows holder
			local holder = Instance.new("Frame", section)
			holder.Size = UDim2.new(0, RW, 0, 0)
			holder.Position = UDim2.new(0, 0, 0, SZ.secHdrH)
			holder.AutomaticSize = Enum.AutomaticSize.Y
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = 4
			local hl = Instance.new("UIListLayout", holder)
			hl.Padding = UDim.new(0, 0)
			hl.SortOrder = Enum.SortOrder.LayoutOrder
			local hp = Instance.new("UIPadding", holder)
			hp.PaddingBottom = UDim.new(0, s(6))

			local api = {}

			-- ROW FACTORY
			local function row(h)
				local r = Instance.new("Frame", holder)
				r.Size = UDim2.new(0, RW, 0, h)
				r.BorderSizePixel = 0
				r.ZIndex = 5
				r.ClipsDescendants = false
				reg(r, "BackgroundColor3", "White")
				frame(r, s(10), h - 1, RW - s(20), 1, "Panel", 5) -- divider
				r.MouseEnter:Connect(function()
					tw(r, { BackgroundColor3 = C.Base }, 0.08)
				end)
				r.MouseLeave:Connect(function()
					tw(r, { BackgroundColor3 = C.White }, 0.08)
				end)
				return r
			end

			------------------------------------------------------------------
			-- TOGGLE
			-- Size: opts.Size = "sm"|"md"|"lg"|"xl"  (row height only)
			------------------------------------------------------------------
			function api:CreateToggle(opts)
				local hasDesc = opts.Description and opts.Description ~= ""

				-- size-specific row heights
				local RH_MAP = { sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL }
				local rh = RH_MAP[opts.Size] or (hasDesc and SZ.rowLG or SZ.rowMD)

				local r = row(rh)
				local state = opts.CurrentValue or false

				local nameY = math.floor((rh - s(16) - (hasDesc and s(13) or 0)) / 2)
				local nameSz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtMD

				txt(r, opts.Name, s(12), nameY, RW - s(60), s(16), "Text", nameSz, "base", 6)
				if hasDesc then
					local dl =
						txt(r, opts.Description, s(12), nameY + s(17), RW - s(60), s(13), "Muted", SZ.txtXS, "base", 6)
					dl.TextYAlignment = Enum.TextYAlignment.Top
				end

				local pill = frame(
					r,
					RW - s(44),
					math.floor((rh - SZ.pillH) / 2),
					SZ.pillW,
					SZ.pillH,
					state and "Accent" or "Panel",
					6
				)
				rnd(pill, 99)
				local thumb = frame(
					pill,
					state and (SZ.pillW - SZ.thumbSz - s(3)) or s(3),
					math.floor((SZ.pillH - SZ.thumbSz) / 2),
					SZ.thumbSz,
					SZ.thumbSz,
					"White",
					7
				)
				rnd(thumb, 99)
				bdr(thumb, "Border", 1)

				local function update()
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
				end

				local hit = Instance.new("TextButton", r)
				hit.Size = UDim2.new(0, RW, 0, rh)
				hit.BackgroundTransparency = 1
				hit.Text = ""
				hit.ZIndex = 8
				hit.MouseButton1Click:Connect(function()
					state = not state
					update()
				end)

				return {
					SetValue = function(_, v)
						state = v
						update()
					end,
					GetValue = function(_)
						return state
					end,
				}
			end

			------------------------------------------------------------------
			-- SLIDER
			-- opts.Size controls text size and row padding feel
			------------------------------------------------------------------
			function api:CreateSlider(opts)
				local rh = SZ.rowSlider
				if opts.Size == "lg" then
					rh = s(52)
				elseif opts.Size == "xl" then
					rh = s(60)
				elseif opts.Size == "sm" then
					rh = s(38)
				end

				local r = row(rh)
				local trkY = rh - s(13)
				local nameSz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtMD

				local nl = txt(
					r,
					opts.Name .. ": " .. (opts.CurrentValue or opts.Min),
					s(12),
					s(4),
					RW - s(20),
					s(16),
					"Text",
					nameSz,
					"base",
					6
				)

				local track = frame(r, s(12), trkY, RW - s(24), SZ.trackH, "Panel", 6)
				rnd(track, 99)
				local fill = frame(track, 0, 0, 0, SZ.trackH, "Accent", 7)
				rnd(fill, 99)

				local hsz = SZ.handleSz
				local handle = frame(track, 0, 0, hsz, hsz, "White", 8)
				handle.AnchorPoint = Vector2.new(0.5, 0.5)
				handle.Position = UDim2.new(0, 0, 0.5, 0)
				rnd(handle, 99)
				bdr(handle, "Accent", 2)

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

			------------------------------------------------------------------
			-- DROPDOWN
			------------------------------------------------------------------
			function api:CreateDropdown(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local r = row(rh)
				local nameSz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtMD

				txt(r, opts.Name, s(12), 0, RW / 2 - s(20), rh, "Text", nameSz, "base", 6)

				local selW = math.floor(RW / 2) - s(8)
				local selH = math.min(SZ.inputH, rh - s(12))
				local selBtn = Instance.new("TextButton", r)
				selBtn.Size = UDim2.new(0, selW, 0, selH)
				selBtn.Position = UDim2.new(0, RW - selW - s(10), 0, math.floor((rh - selH) / 2))
				selBtn.BorderSizePixel = 0
				selBtn.Text = ""
				selBtn.AutoButtonColor = false
				selBtn.ZIndex = 6
				reg(selBtn, "BackgroundColor3", "Base")
				rnd(selBtn, s(5))
				bdr(selBtn, "Border", 1)

				local selected = opts.Default or opts.Options[1]
				UI.Flags[opts.Flag] = selected

				local selLbl = txt(selBtn, selected, s(8), 0, selW - s(22), selH, "Text", SZ.txtSM, "base", 7)
				local chev = txt(selBtn, "v", selW - s(18), 0, s(16), selH, "Muted", SZ.txtXS, "bold", 7)
				chev.TextXAlignment = Enum.TextXAlignment.Center

				local OPH = s(26)
				local listH = math.min(#opts.Options * OPH, s(130))
				local list = Instance.new("Frame", gui)
				list.Size = UDim2.new(0, selW, 0, 0)
				list.BorderSizePixel = 0
				list.ZIndex = 60
				list.Visible = false
				list.ClipsDescendants = true
				reg(list, "BackgroundColor3", "White")
				rnd(list, s(5))
				bdr(list, "Border", 1)
				local ll = Instance.new("UIListLayout", list)
				ll.SortOrder = Enum.SortOrder.LayoutOrder

				local open = false
				local function close()
					open = false
					tw(chev, { Rotation = 0 }, 0.12)
					tw(list, { Size = UDim2.new(0, selW, 0, 0) }, 0.12)
					task.delay(0.13, function()
						list.Visible = false
					end)
				end

				selBtn.MouseButton1Click:Connect(function()
					if open then
						close()
					else
						open = true
						local ap = selBtn.AbsolutePosition
						local as = selBtn.AbsoluteSize
						list.Size = UDim2.new(0, selW, 0, 0)
						list.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + s(2))
						list.Visible = true
						tw(chev, { Rotation = 180 }, 0.12)
						tw(list, { Size = UDim2.new(0, selW, 0, listH) }, 0.15)
					end
				end)

				for _, opt in ipairs(opts.Options) do
					local ob = Instance.new("TextButton", list)
					ob.Size = UDim2.new(0, selW, 0, OPH)
					ob.BorderSizePixel = 0
					ob.Text = ""
					ob.AutoButtonColor = false
					ob.ZIndex = 61
					reg(ob, "BackgroundColor3", "White")
					local ol = txt(
						ob,
						opt,
						s(10),
						0,
						selW - s(10),
						OPH,
						opt == selected and "Accent" or "Text",
						SZ.txtSM,
						"base",
						62
					)
					ob.MouseEnter:Connect(function()
						tw(ob, { BackgroundColor3 = C.Base }, 0.08)
					end)
					ob.MouseLeave:Connect(function()
						tw(ob, { BackgroundColor3 = C.White }, 0.08)
					end)
					ob.MouseButton1Click:Connect(function()
						selected = opt
						selLbl.Text = opt
						UI.Flags[opts.Flag] = opt
						for _, child in pairs(list:GetChildren()) do
							if child:IsA("TextButton") then
								local tl = child:FindFirstChildOfClass("TextLabel")
								if tl then
									tl.TextColor3 = tl.Text == opt and C.Accent or C.Text
								end
							end
						end
						close()
						if opts.Callback then
							opts.Callback(opt)
						end
					end)
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
				}
			end

			------------------------------------------------------------------
			-- MULTI SELECT
			-- opts.Name     display label
			-- opts.Flag     key in UI.Flags  → table of selected strings
			-- opts.Options  array of strings
			-- opts.Default  array of pre-selected strings (optional)
			-- opts.Callback called with (selectedTable) on every change
			-- opts.Size     "sm"|"md"|"lg"|"xl"
			------------------------------------------------------------------
			function api:CreateMultiSelect(opts)
				-- Header row shows name + count badge + chevron
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local nameSz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtMD
				local headerRow = row(rh)

				-- selected set
				local selected = {}
				if opts.Default then
					for _, v in ipairs(opts.Default) do
						selected[v] = true
					end
				end
				UI.Flags[opts.Flag] = selected

				-- name label
				txt(headerRow, opts.Name, s(12), 0, RW - s(80), rh, "Text", nameSz, "base", 6)

				-- count badge
				local badgeW = s(32)
				local badge =
					frame(headerRow, RW - badgeW - s(28), math.floor((rh - s(18)) / 2), badgeW, s(18), "TagBg", 6)
				rnd(badge, 99)
				local countLbl = txt(badge, "0", 0, 0, badgeW, s(18), "TagText", SZ.txtXS, "bold", 7)
				countLbl.TextXAlignment = Enum.TextXAlignment.Center

				-- chevron
				local chev = txt(headerRow, "v", RW - s(22), 0, s(16), rh, "Muted", SZ.txtXS, "bold", 6)
				chev.TextXAlignment = Enum.TextXAlignment.Center

				-- click area on header
				local headerHit = Instance.new("TextButton", headerRow)
				headerHit.Size = UDim2.new(0, RW, 0, rh)
				headerHit.BackgroundTransparency = 1
				headerHit.Text = ""
				headerHit.ZIndex = 8

				-- expandable list panel (inline, not floating, so it pushes layout)
				local OPH = s(28)
				local listPanel = Instance.new("Frame", holder)
				listPanel.Size = UDim2.new(0, RW, 0, 0)
				listPanel.BackgroundTransparency = 1
				listPanel.BorderSizePixel = 0
				listPanel.ZIndex = 5
				listPanel.ClipsDescendants = true

				local listLL = Instance.new("UIListLayout", listPanel)
				listLL.Padding = UDim.new(0, 0)
				listLL.SortOrder = Enum.SortOrder.LayoutOrder

				-- "Select All / Clear" bar
				local ctrlRow = Instance.new("Frame", listPanel)
				ctrlRow.Size = UDim2.new(0, RW, 0, s(24))
				ctrlRow.BackgroundTransparency = 1
				ctrlRow.BorderSizePixel = 0
				ctrlRow.ZIndex = 5

				local function countSelected()
					local n = 0
					for _ in pairs(selected) do
						n = n + 1
					end
					return n
				end

				local function refreshCount()
					countLbl.Text = tostring(countSelected())
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
				end

				-- all option rows (built first so Select All can reference them)
				local optFrames = {}

				local function rebuildOptionColors()
					for _, of in pairs(optFrames) do
						local isOn = selected[of.opt] == true
						tw(of.bg, { BackgroundColor3 = isOn and C.TagBg or C.White }, 0.1)
						of.lbl.TextColor3 = isOn and C.Accent or C.Text
						of.check.Text = isOn and "✓" or ""
						of.check.TextColor3 = C.Accent
					end
				end

				-- Select All button
				local selAllBtn = Instance.new("TextButton", ctrlRow)
				selAllBtn.Size = UDim2.new(0, math.floor(RW / 2) - s(14), 0, s(20))
				selAllBtn.Position = UDim2.new(0, s(12), 0, s(2))
				selAllBtn.BackgroundTransparency = 1
				selAllBtn.Text = "Select all"
				selAllBtn.TextColor3 = C.Accent
				selAllBtn.Font = _fontBase
				selAllBtn.TextSize = SZ.txtXS
				selAllBtn.TextXAlignment = Enum.TextXAlignment.Left
				selAllBtn.BorderSizePixel = 0
				selAllBtn.ZIndex = 6
				selAllBtn.MouseButton1Click:Connect(function()
					for _, opt in ipairs(opts.Options) do
						selected[opt] = true
					end
					rebuildOptionColors()
					refreshCount()
					fireCallback()
				end)

				-- Clear button
				local clearBtn = Instance.new("TextButton", ctrlRow)
				clearBtn.Size = UDim2.new(0, math.floor(RW / 2) - s(14), 0, s(20))
				clearBtn.Position = UDim2.new(0, math.floor(RW / 2) + s(2), 0, s(2))
				clearBtn.BackgroundTransparency = 1
				clearBtn.Text = "Clear"
				clearBtn.TextColor3 = C.Danger
				clearBtn.Font = _fontBase
				clearBtn.TextSize = SZ.txtXS
				clearBtn.TextXAlignment = Enum.TextXAlignment.Left
				clearBtn.BorderSizePixel = 0
				clearBtn.ZIndex = 6
				clearBtn.MouseButton1Click:Connect(function()
					for k in pairs(selected) do
						selected[k] = nil
					end
					rebuildOptionColors()
					refreshCount()
					fireCallback()
				end)

				-- option rows
				for _, opt in ipairs(opts.Options) do
					local or2 = Instance.new("Frame", listPanel)
					or2.Size = UDim2.new(0, RW, 0, OPH)
					or2.BorderSizePixel = 0
					or2.ZIndex = 5
					reg(or2, "BackgroundColor3", "White")

					-- left accent bar (shown when selected)
					local acBar = frame(or2, 0, s(4), s(3), OPH - s(8), "Accent", 6)
					acBar.Visible = selected[opt] == true

					-- background tint
					local opBg = frame(or2, s(3), 0, RW - s(3), OPH, selected[opt] and "TagBg" or "White", 6)

					-- checkmark
					local chk = Instance.new("TextLabel", or2)
					chk.Size = UDim2.new(0, s(20), 0, OPH)
					chk.Position = UDim2.new(0, s(10), 0, 0)
					chk.BackgroundTransparency = 1
					chk.Text = selected[opt] and "✓" or ""
					chk.TextColor3 = C.Accent
					chk.Font = _fontBold
					chk.TextSize = SZ.txtSM
					chk.TextXAlignment = Enum.TextXAlignment.Center
					chk.ZIndex = 7

					-- label
					local ol = txt(
						or2,
						opt,
						s(32),
						0,
						RW - s(44),
						OPH,
						selected[opt] and "Accent" or "Text",
						nameSz,
						"base",
						7
					)

					-- bottom divider
					frame(or2, s(32), OPH - 1, RW - s(44), 1, "Panel", 5)

					-- hover
					or2.MouseEnter:Connect(function()
						if not selected[opt] then
							tw(opBg, { BackgroundColor3 = C.Base }, 0.08)
						end
					end)
					or2.MouseLeave:Connect(function()
						if not selected[opt] then
							tw(opBg, { BackgroundColor3 = C.White }, 0.08)
						end
					end)

					local hit2 = Instance.new("TextButton", or2)
					hit2.Size = UDim2.new(0, RW, 0, OPH)
					hit2.BackgroundTransparency = 1
					hit2.Text = ""
					hit2.ZIndex = 8
					hit2.MouseButton1Click:Connect(function()
						if selected[opt] then
							selected[opt] = nil
						else
							selected[opt] = true
						end
						local isOn = selected[opt] == true
						acBar.Visible = isOn
						tw(opBg, { BackgroundColor3 = isOn and C.TagBg or C.White }, 0.1)
						ol.TextColor3 = isOn and C.Accent or C.Text
						chk.Text = isOn and "✓" or ""
						refreshCount()
						fireCallback()
					end)

					table.insert(optFrames, { opt = opt, bg = opBg, lbl = ol, check = chk, bar = acBar })
				end

				refreshCount()

				-- toggle open/close
				local collapsed = true
				local totalH = s(24) + #opts.Options * OPH

				headerHit.MouseButton1Click:Connect(function()
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
						rebuildOptionColors()
						refreshCount()
						fireCallback()
					end,
					AddOption = function(_, opt)
						if not table.find(opts.Options, opt) then
							table.insert(opts.Options, opt)
							-- rebuild would need full re-render; simplest is re-open
						end
					end,
				}
			end

			------------------------------------------------------------------
			-- BUTTON
			-- opts.Size = "sm"|"md"|"lg"|"xl"
			-- opts.Style = "accent"|"danger"|"ghost"   (default = dark fill)
			-- opts.Font  overrides font for this button only
			------------------------------------------------------------------
			function api:CreateButton(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local bh = math.floor(rh * 0.68)
				local r = row(rh)

				local colorKey = opts.Style == "accent" and "Accent" or opts.Style == "danger" and "Danger" or "Dark"
				local isGhost = opts.Style == "ghost"
				local textSz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtMD
				local btnFont = opts.Font and resolveFont(opts.Font) or _fontBold

				local btn = Instance.new("TextButton", r)
				btn.Size = UDim2.new(0, RW - s(24), 0, bh)
				btn.Position = UDim2.new(0, s(12), 0, math.floor((rh - bh) / 2))
				btn.BorderSizePixel = 0
				btn.Text = opts.Name
				btn.Font = btnFont
				btn.TextSize = textSz
				btn.AutoButtonColor = false
				btn.ZIndex = 6
				rnd(btn, s(6))

				if isGhost then
					btn.BackgroundTransparency = 1
					btn.TextColor3 = C.Accent
					bdr(btn, "Accent", 1)
					btn.MouseEnter:Connect(function()
						tw(
							btn,
							{ BackgroundColor3 = C.Accent, BackgroundTransparency = 0.85, TextColor3 = C.White },
							0.1
						)
					end)
					btn.MouseLeave:Connect(function()
						tw(btn, { BackgroundColor3 = C.White, BackgroundTransparency = 1, TextColor3 = C.Accent }, 0.1)
					end)
				else
					reg(btn, "BackgroundColor3", colorKey)
					btn.TextColor3 = C.White
					btn.MouseEnter:Connect(function()
						tw(btn, { BackgroundColor3 = C[colorKey]:Lerp(Color3.new(0, 0, 0), 0.15) }, 0.1)
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

			------------------------------------------------------------------
			-- INPUT
			-- opts.Size / opts.Font supported
			------------------------------------------------------------------
			function api:CreateInput(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local ih = math.min(SZ.inputH, rh - s(12))
				local r = row(rh)
				local nameSz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtMD
				local inputFont = opts.Font and resolveFont(opts.Font) or _fontBase

				txt(r, opts.Name, s(12), 0, RW / 2 - s(20), rh, "Text", nameSz, "base", 6)

				local bxW = math.floor(RW / 2) - s(8)
				local bx = Instance.new("TextBox", r)
				bx.Size = UDim2.new(0, bxW, 0, ih)
				bx.Position = UDim2.new(0, RW - bxW - s(10), 0, math.floor((rh - ih) / 2))
				bx.BorderSizePixel = 0
				bx.Text = opts.Default or ""
				bx.PlaceholderText = opts.Placeholder or "Type here..."
				bx.Font = inputFont
				bx.TextSize = nameSz
				bx.ClearTextOnFocus = opts.ClearOnFocus ~= false
				bx.ZIndex = 6
				reg(bx, "BackgroundColor3", "Base")
				reg(bx, "TextColor3", "Text")
				reg(bx, "PlaceholderColor3", "Muted")
				rnd(bx, s(5))
				local bs = bdr(bx, "Border", 1)

				bx.Focused:Connect(function()
					tw(bs, { Color = C.Accent }, 0.12)
				end)
				bx.FocusLost:Connect(function(enter)
					tw(bs, { Color = C.Border }, 0.12)
					UI.Flags[opts.Flag] = bx.Text
					if opts.Callback then
						opts.Callback(bx.Text, enter)
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

			------------------------------------------------------------------
			-- KEYBIND
			------------------------------------------------------------------
			function api:CreateKeybind(opts)
				local rh = ({ sm = SZ.rowSM, md = SZ.rowMD, lg = SZ.rowLG, xl = SZ.rowXL })[opts.Size] or SZ.rowMD
				local ih = math.min(SZ.inputH, rh - s(12))
				local r = row(rh)
				local nameSz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtMD

				txt(r, opts.Name, s(12), 0, RW / 2 - s(20), rh, "Text", nameSz, "base", 6)
				if opts.Description then
					txt(r, opts.Description, s(12), s(20), RW / 2 - s(20), s(13), "Muted", SZ.txtXS, "base", 6)
				end

				local current = opts.Default or Enum.KeyCode.Unknown
				UI.Flags[opts.Flag] = current

				local kbW = math.floor(RW / 2) - s(8)
				local kbBtn = Instance.new("TextButton", r)
				kbBtn.Size = UDim2.new(0, kbW, 0, ih)
				kbBtn.Position = UDim2.new(0, RW - kbW - s(10), 0, math.floor((rh - ih) / 2))
				kbBtn.BorderSizePixel = 0
				kbBtn.Text = tostring(current.Name)
				kbBtn.Font = _fontBase
				kbBtn.TextSize = nameSz
				kbBtn.AutoButtonColor = false
				kbBtn.ZIndex = 6
				reg(kbBtn, "BackgroundColor3", "Base")
				reg(kbBtn, "TextColor3", "Text")
				rnd(kbBtn, s(5))
				local kbs = bdr(kbBtn, "Border", 1)

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

			------------------------------------------------------------------
			-- COLOR PICKER
			------------------------------------------------------------------
			function api:CreateColorPicker(opts)
				local current = opts.Default or Color3.fromRGB(255, 80, 80)
				UI.Flags[opts.Flag] = current
				local collapsed = true

				local headerRow = row(SZ.rowMD)
				txt(headerRow, opts.Name, s(12), 0, RW / 2 - s(20), SZ.rowMD, "Text", SZ.txtMD, "base", 6)

				local swatch = frame(headerRow, RW - s(46), s(7), s(28), s(20), "Base", 6)
				swatch.BackgroundColor3 = current
				rnd(swatch, s(4))
				bdr(swatch, "Border", 1)

				local swBtn = Instance.new("TextButton", headerRow)
				swBtn.Size = UDim2.new(0, RW, 0, SZ.rowMD)
				swBtn.BackgroundTransparency = 1
				swBtn.Text = ""
				swBtn.ZIndex = 7

				local pickerRow = Instance.new("Frame", holder)
				pickerRow.Size = UDim2.new(0, RW, 0, 0)
				pickerRow.BackgroundTransparency = 1
				pickerRow.BorderSizePixel = 0
				pickerRow.ZIndex = 5
				pickerRow.ClipsDescendants = true

				local svW = RW - s(40)
				local svH = math.floor(svW * 0.45)

				local svBox = frame(pickerRow, s(12), s(8), svW, svH, "White", 6)
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
				svBk.ZIndex = 7
				local svBG = Instance.new("UIGradient", svBk)
				svBG.Rotation = 90
				svBG.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
				})
				svBG.Transparency =
					NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })

				local svCursor = frame(svBox, 0, 0, s(10), s(10), "White", 10)
				rnd(svCursor, 99)
				svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
				bdr(svCursor, "Border", 1)

				local hueY = s(8) + svH + s(8)
				local hueBar = frame(pickerRow, s(12), hueY, svW, s(12), "White", 6)
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
				local hueCursor = frame(hueBar, 0, 0, s(6), s(12), "White", 10)
				rnd(hueCursor, s(2))
				bdr(hueCursor, "Border", 1)

				local hexY = hueY + s(12) + s(6)
				local hexLbl = txt(pickerRow, "#FFFFFF", s(12), hexY, svW, s(14), "Muted", SZ.txtXS, "base", 6)

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

			------------------------------------------------------------------
			-- LABEL
			-- opts.Size / opts.Font supported
			-- Style: "default"|"header"|"info"|"success"|"warn"|"error"
			------------------------------------------------------------------
			function api:CreateLabel(opts)
				local text, style, sizeKey, customFont
				if type(opts) == "string" then
					text = opts
					style = "default"
					sizeKey = "sm"
				else
					text = opts.Text or ""
					style = opts.Style or "default"
					sizeKey = opts.Size or "sm"
					customFont = opts.Font
				end

				local colorKey = ({
					default = "Muted",
					info = "Accent",
					success = "Green",
					warn = "Amber",
					error = "Danger",
					header = "Text",
				})[style] or "Muted"
				local isBold = (style == "header")
				local szMap = { sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL }
				local sz = szMap[sizeKey] or SZ.txtSM
				local rh = sz + s(14)
				local r = row(rh)

				local nl = txt(r, text, s(12), 0, RW - s(24), rh, colorKey, sz, isBold and "bold" or "base", 6)
				if customFont then
					nl.Font = resolveFont(customFont)
				end

				return {
					SetText = function(_, t)
						nl.Text = t
					end,
					GetText = function(_)
						return nl.Text
					end,
				}
			end

			------------------------------------------------------------------
			-- PARAGRAPH
			-- opts.Font overrides body font
			------------------------------------------------------------------
			function api:CreateParagraph(opts)
				local title = opts.Title or ""
				local body = opts.Body or opts.Text or ""
				local sz = ({ sm = SZ.txtSM, md = SZ.txtMD, lg = SZ.txtLG, xl = SZ.txtXL })[opts.Size] or SZ.txtSM
				local customFont = opts.Font

				local charsPerLine = math.floor((RW - s(24)) / (sz * 0.55))
				local lines = math.ceil(#body / math.max(charsPerLine, 1)) + 1
				local rh = s(14) + (title ~= "" and s(16) or 0) + lines * (sz + s(4)) + s(10)
				rh = math.max(rh, s(40))

				local r = row(rh)
				r.ClipsDescendants = false

				if title ~= "" then
					txt(r, title, s(12), s(6), RW - s(24), s(16), "Text", sz, "bold", 6)
				end

				local bl = Instance.new("TextLabel", r)
				bl.Position = UDim2.new(0, s(12), 0, title ~= "" and s(24) or s(8))
				bl.Size = UDim2.new(0, RW - s(24), 0, lines * (sz + s(4)))
				bl.BackgroundTransparency = 1
				bl.Text = body
				bl.TextWrapped = true
				bl.Font = customFont and resolveFont(customFont) or _fontBase
				bl.TextSize = sz
				bl.TextXAlignment = Enum.TextXAlignment.Left
				bl.TextYAlignment = Enum.TextYAlignment.Top
				bl.ZIndex = 6
				table.insert(_themed, { obj = bl, prop = "TextColor3", key = "Muted" })

				return {
					SetBody = function(_, t)
						bl.Text = t
					end,
				}
			end

			------------------------------------------------------------------
			-- DIVIDER
			------------------------------------------------------------------
			function api:CreateDivider(label_text)
				local dh = s(20)
				local r = row(dh)
				r.BackgroundTransparency = 1

				if label_text and label_text ~= "" then
					local lw = math.min(#label_text * s(7) + s(8), math.floor(RW / 2))
					local lnW = math.floor((RW - lw - s(24)) / 2)
					frame(r, s(12), s(9), lnW, 1, "Panel", 6)
					local dl = txt(r, label_text, s(12) + lnW + s(4), s(4), lw, s(12), "Muted", SZ.txtXS, "base", 6)
					dl.TextXAlignment = Enum.TextXAlignment.Center
					frame(r, s(12) + lnW + s(4) + lw + s(4), s(9), lnW, 1, "Panel", 6)
				else
					frame(r, s(12), s(9), RW - s(24), 1, "Panel", 6)
				end
			end

			return api
		end -- CreateSection
		return tab
	end -- CreateTab
	return window
end -- CreateWindow

return UI
