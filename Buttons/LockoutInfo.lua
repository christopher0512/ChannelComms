-- Create Lockout Viewer Button
_G.lockoutButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
lockoutButton:SetSize(32, 32)
lockoutButton:SetPoint("LEFT", masterToggleButton, "RIGHT", 5, 0)
lockoutButton:SetNormalTexture("Interface\\Icons\\inv_10_misc_dragonorb_color1")

-- Tooltip
lockoutButton:SetScript("OnEnter", function()
    GameTooltip:SetOwner(lockoutButton, "ANCHOR_TOP")
    GameTooltip:SetText("View Dungeon and Raid Lockouts", 1, 1, 1)
    GameTooltip:Show()
end)
lockoutButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

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
    lockoutFrame:SetBackdropColor(0, 0, 0, 0.8) -- Semi-transparent background

    -- Dragging Functionality
    lockoutFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    lockoutFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

	-- Title background (full-width red bar)
	local titleBG = lockoutFrame:CreateTexture(nil, "BACKGROUND")
	titleBG:SetColorTexture(1, 0, 0, 0.9) -- Red with transparency
	titleBG:SetPoint("TOPLEFT", lockoutFrame, "TOPLEFT", 4, -4)
	titleBG:SetPoint("TOPRIGHT", lockoutFrame, "TOPRIGHT", -4, -4)
	titleBG:SetHeight(32) -- Height of the title bar

	-- Title text (yellow letters centered on the bar)
	local title = lockoutFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	title:SetPoint("CENTER", titleBG, "CENTER", 0, -2)
	title:SetText("Dungeon and Raid Lockouts")
	title:SetTextColor(1, 1, 0) -- Yellow text

    local titleBG = lockoutFrame:CreateTexture(nil, "BACKGROUND")
    titleBG:SetColorTexture(1, 0, 0, 0.7) -- Red background
    titleBG:SetPoint("TOPLEFT", title, -10, 10)
    titleBG:SetPoint("BOTTOMRIGHT", title, 10, -10)

    -- Close Button
    local closeButton = CreateFrame("Button", nil, lockoutFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", lockoutFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        lockoutFrame:Hide()
        lockoutButton:Enable() -- Re-enable button when closing
    end)

-- ScrollFrame container
local scrollFrame = CreateFrame("ScrollFrame", nil, lockoutFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", lockoutFrame, "TOPLEFT", 10, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", lockoutFrame, "BOTTOMRIGHT", -30, 10) -- anchors to bottom-right with padding

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

        for i = 1, numInstances do
            local name, _, reset, difficultyID, locked, extended, instanceID, isRaid, maxPlayers, difficultyName = GetSavedInstanceInfo(i)

            if not name or name == "" then name = "Unknown" end
            local resetTime = (reset and reset > 0) and SecondsToTime(reset) or "No Lockout"
            local difficulty = difficultyName or "Unknown"

            if resetTime ~= "No Lockout" then
                local formattedText = string.format("%s (%s) - Resets in %s", name, difficulty, resetTime)

                local lockoutText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                lockoutText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)

                lockoutText:SetText(formattedText)
                lockoutText:Show()
                yOffset = yOffset + 20
            end
        end

        contentFrame:SetHeight(yOffset) -- Allow scrolling if taller than scrollFrame
    end

    UpdateLockoutList()
end -- <-- closes CreateLockoutWindow properly

-- Button Click Action
lockoutButton:SetScript("OnClick", function()
    lockoutButton:Disable() -- Disable while active
    CreateLockoutWindow()
    lockoutFrame:Show()
end)