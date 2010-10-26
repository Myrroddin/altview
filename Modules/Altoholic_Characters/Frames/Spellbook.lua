local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local SPELLS_PER_PAGE = 12

addon.Spellbook = {}

local ns = addon.Spellbook		-- ns = namespace

local parent = "AltoholicFrameSpellbook"
local currentSchool, currentGlyphType
local currentPage

function ns:OnEnter(frame)
	local id = frame.spellID
	if id then 
		AltoTooltip:SetOwner(frame, "ANCHOR_LEFT");
		AltoTooltip:ClearLines();
		AltoTooltip:SetHyperlink("spell:" ..id);
		AltoTooltip:Show();
	end
end

function ns:OnClick(frame, button)
	if frame.spellID and ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
		local chat = ChatEdit_GetLastActiveWindow()
		if chat:IsShown() then
			local link = DataStore:GetCompanionLink(frame.spellID)
			if link then
				chat:Insert(link)
			end
		end
	end
end

local function SetPage(pageNum)
	currentPage = pageNum
	
	local character = addon.Tabs.Characters:GetCurrent()
	
	if currentPage == 1 then
		_G[parent .. "PrevPage"]:Disable()
	else
		_G[parent .. "PrevPage"]:Enable()
	end
	
	local maxPages = 1

	if currentSchool then
		maxPages = ceil(DataStore:GetNumSpells(character, currentSchool) / SPELLS_PER_PAGE)
	end
	
	if currentGlyphType then
		local glyphCount = 0
		for i = 1, DataStore:GetNumGlyphs(character) do
			local isHeader, _, group = DataStore:GetGlyphInfo(character, i)
			if not isHeader and group == currentGlyphType then
				glyphCount = glyphCount + 1
			end
		end
		
		maxPages = ceil(glyphCount / SPELLS_PER_PAGE)
	end
	
	if maxPages == 0 then
		maxPages = 1
	end
	
	if currentPage == maxPages then
		_G[parent .. "NextPage"]:Disable()
	else
		_G[parent .. "NextPage"]:Enable()
	end

	_G[parent .. "_PageNumber"]:SetText(format(PAGE_NUMBER, currentPage))	
	
	if currentSchool then ns:Update() end
	if currentGlyphType then ns:UpdateKnownGlyphs() end
end

function ns:GoToPreviousPage()
	SetPage(currentPage - 1)

end

function ns:GoToNextPage()
	SetPage(currentPage + 1)
end

function ns:Update()
	local character = addon.Tabs.Characters:GetCurrent()
	AltoholicTabCharactersStatus:SetText(format("%s|r / %s / %s", DataStore:GetColoredCharacterName(character), SPELLBOOK, currentSchool))
	
	local itemName, itemButton
	local spellID, availableAt

	local maxSpells = DataStore:GetNumSpells(character, currentSchool)
	local offset = (currentPage-1) * SPELLS_PER_PAGE
	local spellIndex = offset + 1
	
	local index = 1
	while index <= SPELLS_PER_PAGE do
		spellID, availableAt = DataStore:GetSpellInfo(character, currentSchool, spellIndex)
		
		if spellID then
			itemName = parent .. "_SpellIcon" .. index
			itemButton = _G[itemName]
			itemButton.spellID = spellID
	
			local name, info, icon = GetSpellInfo(spellID)
			
			addon:SetItemButtonTexture(itemName, icon, 30, 30)
			_G[itemName .. "SpellName"]:SetText(name)
			_G[itemName .. "SpellName"]:Show()
			
			_G[itemName .. "SubSpellName"]:Show()
			
			if availableAt == 0 then	-- 0 = already known
				_G[itemName .. "SpellName"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
				_G[itemName .. "SubSpellName"]:SetText(info)
				_G[itemName .. "SubSpellName"]:SetTextColor(0.50, 0.25, 0)
				_G[itemName .. "IconTexture"]:SetDesaturated(0)
				_G[itemName .. "IconTexture"]:SetVertexColor(1.0, 1.0, 1.0)
			else
				_G[itemName .. "SpellName"]:SetTextColor(0.4, 0.4, 0.4)
				_G[itemName .. "SubSpellName"]:SetFormattedText(SPELLBOOK_AVAILABLE_AT, availableAt)
				_G[itemName .. "SubSpellName"]:SetTextColor(0.4, 0.4, 0.4)
				_G[itemName .. "IconTexture"]:SetDesaturated(1)
				_G[itemName .. "IconTexture"]:SetVertexColor(0.4, 0.4, 0.4)
			end
			
			itemButton:Show()
			index = index + 1
		end
		
		spellIndex = spellIndex + 1
	
		if spellIndex > maxSpells then
			break
		end
	end
	
	while index <= SPELLS_PER_PAGE do
		itemButton = _G[parent .. "_SpellIcon" .. index]
		itemButton:Hide()
		index = index + 1
	end
	
	_G[ parent ]:Show()
end

function ns:UpdateKnownGlyphs()
	local character = addon.Tabs.Characters:GetCurrent()
	
	local glyphText
	if currentGlyphType == 1 then
		glyphText = PRIME_GLYPHS
	elseif currentGlyphType == 2 then
		glyphText = MAJOR_GLYPHS
	elseif currentGlyphType == 3 then
		glyphText = MINOR_GLYPHS
	end
	
	AltoholicTabCharactersStatus:SetText(format("%s|r / %s / %s", DataStore:GetColoredCharacterName(character), SPELLBOOK, glyphText))
	
	if currentGlyphType == 1 then
		glyphText = PRIME_GLYPH
	elseif currentGlyphType == 2 then
		glyphText = MAJOR_GLYPH
	elseif currentGlyphType == 3 then
		glyphText = MINOR_GLYPH
	end
	
	local itemName, itemButton
	local isHeader, isKnown, group, spellID
	
	local maxGlyphs = DataStore:GetNumGlyphs(character)
	local offset = (currentPage-1) * SPELLS_PER_PAGE
	local glyphIndex = 1
	local skipCount = 0	-- number of glyphs of the same category that have been skipped (don't display while skipCount is lower than offset
	
	local index = 1
	while index <= SPELLS_PER_PAGE do
		isHeader, isKnown, group, spellID = DataStore:GetGlyphInfo(character, glyphIndex)
		
		if not isHeader and (group == currentGlyphType) then		-- not a header and right group ? process
		
			if skipCount < offset then
				skipCount = skipCount + 1
			else
				itemName = parent .. "_SpellIcon" .. index
				itemButton = _G[itemName]
				itemButton.spellID = spellID
				
				local name, _, icon = GetSpellInfo(spellID)
				
				addon:SetItemButtonTexture(itemName, icon, 30, 30)
				_G[itemName .. "SpellName"]:SetText(name)
				_G[itemName .. "SpellName"]:Show()
				_G[itemName .. "SubSpellName"]:SetText(glyphText)
				_G[itemName .. "SubSpellName"]:Show()
				
				if isKnown then
					_G[itemName .. "SpellName"]:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
					_G[itemName .. "SubSpellName"]:SetTextColor(0.50, 0.25, 0)
					_G[itemName .. "IconTexture"]:SetDesaturated(0)
					_G[itemName .. "IconTexture"]:SetVertexColor(1.0, 1.0, 1.0)
				else
					_G[itemName .. "SpellName"]:SetTextColor(0.4, 0.4, 0.4)
					_G[itemName .. "SubSpellName"]:SetTextColor(0.4, 0.4, 0.4)
					_G[itemName .. "IconTexture"]:SetDesaturated(1)
					_G[itemName .. "IconTexture"]:SetVertexColor(0.4, 0.4, 0.4)
				end

				itemButton:Show()
			
				index = index + 1
			end
		end
		glyphIndex = glyphIndex + 1
	
		if glyphIndex > maxGlyphs then
			break
		end
	end
	
	while index <= SPELLS_PER_PAGE do
		itemButton = _G[parent .. "_SpellIcon" .. index]
		itemButton:Hide()
		index = index + 1
	end
	
	_G[ parent ]:Show()
end

function ns:SetSchool(school)
	currentSchool = school
	currentGlyphType = nil
	SetPage(1)
end

function ns:SetGlyphType(id)
	currentSchool = nil
	currentGlyphType = id
	SetPage(1)
end
