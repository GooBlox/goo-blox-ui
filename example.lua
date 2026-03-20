local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/GooBlox/goo-blox-ui/refs/heads/main/main.lua"))()

local Window = UI:CreateWindow("Goo Blox")

local Tab = Window:CreateTab("Farm")
local Section = Tab:CreateSection("Main")

Section:CreateToggle({
	Name = "Auto Farm",
	Flag = "AutoFarm",
	CurrentValue = false,
	Callback = function(v)
		print("AutoFarm:", v)
	end,
})

Section:CreateSlider({
	Name = "Range",
	Min = 10,
	Max = 200,
	CurrentValue = 50,
	Flag = "Range",
	Callback = function(v)
		print("Range:", v)
	end,
})

Section:CreateDropdown({
	Name = "Enemy",
	Options = { "RockEnemies", "MagmaEnemies" },
	Flag = "EnemyType",
	Callback = function(v)
		print("Enemy:", v)
	end,
})
