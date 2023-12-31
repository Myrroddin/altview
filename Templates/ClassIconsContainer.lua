local addonName = "Altoholic"
local addon = _G[addonName]

local OPTION_FORMAT = "Tabs.%s.%s.%s.Column%d"

addon:Controller("AltoholicUI.ClassIconsContainer", {
	OnBind = function(frame)
		local prefix = frame.iconPrefix
			
		-- auto create the sort buttons, with the quantity passed as key
		for i = 1, frame.numIcons do
			local button = CreateFrame("Button", nil, frame, frame.iconTemplate)
			
			if i == 1 then
				button:SetPoint("TOPLEFT")
			else
				-- attach to previous frame
				button:SetPoint("TOPLEFT", frame[prefix..(i-1)], "TOPRIGHT", 5, 0)
			end
			
			button:SetID(i)
			frame[prefix..i] = button
		end	
	end,
	SetIDs = function(frame, page)
		for i = 1, frame.numIcons do
			local index = ((page - 1) * 12) + i		-- Pages = 1-12, 13-24, etc..
			
			frame[frame.iconPrefix..i]:SetID(index)
		end		
	end,
	Update = function(frame, account, realm, page)
		frame:SetIDs(page)
	
		local tabName = frame.tabName
		local numIcons = frame.numIcons
		
		local key = addon:GetOption(format(OPTION_FORMAT, tabName, account, realm, 1))
		if not key then	-- first time this realm is displayed, or reset by player
		
			local index = 1

			-- Clear all options for this tab, for all pages
			addon:ClearOptions(format("Tabs.%s.%s.%s.Column", tabName, account, realm))
			
			-- add the first 11 keys found on this realm
			for characterName, characterKey in pairs(DataStore:GetCharacters(realm, account)) do	
				-- ex: : ["Tabs.Grids.Default.MyRealm.Column4"] = "Account.realm.alt7"

				addon:SetOption(format(OPTION_FORMAT, tabName, account, realm, index), characterKey)
				
				index = index + 1
				if index > numIcons then
					break
				end
			end
		end

		-- Set each class/icon
		for i = 1, numIcons do
			local class, faction, _
			
			local index = ((page - 1) * 12) + i		-- Pages = 1-12, 13-24, etc..
			
			key = addon:GetOption(format(OPTION_FORMAT, tabName, account, realm, index))
			if key then
				_, class = DataStore:GetCharacterClass(key)
				faction = DataStore:GetCharacterFaction(key)
			end
			
			frame[frame.iconPrefix..i]:SetClass(class, faction)
		end
	end,
})
