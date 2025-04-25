--------------------------------------------------------------
-- Create Quest Checker Button and its popup window
-- you type in the quest number and it lets you know if you 
-- have completed the quest and looks up the name of the Quest
-- echoing this back to you in chat so you know from the text
--------------------------------------------------------------
-- Create Quest Checker Button
_G.questCheckButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
questCheckButton:SetSize(32, 32) -- Adjust size
questCheckButton:SetPoint("LEFT", tymenubutton, "RIGHT", 1, 0) -- Positioned next to ty4Portal button

-- Add an icon for the button
local questCheckIcon = questCheckButton:CreateTexture(nil, "ARTWORK")
questCheckIcon:SetTexture("Interface\\Icons\\inv_misc_scrollrolled02b") -- Quest completion icon
questCheckIcon:SetAllPoints(questCheckButton)

questCheckButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Use the number of the quest to see if you completed it")
    GameTooltip:Show()
end)

questCheckButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Add functionality to open popup input box
questCheckButton:SetScript("OnClick", function()
    questCheckButton:Disable() -- Disable the button while the popup window is active

    -- Create popup input box for quest number
    local popupFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
    popupFrame:SetSize(300, 400) -- Updated dimensions: Width 300, Height 400
    popupFrame:SetPoint("CENTER", UIParent, "CENTER") -- Centered on the screen
    popupFrame:SetAlpha(0.85) -- Make the frame slightly see-through
    popupFrame:SetMovable(true) -- Enable dragging
    popupFrame:EnableMouse(true) -- Allow mouse interaction
    popupFrame:RegisterForDrag("LeftButton") -- Register the left mouse button for dragging
    popupFrame:SetScript("OnDragStart", popupFrame.StartMoving) -- Start dragging
    popupFrame:SetScript("OnDragStop", popupFrame.StopMovingOrSizing) -- Stop dragging

    -- Add functionality to re-enable the button when the popup is closed
    popupFrame:SetScript("OnHide", function()
        questCheckButton:Enable() -- Re-enable the button when the popup is closed
    end)

    -- Add a background for the title
    local titleBackground = popupFrame:CreateTexture(nil, "BACKGROUND")
    titleBackground:SetColorTexture(0.5, 0, 0) -- Dark red background (RGB: 0.5, 0, 0)
    titleBackground:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", -4, -4) -- Background starts slightly inset
    titleBackground:SetPoint("TOPRIGHT", popupFrame, "TOPRIGHT", -4, -4) -- Background stretches across
    titleBackground:SetHeight(30) -- Height of the title bar

    -- Add a title to the popup
    local popupTitle = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    popupTitle:SetPoint("CENTER", titleBackground, "CENTER", 0, 8) -- Increase offset to move text higher
    popupTitle:SetText("Enter Quest Number")
    popupTitle:SetTextColor(1, 1, 0) -- Yellow text (RGB: 1, 1, 0)

    -- Create the input box for entering the quest ID directly under the title
    local popupEditBox = CreateFrame("EditBox", nil, popupFrame, "InputBoxTemplate")
    popupEditBox:SetSize(150, 20) -- Adjust size
    popupEditBox:SetPoint("TOP", titleBackground, "BOTTOM", 0, -10) -- Position directly below the title
    popupEditBox:SetAutoFocus(true)
    popupEditBox:SetFontObject(GameFontNormal)

    -- Create a scrollable text area
    local scrollFrame = CreateFrame("ScrollFrame", nil, popupFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(260, 300) -- Adjust size to fit the remaining space
    scrollFrame:SetPoint("TOP", popupEditBox, "BOTTOM", 0, -10) -- Position below the input box

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(260, 300) -- Same size as the scroll frame
    scrollFrame:SetScrollChild(scrollChild)

    local resultsText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    resultsText:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -5) -- Align text in the top-left corner
    resultsText:SetWidth(250)
    resultsText:SetJustifyH("LEFT")
    resultsText:SetJustifyV("TOP")
    resultsText:SetText("") -- Start with empty text

    -- Add Enter key functionality to trigger quest lookup
popupEditBox:SetScript("OnEnterPressed", function()
    local questID = tonumber(popupEditBox:GetText()) -- Convert input text to a number

    -- Validate quest ID input
    if not questID then
        resultsText:SetText((resultsText:GetText() or "") .. "\n|cffff0000Error: Input is empty or not numeric.|r\n|cffffcc00>>------<<|r")
        popupEditBox:SetText("") -- Clear input field
        return
    end

    -- Get quest name
    local questName = C_QuestLog.GetTitleForQuestID(questID) or "Unknown Quest"

    -- Check quest completion
    local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(questID)
	local resultMessage
	if isCompleted then
		resultMessage = "|cff00ff00" .. questID .. " - Complete\n" .. "|r"
		resultMessage = resultMessage .. " - " .. questName .. "\n|cffffcc00>>------>" .. "|r" -- Add custom indicator
	else
		resultMessage = "|cffff0000" .. questID .. " - Not complete\n" .. "|r"
		resultMessage = resultMessage .. " - " .. questName .. "\n|cffffcc00<------<<" .. "|r" -- Add custom indicator
	end
    

    -- Safely update resultsText
    resultsText:SetText((resultsText:GetText() or "") .. "\n" .. resultMessage)
    popupEditBox:SetText("") -- Clear input field after lookup
end)

    popupFrame:Show() -- Ensure the popup appears
end)

questCheckButton:Show() -- Ensure the button appears