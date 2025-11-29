ChannelComms = ChannelComms or {}
ChannelComms.Modules = ChannelComms.Modules or {}

if not ChannelComms then
    print("Error: ChannelComms global is not defined. Ensure the core addon is loaded first!")
    return
end

-- Make this module globally accessible within ChannelComms
ChannelComms.Modules.CollectibleTracker = CollectibleTracker

local function CreateTitleBar(parent)
-- Create the title bar frame
    _G.titleBar = CreateFrame("Frame", nil, parent)
    titleBar:SetSize(parent:GetWidth(), 20) -- Match the width of the parent frame
    titleBar:SetPoint("TOP", parent, "TOP", 0, 0) -- Position at the top of the parent frame

-- Add background texture for the title bar
    local bgTexture = titleBar:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetColorTexture(0.4, 0, 0, 1) -- Maroon background
    bgTexture:SetAllPoints(titleBar)

-- Add a title
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    titleText:SetText("ChannelComms")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 2, 0)
    titleText:SetTextColor(0, 1, 1) -- Cyan text

-- Add a /R button to reload the UI
	_G.reloadButton = CreateFrame("Button", nil, titleBar, "UIPanelButtonTemplate")
	reloadButton:SetSize(24, 22) -- Compact size for the button
	reloadButton:SetPoint("LEFT", titleBar, "LEFT", 0, 0) -- Positioned to the left of the title
	reloadButton:SetText("/R") -- Button label
	reloadButton:SetScript("OnClick", function()
		ReloadUI() -- Reloads the user interface when clicked
	end)
	reloadButton:SetNormalFontObject(GameFontNormalSmall) -- Match the style with a smaller font
	reloadButton:GetFontString():SetTextColor(1, 1, 0) -- Yellow text color

	-- Add tooltip for mouseover
	reloadButton:SetScript("OnEnter", function()
		GameTooltip:SetOwner(reloadButton, "ANCHOR_TOP")
		GameTooltip:SetText("Reload UI", 1, 1, 1)
		GameTooltip:Show()
	end)
	reloadButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
    reloadButton:SetNormalFontObject(GameFontNormalSmall) -- Match the style with a smaller font
    reloadButton:GetFontString():SetTextColor(1, 1, 0) -- Yellow text color

 -------------------------------------------------------------
 -- Add a Close (X) button
 -------------------------------------------------------------
    local closeButton = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
    closeButton:SetSize(20, 20) -- Button size
    closeButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -1) -- Adjust position
    closeButton:SetScript("OnClick", function() parent:Hide() end)

-- Enable dragging functionality
    titleBar:EnableMouse(true)
    titleBar:SetMovable(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() parent:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() parent:StopMovingOrSizing() end)

    return titleBar
end

-------------------------------------------------------------
-- Create the close button
-------------------------------------------------------------
local function CreateCloseButton(parent)

    local closeButton = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
    closeButton:SetSize(20, 20) -- Button size

-- Adjust position: move up and right (6 units each)
    closeButton:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -1) -- Modify x and y offsets

    closeButton:SetScript("OnClick", function() parent:Hide() end)

    return closeButton
end

-------------------------------------------------------------
-- Create main frame
-------------------------------------------------------------
function ChannelComms_CreateFrame()
    _G.frame = CreateFrame("Frame", "ChannelCommsInputFrame", UIParent)
    frame:SetSize(350, 142) -- Match the dimensions
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)

-- Add background texture
    _G.bgTexture = frame:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetColorTexture(0, 0, 0, 1) -- Transparent black background
    bgTexture:SetAllPoints(frame)

-------------------------------------------------------------
-- Create the title bar and close button
-------------------------------------------------------------
	CreateTitleBar(frame)
	CreateCloseButton(frame)

-- Add buttons for emotes
	ChannelComms_CreateButtons(frame)

-- Show the frame to ensure it appears
	frame:Show()

    return frame
end

-------------------------------------------------------------
-- Save frame position and mouse ups
-------------------------------------------------------------

	local function SaveFramePosition(frame)
		local point, _, relativePoint, xOffset, yOffset = frame:GetPoint()
-- Save these values somewhere (e.g., a saved variable)
		print("Frame position saved:", point, relativePoint, xOffset, yOffset)
	end

	function ChannelCommsInputFrame_OnMouseUp(self)
		self:StopMovingOrSizing()
		SaveFramePosition(self) -- Call save function here if needed
	end

-------------------------------------------------------------
-- Create the main frame and appearence 
-------------------------------------------------------------
function ChannelComms_CreateFrame()
    _G.frame = CreateFrame("Frame", "ChannelCommsInputFrame", UIParent)
    frame:SetSize(340, 188) -- Adjust height to accommodate input box
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)

-- Add background texture
    _G.bgTexture = frame:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetColorTexture(0, 0, 0, 1) -- Transparent black background
    bgTexture:SetAllPoints(frame)

-- Create the title bar and close button
    CreateTitleBar(frame)
    CreateCloseButton(frame)

-- Add buttons for emotes
    ChannelComms_CreateButtons(frame)

-------------------------------------------------------------
-- Add a text input box type what you want to say in here
-- and it figures out where you are solo/party/raid/delve/lfr
-- and posts what you said the the correct channel
-------------------------------------------------------------
    local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    editBox:SetSize(330, 20) -- Adjusted width to match the window
    editBox:SetPoint("BOTTOM", frame, "BOTTOM", 3, 2) -- Positioned at the bottom of the frame
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontNormal) 

-- Handle Enter key press to send message
editBox:SetScript("OnEnterPressed", function()
    local message = editBox:GetText()
    
    -- ✅ Detect if input matches "number(space)number(space)optional words"
	message = message:gsub(",", " ") -- Replace commas with spaces
	message = message:gsub("%s+", " ") -- Normalize multiple spaces into a single space

	-- Extract coordinates and any following note
	local x, y, note = message:match("^(%d+%.?%d*)%s+(%d+%.?%d*)%s*(.*)$")

	if x and y then
		local waypointCommand = "/way " .. x .. " " .. y
		if note and note ~= "" then
			waypointCommand = waypointCommand .. " " .. note -- Append note if present
		end

		-- ✅ Submit as a waypoint command
		ChatFrame1.editBox:SetText(waypointCommand)
		ChatEdit_SendText(ChatFrame1.editBox, false) -- ✅ Auto-submit command
	else
		-- ✅ Determine chat channel for normal messages
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

		-- ✅ Send regular message to correct channel
		if channel then
			SendChatMessage(message, channel)
		end
	end

    editBox:SetText("") -- ✅ Clears input after sending
    editBox:ClearFocus()
end)

-- Show the frame to ensure it appears
    frame:Show()

    return frame
end
---------------------------------------------------------------
-- add all the emote buttons, if you want different one you can
-- look up the emotes online and switch them out here in the 
-- array, limits to 6 characters but you can tailor the ifs
-- below to show what you want to buttons to display
---------------------------------------------------------------
local emotes = {
    "hello", "cheer", "smile", "thank",
	"bye", "commend", "smirk", "welcome", 
    "laugh", "victory", "salute", "train",
	"brb", "Grats", "bow", "dance", 
    "Ready", "nod", "hug", "luck"
}

function ChannelComms_CreateButtons(parent)
    local numColumns = 4
    local numRows = 5
    local buttonWidth = 52
    local buttonHeight = 22
    local padding = 0
    local startYOffset = -54

    for i, emote in ipairs(emotes) do
        -- Create background frame below the button
        local bgFrame = CreateFrame("Frame", nil, parent)
        bgFrame:SetSize(buttonWidth, buttonHeight)
        bgFrame:SetPoint("TOPLEFT", parent, "TOPLEFT",
            ((i - 1) % numColumns) * (buttonWidth + padding),
            startYOffset - math.floor((i - 1) / numColumns) * (buttonHeight + padding))
        bgFrame:SetFrameLevel(parent:GetFrameLevel() + 1)

        -- Add red texture to background frame
        local bg = bgFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0.8, 0.2, 0.2) -- Red background

        -- Create the button above the background
        local button = CreateFrame("Button", "ChannelCommsButton" .. i, bgFrame, "UIPanelButtonTemplate")
        button:SetSize(buttonWidth, buttonHeight)
        button:SetPoint("TOPLEFT", bgFrame, "TOPLEFT", 0, 0)

        -- Change button label based on emote
        local label = emote
        if emote == "hello" then label = "Hi" end
        if emote == "bye" then label = "Bye" end
        if emote == "thank" then label = "Thanks" end
        if emote == "welcome" then label = "YvW" end
        if emote == "brb" then label = "BRB" end
        if emote == "incoming" then label = "INC!" end
        if emote == "nod" then label = "Nod" end
        if emote == "luck" then label = "G-Luck" end
        if emote == "confused" then label = "Huh" end
        if emote == "victory" then label = "Win!" end
        if emote == "commend" then label = "G-Job" end
        if emote == "eyebrow" then label = "Eyes" end
        if emote == "laugh" then label = "LOL" end

        label = string.sub(label, 1, 6)
        button:SetText(label:gsub("^%l", string.upper))
        button:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 12)

        -- Attach OnClick handler
        button:SetScript("OnClick", function()
            DoEmote(emote)
        end)
    end
end

-- Explicitly call the frame creation function to initialize it
	local parentFrame = ChannelComms_CreateFrame()

-- Determine appropriate chat channel
local function GetChatChannel()
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    else
        return "SAY"
    end
end

-- General Thank-You Button Creator
local function CreateThankYouButton(name, text, parent, xOffset, yOffset, chatMessage)
    -- Create background frame below the button
    local bgFrame = CreateFrame("Frame", nil, parent)
    bgFrame:SetSize(64, 22)
    bgFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    bgFrame:SetFrameLevel(parent:GetFrameLevel() + 1) -- Ensure it's below the button

    -- Add blue texture to background frame
    local bg = bgFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.2, 0.4, 0.8)
    
    -- Create the actual button above the background
    local button = CreateFrame("Button", name, bgFrame, "UIPanelButtonTemplate")
    button:SetSize(64, 22)
    button:SetPoint("TOPLEFT", bgFrame, "TOPLEFT", 0, 0)
    button:SetText(text)
    button:SetScript("OnClick", function()
        SendChatMessage(chatMessage, GetChatChannel())
    end)

    -- Strip default texture
    local normal = button:GetNormalTexture()
    if normal then
        normal:SetTexture(nil)
    end

    -- Add hover effect
    local highlight = button:GetHighlightTexture()
    if highlight then
        highlight:SetColorTexture(0.4, 0.6, 0.9, 0.5) -- Lighter blue on hover
        highlight:SetBlendMode("ADD")
    end

    return button
end

-- Thank-You Messages and Labels
local thankYous = {
    { "SummonsButton", "Summon", "Thank you for the Summons" },
    { "InviteButton", "Invite", "Thank you for the Invite" },
    { "PortalButton", "Portal", "Thank you for the Portal" },
    { "CookiesButton", "Cookies", "Thank you for the Cookies" },
    { "TableButton", "Table", "Thank you for the Mage Table" },
    { "FoodButton", "Food", "Thank you for the Food" },
    { "HealsButton", "Heals", "Thank you for the Awesome Healing!" },
    { "RezButton", "Rez", "Thank you for the Rez" },
    { "LootButton", "Loot", "Thank you for the Loot" },
    { "RepairsButton", "Repairs", "Thank you for the Repairs" },
}

-- Grid Layout Configuration
local parent = _G.frame -- Ensure this matches your actual frame name
local numColumns = 2
local buttonWidth = 64
local buttonHeight = 22
local padding = 0
local startYOffset = -54 -- Adjust to stack below emotes
local horizontalShift = 208 -- Adjust this to move the grid right

-- Create Thank-You Buttons in Grid
for i, data in ipairs(thankYous) do
    local column = (i - 1) % numColumns
    local row = math.floor((i - 1) / numColumns)
    local xOffset = horizontalShift + column * (buttonWidth + padding)
    local yOffset = startYOffset - row * (buttonHeight + padding)
    CreateThankYouButton(data[1], data[2], parent, xOffset, yOffset, data[3])
end

-- Add slash command for frame toggle
	SLASH_ChannelComms1 = "/ChannelComms" -- Define the slash command "/ChannelComms"
	SlashCmdList["ChannelComms"] = function()
		if parentFrame:IsShown() then
			parentFrame:Hide()
		else
			parentFrame:Show()
		end
end