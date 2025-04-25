-- Create Lockout Viewer Button
_G.lockoutButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
lockoutButton:SetSize(32, 32)
lockoutButton:SetPoint("LEFT", rollButton, "RIGHT", 1, 0)
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

-- Create Lockout Window (Scroll Features Removed)
local function CreateLockoutWindow()
    if _G.lockoutFrame then return end -- Prevent duplicate frames

    -- Main frame
    _G.lockoutFrame = CreateFrame("Frame", "LockoutFrame", UIParent, "BackdropTemplate")
    lockoutFrame:SetSize(400, 300)
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

    -- Title
    local title = lockoutFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", lockoutFrame, "TOP", 0, -10)
    title:SetText("Dungeon and Raid Lockouts")

    -- Close Button
    local closeButton = CreateFrame("Button", nil, lockoutFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", lockoutFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        lockoutFrame:Hide()
        lockoutButton:Enable() -- Re-enable button when closing
    end)

    -- Create Content Container (Scroll Logic Removed)
    local contentFrame = CreateFrame("Frame", nil, lockoutFrame)
    contentFrame:SetSize(360, 240)
    contentFrame:SetPoint("TOPLEFT", lockoutFrame, "TOPLEFT", 10, -40)

    -- Populate Lockouts
    local function UpdateLockoutList()
        local numInstances = GetNumSavedInstances()
        local yOffset = 0

        -- Clear previous entries before repopulating
        for _, child in ipairs({contentFrame:GetChildren()}) do
            child:Hide()
        end

        for i = 1, numInstances do
            local name, _, reset = GetSavedInstanceInfo(i)

            -- **Ensure values are fully validated**
            if not name or name == "" then name = "Unknown" end
            local resetTime = (reset and reset > 0) and SecondsToTime(reset) or "No Lockout"

            -- **Debugging Check**
            if resetTime == "No Lockout" then
                print(string.format("Skipping invalid lockout: name='%s', resetTime='%s'", tostring(name), tostring(resetTime)))
            else
                -- **Final Controlled Formatting Check**
                local formattedText = name .. " - Resets in " .. resetTime -- Remove `string.format()`
                
                local lockoutText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                lockoutText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -yOffset)
                
                -- **Explicitly Ensure Both Values Exist Before Setting Text**
                if formattedText then
                    lockoutText:SetText(formattedText)
                    lockoutText:Show()
                    yOffset = yOffset + 20
                    print("Lockout entry added:", formattedText) -- Debug log
                else
                    print("Skipping entry due to unexpected nil values:", name, resetTime)
                end
            end
        end

        -- **Confirm Content Frame Updates Properly**
        contentFrame:SetHeight(math.max(yOffset, 240)) -- Prevent shrinking too much

        -- **Log Update**
        print(string.format("ContentFrame updated: Height=%d, NumInstances=%d", yOffset, numInstances))
    end

    UpdateLockoutList()
end

-- Button Click Action
lockoutButton:SetScript("OnClick", function()
    lockoutButton:Disable() -- Disable while active
    CreateLockoutWindow()
    lockoutFrame:Show()
end)