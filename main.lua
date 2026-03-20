local UI = {}
UI.Flags = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local ACCENT = Color3.fromRGB(120, 180, 255)

local function tween(obj, props, t)
	TweenService:Create(obj, TweenInfo.new(t or 0.2), props):Play()
end

-- 💾 CONFIG SYSTEM
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

function UI:CreateWindow(title)
	if game.CoreGui:FindFirstChild("MyUILib") then
		game.CoreGui.MyUILib:Destroy()
	end

	-- 🌫 BLUR
	local blur = Instance.new("BlurEffect", Lighting)
	tween(blur, { Size = 12 }, 0.3)

	local gui = Instance.new("ScreenGui")
	gui.Name = "MyUILib"
	gui.Parent = game.CoreGui

	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 400, 0, 280)
	main.Position = UDim2.new(0.5, -200, 0.5, -140)
	main.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
	main.Active = true
	main.Draggable = true
	Instance.new("UICorner", main)

	Instance.new("UIStroke", main).Color = ACCENT

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

	-- CLOSE
	local close = Instance.new("TextButton", header)
	close.Size = UDim2.new(0, 26, 0, 26)
	close.Position = UDim2.new(1, -30, 0, 3)
	close.Text = "X"
	close.BackgroundColor3 = Color3.fromRGB(150, 60, 60)

	close.MouseButton1Click:Connect(function()
		tween(blur, { Size = 0 }, 0.2)
		task.wait(0.2)
		blur:Destroy()
		gui:Destroy()
	end)

	-- 🎮 KEYBIND (RightControl)
	UserInputService.InputBegan:Connect(function(input, gp)
		if input.KeyCode == Enum.KeyCode.RightControl then
			gui.Enabled = not gui.Enabled
		end
	end)

	-- NAV
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

		local page = Instance.new("ScrollingFrame", content)
		page.Size = UDim2.new(1, 0, 1, 0)
		page.Visible = false
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
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
			title.BackgroundTransparency = 1
			title.TextColor3 = Color3.new(1, 1, 1)

			local holder = Instance.new("Frame", section)
			holder.Position = UDim2.new(0, 0, 0, 20)
			holder.AutomaticSize = Enum.AutomaticSize.Y
			holder.BackgroundTransparency = 1

			local layout = Instance.new("UIListLayout", holder)
			layout.Padding = UDim.new(0, 4)

			local api = {}

			-- 🔘 TOGGLE
			function api:CreateToggle(opts)
				local btn = Instance.new("TextButton", holder)
				btn.Size = UDim2.new(1, 0, 0, 24)
				btn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
				btn.Text = opts.Name

				local state = opts.CurrentValue or false

				btn.MouseButton1Click:Connect(function()
					state = not state
					UI.Flags[opts.Flag] = state
					if opts.Callback then
						opts.Callback(state)
					end
				end)
			end

			-- 🎚 SLIDER (DRAG)
			function api:CreateSlider(opts)
				local frame = Instance.new("Frame", holder)
				frame.Size = UDim2.new(1, 0, 0, 40)
				frame.BackgroundTransparency = 1

				local bar = Instance.new("Frame", frame)
				bar.Size = UDim2.new(1, 0, 0, 6)
				bar.Position = UDim2.new(0, 0, 0, 20)
				bar.BackgroundColor3 = Color3.fromRGB(70, 70, 70)

				local fill = Instance.new("Frame", bar)
				fill.Size = UDim2.new(0, 0, 1, 0)
				fill.BackgroundColor3 = ACCENT

				local dragging = false

				bar.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
					end
				end)

				UserInputService.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(i)
					if dragging then
						local x = i.Position.X - bar.AbsolutePosition.X
						local p = math.clamp(x / bar.AbsoluteSize.X, 0, 1)
						fill.Size = UDim2.new(p, 0, 1, 0)

						local val = math.floor(opts.Min + (opts.Max - opts.Min) * p)
						UI.Flags[opts.Flag] = val

						if opts.Callback then
							opts.Callback(val)
						end
					end
				end)
			end

			-- 📋 DROPDOWN (REAL)
			function api:CreateDropdown(opts)
				local frame = Instance.new("Frame", holder)
				frame.Size = UDim2.new(1, 0, 0, 24)
				frame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)

				local btn = Instance.new("TextButton", frame)
				btn.Size = UDim2.new(1, 0, 1, 0)
				btn.Text = opts.Name
				btn.BackgroundTransparency = 1

				local list = Instance.new("Frame", frame)
				list.Position = UDim2.new(0, 0, 1, 0)
				list.Size = UDim2.new(1, 0, 0, 0)
				list.ClipsDescendants = true
				list.BackgroundColor3 = Color3.fromRGB(35, 35, 40)

				local layout = Instance.new("UIListLayout", list)

				local open = false

				btn.MouseButton1Click:Connect(function()
					open = not open
					tween(list, { Size = UDim2.new(1, 0, 0, open and (#opts.Options * 20) or 0) })
				end)

				for _, opt in pairs(opts.Options) do
					local o = Instance.new("TextButton", list)
					o.Size = UDim2.new(1, 0, 0, 20)
					o.Text = opt
					o.BackgroundColor3 = Color3.fromRGB(50, 50, 55)

					o.MouseButton1Click:Connect(function()
						UI.Flags[opts.Flag] = opt
						if opts.Callback then
							opts.Callback(opt)
						end
					end)
				end
			end

			return api
		end

		return tab
	end

	return window
end

return UI
