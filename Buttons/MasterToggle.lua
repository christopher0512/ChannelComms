-- ============================================================
-- MASTER TOGGLE BUTTON
-- ============================================================

_G.masterToggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
masterToggleButton:SetSize(32, 32)
masterToggleButton:SetPoint("LEFT", questCheckButton, "RIGHT", 5, 0)

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

-- ============================================================
-- MAP SIZE ROW
-- ============================================================

local function CreateMapSizeRow(parent, yOffset, toggleFunction, initialState)
    local smallButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    smallButton:SetSize(40, 22)
    smallButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
    smallButton:SetText("1.0")

    local largeButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    largeButton:SetSize(40, 22)
    largeButton:SetPoint("LEFT", smallButton, "RIGHT", 10, 0)
    largeButton:SetText("2.0")

    local resizeLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resizeLabel:SetPoint("LEFT", largeButton, "RIGHT", 20, 0)
    resizeLabel:SetWidth(120)
    resizeLabel:SetText("MiniMap Resizing")

    local sizeStatusLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sizeStatusLabel:SetPoint("LEFT", resizeLabel, "RIGHT", 40, 0)
    sizeStatusLabel:SetWidth(80)
    sizeStatusLabel:SetText(initialState == 2.0 and "2.0" or "1.0")

    smallButton:SetScript("OnClick", function()
        toggleFunction(1.0)
        sizeStatusLabel:SetText("1.0")
    end)

    largeButton:SetScript("OnClick", function()
        toggleFunction(2.0)
        sizeStatusLabel:SetText("2.0")
    end)
end

-- ============================================================
-- MOW THE LAWN / AUTO MOW LOGIC
-- ============================================================

-- Per-character key
local function GetPlayerKey()
    local name = UnitName("player") or "Unknown"
    local realm = GetRealmName() or "UnknownRealm"
    return name .. "-" .. realm
end

-- Initialize DB
if not ChannelCommsDB then ChannelCommsDB = {} end
local playerKey = GetPlayerKey()

ChannelCommsDB.yardBounds = ChannelCommsDB.yardBounds or {}
ChannelCommsDB.yardBounds[playerKey] = ChannelCommsDB.yardBounds[playerKey] or {}

-- NEW SAVED SETTINGS
ChannelCommsDB.mowEnabled = ChannelCommsDB.mowEnabled or false
ChannelCommsDB.autoMow = ChannelCommsDB.autoMow or false

local AutoTrimEnabled = ChannelCommsDB.autoMow

-- Default fallback yard
local function GetYardBounds()
    local b = ChannelCommsDB.yardBounds[playerKey]
    if not b.mapID then
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
    SetCVar("environmentDetail", 0.1)
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

-- Toggle Mow (writes to DB)
local function ToggleMowTheLawn(state)
    ChannelCommsDB.mowEnabled = state
    if state then ApplyCleanGrass() else ApplyFullGrass() end
end

-- Toggle Auto Mow (writes to DB)
local function ToggleAutoTrim(state)
    ChannelCommsDB.autoMow = state
    AutoTrimEnabled = state
    print("Auto Mow the Lawn: " .. (state and "Enabled" or "Disabled"))
end

-- Yard detection
local function PlayerIsInYard()
    local b = GetYardBounds()
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
        if inYard then ApplyCleanGrass() else ApplyFullGrass() end
    end
end

C_Timer.NewTicker(2, AutoTrimUpdate)

-- Yard tools
local function DefineYardAtCurrentPosition()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then print("Mow: Unable to determine map ID.") return end

    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then print("Mow: Unable to determine player position.") return end

    local centerX, centerY = pos.x, pos.y
    local boxSize = 0.01

    local b = ChannelCommsDB.yardBounds[playerKey]
    b.mapID = mapID
    b.minX = centerX - boxSize
    b.maxX = centerX + boxSize
    b.minY = centerY - boxSize
    b.maxY = centerY + boxSize

    print(string.format("Mow: Yard defined at map %d (%.3f, %.3f).", mapID, centerX, centerY))
end

local function ResetYardBounds()
    ChannelCommsDB.yardBounds[playerKey] = {}
    print("Mow: Yard bounds reset.")
end

local function DebugYardBounds()
    local b = GetYardBounds()
    print(string.format("Mow Debug: mapID=%d, X[%.3f-%.3f], Y[%.3f-%.3f]", b.mapID, b.minX, b.maxX, b.minY, b.maxY))
end

-- ============================================================
-- RESTORE SETTINGS ON LOGIN
-- ============================================================

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    -- Restore Mow state
    if ChannelCommsDB.mowEnabled then
        ApplyCleanGrass()
    else
        ApplyFullGrass()
    end

    -- Restore Auto Mow
    AutoTrimEnabled = ChannelCommsDB.autoMow
end)

-- ============================================================
-- POPUP WINDOW
-- ============================================================

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

    local title = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", popupFrame, "TOP", 0, -5)
    title:SetText("Master Toggle Menu")
    title:SetTextColor(0, 1, 1)

    local headerItem = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerItem:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", 110, -40)
    headerItem:SetWidth(150)
    headerItem:SetText("Items")

    local headerStatus = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerStatus:SetPoint("LEFT", headerItem, "RIGHT", 30, 0)
    headerStatus:SetWidth(80)
    headerStatus:SetText("Status")

    -- Row builder
    local function CreateRow(parent, yOffset, itemName, toggleFunction, initialState)
        local onButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        onButton:SetSize(40, 22)
        onButton:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)
        onButton:SetText("On")

        local offButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
        offButton:SetSize(40, 22)
        offButton:SetPoint("LEFT", onButton, "RIGHT", 10, 0)
        offButton:SetText("Off")

        local itemLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemLabel:SetPoint("LEFT", offButton, "RIGHT", 20, 0)
        itemLabel:SetWidth(120)
        itemLabel:SetText(itemName)

        local statusLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statusLabel:SetPoint("LEFT", itemLabel, "RIGHT", 40, 0)
        statusLabel:SetWidth(80)
        statusLabel:SetText(initialState and "On" or "Off")

        onButton:SetScript("OnClick", function()
            toggleFunction(true)
            statusLabel:SetText("On")
        end)

        offButton:SetScript("OnClick", function()
            toggleFunction(false)
            statusLabel:SetText("Off")
        end)
    end

    -- Initial states
    local isMusicOn = GetCVar("Sound_EnableMusic") == "1"
    local areTooltipsEnabled = not GameTooltip.override
    local isTalkingHeadVisible = TalkingHeadFrame:IsShown()
    local isMiniMapVisible = MinimapCluster:IsShown()
    local miniMapSize = MinimapCluster:GetScale()

    -- Add rows
    CreateRow(popupFrame, -60, "Music", function(state)
        SetCVar("Sound_EnableMusic", state and "1" or "0")
    end, isMusicOn)

    CreateRow(popupFrame, -90, "Tool Tips", function(state)
        GameTooltip.override = not state
        GameTooltip:SetScript("OnShow", GameTooltip.override and GameTooltip.Hide or GameTooltip.Show)
    end, areTooltipsEnabled)

    CreateRow(popupFrame, -120, "Talking Head", function(state)
        if state then TalkingHeadFrame:Show() else TalkingHeadFrame:Hide() end
    end, isTalkingHeadVisible)

    CreateRow(popupFrame, -150, "MiniMap", function(state)
        MinimapCluster:SetShown(state)
    end, isMiniMapVisible)

    CreateMapSizeRow(popupFrame, -180, function(size)
        MinimapCluster:SetScale(size)
    end, miniMapSize)

    -- Script errors
    CreateRow(popupFrame, -210, "Suppress Errors", function(state)
        ConsoleExec(state and "scriptErrors 0" or "scriptErrors 1")
    end, GetCVar("scriptErrors") == "1")

    -- Mow the Lawn (SYNCED TO SAVED STATE)
    CreateRow(popupFrame, -340, "Mow the Lawn", ToggleMowTheLawn, ChannelCommsDB.mowEnabled)

    -- Auto Mow (SYNCED TO SAVED STATE)
    CreateRow(popupFrame, -370, "Auto Mow", ToggleAutoTrim, ChannelCommsDB.autoMow)

    -- Yard tools
    local defineButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
    defineButton:SetSize(80, 22)
    defineButton:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", 20, -420)
    defineButton:SetText("Define Yard")
    defineButton:SetScript("OnClick", DefineYardAtCurrentPosition)

    local resetButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
    resetButton:SetSize(80, 22)
    resetButton:SetPoint("LEFT", defineButton, "RIGHT", 10, 0)
    resetButton:SetText("Reset Yard")
    resetButton:SetScript("OnClick", ResetYardBounds)

    local debugButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
    debugButton:SetSize(80, 22)
    debugButton:SetPoint("LEFT", resetButton, "RIGHT", 10, 0)
    debugButton:SetText("Debug Yard")
    debugButton:SetScript("OnClick", DebugYardBounds)

    local yardLabel = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    yardLabel:SetPoint("BOTTOMLEFT", defineButton, "TOPLEFT", 0, 6)
    yardLabel:SetWidth(140)
    yardLabel:SetText("Mow the Lawn Tools")

    popupFrame:Show()
end)