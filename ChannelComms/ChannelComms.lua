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
    frame:SetSize(352, 122) -- Match the dimensions
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
    frame:SetSize(364, 164) -- Adjust height to accommodate input box
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
    editBox:SetSize(356, 20) -- Adjusted width to match the window
    editBox:SetPoint("BOTTOM", frame, "BOTTOM", 3, 2) -- Positioned at the bottom of the frame
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontNormal) 

-- Handle Enter key press to send message
    editBox:SetScript("OnEnterPressed", function()
        local message = editBox:GetText()
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

        if channel then
            SendChatMessage(message, channel)
        end
        editBox:SetText("") -- Clear after sending
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
    "hello", "bye", "thank", "yw", "kneel", "bow", "salute",  
	"nod", "no", "dance", "train",  "smile", "smirk", "congratulate",
    "incoming", "victory", "amaze", "clap", "commend", "hug", "cheer", 
    "Ready", "brb", "eyebrow", "confused", "oops", "rude", "laugh"
}

function ChannelComms_CreateButtons(parent)
    local numColumns = 7
    local numRows = 4
    local buttonWidth = 52 -- Fixed width for uniform buttons
    local buttonHeight = 22 -- Fixed height for uniform buttons
    local padding = 0 -- Adjust for consistent spacing
    local startYOffset = -54 -- Offset to place buttons below the title bar

    for i, emote in ipairs(emotes) do
        -- Create the button
        local button = CreateFrame("Button", "ChannelCommsButton" .. i, parent, "UIPanelButtonTemplate")
        button:SetSize(buttonWidth, buttonHeight)

-------------------------------------------------------------
-- Change button label based on emote
-------------------------------------------------------------
		local label = emote
        if emote == "hello" then label = "Hi" end
        if emote == "bye" then label = "Bye" end
        if emote == "thank" then label = "TY" end
        if emote == "welcome" then label = "YW" end
        if emote == "brb" then label = "BRB" end
        if emote == "incoming" then label = "INC!" end
        if emote == "nod" then label = "Yes" end
		if emote == "congratulate" then label = "Grats" end
        if emote == "confused" then label = "Huh" end
        if emote == "victory" then label = "Win!" end
        if emote == "commend" then label = "GJob" end
        if emote == "eyebrow" then label = "Eyes" end
		if emote == "laugh" then label = "LOL" end

-- Limit label to 6 characters
        label = string.sub(label, 1, 6)

-- Set button text and font
        button:SetText(label:gsub("^%l", string.upper)) -- Capitalize first letter
        button:GetFontString():SetFont("Fonts\\FRIZQT__.TTF", 12) -- Standard font size

-- Position buttons in a grid below the title bar
        button:SetPoint("TOPLEFT", parent, "TOPLEFT",
            ((i - 1) % numColumns) * (buttonWidth + padding),
            startYOffset - math.floor((i - 1) / numColumns) * (buttonHeight + padding))

-- Attach OnClick handler
        button:SetScript("OnClick", function()
            DoEmote(emote) -- Perform the emote directly
        end)
    end
end

-- Explicitly call the frame creation function to initialize it
	local parentFrame = ChannelComms_CreateFrame()

-- Add slash command for frame toggle
	SLASH_ChannelComms1 = "/ChannelComms" -- Define the slash command "/ChannelComms"
	SlashCmdList["ChannelComms"] = function()
		if parentFrame:IsShown() then
			parentFrame:Hide()
		else
			parentFrame:Show()
		end
end
