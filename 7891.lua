-- 自制脚本优化增强版 v4.2 - 全功能修复版
if not game:IsLoaded() then
    game.Loaded:Wait()
end

if writefile then
    writefile = nil
end

game.TextChatService.ChatWindowConfiguration.Enabled = true

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/qewwwwwww/666/blob/main/ui.lua"))()
local Confirmed = false

-- 攻击系统状态管理
local attackSystem = {
    banana = {
        enabled = false,
        cooldown = 0,
        lastAttackTime = 0,
        attackLoop = nil,
        active = false
    },
    dart = {
        enabled = false,
        cooldown = 0,
        lastAttackTime = 0,
        attackLoop = nil,
        active = false
    },
    fullMap = {
        enabled = false,
        attackLoop = nil,
        active = false
    }
}

function loadPublicScript()
    WindUI:Notify({
        Title = "正在加载公益脚本",
        Content = "请稍候，正在获取SEHUB公益版本...",
        Duration = 3,
        Icon = "loader"
    })
    
    print("正在加载公益脚本: SEHUB WYT公益版")
    
    local publicScriptUrl = "https://raw.githubusercontent.com/ParKe001/ParKe/refs/heads/main/SEHUB/WYTýý (1)-obfuscated.lua"
    
    local success, errorMsg = pcall(function()
        local publicScript = game:HttpGet(publicScriptUrl)
        if publicScript and #publicScript > 0 then
            print("成功获取公益脚本，正在执行...")
            WindUI:Notify({
                Title = "加载成功",
                Content = "SEHUB公益版已就绪，正在执行...",
                Duration = 2,
                Icon = "check"
            })
            
            loadstring(publicScript)()
        else
            error("未能获取公益脚本内容")
        end
    end)
    
    if not success then
        print("公益脚本加载失败: " .. errorMsg)
        WindUI:Notify({
            Title = "加载失败",
            Content = "无法加载公益脚本，请检查网络或链接\n" .. errorMsg,
            Duration = 5,
            Icon = "x"
        })
    end
end

WindUI:Popup({
    Title = '脚本版本选择',
    IconThemed = true,
    Icon = "layers",
    Content = "请选择要执行的脚本版本：\n\n" ..
            "✨ 自制版\n" ..
            "• 全图攻击、自动收集\n" ..
            "• 高射速、无冷却\n" ..
            "• 自动购买飞镖检测\n" ..
            "• 双重条件切换:血量优先/0.5秒\n" ..
            "• 所有高级功能\n\n" ..
            "🔓 公益版\n" ..
            "• SEHUB WYT免费版本\n" ..
            "• 基础功能\n" ..
            "• 无付费限制",
    Buttons = {
        {
            Title = "🔓 公益版",
            Callback = function()
                WindUI:Notify({
                    Title = "正在加载公益版",
                    Content = "即将启动SEHUB公益脚本...",
                    Duration = 2,
                    Icon = "heart"
                })
                task.wait(1)
                loadPublicScript()
            end,
            Variant = "Success"
        },
        {
            Title = "✨ 自制版", 
            Callback = function()
                WindUI:Notify({
                    Title = "正在加载自制版",
                    Content = "即将启动自制脚本优化增强版...",
                    Duration = 2,
                    Icon = "zap"
                })
                Confirmed = true
                task.wait(1)
                createUI()
            end,
            Variant = "Primary"
        }
    }
})

function createUI()
    local PasswordSystemEnabled = true
    local defaultPassword = "mystic2024"
    local maxAttempts = 3
    local attempts = 0
    local verified = false
    
    local function createNativePasswordInput()
        local password = ""
        local completed = false
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "PasswordInput"
        screenGui.Parent = game.CoreGui
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local background = Instance.new("Frame")
        background.Size = UDim2.new(1, 0, 1, 0)
        background.BackgroundColor3 = Color3.new(0, 0, 0)
        background.BackgroundTransparency = 0.5
        background.Parent = screenGui
        local mainFrame = Instance.new("Frame")
        mainFrame.Size = UDim2.new(0, 400, 0, 300)
        mainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
        mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 50)
        titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        titleBar.Parent = mainFrame
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 1, 0)
        title.Text = "🔐 脚本安全验证"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 22
        title.BackgroundTransparency = 1
        title.Parent = titleBar
        local hintLabel = Instance.new("TextLabel")
        hintLabel.Size = UDim2.new(0.9, 0, 0, 60)
        hintLabel.Position = UDim2.new(0.05, 0, 0.2, 0)
        hintLabel.Text = "请输入访问密码\n\n⚠️ 密码错误"..maxAttempts.."次将自动踢出"
        hintLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        hintLabel.Font = Enum.Font.SourceSans
        hintLabel.TextSize = 16
        hintLabel.TextWrapped = true
        hintLabel.BackgroundTransparency = 1
        hintLabel.Parent = mainFrame
        local inputFrame = Instance.new("Frame")
        inputFrame.Size = UDim2.new(0.9, 0, 0, 50)
        inputFrame.Position = UDim2.new(0.05, 0, 0.5, 0)
        inputFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        inputFrame.BorderSizePixel = 0
        inputFrame.Parent = mainFrame
        local passwordBox = Instance.new("TextBox")
        passwordBox.Size = UDim2.new(1, 0, 1, 0)
        passwordBox.Text = ""
        passwordBox.PlaceholderText = "在此输入密码..."
        passwordBox.TextColor3 = Color3.new(1, 1, 1)
        passwordBox.Font = Enum.Font.SourceSans
        passwordBox.TextSize = 18
        passwordBox.BackgroundTransparency = 1
        passwordBox.Parent = inputFrame
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(0.9, 0, 0, 50)
        buttonContainer.Position = UDim2.new(0.05, 0, 0.75, 0)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = mainFrame
        local cancelButton = Instance.new("TextButton")
        cancelButton.Size = UDim2.new(0.45, 0, 1, 0)
        cancelButton.Position = UDim2.new(0, 0, 0, 0)
        cancelButton.Text = "❌ 取消"
        cancelButton.TextColor3 = Color3.new(1, 1, 1)
        cancelButton.Font = Enum.Font.SourceSansBold
        cancelButton.TextSize = 16
        cancelButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        cancelButton.Parent = buttonContainer
        cancelButton.MouseButton1Click:Connect(function()
            screenGui:Destroy()
            game:GetService("Players").LocalPlayer:Kick("验证取消")
        end)
        local verifyButton = Instance.new("TextButton")
        verifyButton.Size = UDim2.new(0.45, 0, 1, 0)
        verifyButton.Position = UDim2.new(0.55, 0, 0, 0)
        verifyButton.Text = "✅ 验证"
        verifyButton.TextColor3 = Color3.new(1, 1, 1)
        verifyButton.Font = Enum.Font.SourceSansBold
        verifyButton.TextSize = 16
        verifyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        verifyButton.Parent = buttonContainer
        verifyButton.MouseButton1Click:Connect(function()
            password = passwordBox.Text
            completed = true
            screenGui:Destroy()
        end)
        passwordBox.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                password = passwordBox.Text
                completed = true
                screenGui:Destroy()
            end
        end)
        task.wait(0.1)
        passwordBox:CaptureFocus()
        local startTime = tick()
        while not completed and screenGui.Parent and tick() - startTime < 120 do
            task.wait(0.1)
        end
        if not completed and screenGui.Parent then
            screenGui:Destroy()
        end
        return password
    end
    
    if PasswordSystemEnabled then
        WindUI:Notify({
            Title = "脚本启动",
            Content = "正在加载密码验证系统...",
            Duration = 2
        })
        task.wait(1)
        while not verified and attempts < maxAttempts do
            local userPassword = createNativePasswordInput()
            if not userPassword or #userPassword == 0 then
                attempts = maxAttempts
                break
            end
            attempts = attempts + 1
            if userPassword == defaultPassword then
                verified = true
                WindUI:Notify({
                    Title = "✅ 验证成功",
                    Content = "欢迎使用自制脚本控制面板",
                    Duration = 3
                })
            else
                local remaining = maxAttempts - attempts
                if remaining > 0 then
                    WindUI:Notify({
                        Title = "⚠️ 密码错误",
                        Content = "密码验证失败，剩余尝试次数: "..remaining,
                        Duration = 3
                    })
                    task.wait(1.5)
                else
                    WindUI:Notify({
                        Title = "❌ 验证失败",
                        Content = "密码错误次数过多，即将返回大厅",
                        Duration = 3
                    })
                    task.wait(2)
                    game:GetService("Players").LocalPlayer:Kick("密码验证失败次数过多")
                end
            end
        end
        if not verified then
            return
        end
    end
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")

    local devv = require(ReplicatedStorage.devv)
    local Signal = devv.load("Signal")
    local v3item = devv.load("v3item")
    local GUID = require(ReplicatedStorage.devv.shared.Helpers.string.GUID)
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character:WaitForChild("Humanoid")

    _G.BananaRange = 50
    _G.DartRange = 20
    _G.bananaSpeed = 1500
    _G.dartSpeed = 2000
    _G.bananaCooldown = 0
    _G.dartCooldown = 0
    _G.bananaPredictDistance = 2.0
    _G.dartPredictDistance = 1.2
    _G.maxTargetCount = 3
    _G.attackPriority = 1.0
    _G.useEnhancedPrediction = true

    local autoATMCashCombo = false
    local autoSellEnabled = false
    local autoSellConnection = nil
    local lastBombardmentTime = 0
    local autoSellInterval = 5
    local bananaaura = false
    local dartaura = false
    local autoFists = false
    local bananaToggle = nil
    local dartToggle = nil
    local autokill = false
    local targetLockEnabled = false
    local lockedTargetName = ""
    local lockedTargetPlayer = nil
    local fullMapAttackEnabled = false
    local fullMapAttackConnection = nil
    local fullMapTeleportCooldown = 0
    local lastFullMapTeleportTime = 0
    local fullMapDartCountPerAttack = 10
    local fullMapAttackDelayBetweenDarts = 0
    local fullMapImmunityCheckTime = 0
    local fullMapAttackRange = 2000
    local fullMapAutoBuyDarts = true
    local fullMapMinTargetHealth = 1
    local fullMapUsePrediction = true
    local fullMapAttackMode = "behind"
    local fullMapCircleRadius = 10
    local fullMapCircleSpeed = 0.5
    local fullMapCurrentCircleAngle = 0
    local fullMapBehindDistance = 1
    local fullMapCircleSpeedMultiplier = 1.0

    local dartManager = {
        lastPurchaseTime = 0,
        purchaseCooldown = 5,
        maxRetryCount = 3,
        currentRetryCount = 0,
        lastCheckTime = 0,
        checkCooldown = 1
    }

    load = require(ReplicatedStorage.devv).load
    Signal = load("Signal")
    FireServer = Signal.FireServer
    InvokeServer = Signal.InvokeServer
    GUID = load("GUID")
    v3item = load("v3item")
    Raycast = load("Raycast")
    local inventory = v3item.inventory
    local melee = require(game:GetService("ReplicatedStorage").devv).load("ClientReplicator")

    local function getOptimizedTargets(range, requireHead, weaponType)
        local allTargets = {}
        local now = tick()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local character = player.Character
            if not character then continue end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            if not humanoid or humanoid.Health <= 0 or not rootPart then continue end
            if requireHead and not head then continue end
            local distance = (HumanoidRootPart.Position - rootPart.Position).Magnitude
            if distance <= range and distance >= 5 then
                local distanceFactor = 1.0 - (distance / range)
                local velocity = rootPart.Velocity.Magnitude
                local speedFactor = velocity > 20 and 1.2 or 1.0
                local priority = distanceFactor * speedFactor * _G.attackPriority
                table.insert(allTargets, {
                    player = player,
                    character = character,
                    distance = distance,
                    rootPart = rootPart,
                    head = head,
                    priority = priority,
                    lastSeenTime = now
                })
            end
        end
        table.sort(allTargets, function(a, b)
            return a.priority > b.priority
        end)
        local selectedTargets = {}
        for _, target in ipairs(allTargets) do
            if #selectedTargets < _G.maxTargetCount then
                table.insert(selectedTargets, target)
            end
        end
        return selectedTargets
    end

    local function validateAndApplySpeedSettings()
        _G.bananaSpeed = math.clamp(_G.bananaSpeed, 200, 9999)
        _G.dartSpeed = math.clamp(_G.dartSpeed, 300, 9999)
        print(string.format("射速设置验证: 香蕉皮=%d, 飞镖=%d", _G.bananaSpeed, _G.dartSpeed))
    end

    executeBananaAttack = function(targetPlayer, targetChar)
        if targetPlayer == LocalPlayer then return false end
        local currentTime = tick()
        
        if currentTime - attackSystem.banana.lastAttackTime < 0.2 then
            return false
        end
        
        if not Character or not Humanoid or Humanoid.Health <= 0 then
            return false
        end
        
        local localChar = LocalPlayer.Character
        if not localChar then return false end
        local localHumanoid = localChar:FindFirstChildOfClass("Humanoid")
        if not localHumanoid or localHumanoid.Health <= 0 then return false end
        
        local rightHand = localChar:FindFirstChild("RightHand")
        if not rightHand then return false end
        
        local itemData, itemGuid = findBanana()
        if not itemData or not itemGuid then
            task.spawn(function()
                pcall(function()
                    InvokeServer("attemptPurchase", "Banana Peel")
                end)
            end)
            return false
        end
        
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        local rootPart = targetChar:FindFirstChild("HumanoidRootPart")
        if not humanoid or humanoid.Health <= 0 or not rootPart then return false end
        
        local distance = (HumanoidRootPart.Position - rootPart.Position).Magnitude
        if distance > _G.BananaRange or distance < 5 then return false end
        
        attackSystem.banana.lastAttackTime = currentTime
        
        task.spawn(function()
            pcall(function()
                FireServer("equip", itemGuid)
            end)
        end)
        
        local startPos = rightHand.Position
        local targetPos = rootPart.Position - Vector3.new(0, 2, 0)
        local predictedPos = targetPos
        
        if _G.useEnhancedPrediction then
            local velocity = rootPart.Velocity
            local speed = velocity.Magnitude
            local moveDirection = velocity.Unit
            if speed > 5 then
                local timeToTarget = distance / math.max(_G.bananaSpeed, 1)
                local forwardDistance = speed * timeToTarget * _G.bananaPredictDistance
                forwardDistance = math.min(forwardDistance, distance * 0.5)
                predictedPos = targetPos + (moveDirection * forwardDistance)
            end
        end
        
        local appliedSpeed = math.clamp(_G.bananaSpeed, 200, 9999)
        local velocityVector = (predictedPos - startPos).Unit * appliedSpeed
        
        print(string.format("[香蕉皮攻击] 射速: %d, 距离: %.1f", appliedSpeed, distance))
        
        local success = pcall(function()
            hackthrow(LocalPlayer, "Banana Peel", itemGuid, velocityVector, predictedPos, "banana")
        end)
        
        return success
    end

    executeDartAttack = function(targetPlayer, targetChar)
        if targetPlayer == LocalPlayer then return false end
        local currentTime = tick()
        
        if currentTime - attackSystem.dart.lastAttackTime < 0.2 then
            return false
        end
        
        if not Character or not Humanoid or Humanoid.Health <= 0 then
            return false
        end
        
        local localChar = LocalPlayer.Character
        if not localChar then return false end
        local localHumanoid = localChar:FindFirstChildOfClass("Humanoid")
        if not localHumanoid or localHumanoid.Health <= 0 then return false end
        
        local rightHand = localChar:FindFirstChild("RightHand")
        if not rightHand then return false end
        
        local ninjaStarData, ninjaStarGuid = findNinjaStar()
        if not ninjaStarData or not ninjaStarGuid then
            task.spawn(function()
                pcall(function()
                    InvokeServer("attemptPurchase", "Ninja Star")
                end)
            end)
            return false
        end
        
        local humanoid = targetChar:FindFirstChildOfClass("Humanoid")
        local head = targetChar:FindFirstChild("Head")
        if not humanoid or humanoid.Health <= 0 or not head then return false end
        
        local distance = (HumanoidRootPart.Position - head.Position).Magnitude
        if distance > _G.DartRange or distance < 5 then return false end
        
        attackSystem.dart.lastAttackTime = currentTime
        
        task.spawn(function()
            pcall(function()
                FireServer("equip", ninjaStarGuid)
            end)
        end)
        
        local startPos = rightHand.Position
        local targetPos = head.Position + Vector3.new(0, 0.2, 0)
        local predictedPos = targetPos
        
        if _G.useEnhancedPrediction then
            local rootPart = targetChar:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local velocity = rootPart.Velocity
                local speed = velocity.Magnitude
                local moveDirection = velocity.Unit
                if speed > 2 then
                    local timeToTarget = distance / math.max(_G.dartSpeed, 1)
                    local forwardDistance = speed * timeToTarget * _G.dartPredictDistance
                    forwardDistance = math.min(forwardDistance, distance * 0.3)
                    predictedPos = targetPos + (moveDirection * forwardDistance)
                    local gravityEffect = Vector3.new(0, -0.5 * (distance / 100), 0)
                    predictedPos = predictedPos + gravityEffect
                end
            end
        end
        
        local appliedSpeed = math.clamp(_G.dartSpeed, 300, 9999)
        local velocityVector = (targetPos - startPos).Unit * appliedSpeed
        
        print(string.format("[飞镖攻击] 射速: %d, 距离: %.1f", appliedSpeed, distance))
        
        local success = pcall(function()
            hackthrow(LocalPlayer, "Ninja Star", ninjaStarGuid, velocityVector, targetPos, "dart")
        end)
        
        return success
    end

    local function getFullMapTargets()
        local targets = {}
        local now = tick()
        local myPosition = HumanoidRootPart and HumanoidRootPart.Position or Vector3.new(0, 0, 0)
        
        if targetLockEnabled and lockedTargetPlayer then
            local character = lockedTargetPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and humanoid.Health > 0 and rootPart then
                    local distance = (myPosition - rootPart.Position).Magnitude
                    table.insert(targets, {
                        player = lockedTargetPlayer,
                        character = character,
                        humanoid = humanoid,
                        rootPart = rootPart,
                        distance = distance,
                        health = humanoid.Health,
                        maxHealth = humanoid.MaxHealth,
                        priority = 9999,
                        isImmune = false,
                        lastAttackTime = 0
                    })
                end
            end
        else
            for _, player in ipairs(Players:GetPlayers()) do
                if player == LocalPlayer then continue end
                
                local character = player.Character
                if not character then continue end
                
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                
                if not humanoid or humanoid.Health <= fullMapMinTargetHealth or not rootPart then
                    continue
                end
                
                local distance = (myPosition - rootPart.Position).Magnitude
                if distance <= fullMapAttackRange then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local priority = 1.0 - healthPercent
                    
                    table.insert(targets, {
                        player = player,
                        character = character,
                        humanoid = humanoid,
                        rootPart = rootPart,
                        distance = distance,
                        health = humanoid.Health,
                        maxHealth = humanoid.MaxHealth,
                        priority = priority,
                        isImmune = false,
                        lastAttackTime = 0
                    })
                end
            end
        end
        
        table.sort(targets, function(a, b)
            if a.priority ~= b.priority then
                return a.priority > b.priority
            end
            return a.distance < b.distance
        end)
        
        return targets
    end

    hackthrow = function(plr, itemname, itemguid, velocity, epos, projectileType)
        if plr ~= LocalPlayer then
            return
        end
        local char = plr.Character
        if not char then
            return
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            return
        end
        local rightHand = char:FindFirstChild("RightHand")
        if not rightHand then
            return
        end
        local throwGuid = GUID()
        local startPos = rightHand.Position
        local success, stickyId = InvokeServer("throwSticky", throwGuid, itemname, itemguid, velocity, epos)
        if not success then
            return
        end
        local dummyPart = Instance.new("Part")
        dummyPart.Size = Vector3.new(4, 4, 4)
        dummyPart.Position = epos
        dummyPart.Anchored = true
        dummyPart.Transparency = 1
        dummyPart.CanCollide = false
        dummyPart.Parent = workspace
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {plr.Character, workspace.Game.Local, workspace.Game.Drones}
        local dist = (startPos - epos).Magnitude
        local rayResult = workspace:Raycast(
            startPos,
            (epos - startPos).Unit * (dist + 5),
            rayParams
        )
        if rayResult and rayResult.Instance then
            local hitPart = rayResult.Instance
            local relativeHitCFrame = hitPart.CFrame:ToObjectSpace(CFrame.new(rayResult.Position, rayResult.Position + rayResult.Normal))
            local stickyCFrame = CFrame.new(rayResult.Position)
            if dummyPart.Parent then
                dummyPart:Destroy()
            end
            if projectileType == "banana" then
                bananaThrowArgs = {
                    "hitSticky",
                    stickyId or throwGuid,
                    hitPart,
                    relativeHitCFrame,
                    stickyCFrame
                }
            elseif projectileType == "dart" then
                dartThrowArgs = {
                    "hitSticky",
                    stickyId or throwGuid,
                    hitPart,
                    relativeHitCFrame,
                    stickyCFrame
                }
            end
            InvokeServer("hitSticky", stickyId or throwGuid, hitPart, relativeHitCFrame, stickyCFrame)
        else
            if dummyPart.Parent then
                dummyPart:Destroy()
            end
        end
    end

    local function equipFists()
        for i, v in next, inventory.items do
            if v.name == 'Fists' then
                FireServer("equip", v.guid)
                break
            end
        end
    end

    getinventory = function()
        return inventory.items
    end

    findBanana = function()
        for guid, data in next, getinventory() do
            if data.name == "Banana Peel" then
                return data, guid
            end
        end
        return nil, nil
    end

    findNinjaStar = function()
        for guid, data in next, getinventory() do
            if data.name == "Ninja Star" then
                return data, guid
            end
        end
        return nil, nil
    end

    local function manageDarts(showNotification)
        local currentTime = tick()
        
        if currentTime - dartManager.lastCheckTime < dartManager.checkCooldown then
            return findNinjaStar()
        end
        
        dartManager.lastCheckTime = currentTime
        
        local ninjaStarData, ninjaStarGuid = findNinjaStar()
        
        if not ninjaStarData or not ninjaStarGuid then
            if currentTime - dartManager.lastPurchaseTime < dartManager.purchaseCooldown then
                if showNotification then
                    WindUI:Notify({
                        Title = "⏳ 购买冷却中",
                        Content = string.format("请等待%.1f秒后自动购买", 
                            dartManager.purchaseCooldown - (currentTime - dartManager.lastPurchaseTime)),
                        Duration = 2,
                        Icon = "clock"
                    })
                end
                return nil, nil
            end
            
            if dartManager.currentRetryCount >= dartManager.maxRetryCount then
                if showNotification then
                    WindUI:Notify({
                        Title = "⚠️ 多次购买失败",
                        Content = "已尝试3次购买飞镖失败，请手动检查",
                        Duration = 3,
                        Icon = "x"
                    })
                end
                return nil, nil
            end
            
            dartManager.currentRetryCount = dartManager.currentRetryCount + 1
            dartManager.lastPurchaseTime = currentTime
            
            if showNotification then
                WindUI:Notify({
                    Title = "🔄 自动补给",
                    Content = string.format("第%d次尝试购买飞镖...", dartManager.currentRetryCount),
                    Duration = 2,
                    Icon = "refresh-cw"
                })
            end
            
            print("自动补给: 正在购买飞镖，尝试次数:", dartManager.currentRetryCount)
            
            local purchaseSuccess = pcall(function()
                InvokeServer("attemptPurchase", "Ninja Star")
            end)
            
            if purchaseSuccess then
                if showNotification then
                    WindUI:Notify({
                        Title = "✅ 购买请求已发送",
                        Content = "正在获取飞镖，请稍候...",
                        Duration = 2,
                        Icon = "shopping-cart"
                    })
                end
                
                task.wait(2)
                
                ninjaStarData, ninjaStarGuid = findNinjaStar()
                
                if ninjaStarData and ninjaStarGuid then
                    dartManager.currentRetryCount = 0
                    if showNotification then
                        WindUI:Notify({
                            Title = "🎯 补给成功",
                            Content = "已获得飞镖，弹药就绪！",
                            Duration = 2,
                            Icon = "check"
                        })
                    end
                end
            else
                if showNotification then
                    WindUI:Notify({
                        Title = "❌ 购买失败",
                        Content = "无法购买飞镖，请检查游戏设置",
                        Duration = 2,
                        Icon = "x"
                    })
                end
            end
        else
            dartManager.currentRetryCount = 0
        end
        
        return ninjaStarData, ninjaStarGuid
    end

    local function teleportBehindTargetFullMap(targetRootPart, targetCharacter)
        if not targetRootPart or not HumanoidRootPart then
            return false
        end
        local targetCFrame = targetRootPart.CFrame
        local lookVector = targetCFrame.LookVector
        local teleportPosition = targetRootPart.Position - (lookVector * fullMapBehindDistance)
        teleportPosition = teleportPosition + Vector3.new(0, 3, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
        local rayResult = workspace:Raycast(
            teleportPosition + Vector3.new(0, 10, 0),
            Vector3.new(0, -20, 0),
            rayParams
        )
        if rayResult and rayResult.Position then
            teleportPosition = rayResult.Position + Vector3.new(0, 3, 0)
        end
        HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
        HumanoidRootPart.CFrame = CFrame.new(teleportPosition, targetRootPart.Position)
        return true
    end

    local function teleportCircleAroundTargetFullMap(targetRootPart, targetCharacter)
        if not targetRootPart or not HumanoidRootPart then
            return false
        end
        local targetPosition = targetRootPart.Position
        local currentTime = tick()
        fullMapCurrentCircleAngle = fullMapCurrentCircleAngle + (fullMapCircleSpeed * fullMapCircleSpeedMultiplier)
        if fullMapCurrentCircleAngle >= 360 then
            fullMapCurrentCircleAngle = fullMapCurrentCircleAngle - 360
        end
        local angleRad = math.rad(fullMapCurrentCircleAngle)
        local offsetX = math.cos(angleRad) * fullMapCircleRadius
        local offsetZ = math.sin(angleRad) * fullMapCircleRadius
        local teleportPosition = targetPosition + Vector3.new(offsetX, 0, offsetZ)
        teleportPosition = teleportPosition + Vector3.new(0, 5, 0)
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, targetCharacter}
        local rayResult = workspace:Raycast(
            teleportPosition + Vector3.new(0, 10, 0),
            Vector3.new(0, -20, 0),
            rayParams
        )
        if rayResult and rayResult.Position then
            teleportPosition = rayResult.Position + Vector3.new(0, 3, 0)
        end
        HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
        HumanoidRootPart.CFrame = CFrame.new(teleportPosition, targetRootPart.Position)
        return true
    end

    local function teleportToTargetFullMap(targetRootPart, targetCharacter)
        if fullMapAttackMode == "circle" then
            return teleportCircleAroundTargetFullMap(targetRootPart, targetCharacter)
        else
            return teleportBehindTargetFullMap(targetRootPart, targetCharacter)
        end
    end

    local function executeQuickDartAttack(target)
        if not target or not target.character or not target.rootPart then
            return false
        end
        
        local head = target.character:FindFirstChild("Head")
        if not head then
            return false
        end
        
        local ninjaStarData, ninjaStarGuid = manageDarts(false)
        if not ninjaStarData or not ninjaStarGuid then
            return false
        end
        
        local equipSuccess = pcall(function()
            FireServer("equip", ninjaStarGuid)
        end)
        if not equipSuccess then
            return false
        end
        
        local myCharacter = LocalPlayer.Character
        if not myCharacter then
            return false
        end
        
        local rightHand = myCharacter:FindFirstChild("RightHand")
        if not rightHand then
            return false
        end
        
        if not target.humanoid or target.humanoid.Health <= 0 then
            return false
        end
        
        local startPos = rightHand.Position
        local appliedSpeed = math.max(_G.dartSpeed, 1500)
        
        local targetPos = head.Position + Vector3.new(0, 0.2, 0)
        
        if fullMapUsePrediction and target.rootPart then
            local velocity = target.rootPart.Velocity
            local speed = velocity.Magnitude
            if speed > 2 then
                local distance = (startPos - targetPos).Magnitude
                local timeToTarget = distance / math.max(appliedSpeed, 1)
                local forwardDistance = speed * timeToTarget * 1.5
                local moveDirection = velocity.Unit
                targetPos = targetPos + (moveDirection * forwardDistance)
            end
        end
        
        local velocityVector = (targetPos - startPos).Unit * appliedSpeed
        
        local success = pcall(function()
            if not dartThrowArgs then
                hackthrow(LocalPlayer, "Ninja Star", ninjaStarGuid, velocityVector, targetPos, "dart")
            else
                dartThrowArgs[3] = head
                dartThrowArgs[5] = CFrame.new(targetPos)
                pcall(InvokeServer, unpack(dartThrowArgs))
            end
        end)
        
        return success
    end
    local function executeMultiDartAttackFullMap(target)
        if not target or not target.character or not target.rootPart then
            return false
        end
        
        if not Character or not Humanoid or Humanoid.Health <= 0 then
            print("自身角色死亡，停止攻击")
            return false
        end
        
        local head = target.character:FindFirstChild("Head")
        if not head then
            return false
        end
        
        local ninjaStarData, ninjaStarGuid = manageDarts(true)
        
        if not ninjaStarData or not ninjaStarGuid then
            WindUI:Notify({
                Title = "⚠️ 紧急补给",
                Content = "正在尝试紧急购买飞镖...",
                Duration = 2,
                Icon = "zap"
            })
            
            pcall(function()
                InvokeServer("attemptPurchase", "Ninja Star")
            end)
            
            task.wait(1.5)
            ninjaStarData, ninjaStarGuid = findNinjaStar()
            
            if not ninjaStarData or not ninjaStarGuid then
                WindUI:Notify({
                    Title = "❌ 攻击中止",
                    Content = "检测到飞镖数量为0，全图攻击暂停",
                    Duration = 3,
                    Icon = "stop-circle"
                })
                return false
            end
        end
        
        local equipSuccess = pcall(function()
            FireServer("equip", ninjaStarGuid)
        end)
        
        if not equipSuccess then
            WindUI:Notify({
                Title = "❌ 装备失败",
                Content = "无法装备飞镖，请检查物品",
                Duration = 2,
                Icon = "x"
            })
            return false
        end
        
        local myCharacter = LocalPlayer.Character
        if not myCharacter then
            return false
        end
        
        local rightHand = myCharacter:FindFirstChild("RightHand")
        if not rightHand then
            return false
        end
        
        local successCount = 0
        local startPos = rightHand.Position
        local appliedSpeed = math.max(_G.dartSpeed, 1500)
        
        WindUI:Notify({
            Title = "🎯 开始攻击",
            Content = string.format("目标: %s\n射速: %d\n切换条件: 血量优先或0.5秒", 
                target.player.Name, appliedSpeed),
            Duration = 2,
            Icon = "crosshair"
        })
        
        local attackStartTime = tick()
        local maxAttackDuration = 0.5
        local shouldContinueAttack = true
        local attackReason = "时间到达"
        
        while shouldContinueAttack do
            if not target.humanoid or target.humanoid.Health <= 0 then
                print(string.format("目标 %s 已死亡，停止攻击。", target.player.Name))
                attackReason = "目标死亡"
                shouldContinueAttack = false
                break
            end
            
            local currentDuration = tick() - attackStartTime
            if currentDuration >= maxAttackDuration then
                print(string.format("攻击 %s 已达%.2f秒，切换目标。", target.player.Name, maxAttackDuration))
                attackReason = "时间到达"
                shouldContinueAttack = false
                break
            end
            
            if not Character or not Humanoid or Humanoid.Health <= 0 then
                print("攻击过程中角色死亡，停止攻击")
                attackReason = "自身死亡"
                shouldContinueAttack = false
                break
            end
            
            local quickHitSuccess = executeQuickDartAttack(target)
            if quickHitSuccess then
                successCount = successCount + 1
            end
            
            task.wait(0.05)
        end
        
        if successCount > 0 then
            print(string.format("攻击了 %s，成功次数: %d，持续时间: %.3f秒，切换原因: %s", 
                target.player.Name, successCount, tick() - attackStartTime, attackReason))
        end
        
        return successCount > 0
    end
    
    local function lockTarget(playerName)
        if not playerName or playerName == "" then
            WindUI:Notify({
                Title = "锁定失败",
                Content = "请输入要锁定的玩家名称",
                Duration = 2,
                Icon = "x"
            })
            return false
        end
        
        local foundPlayer = nil
        local searchName = playerName:lower()
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then
                continue
            end
            
            local playerNameLower = player.Name:lower()
            
            if playerNameLower == searchName then
                foundPlayer = player
                break
            end
            
            if playerNameLower:find(searchName, 1, true) then
                foundPlayer = player
                break
            end
            
            if searchName:len() >= 3 and playerNameLower:find(searchName:sub(1, 3), 1, true) then
                foundPlayer = player
                break
            end
            
            local displayName = player.DisplayName:lower()
            if displayName:find(searchName, 1, true) then
                foundPlayer = player
                break
            end
        end
        
        if foundPlayer then
            lockedTargetName = foundPlayer.Name
            lockedTargetPlayer = foundPlayer
            targetLockEnabled = true
            
            WindUI:Notify({
                Title = "目标已锁定",
                Content = "已锁定目标: " .. foundPlayer.Name,
                Duration = 3,
                Icon = "target"
            })
            
            print("目标锁定成功:", foundPlayer.Name, "UserId:", foundPlayer.UserId)
            return true
        else
            WindUI:Notify({
                Title = "锁定失败",
                Content = "未找到玩家: " .. playerName .. "\n请检查玩家名称是否正确或是否在线",
                Duration = 3,
                Icon = "x"
            })
            return false
        end
    end
    
    local function unlockTarget()
        targetLockEnabled = false
        lockedTargetName = ""
        lockedTargetPlayer = nil
        
        WindUI:Notify({
            Title = "目标已解锁",
            Content = "已解锁所有目标",
            Duration = 2,
            Icon = "unlock"
        })
    end
    
    local function bananaAttackLoop()
        return RunService.Heartbeat:Connect(function()
            if not bananaaura or not attackSystem.banana.enabled then
                attackSystem.banana.active = false
                return
            end
            
            if not Character or not Humanoid or Humanoid.Health <= 0 then
                attackSystem.banana.active = false
                return
            end
            
            attackSystem.banana.active = true
            
            local targets = getOptimizedTargets(_G.BananaRange, false, "banana")
            if #targets == 0 then
                return
            end
            
            for _, target in ipairs(targets) do
                if not bananaaura or not attackSystem.banana.enabled then
                    break
                end
                
                local success = executeBananaAttack(target.player, target.character)
                if success then
                    print(string.format("[香蕉皮] 攻击了 %s (距离: %.1f)", 
                        target.player.Name, target.distance))
                end
                
                task.wait(0.1)
                break
            end
        end)
    end
    
    local function dartAttackLoop()
        return RunService.Heartbeat:Connect(function()
            if not dartaura or not attackSystem.dart.enabled then
                attackSystem.dart.active = false
                return
            end
            
            if not Character or not Humanoid or Humanoid.Health <= 0 then
                attackSystem.dart.active = false
                return
            end
            
            attackSystem.dart.active = true
            
            local targets = getOptimizedTargets(_G.DartRange, true, "dart")
            if #targets == 0 then
                return
            end
            
            for _, target in ipairs(targets) do
                if not dartaura or not attackSystem.dart.enabled then
                    break
                end
                
                local success = executeDartAttack(target.player, target.character)
                if success then
                    print(string.format("[飞镖] 攻击了 %s (距离: %.1f)", 
                        target.player.Name, target.distance))
                end
                
                task.wait(0.1)
                break
            end
        end)
    end
    
    local function fullMapAttackLoop()
        return RunService.Heartbeat:Connect(function()
            if not fullMapAttackEnabled then
                return
            end
            
            if not Character or not Character.Parent or not Humanoid or Humanoid.Health <= 0 then
                print("角色死亡，暂停攻击")
                return
            end
            
            if not LocalPlayer.Character or LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health <= 0 then
                print("角色死亡或不存在，暂停攻击")
                return
            end
            
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            Humanoid = Character:WaitForChild("Humanoid")
            
            local ninjaStarData, ninjaStarGuid = findNinjaStar()
            if not ninjaStarData or not ninjaStarGuid then
                if fullMapAutoBuyDarts then
                    WindUI:Notify({
                        Title = "⚠️ 弹药检测",
                        Content = "检测到飞镖数量为0，正在尝试自动购买...",
                        Duration = 2,
                        Icon = "alert-circle"
                    })
                    
                    local purchaseSuccess = pcall(function()
                        InvokeServer("attemptPurchase", "Ninja Star")
                    end)
                    
                    if purchaseSuccess then
                        WindUI:Notify({
                            Title = "✅ 购买请求已发送",
                            Content = "请等待自动购买完成",
                            Duration = 2,
                            Icon = "shopping-cart"
                        })
                    end
                end
                
                task.wait(1)
                return
            end
            
            local targets = getFullMapTargets()
            if #targets == 0 then
                return
            end
            
            for _, target in ipairs(targets) do
                if not fullMapAttackEnabled then
                    break
                end
                
                if not target.humanoid or target.humanoid.Health <= 0 then
                    continue
                end
                
                if not Character or not Humanoid or Humanoid.Health <= 0 then
                    print("攻击过程中角色死亡，停止当前攻击")
                    break
                end
                
                local teleportSuccess = teleportToTargetFullMap(target.rootPart, target.character)
                if not teleportSuccess then
                    continue
                end
                
                local attackSuccess = executeMultiDartAttackFullMap(target)
                
                if attackSuccess then
                    print(string.format("攻击了 %s (血量: %.0f/%.0f, 距离: %.1f)", 
                        target.player.Name, target.humanoid.Health, target.maxHealth, target.distance))
                end
                
                task.wait(0.1)
                break
            end
        end)
    end
    
    local function toggleFullMapAttack(state)
        if state and (not Character or not Humanoid or Humanoid.Health <= 0) then
            WindUI:Notify({
                Title = "❌ 无法启用",
                Content = "角色死亡，请复活后再启用攻击",
                Duration = 3,
                Icon = "x"
            })
            return
        end
        
        fullMapAttackEnabled = state
        attackSystem.fullMap.enabled = state
        
        if fullMapAttackEnabled then
            local modeText = fullMapAttackMode == "circle" and "旋转攻击模式" or "背后攻击模式"
            
            if bananaaura then
                bananaToggle:SetValue(false)
                WindUI:Notify({
                    Title = "自动切换",
                    Content = "已禁用香蕉皮攻击，启用全图攻击",
                    Duration = 2,
                    Icon = "refresh-cw"
                })
            end
            
            if dartaura then
                dartToggle:SetValue(false)
                WindUI:Notify({
                    Title = "自动切换",
                    Content = "已禁用飞镖攻击，启用全图攻击",
                    Duration = 2,
                    Icon = "refresh-cw"
                })
            end
            
            WindUI:Notify({
                Title = "全图攻击已启用",
                Content = string.format("模式: %s\n高射速无冷却\n双重条件: 血量(优先)或0.5秒自动切换", modeText),
                Duration = 3,
                Icon = "crosshair"
            })
            
            local ninjaStarData, ninjaStarGuid = findNinjaStar()
            if not ninjaStarData or not ninjaStarGuid then
                WindUI:Notify({
                    Title = "⚠️ 警告",
                    Content = "未检测到飞镖，请在攻击前确保拥有弹药",
                    Duration = 3,
                    Icon = "alert-triangle"
                })
            end
            
            if fullMapAttackConnection then
                fullMapAttackConnection:Disconnect()
            end
            
            Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            Humanoid = Character:WaitForChild("Humanoid")
            
            fullMapAttackConnection = fullMapAttackLoop()
            attackSystem.fullMap.active = true
        else
            if fullMapAttackConnection then
                fullMapAttackConnection:Disconnect()
                fullMapAttackConnection = nil
            end
            attackSystem.fullMap.active = false
            WindUI:Notify({
                Title = "全图攻击已禁用",
                Content = "全图攻击功能已停止\n切换条件: 血量归零或攻击0.5秒",
                Duration = 2,
                Icon = "stop-circle"
            })
        end
    end
    
    local function executeSingleFullMapAttack()
        local targets = getFullMapTargets()
        if #targets == 0 then
            WindUI:Notify({
                Title = "全图攻击",
                Content = "未找到可攻击的目标",
                Duration = 2,
                Icon = "x"
            })
            return
        end
        
        local target = targets[1]
        local modeText = fullMapAttackMode == "circle" and "旋转攻击模式" or "背后攻击模式"
        WindUI:Notify({
            Title = "全图攻击执行中",
            Content = string.format("%s\n目标: %s\n切换条件: 血量优先或0.5秒", modeText, target.player.Name),
            Duration = 2,
            Icon = "zap"
        })
        
        local teleportSuccess = teleportToTargetFullMap(target.rootPart, target.character)
        if teleportSuccess then
            local attackSuccess = executeMultiDartAttackFullMap(target)
            if attackSuccess then
                WindUI:Notify({
                    Title = "攻击完成",
                    Content = "成功攻击: " .. target.player.Name .. "\n切换原因: " .. 
                              (target.humanoid.Health <= 0 and "目标死亡" or "时间到达"),
                    Duration = 2,
                    Icon = "check"
                })
            end
        end
    end
    
    local Window = WindUI:CreateWindow({
        Title = '自制脚本 优化增强版 v4.2',
        Icon = "crown",
        IconThemed = true,
        Author = "v4.2 by 自制版 | 远程攻击已修复 | 0.5秒自动切换",
        Folder = "CloudHub",
        Size = UDim2.fromOffset(100, 150),
        
        Transparent = true,
        Theme = "Dark",
        HideSearchBar = false,
        ScrollBarEnabled = true,
        Resizable = true,
        
        Background = "rbxassetid://0",
        BackgroundImageTransparency = 0.1,
        BackgroundImageBlur = 8,
        BackgroundImageScale = 1,
        BackgroundColor = Color3.fromHex("#1E1E2E"),
        BackgroundTransparency = 0.2,
        
        Border = true,
        BorderColor = Color3.fromHex("#5D9CEC"),
        BorderTransparency = 0.2,
        BorderSize = 2,
        
        DropShadow = true,
        ShadowColor = Color3.fromHex("#000000"),
        ShadowTransparency = 0.5,
        ShadowSize = 8,
        
        CornerRadius = 12,
        
        TitleBarTransparent = true,
        TitleBarColor = Color3.fromHex("#252535"),
        TitleBarTransparency = 0.4,
        
        SideBarTransparent = true,
        SideBarColor = Color3.fromHex("#1F1F2F"),
        SideBarTransparency = 0.3,
        
        User = {
            Enabled = true,
            Callback = function()
                WindUI:Notify({
                    Title = "点击了自己",
                    Content = "没什么",
                    Duration = 1,
                    Icon = "4483362748"
                })
            end,
            Anonymous = false
        },
        SideBarWidth = 250,
        Search = {
            Enabled = true,
            Placeholder = "搜索...",
            Callback = function(searchText)
                print("搜索内容:", searchText)
            end
        },
        SidePanel = {
            Enabled = true,
            Content = {
                {
                    Type = "Button",
                    Text = "",
                    Style = "Subtle",
                    Size = UDim2.new(1, -20, 0, 30),
                    Callback = function()
                    end
                }
            }
        }
    })
    
    Window:EditOpenButton({
        Title = "自制脚本 v4.2",
        Icon = "crown",
        CornerRadius = UDim.new(0, 16),
        StrokeThickness = 4,
        Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
        Draggable = true
    })
    
    Window:Tag({
        Title = "远程攻击已修复",
        Color = Color3.fromHex("#00FF00")
    })
    
    Window:Tag({
        Title = "0.5秒自动切换",
        Color = Color3.fromHex("#00FF00")
    })
    
    Window:Tag({
        Title = "v4.2",
        Color = Color3.fromHex("#FFA500")
    })

    local AttackTab = Window:Tab({Title = "攻击功能", Icon = "swords"})
    AttackTab:Select()

    AttackTab:Section({Title = "目标锁定", Icon = "target"})

    AttackTab:Input({
        Title = "锁定目标玩家名",
        Desc = "输入要锁定的玩家名称（支持模糊匹配）",
        Placeholder = "输入玩家名称...",
        Value = "",
        Callback = function(value)
            if value ~= "" then
                lockTarget(value)
            end
        end
    })

    AttackTab:Button({
        Title = "锁定当前目标",
        Desc = "锁定当前正在攻击的目标",
        Icon = "target",
        Callback = function()
            local targets = getFullMapTargets()
            if #targets > 0 then
                local currentTarget = targets[1]
                lockTarget(currentTarget.player.Name)
            else
                WindUI:Notify({
                    Title = "锁定失败",
                    Content = "没有找到可锁定的目标",
                    Duration = 2,
                    Icon = "x"
                })
            end
        end
    })

    AttackTab:Button({
        Title = "解锁目标",
        Desc = "清除所有目标锁定",
        Icon = "unlock",
        Callback = unlockTarget
    })

    AttackTab:Toggle({
        Title = "启用目标锁定",
        Desc = "启用后只攻击锁定的目标",
        Value = targetLockEnabled,
        Callback = function(state)
            targetLockEnabled = state
            WindUI:Notify({
                Title = "目标锁定",
                Content = "目标锁定: " .. (state and "已启用" or "已禁用"),
                Duration = 2,
                Icon = state and "lock" or "unlock"
            })
        end
    })

    AttackTab:Section({Title = "远程攻击", Icon = "target"})

    local function updateBananaToggleTitle()
        if bananaToggle then
            bananaToggle:SetTitle(string.format("香蕉皮攻击 (射程: %d, 射速: %d)", _G.BananaRange, _G.bananaSpeed))
        end
    end

    local function updateDartToggleTitle()
        if dartToggle then
            dartToggle:SetTitle(string.format("飞镖攻击 (射程: %d, 射速: %d)", _G.DartRange, _G.dartSpeed))
        end
    end

    local function refreshAllAttackUI()
        updateBananaToggleTitle()
        updateDartToggleTitle()
        WindUI:Notify({
            Title = "UI已刷新",
            Content = "攻击设置UI已更新显示",
            Duration = 1,
            Icon = "check"
        })
    end

    bananaToggle = AttackTab:Toggle({
        Title = string.format("香蕉皮攻击 (射程: %d, 射速: %d)", _G.BananaRange, _G.bananaSpeed),
        Value = false,
        Callback = function(state)
            bananaaura = state
            attackSystem.banana.enabled = state
            
            if state then
                if attackSystem.fullMap.active then
                    toggleFullMapAttack(false)
                    WindUI:Notify({
                        Title = "切换攻击模式",
                        Content = "已切换到香蕉皮攻击模式",
                        Duration = 2,
                        Icon = "info"
                    })
                end
                
                if attackSystem.banana.attackLoop then
                    attackSystem.banana.attackLoop:Disconnect()
                end
                attackSystem.banana.attackLoop = bananaAttackLoop()
                
                WindUI:Notify({
                    Title = "香蕉皮攻击已启用",
                    Content = string.format("射程: %d, 射速: %d", _G.BananaRange, _G.bananaSpeed),
                    Duration = 2,
                    Icon = "zap"
                })
            else
                if attackSystem.banana.attackLoop then
                    attackSystem.banana.attackLoop:Disconnect()
                    attackSystem.banana.attackLoop = nil
                end
                attackSystem.banana.active = false
                WindUI:Notify({
                    Title = "香蕉皮攻击已禁用",
                    Content = "香蕉皮攻击功能已停止",
                    Duration = 2,
                    Icon = "stop-circle"
                })
            end
        end
    })

    dartToggle = AttackTab:Toggle({
        Title = string.format("飞镖攻击 (射程: %d, 射速: %d)", _G.DartRange, _G.dartSpeed),
        Value = false,
        Callback = function(state)
            dartaura = state
            attackSystem.dart.enabled = state
            
            if state then
                if attackSystem.fullMap.active then
                    toggleFullMapAttack(false)
                    WindUI:Notify({
                        Title = "切换攻击模式",
                        Content = "已切换到飞镖攻击模式",
                        Duration = 2,
                        Icon = "info"
                    })
                end
                
                if attackSystem.dart.attackLoop then
                    attackSystem.dart.attackLoop:Disconnect()
                end
                attackSystem.dart.attackLoop = dartAttackLoop()
                
                WindUI:Notify({
                    Title = "飞镖攻击已启用",
                    Content = string.format("射程: %d, 射速: %d", _G.DartRange, _G.dartSpeed),
                    Duration = 2,
                    Icon = "target"
                })
            else
                if attackSystem.dart.attackLoop then
                    attackSystem.dart.attackLoop:Disconnect()
                    attackSystem.dart.attackLoop = nil
                end
                attackSystem.dart.active = false
                WindUI:Notify({
                    Title = "飞镖攻击已禁用",
                    Content = "飞镖攻击功能已停止",
                    Duration = 2,
                    Icon = "stop-circle"
                })
            end
        end
    })

    AttackTab:Section({Title = "全图攻击", Icon = "crosshair"})

    AttackTab:Toggle({
        Title = "全图攻击（如果没有攻击请丢掉背包的飞镖）",
        Desc = "启用高射速无冷却全图攻击，血量归零或攻击0.5秒自动切换",
        Value = false,
        Callback = toggleFullMapAttack
    })

    AttackTab:Button({
        Title = "立即攻击（测试切换逻辑）",
        Desc = "立即执行一次全图攻击，测试0.5秒自动切换功能",
        Icon = "zap",
        Callback = executeSingleFullMapAttack
    })

    AttackTab:Slider({
        Title = "攻击范围",
        Desc = "设置全图攻击的搜索范围",
        Value = {
            Min = 50,
            Max = 2000,
            Default = fullMapAttackRange
        },
        Callback = function(value)
            fullMapAttackRange = value
            WindUI:Notify({
                Title = "设置已更新",
                Content = "攻击范围: " .. value,
                Duration = 2,
                Icon = "maximize-2"
            })
        end
    })

    AttackTab:Slider({
        Title = "切换时间(秒)",
        Desc = "设置攻击同一目标的最大持续时间（0.1-2.0秒）",
        Value = {
            Min = 0.1,
            Max = 2.0,
            Default = 0.5
        },
        Callback = function(value)
            WindUI:Notify({
                Title = "切换时间已更新",
                Content = "攻击同一目标最大时间: " .. value .. "秒\n(需重启攻击生效)",
                Duration = 2,
                Icon = "clock"
            })
        end
    })

    AttackTab:Section({Title = "近战攻击", Icon = "fist"})

    AttackTab:Toggle({
        Title = "自动装备拳头",
        Value = false,
        Callback = function(state)
            autoFists = state
        end
    })

    local MainTab = Window:Tab({Title = "新功能", Icon = "dollar-sign"})

    MainTab:Toggle({
        Title = "自动ATM",
        Value = false,
        Callback = function(Value)
            autoATMCashCombo = Value
            if autoATMCashCombo then
                local function collectCash()
                    local player = game:GetService("Players").LocalPlayer
                    local cashSize = Vector3.new(2, 0.2499999850988388, 1)
                    for _, part in ipairs(workspace.Game.Entities.CashBundle:GetDescendants()) do
                        if part:IsA("BasePart") and part.Size == cashSize then
                            player.Character.HumanoidRootPart.CFrame = part.CFrame
                            task.wait()
                        end
                    end
                end
                coroutine.wrap(function()
                    while autoATMCashCombo and task.wait() do
                        local ATMsFolder = workspace:FindFirstChild("ATMs")
                        local localPlayer = game:GetService("Players").LocalPlayer
                        local hasActiveATM = false
                        if ATMsFolder and localPlayer.Character then
                            for _, atm in ipairs(ATMsFolder:GetChildren()) do
                                if atm:IsA("Model") then
                                    local hp = atm:GetAttribute("health")
                                    if hp ~= 0 then
                                        hasActiveATM = true
                                        for _, part in ipairs(atm:GetChildren()) do
                                            if part.Name == "Main" and part:IsA("BasePart") then
                                                localPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
                                                task.wait()
                                                atm:SetAttribute("health", 0)
                                                break
                                            end
                                        end
                                        task.wait()
                                    end
                                end
                            end
                        end
                        if hasActiveATM then
                            task.wait(1)
                        else
                            collectCash()
                            task.wait()
                        end
                    end
                end)()
            end
        end
    })

    local function autoSellItems()
        for i, v in next, v3item.inventory.items do
            local sellid = v.guid
            Signal.FireServer("equip", sellid)
            Signal.FireServer("sellItem", sellid)
            task.wait(0.1)
        end
    end

    MainTab:Section({Title = "售卖功能", Icon = "shopping-cart"})

    MainTab:Toggle({
        Title = "自动售卖全部物品",
        Value = false,
        Callback = function(Value)
            autoSellEnabled = Value
            if autoSellConnection then
                autoSellConnection:Disconnect()
                autoSellConnection = nil
            end
            if Value then
                autoSellConnection = RunService.Heartbeat:Connect(function()
                    local currentTime = tick()
                    if currentTime - lastBombardmentTime >= autoSellInterval then
                        pcall(function()
                            autoSellItems()
                        end)
                        lastBombardmentTime = currentTime
                    end
                end)
            end
        end
    })

    MainTab:Slider({
        Title = "自动售卖间隔",
        Desc = "设置自动售卖的间隔时间（秒）",
        Value = {
            Min = 1,
            Max = 30,
            Default = autoSellInterval
        },
        Callback = function(value)
            autoSellInterval = value
            WindUI:Notify({
                Title = "设置已更新",
                Content = "自动售卖间隔: " .. value .. "秒",
                Duration = 2,
                Icon = "clock"
            })
        end
    })

    local SettingsTab = Window:Tab({Title = "攻击设置", Icon = "settings"})

    SettingsTab:Section({Title = "远程攻击设置", Icon = "target"})

    SettingsTab:Slider({
        Title = "香蕉皮射程",
        Desc = "设置香蕉皮最大投射距离 (50-1000)",
        Value = {
            Min = 50,
            Max = 1000,
            Default = _G.BananaRange
        },
        Callback = function(value)
            _G.BananaRange = value
            updateBananaToggleTitle()
            WindUI:Notify({
                Title = "设置已更新",
                Content = "香蕉皮射程: " .. _G.BananaRange,
                Duration = 2,
                Icon = "ruler"
            })
        end
    })

    SettingsTab:Slider({
        Title = "飞镖射程",
        Desc = "设置飞镖最大投射距离 (20-1000)",
        Value = {
            Min = 20,
            Max = 1000,
            Default = _G.DartRange
        },
        Callback = function(value)
            _G.DartRange = value
            updateDartToggleTitle()
            WindUI:Notify({
                Title = "设置已更新",
                Content = "飞镖射程: " .. _G.DartRange,
                Duration = 2,
                Icon = "ruler"
            })
        end
    })

    SettingsTab:Slider({
        Title = "追踪敌人数量",
        Desc = "同时攻击的最大敌人数量",
        Value = {
            Min = 1,
            Max = 5,
            Default = _G.maxTargetCount
        },
        Callback = function(value)
            _G.maxTargetCount = value
            WindUI:Notify({
                Title = "设置已更新",
                Content = "追踪敌人数量: " .. _G.maxTargetCount,
                Duration = 2,
                Icon = "target"
            })
        end
    })

    SettingsTab:Section({Title = "射速设置", Icon = "zap"})

    SettingsTab:Slider({
        Title = "香蕉皮射速",
        Desc = "设置香蕉皮的投射速度 (200-9999)",
        Value = {
            Min = 200,
            Max = 9999,
            Default = _G.bananaSpeed
        },
        Callback = function(value)
            _G.bananaSpeed = math.clamp(value, 200, 9999)
            updateBananaToggleTitle()
            validateAndApplySpeedSettings()
            WindUI:Notify({
                Title = "射速设置已更新",
                Content = "香蕉皮射速: " .. _G.bananaSpeed,
                Duration = 2,
                Icon = "zap"
            })
            print("香蕉皮射速已设置为: " .. _G.bananaSpeed)
        end
    })

    SettingsTab:Slider({
        Title = "飞镖射速",
        Desc = "设置飞镖的投射速度 (300-9999)",
        Value = {
            Min = 300,
            Max = 9999,
            Default = _G.dartSpeed
        },
        Callback = function(value)
            _G.dartSpeed = math.clamp(value, 300, 9999)
            updateDartToggleTitle()
            validateAndApplySpeedSettings()
            WindUI:Notify({
                Title = "射速设置已更新",
                Content = "飞镖射速: " .. _G.dartSpeed,
                Duration = 2,
                Icon = "zap"
            })
            print("飞镖射速已设置为: " .. _G.dartSpeed)
        end
    })

    SettingsTab:Section({Title = "全图攻击设置", Icon = "globe"})

    SettingsTab:Toggle({
        Title = "自动购买飞镖",
        Desc = "飞镖数量为0时自动购买",
        Value = fullMapAutoBuyDarts,
        Callback = function(state)
            fullMapAutoBuyDarts = state
            WindUI:Notify({
                Title = "设置已更新",
                Content = "自动购买飞镖: " .. (state and "已启用" or "已禁用"),
                Duration = 2,
                Icon = state and "check" or "x"
            })
        end
    })

    SettingsTab:Toggle({
        Title = "攻击方式切换",
        Desc = "切换攻击方式: 背后攻击(关) / 旋转攻击(开)",
        Value = fullMapAttackMode == "circle",
        Callback = function(state)
            if state then
                fullMapAttackMode = "circle"
                WindUI:Notify({
                    Title = "攻击模式已切换",
                    Content = "已切换到旋转攻击模式",
                    Duration = 2,
                    Icon = "refresh-cw"
                })
            else
                fullMapAttackMode = "behind"
                WindUI:Notify({
                    Title = "攻击模式已切换",
                    Content = "已切换到背后攻击模式",
                    Duration = 2,
                    Icon = "user"
                })
            end
        end
    })

    SettingsTab:Slider({
        Title = "背后距离",
        Desc = "背后攻击模式的距离设置",
        Value = {
            Min = 0.5,
            Max = 5.0,
            Default = fullMapBehindDistance
        },
        Callback = function(value)
            fullMapBehindDistance = value
            WindUI:Notify({
                Title = "背后距离已更新",
                Content = "背后攻击距离: " .. value,
                Duration = 2,
                Icon = "ruler"
            })
        end
    })

    SettingsTab:Slider({
        Title = "旋转半径",
        Desc = "旋转攻击模式的半径（距离）",
        Value = {
            Min = 5,
            Max = 30,
            Default = fullMapCircleRadius
        },
        Callback = function(value)
            fullMapCircleRadius = value
            WindUI:Notify({
                Title = "旋转半径已更新",
                Content = "旋转半径: " .. value,
                Duration = 2,
                Icon = "circle"
            })
        end
    })

    SettingsTab:Slider({
        Title = "旋转速度",
        Desc = "旋转攻击模式的速度（角度/秒）",
        Value = {
            Min = 0.1,
            Max = 20.0,
            Default = fullMapCircleSpeed
        },
        Callback = function(value)
            fullMapCircleSpeed = value
            WindUI:Notify({
                Title = "旋转速度已更新",
                Content = "旋转速度: " .. value,
                Duration = 2,
                Icon = "zap"
            })
        end
    })

    SettingsTab:Slider({
        Title = "旋转速度倍率",
        Desc = "旋转速度的倍率调节",
        Value = {
            Min = 0.1,
            Max = 10.0,
            Default = fullMapCircleSpeedMultiplier
        },
        Callback = function(value)
            fullMapCircleSpeedMultiplier = value
            WindUI:Notify({
                Title = "旋转倍率已更新",
                Content = "旋转速度倍率: " .. value,
                Duration = 2,
                Icon = "refresh-cw"
            })
        end
    })

    SettingsTab:Button({
        Title = "手动购买飞镖",
        Desc = "立即尝试购买飞镖",
        Icon = "shopping-cart",
        Callback = function()
            WindUI:Notify({
                Title = "🔄 购买中",
                Content = "正在尝试购买飞镖...",
                Duration = 2,
                Icon = "loader"
            })
            
            local success = pcall(function()
                InvokeServer("attemptPurchase", "Ninja Star")
            end)
            
            task.wait(1)
            
            local ninjaStarData, ninjaStarGuid = findNinjaStar()
            
            if ninjaStarData and ninjaStarGuid then
                WindUI:Notify({
                    Title = "✅ 购买成功",
                    Content = "已获得飞镖，准备攻击！",
                    Duration = 2,
                    Icon = "check"
                })
            else
                WindUI:Notify({
                    Title = "❌ 购买失败",
                    Content = "无法购买飞镖，请检查游戏设置",
                    Duration = 2,
                    Icon = "x"
                })
            end
        end
    })

    SettingsTab:Button({
        Title = "检查飞镖库存",
        Desc = "查看当前飞镖数量",
        Icon = "package",
        Callback = function()
            local ninjaStarData, ninjaStarGuid = findNinjaStar()
            
            if ninjaStarData and ninjaStarGuid then
                WindUI:Notify({
                    Title = "✅ 飞镖状态",
                    Content = "飞镖库存正常，可以攻击",
                    Duration = 2,
                    Icon = "check"
                })
            else
                WindUI:Notify({
                    Title = "⚠️ 库存不足",
                    Content = "没有找到飞镖，请购买",
                    Duration = 2,
                    Icon = "alert-triangle"
                })
            end
        end
    })

    SettingsTab:Button({
        Title = "显示当前攻击模式",
        Desc = "查看当前的攻击方式设置",
        Icon = "eye",
        Callback = function()
            local modeText = fullMapAttackMode == "circle" and "旋转攻击模式" or "背后攻击模式"
            local isEnabled = fullMapAttackMode == "circle" and "开启" or "关闭"
            WindUI:Notify({
                Title = "当前攻击模式",
                Content = string.format("模式: %s\n开关状态: %s\n背后距离: %.1f\n旋转半径: %.1f\n自动购买: %s\n切换条件: 血量优先或0.5秒", 
                    modeText, isEnabled, fullMapBehindDistance, fullMapCircleRadius, 
                    fullMapAutoBuyDarts and "开启" or "关闭"),
                Duration = 3,
                Icon = "info"
            })
        end
    })

    SettingsTab:Section({Title = "高级设置", Icon = "settings"})

    SettingsTab:Toggle({
        Title = "增强预判算法",
        Desc = "使用更精确的目标移动预判",
        Value = _G.useEnhancedPrediction,
        Callback = function(state)
            _G.useEnhancedPrediction = state
            WindUI:Notify({
                Title = "设置已更新",
                Content = "增强预判: " .. (state and "开启" or "关闭"),
                Duration = 1,
                Icon = "crosshair"
            })
        end
    })

    SettingsTab:Slider({
        Title = "攻击优先级",
        Desc = "设置攻击目标的选择优先级 (0.5-2.0)",
        Value = {
            Min = 0.5,
            Max = 2.0,
            Default = _G.attackPriority
        },
        Callback = function(value)
            _G.attackPriority = value
            WindUI:Notify({
                Title = "设置已更新",
                Content = "攻击优先级: " .. _G.attackPriority,
                Duration = 1,
                Icon = "target"
            })
        end
    })

    SettingsTab:Section({Title = "调试功能", Icon = "settings"})

    SettingsTab:Button({
        Title = "测试全图攻击",
        Desc = "测试全图攻击功能是否正常（带飞镖检测）",
        Icon = "test-tube",
        Callback = function()
            local targetCount = #getFullMapTargets()
            
            local ninjaStarData, ninjaStarGuid = findNinjaStar()
            local dartStatus = ninjaStarData and "有飞镖" or "无飞镖"
            
            WindUI:Notify({
                Title = "全图攻击测试",
                Content = string.format("目标数量: %d\n射速: %d\n飞镖状态: %s\n攻击模式: %s\n切换逻辑: 血量优先/0.5秒", 
                    targetCount, _G.dartSpeed, dartStatus, 
                    fullMapAttackMode == "circle" and "旋转攻击" or "背后攻击"),
                Duration = 3,
                Icon = "crosshair"
            })
            
            if targetCount > 0 then
                local targets = getFullMapTargets()
                local target = targets[1]
                print("测试攻击目标:", target.player.Name)
                
                local startTime = tick()
                local success = executeMultiDartAttackFullMap(target)
                local endTime = tick()
                
                WindUI:Notify({
                    Title = "攻击测试完成",
                    Content = string.format("结果: %s\n时间: %.3f秒\n切换原因: %s", 
                        success and "成功" or "失败", endTime - startTime,
                        target.humanoid.Health <= 0 and "目标死亡" or "时间到达"),
                    Duration = 3,
                    Icon = success and "check" or "x"
                })
            end
        end
    })

    SettingsTab:Button({
        Title = "刷新UI显示",
        Desc = "强制更新所有UI元素的显示值",
        Icon = "refresh-cw",
        Callback = refreshAllAttackUI
    })

    SettingsTab:Button({
        Title = "重置为默认设置",
        Desc = "将所有攻击设置重置为默认值",
        Icon = "rotate-ccw",
        Callback = function()
            _G.BananaRange = 50
            _G.DartRange = 20
            _G.bananaSpeed = 1500
            _G.dartSpeed = 2000
            _G.bananaCooldown = 0
            _G.dartCooldown = 0
            _G.bananaPredictDistance = 2.0
            _G.dartPredictDistance = 1.2
            _G.maxTargetCount = 3
            _G.attackPriority = 1.0
            _G.useEnhancedPrediction = true
            
            refreshAllAttackUI()
            
            WindUI:Notify({
                Title = "设置已重置",
                Content = "所有攻击设置已重置为默认值\n香蕉皮射速: 1500\n飞镖射速: 2000\n飞镖检测: 启用\n切换逻辑: 血量优先/0.5秒",
                Duration = 3,
                Icon = "check"
            })
            
            print("射速已重置为默认值")
        end
    })

    local SurvivalTab = Window:Tab({Title = "生存功能", Icon = "shield"})

    SurvivalTab:Section({Title = "自动保护", Icon = "shield"})

    local AutoArmor = false
    local armorConnection = nil
    SurvivalTab:Toggle({
        Title = "自动穿甲",
        Value = false,
        Callback = function(Value)
            AutoArmor = Value
            if Value then
                if armorConnection then
                    armorConnection:Disconnect()
                end
                
                armorConnection = RunService.Heartbeat:Connect(function()
                    if not AutoArmor then
                        armorConnection:Disconnect()
                        armorConnection = nil
                        return
                    end
                    
                    pcall(function()
                        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.Health > 35 then
                            local items = inventory.items
                            local hasLightVest = false
                            for i, v in next, items do
                                if v.name == "Light Vest" then
                                    hasLightVest = true
                                    local light = v.guid
                                    local armor = LocalPlayer:GetAttribute('armor')
                                    if armor == nil or armor <= 0 then
                                        FireServer("equip", light)
                                        FireServer("useConsumable", light)
                                        FireServer("removeItem", light)
                                    end
                                    break
                                end
                            end
                            
                            if not hasLightVest then
                                InvokeServer("attemptPurchase", "Light Vest")
                            end
                        end
                    end)
                end)
            else
                if armorConnection then
                    armorConnection:Disconnect()
                    armorConnection = nil
                end
            end
        end
    })

    local autokz = false
    local maskThread = nil
    SurvivalTab:Toggle({
        Title = "自动面具",
        Value = false,
        Callback = function(state)
            autokz = state
            if autokz then
                maskThread = task.spawn(function()
                    while autokz and task.wait(1) do
                        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                        local Mask = character:FindFirstChild("Hockey Mask")
                        local items = inventory.items
                        
                        if not Mask then
                            InvokeServer("attemptPurchase", "Hockey Mask")
                            for i, v in next, items do
                                if v.name == "Hockey Mask" then
                                    local sugid = v.guid
                                    if not Mask then
                                        FireServer("equip", sugid)
                                        FireServer("wearMask", sugid)
                                    end
                                    break
                                end
                            end
                        end
                    end
                end)
            else
                if maskThread then
                    task.cancel(maskThread)
                    maskThread = nil
                end
            end
        end
    })

    local healThread = nil
    SurvivalTab:Toggle({
        Title = "自动回血",
        Value = false,
        Callback = function(Value)
            if healThread then
                healThread:Disconnect()
                healThread = nil
            end
            
            if Value then
                healThread = RunService.Heartbeat:Connect(function()
                    InvokeServer("attemptPurchase", 'Bandage')
                    for _, v in next, inventory.items do
                        if v.name == 'Bandage' then
                            local bande = v.guid
                            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                            local Humanoid = Character:WaitForChild('Humanoid')
                            if Humanoid.Health >= 5 and Humanoid.Health < Humanoid.MaxHealth then
                                FireServer("equip", bande)
                                FireServer("useConsumable", bande)
                                FireServer("removeItem", bande)
                            end
                            break
                        end
                    end
                end)
            end
        end
    })

    SurvivalTab:Section({Title = "防御功能", Icon = "shield-check"})

    local AutoKnockReset = false
    SurvivalTab:Toggle({
        Title = "防倒地",
        Value = false,
        Callback = function(Value)
            AutoKnockReset = Value
            if Value then
                task.spawn(function()
                    while AutoKnockReset do
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            melee.Set(LocalPlayer, "knocked", false)
                            melee.Replicate("knocked")
                        end
                        task.wait()
                    end
                end)
            end
        end
    })

    SurvivalTab:Toggle({
        Title = "防虚空",
        Value = false,
        Callback = function(Value)
            task.spawn(function()
                while Value and task.wait(0.1) do
                    local character = LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        local position = humanoidRootPart.Position
                        if position.Y < -200 then
                            humanoidRootPart.CFrame = CFrame.new(1339.9090576171875, 6.044891357421875, -660.3264770507812)
                        end
                    end
                end
            end)
        end
    })

    SurvivalTab:Toggle({
        Title = "防甩飞",
        Value = false,
        Callback = function(Value)
            task.spawn(function()
                while Value and task.wait(0.1) do
                    local character = LocalPlayer.Character
                    if character then
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    })

    local deathDetectionConnection = nil
    local function setupDeathDetection()
        if deathDetectionConnection then
            deathDetectionConnection:Disconnect()
        end
        
        deathDetectionConnection = LocalPlayer.CharacterAdded:Connect(function(newCharacter)
            print("角色重新生成，重置攻击系统...")
            
            task.wait(0.5)
            
            Character = newCharacter
            HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
            Humanoid = newCharacter:WaitForChild("Humanoid")
            
            if fullMapAttackEnabled and fullMapAttackConnection then
                print("重新启用全图攻击...")
                WindUI:Notify({
                    Title = "系统恢复",
                    Content = "角色重生，重新启用攻击系统",
                    Duration = 3,
                    Icon = "refresh-cw"
                })
                
                fullMapAttackConnection:Disconnect()
                fullMapAttackConnection = fullMapAttackLoop()
            end
            
            if bananaaura then
                WindUI:Notify({
                    Title = "香蕉皮攻击恢复",
                    Content = "已重新启用香蕉皮攻击",
                    Duration = 2,
                    Icon = "check"
                })
            end
            
            if dartaura then
                WindUI:Notify({
                    Title = "飞镖攻击恢复",
                    Content = "已重新启用飞镖攻击",
                    Duration = 2,
                    Icon = "check"
                })
            end
        end)
    end
    
    setupDeathDetection()
    
    local function monitorDeath()
        local function onCharacterAdded(character)
            local humanoid = character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                print("角色死亡，暂停所有攻击功能...")
                
                if fullMapAttackEnabled and fullMapAttackConnection then
                    print("暂停全图攻击...")
                    WindUI:Notify({
                        Title = "攻击暂停",
                        Content = "角色死亡，攻击功能已暂停",
                        Duration = 3,
                        Icon = "pause"
                    })
                end
                
                bananaaura = false
                dartaura = false
                
                if bananaToggle then
                    bananaToggle:SetValue(false)
                end
                
                if dartToggle then
                    dartToggle:SetValue(false)
                end
            end)
        end
        
        if LocalPlayer.Character then
            onCharacterAdded(LocalPlayer.Character)
        end
        LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    end
    
    monitorDeath()
    
    task.wait(1)
    WindUI:Notify({
        Title = "脚本加载完成",
        Content = "✓ 高射速无冷却系统已启用\n" ..
                 "✓ 全图攻击功能就绪\n" ..
                 "✓ 远程攻击系统已修复\n" +
                 "✓ 智能飞镖检测已集成\n" +
                 "✓ 自动购买系统正常\n" +
                 "✓ 目标锁定功能正常\n" +
                 "✓ 双重条件切换: 血量优先/0.5秒\n" +
                 "✓ 所有功能已修复完成",
        Duration = 5,
        Icon = "check"
    })

    print("脚本加载完成")
    print("高射速无冷却系统: 已启用")
    print("香蕉皮射速: ".._G.bananaSpeed)
    print("飞镖射速: ".._G.dartSpeed)
    print("远程攻击系统: 已修复")
    print("全图攻击: 就绪")
    print("攻击方式: "..(fullMapAttackMode == "circle" and "旋转攻击" or "背后攻击"))
    print("自动购买飞镖: "..(fullMapAutoBuyDarts and "启用" or "禁用"))
    print("切换条件: 血量优先或攻击0.5秒自动切换")
    print("================================================")
    
    task.spawn(function()
        while task.wait(5) do
            print("系统状态:")
            print("  - 香蕉皮攻击: "..(attackSystem.banana.active and "运行中" or "停止"))
            print("  - 飞镖攻击: "..(attackSystem.dart.active and "运行中" or "停止"))
            print("  - 全图攻击: "..(attackSystem.fullMap.active and "运行中" or "停止"))
            print("  - 角色状态: "..(Humanoid and Humanoid.Health > 0 and "存活" or "死亡"))
        end
    end)
end

repeat
    task.wait()
until Confirmed
