local UI = {}
UI.Flags = {}

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- 🎨 CONFIG
local ACCENT = Color3.fromRGB(120, 180, 255)

local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.2), props):Play()
end

function UI:CreateWindow(title)
	if game.CoreGui:FindFirstChild("MyUILib") then
		game.CoreGui.MyUILib:Destroy()
	end

	-- 🌫 BLUR
	local blur = Instance.new("BlurEffect", Lighting)
	blur.Size = 0
	tween(blur, { Size = 12 }, 0.3)

	-- GUI
	local gui = Instance.new("ScreenGui")
	gui.Name = "MyUILib"
	gui.Parent = game.CoreGui

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 380, 0, 270)
	main.Position = UDim2.new(0.5, -190, 0.5, -135)
	main.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	main.Active = true
	main.Draggable = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

	-- 💡 Glow
	local stroke = Instance.new("UIStroke", main)
	stroke.Color = ACCENT
	stroke.Thickness = 1
	stroke.Transparency = 0.7

	-- HEADER
	local header = Instance.new("Frame", main)
	header.Size = UDim2.new(1, 0, 0, 32)
	header.BackgroundColor3 = Color3.fromRGB(35, 35, 40)

	local titleLabel = Instance.new("TextLabel", header)
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.Text = title
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- ❌ CLOSE
	local close = Instance.new("TextButton", header)
	close.Size = UDim2.new(0, 26, 0, 26)
	close.Position = UDim2.new(1, -30, 0, 3)
	close.Text = "X"
	close.BackgroundColor3 = Color3.fromRGB(150, 60, 60)
	close.TextColor3 = Color3.new(1, 1, 1)

	close.MouseEnter:Connect(function()
		tween(close, { BackgroundColor3 = Color3.fromRGB(200, 80, 80) })
	end)

	close.MouseLeave:Connect(function()
		tween(close, { BackgroundColor3 = Color3.fromRGB(150, 60, 60) })
	end)

	close.MouseButton1Click:Connect(function()
		tween(blur, { Size = 0 }, 0.2)
		task.wait(0.2)
		blur:Destroy()
		gui:Destroy()
	end)

	-- LEFT NAV
	local tabsHolder = Instance.new("Frame", main)
	tabsHolder.Size = UDim2.new(0, 110, 1, -32)
	tabsHolder.Position = UDim2.new(0, 0, 0, 32)
	tabsHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 26)

	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1, -110, 1, -32)
	content.Position = UDim2.new(0, 110, 0, 32)
	content.BackgroundTransparency = 1

	local window = {}

	function window:CreateTab(name)
		local tabBtn = Instance.new("TextButton", tabsHolder)
		tabBtn.Size = UDim2.new(1, 0, 0, 26)
		tabBtn.Text = name
		tabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		tabBtn.TextColor3 = Color3.new(1, 1, 1)

		tabBtn.MouseEnter:Connect(function()
			tween(tabBtn, { BackgroundColor3 = ACCENT })
		end)

		tabBtn.MouseLeave:Connect(function()
			tween(tabBtn, { BackgroundColor3 = Color3.fromRGB(35, 35, 40) })
		end)

		local page = Instance.new("ScrollingFrame", content)
		page.Size = UDim2.new(1, 0, 1, 0)
		page.Visible = false
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = 3
		page.BackgroundTransparency = 1

		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0, 4)

		tabBtn.MouseButton1Click:Connect(function()
			for _, v in pairs(content:GetChildren()) do
				if v:IsA("ScrollingFrame") then
					v.Visible = false
				end
			end
			page.Visible = true
		end)

		local tab = {}

		function tab:CreateSection(name)
			local section = Instance.new("Frame", page)
			section.AutomaticSize = Enum.AutomaticSize.Y
			section.Size = UDim2.new(1, -6, 0, 0)
			section.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			Instance.new("UICorner", section)

			local title = Instance.new("TextLabel", section)
			title.Size = UDim2.new(1, 0, 0, 20)
			title.Text = name
			title.TextSize = 12
			title.BackgroundTransparency = 1
			title.TextColor3 = Color3.new(1, 1, 1)

			local holder = Instance.new("Frame", section)
			holder.Position = UDim2.new(0, 0, 0, 20)
			holder.AutomaticSize = Enum.AutomaticSize.Y
			holder.Size = UDim2.new(1, 0, 0, 0)
			holder.BackgroundTransparency = 1

			local layout = Instance.new("UIListLayout", holder)
			layout.Padding = UDim.new(0, 4)

			local sectionAPI = {}

			-- 🔘 TOGGLE (ANIMATED)
			function sectionAPI:CreateToggle(opts)
				local btn = Instance.new("TextButton", holder)
				btn.Size = UDim2.new(1, 0, 0, 24)
				btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
				btn.Text = ""

				local label = Instance.new("TextLabel", btn)
				label.Text = opts.Name
				label.Size = UDim2.new(1, -50, 1, 0)
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.new(1, 1, 1)
				label.TextXAlignment = Enum.TextXAlignment.Left

				local toggle = Instance.new("Frame", btn)
				toggle.Size = UDim2.new(0, 40, 0, 18)
				toggle.Position = UDim2.new(1, -45, 0.5, -9)
				toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				Instance.new("UICorner", toggle)

				local knob = Instance.new("Frame", toggle)
				knob.Size = UDim2.new(0, 18, 1, 0)
				knob.BackgroundColor3 = Color3.new(1, 1, 1)
				Instance.new("UICorner", knob)

				local state = opts.CurrentValue or false

				local function update()
					if state then
						tween(toggle, { BackgroundColor3 = ACCENT })
						tween(knob, { Position = UDim2.new(1, -18, 0, 0) })
					else
						tween(toggle, { BackgroundColor3 = Color3.fromRGB(80, 80, 80) })
						tween(knob, { Position = UDim2.new(0, 0, 0, 0) })
					end

					if opts.Flag then
						UI.Flags[opts.Flag] = state
					end
				end

				update()

				btn.MouseButton1Click:Connect(function()
					state = not state
					update()
					if opts.Callback then
						opts.Callback(state)
					end
				end)
			end

			return sectionAPI
		end

		return tab
	end

	return window
end

return UI
