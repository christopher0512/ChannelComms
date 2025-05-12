-------------------------------------------------------------
-- Add a SoulWell button (only if the character is a Warlock)
-------------------------------------------------------------
	local _, playerClass = UnitClass("player")

	if playerClass == "WARLOCK" then
    
-- Create the SoulWell button
    local soulWellButton = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
    soulWellButton:SetSize(64, 22) -- Larger size for longer label
    soulWellButton:SetPoint("LEFT", reloadButton, "RIGHT", 0, 0) -- Positioned to the right of the reload button
    soulWellButton:SetText("SoulWell") -- Button label
    soulWellButton:SetNormalFontObject(GameFontNormalSmall) -- Match the style with a smaller font
    soulWellButton:GetFontString():SetTextColor(0, 1, 0) -- Green text color

-- Define fun messages
    local funMessages = {
        "Get your cookies here, fresh from the void!",
        "Step right up and grab a snack for your soul!",
        "Soulwell is up! Remember, I don't do refunds if your soul tastes like ash.",
        "Dark magic snacks: satisfaction guaranteed!",
        "Free cookies for all who dare!",
        "Taste the void, one cookie at a time!",
        "Snacks so good, you'll want another life!",
        "The Void's finest baked goods!",
        "Step right up! Fresh Healthstones, guaranteed not to taste like ashes… probably.",
        "Feast upon the darkness—it's cookie time!",
        "Made with love... and a pinch of fel energy!",
        "Soulwell is up! Come to the dark side, we have cookies.",
    }

-- Add functionality to SoulWell button
    soulWellButton:SetScript("OnClick", function()
        local channel
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
            channel = "INSTANCE_CHAT"
        elseif IsInRaid() then
            channel = "RAID"
        elseif IsInGroup() then
            channel = "PARTY"
        else
            channel = "SAY"
        end
        local randomMessage = funMessages[math.random(#funMessages)]
        SendChatMessage(randomMessage, channel)
    end)
    
-- Force visibility for debugging
    soulWellButton:Show()
end