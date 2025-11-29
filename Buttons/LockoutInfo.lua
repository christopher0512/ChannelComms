-- Create Lockout Viewer Button
_G.lockoutButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
lockoutButton:SetSize(32, 32)
lockoutButton:SetPoint("LEFT", masterToggleButton, "RIGHT", 5, 0)
lockoutButton:SetNormalTexture("Interface\\Icons\\inv_10_misc_dragonorb_color1")

-- Tooltip
lockoutButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(lockoutButton, "ANCHOR_TOP")
    GameTooltip:SetText("View Invasion Points, Dungeon and Raid Lockouts", 1, 1, 1)
    GameTooltip:Show()
end)
lockoutButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- Argus Invasion Point Quest IDs
local invasionQuests = {
    -- Normal Invasion Points
    [48282] = "Invasion Point: Aurinor",
    [48283] = "Invasion Point: Bonich",
    [48284] = "Invasion Point: Cen'gar",
    [48285] = "Invasion Point: Naigtal",
    [48286] = "Invasion Point: Sangua",
    [48287] = "Invasion Point: Val",

    -- Greater Invasion Points
    [49075] = "Greater Invasion Point: Matron Folnuna",
    [49183] = "Greater Invasion Point: Mistress Alluradel",
    [49077] = "Greater Invasion Point: Inquisitor Meto",
    [49078] = "Greater Invasion Point: Occularus",
    [49079] = "Greater Invasion Point: Sotanathor",
    [49080] = "Greater Invasion Point: Pit Lord Vilemus",
}

-- Create Lockout Window
local function CreateLockoutWindow()
    if _G.lockoutFrame then return end -- Prevent duplicate frames

    -- Main frame
    _G.lockoutFrame = CreateFrame("Frame", "LockoutFrame", UIParent, "BackdropTemplate")
    lockoutFrame:SetSize(460, 350)
    lockoutFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    lockoutFrame:SetMovable(true)
    lockoutFrame:EnableMouse(true)
    lockoutFrame:RegisterForDrag("LeftButton")
    lockoutFrame:SetClampedToScreen(true)
    lockoutFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    lockoutFrame:SetBackdropColor(0, 0, 0, 0.8)

    -- Dragging
    lockoutFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    lockoutFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    -- Title background (full-width red bar)
    local titleBG = lockoutFrame:CreateTexture(nil, "BACKGROUND")
    titleBG:SetColorTexture(1, 0, 0, 0.9)
    titleBG:SetPoint("TOPLEFT", lockoutFrame, "TOPLEFT", 4, -4)
    titleBG:SetPoint("TOPRIGHT", lockoutFrame, "TOPRIGHT", -4, -4)
    titleBG:SetHeight(32)

    -- Title text (yellow letters centered on the bar)
    local title = lockoutFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("CENTER", titleBG, "CENTER", 0, -2)
    title:SetText("Dungeon and Raid Lockouts")
    title:SetTextColor(1, 1, 0)

    -- Close Button
    local closeButton = CreateFrame("Button", nil, lockoutFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", lockoutFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        lockoutFrame:Hide()
        lockoutButton:Enable()
    end)

    -- ScrollFrame container
    local scrollFrame = CreateFrame("ScrollFrame", nil, lockoutFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", lockoutFrame, "TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", lockoutFrame, "BOTTOMRIGHT", -30, 10)

    -- Content frame inside scroll
    local contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(400, 240)
    scrollFrame:SetScrollChild(contentFrame)

    -- Populate Lockouts
	local function UpdateLockoutList()
		local numInstances = GetNumSavedInstances()
		local yOffset = 0

		-- Clear previous entries
		for _, child in ipairs({contentFrame:GetChildren()}) do
			child:Hide()
		end

		-- Separate raids and dungeons
		local raids, dungeons = {}, {}

		for i = 1, numInstances do
			local name, _, reset, difficultyID, locked, extended, instanceID, isRaid, maxPlayers, difficultyName = GetSavedInstanceInfo(i)

			if name and reset and reset > 0 then
				local resetTime = SecondsToTime(reset)
				local difficulty = difficultyName or "Unknown"
				local entry = string.format("%s (%s) - Resets in %s", name, difficulty, resetTime)

				if isRaid then
					table.insert(raids, entry)
				else
					table.insert(dungeons, entry)
				end
			end
		end

		-- Sort alphabetically
		table.sort(raids)
		table.sort(dungeons)

		-- Raids header
		if #raids > 0 then
			local raidHeader = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			raidHeader:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)
			raidHeader:SetText("Raids Completed")
			yOffset = yOffset + 20

			for _, text in ipairs(raids) do
				local fs = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)
				fs:SetText(text)
				fs:Show()
				yOffset = yOffset + 20
			end
		end

		-- Dungeons header
		if #dungeons > 0 then
			local dungeonHeader = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			dungeonHeader:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)
			dungeonHeader:SetText("Dungeons Completed")
			yOffset = yOffset + 20

			for _, text in ipairs(dungeons) do
				local fs = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				fs:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)
				fs:SetText(text)
				fs:Show()
				yOffset = yOffset + 20
			end
		end

		-- Argus Invasion Points header
		local invasionHeader = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		invasionHeader:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)
		invasionHeader:SetText("Argus Invasion Points (Completed)")
		yOffset = yOffset + 20

		for questID, invasionName in pairs(invasionQuests) do
			local completed = C_QuestLog.IsQuestFlaggedCompleted(questID)
			if completed then
				local invasionText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				invasionText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)
				invasionText:SetText(string.format("%s - |cff00ff00Completed|r", invasionName))
				invasionText:Show()
				yOffset = yOffset + 20
			end
		end

		contentFrame:SetHeight(yOffset)
	end

    -- Expose function
    lockoutFrame.UpdateLockoutList = UpdateLockoutList

    -- Initial update
    UpdateLockoutList()

    -- Auto-refresh on events
    lockoutFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
    lockoutFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    lockoutFrame:SetScript("OnEvent", function(self, event)
        self.UpdateLockoutList()
    end)
end

-- Button Click Action
lockoutButton:SetScript("OnClick", function()
    lockoutButton:Disable()
    CreateLockoutWindow()
    lockoutFrame:Show()
    lockoutFrame.UpdateLockoutList() -- refresh each time opened
end)