local CollectibleTracker = {}

-- Function to check if the item is in the player's bags
local function IsItemInBag(itemID)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local bagItemInfo = C_Container.GetContainerItemInfo(bag, slot)
            if bagItemInfo and bagItemInfo.itemID == itemID then
                return true
            end
        end
    end
    return false
end

-- Function to check if the item is in the vendor window
local function IsItemInVendor(itemID)
    if MerchantFrame:IsShown() then
        for i = 1, GetMerchantNumItems() do
            local vendorItemLink = GetMerchantItemLink(i)
            local vendorItemID = vendorItemLink and GetItemInfoInstant(vendorItemLink)
            if vendorItemID == itemID then
                return true
            end
        end
    end
    return false
end

-- Function to check if the item is in the quest window
local function IsItemInQuestWindow(itemID)
    if QuestFrame and QuestFrame:IsShown() then
        -- Attempt to fetch the currently selected quest ID
        local questID = C_QuestLog.GetSelectedQuest()
        if questID and questID ~= 0 then -- Ensure questID is valid and not zero
            local success, numChoices = pcall(GetNumQuestLogChoices, questID) -- Use pcall for safer API handling
            if success and numChoices and numChoices > 0 then
                for i = 1, numChoices do
                    local questItemLink = GetQuestLogItemLink("choice", i)
                    local questItemID = questItemLink and GetItemInfoInstant(questItemLink)
                    if questItemID == itemID then
                        return true
                    end
                end
            end
        end
    end
    return false
end


local function ShouldTrackItem(itemID)
    if not itemID then return false end

    local _, _, _, _, _, itemType = GetItemInfo(itemID)

    -- Check if the item is weapon or gear
    if itemType == "Weapon" or itemType == "Armor" then
        -- Check if the item is in bags, vendor window, or quest window
        if IsItemInBag(itemID) or IsItemInVendor(itemID) or IsItemInQuestWindow(itemID) then
            return true
        end
    end

    return false
end

-- Function to handle tooltip modifications
hooksecurefunc(GameTooltip, "SetHyperlink", function(self, link)
    if link then
        local itemID = GetItemInfoInstant(link)
        local isCollected = false -- Track if we find any collected status

        if ShouldTrackItem(itemID) then
            -- Insert a blank line for clarity
            self:AddLine(" ") -- Adds a blank line

            -- Appearance check for visual ID
            local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemID)
            if appearanceID and C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) then
                self:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
                isCollected = true
            end

            -- Final fallback if no collected status found
            if not isCollected then
                self:AddLine("|cffff6060Channel Comms Status: Not Collected|r") -- Salmon color for clarity
            end

            self:Show() -- Refresh the tooltip display
        end
    end
end)

-- Tooltip processor for item tooltips
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if not data or not data.hyperlink then
        return -- Safeguard for nil data
    end

    local itemID = GetItemInfoInstant(data.hyperlink)
    local isCollected = false -- Track if we find any collected status

    if ShouldTrackItem(itemID) then
        -- Insert a blank line for clarity
        tooltip:AddLine(" ") -- Adds a blank line

        -- Appearance check for visual ID
        local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemID)
        if appearanceID and C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) then
            tooltip:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
            isCollected = true
        end

        -- Final fallback if no collected status found
        if not isCollected then
            tooltip:AddLine("|cffff6060Channel Comms Status: Not Collected|r") -- Salmon color for clarity
        end

        tooltip:Show() -- Refresh the tooltip display
    end
end)

-- Register the module within ChannelComms
ChannelComms.Modules.CollectibleTracker = CollectibleTracker