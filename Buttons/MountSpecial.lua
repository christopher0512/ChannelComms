--------------------------------------------------
-- Add the Special button to perform /mountspecial
-- this button will only appear if the character
-- is mounted, the window actively checks for this
--------------------------------------------------
	local specialButton = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
	specialButton:SetSize(64, 22) -- Button size
	specialButton:SetPoint("RIGHT", titleBar, "RIGHT", -48, 0) -- Positioned next to the X button
	specialButton:SetText("Special") -- Button label
	specialButton:SetNormalFontObject(GameFontNormalSmall) -- Match the style with a smaller font
	specialButton:GetFontString():SetTextColor(0, 0.5, 2.5) -- Blue text color

-- Add functionality to the Special button
	specialButton:SetScript("OnClick", function()
		DoEmote("mountspecial") -- Execute the /mountspecial emote
	end)

-- Function to update button visibility based on mounting status
	local function UpdateButtonVisibility()
		if IsMounted() then
			specialButton:Show()
		else
			specialButton:Hide()
		end
	end

-- Event frame to listen for mounting status changes
	local eventFrame = CreateFrame("Frame")
	eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED") -- Event triggered when mount status changes
	eventFrame:SetScript("OnEvent", UpdateButtonVisibility)

-- Initialize button visibility
	UpdateButtonVisibility()