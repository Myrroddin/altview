local addonName = "Altoholic"
local addon = _G[addonName]

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local WHITE		= "|cFFFFFFFF"
local GREEN		= "|cFF00FF00"
local YELLOW	= "|cFFFFFF00"
local RED		= "|cFFFF0000"
local TEAL		= "|cFF00FF9A"

addon.Mail = {}

local ns = addon.Mail		-- ns = namespace

local function SortByName(a, b, ascending)
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	
	local textA = DS:GetMailSubject(character, a) or ""
	local textB = DS:GetMailSubject(character, b) or ""

	if ascending then
		return textA < textB
	else
		return textA > textB
	end
end

local function SortBySender(a, b, ascending)
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	
	local senderA = DS:GetMailSender(character, a)
	local senderB = DS:GetMailSender(character, b)

	if ascending then
		return senderA < senderB
	else
		return senderA > senderB
	end
end

local function SortByExpiry(a, b, ascending)
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	
	local _, expiryA = DS:GetMailExpiry(character, a)
	local _, expiryB = DS:GetMailExpiry(character, b)
	
	if ascending then
		return expiryA < expiryB
	else
		return expiryA > expiryB
	end
end

function ns:BuildView(field, ascending)
	
	field = field or "expiry"

	self.view = self.view or {}
	wipe(self.view)
	
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	if not character then return end
	
	local numMails = DS:GetNumMails(character) or 0
	for i = 1, numMails do
		table.insert(self.view, i)
	end

	if field == "name" then
		table.sort(self.view, function(a, b) return SortByName(a, b, ascending) end)
	elseif field == "from" then
		table.sort(self.view, function(a, b) return SortBySender(a, b, ascending) end)
	elseif field == "expiry" then
		table.sort(self.view, function(a, b) return SortByExpiry(a, b, ascending) end)
	end
end

function ns:Update()
	local VisibleLines = 7
	local frame = "AltoholicFrameMail"
	local entry = frame.."Entry"
	
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	
	local numMails = DS:GetNumMails(character) or 0
	AltoholicTabCharacters.Status:SetText(format("%s|r / %s", DataStore:GetColoredCharacterName(character), format(L["Mails %s(%d)"], GREEN, numMails)))
	if numMails == 0 then		-- make sure the scroll frame is cleared !
		addon:ClearScrollFrame( _G[ frame.."ScrollFrame" ], entry, VisibleLines, 41)
		return
	end
	
	local offset = FauxScrollFrame_GetOffset( _G[ frame.."ScrollFrame" ] );
	
	for i=1, VisibleLines do
		local line = i + offset
		if line <= numMails then
			local index = ns.view[line]
			
			local icon, count, link, _, _, wasReturned = DS:GetMailInfo(character, index)
			
			_G[ entry..i.."Name" ]:SetText(link or DS:GetMailSubject(character, index))
			_G[ entry..i.."Character" ]:SetText(DS:GetMailSender(character, index))
			
			local msg
			if not wasReturned then
				msg = format(L["Will be %sreturned|r in"], GREEN, WHITE)
			else
				msg = format(L["Will be %sdeleted|r in"], RED, WHITE)
			end
			
			local _, seconds = DataStore:GetMailExpiry(character, index)
			_G[ entry..i.."Expiry" ]:SetText(format("%s:\n%s", msg, WHITE .. SecondsToTime(seconds)))
			
			_G[ entry..i.."ItemIconTexture" ]:SetTexture(icon);
			if count and count > 1 then
				_G[ entry..i.."ItemCount" ]:SetText(count)
				_G[ entry..i.."ItemCount" ]:Show()
			else
				_G[ entry..i.."ItemCount" ]:Hide()
			end
			-- trick: pass the index of the current item in the results table, required for the tooltip
			_G[ entry..i.."Item" ]:SetID(index)
			_G[ entry..i ]:Show()
		else
			_G[ entry..i ]:Hide()
		end
	end
	
	if numMails < VisibleLines then
		FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], VisibleLines, VisibleLines, 41);
	else
		FauxScrollFrame_Update( _G[ frame.."ScrollFrame" ], numMails, VisibleLines, 41);
	end
end

function ns:Sort(self, field)
	ns:BuildView(field, self.ascendingSort)
	ns:Update()
end

function ns:OnEnter(self)
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	local index = self:GetID()
	local _, _, link, money, text = DS:GetMailInfo(character, index)
						
	if link then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetHyperlink(link);
		GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:ClearLines();
		
		local subject = DS:GetMailSubject(character, index)
		if subject then 
			GameTooltip:AddLine("|cFFFFFFFF" .. subject,1,1,1);
		end
		if text then 
			GameTooltip:AddLine("|cFFFFD700" .. text, 1, 1, 1, 1, 1);
		end
		if money > 0 then
			GameTooltip:AddLine("|rAttached Money: " .. addon:GetMoneyString(money),1,1,1);
		end
		GameTooltip:Show();
	end
end

function ns:OnClick(self, button)
	local DS = DataStore
	local character = addon.Tabs.Characters:GetAltKey()
	local index = self:GetID()
	local _, _, link = DS:GetMailInfo(character, index)

	if link then
		if ( button == "LeftButton" ) and ( IsShiftKeyDown() ) then
			local chat = ChatEdit_GetLastActiveWindow()
			if chat:IsShown() then
				chat:Insert(link);
			end
		end
	end
end
