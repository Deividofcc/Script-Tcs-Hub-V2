-- ⚽ TCS HUB V2 Delta - Reach Funcional Suave

-- Config do Reach
local CONFIG = {
    reach = 10,            -- alcance do Reach
    magnetStrength = 50,   -- força com que a bola é puxada
    showReachSphere = true,
    autoSecondTouch = true,
    scanCooldown = 2,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS" }
}

-- Variables
local balls = {}
local legParts = {}
local player = game.Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Fast lookup
local BALL_NAME_SET = {}
for _, name in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[name] = true
end

-- Refresh balls
local function refreshBalls()
    table.clear(balls)
    for _, v in ipairs(Workspace:GetDescendants()) do
        if BALL_NAME_SET[v.Name] and v:IsA("BasePart") then
            table.insert(balls, v)
        end
    end
end

-- Refresh legs
local function refreshLegs()
    legParts = {}
    local char = player.Character
    if not char then return end
    local rightLegs = {"Right Leg", "RightLowerLeg", "RightFoot", "RightUpperLeg"}
    local leftLegs = {"Left Leg", "LeftLowerLeg", "LeftFoot", "LeftUpperLeg"}
    for _, name in ipairs(rightLegs) do
        local part = char:FindFirstChild(name)
        if part then
            table.insert(legParts, part)
            break
        end
    end
    for _, name in ipairs(leftLegs) do
        local part = char:FindFirstChild(name)
        if part then
            table.insert(legParts, part)
            break
        end
    end
end

-- Reach suave (magnet)
local function touchBalls()
    if #legParts == 0 then refreshLegs() end
    if #legParts == 0 then return end

    for _, ball in ipairs(balls) do
        for _, leg in ipairs(legParts) do
            local distance = (ball.Position - leg.Position).Magnitude
            if distance <= CONFIG.reach then
                pcall(function()
                    -- Aplica força na direção da perna
                    local direction = (leg.Position - ball.Position).Unit
                    ball.Velocity = direction * CONFIG.magnetStrength
                end)
                break
            end
        end
    end
end

-- Auto second touch
RunService.RenderStepped:Connect(function()
    touchBalls()
end)

-- Auto refresh balls
task.spawn(function()
    while true do
        refreshBalls()
        task.wait(CONFIG.scanCooldown)
    end
end)

-- Refresh legs ao respawn
player.CharacterAdded:Connect(function()
    task.wait(2)
    refreshLegs()
end)

-- Init
refreshBalls()
refreshLegs()
print("🔵 TCS HUB V2 Delta carregado! Reach funcional suave ativo!")
