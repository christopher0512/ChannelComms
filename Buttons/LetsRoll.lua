-------------------------------------------------------------
-- Roll Button for rolling on gear or stuff
-------------------------------------------------------------
_G.rollButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
rollButton:SetSize(32, 32) -- Adjust button size
rollButton:SetPoint("LEFT", gearScoreButton, "RIGHT", 1, 0) -- Positioned next to Gear Score button
rollButton:SetNormalTexture("Interface\\Icons\\ability_rogue_keepitrolling") -- Set icon

-- Function to handle rolling and sending result to chat
local function RollAndPost()
    local rollResult = math.random(1, 100) -- Simulates /roll
    local chatType = IsInRaid() and "RAID" or IsInGroup() and "PARTY" or IsInInstance() and "INSTANCE_CHAT" or "SAY"
    local message = string.format("Rolling... [%d]", rollResult)

    SendChatMessage(message, chatType)
    -- print("Roll Button Pressed: Result =", rollResult, "Chat Type =", chatType) -- -- Debug output
end

rollButton:SetScript("OnClick", RollAndPost)

-- Tooltip for clarification
rollButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(rollButton, "ANCHOR_TOP")
    GameTooltip:SetText("Roll on Gear (1-100)", 1, 1, 1)
    GameTooltip:Show()
end)

rollButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
rollButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)