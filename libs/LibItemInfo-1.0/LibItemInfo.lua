--[[	*** LibItemInfo ***
Written by : Thaoky, EU-Marécages de Zangar
March 19th, 2021

This library contains various information about items, namely:

- the expansion pack to which that item is related
- the profession to which the item is related (for reagents or crafted goods)
- etc..

The information returned is not necessarily the source, although it may be, it is mostly where the item is to be used.
Ex: enchanted heavy callous hide would be "leatherworking", even though it was created by "enchanting".
Leatherworking is the profession where it will be helpful, and is also the bag type that in which it will be stored.

Note: I know the game is now supposed to returned the expansion pack of an item with GetItemInfo, but it appears this info
is only valid for BfA & Shadowlands. Older items are mostly invalid.

--]]

local LIB_VERSION_MAJOR, LIB_VERSION_MINOR = "LibItemInfo-1.0", 1
local lib = LibStub:NewLibrary(LIB_VERSION_MAJOR, LIB_VERSION_MINOR)

if not lib then return end -- No upgrade needed

local L = {
	["Multiple Professions"] = "Multiple Professions"
}

local locale = GetLocale()
if locale == "frFR" then
	L["Multiple Professions"] = "Plusieurs Professions"
elseif locale == "deDE" then
	L["Multiple Professions"] = "Mehrere Berufe"
end

--[[ ** Data Format **
format [spellID] = attribute (number, to be read bit by bit)

'attribute' :
	bits 0-3 : internal id of the tradeskill (4 bits)
	bits 4-7 : expansion level (4 bits)
	bits 8-27 : item id (resulting item)
	bits 28-47 : item id (of the recipe item teaching this spell ID)
--]]

-- *** Bitwise operations ***
local bAnd = bit.band
local bOr = bit.bor
local RShift = bit.rshift
local LShift = bit.lshift

local function RightShift(value, numBits)
	-- for bits beyond bit 31
	return math.floor(value / 2^numBits)
end

local function LeftShift(value, numBits)
   -- for bits beyond bit 31
   return value * 2^numBits
end

local itemDB = {}

lib.Enum = {
	ReagentTypes = {
		Alchemy = 1,
		Blacksmithing = 2,
		Enchanting = 3,
		Engineering = 4,
		Herbalism = 5,
		Inscription = 6,
		Jewelcrafting = 7,
		Leatherworking = 8,
		Mining = 9,
		Skinning = 10,
		Tailoring = 11,
		Cooking = 12,
		Archaeology = 13,
		Fishing = 14,
		Multi = 15,
	},
	BagTypes = {
		-- These id's match GetItemSubClassInfo(LE_ITEM_CLASS_CONTAINER, id)
		SoulBag = 1,
		HerbBag = 2,
		EnchantingBag = 3,
		EngineeringBag = 4,
		GemBag = 5,
		MiningBag = 6,
		LeatherworkingBag = 7,
		InscriptionBag = 8,
		TackleBox = 9,
		CookingBag = 10,
	},
}

local TYPE_REAGENT = 1

local reagentTypes = {
	[1] = GetSpellInfo(2259),		-- Alchemy
	[2] = GetSpellInfo(3100),		-- Blacksmithing
	[3] = GetSpellInfo(7411),		-- Enchanting
	[4] = GetSpellInfo(4036),		-- Engineering
	[5] = GetSpellInfo(2366),		-- Herbalism
	[6] = GetSpellInfo(45357),		-- Inscription
	[7] = GetSpellInfo(25229),		-- Jewelcrafting
	[8] = GetSpellInfo(2108),		-- Leatherworking
	[9] = GetSpellInfo(2656),		-- Mining
	[10] = GetSpellInfo(8613),		-- Skinning
	[11] = GetSpellInfo(3908),		-- Tailoring
	[12] = GetSpellInfo(2550),		-- Cooking
	[13] = GetSpellInfo(78670),	-- Archaeology
	[14] = GetSpellInfo(131474),	-- Fishing
	[15] = L["Multiple Professions"],	-- For items used in multiple professions
}

local bagTypes = {}

for i = 1, 10 do
	bagTypes[i] = GetItemSubClassInfo(LE_ITEM_CLASS_CONTAINER, i)
end

--	*** API ***

function lib:RegisterItems(itemList)
	for itemID, itemInfo in pairs(itemList) do
		if not itemDB[itemID] then
			itemDB[itemID] = itemInfo
		else
			print(format("LibItemInfo: item %d is already registered", itemID))
		end
	end
end

-- Set item information for a crafting reagent
-- Note that the goal is not necessarily to match the in-game approach.
-- For example, fishes are cooking reagents, but are categorized here as "Fishing", because one of the use cases is to be able
-- to show that fishes would go into a fishing bag.
function lib.SetReagent(expansion, professionID, level, goesInBag)
	return expansion											-- Bits 0-4 : expansion (classic = 0)
		+ (TYPE_REAGENT * 32)								-- Bits 5-9 : type
		+ (professionID * 2^10)								-- Bits 10-14 : profession
		+ ((goesInBag or 0) * 2^15)						-- Bits 15-18 : bag type
		+ ((level or 0) * 2^19)								-- Bits 19+ : level
end

-- Returns the name of the profession that created the item
function lib:GetItemSource(itemID)
	if not itemDB[itemID] then return end

	local attrib = itemDB[itemID]
	local expansion = bAnd(attrib, 31)							-- Bits 0-4 : expansion (classic = 0)
	local itemType = bAnd(RightShift(attrib, 5), 31)		-- Bits 5-9 : type
	
	if itemType == TYPE_REAGENT then
		local professionID = bAnd(RightShift(attrib, 10), 31)		-- Bits 10-14 : profession
		local goesInBag = bAnd(RightShift(attrib, 15), 15)			-- Bits 15-18 : bag type
		local level = bAnd(RightShift(attrib, 19), 524287)			-- Bits 19+ : level
		
		local profession = reagentTypes[professionID] or UNKNOWN
		if level > 0 then
			profession = format("%s, %d", profession, level)
		end
		
		return _G[format("EXPANSION_NAME%d", expansion)], expansion, profession, bagTypes[goesInBag]
	end
end
