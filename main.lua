--[[
    FlatGrayUI  —  Complete UI Library
    Components:  Toggle, Slider, Dropdown, Button, Input,
                 Keybind, ColorPicker, Label, Paragraph, Divider
    Extras:      Notify, SaveConfig, LoadConfig, SetTheme
    Themes:      "light" (default), "dark", "ocean"
--]]

local UI = {}
UI.Flags = {}

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")

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

local C = THEMES.light -- active theme, swapped by SetTheme

-- Track all themed objects so SetTheme can re-colour them live
local _themed = {} -- { obj, prop, key }  e.g. {frame, "BackgroundColor3", "Surface"}
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
-- HELPERS
---------------------------------------------------------------------------
local function tw(o, p, t)
	TS:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), p):Play()
end

local function rnd(o, r)
	local u = Instance.new("UICorner", o)
	u.CornerRadius = UDim.new(0, r or 6)
end

local function bdr(o, key, th)
	local s = Instance.new("UIStroke", o)
	s.Color = C[key] or C.Border
	s.Thickness = th or 1
	table.insert(_themed, { obj = s, prop = "Color", key = key or "Border" })
	return s
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

local function txt(parent, text, x, y, w, h, colorKey, sz, font, z)
	local l = Instance.new("TextLabel", parent)
	l.Position = UDim2.new(0, x, 0, y)
	l.Size = UDim2.new(0, w, 0, h)
	l.BackgroundTransparency = 1
	l.Text = text
	l.Font = font or Enum.Font.Gotham
	l.TextSize = sz or 12
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

	local n = Instance.new("Frame", gui)
	n.Size = UDim2.new(0, 230, 0, 46)
	n.Position = UDim2.new(1, -250, 1, 10)
	n.BackgroundColor3 = bg
	n.BorderSizePixel = 0
	n.ZIndex = 100
	rnd(n, 8)
	local ns = Instance.new("UIStroke", n)
	ns.Color = C.Border
	ns.Thickness = 1

	local bar = Instance.new("Frame", n)
	bar.Size = UDim2.new(0, 4, 1, -16)
	bar.Position = UDim2.new(0, 8, 0, 8)
	bar.BackgroundColor3 = tc
	bar.BorderSizePixel = 0
	bar.ZIndex = 101
	rnd(bar, 2)

	local tl = Instance.new("TextLabel", n)
	tl.Size = UDim2.new(1, -26, 1, 0)
	tl.Position = UDim2.new(0, 22, 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = text
	tl.TextColor3 = tc
	tl.Font = Enum.Font.Gotham
	tl.TextSize = 12
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.TextWrapped = true
	tl.ZIndex = 101

	tw(n, { Position = UDim2.new(1, -250, 1, -58) }, 0.25)
	task.delay(duration, function()
		tw(n, { Position = UDim2.new(1, -250, 1, 10) }, 0.25)
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
	_themed = {} -- reset theme registry for new window

	local W, H, TH, SW, SBH = 500, 340, 36, 115, 22
	local CW = W - SW
	local CH = H - TH - SBH

	local gui = Instance.new("ScreenGui")
	gui.Name = "FlatGrayUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.Parent = game.CoreGui

	-----------------------------------------------------------------------
	-- MAIN
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
	rnd(main, 10)
	local mainStroke = Instance.new("UIStroke", main)
	mainStroke.Thickness = 1
	table.insert(_themed, { obj = mainStroke, prop = "Color", key = "Border" })

	main.Size = UDim2.new(0, W, 0, 0)
	tw(main, { Size = UDim2.new(0, W, 0, H) }, 0.22)

	-----------------------------------------------------------------------
	-- TITLE BAR
	-----------------------------------------------------------------------
	local tb = frame(main, 0, 0, W, TH, "Surface", 2)

	local tbLine = frame(tb, 0, TH - 1, W, 1, "Border", 3)

	-- icon circle
	local ic = frame(tb, 10, 8, 20, 20, "Accent", 3)
	rnd(ic, 10)
	local icl = txt(ic, string.upper(string.sub(title, 1, 1)), 0, 0, 20, 20, "White", 11, Enum.Font.GothamBold, 4)
	icl.TextXAlignment = Enum.TextXAlignment.Center

	txt(tb, title, 36, 0, 120, TH, "Text", 13, Enum.Font.GothamSemibold, 3)

	if subtitle then
		local bg2 = frame(tb, 162, 9, 48, 18, "TagBg", 3)
		rnd(bg2, 99)
		local sl = txt(bg2, subtitle, 0, 0, 48, 18, "TagText", 10, Enum.Font.GothamSemibold, 4)
		sl.TextXAlignment = Enum.TextXAlignment.Center
	end

	-- window dots
	local dotDefs = {
		{ "Danger", Color3.fromRGB(180, 60, 60) },
		{ "Border", Color3.fromRGB(150, 150, 150) },
		{ "Panel", Color3.fromRGB(170, 170, 170) },
	}
	local dots = {}
	for i, d in ipairs(dotDefs) do
		local dot = Instance.new("TextButton", tb)
		dot.Size = UDim2.new(0, 12, 0, 12)
		dot.Position = UDim2.new(0, W - (i * 18), 0, 12)
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

	-- titlebar drag (safe — doesn't steal slider events)
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

	local sdiv = frame(sidebar, SW - 1, 0, 1, CH, "Border", 3)

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

	local sbDot = frame(sb, 10, 7, 7, 7, "Green", 3)
	rnd(sbDot, 99)

	local sbTxt = txt(sb, "Ready", 22, 0, 280, SBH, "Text", 11, Enum.Font.Gotham, 3)
	local sbVer = txt(sb, subtitle or "v1.0", W - 96, 0, 90, SBH, "Muted", 10, Enum.Font.Gotham, 3)
	sbVer.TextXAlignment = Enum.TextXAlignment.Right

	-----------------------------------------------------------------------
	-- WINDOW OBJECT
	-----------------------------------------------------------------------
	local window = {}
	local pages, tabBtns = {}, {}
	local tabCount = 0
	local TAB_H, TAB_PAD, TAB_GAP = 28, 8, 2

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

		local yPos = TAB_PAD + (idx - 1) * (TAB_H + TAB_GAP)

		local btn = Instance.new("TextButton", sidebar)
		btn.Size = UDim2.new(0, SW - 12, 0, TAB_H)
		btn.Position = UDim2.new(0, 6, 0, yPos)
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 4
		reg(btn, "BackgroundColor3", isFirst and "White" or "Surface")
		rnd(btn, 6)

		local bar = Instance.new("Frame", btn)
		bar.Size = UDim2.new(0, 3, 0, TAB_H - 8)
		bar.Position = UDim2.new(0, 0, 0, 4)
		bar.BorderSizePixel = 0
		bar.Visible = isFirst
		bar.ZIndex = 5
		reg(bar, "BackgroundColor3", "Accent")

		local btnLbl = txt(
			btn,
			name,
			10,
			0,
			SW - 26,
			TAB_H,
			isFirst and "Text" or "Muted",
			12,
			isFirst and Enum.Font.GothamSemibold or Enum.Font.Gotham,
			5
		)

		local page = Instance.new("ScrollingFrame", contentArea)
		page.Size = UDim2.new(0, CW, 0, CH)
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = C.Border
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Visible = isFirst
		page.ZIndex = 3

		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder

		local pad = Instance.new("UIPadding", page)
		pad.PaddingTop = UDim.new(0, 10)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.PaddingBottom = UDim.new(0, 10)

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
				t.lbl.Font = Enum.Font.Gotham
			end
			page.Visible = true
			bar.Visible = true
			btn.BackgroundColor3 = C.White
			btnLbl.TextColor3 = C.Text
			btnLbl.Font = Enum.Font.GothamSemibold
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
		local RW = CW - 20

		function tab:CreateSection(secName)
			local section = Instance.new("Frame", page)
			section.Size = UDim2.new(0, RW, 0, 0)
			section.AutomaticSize = Enum.AutomaticSize.Y
			section.BorderSizePixel = 0
			section.ZIndex = 4
			reg(section, "BackgroundColor3", "White")
			rnd(section, 8)
			bdr(section, "Panel", 1)

			local hdr = frame(section, 0, 0, RW, 26, "Surface", 5)
			rnd(hdr, 8)
			frame(hdr, 0, 18, RW, 8, "Surface", 5) -- square bottom corners
			frame(hdr, 0, 25, RW, 1, "Panel", 6) -- bottom line

			local ad = frame(hdr, 9, 11, 4, 4, "Accent", 6)
			rnd(ad, 99)

			txt(hdr, secName, 18, 0, RW - 24, 26, "Muted", 10, Enum.Font.GothamSemibold, 6)

			local holder = Instance.new("Frame", section)
			holder.Size = UDim2.new(0, RW, 0, 0)
			holder.Position = UDim2.new(0, 0, 0, 26)
			holder.AutomaticSize = Enum.AutomaticSize.Y
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = 4

			local hl = Instance.new("UIListLayout", holder)
			hl.Padding = UDim.new(0, 0)
			hl.SortOrder = Enum.SortOrder.LayoutOrder

			local hp = Instance.new("UIPadding", holder)
			hp.PaddingBottom = UDim.new(0, 6)

			local api = {}

			-- ROW factory
			local function row(h)
				local r = Instance.new("Frame", holder)
				r.Size = UDim2.new(0, RW, 0, h)
				r.BorderSizePixel = 0
				r.ZIndex = 5
				r.ClipsDescendants = false
				reg(r, "BackgroundColor3", "White")

				local dv = frame(r, 10, h - 1, RW - 20, 1, "Panel", 5)

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
			------------------------------------------------------------------
			function api:CreateToggle(opts)
				local hasDesc = opts.Description and opts.Description ~= ""
				local rh = hasDesc and 40 or 32
				local r = row(rh)
				local state = opts.CurrentValue or false

				txt(r, opts.Name, 12, hasDesc and 5 or 8, RW - 60, 16, "Text", 12, Enum.Font.Gotham, 6)
				if hasDesc then
					local dl = txt(r, opts.Description, 12, 22, RW - 60, 13, "Muted", 10, Enum.Font.Gotham, 6)
					dl.TextYAlignment = Enum.TextYAlignment.Top
				end

				local pill = frame(r, RW - 44, math.floor((rh - 18) / 2), 34, 18, state and "Accent" or "Panel", 6)
				rnd(pill, 99)

				local thumb = frame(pill, state and 19 or 3, 3, 12, 12, "White", 7)
				rnd(thumb, 99)
				bdr(thumb, "Border", 1)

				local function update()
					UI.Flags[opts.Flag] = state
					tw(pill, { BackgroundColor3 = state and C.Accent or C.Panel }, 0.15)
					tw(thumb, { Position = state and UDim2.new(0, 19, 0, 3) or UDim2.new(0, 3, 0, 3) }, 0.15)
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
			------------------------------------------------------------------
			function api:CreateSlider(opts)
				local r = row(44)

				local nl = txt(
					r,
					opts.Name .. ": " .. (opts.CurrentValue or opts.Min),
					12,
					4,
					RW - 20,
					16,
					"Text",
					12,
					Enum.Font.Gotham,
					6
				)

				local track = frame(r, 12, 27, RW - 24, 5, "Panel", 6)
				rnd(track, 99)

				local fill = frame(track, 0, 0, 0, 5, "Accent", 7)
				rnd(fill, 99)

				local handle = frame(track, 0, 0, 13, 13, "White", 8)
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
						local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						upd(opts.Min + (opts.Max - opts.Min) * pct)
					end
				end)
				UIS.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				UIS.InputChanged:Connect(function(i)
					if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						local pct = math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
						upd(opts.Min + (opts.Max - opts.Min) * pct)
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
				local r = row(34)
				txt(r, opts.Name, 12, 0, RW / 2 - 20, 34, "Text", 12, Enum.Font.Gotham, 6)

				local selW = math.floor(RW / 2) - 8
				local selBtn = Instance.new("TextButton", r)
				selBtn.Size = UDim2.new(0, selW, 0, 22)
				selBtn.Position = UDim2.new(0, RW - selW - 10, 0, 6)
				selBtn.BorderSizePixel = 0
				selBtn.Text = ""
				selBtn.AutoButtonColor = false
				selBtn.ZIndex = 6
				reg(selBtn, "BackgroundColor3", "Base")
				rnd(selBtn, 5)
				bdr(selBtn, "Border", 1)

				local selected = opts.Default or opts.Options[1]
				UI.Flags[opts.Flag] = selected

				local selLbl = txt(selBtn, selected, 8, 0, selW - 22, 22, "Text", 11, Enum.Font.Gotham, 7)
				local chev = txt(selBtn, "v", selW - 18, 0, 16, 22, "Muted", 10, Enum.Font.GothamBold, 7)
				chev.TextXAlignment = Enum.TextXAlignment.Center

				local OPH = 26
				local listH = math.min(#opts.Options * OPH, 130)

				local list = Instance.new("Frame", gui)
				list.Size = UDim2.new(0, selW, 0, 0)
				list.BorderSizePixel = 0
				list.ZIndex = 60
				list.Visible = false
				list.ClipsDescendants = true
				reg(list, "BackgroundColor3", "White")
				rnd(list, 5)
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
						list.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2)
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
						10,
						0,
						selW - 10,
						OPH,
						opt == selected and "Accent" or "Text",
						11,
						Enum.Font.Gotham,
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
			-- BUTTON
			------------------------------------------------------------------
			function api:CreateButton(opts)
				local r = row(36)
				local isAccent = opts.Style == "accent"
				local isDanger = opts.Style == "danger"
				local colorKey = isAccent and "Accent" or (isDanger and "Danger" or "Dark")

				local btn = Instance.new("TextButton", r)
				btn.Size = UDim2.new(0, RW - 24, 0, 24)
				btn.Position = UDim2.new(0, 12, 0, 6)
				btn.BorderSizePixel = 0
				btn.Text = opts.Name
				btn.TextColor3 = C.White
				btn.Font = Enum.Font.GothamSemibold
				btn.TextSize = 12
				btn.AutoButtonColor = false
				btn.ZIndex = 6
				reg(btn, "BackgroundColor3", colorKey)
				rnd(btn, 6)

				btn.MouseEnter:Connect(function()
					tw(btn, { BackgroundColor3 = C[colorKey]:Lerp(Color3.new(0, 0, 0), 0.15) }, 0.1)
				end)
				btn.MouseLeave:Connect(function()
					tw(btn, { BackgroundColor3 = C[colorKey] }, 0.1)
				end)
				btn.MouseButton1Down:Connect(function()
					tw(btn, { Size = UDim2.new(0, RW - 28, 0, 22), Position = UDim2.new(0, 14, 0, 7) }, 0.06)
				end)
				btn.MouseButton1Up:Connect(function()
					tw(btn, { Size = UDim2.new(0, RW - 24, 0, 24), Position = UDim2.new(0, 12, 0, 6) }, 0.06)
				end)
				btn.MouseButton1Click:Connect(function()
					if opts.Callback then
						opts.Callback()
					end
				end)
			end

			------------------------------------------------------------------
			-- INPUT  (text box)
			------------------------------------------------------------------
			function api:CreateInput(opts)
				local r = row(34)
				txt(r, opts.Name, 12, 0, RW / 2 - 20, 34, "Text", 12, Enum.Font.Gotham, 6)

				local bxW = math.floor(RW / 2) - 8
				local bx = Instance.new("TextBox", r)
				bx.Size = UDim2.new(0, bxW, 0, 22)
				bx.Position = UDim2.new(0, RW - bxW - 10, 0, 6)
				bx.BorderSizePixel = 0
				bx.Text = opts.Default or ""
				bx.PlaceholderText = opts.Placeholder or "Type here..."
				bx.TextColor3 = C.Text
				bx.PlaceholderColor3 = C.Muted
				bx.Font = Enum.Font.Gotham
				bx.TextSize = 11
				bx.ClearTextOnFocus = opts.ClearOnFocus ~= false
				bx.ZIndex = 6
				reg(bx, "BackgroundColor3", "Base")
				rnd(bx, 5)
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
			-- Shows current key; click then press any key to rebind
			------------------------------------------------------------------
			function api:CreateKeybind(opts)
				local r = row(34)
				txt(r, opts.Name, 12, 0, RW / 2 - 20, 34, "Text", 12, Enum.Font.Gotham, 6)
				if opts.Description then
					txt(r, opts.Description, 12, 20, RW / 2 - 20, 13, "Muted", 10, Enum.Font.Gotham, 6)
				end

				local current = opts.Default or Enum.KeyCode.Unknown
				UI.Flags[opts.Flag] = current

				local kbW = math.floor(RW / 2) - 8
				local kbBtn = Instance.new("TextButton", r)
				kbBtn.Size = UDim2.new(0, kbW, 0, 22)
				kbBtn.Position = UDim2.new(0, RW - kbW - 10, 0, 6)
				kbBtn.BorderSizePixel = 0
				kbBtn.Text = tostring(current.Name)
				kbBtn.TextColor3 = C.Text
				kbBtn.Font = Enum.Font.Gotham
				kbBtn.TextSize = 11
				kbBtn.AutoButtonColor = false
				kbBtn.ZIndex = 6
				reg(kbBtn, "BackgroundColor3", "Base")
				rnd(kbBtn, 5)
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
					-- Escape cancels
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

				-- fire when the bound key is pressed (outside listening state)
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
			-- Compact: shows a color swatch; clicking opens an inline
			-- hue/saturation picker + brightness slider
			------------------------------------------------------------------
			function api:CreateColorPicker(opts)
				local current = opts.Default or Color3.fromRGB(255, 80, 80)
				UI.Flags[opts.Flag] = current

				local PICKER_H = 140
				local collapsed = true

				-- header row (always visible)
				local headerRow = row(34)

				txt(headerRow, opts.Name, 12, 0, RW / 2 - 20, 34, "Text", 12, Enum.Font.Gotham, 6)

				local swatch = frame(headerRow, RW - 46, 7, 28, 20, "Base", 6)
				swatch.BackgroundColor3 = current
				rnd(swatch, 4)
				bdr(swatch, "Border", 1)

				local swBtn = Instance.new("TextButton", headerRow)
				swBtn.Size = UDim2.new(0, RW, 0, 34)
				swBtn.BackgroundTransparency = 1
				swBtn.Text = ""
				swBtn.ZIndex = 7

				-- picker panel (toggled)
				local pickerRow = Instance.new("Frame", holder)
				pickerRow.Size = UDim2.new(0, RW, 0, 0)
				pickerRow.BackgroundTransparency = 1
				pickerRow.BorderSizePixel = 0
				pickerRow.ZIndex = 5
				pickerRow.ClipsDescendants = true

				-- SV (saturation/value) square — drawn with nested gradients
				local svSize = RW - 40
				local svBox = frame(pickerRow, 12, 8, svSize, svSize * 0.5, "White", 6)
				rnd(svBox, 4)

				local svWhite = Instance.new("UIGradient", svBox)
				svWhite.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
				})
				svWhite.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(1, 1),
				})

				local svBlack = Instance.new("Frame", svBox)
				svBlack.Size = UDim2.new(1, 0, 1, 0)
				svBlack.BackgroundTransparency = 0
				svBlack.BorderSizePixel = 0
				svBlack.ZIndex = 7
				local svBG = Instance.new("UIGradient", svBlack)
				svBG.Rotation = 90
				svBG.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
					ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0)),
				})
				svBG.Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(1, 0),
				})

				-- SV cursor
				local svCursor = frame(svBox, 0, 0, 10, 10, "White", 10)
				rnd(svCursor, 99)
				svCursor.BackgroundColor3 = Color3.new(1, 1, 1)
				bdr(svCursor, "Border", 1)

				-- Hue bar
				local hueBarY = 8 + svSize * 0.5 + 8
				local hueBar = frame(pickerRow, 12, hueBarY, svSize, 12, "White", 6)
				rnd(hueBar, 4)
				local hueGrad = Instance.new("UIGradient", hueBar)
				hueGrad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
					ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
					ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
					ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
					ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
					ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
				})

				local hueCursor = frame(hueBar, 0, 0, 6, 12, "White", 10)
				rnd(hueCursor, 2)
				bdr(hueCursor, "Border", 1)

				-- hex label
				local hexY = hueBarY + 12 + 6
				local hexLbl = txt(
					pickerRow,
					"#"
						.. string.format(
							"%02X%02X%02X",
							math.floor(current.R * 255),
							math.floor(current.G * 255),
							math.floor(current.B * 255)
						),
					12,
					hexY,
					svSize,
					14,
					"Muted",
					10,
					Enum.Font.GothamSemibold,
					6
				)

				-- internal H, S, V state
				local H, S, V = Color3.toHSV(current)

				local function applyColor()
					current = Color3.fromHSV(H, S, V)
					UI.Flags[opts.Flag] = current
					swatch.BackgroundColor3 = current
					svBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
					local cx = math.clamp(S * (svSize - 10), 0, svSize - 10)
					local cy = math.clamp((1 - V) * (svSize * 0.5 - 10), 0, svSize * 0.5 - 10)
					svCursor.Position = UDim2.new(0, cx, 0, cy)
					hueCursor.Position = UDim2.new(0, math.clamp(H * (svSize - 6), 0, svSize - 6), 0, 0)
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

				-- SV drag
				local svDragging = false
				svBox.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						svDragging = true
						S = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
						V = 1 - math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
						applyColor()
					end
				end)
				UIS.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						svDragging = false
					end
				end)
				UIS.InputChanged:Connect(function(i)
					if svDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						S = math.clamp((i.Position.X - svBox.AbsolutePosition.X) / svBox.AbsoluteSize.X, 0, 1)
						V = 1 - math.clamp((i.Position.Y - svBox.AbsolutePosition.Y) / svBox.AbsoluteSize.Y, 0, 1)
						applyColor()
					end
				end)

				-- Hue drag
				local hueDragging = false
				hueBar.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						hueDragging = true
						H = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
						applyColor()
					end
				end)
				UIS.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						hueDragging = false
					end
				end)
				UIS.InputChanged:Connect(function(i)
					if hueDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						H = math.clamp((i.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
						applyColor()
					end
				end)

				-- toggle open/close
				local totalPickerH = 8 + svSize * 0.5 + 8 + 12 + 6 + 14 + 8
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
			-- LABEL  (static styled text line)
			------------------------------------------------------------------
			function api:CreateLabel(opts)
				-- accepts either a plain string OR a table
				local text, style
				if type(opts) == "string" then
					text = opts
					style = "default"
				else
					text = opts.Text or ""
					style = opts.Style or "default"
				end

				local colorKey = ({
					default = "Muted",
					info = "Accent",
					success = "Green",
					warn = "Amber",
					error = "Danger",
					header = "Text",
				})[style] or "Muted"

				local font = (style == "header") and Enum.Font.GothamSemibold or Enum.Font.Gotham
				local sz = (style == "header") and 13 or 11

				local r = row(26)
				local nl = txt(r, text, 12, 0, RW - 24, 26, colorKey, sz, font, 6)
				nl.TextXAlignment = Enum.TextXAlignment.Left

				-- return handle so caller can update text
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
			-- PARAGRAPH  (multi-line wrapped text block)
			------------------------------------------------------------------
			function api:CreateParagraph(opts)
				local title = opts.Title or ""
				local body = opts.Body or opts.Text or ""

				-- measure approximate height: ~16px per wrapped line + title row
				local charsPerLine = math.floor((RW - 24) / 7)
				local lines = math.ceil(#body / math.max(charsPerLine, 1)) + 1
				local rh = 14 + lines * 16 + 10
				rh = math.max(rh, 40)

				local r = row(rh)
				r.ClipsDescendants = false

				if title ~= "" then
					txt(r, title, 12, 6, RW - 24, 14, "Text", 11, Enum.Font.GothamSemibold, 6)
				end

				local bl = Instance.new("TextLabel", r)
				bl.Position = UDim2.new(0, 12, 0, title ~= "" and 22 or 8)
				bl.Size = UDim2.new(0, RW - 24, 0, lines * 16)
				bl.BackgroundTransparency = 1
				bl.Text = body
				bl.TextWrapped = true
				bl.TextColor3 = C.Muted
				bl.Font = Enum.Font.Gotham
				bl.TextSize = 11
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
			-- DIVIDER  (visual separator with optional label)
			------------------------------------------------------------------
			function api:CreateDivider(label_text)
				local r = row(20)
				r.BackgroundTransparency = 1 -- divider row itself is invisible

				if label_text and label_text ~= "" then
					-- line — label — line layout
					local lw = math.min(#label_text * 7 + 8, RW / 2)
					local lineW = math.floor((RW - lw - 24) / 2)

					frame(r, 12, 9, lineW, 1, "Panel", 6)
					txt(r, label_text, 12 + lineW + 4, 4, lw, 12, "Muted", 9, Enum.Font.Gotham, 6)
					frame(r, 12 + lineW + 4 + lw + 4, 9, lineW, 1, "Panel", 6)
				else
					frame(r, 12, 9, RW - 24, 1, "Panel", 6)
				end

				-- remove the divider at the bottom of the divider row itself
				local children = r:GetChildren()
				for _, ch in pairs(children) do
					if ch:IsA("Frame") and ch.Size.Y.Offset == 1 and ch.Position.Y.Offset == 19 then
						ch:Destroy()
						break
					end
				end
			end

			return api
		end -- CreateSection

		return tab
	end -- CreateTab

	return window
end -- CreateWindow

return UI
