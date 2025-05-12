-------------------------------------------------------------
-- Played Time Button
-------------------------------------------------------------
-- Create the P Button
_G.pButton = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
pButton:SetSize(24, 22) -- Match the size of the /R button
pButton:SetPoint("RIGHT", titleBar, "RIGHT", -24, 0) -- Position it next to the close button
pButton:SetText("P") -- Button label
pButton:SetNormalFontObject(GameFontNormalSmall) -- Match the style
pButton:GetFontString():SetTextColor(1, 1, 0) -- Yellow text color

-- Tooltip for P Button
pButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(pButton, "ANCHOR_TOP")
    GameTooltip:SetText("Time Played on this Character", 1, 1, 1)
    GameTooltip:Show()
end)
pButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- P Button Click Action
pButton:SetScript("OnClick", function()
    pButton:Disable() -- Disable while active
    CreatePlayedWindow()
    playedFrame:Show()
end)

-- Create Played-Time Window
local function CreatePlayedWindow()
    if _G.playedFrame then return end -- Prevent duplicate frames

    -- Main played-time window
    _G.playedFrame = CreateFrame("Frame", "PlayedFrame", UIParent, "BackdropTemplate")
    playedFrame:SetSize(300, 100) -- Adjust height to fit additional info
    playedFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    playedFrame:SetMovable(true)
    playedFrame:EnableMouse(true)
    playedFrame:RegisterForDrag("LeftButton")
    playedFrame:SetClampedToScreen(true)
    playedFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    playedFrame:SetBackdropColor(0, 0, 0, 0.8) -- Semi-transparent background

    -- Title Bar
    local titleBackground = playedFrame:CreateTexture(nil, "ARTWORK")
    titleBackground:SetSize(300, 30)
    titleBackground:SetPoint("TOP", playedFrame, "TOP", 0, 0)
    titleBackground:SetColorTexture(0.5, 0, 0, 1) -- Dark red background

    local titleText = playedFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleText:SetPoint("CENTER", titleBackground, "CENTER", 0, 0)
    titleText:SetText("|cffffd700Total Time Played|r") -- Yellow title

    -- Close Button
    local closeButton = CreateFrame("Button", nil, playedFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", playedFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        playedFrame:Hide()
        pButton:Enable() -- Re-enable P button when closing
    end)

    -- Played Time Display
    local playedText = playedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playedText:SetPoint("TOPLEFT", playedFrame, "TOPLEFT", 10, -50)
    playedText:SetJustifyH("LEFT") -- Align text to the left
    playedText:SetText("Fetching played time...") -- Temporary placeholder

    -- Suppress Chat Output
    local originalChatFrame_OnEvent = ChatFrame_OnEvent
    ChatFrame_OnEvent = function(self, event, ...)
        if event == "TIME_PLAYED_MSG" then return end
        return originalChatFrame_OnEvent(self, event, ...)
    end

    -- Fetch Played Time Data
    local function GetPlayedTime()
        RequestTimePlayed() -- Request `/played` data from WoW API
    end

    -- Event Listener for Played Time
    playedFrame:SetScript("OnEvent", function(self, event, totalTime, levelTime)
        if event == "TIME_PLAYED_MSG" then
            -- Calculate class-specific time (total time minus level time for simplicity)
            local classTime = totalTime - levelTime

            local formattedText = string.format(
                "|cffffd700Total Time Played:|r |cff00ff00%s|r\n|cffffd700Time Played This Level:|r |cff00ff00%s|r\n|cffffd700Time Played This Class:|r |cff00ff00%s|r",
                SecondsToTime(totalTime),
                SecondsToTime(levelTime),
                SecondsToTime(classTime)
            )
            playedText:SetText(formattedText)
        end
    end)

    -- Register Event & Fetch Data
    playedFrame:RegisterEvent("TIME_PLAYED_MSG")
    GetPlayedTime()
end

-- P Button Click Action
pButton:SetScript("OnClick", function()
    pButton:Disable() -- Disable while active
    CreatePlayedWindow()
    playedFrame:Show()
end)