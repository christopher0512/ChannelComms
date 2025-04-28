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
		{title = "Repair Buddies", xOffset = -10, width = 240},
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
    {id = {horde = 284, alliance = 280}, name = "Traveler's Tundra Mammoth"},
    {id = 1039, name = "Mighty Caravan Brutosaur"}
}

-- Mount Icons
local mountIcons = {
    "Interface\\Icons\\inv_bearmountutility",
    "Interface\\Icons\\ability_mount_travellersyakmount",
    "Interface\\Icons\\ability_mount_mammoth_white_3seater",
    "Interface\\Icons\\inv_brontosaurusmount"
}

-- Tooltip Data for Mounts
local tooltipData = {
    ["Grizzly Hills Packmaster"] = "Available at Blizzard Store",
    ["Grand Expedition Yak"] = "Sold by Uncle BigPocket Kun-Lai Summit (65.4 61.6) - 120k",
    ["Traveler's Tundra Mammoth"] = "Sold by Mei Francis in Dalaran - 16-20k",
    ["Mighty Caravan Brutosaur"] = "Available via Black Market Auctions - Gold Cap"
}

-- Function to Get the Correct Mount ID Based on Faction
local function GetMountID(mount)
    if type(mount.id) == "table" then
        local faction = UnitFactionGroup("player")
        return mount.id[faction:lower()] -- Match faction to correct mount ID
    else
        return mount.id
    end
end

-- Function to Determine if a Mount is Collected
local function IsMountCollected(id)
    local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(id)
    return isCollected -- Returns true if collected, false otherwise
end

-- Function to Check if Player Can Mount
local function CanPlayerMount()
    return IsOutdoors() and not IsInRaid() and not UnitInVehicle("player")
end

-- Function to Refresh Mount Data
local function RefreshMountData()
    for index, mount in ipairs(mounts) do
        local mountID = GetMountID(mount)
        local isCollected = IsMountCollected(mountID)
    end
end

-- Function to Refresh Mount Buttons
local function RefreshMountButtons()
    local rowYOffset = - 64 -- Vertical offset for the first row
    local rowSpacing = 30 -- Increased spacing for better clarity

    -- Clear existing elements
    if RepairWindow.rows then
        for _, row in ipairs(RepairWindow.rows) do
            row:Hide()
        end
    else
        RepairWindow.rows = {}
    end

    for index, mount in ipairs(mounts) do
        local mountID = GetMountID(mount)
        local isCollected = IsMountCollected(mountID)

        -- Row container
        local row = CreateFrame("Frame", nil, RepairWindow)
        row:SetSize(400, 30)
        row:SetPoint("TOPLEFT", RepairWindow, "TOPLEFT", 10, rowYOffset)
        table.insert(RepairWindow.rows, row)

        -- Column 1: Icon
        local mountIcon = row:CreateTexture(nil, "ARTWORK")
        mountIcon:SetSize(20, 20)
        mountIcon:SetPoint("LEFT", row, "LEFT", 4, 0)
        mountIcon:SetTexture(mountIcons[index])

        -- Column 2: Mount Name
        local mountNameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        mountNameText:SetPoint("LEFT", mountIcon, "RIGHT", 10, 0)
        mountNameText:SetText(mount.name)

        -- Column 3: Mount/Dismount Button
        local statusWidget = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        statusWidget:SetSize(110, 25)
        statusWidget:SetPoint("CENTER", row, "CENTER", 92, 0) -- Centered in Column 3

        local function UpdateButtonText()
            statusWidget:SetText("") -- Clear text
            statusWidget:Disable() -- Default to disabled

            if not isCollected then
                statusWidget:SetText("Not Collected")
            elseif not CanPlayerMount() then
                statusWidget:SetText("Can't Mount")
            elseif IsMounted() then
                statusWidget:SetText("Dismount")
                statusWidget:Enable() -- Enable for interaction
            else
                statusWidget:SetText("Mount")
                statusWidget:Enable() -- Enable for interaction
            end
        end

        statusWidget:SetScript("OnClick", function()
            if not CanPlayerMount() then
                print("Mounting is not allowed in this area")
                return -- Prevent interaction
            end

            if IsMounted() then
                Dismount()
            else
                C_MountJournal.SummonByID(mountID)
            end
            UpdateButtonText()
        end)

        -- Update text on window show
        RepairWindow:HookScript("OnShow", function()
            UpdateButtonText()
        end)

        -- Initial text update
        UpdateButtonText()

        rowYOffset = rowYOffset - rowSpacing -- Adjust for next row
    end
end

-- Event Handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("COMPANION_UPDATE")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" or event == "COMPANION_UPDATE" then
        C_Timer.After(1, function()
            RefreshMountData()
            RefreshMountButtons()
        end)
    end
end)
	
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
						-- print(string.format("Found %s in Bag %d, Slot %d", buddy.name, bag, slot))
						break
					end
				end
				if buddy.slot then break end -- Stop searching once found
			end

			if not buddy.slot then
				-- print(string.format("Could not find %s in any bag.", buddy.name))
			end
		end
	end

-- Function to update buddy statuses
	local function RefreshBuddyStatuses()
		for index, buddy in ipairs(repairBuddies) do
			local statusButton = statusButtons[index]
			if statusButton then
-- Adjust the button width to accommodate longer text
				statusButton:SetWidth(120) -- Set desired width in pixels
			   
-- Check if the item is in the user's bags
				local itemCount = GetItemCount(buddy.itemID)
				if itemCount > 0 then
-- Get cooldown data
					local start, duration = GetItemCooldown(buddy.itemID)
					local cooldownRemaining = math.ceil(duration - (GetTime() - start))
					
					if start > 0 and duration > 0 then
-- Item is on cooldown, convert seconds to minutes
						local cooldownMinutes = math.ceil(cooldownRemaining / 60)
						statusButton:SetText(string.format("|cFFFFFF00On CD - %dm|r", cooldownMinutes)) -- Bright yellow text
						statusButton:Disable()
					else
-- Locate the item in bags
						if buddy.slot and buddy.slot.bag and buddy.slot.slot then
							local bag = buddy.slot.bag
							local slot = buddy.slot.slot
-- Display Quantity, Bag #, and Slot #
							statusButton:SetText(string.format("(%d) Bag %d Slot %d", itemCount, bag, slot))
						else
-- Fallback if slot info isn't available
							statusButton:SetText(string.format("(%d) Location Unknown", itemCount))
						end
						statusButton:Enable()
					end
					statusButton:Show() -- Force refresh
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
		statusButton:SetPoint("TOPLEFT", RepairWindow, "TOPLEFT", 240, repairRowYOffset)
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