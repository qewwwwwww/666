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

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TX_BondUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 55)
frame.Position = UDim2.new(0.5, -200, 0.85, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -20, 0, 22)
label.Position = UDim2.new(0, 10, 0, 4)
label.BackgroundTransparency = 1
label.Text = "债券: 0 / 0"
label.TextColor3 = Color3.fromRGB(220, 220, 220)
label.TextScaled = true
label.Font = Enum.Font.GothamBold
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = frame

local progressBarBg = Instance.new("Frame")
progressBarBg.Size = UDim2.new(1, -20, 0, 14)
progressBarBg.Position = UDim2.new(0, 10, 0, 33)
progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
progressBarBg.BorderSizePixel = 0
progressBarBg.Parent = frame

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 6)
barCorner.Parent = progressBarBg

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = Color3.fromRGB(65, 170, 245)
progressBar.BorderSizePixel = 0
progressBar.Parent = progressBarBg

local progressCorner = Instance.new("UICorner")
progressCorner.CornerRadius = UDim.new(0, 6)
progressCorner.Parent = progressBar

local function updateUI(found, collected, total)
    label.Text = "债券: " .. found .. " / " .. collected
    if total > 0 then
        local ratio = math.min(collected / total, 1)
        progressBar:TweenSize(UDim2.new(ratio, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, 0.08, true)
    end
end

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
local primaryPart=zone.PrimaryPart or zone:FindFirstChildWhichIsA("BasePart")
if not primaryPart then return true end
for _,otherPlayer in pairs(Players:GetPlayers()) do
if otherPlayer~=player then
local otherChar=otherPlayer.Character
if otherChar then
local otherRoot=otherChar:FindFirstChild("HumanoidRootPart") or otherChar.PrimaryPart
if otherRoot then
local dist=(otherRoot.Position-primaryPart.Position).Magnitude
if dist<math.max(primaryPart.Size.X,primaryPart.Size.Z)/2+5 then return true end end end end end
return false end
local function isInZone(zone)
if not zone then return false end
local primaryPart=zone.PrimaryPart or zone:FindFirstChildWhichIsA("BasePart")
if not primaryPart then return false end
local character=player.Character
if not character then return false end
local hrp=character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
if not hrp then return false end
local dist=(hrp.Position-primaryPart.Position).Magnitude
return dist<32 end
local function isGameZoneExists()
local indicators={Workspace:FindFirstChild("Game"),Workspace:FindFirstChild("Map"),Workspace:FindFirstChild("Train"),Workspace:FindFirstChild("World"),Workspace:FindFirstChild("Level"),Workspace:FindFirstChild("Environment"),Workspace:FindFirstChild("Terrain")}
for _,indicator in ipairs(indicators) do if indicator then return true end end
local partCount=0
for _,obj in ipairs(Workspace:GetDescendants()) do
if obj:IsA("BasePart") then
partCount=partCount+1
if partCount>98 then return true end end end
return false end
local function teleportToZone(zone)
if not zone then return false end
local primaryPart=zone.PrimaryPart or zone:FindFirstChildWhichIsA("BasePart")
if not primaryPart then return false end
local targetPos=primaryPart.Position+Vector3.new(0,3,0)
local character=player.Character
if not character then return false end
local hrp=character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
if not hrp then return false end
hrp.CFrame=CFrame.new(targetPos)
task.wait(0.86)
local dist=(hrp.Position-targetPos).Magnitude
return dist<46 end
local function createPublicRoomTwice()
local CreateParty=RS.Shared.Universe.Network.RemoteEvent:FindFirstChild("CreateParty")
if not CreateParty then return false end
CreateParty:FireServer({isPrivate=false,maxMembers=1,trainId="default",gameMode="Normal"})
task.wait(1.078)
CreateParty:FireServer({isPrivate=false,maxMembers=1,trainId="default",gameMode="Normal"})
return true end
local function attemptStartGame(zones)
setupPartyZoneDetection()
while true do
local availableZones={}
for _,zone in ipairs(zones) do
if not isZoneOccupied(zone) then table.insert(availableZones,zone) end end
if #availableZones==0 then task.wait(3) continue end
local targetZone=availableZones[math.random(1,#availableZones)]
local teleportSuccess=teleportToZone(targetZone)
if not teleportSuccess then task.wait(2) continue end
local waitStart=tick()
local arrived=false
while tick()-waitStart<19 do
task.wait(0.476)
arrived=isInZone(targetZone)
if arrived then break end end
if not arrived then task.wait(2) continue end
createPublicRoomTwice()
partyZoneReservedDetected = false
local detected=false
for i=1,78 do
task.wait(0.422)
if partyZoneReservedDetected then
detected=true
break end
if isGameZoneExists() then detected=true break end end
if detected then return true end
task.wait(1) end end
local function killSelf()
local character=player.Character
if not character then return false end
local humanoid=character:FindFirstChild("Humanoid")
if humanoid then humanoid.Health=0 return true end
return false end
local function startEndDecisionLoop()
local EndDecision=RS.Remotes:FindFirstChild("EndDecision")
if not EndDecision then return false end
killSelf()
task.wait(0.698)
while true do
pcall(function() EndDecision:FireServer(false) end)
task.wait(0.274) end end
local function isDuplicate(id,foundList)
for _,v in ipairs(foundList) do if v==id then return true end end
return false end
local function scanForBonds(world,comps,replicator)
local Storable=comps.Storable
local ObjectId=comps.ObjectId
local Sack=comps.Sack
local bondList={}
local char=world:get_resource(comps.ClientStateResource).localCharacter
if char then
if not world:has(char,Sack) then
world:add(char,Sack)
world:set(char,Sack,{contents={},maxContents=99900}) end
for id=1,28500,1690 do
local batchEnd=math.min(id+1689,31500)
for j=id,batchEnd do
if world:has(j,Storable) and world:get(j,ObjectId)=="bond" then
local sr=replicator:get_server_entity(j)
if sr and sr~=j then bondList[#bondList+1]={id=j,serverEntity=sr} end end end
task.wait() end end
return bondList end
local function processBonds(bondList,StoreRemote,ActionableEvent)
local baggedCount=0
local collectedCount=0
for index,bondData in ipairs(bondList) do
if Workspace:FindFirstChild("PartyZones") then return baggedCount,collectedCount end
local j=bondData.id
local sr=bondData.serverEntity
StoreRemote:FireServer(sr)
baggedCount=baggedCount+1
task.wait(0.089)
StoreRemote:FireServer()
ActionableEvent:FireServer(sr)
collectedCount=collectedCount+1
task.wait(0.087)
updateUI(#bondList, collectedCount, #bondList)
end
return baggedCount,collectedCount end
local function startFarmingBonds()
if Workspace:FindFirstChild("PartyZones") then return false end
local world,comps,replicator,Remotes,Event
local loadSuccess=false
local retryCount=0
while not loadSuccess and retryCount<8600 do
loadSuccess=pcall(function()
world=require(RS.Shared.Universe.ECS.world)
comps=require(RS.Shared.Universe.ECS.components)
replicator=require(RS.Client.Universe.Replication.clientReplicator)
Remotes=require(RS.Shared.Universe.Remotes)
Event=RS.Shared.Universe.Network.RemoteEvent.Actionable end)
if not loadSuccess then retryCount=retryCount+1 task.wait(0.518) end
if Workspace:FindFirstChild("PartyZones") then return false end end
if not loadSuccess then return false end
local ClientStateResource=comps.ClientStateResource
local maxInitRetries=1580
local initRetry=0
local initSuccess=false
while not initSuccess and initRetry<maxInitRetries do
initRetry=initRetry+1
local ok,res=pcall(function() return world:get_resource(ClientStateResource) end)
if ok and res then initSuccess=true break end
task.wait(0.516)
if Workspace:FindFirstChild("PartyZones") then return false end end
if not initSuccess then return false end
local Storable=comps.Storable
local ObjectId=comps.ObjectId
local Sack=comps.Sack
local StoreRemote=Remotes.Store
local ActionableEvent=Event
local startTime=tick()
local scanFound=false
local allBondList={}
while tick()-startTime<28 do
if Workspace:FindFirstChild("PartyZones") then return false end
local newBonds=scanForBonds(world,comps,replicator)
for _,bond in ipairs(newBonds) do
if not isDuplicate(bond.id,allBondList) then allBondList[#allBondList+1]=bond end end
if #allBondList>0 then scanFound=true break end
task.wait(0.286) end
if not scanFound then
updateUI(0, 0, 0)
CoreGui:SetCore("SendNotification",{Title="TX Script",Text="未发现债券，强制加入死亡轨道",Duration=5})
forceJoinDeadRails()
return true end
updateUI(#allBondList, 0, #allBondList)
local totalBagged=0
local totalCollected=0
local bagged,collected=processBonds(allBondList,StoreRemote,ActionableEvent)
totalBagged=totalBagged+bagged
totalCollected=totalCollected+collected
local secondBondList=scanForBonds(world,comps,replicator)
local missedBonds={}
for _,bond in ipairs(secondBondList) do
if not isDuplicate(bond.id,allBondList) then missedBonds[#missedBonds+1]=bond end end
if #missedBonds>0 then
for _,bond in ipairs(missedBonds) do allBondList[#allBondList+1]=bond end
updateUI(#allBondList, totalCollected, #allBondList)
local missedBagged,missedCollected=processBonds(missedBonds,StoreRemote,ActionableEvent)
totalBagged=totalBagged+missedBagged
totalCollected=totalCollected+missedCollected
local thirdBondList=scanForBonds(world,comps,replicator)
local finalMissed={}
for _,bond in ipairs(thirdBondList) do
if not isDuplicate(bond.id,allBondList) then finalMissed[#finalMissed+1]=bond end end
if #finalMissed>0 then
for _,bond in ipairs(finalMissed) do allBondList[#allBondList+1]=bond end
updateUI(#allBondList, totalCollected, #allBondList)
local finalBagged,finalCollected=processBonds(finalMissed,StoreRemote,ActionableEvent)
totalBagged=totalBagged+finalBagged
totalCollected=totalCollected+finalCollected end end
updateUI(#allBondList, totalCollected, #allBondList)
CoreGui:SetCore("SendNotification",{Title="TX Script",Text="债券处理完毕，强制加入死亡轨道",Duration=5})
forceJoinDeadRails()
return true end
local partyZonesFolder=Workspace:FindFirstChild("PartyZones")
if not partyZonesFolder then
local needSuicide=startFarmingBonds()
if needSuicide then task.wait(1) startEndDecisionLoop() end
else
local zones={}
for _,zone in ipairs(partyZonesFolder:GetChildren()) do
if zone:IsA("Model") then table.insert(zones,zone) end end
if #zones==0 then
local needSuicide=startFarmingBonds()
if needSuicide then task.wait(1) startEndDecisionLoop() end
return end
local startSuccess=attemptStartGame(zones)
if startSuccess then
local needSuicide=startFarmingBonds()
if needSuicide then task.wait(1) startEndDecisionLoop() end end end
