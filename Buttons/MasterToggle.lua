-- Create the Master Toggle Button
_G.masterToggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
masterToggleButton:SetSize(32, 32)
masterToggleButton:SetPoint("LEFT", questCheckButton, "RIGHT", 1, 0)

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
-- Create the Popup Window
local popupFrame

masterToggleButton:SetScript("OnClick", function()
    if popupFrame and popupFrame:IsShown() then
        popupFrame:Hide()
        return
    end

    popupFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
    popupFrame:SetSize(400, 400)
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

    popupFrame:Show()
end)