local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Whitelist = {}

local Window = Rayfield:CreateWindow({
	Name = "Gun Grounds FFA | Nikita Hub",
	LoadingTitle = "Загрузка...",
	LoadingSubtitle = "by Nikita",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "NikitaHubGG",
		FileName = "Settings"
	},
	KeySystem = false,
})

local MovementTab = Window:CreateTab("Movement", 0)
local EspTab = Window:CreateTab("ESP", 0)
local CombatTab = Window:CreateTab("Combat", 0)
local AimbotTab = Window:CreateTab("AimBot", 0)

local AimBotEnabled = false
local AimRadius = 15
local BunnyHopEnabled = false
local SpeedEnabled = false
local TargetSpeed = 20
local HitboxSize = 3
local ESPEnabled = false

MovementTab:CreateToggle({
	Name = "BunnyHop",
	CurrentValue = false,
	Callback = function(Value)
		BunnyHopEnabled = Value
	end,
})

task.spawn(function()
	while task.wait(0.1) do
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
			if hum then hum.WalkSpeed = 16 end
		end
	end,
})

MovementTab:CreateSlider({
	Name = "Speed Value",
	Range = {20, 60},
	Increment = 1,
	Suffix = "Speed",
	CurrentValue = 20,
	Callback = function(Value)
		TargetSpeed = Value
	end,
})

task.spawn(function()
	while task.wait(0.1) do
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
		ESPEnabled = Value
	end,
})

task.spawn(function()
	while task.wait(1) do
		if ESPEnabled then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("PlayerESP") then
					local h = Instance.new("Highlight")
					h.Name = "PlayerESP"
					h.FillColor = Color3.fromRGB(0, 255, 0)
					h.FillTransparency = 0.5
					h.OutlineTransparency = 1
					h.Adornee = p.Character
					h.Parent = p.Character
				end
			end
		else
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Character and p.Character:FindFirstChild("PlayerESP") then
					p.Character:FindFirstChild("PlayerESP"):Destroy()
				end
			end
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
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			pcall(function()
				hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
				hrp.Transparency = 1
				hrp.CanCollide = false
			end)
		end
	end
end)

AimbotTab:CreateToggle({
	Name = "AimBot",
	CurrentValue = false,
	Callback = function(Value)
		AimBotEnabled = Value
	end,
})

AimbotTab:CreateSlider({
	Name = "Aim Radius",
	Range = {5, 100},
	Increment = 1,
	Suffix = "m",
	CurrentValue = AimRadius,
	Callback = function(Value)
		AimRadius = Value
	end,
})

RunService.RenderStepped:Connect(function()
	if not AimBotEnabled then return end
	local closest, shortest = nil, AimRadius
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and not table.find(Whitelist, p.Name) then
			local dist = (p.Character.Head.Position - Camera.CFrame.Position).Magnitude
			if dist <= shortest then
				shortest = dist
				closest = p
			end
		end
	end
	if closest and closest.Character and closest.Character:FindFirstChild("Head") then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.Head.Position)
	end
end)

for i = 1, 10 do
	local name = ""
	AimbotTab:CreateInput({
		Name = "Whitelist Slot " .. i,
		PlaceholderText = "Name Player",
		RemoveTextAfterFocusLost = false,
		Callback = function(txt)
			name = txt
		end,
	})
	AimbotTab:CreateToggle({
		Name = "Whitelist",
		CurrentValue = false,
		Callback = function(Value)
			if Value and not table.find(Whitelist, name) then
				table.insert(Whitelist, name)
			elseif not Value then
				for i, v in ipairs(Whitelist) do
					if v == name then
						table.remove(Whitelist, i)
						break
					end
				end
			end
		end,
	})
end
