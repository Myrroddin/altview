local addon = LibStub("AceAddon-3.0"):NewAddon("Altoholic_Renewed", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "AceTimer-3.0", "LibMVC-1.0")
local DataStore = LibStub("AceAddon-3.0"):GetAddon("DataStore_Renewed")

addon.Version = 1.00

local L = LibStub("AceLocale-3.0"):GetLocale("Altoholic_Renewed")
local commPrefix = "Altoholic_Renewed"

BINDING_HEADER_ALTOHOLIC_RENEWED = "Altoholic_Renewed"
BINDING_NAME_ALTOHOLIC_TOGGLE_RENEWED = L["Toggle UI"]

-- the UI options table
local options = {
	type = "group",
	args = {
		search = {
			type = "input",
			name = SEARCH,
			usage = L["<item name>"],
			desc = L["Search in bags"],
			get = false,
			set = "CmdSearchBags",
		},
		show = {
			type = "execute",
			name = SHOW,
			desc = L["Shows the UI"],
			func = function() AltoholicFrame:Show() end
		},
		hide = {
			type = "execute",
			name = HIDE,
			desc = L["Hides the UI"],
			func = function() AltoholicFrame:Hide() end
		},
		toggle = {
			type = "execute",
			name = L["Toggle"],
			desc = L["Toggles the UI"],
			func = function() addon:ToggleUI() end
		}
	}
}

-- addon defaults for the options
local defaults = {
	global = {
		Guilds = {
			['*'] = {			-- ["Account.Realm.Name"]
				hideInTooltip = nil,		-- true if this guild should not be shown in the tooltip counters
			}
		},
		Characters = {
			['*'] = {					-- ["Account.Realm.Name"]
			},
		},
		Sharing = {
			Clients = {},
			SharedContent = {			-- lists the shared content
				--	["Account.Realm.Name"]  = true means the char is shared,
				--	["Account.Realm.Name.Module"]  = true means the module is shared for that char
			},
			Domains = {
				['*'] = {			-- ["Account.Realm"]
					lastSharingTimestamp = nil,	-- a date, the last time information from this realm/account was queried and successfully saved.
					lastUpdatedWith = nil,		-- last player with whom the account sharing took place
				},
			},
		},
		unsafeItems = {},
		moreRecentVersion = nil,
		options = {
			-- ** Summary tab options **
			["UI.Tabs.Summary.ShowRestXP150pc"] = false,						-- display max rest xp in normal 100% mode or in level equivalent 150% mode ?
			["UI.Tabs.Summary.CurrentMode"] = 1,								-- current mode (1 = account summary, 2 = bags, ...)
			["UI.Tabs.Summary.CurrentColumn"] = "Name",						-- current column (default = "Name")
			["UI.Tabs.Summary.CurrentRealms"] = 2,								-- selected realms (current/all in current/all accounts)
			["UI.Tabs.Summary.CurrentFactions"] = 3,							-- 1 = Alliance, 2 = Horde, 3 = Both
			["UI.Tabs.Summary.CurrentLevels"] = 1,								-- 1 = All
			["UI.Tabs.Summary.CurrentLevelsMin"] = 1,
			["UI.Tabs.Summary.CurrentLevelsMax"] = 60,
			["UI.Tabs.Summary.CurrentClasses"] = 0,							-- 0 = All
			["UI.Tabs.Summary.CurrentTradeSkill"] = 0,						-- 0 = All
			["UI.Tabs.Summary.SortAscending"] = true,							-- ascending or descending sort order
			["UI.Tabs.Summary.ShowLevelDecimals"] = true,					-- display character level with decimals or not
			["UI.Tabs.Summary.ShowILevelDecimals"] = true,					-- display character level with decimals or not
			["UI.Tabs.Summary.ShowGuildRank"] = false,						-- display the guild rank or the guild name

			-- ** Character tab options **
			["UI.Tabs.Characters.ViewBags"] = true,
			["UI.Tabs.Characters.ViewBank"] = true,
			["UI.Tabs.Characters.ViewBagsAllInOne"] = false,
			["UI.Tabs.Characters.ViewVoidStorage"] = true,
			["UI.Tabs.Characters.ViewReagentBank"] = true,
			["UI.Tabs.Characters.ViewBagsRarity"] = 0,						-- rarity level of items (not a boolean !)
			["UI.Tabs.Characters.GarrisonMissions"] = 1,						-- available missions = 1, active missions = 2
			["UI.Tabs.Characters.SortAscending"] = true,						-- ascending or descending sort order
			["UI.Tabs.Characters.ViewLearnedRecipes"] = true,				-- View learned recipes ?
			["UI.Tabs.Characters.ViewUnlearnedRecipes"] = false,			-- View unlearned recipes ?

			-- ** Search tab options **
			["UI.Tabs.Search.ItemInfoAutoQuery"] = false,
			["UI.Tabs.Search.IncludeNoMinLevel"] = true,				-- include items with no minimum level
			["UI.Tabs.Search.IncludeMailboxItems"] = true,
			["UI.Tabs.Search.IncludeGuildBankItems"] = true,
			["UI.Tabs.Search.IncludeKnownRecipes"] = true,
			["UI.Tabs.Search.SortAscending"] = true,							-- ascending or descending sort order
			TotalLoots = 0,					-- make at least one search in the loot tables to initialize these values
			UnknownLoots = 0,

			-- ** Guild Bank tab options **
			["UI.Tabs.Guild.BankItemsRarity"] = 0,								-- rarity filter in the guild bank tab
			["UI.Tabs.Guild.BankAutoUpdate"] = false,							-- can the guild bank tabs update requests be answered automatically or not.
			["UI.Tabs.Guild.SortAscending"] = true,							-- ascending or descending sort order

			-- ** Grids tab options **
			["UI.Tabs.Grids.Reputations.CurrentXPack"] = 1,					-- Current expansion pack
			["UI.Tabs.Grids.Reputations.CurrentFactionGroup"] = 1,		-- Current faction group in that xpack
			["UI.Tabs.Grids.Currencies.CurrentTokenType"] = nil,			-- Current token type (default to nil = all-in-one)
			["UI.Tabs.Grids.Companions.CurrentXPack"] = 1,					-- Current expansion pack
			["UI.Tabs.Grids.Mounts.CurrentFaction"] = 1,						-- Current faction
			["UI.Tabs.Grids.Tradeskills.CurrentXPack"] = 1,					-- Current expansion pack
			["UI.Tabs.Grids.Tradeskills.CurrentTradeSkill"] = 1,			-- Current tradeskill index
			["UI.Tabs.Grids.Archaeology.CurrentRace"] = 1,					-- Current race index
			["UI.Tabs.Grids.Dungeons.CurrentXPack"] = 1,						-- Current expansion pack
			["UI.Tabs.Grids.Dungeons.CurrentRaids"] = 1,						-- Current raid index
			["UI.Tabs.Grids.Garrisons.CurrentBuildings"] = 1,				-- Current building type
			["UI.Tabs.Grids.Garrisons.CurrentFollowers"] = 1,				-- Current follower type
			["UI.Tabs.Grids.Garrisons.CurrentStats"] = 1,					-- Current stats (abilities = 1, traits = 2, counters = 3)
			["UI.Tabs.Grids.Sets.IncludePVE"] = true,							-- Include PVE Sets
			["UI.Tabs.Grids.Sets.IncludePVP"] = true,							-- Include PVP Sets
			["UI.Tabs.Grids.Sets.CurrentXPack"] = 1,							-- Current expansion pack
			["UI.Tabs.Grids.Emissaries.ShowXPack6"] = true,					-- Show Legion Emissaries
			["UI.Tabs.Grids.Emissaries.ShowXPack7"] = true,					-- Show BfA Emissaries
			["UI.Tabs.Grids.Emissaries.ShowXPack8"] = true,					-- Show Shadowlands Emissaries

			-- ** Tooltip options **
			["UI.Tooltip.ShowItemSource"] = true,
			["UI.Tooltip.ShowItemXPack"] = true,
			["UI.Tooltip.ShowItemCount"] = true,
			["UI.Tooltip.ShowSimpleCount"] = false,				-- display just the counter, without details (like AH, equipped, etc..)
			["UI.Tooltip.ShowTotalItemCount"] = true,
			["UI.Tooltip.ShowKnownRecipes"] = true,
			["UI.Tooltip.ShowItemID"] = false,						-- display item id & item level in the tooltip (default: off)
			["UI.Tooltip.ShowGatheringNodesCount"] = true,		-- display counters when mousing over a gathering node (default:  on)
			["UI.Tooltip.ShowCrossFactionCount"] = true,			-- display counters for both factions on a pve server
			["UI.Tooltip.ShowMergedRealmsCount"] = true,			-- display counters for characters on connected realms
			["UI.Tooltip.ShowAllAccountsCount"] = true,			-- display counters for all accounts on the same realm
			["UI.Tooltip.ShowGuildBankCount"] = true,				-- display guild bank counters
			["UI.Tooltip.ShowHearthstoneCount"] = true,			-- display hearthstone counters
			["UI.Tooltip.IncludeGuildBankInTotal"] = true,		-- total count = alts + guildbank (1) or alts only (0)
			["UI.Tooltip.ShowGuildBankCountPerTab"] = false,	-- guild count = guild:count or guild (tab 1: x, tab2: y ..)

			-- ** Mail options **
			["UI.Mail.GuildMailWarning"] = true,					-- be informed when a guildie sends a mail to one of my alts
			["UI.Mail.AutoCompleteRecipient"] = true,				-- Auto complete recipient name when sending a mail
			["UI.Mail.LastExpiryWarning"] = 0,						-- Last time a mail expiry warning was triggered
			["UI.Mail.TimeToNextWarning"] = 3,						-- Time before the warning is repeated ('3' = no warning for 3 hours)

			-- ** Minimap options **
			["UI.Minimap.ShowIcon"] = true,
			["UI.Minimap.IconAngle"] = 180,
			["UI.Minimap.IconRadius"] = 78,

			-- ** Calendar options **
			["UI.Calendar.WarningsEnabled"] = true,
			["UI.Calendar.UseDialogBoxForWarnings"] = false,	-- use a dialog box for warnings (true), or default chat frame (false)
			["UI.Calendar.WeekStartsOnMonday"] = false,

			WarningType1 = "30|15|10|5|4|3|2|1",		-- for profession cooldowns
			WarningType2 = "30|15|10|5|4|3|2|1",		-- for dungeon resets
			WarningType3 = "30|15|10|5|4|3|2|1",		-- for calendar events
			WarningType4 = "30|15|10|5|4|3|2|1",		-- for item timers (like mysterious egg)

			-- ** Global options **
			["UI.AHColorCoding"] = true,					-- color coded recipes at the AH
			["UI.VendorColorCoding"] = true,				-- color coded recipes at vendors
			["UI.AccountSharing.IsEnabled"] = false,	-- account sharing communication handler is disabled by default

			["UI.Scale"] = 1.0,
			["UI.Transparency"] = 1.0,
			["UI.ClampWindowToScreen"] = true,

		}
	}
}

addon.Colors = {
	white	= "|cFFFFFFFF",
	red = "|cFFFF0000",
	darkred = "|cFFF00000",
	green = "|cFF00FF00",
	orange = "|cFFFF7F00",
	yellow = "|cFFFFFF00",
	gold = "|cFFFFD700",
	teal = "|cFF00FF9A",
	cyan = "|cFF1CFAFE",
	lightBlue = "|cFFB0B0FF",
	battleNetBlue = "|cff82c5ff",
	grey = "|cFF909090",

	-- classes
	classMage = "|cFF69CCF0",
	classHunter = "|cFFABD473",

	-- recipes
	recipeGrey = "|cFF808080",
	recipeGreen = "|cFF40C040",
	recipeOrange = "|cFFFF8040",

	-- rarity : http://wow.gamepedia.com/Quality
	common = "|cFFFFFFFF",
	uncommon = "|cFF1EFF00",
	rare = "|cFF0070DD",
	epic = "|cFFA335EE",
	legendary = "|cFFFF8000",
	heirloom = "|cFFE6CC80",

	Alliance = "|cFF2459FF",
	Horde = "|cFFFF0000"
}

addon.Icons = {
	ready = "\124TInterface\\RaidFrame\\ReadyCheck-Ready:14\124t",
	waiting = "\124TInterface\\RaidFrame\\ReadyCheck-Waiting:14\124t",
	notReady = "\124TInterface\\RaidFrame\\ReadyCheck-NotReady:14\124t",
	questionMark = "Interface\\RaidFrame\\ReadyCheck-Waiting",

	Alliance = "Interface\\Icons\\INV_BannerPVP_02",
	Horde = "Interface\\Icons\\INV_BannerPVP_01",
	Neutral = "Interface\\Icons\\Achievement_character_pandaren_female",
}

-- Place Enums in a separate file when there are enough to justify it
addon.Enum = {
	ArmorTypes = {
		[1] = GetItemSubClassInfo(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Cloth),			-- "Cloth"
		[2] = GetItemSubClassInfo(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Leather),		-- "Leather"
		[3] = GetItemSubClassInfo(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Mail),			-- "Mail"
		[4] = GetItemSubClassInfo(Enum.ItemClass.Armor, Enum.ItemArmorSubclass.Plate)			-- "Plate"
	}
}

-- ** LDB Launcher **
LibStub("LibDataBroker-1.1"):NewDataObject("Altoholic_Renewed", {
	type = "launcher",
	icon = "Interface\\Icons\\INV_Drink_13",
	OnClick = function(clickedframe, button)
		addon:ToggleUI()
	end,
	label = "Altoholic_Renewed",
})

local guildMembersVersion = {} 	-- hash table containing guild member info

-- Message types
local MSG_SEND_VERSION							= 1	-- Send Altoholic's version
local MSG_VERSION_REPLY							= 2	-- Reply

-- *** Utility functions ***
local function GuildBroadcast(messageType, ...)
	local serializedData = addon:Serialize(messageType, ...)
	addon:SendCommMessage(commPrefix, serializedData, "GUILD")
end

local function GuildWhisper(player, messageType, ...)
	if DataStore:IsGuildMemberOnline(player) then
		local serializedData = addon:Serialize(messageType, ...)
		addon:SendCommMessage(commPrefix, serializedData, "WHISPER", player)
	end
end

local function SaveVersion(sender, version)
	guildMembersVersion[sender] = version
end

-- *** Guild Comm ***
local function OnAnnounceLogin()
	GuildBroadcast(MSG_SEND_VERSION, addon.Version)
end

local function OnSendVersion(sender, versionNum)
	if sender ~= UnitName("player") then							-- don't send back to self
		GuildWhisper(sender, MSG_VERSION_REPLY, addon.Version)		-- reply by sending my own version
	end
	SaveVersion(sender, versionNum)									-- .. and save it

	if versionNum > addon.Version and not addon.db.global.moreRecentVersion then
		addon:Print(L["A new version of Altoholic_Renewed is available, consider upgrading to get the latest features."])
		addon:Print(L["Official sources: curseforge.com, wago.io, & wowinterface.com"])
		addon.db.global.moreRecentVersion = addon.Version
	end
end

local function OnVersionReply(sender, version)
	SaveVersion(sender, version)
end

local GuildCommCallbacks = {
	[MSG_SEND_VERSION] = OnSendVersion,
	[MSG_VERSION_REPLY] = OnVersionReply,
}

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("Altoholic_RenewedDB", defaults)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Altoholic_Renewed", options)

	self:RegisterChatCommand("altoholic", "ChatCommand")
	self:RegisterChatCommand("alto", "ChatCommand")

	DataStore:SetGuildCommCallbacks(commPrefix, GuildCommCallbacks)

	self:RegisterMessage("DATASTORE_ANNOUNCELOGIN", OnAnnounceLogin)

	selfn:RegisterComm("AltoShare", "AccSharingHandler")
	self:RegisterComm(commPrefix, DataStore:GetGuildCommHandler())

	-- this event MUST stay here, we have to be able to respond to a request event if the guild tab is not loaded
	self:RegisterMessage("DATASTORE_BANKTAB_REQUESTED")
	self:RegisterMessage("DATASTORE_GUILD_MAIL_RECEIVED")
	self:RegisterMessage("DATASTORE_GLOBAL_MAIL_EXPIRY")
	self:RegisterMessage("DATASTORE_CS_TIMEGAP_FOUND")
	self:RegisterMessage("DATASTORE_AUCTIONS_NOT_CHECKED_SINCE")

	local global = addon.db.global
	if global.moreRecentVersion and addon.Version >= global.moreRecentVersion then
		global.moreRecentVersion = nil
	end
end

function addon:GetGuildMemberVersion(member)
	if guildMembersVersion[member] then			-- version number of a main ?
		return guildMembersVersion[member]		-- return it immediately
	end

	-- check if member is an alt
	local main = DataStore:GetNameOfMain(member)
	if main and guildMembersVersion[main] then
		return guildMembersVersion[main]
	end
end

function addon:ChatCommand(input)
	if not input then
		LibStub("AceConfigDialog-3.0"):Open("Altoholic_Renewed")
	else
		LibStub("AceConfigCmd-3.0").HandleCommand(addon, "Alto", "Altoholic", input)
	end
end

addon.TradeSkills = {
	Recipes = {},
	-- spell IDs in alphabetical order (english), primary then secondary
	spellIDs = { 2259, 3100, 7411, 4036, 45357, 25229, 2108, 2656, 3908, 2550, 3273 },
	firstSecondarySkillIndex = 10, -- index of the first secondary profession in the table

	AccountSummaryFiltersSpellIDs = { 2259, 3100, 7411, 4036, 2366, 45357, 25229, 2108, 2575, 8613, 3908, 2550, 131474, 78670 },
	AccountSummaryFirstSecondarySkillIndex = 12, -- index of the first secondary profession in the table

	Names = {
		ALCHEMY = GetSpellInfo(2259),
		ARCHAEOLOGY = GetSpellInfo(78670),
		BLACKSMITHING = GetSpellInfo(3100),
		COOKING = GetSpellInfo(2550),
		ENCHANTING = GetSpellInfo(7411),
		ENGINEERING = GetSpellInfo(4036),
		FISHING = GetSpellInfo(131474),
		HERBALISM = GetSpellInfo(2366),
		INSCRIPTION = GetSpellInfo(45357),
		JEWELCRAFTING = GetSpellInfo(25229),
		LEATHERWORKING = GetSpellInfo(2108),
		MINING = GetSpellInfo(2575),
		SKINNING = GetSpellInfo(8613),
		SMELTING = GetSpellInfo(2656),
		TAILORING = GetSpellInfo(3908),
		FIRSTAID = GetSpellInfo(3273)
	},
}

-- ** Tabs **
local tabList = {
	"Summary",
	"Characters",
	"Search",
	"Guild",
	"Achievements",
	"Agenda",
	"Grids",
}

local frameToID = {}
for index, name in ipairs(tabList) do
	frameToID[name] = index
end

local function SafeLoadAddOn(name)
	if not IsAddOnLoaded(name) then
		LoadAddOn(name)
	end
end

local function ShowTab(name)
	local tab = "Altoholic_Renewed.." .. "Tab" .. name
	if tab then
		tab:Show()
	end
end

local function HideTab(name)
	local tab = "Altoholic_Renewed.." .. "Tab" .. name
	if tab then
		tab:Hide()
	end
end

addon.Tabs = {}

function addon.Tabs:HideAll()
	for _, tabName in pairs(tabList) do
		HideTab(tabName)
	end
end

function addon.Tabs:OnClick(index)
	if type(index) == "string" then
		index = frameToID[index]
	end

	PanelTemplates_SetTab("Altoholic_Renewed.." .. "Frame", index)
	self:HideAll()
	self.current = index

	if index >= 1 and index <= 7 then
		local moduleName = format("%s_%s", "Altoholic_Renewed", tabList[index])
		SafeLoadAddOn(moduleName)		-- make this part a bit more generic once we'll have more LoD parts

		local parentLevel = AltoholicFrame:GetFrameLevel()
		local childName = format("%sTab%s", "Altoholic_Renewed", tabList[index])

		local tabFrame = _G[ childName ]

		if tabFrame then
			local childLevel = tabFrame:GetFrameLevel()

			if childLevel <= parentLevel then	-- if for any reason a child frame has a level lower or equal to its parent, fix it
				tabFrame:SetFrameLevel(parentLevel+1)
			end
		else
			self:Print(L["%s is disabled."]:format(moduleName))
		end
	end

	ShowTab(tabList[index])
end

-- allow ESC to close the main frame
tinsert(UISpecialFrames, "AltoholicFrame")
tinsert(UISpecialFrames, "AltoMessageBox")

function addon:CmdSearchBags(arg1, arg2)
	-- arg 1 is a table, no idea of what it does, investigate later, only  arg2 matters at this point

	if string.len(arg2) == 0 then
		self:Print(L["Usage = /altoholic search <item name>"])
		return
	end

	if not (AltoholicFrame:IsVisible()) then
		AltoholicFrame:Show()
	end
	AltoholicFrame_SearchEditBox:SetText(strlower(arg2))
	addon.Tabs:OnClick("Search")
	addon.Search:FindItem()
end