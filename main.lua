local UI = {}

function UI:CreateWindow(title)
	-- 🧹 remove old
	if game.CoreGui:FindFirstChild("MyUILib") then
		game.CoreGui.MyUILib:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "MyUILib"
	gui.Parent = game.CoreGui

	-- 🧱 MAIN
	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 360, 0, 240)
	main.Position = UDim2.new(0.5, -180, 0.5, -120)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	main.Active = true
	main.Draggable = true
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)

	-- 🔲 HEADER
	local header = Instance.new("Frame", main)
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)

	local titleLabel = Instance.new("TextLabel", header)
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title or "Window"
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- ❌ CLOSE
	local closeBtn = Instance.new("TextButton", header)
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -28, 0, 3)
	closeBtn.Text = "X"
	closeBtn.TextSize = 12
	closeBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", closeBtn)

	closeBtn.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	-- 📂 LEFT TABS
	local tabsHolder = Instance.new("Frame", main)
	tabsHolder.Size = UDim2.new(0, 110, 1, -30)
	tabsHolder.Position = UDim2.new(0, 0, 0, 30)
	tabsHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

	local tabLayout = Instance.new("UIListLayout", tabsHolder)
	tabLayout.Padding = UDim.new(0, 2)

	-- 📄 CONTENT
	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1, -110, 1, -30)
	content.Position = UDim2.new(0, 110, 0, 30)
	content.BackgroundTransparency = 1

	local window = {}

	function window:CreateTab(name)
		local tabBtn = Instance.new("TextButton", tabsHolder)
		tabBtn.Size = UDim2.new(1, 0, 0, 26)
		tabBtn.Text = name
		tabBtn.TextSize = 12
		tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		tabBtn.TextColor3 = Color3.new(1, 1, 1)

		local page = Instance.new("ScrollingFrame", content)
		page.Size = UDim2.new(1, 0, 1, 0)
		page.Visible = false
		page.BackgroundTransparency = 1
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = 3

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

		function tab:CreateSection(secName)
			local section = Instance.new("Frame", page)
			section.Size = UDim2.new(1, -6, 0, 0)
			section.AutomaticSize = Enum.AutomaticSize.Y
			section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			Instance.new("UICorner", section)

			local title = Instance.new("TextLabel", section)
			title.Size = UDim2.new(1, 0, 0, 20)
			title.Text = secName
			title.TextSize = 12
			title.TextColor3 = Color3.new(1, 1, 1)
			title.BackgroundTransparency = 1

			local holder = Instance.new("Frame", section)
			holder.Size = UDim2.new(1, 0, 0, 0)
			holder.Position = UDim2.new(0, 0, 0, 20)
			holder.BackgroundTransparency = 1
			holder.AutomaticSize = Enum.AutomaticSize.Y

			local layout = Instance.new("UIListLayout", holder)
			layout.Padding = UDim.new(0, 3)

			local sectionAPI = {}

			function sectionAPI:CreateToggle(opts)
				local toggle = Instance.new("TextButton", holder)
				toggle.Size = UDim2.new(1, 0, 0, 22)
				toggle.TextSize = 12
				toggle.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
				toggle.TextColor3 = Color3.new(1, 1, 1)

				local state = opts.CurrentValue or false

				local function update()
					toggle.Text = opts.Name .. ": " .. (state and "ON" or "OFF")
				end
				update()

				toggle.MouseButton1Click:Connect(function()
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
