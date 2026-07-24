local player = game.Players.LocalPlayer
local Players = game.Players
local Workspace = workspace
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

-- 极简UI通知
local function notify(title, text)
    pcall(function()
        CoreGui:SetCore("SendNotification", {Title = title, Text = text, Duration = 2})
    end)
end

-- 检测区域是否被占用
local function isZoneOccupied(zone)
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
    local dist = (hrp.Position - primaryPart.Position).Magnitude
    return dist < 30
end

local function isGameZoneExists()
    local indicators = {
        Workspace:FindFirstChild("Game"), Workspace:FindFirstChild("Map"), Workspace:FindFirstChild("Train"),
        Workspace:FindFirstChild("World"), Workspace:FindFirstChild("Level"), Workspace:FindFirstChild("Environment"),
        Workspace:FindFirstChild("Terrain"),
    }
    for _, indicator in ipairs(indicators) do if indicator then return true end end
    local partCount = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            partCount = partCount + 1
            if partCount > 88 then return true end
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
    task.wait(0.592)
    local dist = (hrp.Position - targetPos).Magnitude
    return dist < 33
end

local function createPublicRoomTwice()
    local CreateParty = RS.Shared.Universe.Network.RemoteEvent:FindFirstChild("CreateParty")
    if not CreateParty then return false end
    CreateParty:FireServer({isPrivate = false, maxMembers = 1, trainId = "default", gameMode = "Normal"})
    task.wait(0.995)
    CreateParty:FireServer({isPrivate = false, maxMembers = 1, trainId = "default", gameMode = "Normal"})
    return true
end

local function attemptStartGame(zones)
    local maxAttempts = 12
    local attemptCount = 0
    while attemptCount < maxAttempts do
        attemptCount = attemptCount + 1
        local targetZone = nil
        for _, zone in ipairs(zones) do
            if not isZoneOccupied(zone) then targetZone = zone break end
        end
        if not targetZone then task.wait(5) continue end
        local teleportSuccess = teleportToZone(targetZone)
        if not teleportSuccess then task.wait(2) continue end
        task.wait(0.435)
        local arrived = isInZone(targetZone)
        if not arrived then task.wait(2) continue end
        createPublicRoomTwice()
        local gameCreated = false
        for i = 1, 46 do
            task.wait(0.404)
            if isGameZoneExists() then gameCreated = true break end
        end
        if gameCreated then return true end
        task.wait(1)
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
    task.wait(0.652)
    while true do
        pcall(function() EndDecision:FireServer(false) end)
        task.wait(0.238)
    end
end

local function isDuplicate(id, foundList)
    for _, v in ipairs(foundList) do if v == id then return true end end
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
            world:set(char, Sack, {contents = {}, maxContents = 99000})
        end
        for id = 1, 28000, 1580 do
            local batchEnd = math.min(id + 1579, 40000)
            for j = id, batchEnd do
                if world:has(j, Storable) and world:get(j, ObjectId) == "bond" then
                    local sr = replicator:get_server_entity(j)
                    if sr and sr ~= j then bondList[#bondList + 1] = {id = j, serverEntity = sr} end
                end
            end
            task.wait()
        end
    end
    return bondList
end

local function processBonds(bondList, StoreRemote, ActionableEvent)
    local baggedCount = 0
    local collectedCount = 0
    for index, bondData in ipairs(bondList) do
        if Workspace:FindFirstChild("PartyZones") then return baggedCount, collectedCount end
        local j = bondData.id
        local sr = bondData.serverEntity
        StoreRemote:FireServer(sr)
        baggedCount = baggedCount + 1
        task.wait(0.073)
        StoreRemote:FireServer()
        ActionableEvent:FireServer(sr)
        collectedCount = collectedCount + 1
        task.wait(0.072)
    end
    return baggedCount, collectedCount
end

local function startFarmingBonds()
    if Workspace:FindFirstChild("PartyZones") then return false end
    local world, comps, replicator, Remotes, Event
    local loadSuccess = false
    local retryCount = 0
    while not loadSuccess and retryCount < 6400 do
        loadSuccess = pcall(function()
            world = require(RS.Shared.Universe.ECS.world)
            comps = require(RS.Shared.Universe.ECS.components)
            replicator = require(RS.Client.Universe.Replication.clientReplicator)
            Remotes = require(RS.Shared.Universe.Remotes)
            Event = RS.Shared.Universe.Network.RemoteEvent.Actionable
        end)
        if not loadSuccess then
            retryCount = retryCount + 1
            task.wait(0.496)
        end
        if Workspace:FindFirstChild("PartyZones") then return false end
    end
    if not loadSuccess then return false end
    local ClientStateResource = comps.ClientStateResource
    local maxInitRetries = 1300
    local initRetry = 0
    local initSuccess = false
    while not initSuccess and initRetry < maxInitRetries do
        initRetry = initRetry + 1
        local ok, res = pcall(function() return world:get_resource(ClientStateResource) end)
        if ok and res then initSuccess = true break end
        task.wait(0.498)
        if Workspace:FindFirstChild("PartyZones") then return false end
    end
    if not initSuccess then return false end
    local Storable = comps.Storable
    local ObjectId = comps.ObjectId
    local Sack = comps.Sack
    local StoreRemote = Remotes.Store
    local ActionableEvent = Event
    local startTime = tick()
    local scanFound = false
    local allBondList = {}
    while tick() - startTime < 15 do
        if Workspace:FindFirstChild("PartyZones") then return false end
        local newBonds = scanForBonds(world, comps, replicator)
        for _, bond in ipairs(newBonds) do
            if not isDuplicate(bond.id, allBondList) then allBondList[#allBondList + 1] = bond end
        end
        if #allBondList > 0 then scanFound = true break end
        task.wait(0.258)
    end
    if not scanFound then
        notify("TX Script", "未发现债券，跳过收集")
        return true
    end
    local totalBagged = 0
    local totalCollected = 0
    local bagged, collected = processBonds(allBondList, StoreRemote, ActionableEvent)
    totalBagged = totalBagged + bagged
    totalCollected = totalCollected + collected
    local secondBondList = scanForBonds(world, comps, replicator)
    local missedBonds = {}
    for _, bond in ipairs(secondBondList) do
        if not isDuplicate(bond.id, allBondList) then missedBonds[#missedBonds + 1] = bond end
    end
    if #missedBonds > 0 then
        for _, bond in ipairs(missedBonds) do allBondList[#allBondList + 1] = bond end
        local missedBagged, missedCollected = processBonds(missedBonds, StoreRemote, ActionableEvent)
        totalBagged = totalBagged + missedBagged
        totalCollected = totalCollected + missedCollected
        local thirdBondList = scanForBonds(world, comps, replicator)
        local finalMissed = {}
        for _, bond in ipairs(thirdBondList) do
            if not isDuplicate(bond.id, allBondList) then finalMissed[#finalMissed + 1] = bond end
        end
        if #finalMissed > 0 then
            for _, bond in ipairs(finalMissed) do allBondList[#allBondList + 1] = bond end
            local finalBagged, finalCollected = processBonds(finalMissed, StoreRemote, ActionableEvent)
            totalBagged = totalBagged + finalBagged
            totalCollected = totalCollected + finalCollected
        end
    end
    notify("TX Script", "债券已收集完成，自动开启下一局")
    return true
end

-- 主逻辑执行
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

-- 全注入器自启注册逻辑
local function registerAutoExecute()
    local success = false
    pcall(function()
        if syn and syn.queue_on_teleport then syn.queue_on_teleport(debug.getinfo(1).source) success = true end
    end)
    pcall(function()
        if queue_on_teleport then queue_on_teleport(debug.getinfo(1).source) success = true end
    end)
    pcall(function()
        if KRNL and KRNL.queue_on_teleport then KRNL.queue_on_teleport(debug.getinfo(1).source) success = true end
    end)
    pcall(function()
        if fluxus and fluxus.queue_on_teleport then fluxus.queue_on_teleport(debug.getinfo(1).source) success = true end
    end)
    pcall(function()
        local gui = gethui() or Instance.new("ScreenGui")
        gui.Name = "TX_Bond_AutoLoader"
        gui.ResetOnSpawn = false
        gui.Parent = game:GetService("CoreGui")
        local label = Instance.new("TextLabel")
        label.Visible = false
        label.Text = debug.getinfo(1).source
        label.Parent = gui
    end)
end

registerAutoExecute()
