-- Helper function to format gold amount as a global
_G.FormatGold = _G.FormatGold or function(copperAmount)
    local gold = math.floor(copperAmount / 10000)
    return string.format("%d", gold)
end

-- Create the repairButton
_G.repairButton = CreateFrame("Button", "repairButton", UIParent, "UIPanelButtonTemplate")
repairButton:SetSize(32, 32) -- Ensure consistent button size
--repairButton:SetPoint("CENTER", UIParent, "CENTER", -200, 200) -- Place prominently for testing
repairButton:SetPoint("LEFT", LootsButton, "RIGHT", 1, 0) -- Positioned next to Gear Score button	
repairButton:SetFrameStrata("MEDIUM")
repairButton:SetFrameLevel(10)
repairButton:EnableMouse(true)
repairButton:SetNormalTexture("Interface\\Icons\\inv_gnometoy")
repairButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Click to open Repair Options")
    GameTooltip:Show()
end)
repairButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Toggle the popup window on button click
repairButton:SetScript("OnClick", function()
    if RepairWindow:IsShown() then
        RepairWindow:Hide()
    else
        RepairWindow:Show()
    end
end)

-- Create the Popup Window with BackdropTemplate
_G.RepairWindow = CreateFrame("Frame", "RepairWindow", UIParent, "BackdropTemplate")
RepairWindow:SetSize(375, 530)
RepairWindow:SetPoint("CENTER")
RepairWindow:SetFrameStrata("DIALOG")
RepairWindow:EnableMouse(true)
RepairWindow:SetMovable(true)
RepairWindow:RegisterForDrag("LeftButton")
RepairWindow:SetScript("OnDragStart", RepairWindow.StartMoving)
RepairWindow:SetScript("OnDragStop", RepairWindow.StopMovingOrSizing)
RepairWindow:Hide() -- Start hidden

-- Add Close ("X") Button to Popup Window
local closeButton = CreateFrame("Button", nil, RepairWindow, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", RepairWindow, "TOPRIGHT", -5, -5)
closeButton:SetScript("OnClick", function()
    RepairWindow:Hide() -- Close the popup window
end)

RepairWindow:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
RepairWindow:SetBackdropColor(0, 0, 0, 1)

-- Title Bar Background
local titleBackground = RepairWindow:CreateTexture(nil, "BACKGROUND")
titleBackground:SetSize(350, 30) -- Set width and height for the background
titleBackground:SetPoint("TOP", RepairWindow, "TOP", 0, -10) -- Position the background
titleBackground:SetColorTexture(0.4, 0, 0, 1) -- Dark red color (RGBA: 0.6, 0, 0, 1)

-- Title Bar Text
local playerName = UnitName("player")
local RepairTitle = RepairWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
RepairTitle:SetPoint("TOP", titleBackground, "TOP", 0, -5) -- Center text in the background
RepairTitle:SetText(string.format("|cffffd700%s's Repair Options|r", playerName))

-- Column Headers
local columnHeaders = {
    {title = "Repair Buddy", xOffset = -10, width = 240},
    {title = "Status", xOffset = 254, width = 100}
}

for _, colData in ipairs(columnHeaders) do
    local colHeader = RepairWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colHeader:SetPoint("TOPLEFT", RepairWindow, "TOPLEFT", colData.xOffset, -50)
    colHeader:SetWidth(colData.width)
    colHeader:SetJustifyH("CENTER") -- Centers text horizontally within its column
    colHeader:SetText(colData.title)
    colHeader:SetTextColor(1, 1, 0)
end

-- Mount Table
local mounts = {
    {id = 2237, name = "Grizzly Hills Packmaster"},
    {id = 460, name = "Grand Expedition Yak"},
    {id = {horde = 284, alliance = 320}, name = "Traveler's Tundra Mammoth"},
    {id = 1039, name = "Mighty Caravan Brutosaur"}
}

-- Tooltip Data for Mounts
local tooltipData = {
    ["Grizzly Hills Packmaster"] = "Available at Blizzard Store",
    ["Grand Expedition Yak"] = "Sold by Uncle BigPocket Kun-Lai Summit 65.4 61.6 - 120k",
    ["Traveler's Tundra Mammoth"] = "Sold by Mei Francis in Dalaran - 16-20k",
    ["Mighty Caravan Brutosaur"] = "Available via Black Market Auctions - Gold Cap"
}

-- Function to Get the Correct Mount ID Based on Faction
local function GetMountID(mount)
    if type(mount.id) == "table" then
        local faction = UnitFactionGroup("player") -- Returns "Horde" or "Alliance"
        return faction == "Horde" and mount.id.horde or mount.id.alliance
    else
        return mount.id
    end
end

local function IsMountCollected(id)
    -- Handle both faction-specific and general mounts
    local mountId
    if string.sub(id, 1, 1) == "m" then
        -- Mount IDs prefixed with "m" (hypothetical case)
        mountId = string.sub(id, 2, -1)
    else
        -- General case: derive the mount ID directly
        mountId = id
    end

    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountId)
    return isCollected -- Returns true if collected, false otherwise
end

local mountIcons = { -- Define the icons in the correct order
    "Interface\\Icons\\inv_bearmountutility",
    "Interface\\Icons\\ability_mount_travellersyakmount",
    "Interface\\Icons\\ability_mount_mammoth_white_3seater",
    "Interface\\Icons\\inv_brontosaurusmount"
}

local rowYOffset = -70 -- Initial vertical offset for rows
local rowSpacing = 30 -- Space between rows

for index, mount in ipairs(mounts) do
    -- Column 1: Icon
    local mountIcon = RepairWindow:CreateTexture(nil, "ARTWORK")
    mountIcon:SetSize(20, 20)
    mountIcon:SetPoint("TOPLEFT", RepairWindow, "TOPLEFT", 14, rowYOffset - 5)
    mountIcon:SetTexture(mountIcons[index])

    -- Tooltip for mount icon
    mountIcon:EnableMouse(true)
    mountIcon:SetScript("OnEnter", function()
        GameTooltip:SetOwner(mountIcon, "ANCHOR_RIGHT")
        local tooltipText = tooltipData[mount.name] or "No additional information available."
        GameTooltip:SetText(tooltipText)
        GameTooltip:Show()
    end)
    mountIcon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Column 2: Mount Name
    local mountNameText = RepairWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mountNameText:SetPoint("LEFT", mountIcon, "RIGHT", 5, 0)
    mountNameText:SetText(mount.name)

    -- Tooltip for mount name
    mountNameText:EnableMouse(true)
    mountNameText:SetScript("OnEnter", function()
        GameTooltip:SetOwner(mountNameText, "ANCHOR_RIGHT")
        local tooltipText = tooltipData[mount.name] or "No additional information available."
        GameTooltip:SetText(tooltipText)
        GameTooltip:Show()
    end)
    mountNameText:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Column 3: Status or Label
    local mountID = GetMountID(mount)
    local isCollected = IsMountCollected(mountID)

    if not isCollected then
        -- Center the "Not Collected" label vertically
        local notCollectedLabel = RepairWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        notCollectedLabel:SetPoint("CENTER", RepairWindow, "TOPLEFT", 304, rowYOffset - 15) -- Adjust Y offset for vertical centering
        notCollectedLabel:SetText("Not Collected")
        notCollectedLabel:SetTextColor(1, 0, 0) -- Red for visibility
    else
        local statusWidget = CreateFrame("Button", nil, RepairWindow, "UIPanelButtonTemplate")
        statusWidget:SetSize(70, 25)
        statusWidget:SetPoint("TOPLEFT", RepairWindow, "TOPLEFT", 270, rowYOffset)
        statusWidget:SetText(IsMounted() and "Dismount" or "Mount")
        statusWidget:SetScript("OnClick", function()
            if IsMounted() then
                Dismount()
                statusWidget:SetText("Mount")
            else
                C_MountJournal.SummonByID(mountID)
                statusWidget:SetText("Dismount")
            end
        end)

        RepairWindow:HookScript("OnShow", function()
            if IsMounted() then
                statusWidget:SetText("Dismount")
            else
                statusWidget:SetText("Mount")
            end
        end)
    end

    rowYOffset = rowYOffset - rowSpacing -- Adjust for tighter row spacing
end

-- Add Checkboxes to the Popup Window
local autoRepairCheckbox = CreateFrame("CheckButton", "AutoRepairCheckbox", RepairWindow, "UICheckButtonTemplate")
autoRepairCheckbox:SetPoint("BOTTOMLEFT", RepairWindow, "BOTTOMLEFT", 20, 6)
autoRepairCheckbox:SetChecked(true)
autoRepairCheckbox.text = autoRepairCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
autoRepairCheckbox.text:SetPoint("LEFT", autoRepairCheckbox, "RIGHT", 3, 0)
autoRepairCheckbox.text:SetText("Auto Repair")

local guildRepairCheckbox = CreateFrame("CheckButton", "GuildRepairCheckbox", RepairWindow, "UICheckButtonTemplate")
guildRepairCheckbox:SetPoint("LEFT", autoRepairCheckbox, "RIGHT", 90, 0)
guildRepairCheckbox:SetChecked(true)
guildRepairCheckbox.text = guildRepairCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
guildRepairCheckbox.text:SetPoint("LEFT", guildRepairCheckbox, "RIGHT", 3, 0)
guildRepairCheckbox.text:SetText("Guild Repairs")

local sellJunkCheckbox = CreateFrame("CheckButton", "SellJunkCheckbox", RepairWindow, "UICheckButtonTemplate")
sellJunkCheckbox:SetPoint("LEFT", guildRepairCheckbox, "RIGHT", 90, 0)
sellJunkCheckbox:SetChecked(true)
sellJunkCheckbox.text = sellJunkCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sellJunkCheckbox.text:SetPoint("LEFT", sellJunkCheckbox, "RIGHT", 3, 0)
sellJunkCheckbox.text:SetText("Sell Junk")

-- Repair Functionality
local function RepairBuddyRepairAllItems()
    if not CanMerchantRepair() then return false end

    local repairCost, canRepair = GetRepairAllCost()
    if canRepair and repairCost > 0 then
        print("Repaired items for:", GetCoinTextureString(repairCost)) -- Enhanced message
    elseif repairCost == 0 then
        print("No repairs needed.") -- New message for no repairs
    end

    if guildRepairCheckbox:GetChecked() and CanGuildBankRepair() then
        if not RepairAllItems(1) then
            RepairAllItems()
        end
    else
        RepairAllItems()
    end
end

-- After Mount Handling Logic
-- Begin Repair Buddy Section
local repairBuddies = {
    {itemID = 49040, name = "Jeeves", icon = "Interface\\Icons\\inv_misc_head_clockworkgnome_01"},
    {itemID = 221957, name = "Algari Repair Bot 110", icon = "Interface\\Icons\\achievement_dungeon_ulduarraid_irongolem_01"},
    {itemID = 132514, name = "Auto-Hammer", icon = "Interface\\Icons\\inv_engineering_autohammer"},
    {itemID = 144341, name = "Rechargeable Reaves Battery", icon = "Interface\\Icons\\inv_engineering_reavesmodule"},
    {itemID = 132523, name = "Reeves Battery", icon = "Interface\\Icons\\inv_engineering_reavesmodule"},
    {itemID = 40769, name = "Scrapbot Construction Kit", icon = "Interface\\Icons\\inv_misc_enggizmos_14"},
    {itemID = 34113, name = "Field Repair Bot 110G", icon = "Interface\\Icons\\inv_misc_enggizmos_01"},
    {itemID = 18232, name = "Field Repair Bot 74A", icon = "Interface\\Icons\\inv_egg_05"},
    {itemID = 11590, name = "Mechanical Repair Kit", icon = "Interface\\Icons\\inv_gizmo_03"}
}

local tooltipData = {
    ["Jeeves"] = "Northrend Engineering (75) - Schematic drops from Mechs around 40 40 in Storm Peaks",
    ["Prototype Algari Repair Bot 110"] = "Learned from Khaz Algar Engineering (1)",
    ["Auto-Hammer"] = "Taught by Schematic: Auto-Hammer Rank (1-3) Legion",
    ["Rechargeable Reaves Battery"] = "Legion Engineering (60) - Dalaran",
    ["Reeves Battery"] = "Legion Engineering (1) - Dalaran",
    ["Scrapbot Construction Kit"] = "Northrend - Quest The Prototype Console (12889)",
    ["Field Repair Bot 110G"] = "Outland Engineering (25) - Drops from Simon Unit - Blade's Edge Mountains",
    ["Field Repair Bot 74A"] = "Classic Engineering (300) - Dropped by Golem Lord Argelmach in Black Rock Depths",
    ["Mechanical Repair Kit"] = "Classic Engineering (200) - Taught by Trainers"
}

local repairRowYOffset = -200 -- Starting offset for repair buddy rows
local statusButtons = {} -- Store status buttons for dynamic updates

-- Function to poll bag slots and update buddy slot data
local function UpdateBuddyBagSlots()
    for _, buddy in ipairs(repairBuddies) do
        buddy.slot = nil -- Clear any existing slot data

        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemID = C_Container.GetContainerItemID(bag, slot)
                if itemID == buddy.itemID then
                    buddy.slot = { bag = bag, slot = slot }
                    print(string.format("Found %s in Bag %d, Slot %d", buddy.name, bag, slot))
                    break
                end
            end
            if buddy.slot then break end -- Stop searching once found
        end

        if not buddy.slot then
            print(string.format("Could not find %s in any bag.", buddy.name))
        end
    end
end

-- Function to update buddy statuses
local function RefreshBuddyStatuses()
    for index, buddy in ipairs(repairBuddies) do
        local statusButton = statusButtons[index]
        if statusButton then
            -- Check if the item is in the user's bags
            if GetItemCount(buddy.itemID) > 0 then
                -- Get cooldown data
                local start, duration = GetItemCooldown(buddy.itemID)
                local cooldownRemaining = math.ceil(duration - (GetTime() - start))

                if start > 0 and duration > 0 then
                    -- Item is on cooldown, convert seconds to minutes
                    local cooldownMinutes = math.ceil(cooldownRemaining / 60)
                    statusButton:SetText("|cFFFFFF00On CD - " .. cooldownMinutes .. "m|r") -- Bright yellow text
                    statusButton:Disable()
                    statusButton:Show() -- Force refresh
                else
                    -- Item is ready to use
                    statusButton:SetText("Available")
                    statusButton:Enable()
                    statusButton:Show() -- Force refresh
                end
            else
                -- Item is not present
                statusButton:SetText("None")
                statusButton:Disable()
                statusButton:Show() -- Force refresh
            end
        end
    end
end

-- Function to handle button clicks
local function OnBuddyButtonClick(buddy)
    if buddy.slot then
        local start, duration = C_Container.GetContainerItemCooldown(buddy.slot.bag, buddy.slot.slot)
        if start == 0 and duration == 0 then
            -- Prepare the macro text
            local macroText = string.format("/use %d %d", buddy.slot.bag, buddy.slot.slot)

            -- Whisper the macro to the player
            SendChatMessage(string.format("To use %s, copy and paste this macro: %s, Because the Blizzard UI blocks calls like this in addons, but not macros", buddy.name, macroText), "WHISPER", nil, UnitName("player"))
        else
            -- Cooldown detected
            local cooldownRemaining = math.ceil(duration - (GetTime() - start))
            local cooldownMinutes = math.ceil(cooldownRemaining / 60)
            SendChatMessage(string.format("%s is on cooldown for %d minutes.", buddy.name, cooldownMinutes), "WHISPER", nil, UnitName("player"))
        end
    else
        -- Whisper a message if the item is not found
        SendChatMessage(string.format("%s is not in your bags.", buddy.name), "WHISPER", nil, UnitName("player"))
    end
end

-- Example: Refresh bag slots when inventory changes
local f = CreateFrame("Frame")
f:RegisterEvent("BAG_UPDATE")
f:SetScript("OnEvent", function()
    UpdateBuddyBagSlots()
    RefreshBuddyStatuses()
end)

-- Add UI elements for repair buddies
for index, buddy in ipairs(repairBuddies) do
    -- Column 1: Icon
    local buddyIcon = RepairWindow:CreateTexture(nil, "ARTWORK")
    buddyIcon:SetSize(20, 20)
    buddyIcon:SetPoint("TOPLEFT", RepairWindow, "TOPLEFT", 14, repairRowYOffset - 5)
    buddyIcon:SetTexture(buddy.icon)

    -- Tooltip for buddy icon
    buddyIcon:EnableMouse(true)
    buddyIcon:SetScript("OnEnter", function()
        GameTooltip:SetOwner(buddyIcon, "ANCHOR_RIGHT")
        local tooltipText = tooltipData[buddy.name] or "No additional information available."
        GameTooltip:SetText(tooltipText)
        GameTooltip:Show()
    end)
    buddyIcon:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Column 2: Repair Buddy Name
    local buddyNameText = RepairWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buddyNameText:SetPoint("LEFT", buddyIcon, "RIGHT", 5, 0)
    buddyNameText:SetText(buddy.name)

    -- Tooltip for buddy name
    buddyNameText:EnableMouse(true)
    buddyNameText:SetScript("OnEnter", function()
        GameTooltip:SetOwner(buddyNameText, "ANCHOR_RIGHT")
        local tooltipText = tooltipData[buddy.name] or "No additional information available."
        GameTooltip:SetText(tooltipText)
        GameTooltip:Show()
    end)
    buddyNameText:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Column 3: Status Button
    local statusButton = CreateFrame("Button", nil, RepairWindow, "UIPanelButtonTemplate")
    statusButton:SetSize(100, 25)
    statusButton:SetPoint("TOPLEFT", RepairWindow, "TOPLEFT", 258, repairRowYOffset)
    statusButton:SetNormalFontObject("GameFontNormal")
    statusButtons[index] = statusButton -- Store reference for later updates
    statusButton:SetText("Initializing...")

    -- Assign the click handler
    statusButton:SetScript("OnClick", function()
        OnBuddyButtonClick(buddy)
    end)

    -- Adjust row offset for the next buddy
    repairRowYOffset = repairRowYOffset - 30
end

-- Auto-update while the popup window is open
RepairWindow:SetScript("OnUpdate", function(self, elapsed)
    if self:IsShown() then
        RefreshBuddyStatuses()
    end
end)

-- Automatically refresh on window show
RepairWindow:SetScript("OnShow", RefreshBuddyStatuses)

-- Junk Selling Functionality
local function RepairBuddySellGrayItems()
    local totalSaleValue = 0

    for bag = 0, NUM_BAG_SLOTS do
        local slots = C_Container.GetContainerNumSlots(bag)
        for slot = 1, slots do
            local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if itemInfo then
                local quality = itemInfo.quality
                local saleValue = itemInfo.itemPrice
                if quality == 0 then -- Gray items only
                    C_Container.UseContainerItem(bag, slot)
                    totalSaleValue = totalSaleValue + (saleValue or 0)
                end
            end
        end
    end

    -- Display message only if junk was sold
    if totalSaleValue > 0 then
        print("Junk sold for:", GetCoinTextureString(totalSaleValue))
    end
end

-- Event Handling for Repairs and Junk Selling
local function RepairBuddyEventHandler()
    if autoRepairCheckbox:GetChecked() then
        RepairBuddyRepairAllItems()
    end

    if sellJunkCheckbox:GetChecked() then
        RepairBuddySellGrayItems()
    end
end

-- Register the event
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("MERCHANT_SHOW")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" then
        RepairBuddyEventHandler()
    end
end)