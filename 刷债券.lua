if _G.TX_Bond_Running then return end
_G.TX_Bond_Running = true

local CoreGui = game:GetService("StarterGui")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local TS = game:GetService("TeleportService")
local DEAD_RAILS_PLACE_ID = 116495829188952

CoreGui:SetCore("SendNotification",{Title="TX Script",Text="刷债券V25.0",Duration=5})

-- 锁定债券UI位置
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local bondInfo = player.PlayerGui:WaitForChild("BondGui", 5):WaitForChild("BondInfo", 2)
            bondInfo.Position = UDim2.new(0.5, 0, 0.75, 0)
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
    return (hrp.Position - primaryPart.Position).Magnitude < 32
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
            if partCount > 98 then return true end
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
    task.wait(0.86)
    return (hrp.Position - targetPos).Magnitude < 46
end

local function createPublicRoom()
    local CreateParty = RS.Shared.Universe.Network.RemoteEvent:FindFirstChild("CreateParty")
    if not CreateParty then return false end
    CreateParty:FireServer({isPrivate=false, maxMembers=1, trainId="default", gameMode="Normal"})
    return true
end

local function attemptStartGame(zones)
    setupPartyZoneDetection()
    
    -- 收集所有空闲区域
    local availableZones = {}
    for _, zone in ipairs(zones) do
        if not isZoneOccupied(zone) then table.insert(availableZones, zone) end
    end
    if #availableZones == 0 then
        task.wait(3)
        return false
    end
    
    -- 随机打乱顺序
    for i = #availableZones, 2, -1 do
        local j = math.random(1, i)
        availableZones[i], availableZones[j] = availableZones[j], availableZones[i]
    end
    
    -- 循环遍历每个区域
    local zoneIndex = 1
    while true do
        local targetZone = availableZones[zoneIndex]
        if not targetZone or not targetZone.Parent then
            -- 区域被移除，重新收集
            availableZones = {}
            for _, zone in ipairs(zones) do
                if zone.Parent and not isZoneOccupied(zone) then table.insert(availableZones, zone) end
            end
            if #availableZones == 0 then
                task.wait(3)
                return false
            end
            zoneIndex = 1
            targetZone = availableZones[1]
        end
        
        -- 传送到目标区域
        if not teleportToZone(targetZone) then
            zoneIndex = zoneIndex + 1
            if zoneIndex > #availableZones then zoneIndex = 1 end
            task.wait(2)
            continue
        end
        
        -- 等待到达
        local waitStart = tick()
        local arrived = false
        while tick() - waitStart < 19 do
            task.wait(0.476)
            arrived = isInZone(targetZone)
            if arrived then break end
        end
        
        if not arrived then
            zoneIndex = zoneIndex + 1
            if zoneIndex > #availableZones then zoneIndex = 1 end
            task.wait(2)
            continue
        end
        
        -- 发送创建房间包
        createPublicRoom()
        
        -- 等待检测
        partyZoneReservedDetected = false
        local detected = false
        for i = 1, 78 do
            task.wait(0.422)
            if partyZoneReservedDetected or isGameZoneExists() then
                detected = true
                break
            end
        end
        
        if detected then
            return true
        end
        
        -- 没检测到，等待3秒后传送到下一个区域
        task.wait(3)
        zoneIndex = zoneIndex + 1
        if zoneIndex > #availableZones then zoneIndex = 1 end
    end
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
    task.wait(0.698)
    while true do
        pcall(function() EndDecision:FireServer(false) end)
        task.wait(0.274)
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
            world:set(char, Sack, {contents={}, maxContents=99900})
        end
        for id = 1, 28500, 1690 do
            local batchEnd = math.min(id + 1689, 31500)
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
        task.wait(0.089)
        StoreRemote:FireServer()
        ActionableEvent:FireServer(sr)
        collectedCount = collectedCount + 1
        task.wait(0.087)
    end
    return collectedCount
end

local function startFarmingBonds()
    if Workspace:FindFirstChild("PartyZones") then return false end
    local world, comps, replicator, Remotes, Event
    local loadSuccess = false
    local retryCount = 0
    while not loadSuccess and retryCount < 8600 do
        loadSuccess = pcall(function()
            world = require(RS.Shared.Universe.ECS.world)
            comps = require(RS.Shared.Universe.ECS.components)
            replicator = require(RS.Client.Universe.Replication.clientReplicator)
            Remotes = require(RS.Shared.Universe.Remotes)
            Event = RS.Shared.Universe.Network.RemoteEvent.Actionable
        end)
        if not loadSuccess then retryCount = retryCount + 1 task.wait(0.518) end
        if Workspace:FindFirstChild("PartyZones") then return false end
    end
    if not loadSuccess then return false end
    
    local ClientStateResource = comps.ClientStateResource
    local initSuccess = false
    for initRetry = 1, 1580 do
        local ok, res = pcall(function() return world:get_resource(ClientStateResource) end)
        if ok and res then initSuccess = true break end
        task.wait(0.516)
        if Workspace:FindFirstChild("PartyZones") then return false end
    end
    if not initSuccess then return false end
    
    local StoreRemote = Remotes.Store
    local ActionableEvent = Event
    local allBondList = {}
    local startTime = tick()
    
    while tick() - startTime < 28 do
        if Workspace:FindFirstChild("PartyZones") then return false end
        local newBonds = scanForBonds(world, comps, replicator)
        for _, bond in ipairs(newBonds) do
            if not isDuplicate(bond.id, allBondList) then table.insert(allBondList, bond) end
        end
        if #allBondList > 0 then break end
        task.wait(0.286)
    end
    
    if #allBondList == 0 then
        CoreGui:SetCore("SendNotification",{Title="TX Script", Text="未发现债券，强制加入死亡轨道", Duration=5})
        forceJoinDeadRails()
        return true
    end
    
    processBonds(allBondList, StoreRemote, ActionableEvent)
    
    -- 第二轮扫描遗漏
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
        -- 第三轮扫描
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
    
    CoreGui:SetCore("SendNotification",{Title="TX Script", Text="债券处理完毕，强制加入死亡轨道", Duration=5})
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
