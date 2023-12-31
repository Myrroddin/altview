local addonName = "Altoholic"
local addon = _G[addonName]
local colors = addon.Colors
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local currentPage
local MAX_PAGES = 12	-- good for 144 alts, should be enough, 1 page per class is even possible
local CHARS_PER_FRAME = 12
local gridCallbacks = {}

addon:Controller("AltoholicUI.TabGrids", {
	OnBind = function(frame)
		currentPage = 1
		frame.PageNumber:SetText(format(MERCHANT_PAGE_NUMBER, currentPage, MAX_PAGES))
	
		frame.Label1:SetText(L["Realm"])
		frame.Equipment.text = L["Equipment"]
		frame.Factions.text = L["Reputations"]
		frame.Archeology.text = GetSpellInfo(78670)
		frame.Dailies.text = "Daily Quests"
		frame.FollowerAbilities.text = format("%s/%s", GARRISON_RECRUIT_ABILITIES, GARRISON_RECRUIT_TRAITS)
		frame.Sets.text = WARDROBE_SETS
		
		frame.SelectRealm:RegisterClassEvent("RealmChanged", function()
				frame.Status:SetText("")
				frame:Update()
			end)
		
		frame.ClassIcons.OnCharacterChanged = function()
				frame:Update()
			end
			
		frame.Equipment:StartAutoCastShine()
		frame.currentGridID = 1
	end,
	RegisterGrid = function(frame, gridID, callbacks)
		gridCallbacks[gridID] = callbacks
	end,
	InitializeGrid = function(frame, gridID)
		if gridCallbacks[gridID] then
			gridCallbacks[gridID].InitViewDDM(frame.SelectView, frame.TextView)
		end
		frame.currentGridID = gridID
	end,
	Update = function(frame)
		local account, realm = frame.SelectRealm:GetCurrentRealm()
		frame.ClassIcons:Update(account, realm, currentPage)

		local grids = AltoholicFrameGrids
		local scrollFrame = grids.ScrollFrame
		local numRows = scrollFrame.numRows
		grids:Show()
			
		local offset = scrollFrame:GetOffset()
		frame:SetStatus("")
		
		local obj = gridCallbacks[frame.currentGridID]	-- point to the callbacks of the current object (equipment, tabards, ..)
		obj:OnUpdate()
		
		local size = obj:GetSize()
		local itemButton
		
		for rowIndex = 1, numRows do
			local rowFrame = scrollFrame:GetRow(rowIndex)
			local dataRowID = rowIndex + offset
			if dataRowID <= size then	-- if the row is visible

				obj:RowSetup(rowFrame, dataRowID)
				itemButton = rowFrame.Name
				itemButton:SetScript("OnEnter", obj.RowOnEnter)
				itemButton:SetScript("OnLeave", obj.RowOnLeave)
				
				for colIndex = 1, CHARS_PER_FRAME do
					itemButton = rowFrame["Item"..colIndex]
					itemButton.IconBorder:Hide()
					
					local optionIndex = ((currentPage - 1) * 12) + colIndex		-- Pages = 1-12, 13-24, etc..
					
					character = addon:GetOption(format("Tabs.Grids.%s.%s.Column%d", account, realm, optionIndex))
					if character then
						itemButton:SetScript("OnEnter", obj.OnEnter)
						itemButton:SetScript("OnClick", obj.OnClick)
						itemButton:SetScript("OnLeave", obj.OnLeave)
						
						itemButton:Show()	-- note: this Show() must remain BEFORE the next call, if the button has to be hidden, it's done in ColumnSetup
						obj:ColumnSetup(itemButton, dataRowID, character)
					else
						itemButton.id = nil
						itemButton:Hide()
					end
				end

				rowFrame:Show()
			else
				rowFrame:Hide()
			end
		end

		scrollFrame:Update(size)
	end,
	UpdateMenuIcons = function(frame)
		if DataStore_Inventory then
			frame.Equipment:EnableIcon()
		else
			frame.Equipment:DisableIcon()
		end

		if DataStore_Reputations then
			frame.Factions:EnableIcon()
		else
			frame.Factions:DisableIcon()
		end
		
		if DataStore_Currencies then
			frame.Tokens:EnableIcon()
		else
			frame.Tokens:DisableIcon()
		end
		
		if DataStore_Pets then
			frame.Pets:EnableIcon()
		else
			frame.Pets:DisableIcon()
		end

		if DataStore_Quests then
			frame.Dailies:EnableIcon()
		else
			frame.Dailies:DisableIcon()
		end
		
		if DataStore_Agenda then
			frame.Dungeons:EnableIcon()
		else
			frame.Dungeons:DisableIcon()
		end
		
		if DataStore_Garrisons then
			frame.GarrisonArchitect:EnableIcon()
			frame.GarrisonFollowers:EnableIcon()
			frame.FollowerAbilities:EnableIcon()
		else
			frame.GarrisonArchitect:DisableIcon()
			frame.GarrisonFollowers:DisableIcon()
			frame.FollowerAbilities:DisableIcon()
		end
	end,
	SetStatus = function(frame, text)
		frame.Status:SetText(text or "")
	end,
	SetViewDDMText = function(frame, text)
		frame.SelectView:SetText(text)
	end,
	GoToPreviousPage = function(frame)
		frame:SetPage(currentPage - 1)
	end,
	GoToNextPage = function(frame)
		frame:SetPage(currentPage + 1)
	end,
	GetPage = function(frame)
		return currentPage
	end,
	SetPage = function(frame, pageNum)
		currentPage = pageNum

		-- fix minimum page number
		currentPage = (currentPage < 1) and 1 or currentPage
		
		if currentPage == 1 then
			frame.PrevPage:Disable()
		else
			frame.PrevPage:Enable()
		end
		
		-- fix maximum page number
		currentPage = (currentPage > MAX_PAGES) and MAX_PAGES or currentPage
		
		if currentPage == MAX_PAGES then
			frame.NextPage:Disable()
		else
			frame.NextPage:Enable()
		end

		frame.PageNumber:SetText(format(MERCHANT_PAGE_NUMBER, currentPage, MAX_PAGES))	
		frame:Update()
	end,
	GetRealm = function(frame)
		return frame.SelectRealm:GetCurrentRealm()	-- returns : account, realm
	end,
})
