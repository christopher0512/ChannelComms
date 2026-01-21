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
    -- Normal Invasion Points (world quests, repeatable daily)
    [48282] = "Invasion Point: Aurinor",
    [48283] = "Invasion Point: Bonich",
    [48284] = "Invasion Point: Cen'gar",
    [48285] = "Invasion Point: Naigtal",
    [48286] = "Invasion Point: Sangua",
    [48287] = "Invasion Point: Val",

    -- Greater Invasion Points (weekly bosses)
    [49075] = "Greater Invasion Point: Matron Folnuna",
    [49183] = "Greater Invasion Point: Mistress Alluradel",
    [49077] = "Greater Invasion Point: Inquisitor Meto",
    [49078] = "Greater Invasion Point: Occularus",
    [49079] = "Greater Invasion Point: Sotanathor",
    [49080] = "Greater Invasion Point: Pit Lord Vilemus",
}

-- Track completion dates for lesser invasions
local invasionCompletionDates = {}
-- Create Lockout Window
local function CreateLockoutWindow()
    if _G.lockoutFrame then return end -- Prevent duplicate frames

    -- Main frame
    _G.lockoutFrame = CreateFrame("Frame", "LockoutFrame", UIParent, "BackdropTemplate")
    lockoutFrame:SetSize(460, 480)
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
    lockoutFrame:SetBackdropColor(0, 0, 0, .90)

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
    contentFrame:SetSize(460, 480)
    scrollFrame:SetScrollChild(contentFrame)
    -- Populate Lockouts
    local function UpdateLockoutList()
        local numInstances = GetNumSavedInstances()
        local yOffset = 0

        -- Clear previous entries (hides previous text and buttons)
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

		-- Raids header with maroon background and bold yellow text
		if #raids > 0 then
			local lineWidth = 386
			local lineHeight = 20

			local raidHeaderFrame = CreateFrame("Frame", nil, contentFrame)
			raidHeaderFrame:SetSize(lineWidth + 40, 22)
			raidHeaderFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)

			local raidHeaderBG = raidHeaderFrame:CreateTexture(nil, "BACKGROUND")
			raidHeaderBG:SetAllPoints(raidHeaderFrame)
			raidHeaderBG:SetColorTexture(0.5, 0.0, 0.0, 0.95) -- maroon

			local raidHeader = raidHeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			raidHeader:SetPoint("CENTER", raidHeaderFrame, "CENTER", 0, 0)
			raidHeader:SetText("Raids")
			raidHeader:SetTextColor(1, 1, 0) -- yellow
			raidHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE") -- bold look

			yOffset = yOffset + 26

			for _, text in ipairs(raids) do
				local lineFrame = CreateFrame("Frame", nil, contentFrame)
				lineFrame:SetSize(lineWidth + 40, lineHeight)
				lineFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)

				local fs = lineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				fs:SetPoint("LEFT", lineFrame, "LEFT", 0, 0)
				fs:SetWidth(lineWidth)
				fs:SetJustifyH("LEFT")
				fs:SetText(text)
				fs:Show()

				yOffset = yOffset + lineHeight + 2
			end

			-- extra blank line after last raid
			yOffset = yOffset + 8
		end

		-- Dungeons header with maroon background and bold yellow text
		if #dungeons > 0 then
			local lineWidth = 386
			local lineHeight = 20

			local dungeonHeaderFrame = CreateFrame("Frame", nil, contentFrame)
			dungeonHeaderFrame:SetSize(lineWidth + 40, 22)
			dungeonHeaderFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)

			local dungeonHeaderBG = dungeonHeaderFrame:CreateTexture(nil, "BACKGROUND")
			dungeonHeaderBG:SetAllPoints(dungeonHeaderFrame)
			dungeonHeaderBG:SetColorTexture(0.5, 0.0, 0.0, 0.95) -- maroon

			local dungeonHeader = dungeonHeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			dungeonHeader:SetPoint("CENTER", dungeonHeaderFrame, "CENTER", 0, 0)
			dungeonHeader:SetText("Dungeons")
			dungeonHeader:SetTextColor(1, 1, 0) -- yellow
			dungeonHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE") -- bold look

			yOffset = yOffset + 26

			for _, text in ipairs(dungeons) do
				local lineFrame = CreateFrame("Frame", nil, contentFrame)
				lineFrame:SetSize(lineWidth + 40, lineHeight)
				lineFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)

				local fs = lineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				fs:SetPoint("LEFT", lineFrame, "LEFT", 0, 0)
				fs:SetWidth(lineWidth)
				fs:SetJustifyH("LEFT")
				fs:SetText(text)
				fs:Show()

				yOffset = yOffset + lineHeight + 2
			end

			-- extra blank line after last dungeon
			yOffset = yOffset + 8
		end
		
		-- Argus Invasion Points header with maroon background and bold yellow text
		local lineWidth = 386
		local lineHeight = 22

		local invasionHeaderFrame = CreateFrame("Frame", nil, contentFrame)
		invasionHeaderFrame:SetSize(lineWidth + 40, 22)
		invasionHeaderFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)

		local invasionHeaderBG = invasionHeaderFrame:CreateTexture(nil, "BACKGROUND")
		invasionHeaderBG:SetAllPoints(invasionHeaderFrame)
		invasionHeaderBG:SetColorTexture(0.5, 0.0, 0.0, 0.95) -- maroon

		local invasionHeader = invasionHeaderFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		invasionHeader:SetPoint("CENTER", invasionHeaderFrame, "CENTER", 0, 0)
		invasionHeader:SetText("Argus Invasion Points")
		invasionHeader:SetTextColor(1, 1, 0) -- yellow
		invasionHeader:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE") -- bold look

		yOffset = yOffset + 26

		for questID, invasionName in pairs(invasionQuests) do
			local isGreater = questID >= 49075
			local showLine = false
			local completionText = ""

			if isGreater then
				if C_QuestLog.IsQuestFlaggedCompleted(questID) then
					showLine = true
					completionText = "|cff00ff00Completed|r"
				end
			else
				if invasionCompletionDates[questID] then
					showLine = true
					completionText = "|cff00ff00Completed on " .. invasionCompletionDates[questID] .. "|r"
				elseif C_TaskQuest.IsActive and C_TaskQuest.IsActive(questID) then
					showLine = true
					completionText = "|cffffff00Available Today|r"
				end
			end

			if showLine then
				local lineFrame = CreateFrame("Frame", nil, contentFrame)
				lineFrame:SetSize(lineWidth + 40, lineHeight)
				lineFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)

				local invasionText = lineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				invasionText:SetPoint("LEFT", lineFrame, "LEFT", 0, 0)
				invasionText:SetWidth(lineWidth)
				invasionText:SetJustifyH("LEFT")
				invasionText:SetText(string.format("%s - %s", invasionName, completionText))
				invasionText:Show()

				if not isGreater then
					local markBtn = CreateFrame("Button", nil, lineFrame)
					markBtn:SetSize(18, 18)
					markBtn:SetPoint("RIGHT", lineFrame, "RIGHT", -4, 0)
					markBtn:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Check")
					markBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
					markBtn:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
						GameTooltip:AddLine("Left-click: Mark completed today", 1,1,1)
						GameTooltip:AddLine("Right-click: Clear recorded date", 0.8,0.8,0.8)
						GameTooltip:Show()
					end)
					markBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
					markBtn:SetScript("OnClick", function(self, button)
						if button == "LeftButton" then
							invasionCompletionDates[questID] = date("%Y-%m-%d")
						elseif button == "RightButton" then
							invasionCompletionDates[questID] = nil
						end
						lockoutFrame.UpdateLockoutList()
					end)
					markBtn:Show()
				end

				yOffset = yOffset + lineHeight + 2
			end
		end

		contentFrame:SetHeight(yOffset)

    end -- closes UpdateLockoutList

    -- Expose function so other parts can call it
    lockoutFrame.UpdateLockoutList = UpdateLockoutList

    -- Initial update when the window is created
    UpdateLockoutList()

    -- Auto-refresh on events and record quest turn-ins
    lockoutFrame:RegisterEvent("QUEST_TURNED_IN")
    lockoutFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
    lockoutFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    lockoutFrame:SetScript("OnEvent", function(self, event, questID)
        if event == "QUEST_TURNED_IN" and invasionQuests[questID] then
            -- If a lesser invasion is turned in while addon is loaded, record today's date
            if questID < 49075 then
                invasionCompletionDates[questID] = date("%Y-%m-%d")
            end
        end
        -- Always refresh the list on relevant events
        self.UpdateLockoutList()
    end)
end -- closes CreateLockoutWindow

-- Button Click Action
lockoutButton:SetScript("OnClick", function()
    lockoutButton:Disable()
    CreateLockoutWindow()
    lockoutFrame:Show()
    lockoutFrame.UpdateLockoutList() -- refresh each time opened
end)