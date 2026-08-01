-- ============================================================
-- 自动射击系统 v1
-- 功能：射线检测 + 自动瞄准头部 + 冷却射击 + 原生UI控制
-- ============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ========================
-- 配置区
-- ========================
local CONFIG = {
    Cooldown = 0.7,              -- 射击冷却（秒）
    MaxDistance = 700,            -- 最大射击距离
    FOV_Angle = 360,              -- 视场角限制（度）
    HeadOffset = Vector3.new(0, 0.3, 0), -- 头部偏移微调
    AutoAim = true,                -- 是否自动瞄准
    WallCheck = true,              -- 是否射线穿墙检测
}

-- ========================
-- 全局状态
-- ========================
local State = {
    Enabled = false,
    Shooting = false,
    LastShot = 0,
    Target = nil,
}

-- ========================
-- 射线检测：是否能看到目标
-- ========================
local function canSeeTarget(targetPart)
    if not targetPart then return false end
    
    local origin = Camera.CFrame.Position
    local target = targetPart.Position + CONFIG.HeadOffset
    local direction = (target - origin)
    local distance = direction.Magnitude
    
    if distance > CONFIG.MaxDistance then return false end
    
    if not CONFIG.WallCheck then return true end
    
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character or {}}
    rayParams.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, direction.Unit * distance, rayParams)
    if not result then return true end -- 无阻挡
    
    -- 检查命中是否在目标角色内
    local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
    if hitModel and hitModel == targetPart.Parent then
        return true
    end
    
    return false
end

-- ========================
-- 获取FOV内最近的敌人头部
-- ========================
local function getBestTarget()
    local bestTarget = nil
    local bestAngle = CONFIG.FOV_Angle
    local cameraPos = Camera.CFrame.Position
    local cameraLook = Camera.CFrame.LookVector
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
            
            -- 检查是否存活
            if head and humanoid and humanoid.Health > 0 then
                local toTarget = (head.Position - cameraPos).Unit
                local angle = math.deg(math.acos(toTarget:Dot(cameraLook)))
                
                if angle < bestAngle then
                    -- 射线检测是否可见
                    if canSeeTarget(head) then
                        bestAngle = angle
                        bestTarget = head
                    end
                end
            end
        end
    end
    
    return bestTarget
end

-- ========================
-- 瞄准目标
-- ========================
local function aimAt(targetPart)
    if not CONFIG.AutoAim or not targetPart then return end
    
    local targetPos = targetPart.Position + CONFIG.HeadOffset
    local newCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    Camera.CFrame = newCFrame
end

-- ========================
-- 射击事件（基于你提供的 Cobalt 格式）
-- ========================
local function GetNil(Name, DebugId)
    for _, Object in getnilinstances() do
        if Object.Name == Name and Object:GetDebugId() == DebugId then
            return Object
        end
    end
end

local function fireShot(targetHead)
    if not targetHead then return end
    
    local origin = Camera.CFrame.Position
    local hitPos = targetHead.Position
    local direction = (hitPos - origin).Unit
    
    -- 尝试获取远程事件
    local success = pcall(function()
        -- 方式1：RequestActionSync（伤害同步）
        local RequestActionSync = ReplicatedStorage:FindFirstChild("SystemResources", true)
            and ReplicatedStorage.SystemResources:FindFirstChild("BufferCache", true)
            and ReplicatedStorage.SystemResources.BufferCache:FindFirstChild("RequestActionSync")
        
        if RequestActionSync then
            RequestActionSync:FireServer({
                direction = direction,
                hitPosition = hitPos,
                origin = origin,
                hitInstance = targetHead,
                hitHumanoid = targetHead.Parent and targetHead.Parent:FindFirstChildWhichIsA("Humanoid"),
                IsHeadshot = true
            })
        end
        
        -- 方式2：ReplicateFakeBullet（子弹轨迹）
        local ReplicateBullet = ReplicatedStorage:FindFirstChild("Events", true)
            and ReplicatedStorage.Events:FindFirstChild("RemoteEvents", true)
            and ReplicatedStorage.Events.RemoteEvents:FindFirstChild("ReplicateFakeBullet")
        
        if ReplicateBullet then
            ReplicateBullet:FireServer(
                CFrame.new(origin, hitPos),
                direction
            )
        end
        
        -- 方式3：MuzzleFlash（枪口闪光）
        local MuzzleFlash = ReplicatedStorage:FindFirstChild("Events", true)
            and ReplicatedStorage.Events:FindFirstChild("RemoteEvents", true)
            and ReplicatedStorage.Events.RemoteEvents:FindFirstChild("CharacterMuzzleFlash")
        
        if MuzzleFlash then
            MuzzleFlash:FireServer()
        end
    end)
    
    if success then
        print("🔫 射击成功 → " .. (targetHead.Parent and targetHead.Parent.Name or "Unknown"))
    else
        warn("❌ 射击事件未找到，请检查 RemoteEvent 路径")
    end
end

-- ========================
-- 主循环
-- ========================
RunService.Heartbeat:Connect(function()
    if not State.Enabled then return end
    
    local target = getBestTarget()
    State.Target = target
    
    if target then
        -- 瞄准
        aimAt(target)
        
        -- 冷却检查
        local now = tick()
        if now - State.LastShot >= CONFIG.Cooldown then
            State.LastShot = now
            fireShot(target)
        end
    end
end)

-- ========================
-- 原生UI 控制面板
-- ========================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoShootGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- 主面板
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 280)
MainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 120)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- 标题栏
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🔫 培根制作专打无敌少侠"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- 关闭按钮
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -32, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TitleBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    State.Enabled = false
    print("🛑 自动射击系统已关闭")
end)

-- 状态标签
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 45)
StatusLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
StatusLabel.Text = "● 状态: 已关闭"
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- 开关按钮
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0, 85)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
ToggleBtn.Text = "▶ 启用自动射击"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16
ToggleBtn.Parent = MainFrame

ToggleBtn.MouseButton1Click:Connect(function()
    State.Enabled = not State.Enabled
    if State.Enabled then
        ToggleBtn.Text = "⏸ 停用自动射击"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        StatusLabel.Text = "● 状态: 运行中"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        ToggleBtn.Text = "▶ 启用自动射击"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        StatusLabel.Text = "● 状态: 已关闭"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    end
end)

-- 自动瞄准开关
local AimToggle = Instance.new("TextButton")
AimToggle.Size = UDim2.new(0.9, 0, 0, 35)
AimToggle.Position = UDim2.new(0.05, 0, 0, 140)
AimToggle.BackgroundColor3 = Color3.fromRGB(60, 100, 140)
AimToggle.Text = "🎯 自动瞄准: 开"
AimToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimToggle.Font = Enum.Font.SourceSans
AimToggle.TextSize = 14
AimToggle.Parent = MainFrame

AimToggle.MouseButton1Click:Connect(function()
    CONFIG.AutoAim = not CONFIG.AutoAim
    AimToggle.Text = "🎯 自动瞄准: " .. (CONFIG.AutoAim and "开" or "关")
    AimToggle.BackgroundColor3 = CONFIG.AutoAim 
        and Color3.fromRGB(60, 100, 140) 
        or Color3.fromRGB(80, 80, 80)
end)

-- 穿墙检测开关
local WallToggle = Instance.new("TextButton")
WallToggle.Size = UDim2.new(0.9, 0, 0, 35)
WallToggle.Position = UDim2.new(0.05, 0, 0, 185)
WallToggle.BackgroundColor3 = Color3.fromRGB(60, 100, 140)
WallToggle.Text = "👁 穿墙检测: 开"
WallToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
WallToggle.Font = Enum.Font.SourceSans
WallToggle.TextSize = 14
WallToggle.Parent = MainFrame

WallToggle.MouseButton1Click:Connect(function()
    CONFIG.WallCheck = not CONFIG.WallCheck
    WallToggle.Text = "👁 穿墙检测: " .. (CONFIG.WallCheck and "开" or "关")
    WallToggle.BackgroundColor3 = CONFIG.WallCheck 
        and Color3.fromRGB(60, 100, 140) 
        or Color3.fromRGB(80, 80, 80)
end)

-- 冷却时间显示
local CooldownLabel = Instance.new("TextLabel")
CooldownLabel.Size = UDim2.new(0.9, 0, 0, 25)
CooldownLabel.Position = UDim2.new(0.05, 0, 0, 230)
CooldownLabel.BackgroundTransparency = 1
CooldownLabel.Text = "⏱ 冷却: 0.7s | FOV: 360° | 距离: 700"
CooldownLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
CooldownLabel.Font = Enum.Font.SourceSans
CooldownLabel.TextSize = 12
CooldownLabel.Parent = MainFrame

-- 目标信息显示
local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(0.9, 0, 0, 25)
TargetLabel.Position = UDim2.new(0.05, 0, 0, 250)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "🎯 目标: 无"
TargetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetLabel.Font = Enum.Font.SourceSans
TargetLabel.TextSize = 12
TargetLabel.Parent = MainFrame

-- 更新目标显示
RunService.Heartbeat:Connect(function()
    if State.Target and State.Target.Parent then
        TargetLabel.Text = "🎯 目标: " .. State.Target.Parent.Name
        TargetLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    else
        TargetLabel.Text = "🎯 目标: 无"
        TargetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- ========================
-- 快捷键绑定
-- ========================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F 键切换开关
    if input.KeyCode == Enum.KeyCode.F then
        ToggleBtn.MouseButton1Click:Fire()
    end
    
    -- H 键隐藏/显示面板
    if input.KeyCode == Enum.KeyCode.H then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("✅ 自动射击系统已加载")
print("   F 键 = 开关 | H 键 = 隐藏UI | ✕ 按钮 = 关闭")
  
