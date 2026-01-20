-- ⚽ TCS HUB V2 Delta - Reach Funcional via CFrame

-- Custom Reach | Visible Circle | Magnet | Auto Catch | Second Touch | Two Legs ⚽

-- Services
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- Config
local CONFIG = {
    reach = 10,
    magnetStrength = 0,
    showReachSphere = true,
    autoSecondTouch = true,
    scanCooldown = 2,
    ballNames = { "TPS", "ESA", "MRS", "PRS", "MPS" } -- Pode adicionar nomes extras se quiser
}

-- Variables
local balls = {}
local lastRefreshTime = 0
local reachSphere = nil
local gui, reachLabel
local legParts = {}

-- Fast lookup
local BALL_NAME_SET = {}
for _, name in ipairs(CONFIG.ballNames) do
    BALL_NAME_SET[name] = true
end

-- Notification
local function notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {    
            Title = "Tcs Hub V2",    
            Text = text,    
            Duration = duration or 2    
        })
    end)
end

-- Refresh balls
local function refreshBalls(force)
    if not force and (os.time() - lastRefreshTime) < CONFIG.scanCooldown then return end
    lastRefreshTime = os.time()
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

-- Reach Sphere (Blue + Hide/Show)
local function updateReachSphere()
    if not CONFIG.showReachSphere then
        if reachSphere then    
            reachSphere:Destroy()    
            reachSphere = nil    
        end    
        return
    end

    if not reachSphere then
        reachSphere = Instance.new("Part")    
        reachSphere.Name = "TcsHubV2ReachSphere"    
        reachSphere.Shape = Enum.PartType.Ball    
        reachSphere.Anchored = true    
        reachSphere.CanCollide = false    
        reachSphere.Transparency = 0.8    
        reachSphere.Material = Enum.Material.ForceField    
        reachSphere.Color = Color3.fromRGB(0, 120, 255) -- 🔵 Blue    
        reachSphere.Parent = Workspace    

        RunService.RenderStepped:Connect(function()    
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")    
            if hrp then    
                reachSphere.Position = hrp.Position    
            end    
        end)
    end

    reachSphere.Size = Vector3.new(CONFIG.reach * 2, CONFIG.reach * 2, CONFIG.reach * 2)
end

-- GUI
local function buildGUI()
    if gui then return end
    gui = Instance.new("ScreenGui")
    gui.Name = "TcsHubV2GUI"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(0.22, 0.22)
    frame.Position = UDim2.fromScale(0.02, 0.05)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0.1, 0)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.BackgroundTransparency = 1
    title.Text = "Tcs Hub V2"
    title.TextScaled = true
    title.Font = Enum.Font.SourceSansBold
    title.TextColor3 = Color3.new(1, 1, 1)

    reachLabel = Instance.new("TextLabel", frame)
    reachLabel.Size = UDim2.new(1, 0, 0.2, 0)
    reachLabel.Position = UDim2.new(0, 0, 0.2, 0)
    reachLabel.BackgroundTransparency = 1
    reachLabel.Text = "Reach: " .. CONFIG.reach
    reachLabel.TextScaled = true
    reachLabel.Font = Enum.Font.SourceSans
    reachLabel.TextColor3 = Color3.new(1, 1, 1)

    local function makeBtn(text, pos, callback)
        local btn = Instance.new("TextButton", frame)    
        btn.Size = UDim2.new(0.4, 0, 0.22, 0)    
        btn.Position = pos    
        btn.Text = text    
        btn.TextScaled = true    
        btn.Font = Enum.Font.SourceSansBold    
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)    
        btn.TextColor3 = Color3.new(1, 1, 1)    
        btn.MouseButton1Click:Connect(callback)
    end

    -- Decrease Reach
    makeBtn("-", UDim2.new(0.05, 0, 0.45, 0), function()
        CONFIG.reach = math.max(1, CONFIG.reach - 1)    
        reachLabel.Text = "Reach: " .. CONFIG.reach    
        updateReachSphere()    
        notify("Reach decreased to " .. CONFIG.reach, 1)
    end)

    -- Increase Reach
    makeBtn("+", UDim2.new(0.55, 0, 0.45, 0), function()
        CONFIG.reach = CONFIG.reach + 1    
        reachLabel.Text = "Reach: " .. CONFIG.reach    
        updateReachSphere()    
        notify("Reach increased to " .. CONFIG.reach, 1)
    end)

    -- Hide / Show Sphere Button
    makeBtn("Hide Sphere", UDim2.new(0.3, 0, 0.72, 0), function()
        CONFIG.showReachSphere = not CONFIG.showReachSphere    
        updateReachSphere()    
        if CONFIG.showReachSphere then    
            notify("Reach sphere enabled", 1)    
        else    
            notify("Reach sphere hidden", 1)    
        end
    end)
end

-- Touch balls (Reach funcional via CFrame)
local function touchBalls()
    if #legParts == 0 then refreshLegs() end
    if #legParts == 0 then return end

    for _, ball in ipairs(balls) do
        for _, leg in ipairs(legParts) do
            local distance = (ball.Position - leg.Position).Magnitude
            if distance <= CONFIG.reach then
                pcall(function()
                    -- Move a bola até a perna
                    ball.CFrame = leg.CFrame + Vector3.new(0, 0, 0)
                end)
                break
            end
        end
    end
end

-- Auto second touch
RunService.RenderStepped:Connect(function()
    if CONFIG.autoSecondTouch then
        touchBalls()
    end
end)

-- Auto refresh balls
task.spawn(function()
    while true do
        refreshBalls(false)    
        task.wait(CONFIG.scanCooldown)
    end
end)

-- Refresh legs on respawn
player.CharacterAdded:Connect(function()
    task.wait(2)
    refreshLegs()
end)

-- Init
buildGUI()
updateReachSphere()
refreshBalls(true)
refreshLegs()

print("🔵 TCS HUB V2 Delta carregado! Reach funcional via CFrame + esfera azul + GUI ativos!")
