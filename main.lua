local UI = {}
UI.Flags = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- ─── PALETTE ─────────────────────────────────────────────────────────────────
local C = {
	Base = Color3.fromRGB(245, 245, 245),
	Surface = Color3.fromRGB(236, 236, 236),
	Panel = Color3.fromRGB(224, 224, 224),
	Border = Color3.fromRGB(200, 200, 200),
	Dark = Color3.fromRGB(58, 58, 58),
	Accent = Color3.fromRGB(92, 107, 192),
	AccentHover = Color3.fromRGB(57, 73, 171),
	Danger = Color3.fromRGB(239, 83, 80),
	Text = Color3.fromRGB(26, 26, 26),
	TextMuted = Color3.fromRGB(120, 120, 120),
	White = Color3.fromRGB(255, 255, 255),
	TagPro = Color3.fromRGB(232, 233, 245),
	TagProText = Color3.fromRGB(57, 73, 171),
	Green = Color3.fromRGB(99, 153, 34),
	Amber = Color3.fromRGB(186, 117, 23),
}

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
end

local function corner(obj, r)
	local c = Instance.new("UICorner", obj)
	c.CornerRadius = UDim.new(0, r or 6)
	return c
end

local function stroke(obj, color, thick)
	local s = Instance.new("UIStroke", obj)
	s.Color = color or C.Border
	s.Thickness = thick or 1
	return s
end

local function newLabel(parent, text, size, pos, color, xAlign, fontSize)
	local l = Instance.new("TextLabel", parent)
	l.Size = size
	l.Position = pos or UDim2.new(0, 0, 0, 0)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = color or C.Text
	l.Font = Enum.Font.Gotham
	l.TextSize = fontSize or 12
	l.TextXAlignment = xAlign or Enum.TextXAlignment.Left
	l.TextYAlignment = Enum.TextYAlignment.Center
	return l
end

-- ─── NOTIFY ──────────────────────────────────────────────────────────────────
function UI:Notify(text, duration, kind)
	duration = duration or 3
	kind = kind or "info"

	local gui = game.CoreGui:FindFirstChild("FlatGrayUI")
	if not gui then
		return
	end

	local bgMap = {
		info = Color3.fromRGB(240, 244, 255),
		success = Color3.fromRGB(234, 243, 222),
		warn = Color3.fromRGB(250, 238, 218),
		error = Color3.fromRGB(252, 235, 235),
	}
	local tcMap = {
		info = C.AccentHover,
		success = Color3.fromRGB(59, 109, 17),
		warn = Color3.fromRGB(133, 79, 11),
		error = Color3.fromRGB(163, 45, 45),
	}
	local bg = bgMap[kind] or C.Surface
	local tc = tcMap[kind] or C.Text

	local notif = Instance.new("Frame", gui)
	notif.Size = UDim2.new(0, 220, 0, 44)
	notif.Position = UDim2.new(1, -240, 1, 10)
	notif.BackgroundColor3 = bg
	notif.BorderSizePixel = 0
	notif.ZIndex = 100
	corner(notif, 8)
	stroke(notif, C.Border, 1)

	local bar = Instance.new("Frame", notif)
	bar.Size = UDim2.new(0, 4, 1, -16)
	bar.Position = UDim2.new(0, 8, 0, 8)
	bar.BackgroundColor3 = tc
	bar.BorderSizePixel = 0
	corner(bar, 2)

	local lbl = Instance.new("TextLabel", notif)
	lbl.Size = UDim2.new(1, -24, 1, 0)
	lbl.Position = UDim2.new(0, 20, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = tc
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextWrapped = true

	tween(notif, { Position = UDim2.new(1, -240, 1, -60) }, 0.25)
	task.delay(duration, function()
		tween(notif, { Position = UDim2.new(1, -240, 1, 10) }, 0.25)
		task.wait(0.3)
		notif:Destroy()
	end)
end

-- ─── CONFIG ──────────────────────────────────────────────────────────────────
function UI:SaveConfig(name)
	writefile(name .. ".json", HttpService:JSONEncode(UI.Flags))
end

function UI:LoadConfig(name)
	if isfile(name .. ".json") then
		local data = HttpService:JSONDecode(readfile(name .. ".json"))
		for k, v in pairs(data) do
			UI.Flags[k] = v
		end
	end
end

-- ─── CREATE WINDOW ───────────────────────────────────────────────────────────
function UI:CreateWindow(title, subtitle)
	if game.CoreGui:FindFirstChild("FlatGrayUI") then
		game.CoreGui.FlatGrayUI:Destroy()
	end

	-- layout constants
	local W = 480
	local H = 320
	local TH = 36 -- titlebar height
	local SW = 110 -- sidebar width
	local SBH = 22 -- statusbar height

	local gui = Instance.new("ScreenGui")
	gui.Name = "FlatGrayUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.Parent = game.CoreGui

	-- ── MAIN ────────────────────────────────────────────────────────────────
	local main = Instance.new("Frame", gui)
	main.Name = "Main"
	main.Size = UDim2.new(0, W, 0, H)
	main.Position = UDim2.new(0.5, -W / 2, 0.5, -H / 2)
	main.BackgroundColor3 = C.Base
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = true
	main.ClipsDescendants = true
	corner(main, 10)
	stroke(main, C.Border, 1)

	main.Size = UDim2.new(0, W, 0, 0)
	tween(main, { Size = UDim2.new(0, W, 0, H) }, 0.2)

	-- ── TITLEBAR ────────────────────────────────────────────────────────────
	local titlebar = Instance.new("Frame", main)
	titlebar.Name = "TitleBar"
	titlebar.Size = UDim2.new(1, 0, 0, TH)
	titlebar.Position = UDim2.new(0, 0, 0, 0)
	titlebar.BackgroundColor3 = C.Surface
	titlebar.BorderSizePixel = 0
	titlebar.ZIndex = 5

	local tbLine = Instance.new("Frame", titlebar)
	tbLine.Size = UDim2.new(1, 0, 0, 1)
	tbLine.Position = UDim2.new(0, 0, 1, -1)
	tbLine.BackgroundColor3 = C.Border
	tbLine.BorderSizePixel = 0

	-- icon circle
	local iconFrame = Instance.new("Frame", titlebar)
	iconFrame.Size = UDim2.new(0, 20, 0, 20)
	iconFrame.Position = UDim2.new(0, 10, 0.5, -10)
	iconFrame.BackgroundColor3 = C.Accent
	iconFrame.BorderSizePixel = 0
	iconFrame.ZIndex = 6
	corner(iconFrame, 10)

	local iconLbl = Instance.new("TextLabel", iconFrame)
	iconLbl.Size = UDim2.new(1, 0, 1, 0)
	iconLbl.BackgroundTransparency = 1
	iconLbl.Text = string.upper(string.sub(title, 1, 1))
	iconLbl.TextColor3 = C.White
	iconLbl.Font = Enum.Font.GothamBold
	iconLbl.TextSize = 11
	iconLbl.TextXAlignment = Enum.TextXAlignment.Center
	iconLbl.ZIndex = 7

	-- title text
	local titleLbl = Instance.new("TextLabel", titlebar)
	titleLbl.Size = UDim2.new(0, 110, 1, 0)
	titleLbl.Position = UDim2.new(0, 36, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextColor3 = C.Text
	titleLbl.Font = Enum.Font.GothamSemibold
	titleLbl.TextSize = 13
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.TextYAlignment = Enum.TextYAlignment.Center
	titleLbl.ZIndex = 6

	-- subtitle badge
	if subtitle then
		local badge = Instance.new("Frame", titlebar)
		badge.Size = UDim2.new(0, 44, 0, 18)
		badge.Position = UDim2.new(0, 152, 0.5, -9)
		badge.BackgroundColor3 = C.TagPro
		badge.BorderSizePixel = 0
		badge.ZIndex = 6
		corner(badge, 99)

		local badgeLbl = Instance.new("TextLabel", badge)
		badgeLbl.Size = UDim2.new(1, 0, 1, 0)
		badgeLbl.BackgroundTransparency = 1
		badgeLbl.Text = subtitle
		badgeLbl.TextColor3 = C.TagProText
		badgeLbl.Font = Enum.Font.GothamSemibold
		badgeLbl.TextSize = 10
		badgeLbl.TextXAlignment = Enum.TextXAlignment.Center
		badgeLbl.ZIndex = 7
	end

	-- ── WINDOW CONTROL DOTS ─────────────────────────────────────────────────
	-- FIX: use pixel offset from right, no scale math that breaks
	local dotColors = { C.Danger, Color3.fromRGB(200, 200, 200), Color3.fromRGB(220, 220, 220) }
	local dotOffsets = { -16, -34, -52 } -- right offsets for close, minimize, help
	local dots = {}

	for i, offset in ipairs(dotOffsets) do
		local dot = Instance.new("TextButton", titlebar)
		dot.Size = UDim2.new(0, 12, 0, 12)
		dot.Position = UDim2.new(1, offset, 0.5, -6)
		dot.BackgroundColor3 = dotColors[i]
		dot.BorderSizePixel = 0
		dot.Text = ""
		dot.AutoButtonColor = false
		dot.ZIndex = 6
		corner(dot, 99)

		local base = dotColors[i]
		dot.MouseEnter:Connect(function()
			tween(dot, { BackgroundColor3 = base:Lerp(Color3.new(0, 0, 0), 0.2) }, 0.1)
		end)
		dot.MouseLeave:Connect(function()
			tween(dot, { BackgroundColor3 = base }, 0.1)
		end)

		dots[i] = dot
	end

	local closeBtn = dots[1]
	local minimizeBtn = dots[2]

	-- close
	closeBtn.MouseButton1Click:Connect(function()
		tween(main, { Size = UDim2.new(0, W, 0, 0) }, 0.18)
		task.wait(0.2)
		gui:Destroy()
	end)

	-- minimize / restore
	local minimized = false
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		tween(main, { Size = minimized and UDim2.new(0, W, 0, TH) or UDim2.new(0, W, 0, H) }, 0.2)
	end)

	-- keybind
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == Enum.KeyCode.RightControl then
			gui.Enabled = not gui.Enabled
		end
	end)

	-- ── SIDEBAR ─────────────────────────────────────────────────────────────
	-- FIX: explicit pixel size/position — NOT relative to window using scale.
	--      A UIListLayout inside sidebar handles only the tab buttons (vertical stacking).
	local sidebar = Instance.new("Frame", main)
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, SW, 0, H - TH - SBH)
	sidebar.Position = UDim2.new(0, 0, 0, TH)
	sidebar.BackgroundColor3 = C.Surface
	sidebar.BorderSizePixel = 0
	sidebar.ZIndex = 2

	local sideDiv = Instance.new("Frame", sidebar)
	sideDiv.Size = UDim2.new(0, 1, 1, 0)
	sideDiv.Position = UDim2.new(1, -1, 0, 0)
	sideDiv.BackgroundColor3 = C.Border
	sideDiv.BorderSizePixel = 0

	-- UIListLayout ONLY for the tab buttons inside sidebar
	local tabBtnList = Instance.new("UIListLayout", sidebar)
	tabBtnList.Padding = UDim.new(0, 2)
	tabBtnList.FillDirection = Enum.FillDirection.Vertical
	tabBtnList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabBtnList.SortOrder = Enum.SortOrder.LayoutOrder

	local tabBtnPad = Instance.new("UIPadding", sidebar)
	tabBtnPad.PaddingTop = UDim.new(0, 8)
	tabBtnPad.PaddingLeft = UDim.new(0, 6)
	tabBtnPad.PaddingRight = UDim.new(0, 6)

	-- ── CONTENT AREA ────────────────────────────────────────────────────────
	-- FIX: explicit pixel position starting after sidebar, no overlap
	local content = Instance.new("Frame", main)
	content.Name = "Content"
	content.Size = UDim2.new(0, W - SW, 0, H - TH - SBH)
	content.Position = UDim2.new(0, SW, 0, TH)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ClipsDescendants = true
	content.ZIndex = 2

	-- ── STATUS BAR ──────────────────────────────────────────────────────────
	local statusBar = Instance.new("Frame", main)
	statusBar.Name = "StatusBar"
	statusBar.Size = UDim2.new(1, 0, 0, SBH)
	statusBar.Position = UDim2.new(0, 0, 0, H - SBH)
	statusBar.BackgroundColor3 = C.Surface
	statusBar.BorderSizePixel = 0
	statusBar.ZIndex = 3

	local sbLine = Instance.new("Frame", statusBar)
	sbLine.Size = UDim2.new(1, 0, 0, 1)
	sbLine.BackgroundColor3 = C.Border
	sbLine.BorderSizePixel = 0

	local sbDot = Instance.new("Frame", statusBar)
	sbDot.Size = UDim2.new(0, 7, 0, 7)
	sbDot.Position = UDim2.new(0, 10, 0.5, -3)
	sbDot.BackgroundColor3 = C.Green
	sbDot.BorderSizePixel = 0
	corner(sbDot, 99)

	local sbText = Instance.new("TextLabel", statusBar)
	sbText.Size = UDim2.new(1, -130, 1, 0)
	sbText.Position = UDim2.new(0, 22, 0, 0)
	sbText.BackgroundTransparency = 1
	sbText.Text = "Ready"
	sbText.TextColor3 = C.Text
	sbText.Font = Enum.Font.Gotham
	sbText.TextSize = 11
	sbText.TextXAlignment = Enum.TextXAlignment.Left

	local sbVer = Instance.new("TextLabel", statusBar)
	sbVer.Size = UDim2.new(0, 80, 1, 0)
	sbVer.Position = UDim2.new(1, -86, 0, 0)
	sbVer.BackgroundTransparency = 1
	sbVer.Text = subtitle or "v1.0.0"
	sbVer.TextColor3 = C.TextMuted
	sbVer.Font = Enum.Font.Gotham
	sbVer.TextSize = 10
	sbVer.TextXAlignment = Enum.TextXAlignment.Right

	-- ── WINDOW API ───────────────────────────────────────────────────────────
	local window = {}
	local allPages = {}
	local allTabs = {}
	local firstTab = true

	function window:SetStatus(text, kind)
		sbText.Text = text or "Ready"
		local c = ({ ok = C.Green, running = C.Amber, error = C.Danger, idle = C.Border })[kind or "ok"] or C.Green
		tween(sbDot, { BackgroundColor3 = c }, 0.2)
	end

	-- ── CREATE TAB ──────────────────────────────────────────────────────────
	function window:CreateTab(name)
		local isFirst = firstTab
		firstTab = false

		-- tab button in sidebar
		local tabBtn = Instance.new("TextButton", sidebar)
		tabBtn.Size = UDim2.new(1, 0, 0, 28)
		tabBtn.BackgroundColor3 = isFirst and C.White or C.Surface
		tabBtn.BorderSizePixel = 0
		tabBtn.Text = ""
		tabBtn.AutoButtonColor = false
		tabBtn.ZIndex = 3
		corner(tabBtn, 6)

		local accentBar = Instance.new("Frame", tabBtn)
		accentBar.Size = UDim2.new(0, 3, 1, -8)
		accentBar.Position = UDim2.new(0, 0, 0.5, -10)
		accentBar.BackgroundColor3 = C.Accent
		accentBar.BorderSizePixel = 0
		accentBar.Visible = isFirst
		accentBar.ZIndex = 4

		local tabLbl = Instance.new("TextLabel", tabBtn)
		tabLbl.Size = UDim2.new(1, -10, 1, 0)
		tabLbl.Position = UDim2.new(0, 10, 0, 0)
		tabLbl.BackgroundTransparency = 1
		tabLbl.Text = name
		tabLbl.TextColor3 = isFirst and C.Text or C.TextMuted
		tabLbl.Font = isFirst and Enum.Font.GothamSemibold or Enum.Font.Gotham
		tabLbl.TextSize = 12
		tabLbl.TextXAlignment = Enum.TextXAlignment.Left
		tabLbl.TextYAlignment = Enum.TextYAlignment.Center
		tabLbl.ZIndex = 4

		-- page in content
		local page = Instance.new("ScrollingFrame", content)
		page.Size = UDim2.new(1, 0, 1, 0)
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = 3
		page.ScrollBarImageColor3 = C.Border
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.Visible = isFirst
		page.ZIndex = 2

		local pageLayout = Instance.new("UIListLayout", page)
		pageLayout.Padding = UDim.new(0, 6)
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local pagePad = Instance.new("UIPadding", page)
		pagePad.PaddingTop = UDim.new(0, 10)
		pagePad.PaddingLeft = UDim.new(0, 10)
		pagePad.PaddingRight = UDim.new(0, 10)
		pagePad.PaddingBottom = UDim.new(0, 10)

		table.insert(allPages, page)
		table.insert(allTabs, { btn = tabBtn, bar = accentBar, lbl = tabLbl })

		tabBtn.MouseButton1Click:Connect(function()
			for _, p in pairs(allPages) do
				p.Visible = false
			end
			for _, t in pairs(allTabs) do
				t.bar.Visible = false
				t.btn.BackgroundColor3 = C.Surface
				t.lbl.TextColor3 = C.TextMuted
				t.lbl.Font = Enum.Font.Gotham
			end
			page.Visible = true
			accentBar.Visible = true
			tabBtn.BackgroundColor3 = C.White
			tabLbl.TextColor3 = C.Text
			tabLbl.Font = Enum.Font.GothamSemibold
		end)

		tabBtn.MouseEnter:Connect(function()
			if not page.Visible then
				tween(tabBtn, { BackgroundColor3 = C.Panel }, 0.1)
			end
		end)
		tabBtn.MouseLeave:Connect(function()
			if not page.Visible then
				tween(tabBtn, { BackgroundColor3 = C.Surface }, 0.1)
			end
		end)

		-- ── SECTION ─────────────────────────────────────────────────────────
		local tab = {}

		function tab:CreateSection(sectionName)
			local section = Instance.new("Frame", page)
			section.Size = UDim2.new(1, 0, 0, 0)
			section.AutomaticSize = Enum.AutomaticSize.Y
			section.BackgroundColor3 = C.White
			section.BorderSizePixel = 0
			section.ZIndex = 3
			corner(section, 8)
			stroke(section, C.Panel, 1)

			-- section header
			local header = Instance.new("Frame", section)
			header.Size = UDim2.new(1, 0, 0, 26)
			header.BackgroundColor3 = C.Surface
			header.BorderSizePixel = 0
			header.ZIndex = 4
			corner(header, 8)

			local headerSquare = Instance.new("Frame", header)
			headerSquare.Size = UDim2.new(1, 0, 0, 8)
			headerSquare.Position = UDim2.new(0, 0, 1, -8)
			headerSquare.BackgroundColor3 = C.Surface
			headerSquare.BorderSizePixel = 0

			local headerLine = Instance.new("Frame", header)
			headerLine.Size = UDim2.new(1, 0, 0, 1)
			headerLine.Position = UDim2.new(0, 0, 1, -1)
			headerLine.BackgroundColor3 = C.Panel
			headerLine.BorderSizePixel = 0

			local accentDot = Instance.new("Frame", header)
			accentDot.Size = UDim2.new(0, 4, 0, 4)
			accentDot.Position = UDim2.new(0, 9, 0.5, -2)
			accentDot.BackgroundColor3 = C.Accent
			accentDot.BorderSizePixel = 0
			corner(accentDot, 99)

			local sTitle = Instance.new("TextLabel", header)
			sTitle.Size = UDim2.new(1, -20, 1, 0)
			sTitle.Position = UDim2.new(0, 18, 0, 0)
			sTitle.BackgroundTransparency = 1
			sTitle.Text = sectionName
			sTitle.TextColor3 = C.TextMuted
			sTitle.Font = Enum.Font.GothamSemibold
			sTitle.TextSize = 10
			sTitle.TextXAlignment = Enum.TextXAlignment.Left
			sTitle.ZIndex = 5

			-- rows container
			local holder = Instance.new("Frame", section)
			holder.Name = "Holder"
			holder.Size = UDim2.new(1, 0, 0, 0)
			holder.Position = UDim2.new(0, 0, 0, 26)
			holder.AutomaticSize = Enum.AutomaticSize.Y
			holder.BackgroundTransparency = 1
			holder.BorderSizePixel = 0
			holder.ZIndex = 3

			local holderLayout = Instance.new("UIListLayout", holder)
			holderLayout.Padding = UDim.new(0, 0)
			holderLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local holderPad = Instance.new("UIPadding", holder)
			holderPad.PaddingBottom = UDim.new(0, 6)

			-- ── ROW FACTORY ──────────────────────────────────────────────────
			local api = {}

			local function makeRow(h)
				local row = Instance.new("Frame", holder)
				row.Size = UDim2.new(1, 0, 0, h)
				row.BackgroundColor3 = C.White
				row.BorderSizePixel = 0
				row.ZIndex = 4

				local div = Instance.new("Frame", row)
				div.Size = UDim2.new(1, -20, 0, 1)
				div.Position = UDim2.new(0, 10, 1, -1)
				div.BackgroundColor3 = C.Panel
				div.BorderSizePixel = 0

				row.MouseEnter:Connect(function()
					tween(row, { BackgroundColor3 = C.Base }, 0.08)
				end)
				row.MouseLeave:Connect(function()
					tween(row, { BackgroundColor3 = C.White }, 0.08)
				end)

				return row
			end

			-- ── TOGGLE ───────────────────────────────────────────────────────
			function api:CreateToggle(opts)
				local rowH = opts.Description and 38 or 30
				local row = makeRow(rowH)
				local state = opts.CurrentValue or false

				newLabel(
					row,
					opts.Name,
					UDim2.new(1, -56, 0, 16),
					UDim2.new(0, 12, 0, opts.Description and 4 or 7),
					C.Text,
					Enum.TextXAlignment.Left,
					12
				)

				if opts.Description then
					local d = newLabel(
						row,
						opts.Description,
						UDim2.new(1, -56, 0, 13),
						UDim2.new(0, 12, 0, 21),
						C.TextMuted,
						Enum.TextXAlignment.Left,
						10
					)
					d.TextYAlignment = Enum.TextYAlignment.Top
				end

				local pill = Instance.new("Frame", row)
				pill.Size = UDim2.new(0, 34, 0, 18)
				pill.Position = UDim2.new(1, -44, 0.5, -9)
				pill.BackgroundColor3 = C.Panel
				pill.BorderSizePixel = 0
				pill.ZIndex = 5
				corner(pill, 99)

				local thumb = Instance.new("Frame", pill)
				thumb.Size = UDim2.new(0, 12, 0, 12)
				thumb.Position = UDim2.new(0, 3, 0.5, -6)
				thumb.BackgroundColor3 = C.White
				thumb.BorderSizePixel = 0
				thumb.ZIndex = 6
				corner(thumb, 99)
				stroke(thumb, C.Border, 1)

				local function updateToggle()
					UI.Flags[opts.Flag] = state
					tween(pill, { BackgroundColor3 = state and C.Accent or C.Panel }, 0.15)
					tween(thumb, {
						Position = state and UDim2.new(0, 19, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
					}, 0.15)
					if opts.Callback then
						opts.Callback(state)
					end
				end
				updateToggle()

				local hit = Instance.new("TextButton", row)
				hit.Size = UDim2.new(1, 0, 1, 0)
				hit.BackgroundTransparency = 1
				hit.Text = ""
				hit.ZIndex = 7
				hit.MouseButton1Click:Connect(function()
					state = not state
					updateToggle()
				end)

				return {
					SetValue = function(_, v)
						state = v
						updateToggle()
					end,
				}
			end

			-- ── SLIDER ───────────────────────────────────────────────────────
			function api:CreateSlider(opts)
				local row = makeRow(44)

				local nameLbl = newLabel(
					row,
					opts.Name .. ": " .. (opts.CurrentValue or opts.Min),
					UDim2.new(1, -20, 0, 16),
					UDim2.new(0, 12, 0, 4),
					C.Text,
					Enum.TextXAlignment.Left,
					12
				)

				local track = Instance.new("Frame", row)
				track.Size = UDim2.new(1, -24, 0, 5)
				track.Position = UDim2.new(0, 12, 0, 27)
				track.BackgroundColor3 = C.Panel
				track.BorderSizePixel = 0
				track.ZIndex = 5
				corner(track, 99)

				local fill = Instance.new("Frame", track)
				fill.Size = UDim2.new(0, 0, 1, 0)
				fill.BackgroundColor3 = C.Accent
				fill.BorderSizePixel = 0
				fill.ZIndex = 6
				corner(fill, 99)

				local handle = Instance.new("Frame", track)
				handle.Size = UDim2.new(0, 13, 0, 13)
				handle.AnchorPoint = Vector2.new(0.5, 0.5)
				handle.Position = UDim2.new(0, 0, 0.5, 0)
				handle.BackgroundColor3 = C.White
				handle.BorderSizePixel = 0
				handle.ZIndex = 7
				corner(handle, 99)
				stroke(handle, C.Accent, 2)

				local val = math.clamp(opts.CurrentValue or opts.Min, opts.Min, opts.Max)
				local dragging = false

				local function update(v)
					v = math.clamp(math.floor(v + 0.5), opts.Min, opts.Max)
					val = v
					local pct = (v - opts.Min) / (opts.Max - opts.Min)
					fill.Size = UDim2.new(pct, 0, 1, 0)
					handle.Position = UDim2.new(pct, 0, 0.5, 0)
					nameLbl.Text = opts.Name .. ": " .. v
					UI.Flags[opts.Flag] = v
					if opts.Callback then
						opts.Callback(v)
					end
				end
				update(val)

				local function xToVal(x)
					local pct = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					return opts.Min + (opts.Max - opts.Min) * pct
				end

				track.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						update(xToVal(i.Position.X))
					end
				end)
				UserInputService.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(i)
					if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
						update(xToVal(i.Position.X))
					end
				end)

				return {
					SetValue = function(_, v)
						update(v)
					end,
					GetValue = function(_)
						return val
					end,
				}
			end

			-- ── DROPDOWN ─────────────────────────────────────────────────────
			-- FIX: list frame parented directly to `gui` (ScreenGui) so it
			--      floats above all other frames at ZIndex 50, positioned via
			--      AbsolutePosition of the selector button each time it opens.
			function api:CreateDropdown(opts)
				local row = makeRow(34)

				newLabel(
					row,
					opts.Name,
					UDim2.new(0.45, -8, 0, 16),
					UDim2.new(0, 12, 0.5, -8),
					C.Text,
					Enum.TextXAlignment.Left,
					12
				)

				local selector = Instance.new("TextButton", row)
				selector.Size = UDim2.new(0.55, -12, 0, 22)
				selector.Position = UDim2.new(0.45, 0, 0.5, -11)
				selector.BackgroundColor3 = C.Base
				selector.BorderSizePixel = 0
				selector.Text = ""
				selector.AutoButtonColor = false
				selector.ZIndex = 5
				corner(selector, 5)
				stroke(selector, C.Border, 1)

				local selected = opts.Default or opts.Options[1]
				UI.Flags[opts.Flag] = selected

				local selLbl = newLabel(
					selector,
					selected,
					UDim2.new(1, -22, 1, 0),
					UDim2.new(0, 8, 0, 0),
					C.Text,
					Enum.TextXAlignment.Left,
					11
				)
				selLbl.ZIndex = 6

				local chevron = newLabel(
					selector,
					"v",
					UDim2.new(0, 16, 1, 0),
					UDim2.new(1, -18, 0, 0),
					C.TextMuted,
					Enum.TextXAlignment.Center,
					10
				)
				chevron.Font = Enum.Font.GothamBold
				chevron.ZIndex = 6

				-- list floats in gui root
				local optionH = 26
				local listH = math.min(#opts.Options * optionH, 130)

				local listFrame = Instance.new("Frame", gui)
				listFrame.Size = UDim2.new(0, 100, 0, 0)
				listFrame.BackgroundColor3 = C.White
				listFrame.BorderSizePixel = 0
				listFrame.ZIndex = 50
				listFrame.Visible = false
				listFrame.ClipsDescendants = true
				corner(listFrame, 5)
				stroke(listFrame, C.Border, 1)

				local listLayout = Instance.new("UIListLayout", listFrame)
				listLayout.SortOrder = Enum.SortOrder.LayoutOrder

				local open = false

				local function closeList()
					open = false
					tween(chevron, { Rotation = 0 }, 0.12)
					tween(listFrame, { Size = UDim2.new(0, listFrame.AbsoluteSize.X, 0, 0) }, 0.12)
					task.delay(0.13, function()
						listFrame.Visible = false
					end)
				end

				selector.MouseButton1Click:Connect(function()
					if open then
						closeList()
					else
						open = true
						local ap = selector.AbsolutePosition
						local as = selector.AbsoluteSize
						listFrame.Size = UDim2.new(0, as.X, 0, 0)
						listFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 2)
						listFrame.Visible = true
						tween(chevron, { Rotation = 180 }, 0.12)
						tween(listFrame, { Size = UDim2.new(0, as.X, 0, listH) }, 0.15)
					end
				end)

				for _, opt in ipairs(opts.Options) do
					local optBtn = Instance.new("TextButton", listFrame)
					optBtn.Size = UDim2.new(1, 0, 0, optionH)
					optBtn.BackgroundColor3 = C.White
					optBtn.BorderSizePixel = 0
					optBtn.Text = ""
					optBtn.AutoButtonColor = false
					optBtn.ZIndex = 51

					local optLbl = newLabel(
						optBtn,
						opt,
						UDim2.new(1, -10, 1, 0),
						UDim2.new(0, 10, 0, 0),
						opt == selected and C.Accent or C.Text,
						Enum.TextXAlignment.Left,
						11
					)
					optLbl.ZIndex = 52

					optBtn.MouseEnter:Connect(function()
						tween(optBtn, { BackgroundColor3 = C.Base }, 0.08)
					end)
					optBtn.MouseLeave:Connect(function()
						tween(optBtn, { BackgroundColor3 = C.White }, 0.08)
					end)

					optBtn.MouseButton1Click:Connect(function()
						selected = opt
						selLbl.Text = opt
						UI.Flags[opts.Flag] = opt
						for _, child in pairs(listFrame:GetChildren()) do
							if child:IsA("TextButton") then
								local cl = child:FindFirstChildOfClass("TextLabel")
								if cl then
									cl.TextColor3 = cl.Text == opt and C.Accent or C.Text
								end
							end
						end
						closeList()
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

			-- ── BUTTON ───────────────────────────────────────────────────────
			function api:CreateButton(opts)
				local row = makeRow(36)

				local btn = Instance.new("TextButton", row)
				btn.Size = UDim2.new(1, -24, 0, 24)
				btn.Position = UDim2.new(0, 12, 0.5, -12)
				btn.BackgroundColor3 = opts.Style == "accent" and C.Accent or C.Dark
				btn.BorderSizePixel = 0
				btn.Text = ""
				btn.AutoButtonColor = false
				btn.ZIndex = 5
				corner(btn, 6)

				local btnLbl = newLabel(
					btn,
					opts.Name,
					UDim2.new(1, 0, 1, 0),
					UDim2.new(0, 0, 0, 0),
					C.White,
					Enum.TextXAlignment.Center,
					12
				)
				btnLbl.Font = Enum.Font.GothamSemibold
				btnLbl.ZIndex = 6

				local base = opts.Style == "accent" and C.Accent or C.Dark
				btn.MouseEnter:Connect(function()
					tween(btn, { BackgroundColor3 = base:Lerp(Color3.new(0, 0, 0), 0.15) }, 0.1)
				end)
				btn.MouseLeave:Connect(function()
					tween(btn, { BackgroundColor3 = base }, 0.1)
				end)
				btn.MouseButton1Down:Connect(function()
					tween(btn, { Size = UDim2.new(1, -28, 0, 22), Position = UDim2.new(0, 14, 0.5, -11) }, 0.06)
				end)
				btn.MouseButton1Up:Connect(function()
					tween(btn, { Size = UDim2.new(1, -24, 0, 24), Position = UDim2.new(0, 12, 0.5, -12) }, 0.06)
				end)
				btn.MouseButton1Click:Connect(function()
					if opts.Callback then
						opts.Callback()
					end
				end)
			end

			-- ── INPUT ────────────────────────────────────────────────────────
			function api:CreateInput(opts)
				local row = makeRow(34)

				newLabel(
					row,
					opts.Name,
					UDim2.new(0.4, -8, 0, 16),
					UDim2.new(0, 12, 0.5, -8),
					C.Text,
					Enum.TextXAlignment.Left,
					12
				)

				local box = Instance.new("TextBox", row)
				box.Size = UDim2.new(0.55, -4, 0, 22)
				box.Position = UDim2.new(0.42, 0, 0.5, -11)
				box.BackgroundColor3 = C.Base
				box.BorderSizePixel = 0
				box.Text = opts.Default or ""
				box.PlaceholderText = opts.Placeholder or "Enter value..."
				box.TextColor3 = C.Text
				box.PlaceholderColor3 = C.TextMuted
				box.Font = Enum.Font.Gotham
				box.TextSize = 11
				box.ClearTextOnFocus = opts.ClearOnFocus ~= false
				box.ZIndex = 5
				corner(box, 5)
				local boxStroke = stroke(box, C.Border, 1)

				box.Focused:Connect(function()
					tween(boxStroke, { Color = C.Accent }, 0.12)
				end)
				box.FocusLost:Connect(function(enter)
					tween(boxStroke, { Color = C.Border }, 0.12)
					UI.Flags[opts.Flag] = box.Text
					if opts.Callback then
						opts.Callback(box.Text, enter)
					end
				end)

				return {
					SetValue = function(_, v)
						box.Text = v
						UI.Flags[opts.Flag] = v
					end,
					GetValue = function(_)
						return box.Text
					end,
				}
			end

			-- ── LABEL ────────────────────────────────────────────────────────
			function api:CreateLabel(text)
				local row = makeRow(26)
				newLabel(
					row,
					text,
					UDim2.new(1, -24, 1, 0),
					UDim2.new(0, 12, 0, 0),
					C.TextMuted,
					Enum.TextXAlignment.Left,
					11
				)
			end

			return api
		end -- CreateSection

		return tab
	end -- CreateTab

	return window
end -- CreateWindow

return UI
