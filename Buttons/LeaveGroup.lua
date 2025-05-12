-------------------------------------------------------------
-- Create Leave Group Button for running multi-old raids
-------------------------------------------------------------
	_G.leaveGroupButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	leaveGroupButton:SetSize(32, 32) -- Adjust size for visibility
--	leaveGroupButton:SetPoint("LEFT", LootsButton, "RIGHT", 1, 0) -- Positioned next to Gear Score button
	leaveGroupButton:SetPoint("LEFT", repairButton, "RIGHT", 1, 0) -- Positioned next to Gear Score button	
	leaveGroupButton:SetNormalTexture("Interface\\Icons\\ability_hunter_beastsoothe") -- Hand icon

-- Add click functionality to leave the group
	leaveGroupButton:SetScript("OnClick", function()
		if IsInGroup() then
			C_PartyInfo.LeaveParty() -- Drops the player from the party or raid
		else
			print("You are not in a group.") -- Feedback if not in a group
		end
	end)

-- Add tooltip functionality
	leaveGroupButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText("Leave Group", 1, 0.2, 0.2) -- Red text color for visibility
		GameTooltip:Show()
	end)
	leaveGroupButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	leaveGroupButton:Show() -- Ensure the button appears
