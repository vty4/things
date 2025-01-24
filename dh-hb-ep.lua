-- // Ensure is Da Hood (put in autoexec)
if (game.PlaceId ~= 2788229376) then
    return
end

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Vars
local tablefind = table.find
local MainEvent = ReplicatedStorage.MainEvent

-- // Configuration
local Flags = {
    "CHECKER_1",
    "TeleportDetect",
    "OneMoreTime"
}

-- // __namecall hook
local __namecall
__namecall = hookmetamethod(game, "__namecall", function(...)
    -- // Vars
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()

    -- // See if the game is trying to alert the server
    if (method == "FireServer" and self == MainEvent and tablefind(Flags, args[2])) then
        return
    end

    -- // Anti Crash
    if (not checkcaller() and getfenv(2).crash) then
        -- // Set the crash function (hooking can cause stutters)
        local fenv = getfenv(2)
        fenv.crash = function() end
        setfenv(2, fenv)
    end

    -- //
    return __namecall(...)
end)

-- // __newindex hook (stops game from setting ws/jp)
local __newindex
__newindex = hookmetamethod(game, "__newindex", function(t, k, v)
    -- // Make sure it's trying to set our humanoid's ws/jp
    if (not checkcaller() and t:IsA("Humanoid") and (k == "WalkSpeed" or k == "JumpPower")) then
        -- // Disallow the set
        return
    end

    -- //
    return __newindex(t, k, v)
end)

-- Hitbox Expander Script
getgenv().settings = {
    Size = Vector3.new(5, 5, 5), -- Default hitbox size
    Color = Color3.fromRGB(255, 0, 0), -- Red hitbox
    Transparency = 0.5 -- Semi-transparent
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function expandHitbox(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = getgenv().settings.Size
        hrp.Transparency = getgenv().settings.Transparency
        hrp.BrickColor = BrickColor.new(getgenv().settings.Color)
        hrp.Material = Enum.Material.ForceField
    end
end

local function resetHitbox(character)
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = Vector3.new(2, 2, 1)
        hrp.Transparency = 0
        hrp.BrickColor = BrickColor.new("White")
        hrp.Material = Enum.Material.Plastic
    end
end

local function expandAllHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            expandHitbox(player.Character)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Retry expanding hitbox immediately after respawn
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

-- Run the script every 3 seconds to apply hitbox expansion
while true do
    expandAllHitboxes()
    wait(3)
end

print("Hitbox expander activated!")
