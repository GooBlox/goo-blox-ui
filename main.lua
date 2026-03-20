-- FlatGrayUI Library
-- Flat Gray palette, fixed layout

local UI = {}
UI.Flags = {}

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")

---------------------------------------------------------------------------
-- PALETTE
---------------------------------------------------------------------------
local C = {
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
}

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

local function bdr(o, col, th)
	local s = Instance.new("UIStroke", o)
	s.Color = col or C.Border
	s.Thickness = th or 1
	return s
end

-- Make a simple TextLabel with NO tricky relative sizing
local function lbl(parent, txt, x, y, w, h, col, sz, bold, z)
	local l = Instance.new("TextLabel")
	l.Parent = parent
	l.Position = UDim2.new(0, x, 0, y)
	l.Size = UDim2.new(0, w, 0, h)
	l.BackgroundTransparency = 1
	l.Text = txt
	l.TextColor3 = col or C.Text
	l.Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham
	l.TextSize = sz or 12
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	l.ZIndex = z or 5
	l.ClipsDescendants = false
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

	local bgs = {
		info = Color3.fromRGB(240, 244, 255),
		success = Color3.fromRGB(234, 243, 222),
		warn = Color3.fromRGB(250, 238, 218),
		error = Color3.fromRGB(252, 235, 235),
	}
	local tcs = {
		info = Color3.fromRGB(57, 73, 171),
		success = Color3.fromRGB(59, 109, 17),
		warn = Color3.fromRGB(133, 79, 11),
		error = Color3.fromRGB(163, 45, 45),
	}
	local bg = bgs[kind] or bgs.info
	local tc = tcs[kind] or tcs.info

	local n = Instance.new("Frame", gui)
	n.Size = UDim2.new(0, 220, 0, 44)
	n.Position = UDim2.new(1, -240, 1, 10)
	n.BackgroundColor3 = bg
	n.BorderSizePixel = 0
	n.ZIndex = 100
	rnd(n, 8)
	bdr(n, C.Border, 1)

	local bar = Instance.new("Frame", n)
	bar.Size = UDim2.new(0, 4, 1, -16)
	bar.Position = UDim2.new(0, 8, 0, 8)
	bar.BackgroundColor3 = tc
	bar.BorderSizePixel = 0
	bar.ZIndex = 101
	rnd(bar, 2)

	local t = Instance.new("TextLabel", n)
	t.Size = UDim2.new(1, -24, 1, 0)
	t.Position = UDim2.new(0, 20, 0, 0)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextColor3 = tc
	t.Font = Enum.Font.Gotham
	t.TextSize = 12
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextWrapped = true
	t.ZIndex = 101

	tw(n, { Position = UDim2.new(1, -240, 1, -60) }, 0.25)
	task.delay(duration, function()
		tw(n, { Position = UDim2.new(1, -240, 1, 10) }, 0.25)
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

	-- Fixed pixel dimensions — no scale math that can break
	local W, H, TH, SW, SBH = 480, 320, 36, 110, 22
	local CW = W - SW -- content width  = 370
	local CH = H - TH - SBH -- content height = 262

	local gui = Instance.new("ScreenGui")
	gui.Name = "FlatGrayUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.Parent = game.CoreGui

	---------------------------------------------------------------------------
	-- MAIN FRAME
	---------------------------------------------------------------------------
	local main = Instance.new("Frame", gui)
	main.Name = "Main"
	main.Size = UDim2.new(0, W, 0, H)
	main.Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
	main.BackgroundColor3 = C.Base
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = false -- must be false; true steals mouse drag from sliders
	main.ClipsDescendants = true
	main.ZIndex = 1
	rnd(main, 10)
	bdr(main, C.Border, 1)

	-- open animation
	main.Size = UDim2.new(0, W, 0, 0)
	tw(main, { Size = UDim2.new(0, W, 0, H) }, 0.2)

	---------------------------------------------------------------------------
	-- TITLE BAR  (z=2)
	---------------------------------------------------------------------------
	local tb = Instance.new("Frame", main)
	tb.Size = UDim2.new(0, W, 0, TH)
	tb.Position = UDim2.new(0, 0, 0, 0)
	tb.BackgroundColor3 = C.Surface
	tb.BorderSizePixel = 0
	tb.ZIndex = 2

	-- bottom border
	local tbl = Instance.new("Frame", tb)
	tbl.Size = UDim2.new(0, W, 0, 1)
	tbl.Position = UDim2.new(0, 0, 0, TH - 1)
	tbl.BackgroundColor3 = C.Border
	tbl.BorderSizePixel = 0
	tbl.ZIndex = 3

	-- icon circle
	local ic = Instance.new("Frame", tb)
	ic.Size = UDim2.new(0, 20, 0, 20)
	ic.Position = UDim2.new(0, 10, 0, 8)
	ic.BackgroundColor3 = C.Accent
	ic.BorderSizePixel = 0
	ic.ZIndex = 3
	rnd(ic, 10)

	local icl = Instance.new("TextLabel", ic)
	icl.Size = UDim2.new(0, 20, 0, 20)
	icl.BackgroundTransparency = 1
	icl.Text = string.upper(string.sub(title, 1, 1))
	icl.TextColor3 = C.White
	icl.Font = Enum.Font.GothamBold
	icl.TextSize = 11
	icl.TextXAlignment = Enum.TextXAlignment.Center
	icl.ZIndex = 4

	-- title text
	local titleLbl = Instance.new("TextLabel", tb)
	titleLbl.Size = UDim2.new(0, 110, 0, TH)
	titleLbl.Position = UDim2.new(0, 36, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextColor3 = C.Text
	titleLbl.Font = Enum.Font.GothamSemibold
	titleLbl.TextSize = 13
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.TextYAlignment = Enum.TextYAlignment.Center
	titleLbl.ZIndex = 3

	-- subtitle badge
	if subtitle then
		local bg2 = Instance.new("Frame", tb)
		bg2.Size = UDim2.new(0, 44, 0, 18)
		bg2.Position = UDim2.new(0, 152, 0, 9)
		bg2.BackgroundColor3 = C.TagBg
		bg2.BorderSizePixel = 0
		bg2.ZIndex = 3
		rnd(bg2, 99)

		local bl = Instance.new("TextLabel", bg2)
		bl.Size = UDim2.new(0, 44, 0, 18)
		bl.BackgroundTransparency = 1
		bl.Text = subtitle
		bl.TextColor3 = C.TagText
		bl.Font = Enum.Font.GothamSemibold
		bl.TextSize = 10
		bl.TextXAlignment = Enum.TextXAlignment.Center
		bl.ZIndex = 4
	end

	-- window control dots (close, minimize, help) — right side of titlebar
	local dotData = {
		{ C.Danger, Color3.fromRGB(180, 60, 60) },
		{ Color3.fromRGB(200, 200, 200), Color3.fromRGB(150, 150, 150) },
		{ Color3.fromRGB(220, 220, 220), Color3.fromRGB(170, 170, 170) },
	}
	local dots = {}
	for i, d in ipairs(dotData) do
		local dot = Instance.new("TextButton", tb)
		dot.Size = UDim2.new(0, 12, 0, 12)
		dot.Position = UDim2.new(0, W - (i * 18), 0, 12)
		dot.BackgroundColor3 = d[1]
		dot.BorderSizePixel = 0
		dot.Text = ""
		dot.AutoButtonColor = false
		dot.ZIndex = 3
		rnd(dot, 99)
		dot.MouseEnter:Connect(function()
			tw(dot, { BackgroundColor3 = d[2] }, 0.1)
		end)
		dot.MouseLeave:Connect(function()
			tw(dot, { BackgroundColor3 = d[1] }, 0.1)
		end)
		dots[i] = dot
	end

	-- close
	dots[1].MouseButton1Click:Connect(function()
		tw(main, { Size = UDim2.new(0, W, 0, 0) }, 0.18)
		task.wait(0.2)
		gui:Destroy()
	end)

	-- minimize
	local minimized = false
	dots[2].MouseButton1Click:Connect(function()
		minimized = not minimized
		tw(main, { Size = minimized and UDim2.new(0, W, 0, TH) or UDim2.new(0, W, 0, H) }, 0.2)
	end)

	-- keybind RightCtrl
	UIS.InputBegan:Connect(function(inp, gp)
		if gp then
			return
		end
		if inp.KeyCode == Enum.KeyCode.RightControl then
			gui.Enabled = not gui.Enabled
		end
	end)

	-- manual drag on titlebar only — Draggable=true on main would steal slider drags
	do
		local dragging = false
		local dragStart, startPos

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
				local delta = inp.Position - dragStart
				main.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	end

	---------------------------------------------------------------------------
	-- SIDEBAR  (z=2) — NO UIListLayout; tab buttons positioned manually
	---------------------------------------------------------------------------
	local sidebar = Instance.new("Frame", main)
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, SW, 0, CH)
	sidebar.Position = UDim2.new(0, 0, 0, TH)
	sidebar.BackgroundColor3 = C.Surface
	sidebar.BorderSizePixel = 0
	sidebar.ZIndex = 2
	sidebar.ClipsDescendants = true

	local sdiv = Instance.new("Frame", sidebar)
	sdiv.Size = UDim2.new(0, 1, 0, CH)
	sdiv.Position = UDim2.new(0, SW - 1, 0, 0)
	sdiv.BackgroundColor3 = C.Border
	sdiv.BorderSizePixel = 0
	sdiv.ZIndex = 3

	---------------------------------------------------------------------------
	-- CONTENT AREA  (z=2)
	---------------------------------------------------------------------------
	local contentArea = Instance.new("Frame", main)
	contentArea.Name = "Content"
	contentArea.Size = UDim2.new(0, CW, 0, CH)
	contentArea.Position = UDim2.new(0, SW, 0, TH)
	contentArea.BackgroundTransparency = 1
	contentArea.BorderSizePixel = 0
	contentArea.ClipsDescendants = true
	contentArea.ZIndex = 2

	---------------------------------------------------------------------------
	-- STATUS BAR  (z=2)
	---------------------------------------------------------------------------
	local sb = Instance.new("Frame", main)
	sb.Size = UDim2.new(0, W, 0, SBH)
	sb.Position = UDim2.new(0, 0, 0, H - SBH)
	sb.BackgroundColor3 = C.Surface
	sb.BorderSizePixel = 0
	sb.ZIndex = 2

	local sbl = Instance.new("Frame", sb)
	sbl.Size = UDim2.new(0, W, 0, 1)
	sbl.BackgroundColor3 = C.Border
	sbl.BorderSizePixel = 0
	sbl.ZIndex = 3

	local sbDot = Instance.new("Frame", sb)
	sbDot.Size = UDim2.new(0, 7, 0, 7)
	sbDot.Position = UDim2.new(0, 10, 0, 7)
	sbDot.BackgroundColor3 = C.Green
	sbDot.BorderSizePixel = 0
	sbDot.ZIndex = 3
	rnd(sbDot, 99)

	local sbTxt = Instance.new("TextLabel", sb)
	sbTxt.Size = UDim2.new(0, 280, 0, SBH)
	sbTxt.Position = UDim2.new(0, 22, 0, 0)
	sbTxt.BackgroundTransparency = 1
	sbTxt.Text = "Ready"
	sbTxt.TextColor3 = C.Text
	sbTxt.Font = Enum.Font.Gotham
	sbTxt.TextSize = 11
	sbTxt.TextXAlignment = Enum.TextXAlignment.Left
	sbTxt.TextYAlignment = Enum.TextYAlignment.Center
	sbTxt.ZIndex = 3

	local sbVer = Instance.new("TextLabel", sb)
	sbVer.Size = UDim2.new(0, 90, 0, SBH)
	sbVer.Position = UDim2.new(0, W - 96, 0, 0)
	sbVer.BackgroundTransparency = 1
	sbVer.Text = subtitle or "v1.0.0"
	sbVer.TextColor3 = C.Muted
	sbVer.Font = Enum.Font.Gotham
	sbVer.TextSize = 10
	sbVer.TextXAlignment = Enum.TextXAlignment.Right
	sbVer.TextYAlignment = Enum.TextYAlignment.Center
	sbVer.ZIndex = 3

	---------------------------------------------------------------------------
	-- WINDOW OBJECT
	---------------------------------------------------------------------------
	local window = {}
	local pages = {}
	local tabBtns = {}
	local tabCount = 0
	local TAB_H = 28
	local TAB_PAD_TOP = 8
	local TAB_GAP = 2

	function window:SetStatus(text, kind)
		sbTxt.Text = text or "Ready"
		local col = ({ ok = C.Green, running = C.Amber, error = C.Danger, idle = C.Border })[kind or "ok"] or C.Green
		tw(sbDot, { BackgroundColor3 = col }, 0.2)
	end

	---------------------------------------------------------------------------
	-- CREATE TAB
	---------------------------------------------------------------------------
	function window:CreateTab(name)
		tabCount = tabCount + 1
		local idx = tabCount
		local isFirst = (idx == 1)

		-- tab button — positioned manually, no UIListLayout
		local yPos = TAB_PAD_TOP + (idx - 1) * (TAB_H + TAB_GAP)

		local btn = Instance.new("TextButton", sidebar)
		btn.Size = UDim2.new(0, SW - 12, 0, TAB_H)
		btn.Position = UDim2.new(0, 6, 0, yPos)
		btn.BackgroundColor3 = isFirst and C.White or C.Surface
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 4
		rnd(btn, 6)

		local bar = Instance.new("Frame", btn)
		bar.Size = UDim2.new(0, 3, 0, TAB_H - 8)
		bar.Position = UDim2.new(0, 0, 0, 4)
		bar.BackgroundColor3 = C.Accent
		bar.BorderSizePixel = 0
		bar.ZIndex = 5
		bar.Visible = isFirst

		local btnLbl = Instance.new("TextLabel", btn)
		btnLbl.Size = UDim2.new(0, SW - 22, 0, TAB_H)
		btnLbl.Position = UDim2.new(0, 10, 0, 0)
		btnLbl.BackgroundTransparency = 1
		btnLbl.Text = name
		btnLbl.TextColor3 = isFirst and C.Text or C.Muted
		btnLbl.Font = isFirst and Enum.Font.GothamSemibold or Enum.Font.Gotham
		btnLbl.TextSize = 12
		btnLbl.TextXAlignment = Enum.TextXAlignment.Left
		btnLbl.TextYAlignment = Enum.TextYAlignment.Center
		btnLbl.ZIndex = 5

		-- page
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

		------------------------------------------------------------------------
		-- CREATE SECTION
		------------------------------------------------------------------------
		local tab = {}
		local SEC_W = CW - 20 -- section width inside page (minus left+right padding)

		function tab:CreateSection(secName)
			local section = Instance.new("Frame", page)
			section.Size = UDim2.new(0, SEC_W, 0, 0)
			section.AutomaticSize = Enum.AutomaticSize.Y
			section.BackgroundColor3 = C.White
			section.BorderSizePixel = 0
			section.ZIndex = 4
			rnd(section, 8)
			bdr(section, C.Panel, 1)

			-- header
			local hdr = Instance.new("Frame", section)
			hdr.Size = UDim2.new(0, SEC_W, 0, 26)
			hdr.BackgroundColor3 = C.Surface
			hdr.BorderSizePixel = 0
			hdr.ZIndex = 5
			rnd(hdr, 8)

			-- square off bottom corners of header
			local sq = Instance.new("Frame", hdr)
			sq.Size = UDim2.new(0, SEC_W, 0, 8)
			sq.Position = UDim2.new(0, 0, 0, 18)
			sq.BackgroundColor3 = C.Surface
			sq.BorderSizePixel = 0
			sq.ZIndex = 5

			local hl = Instance.new("Frame", hdr)
			hl.Size = UDim2.new(0, SEC_W, 0, 1)
			hl.Position = UDim2.new(0, 0, 0, 25)
			hl.BackgroundColor3 = C.Panel
			hl.BorderSizePixel = 0
			hl.ZIndex = 6

			local ad = Instance.new("Frame", hdr)
			ad.Size = UDim2.new(0, 4, 0, 4)
			ad.Position = UDim2.new(0, 9, 0, 11)
			ad.BackgroundColor3 = C.Accent
			ad.BorderSizePixel = 0
			ad.ZIndex = 6
			rnd(ad, 99)

			local st = Instance.new("TextLabel", hdr)
			st.Size = UDim2.new(0, SEC_W - 24, 0, 26)
			st.Position = UDim2.new(0, 18, 0, 0)
			st.BackgroundTransparency = 1
			st.Text = secName
			st.TextColor3 = C.Muted
			st.Font = Enum.Font.GothamSemibold
			st.TextSize = 10
			st.TextXAlignment = Enum.TextXAlignment.Left
			st.TextYAlignment = Enum.TextYAlignment.Center
			st.ZIndex = 6

			-- rows holder
			local holder = Instance.new("Frame", section)
			holder.Size = UDim2.new(0, SEC_W, 0, 0)
			holder.Position = UDim2.new(0, 0, 0, 26)
			holder.AutomaticSize = Enum.AutomaticSize.Y
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = 4

			local hl2 = Instance.new("UIListLayout", holder)
			hl2.Padding = UDim.new(0, 0)
			hl2.SortOrder = Enum.SortOrder.LayoutOrder

			local hp = Instance.new("UIPadding", holder)
			hp.PaddingBottom = UDim.new(0, 6)

			local api = {}
			local RW = SEC_W -- row width

			-- ROW FACTORY
			local function row(h)
				local r = Instance.new("Frame", holder)
				r.Size = UDim2.new(0, RW, 0, h)
				r.BackgroundColor3 = C.White
				r.BorderSizePixel = 0
				r.ZIndex = 5
				r.ClipsDescendants = false

				local dv = Instance.new("Frame", r)
				dv.Size = UDim2.new(0, RW - 20, 0, 1)
				dv.Position = UDim2.new(0, 10, 0, h - 1)
				dv.BackgroundColor3 = C.Panel
				dv.BorderSizePixel = 0
				dv.ZIndex = 5

				r.MouseEnter:Connect(function()
					tw(r, { BackgroundColor3 = C.Base }, 0.08)
				end)
				r.MouseLeave:Connect(function()
					tw(r, { BackgroundColor3 = C.White }, 0.08)
				end)
				return r
			end

			----------------------------------------------------------------------
			-- TOGGLE
			----------------------------------------------------------------------
			function api:CreateToggle(opts)
				local hasDesc = opts.Description ~= nil and opts.Description ~= ""
				local rh = hasDesc and 40 or 32
				local r = row(rh)
				local state = opts.CurrentValue or false

				-- name label — pixel positioned, no relative scale
				local nl = Instance.new("TextLabel", r)
				nl.Size = UDim2.new(0, RW - 60, 0, 16)
				nl.Position = UDim2.new(0, 12, 0, hasDesc and 5 or 8)
				nl.BackgroundTransparency = 1
				nl.Text = opts.Name
				nl.TextColor3 = C.Text
				nl.Font = Enum.Font.Gotham
				nl.TextSize = 12
				nl.TextXAlignment = Enum.TextXAlignment.Left
				nl.TextYAlignment = Enum.TextYAlignment.Center
				nl.ZIndex = 6

				if hasDesc then
					local dl = Instance.new("TextLabel", r)
					dl.Size = UDim2.new(0, RW - 60, 0, 13)
					dl.Position = UDim2.new(0, 12, 0, 22)
					dl.BackgroundTransparency = 1
					dl.Text = opts.Description
					dl.TextColor3 = C.Muted
					dl.Font = Enum.Font.Gotham
					dl.TextSize = 10
					dl.TextXAlignment = Enum.TextXAlignment.Left
					dl.TextYAlignment = Enum.TextYAlignment.Top
					dl.ZIndex = 6
				end

				-- pill
				local pill = Instance.new("Frame", r)
				pill.Size = UDim2.new(0, 34, 0, 18)
				pill.Position = UDim2.new(0, RW - 44, 0, math.floor((rh - 18) / 2))
				pill.BackgroundColor3 = state and C.Accent or C.Panel
				pill.BorderSizePixel = 0
				pill.ZIndex = 6
				rnd(pill, 99)

				local thumb = Instance.new("Frame", pill)
				thumb.Size = UDim2.new(0, 12, 0, 12)
				thumb.Position = state and UDim2.new(0, 19, 0, 3) or UDim2.new(0, 3, 0, 3)
				thumb.BackgroundColor3 = C.White
				thumb.BorderSizePixel = 0
				thumb.ZIndex = 7
				rnd(thumb, 99)
				bdr(thumb, C.Border, 1)

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
				}
			end

			----------------------------------------------------------------------
			-- SLIDER
			----------------------------------------------------------------------
			function api:CreateSlider(opts)
				local r = row(44)

				local nl = Instance.new("TextLabel", r)
				nl.Size = UDim2.new(0, RW - 20, 0, 16)
				nl.Position = UDim2.new(0, 12, 0, 4)
				nl.BackgroundTransparency = 1
				nl.Text = opts.Name .. ": " .. (opts.CurrentValue or opts.Min)
				nl.TextColor3 = C.Text
				nl.Font = Enum.Font.Gotham
				nl.TextSize = 12
				nl.TextXAlignment = Enum.TextXAlignment.Left
				nl.TextYAlignment = Enum.TextYAlignment.Center
				nl.ZIndex = 6

				local track = Instance.new("Frame", r)
				track.Size = UDim2.new(0, RW - 24, 0, 5)
				track.Position = UDim2.new(0, 12, 0, 27)
				track.BackgroundColor3 = C.Panel
				track.BorderSizePixel = 0
				track.ZIndex = 6
				rnd(track, 99)

				local fill = Instance.new("Frame", track)
				fill.Size = UDim2.new(0, 0, 1, 0)
				fill.BackgroundColor3 = C.Accent
				fill.BorderSizePixel = 0
				fill.ZIndex = 7
				rnd(fill, 99)

				local handle = Instance.new("Frame", track)
				handle.Size = UDim2.new(0, 13, 0, 13)
				handle.AnchorPoint = Vector2.new(0.5, 0.5)
				handle.Position = UDim2.new(0, 0, 0.5, 0)
				handle.BackgroundColor3 = C.White
				handle.BorderSizePixel = 0
				handle.ZIndex = 8
				rnd(handle, 99)
				bdr(handle, C.Accent, 2)

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

			----------------------------------------------------------------------
			-- DROPDOWN
			-- List is parented to `gui` root and positioned via AbsolutePosition
			----------------------------------------------------------------------
			function api:CreateDropdown(opts)
				local r = row(34)

				local nl = Instance.new("TextLabel", r)
				nl.Size = UDim2.new(0, RW / 2 - 20, 0, 34)
				nl.Position = UDim2.new(0, 12, 0, 0)
				nl.BackgroundTransparency = 1
				nl.Text = opts.Name
				nl.TextColor3 = C.Text
				nl.Font = Enum.Font.Gotham
				nl.TextSize = 12
				nl.TextXAlignment = Enum.TextXAlignment.Left
				nl.TextYAlignment = Enum.TextYAlignment.Center
				nl.ZIndex = 6

				local selBtn = Instance.new("TextButton", r)
				local selW = math.floor(RW / 2) - 8
				selBtn.Size = UDim2.new(0, selW, 0, 22)
				selBtn.Position = UDim2.new(0, RW - selW - 10, 0, 6)
				selBtn.BackgroundColor3 = C.Base
				selBtn.BorderSizePixel = 0
				selBtn.Text = ""
				selBtn.AutoButtonColor = false
				selBtn.ZIndex = 6
				rnd(selBtn, 5)
				bdr(selBtn, C.Border, 1)

				local selected = opts.Default or opts.Options[1]
				UI.Flags[opts.Flag] = selected

				local selLbl = Instance.new("TextLabel", selBtn)
				selLbl.Size = UDim2.new(0, selW - 20, 0, 22)
				selLbl.Position = UDim2.new(0, 8, 0, 0)
				selLbl.BackgroundTransparency = 1
				selLbl.Text = selected
				selLbl.TextColor3 = C.Text
				selLbl.Font = Enum.Font.Gotham
				selLbl.TextSize = 11
				selLbl.TextXAlignment = Enum.TextXAlignment.Left
				selLbl.TextYAlignment = Enum.TextYAlignment.Center
				selLbl.ZIndex = 7

				local chev = Instance.new("TextLabel", selBtn)
				chev.Size = UDim2.new(0, 16, 0, 22)
				chev.Position = UDim2.new(0, selW - 18, 0, 0)
				chev.BackgroundTransparency = 1
				chev.Text = "v"
				chev.TextColor3 = C.Muted
				chev.Font = Enum.Font.GothamBold
				chev.TextSize = 10
				chev.TextXAlignment = Enum.TextXAlignment.Center
				chev.ZIndex = 7

				-- floating list parented to gui root
				local OPH = 26
				local listH = math.min(#opts.Options * OPH, 130)

				local list = Instance.new("Frame", gui)
				list.Size = UDim2.new(0, selW, 0, 0)
				list.BackgroundColor3 = C.White
				list.BorderSizePixel = 0
				list.ZIndex = 60
				list.Visible = false
				list.ClipsDescendants = true
				rnd(list, 5)
				bdr(list, C.Border, 1)

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
					ob.BackgroundColor3 = C.White
					ob.BorderSizePixel = 0
					ob.Text = ""
					ob.AutoButtonColor = false
					ob.ZIndex = 61

					local ol = Instance.new("TextLabel", ob)
					ol.Size = UDim2.new(0, selW - 10, 0, OPH)
					ol.Position = UDim2.new(0, 10, 0, 0)
					ol.BackgroundTransparency = 1
					ol.Text = opt
					ol.TextColor3 = opt == selected and C.Accent or C.Text
					ol.Font = Enum.Font.Gotham
					ol.TextSize = 11
					ol.TextXAlignment = Enum.TextXAlignment.Left
					ol.TextYAlignment = Enum.TextYAlignment.Center
					ol.ZIndex = 62

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

			----------------------------------------------------------------------
			-- BUTTON
			----------------------------------------------------------------------
			function api:CreateButton(opts)
				local r = row(36)
				local accent = opts.Style == "accent"

				local btn = Instance.new("TextButton", r)
				btn.Size = UDim2.new(0, RW - 24, 0, 24)
				btn.Position = UDim2.new(0, 12, 0, 6)
				btn.BackgroundColor3 = accent and C.Accent or C.Dark
				btn.BorderSizePixel = 0
				btn.Text = opts.Name
				btn.TextColor3 = C.White
				btn.Font = Enum.Font.GothamSemibold
				btn.TextSize = 12
				btn.AutoButtonColor = false
				btn.ZIndex = 6
				rnd(btn, 6)

				local base = accent and C.Accent or C.Dark
				btn.MouseEnter:Connect(function()
					tw(btn, { BackgroundColor3 = base:Lerp(Color3.new(0, 0, 0), 0.15) }, 0.1)
				end)
				btn.MouseLeave:Connect(function()
					tw(btn, { BackgroundColor3 = base }, 0.1)
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

			----------------------------------------------------------------------
			-- INPUT
			----------------------------------------------------------------------
			function api:CreateInput(opts)
				local r = row(34)

				local nl = Instance.new("TextLabel", r)
				nl.Size = UDim2.new(0, RW / 2 - 20, 0, 34)
				nl.Position = UDim2.new(0, 12, 0, 0)
				nl.BackgroundTransparency = 1
				nl.Text = opts.Name
				nl.TextColor3 = C.Text
				nl.Font = Enum.Font.Gotham
				nl.TextSize = 12
				nl.TextXAlignment = Enum.TextXAlignment.Left
				nl.TextYAlignment = Enum.TextYAlignment.Center
				nl.ZIndex = 6

				local bxW = math.floor(RW / 2) - 8
				local bx = Instance.new("TextBox", r)
				bx.Size = UDim2.new(0, bxW, 0, 22)
				bx.Position = UDim2.new(0, RW - bxW - 10, 0, 6)
				bx.BackgroundColor3 = C.Base
				bx.BorderSizePixel = 0
				bx.Text = opts.Default or ""
				bx.PlaceholderText = opts.Placeholder or "Type here..."
				bx.TextColor3 = C.Text
				bx.PlaceholderColor3 = C.Muted
				bx.Font = Enum.Font.Gotham
				bx.TextSize = 11
				bx.ClearTextOnFocus = opts.ClearOnFocus ~= false
				bx.ZIndex = 6
				rnd(bx, 5)
				local bs = bdr(bx, C.Border, 1)

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

			----------------------------------------------------------------------
			-- LABEL
			----------------------------------------------------------------------
			function api:CreateLabel(text)
				local r = row(26)
				local nl = Instance.new("TextLabel", r)
				nl.Size = UDim2.new(0, RW - 24, 0, 26)
				nl.Position = UDim2.new(0, 12, 0, 0)
				nl.BackgroundTransparency = 1
				nl.Text = text
				nl.TextColor3 = C.Muted
				nl.Font = Enum.Font.Gotham
				nl.TextSize = 11
				nl.TextXAlignment = Enum.TextXAlignment.Left
				nl.TextYAlignment = Enum.TextYAlignment.Center
				nl.ZIndex = 6
			end

			return api
		end -- CreateSection

		return tab
	end -- CreateTab

	return window
end -- CreateWindow

return UI
