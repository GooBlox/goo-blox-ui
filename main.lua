local UI = {}
UI.Flags = {}

function UI:CreateWindow(title)
	if game.CoreGui:FindFirstChild("MyUILib") then
		game.CoreGui.MyUILib:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "MyUILib"
	gui.Parent = game.CoreGui

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 360, 0, 260)
	main.Position = UDim2.new(0.5, -180, 0.5, -130)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	main.Active = true
	main.Draggable = true
	Instance.new("UICorner", main)

	-- HEADER
	local header = Instance.new("Frame", main)
	header.Size = UDim2.new(1, 0, 0, 30)
	header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

	local titleLabel = Instance.new("TextLabel", header)
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.Text = title
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.new(1, 1, 1)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local close = Instance.new("TextButton", header)
	close.Size = UDim2.new(0, 25, 0, 25)
	close.Position = UDim2.new(1, -28, 0, 2)
	close.Text = "X"
	close.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	close.TextColor3 = Color3.new(1, 1, 1)

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	-- LEFT NAV
	local tabsHolder = Instance.new("Frame", main)
	tabsHolder.Size = UDim2.new(0, 110, 1, -30)
	tabsHolder.Position = UDim2.new(0, 0, 0, 30)
	tabsHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1, -110, 1, -30)
	content.Position = UDim2.new(0, 110, 0, 30)
	content.BackgroundTransparency = 1

	local window = {}

	function window:CreateTab(name)
		local tabBtn = Instance.new("TextButton", tabsHolder)
		tabBtn.Size = UDim2.new(1, 0, 0, 26)
		tabBtn.Text = name
		tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		tabBtn.TextColor3 = Color3.new(1, 1, 1)

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
			section.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

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
			layout.Padding = UDim.new(0, 3)

			local sectionAPI = {}

			-- 🔘 TOGGLE SWITCH
			function sectionAPI:CreateToggle(opts)
				local btn = Instance.new("TextButton", holder)
				btn.Size = UDim2.new(1, 0, 0, 24)
				btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
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

				local knob = Instance.new("Frame", toggle)
				knob.Size = UDim2.new(0, 18, 1, 0)
				knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)

				local state = opts.CurrentValue or false

				local function update()
					if state then
						toggle.BackgroundColor3 = Color3.fromRGB(60, 140, 60)
						knob.Position = UDim2.new(1, -18, 0, 0)
					else
						toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
						knob.Position = UDim2.new(0, 0, 0, 0)
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

			-- 🎚 SLIDER
			function sectionAPI:CreateSlider(opts)
				local frame = Instance.new("Frame", holder)
				frame.Size = UDim2.new(1, 0, 0, 40)
				frame.BackgroundTransparency = 1

				local label = Instance.new("TextLabel", frame)
				label.Size = UDim2.new(1, 0, 0, 15)
				label.Text = opts.Name .. ": " .. opts.CurrentValue
				label.BackgroundTransparency = 1
				label.TextColor3 = Color3.new(1, 1, 1)

				local bar = Instance.new("Frame", frame)
				bar.Size = UDim2.new(1, 0, 0, 6)
				bar.Position = UDim2.new(0, 0, 0, 20)
				bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

				local fill = Instance.new("Frame", bar)
				fill.Size = UDim2.new(0, 0, 1, 0)
				fill.BackgroundColor3 = Color3.fromRGB(100, 180, 100)

				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						local x = input.Position.X - bar.AbsolutePosition.X
						local percent = math.clamp(x / bar.AbsoluteSize.X, 0, 1)
						local value = math.floor(opts.Min + (opts.Max - opts.Min) * percent)

						fill.Size = UDim2.new(percent, 0, 1, 0)
						label.Text = opts.Name .. ": " .. value

						if opts.Flag then
							UI.Flags[opts.Flag] = value
						end

						if opts.Callback then
							opts.Callback(value)
						end
					end
				end)
			end

			-- 📋 DROPDOWN
			function sectionAPI:CreateDropdown(opts)
				local btn = Instance.new("TextButton", holder)
				btn.Size = UDim2.new(1, 0, 0, 24)
				btn.Text = opts.Name .. ": " .. (opts.Options[1] or "")
				btn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
				btn.TextColor3 = Color3.new(1, 1, 1)

				local index = 1

				btn.MouseButton1Click:Connect(function()
					index = index + 1
					if index > #opts.Options then
						index = 1
					end

					local val = opts.Options[index]
					btn.Text = opts.Name .. ": " .. val

					if opts.Flag then
						UI.Flags[opts.Flag] = val
					end

					if opts.Callback then
						opts.Callback(val)
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
