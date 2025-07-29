local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Gun Grounds FFA | Nikita Hub",
	LoadingTitle = "Загрузка меню...",
	LoadingSubtitle = "by Nikita",
	ConfigurationSaving = {Enabled = false},
	KeySystem = false,
})

local MovementTab = Window:CreateTab("Movement", 4370345144)
local EspTab = Window:CreateTab("ESP", 10952945844)
local CombatTab = Window:CreateTab("Combat", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local AimBotEnabled = false
local AimRadius = 300
local BunnyHopEnabled = false
local SpeedEnabled = false
local TargetSpeed = 20
local EspEnabled = false
local EspDrawings = {}
local HitboxSize = 1

MovementTab:CreateToggle({
	Name = "AimBot",
	CurrentValue = false,
	Callback = function(Value)
		AimBotEnabled = Value
	end,
})

MovementTab:CreateSlider({
	Name = "Aim Radius",
	Range = {100, 1000},
	Increment = 10,
	Suffix = "px",
	CurrentValue = AimRadius,
	Callback = function(Value)
		AimRadius = Value
	end,
})

local circle = Drawing.new("Circle")
circle.Color = Color3.fromRGB(0, 255, 0)
circle.Thickness = 2
circle.Filled = false
circle.Transparency = 1
circle.Visible = true
circle.Radius = AimRadius
circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

RunService.RenderStepped:Connect(function()
	circle.Radius = AimRadius
	circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	if AimBotEnabled then
		local closest = nil
		local shortest = AimRadius
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
				local head = player.Character.Head
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
					if dist < shortest then
						shortest = dist
						closest = player
					end
				end
			end
		end
		if closest and closest.Character and closest.Character:FindFirstChild("Head") then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
		end
	end
end)

MovementTab:CreateToggle({
	Name = "BunnyHop",
	CurrentValue = false,
	Callback = function(Value)
		BunnyHopEnabled = Value
	end,
})

task.spawn(function()
	while true do
		task.wait(0.1)
		if BunnyHopEnabled and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.FloorMaterial ~= Enum.Material.Air then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end
end)

MovementTab:CreateToggle({
	Name = "Speed",
	CurrentValue = false,
	Callback = function(Value)
		SpeedEnabled = Value
		if not Value and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 20 end
		end
	end,
})

MovementTab:CreateSlider({
	Name = "Speed Value",
	Range = {20, 100},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 20,
	Callback = function(Value)
		TargetSpeed = Value
	end,
})

task.spawn(function()
	while true do
		task.wait()
		if SpeedEnabled and LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = TargetSpeed end
		end
	end
end)

EspTab:CreateToggle({
	Name = "ESP Players",
	CurrentValue = false,
	Callback = function(Value)
		EspEnabled = Value
		for _, drawing in pairs(EspDrawings) do
			if drawing.Box then drawing.Box.Visible = Value end
		end
	end,
})

RunService.RenderStepped:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if not EspDrawings[player] then
				EspDrawings[player] = {
					Box = Drawing.new("Square")
				}
				EspDrawings[player].Box.Color = Color3.fromRGB(0,255,0)
				EspDrawings[player].Box.Thickness = 1
				EspDrawings[player].Box.Filled = false
				EspDrawings[player].Box.Visible = false
			end
			local boxPos, boxOnScreen = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
			local boxSize = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.5, 0))
			if boxOnScreen and EspEnabled then
				local box = EspDrawings[player].Box
				box.Size = Vector2.new(math.abs(boxSize.X - boxPos.X), math.abs(boxSize.Y - boxPos.Y))
				box.Position = Vector2.new(boxPos.X - box.Size.X / 2, boxPos.Y - box.Size.Y / 2)
				box.Visible = true
			else
				EspDrawings[player].Box.Visible = false
			end
		elseif EspDrawings[player] then
			EspDrawings[player].Box.Visible = false
		end
	end
end)

CombatTab:CreateSlider({
	Name = "Hitbox Size",
	Range = {1, 30},
	Increment = 0.1,
	Suffix = "x",
	CurrentValue = HitboxSize,
	Callback = function(Value)
		HitboxSize = Value
	end,
})

RunService.RenderStepped:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
			hrp.Transparency = 1
			hrp.CanCollide = false
		end
	end
end)
