-- Helper function to format gold amount as a global
_G.FormatGold = _G.FormatGold or function(copperAmount)
    local gold = math.floor(copperAmount / 10000)
    return string.format("%d", gold)
end

-- Initialize lootHistory as a global variable
_G.lootHistory = _G.lootHistory or {}

-- Create the LootsButton
_G.LootsButton = CreateFrame("Button", "LootsButton", UIParent, "UIPanelButtonTemplate")
LootsButton:SetSize(32, 32)
LootsButton:SetPoint("BOTTOMLEFT", SoundOutputButton, "BOTTOMRIGHT", 1, 0)
LootsButton:SetFrameStrata("MEDIUM")
LootsButton:SetFrameLevel(10)
LootsButton:EnableMouse(true)
LootsButton:SetNormalTexture("Interface\\Icons\\inv_misc_ornatebox")
LootsButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Click to see Recent Loot")
    GameTooltip:Show()
end)
LootsButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Create the Popup Window with BackdropTemplate
_G.LootsWindow = CreateFrame("Frame", "LootsWindow", UIParent, "BackdropTemplate")
LootsWindow:SetSize(300, 250)
LootsWindow:SetPoint("CENTER")
LootsWindow:SetFrameStrata("DIALOG")
LootsWindow:EnableMouse(true)
LootsWindow:SetMovable(true)
LootsWindow:RegisterForDrag("LeftButton")
LootsWindow:SetScript("OnDragStart", LootsWindow.StartMoving)
LootsWindow:SetScript("OnDragStop", LootsWindow.StopMovingOrSizing)
LootsWindow:Hide()

-- Define the backdrop
LootsWindow:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
LootsWindow:SetBackdropColor(1, 1, 1, 1) -- Darkened transparency (alpha)

-- Title Bar
local playerName = UnitName("player") -- Get the player's name dynamically
_G.Title = LootsWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
Title:SetPoint("TOP", LootsWindow, "TOP", 0, -10)
Title:SetText(string.format("|cffffd700%s's Recent Loot|r", playerName))

local TitleBackground = LootsWindow:CreateTexture(nil, "BACKGROUND")
TitleBackground:SetColorTexture(0.5, 0, 0, 1) -- Dark red background
TitleBackground:SetPoint("TOPLEFT", LootsWindow, "TOPLEFT", 0, -5)
TitleBackground:SetPoint("BOTTOMRIGHT", LootsWindow, "TOPRIGHT", 0, -30)

-- Close Button
_G.CloseButton = CreateFrame("Button", nil, LootsWindow, "UIPanelCloseButton")
CloseButton:SetPoint("TOPRIGHT", LootsWindow, "TOPRIGHT", -5, -5)
CloseButton:SetScript("OnClick", function()
    LootsWindow:Hide()
    LootsButton:Enable()
end)

-- Scrollable Loot Display
local ScrollFrame = CreateFrame("ScrollFrame", nil, LootsWindow, "UIPanelScrollFrameTemplate")
ScrollFrame:SetPoint("TOPLEFT", LootsWindow, "TOPLEFT", 10, -40)
ScrollFrame:SetPoint("BOTTOMRIGHT", LootsWindow, "BOTTOMRIGHT", -30, 50)

local LootContent = CreateFrame("Frame", nil, ScrollFrame)
LootContent:SetSize(260, 550) -- Adjust based on expected loot size
ScrollFrame:SetScrollChild(LootContent)

_G.LootDisplay = LootContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
LootDisplay:SetPoint("TOPLEFT", LootContent, "TOPLEFT", 0, 0)
LootDisplay:SetWidth(240)
LootDisplay:SetJustifyH("LEFT")

-- Bottom Title Bar with Background
local BottomTitleBackground = LootsWindow:CreateTexture(nil, "BACKGROUND")
BottomTitleBackground:SetColorTexture(0.5, 0, 0, 1) -- Dark red background for gold display
BottomTitleBackground:SetPoint("BOTTOMLEFT", LootsWindow, "BOTTOMLEFT", 10, 5) -- Restrict to the bottom
BottomTitleBackground:SetPoint("TOPRIGHT", LootsWindow, "BOTTOMRIGHT", -10, 35) -- Proper alignment

_G.GoldDisplay = LootsWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GoldDisplay:SetPoint("CENTER", BottomTitleBackground, "CENTER", 0, 0) -- Centered within the background
GoldDisplay:SetTextColor(1, 1, 0) -- Yellow text for gold amount

-- Refresh Functionality
_G.DebugLootHistory = _G.DebugLootHistory or function()
    if lootHistory == nil or #lootHistory == 0 then
        LootDisplay:SetText("No loot yet!")
    else
        local lootText = ""
        for _, loot in ipairs(lootHistory) do
            -- Replace "You receive loot:" with a dash
            local filteredLoot = string.gsub(loot, "You receive loot:", "-")
            local time = date("%H:%M") -- Add time to loot
            lootText = lootText .. string.format("%s %s\n", time, filteredLoot)
        end
        LootDisplay:SetText(lootText)
    end
end

local function RefreshLootsWindow()
    DebugLootHistory()
    GoldDisplay:SetText(string.format("%s's Current Gold: %s", playerName, FormatGold(GetMoney())))
end

-- Button Functionality
LootsButton:SetScript("OnClick", function()
    print("LootsButton clicked!") -- Debug confirmation
    if not LootsWindow:IsShown() then
        LootsWindow:Show()
        LootsButton:Disable()
        RefreshLootsWindow()
    end
end)

-- Auto Refresh
LootsWindow:SetScript("OnUpdate", function(self, elapsed)
    self.refreshTimer = (self.refreshTimer or 0) + elapsed
    if self.refreshTimer >= 1 then -- Refresh every second
        if LootsWindow:IsShown() then -- Only refresh if popup is open
            RefreshLootsWindow()
        end
        self.refreshTimer = 0
    end
end)

-- Event Handling (Example for populating lootHistory)
_G.LootEventFrame = CreateFrame("Frame")
LootEventFrame:RegisterEvent("CHAT_MSG_LOOT")
LootEventFrame:SetScript("OnEvent", function(_, _, message)
    table.insert(lootHistory, 1, message)
    if #lootHistory > 50 then -- Limit to 50 items for scrollback
        table.remove(lootHistory, #lootHistory)
    end
end)