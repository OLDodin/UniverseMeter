local m_isNearMask = 1 --0001 b
local m_isWasDeadMask = 2 --0010 b
local m_isWasKillMask = 4 --0100 b
local m_classColorIndexMask = 240 --1111 0000 b
local m_rangeMask = 65280 --1111 1111 0000 0000 b
--------------------------------------------------------------------------------
-- Type TCombatantData
Global("TCombatantData", {})
--------------------------------------------------------------------------------
function TCombatantData:CreateNewObject()
	return setmetatable({
			Amount = 0,						-- Total amount
			SpellsList = {},				-- List of spells used
			--Determination = nil, -- Determination level
		}, { __index = self })
end

--------------------------------------------------------------------------------
-- Type TCombatant
Global("TCombatant", {})
--------------------------------------------------------------------------------
function TCombatant:CreateNewObject(anID, aName, aClassName, anIsNear)
	local obj = setmetatable({
			ID = anID,				-- ID of the combatant
			Name = aName,			-- Name of the combatant
			Data = {					-- Data (Dps, Hps, Def)
			},
			BitPackedValue = 0,
		}, { __index = self })
		
	obj:SetIsNear(anIsNear)
	obj:SetClassColor(aClassName)
	
	return obj
end

function TCombatant:MakeCleanCopy()
	return TCombatant:CreateNewObject(self.ID, self.Name, self:GetClassColor(), self:GetIsNear())
end

function TCombatant:CreateCombatantData(aMode)
	if not self.Data[aMode] then
		self.Data[aMode] = TCombatantData:CreateNewObject()
	end
end
--------------------------------------------------------------------------------
-- Get spell by identifier 
--------------------------------------------------------------------------------
function TCombatant:GetSpellByIdentifier(anIdentifier, aMode, aSysSubElement)
	if not self.Data[aMode] then 
		return
	end
	for i, spellData in pairs( self.Data[aMode].SpellsList ) do
		if spellData.Identifier == anIdentifier and spellData.Element == aSysSubElement then
			return spellData
		end
	end
	return nil
end
--------------------------------------------------------------------------------
-- Get extra info by index
--------------------------------------------------------------------------------
function TCombatant:GetGlobalInfoByIndex(anIndex, aMode)
	if not self.Data[aMode] then 
		return
	end
	return self.Data[aMode].Determination
end
--------------------------------------------------------------------------------
-- Get spell by index
--------------------------------------------------------------------------------
function TCombatant:GetSpellByIndex(anIndex, aMode)
	if not self.Data[aMode] then 
		return
	end
	return self.Data[aMode].SpellsList[anIndex]
end

function TCombatant:GetAmount(aMode)
	if not self.Data[aMode] then 
		return 0
	end
	return self.Data[aMode].Amount
end

--------------------------------------------------------------------------------
-- Update Global Info
--------------------------------------------------------------------------------
function TCombatant:CreateGlobalInfo(aMode)
	self:CreateCombatantData(aMode)
	if not self.Data[aMode].Determination then
		self.Data[aMode].Determination = TValueDetails:CreateNewObject(enumGlobalInfo.Determination)
	end
end

function TCombatant:UpdateGlobalInfo(aDetermination, aMode)
	self:CreateGlobalInfo(aMode)
	self.Data[aMode].Determination:RecalcDetails(aDetermination)
	self.Data[aMode].Determination.Percentage = self.Data[aMode].Determination:GetAvg()
end

function TCombatant:MergeGlobalInfo(aMode, aCombatantData)
	if not aCombatantData.Data[aMode] or not aCombatantData.Data[aMode].Determination then
		return
	end
	self:CreateGlobalInfo(aMode)
	self.Data[aMode].Determination:MergeDetails(aCombatantData.Data[aMode].Determination)
	self.Data[aMode].Determination.Percentage = self.Data[aMode].Determination:GetAvg()
end
--------------------------------------------------------------------------------
-- Add a new spell to the list
--------------------------------------------------------------------------------
function TCombatant:AddNewSpell(aSpellInfo, aMode)
	if aSpellInfo then
		if aSpellInfo.lethal and aMode == enumMode.Dps then
			self:SetWasKill(true)
		elseif aSpellInfo.lethal and aMode == enumMode.Def then
			self:SetWasDead(true)
		end
		local SpellData
		if aMode == enumMode.Dps or aMode == enumMode.Def then
			SpellData = TDamageSpellData:CreateNewObject()
		elseif aMode == enumMode.Hps or aMode == enumMode.IHps  then
			SpellData = THealSpellData:CreateNewObject()
		end
		if SpellData then
			SpellData.Prefix = aSpellInfo.IsPet and StrPet or nil
			SpellData.PetName = aSpellInfo.IsPet and aSpellInfo.PetName or nil
			SpellData.Name = aSpellInfo.Name
			SpellData.Suffix = aSpellInfo.Suffix and aSpellInfo.Suffix or nil
			SpellData.Element = aSpellInfo.sysSubElement
			SpellData.Identifier = aSpellInfo.Identifier
			SpellData.Desc = aSpellInfo.Desc

			self:CreateCombatantData(aMode)
			table.insert(self.Data[aMode].SpellsList, SpellData)
			return SpellData
		end
	end
end

function TCombatant:AddCopySpell(aMode, aSpellData, aHitTime)
	local spellData = DeepCopyObject(aSpellData)
	spellData.FirstHitTime = aHitTime
	spellData.LastHitTime = aHitTime
	self:CreateCombatantData(aMode)
	table.insert(self.Data[aMode].SpellsList, spellData)
	return spellData
end

function TCombatant:UpdateSpellDataByInfo(aSpellInfo, aSpellData, aMode)
	if aSpellInfo.lethal and aMode == enumMode.Dps then
		self:SetWasKill(true)
	elseif aSpellInfo.lethal and aMode == enumMode.Def then
		self:SetWasDead(true)
	end
	aSpellData:ReceiveValuesFromParams(aSpellInfo)
end

--------------------------------------------------------------------------------
-- Clear the spell list and data
--------------------------------------------------------------------------------
function TCombatant:ClearData()
	for i, data in pairs( self.Data ) do
		data.Amount = 0
		data.AmountPerSec = nil
		data.Percentage = nil
		data.LeaderPercentage = nil
		data.SpellsList = {}
		data.Determination = nil
	end
end
--------------------------------------------------------------------------------
-- Compare spell by amount
--------------------------------------------------------------------------------
local function CompareSpells(A, B)
	if A.Amount == B.Amount then
		return common.CompareWString(A.Name, B.Name) == -1 end
	return A.Amount > B.Amount
end
--------------------------------------------------------------------------------
-- Sort the spell list by damage amount
--------------------------------------------------------------------------------
function TCombatant:SortSpellByAmount(aMode)
	table.sort(self.Data[aMode].SpellsList, CompareSpells)
end
--------------------------------------------------------------------------------
-- Calculate the damage, DPS, HPS, according to the fight time
--------------------------------------------------------------------------------
function TCombatant:CalculateSpell(aFightTime, aMode)
	if not (aFightTime > 0) then aFightTime = 1 end
	if not self.Data[aMode] then
		return
	end
	for i, spellData in pairs( self.Data[aMode].SpellsList ) do
		local spellResistAmount = spellData:GetResistAmount()
		spellData.AmountPerSec = spellData.Amount / aFightTime
		spellData.Percentage = GetPercentageAt(spellData.Amount, self.Data[aMode].Amount)
		spellData:CalculateSpellDetailsPercentage()
		spellData.ResistPercentage = GetPercentageAt(spellResistAmount, (spellData.Amount + spellResistAmount))
		if aMode == enumMode.Dps or aMode == enumMode.Def then
			spellData.ResistPercentage = spellData.ResistPercentage ~= 0 and -1 * spellData.ResistPercentage or spellData.ResistPercentage
		end
	end
	self:SortSpellByAmount(aMode)
end
--------------------------------------------------------------------------------
-- Update information of a combatant
--------------------------------------------------------------------------------
function TCombatant:UpdateCombatant(anID, aName, aClassColorIndex, anIsNear)
	if anID then self.ID = anID end
	if aName then self.Name = aName end
	self:SetClassColor(aClassColorIndex)
	self:SetIsNear(anIsNear)
end
--------------------------------------------------------------------------------
-- Update the Range attribute according to the avatar
--------------------------------------------------------------------------------
function TCombatant:UpdateRange()	
	if self.ID == avatar.GetId() then
		self:SetRange(0)
	else
		local pos = nil
		if self.ID and object.IsExist(self.ID) then
			pos = object.GetPos(self.ID)
		end
		self:SetRange(PosRange(avatar.GetPos(), pos))
	end
end
--------------------------------------------------------------------------------
-- Is the combatant close to the avatar
--------------------------------------------------------------------------------
function TCombatant:IsClose()
	return self:GetIsNear() and self:GetRange() <= Settings.CloseDist
end

function TCombatant:GetIsNear()
	return bit.band(self.BitPackedValue, m_isNearMask) == 1
end

function TCombatant:SetIsNear(aValue)
	self.BitPackedValue = bit.bor(bit.band(self.BitPackedValue,  bit.bnot(m_isNearMask)), aValue and 1 or 0)
end

function TCombatant:GetWasDead()
	return bit.rshift(bit.band(self.BitPackedValue, m_isWasDeadMask), 1) == 1
end

function TCombatant:SetWasDead(aValue)
	self.BitPackedValue = bit.bor(bit.band(self.BitPackedValue,  bit.bnot(m_isWasDeadMask)), aValue and bit.lshift(1, 1) or 0)
end

function TCombatant:GetWasKill()
	return bit.rshift(bit.band(self.BitPackedValue, m_isWasKillMask), 2) == 1
end

function TCombatant:SetWasKill(aValue)
	self.BitPackedValue = bit.bor(bit.band(self.BitPackedValue,  bit.bnot(m_isWasKillMask)), aValue and bit.lshift(1, 2) or 0)
end

function TCombatant:GetClassColor()
	return bit.rshift(bit.band(self.BitPackedValue, m_classColorIndexMask), 4)
end

function TCombatant:SetClassColor(aValue)
	self.BitPackedValue = bit.bor(bit.band(self.BitPackedValue,  bit.bnot(m_classColorIndexMask)), bit.lshift(aValue, 4))
end

function TCombatant:GetRange()
	return bit.rshift(bit.band(self.BitPackedValue, m_rangeMask), 8)
end

function TCombatant:SetRange(aValue)
	if aValue > 255 then --2^8
		aValue = 255
	end
	if aValue < 0 then
		aValue = 0
	end
	self.BitPackedValue = bit.bor(bit.band(self.BitPackedValue,  bit.bnot(m_rangeMask)), bit.lshift(aValue, 8))
end