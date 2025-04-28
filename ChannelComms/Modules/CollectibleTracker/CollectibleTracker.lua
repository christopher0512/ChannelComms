local CollectibleTracker = {}

-- Function to handle tooltip modifications
hooksecurefunc(GameTooltip, "SetHyperlink", function(self, link)
    if link then
        local itemID = GetItemInfoInstant(link)
        local isCollected = false -- Track if we find any collected status

        -- Insert a blank line for clarity
        self:AddLine(" ") -- Adds a blank line

        -- Appearance check for visual ID
        local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemID)
        if appearanceID and C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) then
            self:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
            isCollected = true
        end

        if not isCollected then
            -- Toy collection check
            if PlayerHasToy(itemID) then
                self:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
                isCollected = true
            end
        end

        if not isCollected then
            -- Mount collection check
            local mountID = C_MountJournal.GetMountFromItem(itemID)
            if mountID and C_MountJournal.IsMountCollected(mountID) then
                self:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
                isCollected = true
            end
        end

        if not isCollected then
            -- Heirloom collection check
            if C_Heirloom.PlayerHasHeirloom(itemID) then
                self:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
                isCollected = true
            end
        end

        -- Final fallback if no collected status found
        if not isCollected then
            self:AddLine("|cffff6060Channel Comms Status: Not Collected|r") -- Salmon color for clarity
        end

        self:Show() -- Refresh the tooltip display
    end
end)

-- Register the tooltip processor for item tooltips
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
    if not data or not data.hyperlink then
        return -- Safeguard for nil data
    end

    local itemID = GetItemInfoInstant(data.hyperlink)
    local isCollected = false -- Track if we find any collected status

    -- Insert a blank line for clarity
    tooltip:AddLine(" ") -- Adds a blank line

    -- Appearance check for visual ID
    local appearanceID, sourceID = C_TransmogCollection.GetItemInfo(itemID)
    if appearanceID and C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) then
        tooltip:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
        isCollected = true
    end

    if not isCollected then
        -- Toy collection check
        if PlayerHasToy(itemID) then
            tooltip:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
            isCollected = true
        end
    end

    if not isCollected then
        -- Mount collection check
        local mountID = C_MountJournal.GetMountFromItem(itemID)
        if mountID and C_MountJournal.IsMountCollected(mountID) then
            tooltip:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
            isCollected = true
        end
    end

    if not isCollected then
        -- Heirloom collection check
        if C_Heirloom.PlayerHasHeirloom(itemID) then
            tooltip:AddLine("|cff00ff00Channel Comms Status: Collected|r") -- Green
            isCollected = true
        end
    end

    -- Final fallback if no collected status found
    if not isCollected then
        tooltip:AddLine("|cffff6060Channel Comms Status: Not Collected|r") -- Salmon color for clarity
    end

    tooltip:Show() -- Refresh the tooltip display
end)

-- Register the module within ChannelComms
ChannelComms.Modules.CollectibleTracker = CollectibleTracker