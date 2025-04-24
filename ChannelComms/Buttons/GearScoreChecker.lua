-------------------------------------------------------------
-- Create Gear Score Button and it popup window for quick
-- access to your average and sorting but best/worst pieces
-------------------------------------------------------------

	_G.gearScoreButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	gearScoreButton:SetSize(32, 32) -- Button size
	gearScoreButton:SetPoint("LEFT", masterToggleButton, "RIGHT", 4, 0) -- Position next to Toggle Tool Tips Button

-- Set up icon for the gear score button
	local gearScoreIcon = gearScoreButton:CreateTexture(nil, "ARTWORK")
	gearScoreIcon:SetTexture("Interface\\Icons\\achievement_challengemode_platinum") -- Icon texture
	gearScoreIcon:SetAllPoints(gearScoreButton)

	gearScoreButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Your Gear Score")
		GameTooltip:Show()
	end)

	gearScoreButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

-- Define slotMapping
	local slotMapping = {
		[1] = "Head", [2] = "Neck", [3] = "Shoulder", [4] = "Chest",
		[5] = "Waist", [6] = "Legs", [7] = "Feet", [8] = "Wrist",
		[9] = "Hands", [10] = "Finger1", [11] = "Finger2", [12] = "Trinket1",
		[13] = "Trinket2", [14] = "Back", [15] = "MainHand", [16] = "OffHand", [17] = "Ranged"
	}

-- FetchGearScores function
	local function FetchGearScores()
		local gearScores = {}
		local totalItemLevel = 0
		local itemCount = 0

		for slotID = 1, 18 do
-- Skip the Shirt slot (slotID = 4)
			if slotID ~= 4 then
				local itemLink = GetInventoryItemLink("player", slotID)
				if itemLink then
					local _, _, _, itemLevel = GetItemInfo(itemLink)
					if itemLevel then
						-- Use slotMapping to get the slot name
						local slotName = slotMapping[#gearScores + 1] -- Dynamically assign based on remaining slots
						gearScores[#gearScores + 1] = { name = slotName or "Slot" .. #gearScores + 1, level = itemLevel }
						totalItemLevel = totalItemLevel + itemLevel
						itemCount = itemCount + 1
					end
				end
			end
		end

-- Calculate average item level (exclude Shirt slot)
		local averageItemLevel = itemCount > 0 and math.ceil(totalItemLevel / itemCount) or 0
		return gearScores, averageItemLevel
	end

-- CreatePopupWindow function
	local function CreatePopupWindow(sortMode)
		gearScoreButton:Disable() -- Disable the button when the popup is opened

		local gearScores, averageItemLevel = FetchGearScores()

-- Sort gearScores based on sortMode
		if sortMode == "H2L" then
			table.sort(gearScores, function(a, b) return a.level > b.level end)
		elseif sortMode == "L2H" then
			table.sort(gearScores, function(a, b) return a.level < b.level end)
		else
-- Default to T2B sorting (slotMapping order)
			local sortedGearScores = {}
			for slotIndex = 1, #slotMapping do
				for _, gear in ipairs(gearScores) do
					if gear.name == slotMapping[slotIndex] then
						table.insert(sortedGearScores, gear)
						break
					end
				end
			end
			gearScores = sortedGearScores -- Replace with sorted array order
		end

-- Create popup window
		local popupFrame = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplateWithInset")
		popupFrame:SetSize(200, 300)
		popupFrame:SetPoint("CENTER", UIParent, "CENTER")

-- Make the popup draggable
		popupFrame:SetMovable(true)
		popupFrame:EnableMouse(true)
		popupFrame:RegisterForDrag("LeftButton")
		popupFrame:SetScript("OnDragStart", popupFrame.StartMoving)
		popupFrame:SetScript("OnDragStop", popupFrame.StopMovingOrSizing)

-- Set transparency (alpha)
		popupFrame:SetAlpha(0.9)

-- Create maroon background under the title
		local titleBackground = popupFrame:CreateTexture(nil, "BACKGROUND")
		titleBackground:SetColorTexture(0.5, 0, 0) -- Maroon color (RGB values)
		titleBackground:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", 4, -4)
		titleBackground:SetPoint("TOPRIGHT", popupFrame, "TOPRIGHT", -4, -4)
		titleBackground:SetHeight(30)

-- Add a dynamic title properly centered
		local popupTitle = popupFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		popupTitle:SetPoint("CENTER", titleBackground, "CENTER", -10, 8)
		popupTitle:SetText("Gear Score: " .. averageItemLevel)
		popupTitle:SetTextColor(1, 1, 0) -- Yellow color for the title

-- Create content area directly within the popup and adjust position
		local content = CreateFrame("Frame", nil, popupFrame)
		content:SetPoint("TOPLEFT", popupFrame, "TOPLEFT", 10, -46)
		content:SetPoint("BOTTOMRIGHT", popupFrame, "BOTTOMRIGHT", -10, 40)

-- Populate gear scores in the content frame
		local previousText = nil
		for i, gear in ipairs(gearScores) do
			local gearText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			gearText:SetPoint("TOPLEFT", previousText or content, previousText and "BOTTOMLEFT" or "TOPLEFT", 0, previousText and -2 or -2)
			gearText:SetText(gear.name .. ": " .. gear.level)
			previousText = gearText
		end

-- Add sorting buttons at the bottom
	local function CreateSortButton(parent, label, tooltip, point, sortType)
		local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
		button:SetSize(50, 22)
		button:SetText(label)
		button:SetPoint(unpack(point))
		button:SetScript("OnClick", function()
			parent:Hide()
			CreatePopupWindow(sortType)
		end)
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT") -- Position tooltip away from button
			GameTooltip:SetText(tooltip)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
			button:Show() -- Ensure button remains visible
		end)
		return button
	end

		CreateSortButton(popupFrame, "T2B", "T2B: Sort in default slot order.", { "BOTTOMLEFT", popupFrame, "BOTTOMLEFT", 10, 10 }, "T2B")
		CreateSortButton(popupFrame, "L2H", "L2H: Sort from lowest to highest item level.", { "BOTTOM", popupFrame, "BOTTOM", 0, 10 }, "L2H")
		CreateSortButton(popupFrame, "H2L", "H2L: Sort from highest to lowest item level.", { "BOTTOMRIGHT", popupFrame, "BOTTOMRIGHT", -10, 10 }, "H2L")

-- Re-enable the button when the popup is hidden
		popupFrame:SetScript("OnHide", function()
			gearScoreButton:Enable()
		end)

		popupFrame:Show()
	end

-- Set up Gear Score Button click behavior
	gearScoreButton:SetScript("OnClick", function()
		CreatePopupWindow()
	end)
gearScoreButton:Show()