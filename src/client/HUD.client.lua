local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local notifyEvent = ReplicatedStorage:WaitForChild("Notify")

local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local counter = Instance.new("TextLabel")
counter.Size = UDim2.fromOffset(200, 50)
counter.Position = UDim2.new(0, 16, 0, 16)
counter.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
counter.BackgroundTransparency = 0.3
counter.TextColor3 = Color3.fromRGB(255, 205, 40)
counter.Font = Enum.Font.GothamBold
counter.TextSize = 24
counter.Text = "Монеты: 0"
counter.Parent = gui
Instance.new("UICorner").Parent = counter

local message = Instance.new("TextLabel")
message.Size = UDim2.fromOffset(400, 40)
message.AnchorPoint = Vector2.new(0.5, 0)
message.Position = UDim2.new(0.5, 0, 0, 20)
message.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
message.BackgroundTransparency = 1
message.TextTransparency = 1
message.TextColor3 = Color3.new(1, 1, 1)
message.Font = Enum.Font.GothamMedium
message.TextSize = 20
message.Text = ""
message.Parent = gui
Instance.new("UICorner").Parent = message

local stats = player:WaitForChild("leaderstats")
local coins = stats:WaitForChild("Coins")
coins.Changed:Connect(function(value)
	counter.Text = "Монеты: " .. value
end)

local shownAt = 0
notifyEvent.OnClientEvent:Connect(function(text)
	shownAt = os.clock()
	local thisShow = shownAt
	message.Text = text
	message.TextTransparency = 0
	message.BackgroundTransparency = 0.3

	task.delay(2.5, function()
		if shownAt ~= thisShow then
			return
		end
		TweenService:Create(message, TweenInfo.new(0.5), {
			TextTransparency = 1,
			BackgroundTransparency = 1,
		}):Play()
	end)
end)
