---------------------------------------------------
-- The Trade Inspector button will show up another 
-- players gear and let you decide if you wish to
-- trade with that player if you get a drop you dont
-- need, Press trade in the window, the trade window
-- will open as well as your bags
----------------------------------------------------
-- Show TradePopup Function
function ShowTradePopup()
    _G.TradePopupFrame:Show()
    local targetName = UnitName("target") or "No Target Selected" -- Fallback for no target

    -- Update window title with target's name
    TradePopupFrame.title:SetText(targetName .. "'s Gear") -- Dynamically set title
    TradePopupFrame.title:SetPoint("TOP", TradePopupFrame, "TOP", 0, -15) -- Center title dynamically

    -- Check if a player is targeted
    if not UnitIsPlayer("target") then
        if not TradePopupFrame.warning then
            TradePopupFrame.warning = TradePopupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            TradePopupFrame.warning:SetPoint("CENTER")
            TradePopupFrame.warning:SetText("Target a Player before\nclicking on the button.")
        end
        TradePopupFrame.warning:Show()

        -- Auto-close popup after 5 seconds
        C_Timer.After(5, function()
            TradePopupFrame:Hide()
            _G.TradeInspectorButton:Enable()
            TradePopupFrame.warning:Hide() -- Ensure warning disappears
        end)
    else
        -- Hide warning if it exists
        if TradePopupFrame.warning then
            TradePopupFrame.warning:Hide()
        end

        -- Call the DisplayGearScores function
        DisplayGearScores(0)

        -- Trade Button
        if not TradePopupFrame.tradeButton then
            TradePopupFrame.tradeButton = CreateFrame("Button", nil, TradePopupFrame, "UIPanelButtonTemplate")
            TradePopupFrame.tradeButton:SetSize(80, 22)
            TradePopupFrame.tradeButton:SetPoint("BOTTOM", TradePopupFrame, "BOTTOM", 0, 10)
            TradePopupFrame.tradeButton:SetText("Trade")
            TradePopupFrame.tradeButton:SetScript("OnClick", function()
                InitiateTrade("target")
                OpenAllBags() -- Opens bags when trade is initiated
            end)
        end
        TradePopupFrame.tradeButton:Show()
    end
end

-- DisplayGearScores Function
function DisplayGearScores(retryCount)
    if retryCount == 0 then
        NotifyInspect("target") -- Force inspection
    end

    local slotIDs = {
        {1, "Head"},
        {2, "Neck"},
        {3, "Shoulder"},
        {15, "Back"},
        {5, "Chest"},
        {9, "Wrist"},
        {10, "Hands"},
        {6, "Waist"},
        {7, "Legs"},
        {8, "Feet"},
        {11, "Finger 1"},
        {12, "Finger 2"},
        {13, "Trinket 1"},
        {14, "Trinket 2"},
        {16, "Main-Hand"},
        {17, "Off-Hand"},
        {18, "Ranged"}
    }

    local gearScores = {}
    local displayText = ""
    local allLoaded = true

    -- Use ipairs to ensure proper order
    for _, slotData in ipairs(slotIDs) do
        local slotID, readableName = slotData[1], slotData[2]
        local itemLink = GetInventoryItemLink("target", slotID)
        if itemLink then
            local _, _, _, itemLevel = GetItemInfo(itemLink)
            if itemLevel then
                gearScores[slotID] = itemLevel
                displayText = displayText .. readableName .. ": " .. itemLevel .. "\n"
            else
                allLoaded = false
                displayText = displayText .. readableName .. ": Loading...\n"
            end
        else
            allLoaded = false
            displayText = displayText .. readableName .. ": Not Equipped\n"
        end
    end

    if not TradePopupFrame.gearText then
        TradePopupFrame.gearText = TradePopupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        TradePopupFrame.gearText:SetPoint("TOPLEFT", TradePopupFrame, "TOPLEFT", 24, -50)
        TradePopupFrame.gearText:SetJustifyH("LEFT")
    end
    TradePopupFrame.gearText:SetText(displayText)

    if not allLoaded and retryCount < 9 then
        C_Timer.After(0.75, function() DisplayGearScores(retryCount + 1) end)
    else
       -- print("TradeInspector: Gear scores successfully retrieved.")
    end
end

-- Create the new "TradeInspector" button
_G.TradeInspectorButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
TradeInspectorButton:SetSize(32, 32)
TradeInspectorButton:SetPoint("TOPLEFT", rollButton, "TOPRIGHT", 1, 0)
TradeInspectorButton:SetNormalTexture("Interface\\Icons\\inv_professions_inscription_scribesmagnifyingglass_silver")

-- Disable button while popup is active
TradeInspectorButton:SetScript("OnClick", function()
    if not _G.TradePopupFrame:IsShown() then
        ShowTradePopup() -- Call the globally defined function
        TradeInspectorButton:Disable()
    end
end)

-- Tooltip replacement
TradeInspectorButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Trade Inspector", 1, 1, 1)
    GameTooltip:Show()
end)
TradeInspectorButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Create Popup Window (adjusted size and title alignment)
_G.TradePopupFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
TradePopupFrame:SetSize(260, 400) -- Extended height to 400
TradePopupFrame:SetPoint("CENTER")
TradePopupFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
TradePopupFrame:SetBackdropColor(0, 0, 0, 0.7) -- Transparent black
TradePopupFrame:Hide()
TradePopupFrame:EnableMouse(true)
TradePopupFrame:SetMovable(true)
TradePopupFrame:RegisterForDrag("LeftButton")
TradePopupFrame:SetScript("OnDragStart", TradePopupFrame.StartMoving)
TradePopupFrame:SetScript("OnDragStop", TradePopupFrame.StopMovingOrSizing)

-- Title Configuration with Dark Red Background
local titleBackground = TradePopupFrame:CreateTexture(nil, "BACKGROUND")
titleBackground:SetSize(260, 30) -- Matches popup width
titleBackground:SetPoint("TOP", TradePopupFrame, "TOP", 0, -10)
titleBackground:SetColorTexture(0.35, 0, 0, 1) -- Dark red background under the title

TradePopupFrame.title = TradePopupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
TradePopupFrame.title:SetPoint("TOP", titleBackground, "CENTER") -- Centered dynamically
TradePopupFrame.title:SetText("Party Member Inspector") -- Placeholder text
TradePopupFrame.title:SetTextColor(1, 1, 0) -- Yellow

-- "X" Close Button
local closeButton = CreateFrame("Button", nil, TradePopupFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", TradePopupFrame, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function()
    TradePopupFrame:Hide()
    TradeInspectorButton:Enable()
end)