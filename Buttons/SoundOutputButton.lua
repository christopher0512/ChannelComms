-------------------------------------------------
-- This button lets you select the audio device 
-- that you want, I have monitor speakers, and a
-- Bluetooth speaker, and headphones, these lets 
-- me quicks switch if issue arise in a group and
-- the audio has issues.  Also added muting for 
-- the music (on/off) and muting over all Sound
-------------------------------------------------
-- Create the new button (global reference)
	_G.SoundOutputButton = CreateFrame("Button", "SoundOutputButton", UIParent, "UIPanelButtonTemplate")
	SoundOutputButton:SetSize(32, 32)
	SoundOutputButton:SetPoint("TOPLEFT", masterToggleButton, "TOPRIGHT", 1, 0)
	SoundOutputButton:SetNormalTexture("Interface\\Icons\\inv_helm_armor_earmuffs_b_01_alliance")
	SoundOutputButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	SoundOutputButton:EnableMouse(true)
	SoundOutputButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	SoundOutputButton:SetFrameStrata("TOOLTIP")
	SoundOutputButton:SetFrameLevel(10)

-- Tooltip setup
SoundOutputButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Select Audio Output")
    GameTooltip:Show()
end)

SoundOutputButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Popup window frame
local popupFrame = CreateFrame("Frame", "AudioOutputPopup", UIParent, "BackdropTemplate")
popupFrame:SetSize(300, 190) -- Made the popup longer by 40
popupFrame:SetPoint("CENTER", UIParent, "CENTER")
popupFrame:SetMovable(true)
popupFrame:EnableMouse(true)
popupFrame:RegisterForDrag("LeftButton")
popupFrame:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
popupFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
popupFrame:SetFrameStrata("DIALOG")
popupFrame:Hide()
popupFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
popupFrame:SetBackdropColor(0.2, 0.2, 0.2)

-- Title setup with red background
local titleBackground = popupFrame:CreateTexture(nil, "BACKGROUND")
titleBackground:SetColorTexture(0.5, 0, 0, 1) -- Dark red background
titleBackground:SetSize(200, 30) -- Shrunk the title area to fit the text
titleBackground:SetPoint("TOP", popupFrame, "TOP", 0, -5)

local title = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
title:SetPoint("CENTER", titleBackground, "CENTER")
title:SetText("Select Audio Output")
title:SetTextColor(1, 1, 0)

-- Close Button (X)
local closeButton = CreateFrame("Button", nil, popupFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", popupFrame, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function()
    popupFrame:Hide()
    SoundOutputButton:Enable()
end)

-- Dropdown menu for audio output sources
local audioDropdown = CreateFrame("Frame", "masterToggleButton", popupFrame, "UIDropDownMenuTemplate")
audioDropdown:SetPoint("TOP", titleBackground, "BOTTOM", 0, -5) -- Scooted the dropdown up slightly
UIDropDownMenu_SetWidth(audioDropdown, 200)

-- Function to populate audio devices
local audioDevices = {
    "System Default",
    "Samsung (NVIDIA High Definition Audio)",
    "Speakers (2- Bose Revolve SoundLink)" -- Example devices
}

local function PopulateAudioDropdown()
    UIDropDownMenu_Initialize(audioDropdown, function(self, level, menuList)
        for i, deviceName in ipairs(audioDevices) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = deviceName
            info.func = function()
                UIDropDownMenu_SetSelectedValue(audioDropdown, deviceName)
             --   print("Selected audio device:", deviceName)
                SetCVar("Sound_OutputDriverIndex", i - 1) -- Set index based on dropdown selection
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end
PopulateAudioDropdown()

-- Refresh Devices Button
local refreshButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
refreshButton:SetSize(120, 32)
refreshButton:SetPoint("BOTTOM", popupFrame, "BOTTOM", 0, 20)
refreshButton:SetText("Refresh Devices")
refreshButton:SetScript("OnClick", function()
    print("Refreshing audio devices...")
    PopulateAudioDropdown() -- Repopulates the dropdown
end)

-- Music control buttons (side by side)
local musicOnButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
musicOnButton:SetSize(80, 22)
musicOnButton:SetPoint("BOTTOMLEFT", popupFrame, "BOTTOMLEFT", 60, 90) -- Scooted music buttons up
musicOnButton:SetText("Music Off")
musicOnButton:SetScript("OnClick", function()
    SetCVar("Sound_EnableMusic", 0)
    print("Music turned on!")
end)

local musicOffButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
musicOffButton:SetSize(80, 22)
musicOffButton:SetPoint("BOTTOMRIGHT", popupFrame, "BOTTOMRIGHT", -60, 90) -- Scooted music buttons up
musicOffButton:SetText("Music On")
musicOffButton:SetScript("OnClick", function()
    SetCVar("Sound_EnableMusic", 1)
    print("Music turned off!")
end)

-- Mute and Unmute buttons
local muteButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
muteButton:SetSize(80, 22)
muteButton:SetPoint("BOTTOMLEFT", musicOnButton, "BOTTOMLEFT", 0, -30) -- Aligned with music buttons
muteButton:SetText("Mute")
muteButton:SetScript("OnClick", function()
    SetCVar("Sound_MasterVolume", 0)
    print("Sound muted!")
end)

local unmuteButton = CreateFrame("Button", nil, popupFrame, "UIPanelButtonTemplate")
unmuteButton:SetSize(80, 22)
unmuteButton:SetPoint("BOTTOMRIGHT", musicOffButton, "BOTTOMRIGHT", 0, -30) -- Aligned with music buttons
unmuteButton:SetText("Unmute")
unmuteButton:SetScript("OnClick", function()
    SetCVar("Sound_MasterVolume", 1)
    print("Sound unmuted!")
end)

-- Button to toggle popup
SoundOutputButton:SetScript("OnClick", function(self)
    if popupFrame:IsShown() then
        popupFrame:Hide()
        self:Enable()
    else
        popupFrame:Show()
        self:Disable()
    end
end)