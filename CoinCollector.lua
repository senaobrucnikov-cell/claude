-- Coin Collector: весь код игры в одном скрипте.
-- Вставьте в Script внутри ServerScriptService и нажмите Play.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local ARENA = 200
local MAX_COINS = 40
local COIN_RESPAWN = 3
local BASE_SPEED = 16
local UPGRADE_COST = 10
local UPGRADE_BONUS = 4
local MAX_UPGRADES = 5

local upgrades = {}
local guis = {}

local function setSpeed(player)
	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = BASE_SPEED + (upgrades[player] or 0) * UPGRADE_BONUS
	end
end

local function notify(player, text)
	local gui = guis[player]
	if not gui then
		return
	end
	local label = gui.Message
	label.Text = text
	label.TextTransparency = 0
	label.BackgroundTransparency = 0.3
	local token = (label:GetAttribute("Token") or 0) + 1
	label:SetAttribute("Token", token)
	task.delay(2.5, function()
		if label.Parent and label:GetAttribute("Token") == token then
			TweenService:Create(label, TweenInfo.new(0.5), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
		end
	end)
end

local function makeLabel(parent, name, size, pos)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = pos
	label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	label.BackgroundTransparency = 0.3
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 22
	label.Parent = parent
	Instance.new("UICorner").Parent = label
	return label
end

-- Монеты
local coinsFolder = Instance.new("Folder")
coinsFolder.Name = "Coins"
coinsFolder.Parent = Workspace

local function spawnCoin()
	local half = ARENA / 2 - 5
	local coin = Instance.new("Part")
	coin.Name = "Coin"
	coin.Shape = Enum.PartType.Cylinder
	coin.Size = Vector3.new(0.4, 3, 3)
	coin.CFrame = CFrame.new(math.random(-half, half), 3, math.random(-half, half)) * CFrame.Angles(0, 0, math.rad(90))
	coin.Anchored = true
	coin.CanCollide = false
	coin.Material = Enum.Material.Neon
	coin.Color = Color3.fromRGB(255, 205, 40)
	coin.Parent = coinsFolder

	local taken = false
	coin.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if taken or not player then
			return
		end
		taken = true
		coin:Destroy()
		local stats = player:FindFirstChild("leaderstats")
		if stats then
			stats.Coins.Value += 1
		end
		task.delay(COIN_RESPAWN, spawnCoin)
	end)
end

-- Магазин
local shop = Instance.new("Part")
shop.Name = "SpeedShop"
shop.Anchored = true
shop.Size = Vector3.new(6, 8, 6)
shop.Position = Vector3.new(20, 4, 0)
shop.Color = Color3.fromRGB(80, 120, 255)
shop.Parent = Workspace

local prompt = Instance.new("ProximityPrompt")
prompt.ActionText = "Купить скорость"
prompt.ObjectText = UPGRADE_COST .. " монет"
prompt.HoldDuration = 0.3
prompt.MaxActivationDistance = 12
prompt.Parent = shop

prompt.Triggered:Connect(function(player)
	local stats = player:FindFirstChild("leaderstats")
	local bought = upgrades[player] or 0
	if not stats then
		return
	end
	if bought >= MAX_UPGRADES then
		notify(player, "Максимальная скорость!")
	elseif stats.Coins.Value < UPGRADE_COST then
		notify(player, "Не хватает монет!")
	else
		stats.Coins.Value -= UPGRADE_COST
		upgrades[player] = bought + 1
		setSpeed(player)
		notify(player, "Скорость увеличена! (" .. (bought + 1) .. "/" .. MAX_UPGRADES .. ")")
	end
end)

-- Игроки
Players.PlayerAdded:Connect(function(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = stats

	upgrades[player] = 0
	player.CharacterAdded:Connect(function()
		task.defer(setSpeed, player)
	end)

	local gui = Instance.new("ScreenGui")
	gui.Name = "HUD"
	gui.ResetOnSpawn = false
	local counter = makeLabel(gui, "Counter", UDim2.fromOffset(200, 50), UDim2.new(0, 16, 0, 16))
	counter.TextColor3 = Color3.fromRGB(255, 205, 40)
	counter.Text = "Монеты: 0"
	local message = makeLabel(gui, "Message", UDim2.fromOffset(400, 40), UDim2.new(0.5, -200, 0, 20))
	message.TextSize = 18
	message.TextTransparency = 1
	message.BackgroundTransparency = 1
	coins.Changed:Connect(function(v)
		counter.Text = "Монеты: " .. v
	end)
	gui.Parent = player:WaitForChild("PlayerGui")
	guis[player] = gui
end)

Players.PlayerRemoving:Connect(function(player)
	upgrades[player] = nil
	guis[player] = nil
end)

for _ = 1, MAX_COINS do
	spawnCoin()
end
