if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
if not Rayfield then
    warn("[Ascension Hub] Failed to load UI library.")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Ascension Hub",
    Icon = 0,
    LoadingTitle = "Ascension Hub",
    LoadingSubtitle = "Loading...",
    ShowText = "",
    Theme = {
        TextColor = Color3.fromRGB(30, 40, 60),
        Background = Color3.fromRGB(245, 250, 255),
        Topbar = Color3.fromRGB(100, 180, 255),
        Shadow = Color3.fromRGB(180, 210, 240),
        NotificationBackground = Color3.fromRGB(240, 248, 255),
        NotificationActionsBackground = Color3.fromRGB(255, 255, 255),
        TabBackground = Color3.fromRGB(200, 230, 255),
        TabStroke = Color3.fromRGB(100, 180, 255),
        TabBackgroundSelected = Color3.fromRGB(255, 210, 50),
        TabTextColor = Color3.fromRGB(40, 60, 90),
        SelectedTabTextColor = Color3.fromRGB(20, 20, 20),
        ElementBackground = Color3.fromRGB(230, 242, 255),
        ElementBackgroundHover = Color3.fromRGB(200, 230, 255),
        SecondaryElementBackground = Color3.fromRGB(240, 248, 255),
        ElementStroke = Color3.fromRGB(120, 180, 255),
        SecondaryElementStroke = Color3.fromRGB(160, 200, 240),
        SliderBackground = Color3.fromRGB(255, 210, 50),
        SliderProgress = Color3.fromRGB(255, 195, 30),
        SliderStroke = Color3.fromRGB(255, 175, 0),
        ToggleBackground = Color3.fromRGB(210, 230, 255),
        ToggleEnabled = Color3.fromRGB(255, 200, 40),
        ToggleDisabled = Color3.fromRGB(170, 190, 210),
        ToggleEnabledStroke = Color3.fromRGB(255, 185, 20),
        ToggleDisabledStroke = Color3.fromRGB(140, 170, 200),
        ToggleEnabledOuterStroke = Color3.fromRGB(255, 220, 100),
        ToggleDisabledOuterStroke = Color3.fromRGB(150, 180, 210),
        DropdownSelected = Color3.fromRGB(255, 210, 50),
        DropdownUnselected = Color3.fromRGB(230, 242, 255),
        InputBackground = Color3.fromRGB(235, 245, 255),
        InputStroke = Color3.fromRGB(120, 180, 255),
        PlaceholderColor = Color3.fromRGB(100, 130, 160)
    },
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = false
    }
})

if not Window then
    warn("[Ascension Hub] Failed to create window.")
    return
end

local function DestroyUI()
    Rayfield:Destroy()
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[Ascension Hub] LocalPlayer not found.")
    return
end

pcall(function()
    for _, connection in pairs(getconnections(LocalPlayer.Idled)) do
        connection:Disable()
    end
end)

local Data = {
    Tycoon = nil,
    Values = nil,
    Streams = nil,
    AutoBuy = false,
    AutoUpgrade = false,
    AutoRebirth = false,
    AutoEvolve = false,
    AutoAscend = false,
    AutoBuyPowers = false,
    AutoPhoneOffers = false,
    AutoWake = false,
    AutoCollectFruits = false,
    Settings = {
        BuyInterval = 0,
        UseForeverPurchase = false,
        MaxRebirths = 0,
        MinInvestors = 1000,
        XFactor = 10,
        RebirthAfterTime = false,
        RebirthTime = 60,
        MaxEvolution = 0
    },
    Modules = {},
    Remotes = {}
}

local function FindTycoon()
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") and obj.Name:match("Tycoon%d") then
            local owner = obj:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer then
                return obj
            end
        end
    end
end

local function FindValues(name, child, returnLast)
    if not Data.Tycoon then return end
    local values = Data.Tycoon:FindFirstChild("Values")
    if not values then return end
    local result = values:FindFirstChild(name)
    if not result then return end
    if not child then
        return result
    end
    local sub = result:FindFirstChild(child)
    if sub then
        return returnLast and sub or result, sub
    end
end

-- Initial Load
local start = tick()
repeat
    Data.Tycoon = FindTycoon()
    if tick() - start > 20 then
        warn("[Ascension Hub] Tycoon not found.")
        DestroyUI()
        return
    end
    task.wait(0.2)
until Data.Tycoon

start = tick()
repeat
    Data.Values = FindValues("Values")
    if tick() - start > 8 then
        warn("[Ascension Hub] Values not found.")
        DestroyUI()
        return
    end
    task.wait(0.15)
until Data.Values

pcall(function()
    Data.Streams = FindValues("Income", "Streams", true)
end)

pcall(function()
    Data.Modules.Tycoon = require(ReplicatedStorage.Modules.Tycoon.Tycoon)
    Data.Modules.Balances = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonBalances)
    Data.Modules.Rebirth = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonRebirth)
    Data.Modules.Evolve = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonEvolution)
    Data.Modules.Ascension = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonAscension)
    Data.Modules.PhoneOffers = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonPhoneOffers)
    Data.Modules.Powers = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonPowers)
    Data.Modules.Analyzer = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonAnalyzer)
    Data.Modules.Balance = require(ReplicatedStorage.Balance)
end)

pcall(function()
    local remotes = Data.Tycoon:FindFirstChild("Remotes")
    if remotes then
        Data.Remotes.Rebirth = remotes:FindFirstChild("Rebirth")
        Data.Remotes.Evolve = remotes:FindFirstChild("Evolve")
        Data.Remotes.Ascend = remotes:FindFirstChild("Ascend")
        Data.Remotes.Wake = remotes:FindFirstChild("WakeIncomeStream")
        Data.Remotes.Phone = remotes:FindFirstChild("PhoneOffer")
    end
end)

local function GetComponent(class)
    if not (Data.Modules.Tycoon and class) then return nil end
    local success, result = pcall(function()
        local tycoon = Data.Modules.Tycoon.getLocal()
        return tycoon and tycoon:GetComponent(class)
    end)
    return success and result or nil
end

local Resolving = false
local function Resolve()
    Resolving = true
    task.wait(0.3)

    local newTycoon = FindTycoon()
    if newTycoon then
        Data.Tycoon = newTycoon
        Data.Values = FindValues("Values")
        pcall(function()
            local remotes = newTycoon:FindFirstChild("Remotes")
            if remotes then
                Data.Remotes.Rebirth = remotes:FindFirstChild("Rebirth")
                Data.Remotes.Evolve = remotes:FindFirstChild("Evolve")
                Data.Remotes.Ascend = remotes:FindFirstChild("Ascend")
                Data.Remotes.Wake = remotes:FindFirstChild("WakeIncomeStream")
                Data.Remotes.Phone = remotes:FindFirstChild("PhoneOffer")
            end
        end)
    end
    Resolving = false
end

-- ======================
-- AUTO BUY (TRUE INSTANT)
-- ======================
local CachedAnalyzer = nil
local CachedOrder = nil
local LastCache = 0

local function RefreshCache(force)
    if not force and tick() - LastCache < 1.5 then return end

    local analyzer = GetComponent(Data.Modules.Analyzer)
    if analyzer and Data.Modules.Balance and Data.Modules.Balance.PurchaseOrder then
        CachedAnalyzer = analyzer
        CachedOrder = Data.Modules.Balance.PurchaseOrder
        LastCache = tick()
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        if Data.AutoBuy then
            RefreshCache(true)
        end
    end
end)

task.spawn(function()
    while true do
        local interval = Data.Settings.BuyInterval or 0

        if interval <= 0 then
            task.wait() -- true frame speed
        else
            task.wait(interval)
        end

        if not Data.AutoBuy or Resolving then
            continue
        end

        if not CachedAnalyzer or not CachedOrder then
            RefreshCache(true)
            continue
        end

        local success, purchases = pcall(function()
            return CachedAnalyzer:GetPurchases()
        end)

        if not success or not purchases then
            RefreshCache(true)
            continue
        end

        for _, id in ipairs(CachedOrder) do
            local purchase = purchases[id]
            if purchase then
                local enabled, purchased = false, true

                pcall(function()
                    enabled = purchase:IsEnabled()
                    purchased = purchase:IsPurchased()
                end)

                if enabled and not purchased then
                    local remote = nil
                    pcall(function()
                        if purchase.Instance then
                            remote = purchase.Instance:FindFirstChild("Purchase", true)
                        end
                    end)

                    if remote and remote:IsA("RemoteFunction") then
                        if Data.Settings.UseForeverPurchase then
                            local ok = pcall(function()
                                remote:InvokeServer(true)
                            end)
                            if not ok then
                                pcall(function() remote:InvokeServer() end)
                            end
                        else
                            pcall(function()
                                remote:InvokeServer()
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ======================
-- AUTO UPGRADE
-- ======================
task.spawn(function()
    local remotes = {}
    local lastScan = 0

    while true do
        task.wait(0.4)
        if not Data.AutoUpgrade then continue end

        if tick() - lastScan > 3 then
            remotes = {}
            local folder = Data.Tycoon and Data.Tycoon:FindFirstChild("Purchases")
            if folder then
                for _, v in ipairs(folder:GetDescendants()) do
                    if v:IsA("RemoteFunction") and v.Name == "Upgrade" then
                        table.insert(remotes, v)
                    end
                end
            end
            lastScan = tick()
        end

        for _, remote in ipairs(remotes) do
            if remote and remote.Parent then
                task.spawn(function()
                    for i = 1, 5 do
                        pcall(function() remote:InvokeServer(i) end)
                        task.wait()
                    end
                end)
            end
        end
    end
end)

-- ======================
-- AUTO REBIRTH
-- ======================
task.spawn(function()
    local busy = false
    local lastSuccess = 0
    local lastToggle = 0

    while true do
        task.wait(0.2)
        if not Data.AutoRebirth or busy then
            if not Data.AutoRebirth then lastToggle = 0 end
            continue
        end

        if lastToggle == 0 then
            lastToggle = tick()
            continue
        end
        if tick() - lastToggle < 2 then continue end
        if tick() - lastSuccess < 2.2 then continue end

        if Data.Settings.MaxRebirths > 0 then
            local current = Data.Values and (Data.Values:GetAttribute("Rebirths") or 0) or 0
            if current >= Data.Settings.MaxRebirths then continue end
        end

        local should = false
        if Data.Settings.RebirthAfterTime then
            if tick() - lastSuccess >= Data.Settings.RebirthTime then
                should = true
            end
        else
            local rebirthComp = GetComponent(Data.Modules.Rebirth)
            local balances = GetComponent(Data.Modules.Balances)
            if rebirthComp and balances then
                local potential, current = 0, 0
                pcall(function() potential = rebirthComp:GetPotentialInvestors() end)
                pcall(function() current = balances:GetInvestors() end)

                if potential > 0 then
                    local minMet = Data.Settings.MinInvestors == 0 or potential >= math.log10(Data.Settings.MinInvestors)
                    if minMet then
                        if Data.Settings.XFactor > 0 then
                            if potential >= current + math.log10(Data.Settings.XFactor) then
                                should = true
                            end
                        else
                            should = true
                        end
                    end
                end
            end
        end

        if should and Data.Remotes.Rebirth then
            busy = true
            pcall(function()
                Data.Remotes.Rebirth:InvokeServer()
                Resolve()
                RefreshCache(true)
            end)
            lastSuccess = tick()
            lastToggle = tick()
            task.wait(1)
            busy = false
        end
    end
end)

-- ======================
-- AUTO EVOLVE
-- ======================
task.spawn(function()
    while true do
        task.wait(0.5)
        if not Data.AutoEvolve then continue end

        local mod = GetComponent(Data.Modules.Evolve)
        if not mod then continue end

        local progress = 0
        pcall(function() progress = mod:GetEvolutionProgress() end)

        if progress == 1 then
            local current = Data.Values and (Data.Values:GetAttribute("Evolution") or 0) or 0
            if Data.Settings.MaxEvolution == 0 or current < Data.Settings.MaxEvolution then
                if Data.Remotes.Evolve then
                    pcall(function()
                        Data.Remotes.Evolve:InvokeServer()
                        Resolve()
                        RefreshCache(true)
                    end)
                end
            end
        end
    end
end)

-- ======================
-- AUTO ASCEND
-- ======================
task.spawn(function()
    while true do
        task.wait(0.5)
        if not Data.AutoAscend then continue end

        local mod = GetComponent(Data.Modules.Ascension)
        if not mod then continue end

        local progress = 0
        pcall(function() progress = mod:GetAscensionProgress() end)

        if progress == 1 and Data.Remotes.Ascend then
            pcall(function()
                Data.Remotes.Ascend:InvokeServer()
                Resolve()
                RefreshCache(true)
            end)
        end
    end
end)

-- ======================
-- AUTO BUY POWERS
-- ======================
task.spawn(function()
    while true do
        task.wait(0.55)
        if not Data.AutoBuyPowers then continue end

        local mod = GetComponent(Data.Modules.Powers)
        if not mod then continue end

        local success, levels = pcall(function() return mod:GetLevels() end)
        if success and levels then
            for name, level in pairs(levels) do
                local maxLevel = nil
                pcall(function() maxLevel = mod:GetMaxLevel(name) end)
                if not maxLevel or level < maxLevel then
                    pcall(function() mod:UpgradeAsync(name) end)
                    task.wait(0.08)
                end
            end
        end
    end
end)

-- ======================
-- PHONE OFFERS
-- ======================
task.spawn(function()
    local phone = Data.Remotes.Phone
    if phone then
        phone.OnClientEvent:Connect(function(value)
            if Data.AutoPhoneOffers and type(value) == "number" then
                pcall(function() phone:FireServer("Accept") end)
            end
        end)
    end

    while true do
        task.wait(1.5)
        if Data.AutoPhoneOffers and phone then
            local mod = GetComponent(Data.Modules.PhoneOffers)
            if mod then
                local success, offer = pcall(function() return mod:GetCurrentOffer() end)
                if success and type(offer) == "number" then
                    pcall(function() phone:FireServer("Accept") end)
                end
            end
        end
    end
end)

-- ======================
-- AUTO WAKE
-- ======================
task.spawn(function()
    while true do
        task.wait(0.35)
        if not Data.AutoWake then continue end
        if not Data.Streams or not Data.Remotes.Wake then continue end

        for _, stream in pairs(Data.Streams:GetChildren()) do
            if not stream:GetAttribute("Automatic") then
                pcall(function()
                    Data.Remotes.Wake:InvokeServer(tostring(stream))
                end)
            end
        end
    end
end)

-- ======================
-- COLLECT FRUITS
-- ======================
task.spawn(function()
    local trees = {}
    local originalCFrame = nil

    local function updateTree(obj, adding)
        if obj:IsA("Model") and obj.Name == "LemonTree" then
            if adding then
                if not table.find(trees, obj) then
                    table.insert(trees, obj)
                end
            else
                local index = table.find(trees, obj)
                if index then
                    table.remove(trees, index)
                end
            end
        end
    end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        updateTree(obj, true)
    end
    Workspace.DescendantAdded:Connect(function(obj) updateTree(obj, true) end)
    Workspace.DescendantRemoving:Connect(function(obj) updateTree(obj, false) end)

    while true do
        task.wait(0.18)
        if Data.AutoCollectFruits then
            for _, tree in ipairs(trees) do
                if tree and tree.Parent then
                    for _, part in ipairs(tree:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name == "Fruit" then
                            local detector = part:FindFirstChild("ClickPart") and part.ClickPart:FindFirstChildOfClass("ClickDetector")
                            if detector then
                                local character = LocalPlayer.Character
                                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    pcall(function()
                                        if not originalCFrame then
                                            originalCFrame = hrp.CFrame
                                        end
                                        hrp.CFrame = tree:GetPivot() + Vector3.new(0, tree:GetExtentsSize().Y / 2, 0)
                                        task.wait(0.04)
                                        fireclickdetector(detector)
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        elseif originalCFrame then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.CFrame = originalCFrame
                    originalCFrame = nil
                end)
            end
        end
    end
end)

-- ======================
-- UI
-- ======================
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")
local MiscTab = Window:CreateTab("Misc")

MainTab:CreateSection("Automation")
MainTab:CreateToggle({
    Name = "Auto Buy",
    CurrentValue = false,
    Flag = "AutoBuy",
    Callback = function(value)
        Data.AutoBuy = value
        if value then RefreshCache(true) end
    end
})

MainTab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(value)
        Data.AutoUpgrade = value
    end
})

MainTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(value)
        Data.AutoRebirth = value
    end
})

MainTab:CreateToggle({
    Name = "Auto Evolve",
    CurrentValue = false,
    Flag = "AutoEvolve",
    Callback = function(value)
        Data.AutoEvolve = value
    end
})

MainTab:CreateToggle({
    Name = "Auto Ascend",
    CurrentValue = false,
    Flag = "AutoAscend",
    Callback = function(value)
        Data.AutoAscend = value
    end
})

MainTab:CreateDivider()
MainTab:CreateSection("Extras")

MainTab:CreateToggle({
    Name = "Auto Buy Powers",
    CurrentValue = false,
    Flag = "AutoBuyPowers",
    Callback = function(value)
        Data.AutoBuyPowers = value
    end
})

MainTab:CreateToggle({
    Name = "Auto Phone Offers",
    CurrentValue = false,
    Flag = "AutoPhoneOffers",
    Callback = function(value)
        Data.AutoPhoneOffers = value
    end
})

MainTab:CreateToggle({
    Name = "Auto Wake Sources",
    CurrentValue = false,
    Flag = "AutoWake",
    Callback = function(value)
        Data.AutoWake = value
    end
})

MainTab:CreateToggle({
    Name = "Collect Fruits",
    CurrentValue = false,
    Flag = "AutoCollectFruits",
    Callback = function(value)
        Data.AutoCollectFruits = value
    end
})

-- Settings
SettingsTab:CreateSection("Buy Settings")
SettingsTab:CreateInput({
    Name = "Buy Interval (0 = Instant)",
    CurrentValue = "0",
    PlaceholderText = "0",
    RemoveTextAfterFocusLost = false,
    Flag = "BuyInterval",
    Callback = function(text)
        local number = tonumber(text)
        if number and number >= 0 then
            Data.Settings.BuyInterval = number
        end
    end
})

SettingsTab:CreateToggle({
    Name = "Use Forever Purchase",
    CurrentValue = false,
    Flag = "UseForeverPurchase",
    Callback = function(value)
        Data.Settings.UseForeverPurchase = value
    end
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection("Rebirth Settings")

SettingsTab:CreateInput({
    Name = "Max Rebirths (0 = Unlimited)",
    CurrentValue = "0",
    PlaceholderText = "0",
    RemoveTextAfterFocusLost = false,
    Flag = "MaxRebirths",
    Callback = function(text)
        local number = tonumber(text)
        if number and number >= 0 then
            Data.Settings.MaxRebirths = number
        end
    end
})

SettingsTab:CreateInput({
    Name = "Minimum Investors",
    CurrentValue = "1000",
    PlaceholderText = "1000",
    RemoveTextAfterFocusLost = false,
    Flag = "MinInvestors",
    Callback = function(text)
        local number = tonumber(text)
        if number and number >= 0 then
            Data.Settings.MinInvestors = number
        end
    end
})

SettingsTab:CreateInput({
    Name = "X Factor",
    CurrentValue = "10",
    PlaceholderText = "10",
    RemoveTextAfterFocusLost = false,
    Flag = "XFactor",
    Callback = function(text)
        local number = tonumber(text)
        if number and number >= 0 then
            Data.Settings.XFactor = number
        end
    end
})

SettingsTab:CreateInput({
    Name = "Rebirth After Time (Seconds)",
    CurrentValue = "60",
    PlaceholderText = "60",
    RemoveTextAfterFocusLost = false,
    Flag = "RebirthTime",
    Callback = function(text)
        local number = tonumber(text)
        if number and number >= 0 then
            Data.Settings.RebirthTime = number
        end
    end
})

SettingsTab:CreateToggle({
    Name = "Rebirth After Certain Time",
    CurrentValue = false,
    Flag = "RebirthAfterTime",
    Callback = function(value)
        Data.Settings.RebirthAfterTime = value
    end
})

SettingsTab:CreateDivider()
SettingsTab:CreateSection("Evolve Settings")

SettingsTab:CreateInput({
    Name = "Max Evolution (0 = No Limit)",
    CurrentValue = "0",
    PlaceholderText = "0",
    RemoveTextAfterFocusLost = false,
    Flag = "MaxEvolution",
    Callback = function(text)
        local number = tonumber(text)
        if number and number >= 0 then
            Data.Settings.MaxEvolution = number
        end
    end
})

MiscTab:CreateSection("Utility")
MiscTab:CreateToggle({
    Name = "Disable 3D Rendering",
    CurrentValue = false,
    Flag = "DisableRendering",
    Callback = function(value)
        RunService:Set3dRenderingEnabled(not value)
    end
})

MiscTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        DestroyUI()
    end
})

print("[Ascension Hub] Successfully loaded.")