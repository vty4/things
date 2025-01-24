local notificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/laagginq/ui-libraries/main/xaxas-notification/src.lua"))()
local notifications = notificationLibrary.new({
    NotificationLifetime = 10,
    NotificationPosition = "Middle",
    
    TextFont = Enum.Font.Code,
    TextColor = Color3.fromRGB(255, 0, 0),
    TextSize = 15,
    
    TextStrokeTransparency = 0,
    TextStrokeColor = Color3.fromRGB(0, 0, 0)
})

notifications:BuildNotificationUI()
notifications:Notify("This script was created by @lastwordsb4death on YouTube!")
print('This script was created by stophurtsme on Discord or @lastwordsb4death on YouTube!')
print("Accept the risk that you might get banned.")

if game.PlaceId ~= 2788229376 then
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local tablefind = table.find
local MainEvent = ReplicatedStorage:WaitForChild("MainEvent")
local originalSizes = {}

local function isPlayerExcluded(player)
    return tablefind(_G.Settings.ExcludedPlayers, player.Name) ~= nil
end

local function expandHitbox(character)
    if not character or not character:IsA("Model") then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
        if character.Parent == LocalPlayer.Character then
            return
        end
        if not originalSizes[humanoidRootPart] then
            originalSizes[humanoidRootPart] = {
                Size = humanoidRootPart.Size,
                Transparency = humanoidRootPart.Transparency,
                Color = humanoidRootPart.Color
            }
        end
        if not isPlayerExcluded(Players:GetPlayerFromCharacter(character)) then
            humanoidRootPart.Size = _G.Settings.HitboxSize
            humanoidRootPart.Transparency = _G.Settings.HitboxTransparency
            humanoidRootPart.Color = _G.Settings.HitboxColor
            humanoidRootPart.CanCollide = false  -- Prevent freezing
        end
    else
        warn("HumanoidRootPart not found for " .. character.Name)
    end
end

local function resetHitbox(character)
    if not character or not character:IsA("Model") then return end

    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart and humanoidRootPart:IsA("BasePart") and originalSizes[humanoidRootPart] then
        if not isPlayerExcluded(Players:GetPlayerFromCharacter(character)) then
            humanoidRootPart.Size = originalSizes[humanoidRootPart].Size
            humanoidRootPart.Transparency = originalSizes[humanoidRootPart].Transparency
            humanoidRootPart.Color = originalSizes[humanoidRootPart].Color
        end
        originalSizes[humanoidRootPart] = nil
    end
end

local function expandHitboxesForAllPlayers()
    while true do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                expandHitbox(player.Character)
            end
        end
        wait(3)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if player ~= LocalPlayer then
            expandHitbox(character)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if player.Character and player ~= LocalPlayer then
        resetHitbox(player.Character)
    end
end)

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    LocalPlayer.Character:WaitForChild("Humanoid")
    LocalPlayer.Character.Humanoid.WalkSpeed = 16
    LocalPlayer.Character.Humanoid.JumpPower = 50
end

LocalPlayer.CharacterAdded:Connect(function(character)
    if character:FindFirstChildOfClass("Humanoid") then
        character.Humanoid.WalkSpeed = 16
        character.Humanoid.JumpPower = 50
    end
end)

expandHitboxesForAllPlayers()
