local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)

local notifyEvent = Instance.new("RemoteEvent")
notifyEvent.Name = "Notify"
notifyEvent.Parent = ReplicatedStorage

local upgrades = {} -- [Player] = number of speed upgrades bought

-- Арена ------------------------------------------------------------------

local function createArena()
	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.Size = Vector3.new(Config.ArenaSize, 2, Config.ArenaSize)
	floor.Position = Vector3.new(0, -1, 0)
	floor.Material = Enum.Material.Grass
	floor.Color = Color3.fromRGB(90, 160, 80)
	floor.Parent = Workspace

	local spawn = Instance.new("SpawnLocation")
	spawn.Anchored = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 0.5, 0)
	spawn.Neutral = true
	spawn.Parent = Workspace
end

-- Монеты -----------------------------------------------------------------

local coinsFolder = Instance.new("Folder")
coinsFolder.Name = "Coins"
coinsFolder.Parent = Workspace

local function randomPosition()
	local half = Config.ArenaSize / 2 - 5
	return Vector3.new(math.random(-half, half), 3, math.random(-half, half))
end

local function spawnCoin()
	local coin = Instance.new("Part")
	coin.Name = "Coin"
	coin.Shape = Enum.PartType.Cylinder
	coin.Size = Vector3.new(0.4, 3, 3)
	coin.CFrame = CFrame.new(randomPosition()) * CFrame.Angles(0, 0, math.rad(90))
	coin.Anchored = true
	coin.CanCollide = false
	coin.Material = Enum.Material.Neon
	coin.Color = Color3.fromRGB(255, 205, 40)
	coin.Parent = coinsFolder

	local collected = false
	coin.Touched:Connect(function(hit)
		if collected then
			return
		end
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		collected = true
		coin:Destroy()

		local stats = player:FindFirstChild("leaderstats")
		if stats then
			stats.Coins.Value += Config.CoinValue
		end

		task.delay(Config.CoinRespawnTime, spawnCoin)
	end)
end

-- Магазин ----------------------------------------------------------------

local function applySpeed(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = Config.DefaultWalkSpeed + (upgrades[player] or 0) * Config.SpeedUpgradeBonus
	end
end

local function createShop()
	local shop = Instance.new("Part")
	shop.Name = "SpeedShop"
	shop.Anchored = true
	shop.Size = Vector3.new(6, 8, 6)
	shop.Position = Vector3.new(20, 4, 0)
	shop.Color = Color3.fromRGB(80, 120, 255)
	shop.Material = Enum.Material.SmoothPlastic
	shop.Parent = Workspace

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Купить скорость"
	prompt.ObjectText = string.format("%d монет", Config.SpeedUpgradeCost)
	prompt.HoldDuration = 0.3
	prompt.MaxActivationDistance = 12
	prompt.Parent = shop

	prompt.Triggered:Connect(function(player)
		local stats = player:FindFirstChild("leaderstats")
		if not stats then
			return
		end

		local bought = upgrades[player] or 0
		if bought >= Config.MaxSpeedUpgrades then
			notifyEvent:FireClient(player, "Максимальная скорость достигнута!")
			return
		end
		if stats.Coins.Value < Config.SpeedUpgradeCost then
			notifyEvent:FireClient(player, "Не хватает монет!")
			return
		end

		stats.Coins.Value -= Config.SpeedUpgradeCost
		upgrades[player] = bought + 1
		applySpeed(player)
		notifyEvent:FireClient(player, string.format("Скорость увеличена! (%d/%d)", bought + 1, Config.MaxSpeedUpgrades))
	end)
end

-- Игроки -----------------------------------------------------------------

Players.PlayerAdded:Connect(function(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = stats

	upgrades[player] = 0
	player.CharacterAdded:Connect(function()
		task.defer(applySpeed, player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	upgrades[player] = nil
end)

createArena()
createShop()
for _ = 1, Config.MaxCoins do
	spawnCoin()
end
