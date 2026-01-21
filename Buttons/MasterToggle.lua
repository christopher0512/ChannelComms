-- Create the Master Toggle Button
_G.masterToggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
masterToggleButton:SetSize(32, 32)
masterToggleButton:SetPoint("LEFT", questCheckButton, "RIGHT", 5, 0)

-- Set up icon for the master toggle button
local masterToggleIcon = masterToggleButton:CreateTexture(nil, "ARTWORK")
masterToggleIcon:SetTexture("Interface\\Icons\\trade_engineering")
masterToggleIcon:SetAllPoints(masterToggleButton)

masterToggleButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Enable and Disable UI items")
    GameTooltip:Show()
end)

masterToggleButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Function to Create Map Size Row
local function CreateMapSizeRow(parent, yOffset, toggleFunction, initialState)
    -- 1.0 Button
    local smallButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    smallButton:SetSize(40, 22)
    smallButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    smallButton:SetText("1.0")
    smallButton:SetScript("OnClick", function()
        toggleFunction(1.0)
    end)

    -- 2.0 Button
    local largeButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    largeButton:SetSize(40, 22)
    largeButton:SetPoint("LEFT", smallButton, "RIGHT", 10, 0)
    largeButton:SetText("2.0")
    largeButton:SetScript("OnClick", function()
        toggleFunction(2.0)
    end)

    -- Label
    local resizeLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resizeLabel:SetPoint("LEFT", largeButton, "RIGHT", 20, 0)
    resizeLabel:SetWidth(120)
    resizeLabel:SetText("MiniMap Resizing")

    -- Status Label
    local sizeStatusLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeStatusLabel:SetPoint("LEFT", resizeLabel, "RIGHT", 40, 0)
    sizeStatusLabel:SetWidth(80)
    sizeStatusLabel:SetText(initialState == 2.0 and "2.0" or "1.0")

    -- Toggle Functionality
    smallButton:SetScript("OnClick", function()
        toggleFunction(1.0)
        sizeStatusLabel:SetText("1.0")
    end)
    largeButton:SetScript("OnClick", function()
        toggleFunction(2.0)
        sizeStatusLabel:SetText("2.0")
    end)
end

-- ============================
-- Mow the Lawn / Yard Logic
-- ============================

-- simple per-character key
local function GetPlayerKey()
    local name = UnitName("player") or "Unknown"
    local realm = GetRealmName() or "UnknownRealm"
    return name .. "-" .. realm
end

-- init DB table (will only persist if added to TOC later)
if not ChannelCommsDB then
    ChannelCommsDB = {}
end
local playerKey = GetPlayerKey()
ChannelCommsDB.yardBounds = ChannelCommsDB.yardBounds or {}
ChannelCommsDB.yardBounds[playerKey] = ChannelCommsDB.yardBounds[playerKey] or {}

local AutoTrimEnabled = false

-- default fallback yard (your current house as a starter)
local function GetYardBounds()
    local b = ChannelCommsDB.yardBounds[playerKey]
    if not b.mapID then
        -- default to your known map/coords as a starting point
        b.mapID = 2352
        b.minX, b.maxX = 0.355, 0.368
        b.minY, b.maxY = 0.586, 0.596
    end
    return b
end

local function ApplyCleanGrass()
    SetCVar("groundEffectDensity", 16)
    SetCVar("groundEffectDist", 1)
    SetCVar("grassDensity", 0)
    SetCVar("grassAnimation", 0)
	SetCVar("environmentDetail", 0.5)
    print("Mow the Lawn: Yard trimmed")
end

local function ApplyFullGrass()
    SetCVar("groundEffectDensity", 256)
    SetCVar("groundEffectDist", 200)
    SetCVar("grassDensity", 128)
    SetCVar("grassAnimation", 1)
	SetCVar("environmentDetail", 1.0)
    print("Mow the Lawn: World grass restored")
end

local function ToggleMowTheLawn(state)
    if state then
        ApplyCleanGrass()
    else
        ApplyFullGrass()
    end
end

local function PlayerIsInYard()
    local b = GetYardBounds()
    if not b.mapID then return false end

    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID ~= b.mapID then return false end

    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return false end

    local x, y = pos.x, pos.y
    return (x > b.minX and x < b.maxX and y > b.minY and y < b.maxY)
end

local lastTrimState = nil

local function AutoTrimUpdate()
    if not AutoTrimEnabled then return end

    local inYard = PlayerIsInYard()
    if inYard ~= lastTrimState then
        lastTrimState = inYard
        if inYard then
            ApplyCleanGrass()
        else
            ApplyFullGrass()
        end
    end
end

-- periodic check
C_Timer.NewTicker(2, AutoTrimUpdate)

local function ToggleAutoTrim(state)
    AutoTrimEnabled = state
    print("Auto Mow the Lawn: " .. (state and "Enabled" or "Disabled"))
end

local function DefineYardAtCurrentPosition()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        print("Mow the Lawn: Unable to determine map ID.")
        return
    end

    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then
        print("Mow the Lawn: Unable to determine player position.")
        return
    end

    local centerX, centerY = pos.x, pos.y
    local boxSize = 0.01 -- ~1% box around player

    local b = ChannelCommsDB.yardBounds[playerKey]
    b.mapID = mapID
    b.minX = centerX - boxSize
    b.maxX = centerX + boxSize
    b.minY = centerY - boxSize
    b.maxY = centerY + boxSize

    print(string.format("Mow the Lawn: Yard defined at map %d (%.3f, %.3f).", mapID, centerX, centerY))
end

local function ResetYardBounds()
    ChannelCommsDB.yardBounds[playerKey] = {}
    print("Mow the Lawn: Yard bounds reset. They will be redefined next time you use Define Yard.")
end

local function DebugYardBounds()
    local b = GetYardBounds()
    if not b.mapID then
        print("Mow the Lawn: No yard bounds defined yet.")
        return
    end
    print(string.format(
        "Mow the Lawn Debug: mapID=%d, X[%.3f-%.3f], Y[%.3f-%.3f]",
        b.mapID, b.minX, b.maxX, b.minY, b.maxY
    ))
end

-- Create the Popup Window
local popupFrame

masterToggleButton:SetScript("OnClick", function()
    if popupFrame and popupFrame:IsShown() then
        popupFrame:Hide()
        return
    end

    popupFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
    popupFrame:SetSize(400, 460)
    popupFrame:SetPoint("CENTER", UIParent, "CENTER")
    popupFrame:SetMovable(true)
    popupFrame:EnableMouse(true)
    popupFrame:RegisterForDrag("LeftButton")
    popupFrame:SetScript("OnDragStart", popupFrame.StartMoving)
    popupFrame:SetScript("OnDragStop", popupFrame.StopMovingOrSizing)

    -- Title
    local title = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", popupFrame, "TOP", 0, -5)
    title:SetText("Master Toggle Menu")
    title:SetTextColor(0, 1, 1) -- Cyan text
    
    -- Column Headers
    local headerItem = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerItem:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", 110, -40) -- Align above column 3
    headerItem:SetWidth(150)
    headerItem:SetText("Items")

    local headerStatus = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerStatus:SetPoint("LEFT", headerItem, "RIGHT", 30, 0) -- Moved 30 units to the right
    headerStatus:SetWidth(80)
    headerStatus:SetText("Status")

    -- Dynamic Rows
    local function CreateRow(parent, yOffset, itemName, toggleFunction, initialState)
        -- On Button
        local onButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        onButton:SetSize(40, 22)
        onButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
        onButton:SetText("On")
        
        -- Off Button
        local offButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        offButton:SetSize(40, 22)
        offButton:SetPoint("LEFT", onButton, "RIGHT", 10, 0)
        offButton:SetText("Off")

        -- Item Label
        local itemLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemLabel:SetPoint("LEFT", offButton, "RIGHT", 20, 0)
        itemLabel:SetWidth(120)
        itemLabel:SetText(itemName)

        -- Status Label
        local statusLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statusLabel:SetPoint("LEFT", itemLabel, "RIGHT", 40, 0)
        statusLabel:SetWidth(80)
        statusLabel:SetText(initialState and "On" or "Off")

        -- Toggle Functionality
        onButton:SetScript("OnClick", function()
            toggleFunction(true)
            statusLabel:SetText("On")
        end)
        offButton:SetScript("OnClick", function()
            toggleFunction(false)
            statusLabel:SetText("Off")
        end)
    end

    -- Toggle Functions
    local function ToggleMusic(state)
        SetCVar("Sound_EnableMusic", state and "1" or "0")
        print("Music " .. (state and "On" or "Off"))
    end

    local function ToggleTooltips(state)
        GameTooltip.override = not state
        GameTooltip:SetScript("OnShow", GameTooltip.override and GameTooltip.Hide or GameTooltip.Show)
        print("Tooltips " .. (state and "On" or "Off"))
    end

    local function ToggleTalkingHead(state)
        if state then
            TalkingHeadFrame:Show()
            print("Talking Head Frame On")
        else
            TalkingHeadFrame:Hide()
            print("Talking Head Frame Off")
        end
    end

    -- Function to Force Hide Talking Head Frame When Needed
    local function SuppressTalkingHead()
        if not TalkingHeadFrame:IsShown() then return end
        TalkingHeadFrame:Hide()
        -- print("Talking Head Frame forcibly hidden")
    end

    -- Hook into TALKINGHEAD_REQUESTED Event
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("TALKINGHEAD_REQUESTED")
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "TALKINGHEAD_REQUESTED" then
            SuppressTalkingHead()
        end
    end)

    -- Logic for Talking Head
    local function ToggleTalkingHead(state)
        if state then
            TalkingHeadFrame:Show()
            print("Talking Head Frame On")
        else
            TalkingHeadFrame:Hide()
            print("Talking Head Frame Off")
        end
    end

    local function ToggleMiniMap(state)
        MinimapCluster:SetShown(state)
        print("MiniMap Frame " .. (state and "On" or "Off"))
    end

    local function SetMiniMapSize(size)
        MinimapCluster:SetScale(size)
        print("MiniMap Size " .. (size == 2.0 and "Large" or "Normal"))
    end

    local function ToggleObjectiveTracker(state)
        ObjectiveTrackerFrame:SetShown(state)
        print("Objective Tracker Frame " .. (state and "On" or "Off"))
    end

    -- Check Initial States
    local isMusicOn = GetCVar("Sound_EnableMusic") == "1"
    local areTooltipsEnabled = not GameTooltip.override
    local isTalkingHeadVisible = TalkingHeadFrame:IsShown()
    local isMiniMapVisible = MinimapCluster:IsShown()
    local isObjectiveTrackerVisible = ObjectiveTrackerFrame:IsShown()
    local miniMapSize = MinimapCluster:GetScale() -- Get initial size of MiniMap

    -- Add Rows
    CreateRow(popupFrame, -60, "Music", ToggleMusic, isMusicOn)
    CreateRow(popupFrame, -90, "Tool Tips", ToggleTooltips, areTooltipsEnabled)
    CreateRow(popupFrame, -120, "Talking Head", ToggleTalkingHead, isTalkingHeadVisible)
    CreateRow(popupFrame, -150, "MiniMap", ToggleMiniMap, isMiniMapVisible)
    CreateMapSizeRow(popupFrame, -180, SetMiniMapSize, miniMapSize)
    CreateRow(popupFrame, -210, "Objective Tracker", ToggleObjectiveTracker, isObjectiveTrackerVisible)

    -- Mow the Lawn rows
    CreateRow(popupFrame, -240, "Mow the Lawn", ToggleMowTheLawn, false)
    CreateRow(popupFrame, -270, "Auto Mow", ToggleAutoTrim, false)

    -- Define / Reset / Debug Yard row (buttons only)
    local defineButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
    defineButton:SetSize(80, 22)
    defineButton:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", 20, -320)
    defineButton:SetText("Define Yard")
    defineButton:SetScript("OnClick", function()
        DefineYardAtCurrentPosition()
    end)

    local resetButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
    resetButton:SetSize(80, 22)
    resetButton:SetPoint("LEFT", defineButton, "RIGHT", 10, 0)
    resetButton:SetText("Reset Yard")
    resetButton:SetScript("OnClick", function()
        ResetYardBounds()
    end)

    local debugButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
    debugButton:SetSize(80, 22)
    debugButton:SetPoint("LEFT", resetButton, "RIGHT", 10, 0)
    debugButton:SetText("Debug Yard")
    debugButton:SetScript("OnClick", function()
        DebugYardBounds()
    end)

    local yardLabel = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    yardLabel:SetPoint("BOTTOMLEFT", defineButton, "TOPLEFT", 0, 6)
    yardLabel:SetWidth(140)
    yardLabel:SetText("Mow the Lawn Tools")

    popupFrame:Show()
end)