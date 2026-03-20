local UI = {}
UI.Flags = {}

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService      = game:GetService("HttpService")

-- ─── FLAT GRAY PALETTE ───────────────────────────────────────────────────────
local C = {
    Base        = Color3.fromRGB(245, 245, 245), -- #F5F5F5
    Surface     = Color3.fromRGB(236, 236, 236), -- #ECECEC
    Panel       = Color3.fromRGB(224, 224, 224), -- #E0E0E0
    Border      = Color3.fromRGB(200, 200, 200), -- #C8C8C8
    Dark        = Color3.fromRGB(58,  58,  58 ), -- #3A3A3A
    Accent      = Color3.fromRGB(92,  107, 192), -- #5C6BC0 indigo
    AccentHover = Color3.fromRGB(57,  73,  171), -- #3949AB
    Danger      = Color3.fromRGB(239, 83,  80 ), -- #EF5350
    Text        = Color3.fromRGB(26,  26,  26 ), -- #1A1A1A
    TextMuted   = Color3.fromRGB(120, 120, 120), -- #787878
    White       = Color3.fromRGB(255, 255, 255),
    TagPro      = Color3.fromRGB(232, 233, 245), -- #E8E9F5
    TagProText  = Color3.fromRGB(57,  73,  171), -- #3949A3
    TagNew      = Color3.fromRGB(234, 243, 222), -- #EAF3DE
    TagNewText  = Color3.fromRGB(59,  109, 17 ), -- #3B6D11
}

-- ─── HELPERS ─────────────────────────────────────────────────────────────────
local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 6)
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color     = color or C.Border
    s.Thickness = thickness or 1
    return s
end

local function label(parent, text, size, color, xAlign)
    local l = Instance.new("TextLabel", parent)
    l.Size                = size or UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text                = text
    l.TextColor3          = color or C.Text
    l.Font                = Enum.Font.Gotham
    l.TextSize            = 13
    l.TextXAlignment      = xAlign or Enum.TextXAlignment.Left
    return l
end

-- ─── NOTIFICATION ────────────────────────────────────────────────────────────
function UI:Notify(text, duration, kind)
    duration = duration or 3
    kind     = kind or "info" -- "info" | "success" | "warn" | "error"

    local gui = game.CoreGui:FindFirstChild("FlatGrayUI")
    if not gui then return end

    local bg = ({
        info    = Color3.fromRGB(240, 244, 255),
        success = Color3.fromRGB(234, 243, 222),
        warn    = Color3.fromRGB(250, 238, 218),
        error   = Color3.fromRGB(252, 235, 235),
    })[kind] or C.Surface

    local tc = ({
        info    = C.AccentHover,
        success = Color3.fromRGB(59, 109, 17),
        warn    = Color3.fromRGB(133, 79, 11),
        error   = Color3.fromRGB(163, 45, 45),
    })[kind] or C.Text

    local notif = Instance.new("Frame", gui)
    notif.Size                = UDim2.new(0, 220, 0, 44)
    notif.Position            = UDim2.new(1, -240, 1, 10) -- starts off-screen below
    notif.BackgroundColor3    = bg
    notif.BorderSizePixel     = 0
    corner(notif, 8)
    stroke(notif, C.Border, 1)

    local dot = Instance.new("Frame", notif)
    dot.Size               = UDim2.new(0, 4, 1, -16)
    dot.Position           = UDim2.new(0, 8, 0, 8)
    dot.BackgroundColor3   = tc
    dot.BorderSizePixel    = 0
    corner(dot, 2)

    local lbl = Instance.new("TextLabel", notif)
    lbl.Size                 = UDim2.new(1, -24, 1, 0)
    lbl.Position             = UDim2.new(0, 20, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                 = text
    lbl.TextColor3           = tc
    lbl.Font                 = Enum.Font.Gotham
    lbl.TextSize             = 12
    lbl.TextXAlignment       = Enum.TextXAlignment.Left
    lbl.TextWrapped          = true

    -- slide in
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
    -- clean up old instance
    if game.CoreGui:FindFirstChild("FlatGrayUI") then
        game.CoreGui.FlatGrayUI:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name            = "FlatGrayUI"
    gui.ResetOnSpawn    = false
    gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    gui.Parent          = game.CoreGui

    -- ── MAIN FRAME ──────────────────────────────────────────────────────────
    local main = Instance.new("Frame", gui)
    main.Name              = "Main"
    main.Size              = UDim2.new(0, 480, 0, 320)
    main.Position          = UDim2.new(0.5, -240, 0.5, -160)
    main.BackgroundColor3  = C.Base
    main.BorderSizePixel   = 0
    main.Active            = true
    main.Draggable         = true
    corner(main, 10)
    stroke(main, C.Border, 1)

    -- entrance tween
    main.Size = UDim2.new(0, 480, 0, 0)
    tween(main, { Size = UDim2.new(0, 480, 0, 320) }, 0.22)

    -- ── TITLE BAR ───────────────────────────────────────────────────────────
    local titlebar = Instance.new("Frame", main)
    titlebar.Name             = "TitleBar"
    titlebar.Size             = UDim2.new(1, 0, 0, 36)
    titlebar.BackgroundColor3 = C.Surface
    titlebar.BorderSizePixel  = 0
    corner(titlebar, 10) -- top corners match main

    -- bottom border line on titlebar
    local tbLine = Instance.new("Frame", titlebar)
    tbLine.Size              = UDim2.new(1, 0, 0, 1)
    tbLine.Position          = UDim2.new(0, 0, 1, -1)
    tbLine.BackgroundColor3  = C.Border
    tbLine.BorderSizePixel   = 0

    -- app icon circle
    local iconCircle = Instance.new("Frame", titlebar)
    iconCircle.Size             = UDim2.new(0, 20, 0, 20)
    iconCircle.Position         = UDim2.new(0, 10, 0.5, -10)
    iconCircle.BackgroundColor3 = C.Accent
    iconCircle.BorderSizePixel  = 0
    corner(iconCircle, 10)

    local iconLetter = label(iconCircle, string.upper(string.sub(title, 1, 1)), UDim2.new(1, 0, 1, 0), C.White, Enum.TextXAlignment.Center)
    iconLetter.TextSize = 11
    iconLetter.Font     = Enum.Font.GothamBold

    -- title text
    local titleLbl = label(titlebar, title, UDim2.new(1, -120, 1, 0), C.Text, Enum.TextXAlignment.Left)
    titleLbl.Position = UDim2.new(0, 36, 0, 0)
    titleLbl.Font     = Enum.Font.GothamSemibold
    titleLbl.TextSize = 13

    -- subtitle / version badge
    if subtitle then
        local badge = Instance.new("Frame", titlebar)
        badge.Size             = UDim2.new(0, 0, 0, 18)
        badge.Position         = UDim2.new(0, 36 + titleLbl.TextBounds.X + 8, 0.5, -9)
        badge.BackgroundColor3 = C.TagPro
        badge.BorderSizePixel  = 0
        badge.AutomaticSize    = Enum.AutomaticSize.X
        corner(badge, 99)

        local badgeLbl = label(badge, subtitle, UDim2.new(0, 0, 1, 0), C.TagProText, Enum.TextXAlignment.Center)
        badgeLbl.AutomaticSize = Enum.AutomaticSize.X
        badgeLbl.TextSize      = 10
        badgeLbl.Font          = Enum.Font.GothamSemibold
        badgeLbl.Size          = UDim2.new(0, 0, 1, 0)

        local badgePad = Instance.new("UIPadding", badge)
        badgePad.PaddingLeft  = UDim.new(0, 7)
        badgePad.PaddingRight = UDim.new(0, 7)
    end

    -- ── WINDOW CONTROL BUTTONS ──────────────────────────────────────────────
    local function makeWinBtn(xOffset, bgColor, symbol)
        local btn = Instance.new("TextButton", titlebar)
        btn.Size              = UDim2.new(0, 14, 0, 14)
        btn.Position          = UDim2.new(1, xOffset, 0.5, -7)
        btn.BackgroundColor3  = bgColor
        btn.BorderSizePixel   = 0
        btn.Text              = ""
        btn.AutoButtonColor   = false
        corner(btn, 99)

        -- hover reveals symbol
        local sym = label(btn, symbol, UDim2.new(1, 0, 1, 0), Color3.fromRGB(80, 80, 80), Enum.TextXAlignment.Center)
        sym.TextSize           = 9
        sym.Font               = Enum.Font.GothamBold
        sym.TextTransparency   = 1

        btn.MouseEnter:Connect(function()
            tween(sym, { TextTransparency = 0 }, 0.1)
            tween(btn, { BackgroundColor3 = bgColor:Lerp(Color3.new(0,0,0), 0.15) }, 0.1)
        end)
        btn.MouseLeave:Connect(function()
            tween(sym, { TextTransparency = 1 }, 0.1)
            tween(btn, { BackgroundColor3 = bgColor }, 0.1)
        end)

        return btn
    end

    local closeBtn    = makeWinBtn(-20, C.Danger,  "×")
    local minimizeBtn = makeWinBtn(-40, C.Border,  "–")
    local helpBtn     = makeWinBtn(-60, C.Panel,   "?")

    -- ── CLOSE ───────────────────────────────────────────────────────────────
    closeBtn.MouseButton1Click:Connect(function()
        tween(main, { Size = UDim2.new(0, 480, 0, 0), Position = main.Position + UDim2.new(0, 0, 0, 10) }, 0.18)
        task.wait(0.2)
        gui:Destroy()
    end)

    -- ── MINIMIZE / RESTORE ──────────────────────────────────────────────────
    local minimized    = false
    local fullSize     = UDim2.new(0, 480, 0, 320)
    local miniSize     = UDim2.new(0, 480, 0, 36)

    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(main, { Size = minimized and miniSize or fullSize }, 0.2)
    end)

    -- ── KEYBIND: RightControl toggles visibility ─────────────────────────────
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            gui.Enabled = not gui.Enabled
        end
    end)

    -- ── SIDEBAR (tab navigation) ─────────────────────────────────────────────
    local sidebar = Instance.new("Frame", main)
    sidebar.Name             = "Sidebar"
    sidebar.Size             = UDim2.new(0, 120, 1, -36)
    sidebar.Position         = UDim2.new(0, 0, 0, 36)
    sidebar.BackgroundColor3 = C.Surface
    sidebar.BorderSizePixel  = 0

    local sideRightLine = Instance.new("Frame", sidebar)
    sideRightLine.Size             = UDim2.new(0, 1, 1, 0)
    sideRightLine.Position         = UDim2.new(1, -1, 0, 0)
    sideRightLine.BackgroundColor3 = C.Border
    sideRightLine.BorderSizePixel  = 0

    local tabLayout = Instance.new("UIListLayout", sidebar)
    tabLayout.Padding          = UDim.new(0, 2)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local tabPad = Instance.new("UIPadding", sidebar)
    tabPad.PaddingTop   = UDim.new(0, 8)
    tabPad.PaddingLeft  = UDim.new(0, 6)
    tabPad.PaddingRight = UDim.new(0, 6)

    -- ── CONTENT AREA ────────────────────────────────────────────────────────
    local contentArea = Instance.new("Frame", main)
    contentArea.Name                 = "Content"
    contentArea.Size                 = UDim2.new(1, -120, 1, -36)
    contentArea.Position             = UDim2.new(0, 120, 0, 36)
    contentArea.BackgroundTransparency = 1
    contentArea.ClipsDescendants     = true

    -- ── STATUS BAR ──────────────────────────────────────────────────────────
    -- sits at bottom of main, overlapping content
    local statusBar = Instance.new("Frame", main)
    statusBar.Name             = "StatusBar"
    statusBar.Size             = UDim2.new(1, 0, 0, 22)
    statusBar.Position         = UDim2.new(0, 0, 1, -22)
    statusBar.BackgroundColor3 = C.Surface
    statusBar.BorderSizePixel  = 0
    corner(statusBar, 6)

    local sbTopLine = Instance.new("Frame", statusBar)
    sbTopLine.Size             = UDim2.new(1, 0, 0, 1)
    sbTopLine.BackgroundColor3 = C.Border
    sbTopLine.BorderSizePixel  = 0

    local sbDot = Instance.new("Frame", statusBar)
    sbDot.Size             = UDim2.new(0, 7, 0, 7)
    sbDot.Position         = UDim2.new(0, 10, 0.5, -3.5)
    sbDot.BackgroundColor3 = Color3.fromRGB(99, 153, 34) -- green
    sbDot.BorderSizePixel  = 0
    corner(sbDot, 99)

    local sbText = label(statusBar, "Ready", UDim2.new(1, -110, 1, 0), C.Text, Enum.TextXAlignment.Left)
    sbText.Position = UDim2.new(0, 22, 0, 0)
    sbText.TextSize = 11

    local sbVersion = label(statusBar, "v1.0.0", UDim2.new(0, 80, 1, 0), C.TextMuted, Enum.TextXAlignment.Right)
    sbVersion.Position = UDim2.new(1, -86, 0, 0)
    sbVersion.TextSize = 10

    -- public method to update status bar
    local window = {}

    function window:SetStatus(text, kind)
        sbText.Text = text or "Ready"
        local dotColor = ({
            ok      = Color3.fromRGB(99, 153, 34),
            running = Color3.fromRGB(186, 117, 23),
            error   = Color3.fromRGB(239, 83, 80),
            idle    = C.Border,
        })[kind or "ok"] or Color3.fromRGB(99, 153, 34)
        tween(sbDot, { BackgroundColor3 = dotColor }, 0.2)
    end

    -- ── TABS ────────────────────────────────────────────────────────────────
    local allPages   = {}
    local allTabBtns = {}
    local firstTab   = true

    function window:CreateTab(name, icon)
        local isFirst = firstTab
        firstTab = false

        -- tab button
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size              = UDim2.new(1, 0, 0, 28)
        tabBtn.BackgroundColor3  = isFirst and C.White or C.Surface
        tabBtn.BorderSizePixel   = 0
        tabBtn.Text              = ""
        tabBtn.AutoButtonColor   = false
        corner(tabBtn, 6)

        local accentBar = Instance.new("Frame", tabBtn)
        accentBar.Size             = UDim2.new(0, 3, 1, -8)
        accentBar.Position         = UDim2.new(0, 0, 0, 4)
        accentBar.BackgroundColor3 = C.Accent
        accentBar.BorderSizePixel  = 0
        accentBar.Visible          = isFirst
        corner(accentBar, 0)

        local tabLbl = label(tabBtn, name, UDim2.new(1, -8, 1, 0), isFirst and C.Text or C.TextMuted, Enum.TextXAlignment.Left)
        tabLbl.Position = UDim2.new(0, 10, 0, 0)
        tabLbl.TextSize = 12
        tabLbl.Font     = isFirst and Enum.Font.GothamSemibold or Enum.Font.Gotham

        table.insert(allTabBtns, { btn = tabBtn, bar = accentBar, lbl = tabLbl })

        -- page (scrolling frame)
        local page = Instance.new("ScrollingFrame", contentArea)
        page.Name                  = name
        page.Size                  = UDim2.new(1, 0, 1, -22) -- leaves room for statusbar
        page.CanvasSize            = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        page.ScrollBarThickness    = 3
        page.ScrollBarImageColor3  = C.Border
        page.BackgroundTransparency = 1
        page.BorderSizePixel        = 0
        page.Visible                = isFirst

        local pageLayout = Instance.new("UIListLayout", page)
        pageLayout.Padding = UDim.new(0, 6)

        local pagePad = Instance.new("UIPadding", page)
        pagePad.PaddingTop    = UDim.new(0, 10)
        pagePad.PaddingLeft   = UDim.new(0, 10)
        pagePad.PaddingRight  = UDim.new(0, 10)
        pagePad.PaddingBottom = UDim.new(0, 10)

        table.insert(allPages, page)

        tabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(allPages) do p.Visible = false end
            for _, t in pairs(allTabBtns) do
                t.bar.Visible = false
                tween(t.btn, { BackgroundColor3 = C.Surface }, 0.12)
                t.lbl.TextColor3 = C.TextMuted
                t.lbl.Font       = Enum.Font.Gotham
            end
            page.Visible          = true
            accentBar.Visible     = true
            tween(tabBtn, { BackgroundColor3 = C.White }, 0.12)
            tabLbl.TextColor3 = C.Text
            tabLbl.Font       = Enum.Font.GothamSemibold
        end)

        -- tab hover
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

        -- ── SECTION API ─────────────────────────────────────────────────────
        local tab = {}

        function tab:CreateSection(sectionName)
            local section = Instance.new("Frame", page)
            section.Name             = sectionName
            section.Size             = UDim2.new(1, 0, 0, 0)
            section.AutomaticSize    = Enum.AutomaticSize.Y
            section.BackgroundColor3 = C.White
            section.BorderSizePixel  = 0
            corner(section, 8)
            stroke(section, C.Panel, 1)

            -- section header
            local sectionHeader = Instance.new("Frame", section)
            sectionHeader.Size             = UDim2.new(1, 0, 0, 28)
            sectionHeader.BackgroundColor3 = C.Surface
            sectionHeader.BorderSizePixel  = 0
            corner(sectionHeader, 8)

            local shBottom = Instance.new("Frame", sectionHeader)
            shBottom.Size             = UDim2.new(1, 0, 0, 8)
            shBottom.Position         = UDim2.new(0, 0, 1, -8)
            shBottom.BackgroundColor3 = C.Surface
            shBottom.BorderSizePixel  = 0

            local shLine = Instance.new("Frame", sectionHeader)
            shLine.Size             = UDim2.new(1, 0, 0, 1)
            shLine.Position         = UDim2.new(0, 0, 1, -1)
            shLine.BackgroundColor3 = C.Panel
            shLine.BorderSizePixel  = 0

            local accentDot = Instance.new("Frame", sectionHeader)
            accentDot.Size             = UDim2.new(0, 4, 0, 4)
            accentDot.Position         = UDim2.new(0, 10, 0.5, -2)
            accentDot.BackgroundColor3 = C.Accent
            accentDot.BorderSizePixel  = 0
            corner(accentDot, 99)

            local sectionTitle = label(sectionHeader, sectionName, UDim2.new(1, -24, 1, 0), C.TextMuted, Enum.TextXAlignment.Left)
            sectionTitle.Position = UDim2.new(0, 20, 0, 0)
            sectionTitle.TextSize = 10
            sectionTitle.Font     = Enum.Font.GothamSemibold

            local holder = Instance.new("Frame", section)
            holder.Name                = "Holder"
            holder.Size                = UDim2.new(1, 0, 0, 0)
            holder.Position            = UDim2.new(0, 0, 0, 28)
            holder.AutomaticSize       = Enum.AutomaticSize.Y
            holder.BackgroundTransparency = 1
            holder.BorderSizePixel     = 0

            local holderLayout = Instance.new("UIListLayout", holder)
            holderLayout.Padding = UDim.new(0, 0)

            local holderPad = Instance.new("UIPadding", holder)
            holderPad.PaddingBottom = UDim.new(0, 6)

            local api = {}

            -- ── ROW HELPER ──────────────────────────────────────────────────
            local function makeRow(h)
                local row = Instance.new("Frame", holder)
                row.Size             = UDim2.new(1, 0, 0, h or 34)
                row.BackgroundColor3 = C.White
                row.BorderSizePixel  = 0

                -- subtle hover tint
                row.MouseEnter:Connect(function()
                    tween(row, { BackgroundColor3 = C.Base }, 0.08)
                end)
                row.MouseLeave:Connect(function()
                    tween(row, { BackgroundColor3 = C.White }, 0.08)
                end)

                -- divider
                local div = Instance.new("Frame", row)
                div.Size             = UDim2.new(1, -20, 0, 1)
                div.Position         = UDim2.new(0, 10, 1, -1)
                div.BackgroundColor3 = C.Panel
                div.BorderSizePixel  = 0

                return row
            end

            -- ── TOGGLE ──────────────────────────────────────────────────────
            function api:CreateToggle(opts)
                local row   = makeRow(34)
                local state = opts.CurrentValue or false

                local nameLbl = label(row, opts.Name, UDim2.new(1, -60, 0, 16), C.Text, Enum.TextXAlignment.Left)
                nameLbl.Position = UDim2.new(0, 12, 0, 5)
                nameLbl.TextSize = 12
                nameLbl.Font     = Enum.Font.Gotham

                local descLbl = label(row, opts.Description or "", UDim2.new(1, -60, 0, 13), C.TextMuted, Enum.TextXAlignment.Left)
                descLbl.Position = UDim2.new(0, 12, 0, 19)
                descLbl.TextSize = 10

                -- toggle pill
                local pill = Instance.new("Frame", row)
                pill.Size             = UDim2.new(0, 34, 0, 18)
                pill.Position         = UDim2.new(1, -44, 0.5, -9)
                pill.BackgroundColor3 = C.Panel
                pill.BorderSizePixel  = 0
                corner(pill, 99)

                local thumb = Instance.new("Frame", pill)
                thumb.Size             = UDim2.new(0, 12, 0, 12)
                thumb.Position         = UDim2.new(0, 3, 0.5, -6)
                thumb.BackgroundColor3 = C.White
                thumb.BorderSizePixel  = 0
                corner(thumb, 99)
                stroke(thumb, C.Border, 1)

                local function updateToggle()
                    UI.Flags[opts.Flag] = state
                    tween(pill,  { BackgroundColor3 = state and C.Accent or C.Panel }, 0.15)
                    tween(thumb, { Position = state and UDim2.new(0, 19, 0.5, -6) or UDim2.new(0, 3, 0.5, -6) }, 0.15)
                    if opts.Callback then opts.Callback(state) end
                end

                updateToggle()

                local clickArea = Instance.new("TextButton", row)
                clickArea.Size                = UDim2.new(1, 0, 1, 0)
                clickArea.BackgroundTransparency = 1
                clickArea.Text                = ""
                clickArea.ZIndex              = 2

                clickArea.MouseButton1Click:Connect(function()
                    state = not state
                    updateToggle()
                end)

                return {
                    SetValue = function(_, v)
                        state = v
                        updateToggle()
                    end
                }
            end

            -- ── SLIDER ──────────────────────────────────────────────────────
            function api:CreateSlider(opts)
                local row = makeRow(44)
                row.Size  = UDim2.new(1, 0, 0, 44)

                local nameLbl = label(row, opts.Name .. ": " .. (opts.CurrentValue or opts.Min), UDim2.new(1, -20, 0, 14), C.Text, Enum.TextXAlignment.Left)
                nameLbl.Position = UDim2.new(0, 12, 0, 5)
                nameLbl.TextSize = 12
                nameLbl.Font     = Enum.Font.Gotham

                local track = Instance.new("Frame", row)
                track.Size             = UDim2.new(1, -24, 0, 5)
                track.Position         = UDim2.new(0, 12, 0, 26)
                track.BackgroundColor3 = C.Panel
                track.BorderSizePixel  = 0
                corner(track, 99)

                local fill = Instance.new("Frame", track)
                fill.Size             = UDim2.new(0, 0, 1, 0)
                fill.BackgroundColor3 = C.Accent
                fill.BorderSizePixel  = 0
                corner(fill, 99)

                local handle = Instance.new("Frame", track)
                handle.Size             = UDim2.new(0, 12, 0, 12)
                handle.AnchorPoint      = Vector2.new(0.5, 0.5)
                handle.Position         = UDim2.new(0, 0, 0.5, 0)
                handle.BackgroundColor3 = C.White
                handle.BorderSizePixel  = 0
                corner(handle, 99)
                stroke(handle, C.Accent, 2)

                local value   = math.clamp(opts.CurrentValue or opts.Min, opts.Min, opts.Max)
                local dragging = false

                local function updateSlider(val)
                    val = math.clamp(math.floor(val + 0.5), opts.Min, opts.Max)
                    value = val
                    local pct = (val - opts.Min) / (opts.Max - opts.Min)
                    fill.Size          = UDim2.new(pct, 0, 1, 0)
                    handle.Position    = UDim2.new(pct, 0, 0.5, 0)
                    nameLbl.Text       = opts.Name .. ": " .. val
                    UI.Flags[opts.Flag] = val
                    if opts.Callback then opts.Callback(val) end
                end

                updateSlider(value)

                local function calcFromX(x)
                    local abs  = track.AbsolutePosition.X
                    local size = track.AbsoluteSize.X
                    local pct  = math.clamp((x - abs) / size, 0, 1)
                    return opts.Min + (opts.Max - opts.Min) * pct
                end

                track.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        updateSlider(calcFromX(i.Position.X))
                    end
                end)

                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(calcFromX(i.Position.X))
                    end
                end)

                return {
                    SetValue = function(_, v) updateSlider(v) end,
                    GetValue = function(_)    return value      end,
                }
            end

            -- ── DROPDOWN ────────────────────────────────────────────────────
            function api:CreateDropdown(opts)
                local row = makeRow(34)

                local nameLbl = label(row, opts.Name, UDim2.new(0.5, -8, 0, 14), C.Text, Enum.TextXAlignment.Left)
                nameLbl.Position = UDim2.new(0, 12, 0.5, -7)
                nameLbl.TextSize = 12
                nameLbl.Font     = Enum.Font.Gotham

                -- selector box
                local selector = Instance.new("TextButton", row)
                selector.Size             = UDim2.new(0.5, -12, 0, 22)
                selector.Position         = UDim2.new(0.5, 0, 0.5, -11)
                selector.BackgroundColor3 = C.Base
                selector.BorderSizePixel  = 0
                selector.Text             = ""
                selector.AutoButtonColor  = false
                corner(selector, 5)
                stroke(selector, C.Border, 1)

                local selected = opts.Default or opts.Options[1]
                UI.Flags[opts.Flag] = selected

                local selLbl = label(selector, selected, UDim2.new(1, -20, 1, 0), C.Text, Enum.TextXAlignment.Left)
                selLbl.Position = UDim2.new(0, 8, 0, 0)
                selLbl.TextSize = 11
                selLbl.Font     = Enum.Font.Gotham

                -- chevron
                local chevron = label(selector, "▾", UDim2.new(0, 16, 1, 0), C.TextMuted, Enum.TextXAlignment.Center)
                chevron.Position = UDim2.new(1, -18, 0, 0)
                chevron.TextSize = 12

                -- dropdown list (lives outside row so it overlaps)
                local listFrame = Instance.new("Frame", section)
                listFrame.Size             = UDim2.new(0.5, -12, 0, 0)
                listFrame.BackgroundColor3 = C.White
                listFrame.BorderSizePixel  = 0
                listFrame.ZIndex           = 10
                listFrame.ClipsDescendants = true
                corner(listFrame, 5)
                stroke(listFrame, C.Border, 1)

                local listLayout = Instance.new("UIListLayout", listFrame)
                listLayout.Padding = UDim.new(0, 0)

                local open = false

                local function closeList()
                    open = false
                    tween(chevron, { Rotation = 0 }, 0.15)
                    tween(listFrame, { Size = UDim2.new(0.5, -12, 0, 0) }, 0.15)
                end

                selector.MouseButton1Click:Connect(function()
                    open = not open
                    local h = math.min(#opts.Options * 26, 130)
                    tween(chevron, { Rotation = open and 180 or 0 }, 0.15)
                    tween(listFrame, { Size = UDim2.new(0.5, -12, 0, open and h or 0) }, 0.15)
                end)

                for _, opt in ipairs(opts.Options) do
                    local optBtn = Instance.new("TextButton", listFrame)
                    optBtn.Size             = UDim2.new(1, 0, 0, 26)
                    optBtn.BackgroundColor3 = C.White
                    optBtn.BorderSizePixel  = 0
                    optBtn.Text             = ""
                    optBtn.AutoButtonColor  = false
                    optBtn.ZIndex           = 11

                    local optLbl = label(optBtn, opt, UDim2.new(1, -8, 1, 0), opt == selected and C.Accent or C.Text, Enum.TextXAlignment.Left)
                    optLbl.Position = UDim2.new(0, 10, 0, 0)
                    optLbl.TextSize = 11
                    optLbl.Font     = Enum.Font.Gotham
                    optLbl.ZIndex   = 12

                    optBtn.MouseEnter:Connect(function()
                        tween(optBtn, { BackgroundColor3 = C.Base }, 0.08)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        tween(optBtn, { BackgroundColor3 = C.White }, 0.08)
                    end)

                    optBtn.MouseButton1Click:Connect(function()
                        selected            = opt
                        selLbl.Text         = opt
                        UI.Flags[opts.Flag] = opt
                        -- update all option label colors
                        for _, child in pairs(listFrame:GetChildren()) do
                            if child:IsA("TextButton") then
                                local cl = child:FindFirstChildOfClass("TextLabel")
                                if cl then
                                    cl.TextColor3 = (cl.Text == opt) and C.Accent or C.Text
                                end
                            end
                        end
                        closeList()
                        if opts.Callback then opts.Callback(opt) end
                    end)
                end

                return {
                    SetValue = function(_, v)
                        selected            = v
                        selLbl.Text         = v
                        UI.Flags[opts.Flag] = v
                    end,
                    GetValue = function(_) return selected end,
                }
            end

            -- ── BUTTON ──────────────────────────────────────────────────────
            function api:CreateButton(opts)
                local row = makeRow(36)

                local btn = Instance.new("TextButton", row)
                btn.Size              = UDim2.new(1, -24, 0, 24)
                btn.Position          = UDim2.new(0, 12, 0.5, -12)
                btn.BackgroundColor3  = opts.Style == "accent" and C.Accent or C.Dark
                btn.BorderSizePixel   = 0
                btn.Text              = ""
                btn.AutoButtonColor   = false
                corner(btn, 6)

                local btnLbl = label(btn, opts.Name, UDim2.new(1, 0, 1, 0), C.White, Enum.TextXAlignment.Center)
                btnLbl.TextSize = 12
                btnLbl.Font     = Enum.Font.GothamSemibold

                local base = opts.Style == "accent" and C.Accent or C.Dark

                btn.MouseEnter:Connect(function()
                    tween(btn, { BackgroundColor3 = base:Lerp(Color3.new(0,0,0), 0.15) }, 0.1)
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
                    if opts.Callback then opts.Callback() end
                end)
            end

            -- ── TEXT INPUT ──────────────────────────────────────────────────
            function api:CreateInput(opts)
                local row = makeRow(34)

                local nameLbl = label(row, opts.Name, UDim2.new(0.4, -8, 0, 14), C.Text, Enum.TextXAlignment.Left)
                nameLbl.Position = UDim2.new(0, 12, 0.5, -7)
                nameLbl.TextSize = 12
                nameLbl.Font     = Enum.Font.Gotham

                local box = Instance.new("TextBox", row)
                box.Size                   = UDim2.new(0.55, -4, 0, 22)
                box.Position               = UDim2.new(0.42, 0, 0.5, -11)
                box.BackgroundColor3       = C.Base
                box.BorderSizePixel        = 0
                box.Text                   = opts.Default or ""
                box.PlaceholderText        = opts.Placeholder or "Enter value..."
                box.TextColor3             = C.Text
                box.PlaceholderColor3      = C.TextMuted
                box.Font                   = Enum.Font.Gotham
                box.TextSize               = 11
                box.ClearTextOnFocus       = opts.ClearOnFocus ~= false
                corner(box, 5)
                stroke(box, C.Border, 1)

                local boxStroke = box:FindFirstChildOfClass("UIStroke")

                box.Focused:Connect(function()
                    tween(boxStroke, { Color = C.Accent }, 0.12)
                end)
                box.FocusLost:Connect(function(enter)
                    tween(boxStroke, { Color = C.Border }, 0.12)
                    UI.Flags[opts.Flag] = box.Text
                    if opts.Callback then opts.Callback(box.Text, enter) end
                end)

                return {
                    SetValue = function(_, v)
                        box.Text            = v
                        UI.Flags[opts.Flag] = v
                    end,
                    GetValue = function(_) return box.Text end,
                }
            end

            -- ── LABEL ────────────────────────────────────────────────────────
            function api:CreateLabel(text)
                local row = makeRow(26)
                local lbl = label(row, text, UDim2.new(1, -24, 1, 0), C.TextMuted, Enum.TextXAlignment.Left)
                lbl.Position = UDim2.new(0, 12, 0, 0)
                lbl.TextSize = 11
            end

            return api
        end

        return tab
    end

    return window
end

return UI