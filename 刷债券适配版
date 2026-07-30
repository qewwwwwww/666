if _G.TX_Bond_Running then return end
_G.TX_Bond_Running = true

local CoreGui = game:GetService("StarterGui")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local TS = game:GetService("TeleportService")
local DEAD_RAILS_PLACE_ID = 116495829188952

-- 安全通知函数
local function safeNotify(title, text)
    local success = pcall(function()
        CoreGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5
        })
    end)
    if not success then
        for i = 1, 5 do
            task.wait(1)
            success = pcall(function()
                CoreGui:SetCore("SendNotification", {
                    Title = title,
                    Text = text,
                    Duration = 5
                })
            end)
            if success then break end
        end
    end
end

safeNotify("TX Script", "刷债券V25.0")

-- 锁定债券UI位置
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local bondInfo = player.PlayerGui:WaitForChild("BondGui", 5):WaitForChild("BondInfo", 2)
            bondInfo.Position = UDim2.new(0.5, 0, 0.72, 0)
            bondInfo.AnchorPoint = Vector2.new(0.5, 0.5)
        end)
    end
end)

local function forceJoinDeadRails()
    pcall(function()
        player:Kick("正在传送至死亡轨道，如果卡在这就去注入器设置把Verify Teleports关闭")
    end)
    task.wait(0.3)
    pcall(function()
        TS:Teleport(DEAD_RAILS_PLACE_ID, player)
    end)
end

local partyZoneReservedDetected = false
local partyZoneReservedConnection = nil

local function setupPartyZoneDetection()
    partyZoneReservedDetected = false
    local PartyZoneReserved = RS.Shared.Universe.Network.RemoteEvent:FindFirstChild("PartyZoneReserved")
    if PartyZoneReserved then
        if partyZoneReservedConnection then
            partyZoneReservedConnection:Disconnect()
        end
        partyZoneReservedConnection = PartyZoneReserved.OnClientEvent:Connect(function(...)
            local args = {...}
            if type(args[1]) == "number" and type(args[2]) == "string" then
                partyZoneReservedDetected = true
            end
        end)
    end
end

local function isZoneOccupied(zone)
    if not zone then return true end
    local primaryPart = zone.PrimaryPart or zone:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return true end
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            if otherChar then
                local otherRoot = otherChar:FindFirstChild("HumanoidRootPart") or otherChar.PrimaryPart
                if otherRoot then
                    local dist = (otherRoot.Position - primaryPart.Position).Magnitude
                    if dist < math.max(primaryPart.Size.X, primaryPart.Size.Z) / 2 + 5 then return true end
                end
            end
        end
    end
    return false
end

local function isInZone(zone)
    if not zone then return false end
    local primaryPart = zone.PrimaryPart or zone:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return false end
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not hrp then return false end
    return (hrp.Position - primaryPart.Position).Magnitude < 37
end

local function isGameZoneExists()
    local indicators = {"Game","Map","Train","World","Level","Environment","Terrain"}
    for _, name in ipairs(indicators) do
        if Workspace:FindFirstChild(name) then return true end
    end
    local partCount = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            partCount = partCount + 1
            if partCount > 108 then return true end
        end
    end
    return false
end

local function teleportToZone(zone)
    if not zone then return false end
    local primaryPart = zone.PrimaryPart or zone:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then return false end
    local targetPos = primaryPart.Position + Vector3.new(0, 3, 0)
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
    if not hrp then return false end
    hrp.CFrame = CFrame.new(targetPos)
    task.wait(0.84)
    return (hrp.Position - targetPos).Magnitude < 47
end

local function createPublicRoom()
    local CreateParty = RS.Shared.Universe.Network.RemoteEvent:FindFirstChild("CreateParty")
    if not CreateParty then return false end
    CreateParty:FireServer({isPrivate=false, maxMembers=1, trainId="default", gameMode="Normal"})
    return true
end

-- 开局逻辑：不断传送不同区域创建房间，直到成功进入游戏
local function attemptStartGame(zones)
    setupPartyZoneDetection()
    
    local attemptedIndexes = {}
    local maxAttempts = #zones * 3 + 10
    
    for attempt = 1, maxAttempts do
        if #attemptedIndexes >= #zones then
            attemptedIndexes = {}
        end
        
        -- 找一个没试过的区域
        local targetIndex
        repeat
            targetIndex = math.random(1, #zones)
        until not table.find(attemptedIndexes, targetIndex)
        
        table.insert(attemptedIndexes, targetIndex)
        local targetZone = zones[targetIndex]
        
        if not targetZone or not targetZone.Parent then
            continue
        end
        
        -- 传送到目标区域
        if not teleportToZone(targetZone) then
            task.wait(1.8)
            continue
        end
        
        -- 等待到达
        local arriveStart = tick()
        local hasArrived = false
        while tick() - arriveStart < 21 do
            task.wait(0.39)
            hasArrived = isInZone(targetZone)
            if hasArrived then break end
        end
        
        if not hasArrived then
            task.wait(1.8)
            continue
        end
        
        -- 发送创建房间包
        createPublicRoom()
        task.wait(0.62)
        
        -- 检查是否成功进入游戏
        if isGameZoneExists() then
            return true
        end
        
        task.wait(0.5)
    end
    
    return false
end

local function killSelf()
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then humanoid.Health = 0 return true end
    return false
end

local function startEndDecisionLoop()
    local EndDecision = RS.Remotes:FindFirstChild("EndDecision")
    if not EndDecision then return false end
    killSelf()
    task.wait(0.692)
    while true do
        pcall(function() EndDecision:FireServer(false) end)
        task.wait(0.277)
    end
end

local function isDuplicate(id, foundList)
    for _, v in ipairs(foundList) do
        if v == id then return true end
    end
    return false
end

local function scanForBonds(world, comps, replicator)
    local Storable = comps.Storable
    local ObjectId = comps.ObjectId
    local Sack = comps.Sack
    local bondList = {}
    local char = world:get_resource(comps.ClientStateResource).localCharacter
    if char then
        if not world:has(char, Sack) then
            world:add(char, Sack)
            world:set(char, Sack, {contents={}, maxContents=99500})
        end
        for id = 1, 38000, 1450 do
            local batchEnd = math.min(id + 1449, 42000)
            for j = id, batchEnd do
                if world:has(j, Storable) and world:get(j, ObjectId) == "bond" then
                    local sr = replicator:get_server_entity(j)
                    if sr and sr ~= j then
                        bondList[#bondList + 1] = {id=j, serverEntity=sr}
                    end
                end
            end
            task.wait()
        end
    end
    return bondList
end

local function processBonds(bondList, StoreRemote, ActionableEvent)
    local collectedCount = 0
    for _, bondData in ipairs(bondList) do
        if Workspace:FindFirstChild("PartyZones") then return collectedCount end
        local sr = bondData.serverEntity
        StoreRemote:FireServer(sr)
        task.wait(0.075)
        StoreRemote:FireServer()
        ActionableEvent:FireServer(sr)
        collectedCount = collectedCount + 1
        task.wait(0.065)
    end
    return collectedCount
end

local function startFarmingBonds()
    if Workspace:FindFirstChild("PartyZones") then return false end
    local world, comps, replicator, Remotes, Event
    local loadSuccess = false
    local retryCount = 0
    while not loadSuccess and retryCount < 9800 do
        loadSuccess = pcall(function()
            world = require(RS.Shared.Universe.ECS.world)
            comps = require(RS.Shared.Universe.ECS.components)
            replicator = require(RS.Client.Universe.Replication.clientReplicator)
            Remotes = require(RS.Shared.Universe.Remotes)
            Event = RS.Shared.Universe.Network.RemoteEvent.Actionable
        end)
        if not loadSuccess then retryCount = retryCount + 1 task.wait(0.475) end
        if Workspace:FindFirstChild("PartyZones") then return false end
    end
    if not loadSuccess then return false end
    
    local ClientStateResource = comps.ClientStateResource
    local initSuccess = false
    for initRetry = 1, 2100 do
        local ok, res = pcall(function() return world:get_resource(ClientStateResource) end)
        if ok and res then initSuccess = true break end
        task.wait(0.465)
        if Workspace:FindFirstChild("PartyZones") then return false end
    end
    if not initSuccess then return false end
    
    local StoreRemote = Remotes.Store
    local ActionableEvent = Event
    local allBondList = {}
    local startTime = tick()
    
    while tick() - startTime < 23 do
        if Workspace:FindFirstChild("PartyZones") then return false end
        local newBonds = scanForBonds(world, comps, replicator)
        for _, bond in ipairs(newBonds) do
            if not isDuplicate(bond.id, allBondList) then table.insert(allBondList, bond) end
        end
        if #allBondList > 120 then break end
        task.wait(0.215)
    end
    
    if #allBondList == 0 then
        safeNotify("TX Script", "未发现债券，强制加入死亡轨道")
        forceJoinDeadRails()
        return true
    end
    
    processBonds(allBondList, StoreRemote, ActionableEvent)
    
    local secondList = scanForBonds(world, comps, replicator)
    local missed = {}
    for _, bond in ipairs(secondList) do
        if not isDuplicate(bond.id, allBondList) then
            table.insert(allBondList, bond)
            table.insert(missed, bond)
        end
    end
    if #missed > 0 then
        processBonds(missed, StoreRemote, ActionableEvent)
        local thirdList = scanForBonds(world, comps, replicator)
        local finalMissed = {}
        for _, bond in ipairs(thirdList) do
            if not isDuplicate(bond.id, allBondList) then
                table.insert(allBondList, bond)
                table.insert(finalMissed, bond)
            end
        end
        if #finalMissed > 0 then
            processBonds(finalMissed, StoreRemote, ActionableEvent)
        end
    end
    
    safeNotify("TX Script", "债券处理完毕，强制加入死亡轨道")
    forceJoinDeadRails()
    return true
end

local partyZonesFolder = Workspace:FindFirstChild("PartyZones")
if not partyZonesFolder then
    local needSuicide = startFarmingBonds()
    if needSuicide then task.wait(1) startEndDecisionLoop() end
else
    local zones = {}
    for _, zone in ipairs(partyZonesFolder:GetChildren()) do
        if zone:IsA("Model") then table.insert(zones, zone) end
    end
    if #zones == 0 then
        local needSuicide = startFarmingBonds()
        if needSuicide then task.wait(1) startEndDecisionLoop() end
        return
    end
    local startSuccess = attemptStartGame(zones)
    if startSuccess then
        local needSuicide = startFarmingBonds()
        if needSuicide then task.wait(1) startEndDecisionLoop() end
    end
end
