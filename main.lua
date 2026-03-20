local UI = {}

function UI:CreateWindow(title)
	local gui = Instance.new("ScreenGui", game.CoreGui)

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 400, 0, 250)
	main.Position = UDim2.new(0.5, -200, 0.5, -125)
	main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	main.Active = true
	main.Draggable = true

	local tabsHolder = Instance.new("Frame", main)
	tabsHolder.Size = UDim2.new(0, 120, 1, 0)
	tabsHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

	local content = Instance.new("Frame", main)
	content.Size = UDim2.new(1, -120, 1, 0)
	content.Position = UDim2.new(0, 120, 0, 0)
	content.BackgroundTransparency = 1

	local window = {}

	function window:CreateTab(name)
		local tabBtn = Instance.new("TextButton", tabsHolder)
		tabBtn.Size = UDim2.new(1, 0, 0, 30)
		tabBtn.Text = name
		tabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		tabBtn.TextColor3 = Color3.new(1, 1, 1)

		local page = Instance.new("ScrollingFrame", content)
		page.Size = UDim2.new(1, 0, 1, 0)
		page.Visible = false
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.ScrollBarThickness = 4

		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0, 6)

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
			section.Size = UDim2.new(1, -10, 0, 30)
			section.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

			local title = Instance.new("TextLabel", section)
			title.Size = UDim2.new(1, 0, 0, 20)
			title.Text = secName
			title.TextColor3 = Color3.new(1, 1, 1)
			title.BackgroundTransparency = 1

			local holder = Instance.new("Frame", section)
			holder.Size = UDim2.new(1, 0, 1, -20)
			holder.Position = UDim2.new(0, 0, 0, 20)
			holder.BackgroundTransparency = 1

			local layout = Instance.new("UIListLayout", holder)
			layout.Padding = UDim.new(0, 4)

			local sectionAPI = {}

			function sectionAPI:CreateToggle(opts)
				local toggle = Instance.new("TextButton", holder)
				toggle.Size = UDim2.new(1, 0, 0, 25)
				toggle.Text = opts.Name .. ": OFF"
				toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				toggle.TextColor3 = Color3.new(1, 1, 1)

				local state = opts.CurrentValue or false

				toggle.MouseButton1Click:Connect(function()
					state = not state
					toggle.Text = opts.Name .. ": " .. (state and "ON" or "OFF")

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
