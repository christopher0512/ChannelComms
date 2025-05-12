-- Helper function to determine chat channel
local function GetChatChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    else
        return "SAY"
    end
end

-- Create the new "tymenubutton"
_G.tymenubutton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
tymenubutton:SetSize(32, 32) -- Updated size for better visibility
tymenubutton:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -22) -- Positioned below the emote buttons
tymenubutton:SetNormalTexture("Interface\\Icons\\ui_chat")

-- Tooltip replacement
tymenubutton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Thank You Menu", 1, 1, 1)
    GameTooltip:Show()
end)
tymenubutton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Disable button while popup is active
tymenubutton:SetScript("OnClick", function()
    if not _G.tyPopupFrame:IsShown() then
        _G.tyPopupFrame:Show()
        tymenubutton:Disable()
    end
end)

-- Create Popup Window
_G.tyPopupFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
tyPopupFrame:SetSize(130, 170)
tyPopupFrame:SetPoint("CENTER")
tyPopupFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
tyPopupFrame:SetBackdropColor(0, 0, 0, 0.7) -- Transparent black
tyPopupFrame:Hide()

-- Make popup draggable
tyPopupFrame:EnableMouse(true)
tyPopupFrame:SetMovable(true)
tyPopupFrame:RegisterForDrag("LeftButton")
tyPopupFrame:SetScript("OnDragStart", tyPopupFrame.StartMoving)
tyPopupFrame:SetScript("OnDragStop", tyPopupFrame.StopMovingOrSizing)

-- Title Configuration
local title = tyPopupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("TY4 The...")
title:SetTextColor(1, 1, 0) -- Yellow

-- Create Popup Buttons
local function createPopupButton(name, text, point, yOffset, chatMessage)
    local button = CreateFrame("Button", name, tyPopupFrame, "UIPanelButtonTemplate")
    button:SetSize(80, 22)
    button:SetPoint("TOP", tyPopupFrame, point, 0, yOffset)
    button:SetText(text)
    button:SetScript("OnClick", function()
        SendChatMessage(chatMessage, GetChatChannel())
    end)
    return button
end

local cookiesButton = createPopupButton("CookiesButton", "Cookies", "TOP", -30, "Thank you for the Cookies") -- Adjusted spacing
local tableButton = createPopupButton("TableButton", "Table", "TOP", -60, "Thank you for the Mage Table") -- Adjusted spacing
local portalButton = createPopupButton("PortalButton", "Portal", "TOP", -90, "Thank you for the Portal") -- Adjusted spacing
local foodButton = createPopupButton("FoodButton", "Food", "TOP", -120, "Thank you for the Food") -- Adjusted spacing

-- Add "X" in the upper-right corner to close the popup
local closeButton = CreateFrame("Button", nil, tyPopupFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", tyPopupFrame, "TOPRIGHT", -5, -5) -- Positioned in the upper-right corner
closeButton:SetScript("OnClick", function()
    tyPopupFrame:Hide()
    tymenubutton:Enable()
end)