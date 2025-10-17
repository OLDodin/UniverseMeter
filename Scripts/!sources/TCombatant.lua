local enumCount = enumSpellInfo.Count
local enumAmount = enumSpellInfo.Amount
local enumName = enumSpellInfo.Name
local enumHits = enumSpellInfo.Hits

local enumHitCritical = enumHit.Critical

local enumHitBarrier = enumHitBlock.Barrier

local enumCombatantID = enumCombatantInfo.ID
local enumCombatantName = enumCombatantInfo.Name
local enumCombatantPacked = enumCombatantInfo.BitPackedValue
local enumCombatantData = enumCombatantInfo.Data

local m_isNearMask = { mask = 1, shift = 0 } --0b 0001 b
local m_isAbsentMask = { mask = 2, shift = 1 } --0b 0010 b
local m_classColorIndexMask = { mask = 240, shift = 4 }  --0b 1111 0000 b
local m_rangeMask = { mask = 65280, shift = 8 } --0b 1111 1111 0000 0000 b

-- c 1 начнется уже массив spell-ов self[enumCombatantData][aMode]
local DetermInd = 0

-- хранят последнее посчитанное значение глобально
local m_physicalDamagePercent = nil
local m_elementalDamagePercent = nil
local m_holyDamagePercent = nil
local m_naturalDamagePercent = nil
--------------------------------------------------------------------------------
-- Type TCombatantData
Global("TCombatantData", {})
--------------------------------------------------------------------------------
function TCombatantData:CreateNewObject()
	return 
	{
		--[0] - DetermInd -решимость, а далее с [1] массив spellData
		--Amount = 0 -только для TFight, в TFightPeriod вычисляем 
	}
end

--------------------------------------------------------------------------------
-- Type TCombatant
Global("TCombatant", {})
--------------------------------------------------------------------------------
function TCombatant:CreateNewObject(anID, aName, aClassName, anIsNear)
	local obj = {
			[enumCombatantID] = anID,
			[enumCombatantName] = aName,
			[enumCombatantPacked] = 0,
			[enumCombatantData] = {}			-- Data (Dps, Hps, Def)
		}
		
	TCombatant.SetIsNear(obj, anIsNear)
	TCombatant.SetClassColor(obj, aClassName)
	
	return obj
end

function TCombatant:MakeCleanCopy()
	return TCombatant:CreateNewObject(self[enumCombatantID], self[enumCombatantName], TCombatant.GetClassColor(self), TCombatant.IsNear(self))
end

function TCombatant:CreateCombatantData(aMode)
	local modeData = self[enumCombatantData][aMode]
	if not modeData then
		modeData = TCombatantData:CreateNewObject()
		self[enumCombatantData][aMode] = modeData
	end
	
	return modeData
end

-- update Amount in TFight
function TCombatant:RecalculateAmount(aValue, aMode, anUpdateLast)
	local combatantData = TCombatant.CreateCombatantData(self, aMode)
	if combatantData.LastAmount == nil then
		combatantData.LastAmount = 0
	end
	combatantData.Amount = combatantData.LastAmount + aValue
	if anUpdateLast then
		combatantData.LastAmount = combatantData.Amount
	end
end

function TCombatant:CalculateCombatantsData(aMode, aFightTime, aFightAmount, aLeaderAmount)
	local currData = self[enumCombatantData][aMode]
	if currData then
		local modeAmount = TCombatant.GetAmount(self, aMode)
		currData.AmountPerSec = modeAmount / aFightTime
		currData.Percentage = GetPercentageAt(modeAmount, aFightAmount)
		currData.LeaderPercentage = GetPercentageAt(modeAmount, aLeaderAmount)
	end
end

--------------------------------------------------------------------------------
-- Get spell by identifier 
--------------------------------------------------------------------------------
function TCombatant:GetSpellByIdentifier(aMode, anIsPet, aSysSubElement, aName)
	local modeData = self[enumCombatantData][aMode]
	if not modeData then 
		return
	end
	for _, spellData in ipairs( modeData ) do
		if IsPetData(spellData) == anIsPet and GetSpellDataElement(spellData) == aSysSubElement and spellData[enumName] == aName then
			return spellData
		end
	end
	return nil
end
--------------------------------------------------------------------------------
-- Get extra info by index
--------------------------------------------------------------------------------
function TCombatant:CalculateDamageTypePercent(aMode)
	local physicalAmount = 0
	local elementalAmount = 0
	local holyAmount = 0
	local naturalAmount = 0

	local physicalCnt = 0
	local elementalCnt = 0
	local holyCnt = 0
	local naturalCnt = 0
	
	local totalAmount = 0
	
	for _, spellData in ipairs( self[enumCombatantData][aMode] ) do
		if not IsSpellDataFromBarrier(spellData) then
			if GetSpellDataElement(spellData) == enumDmgTypes.Physical then
				physicalCnt = physicalCnt + spellData[enumCount]
				physicalAmount = physicalAmount + spellData[enumAmount]
			elseif GetSpellDataElement(spellData) == enumDmgTypes.Elemental then
				elementalCnt = elementalCnt + spellData[enumCount]
				elementalAmount = elementalAmount + spellData[enumAmount]
			elseif GetSpellDataElement(spellData) == enumDmgTypes.Holy then
				holyCnt = holyCnt + spellData[enumCount]
				holyAmount = holyAmount + spellData[enumAmount]
			elseif GetSpellDataElement(spellData) == enumDmgTypes.Natural then
				naturalCnt = naturalCnt + spellData[enumCount]
				naturalAmount = naturalAmount + spellData[enumAmount]
			end
			
			totalAmount = totalAmount + spellData[enumAmount]
		end
	end
	
	m_physicalDamagePercent = TValueDetails:CreateNewObjectOneValue(GetPercentageAt(physicalAmount, totalAmount), physicalCnt)
	m_elementalDamagePercent = TValueDetails:CreateNewObjectOneValue(GetPercentageAt(elementalAmount, totalAmount), elementalCnt)
	m_holyDamagePercent = TValueDetails:CreateNewObjectOneValue(GetPercentageAt(holyAmount, totalAmount), holyCnt)
	m_naturalDamagePercent = TValueDetails:CreateNewObjectOneValue(GetPercentageAt(naturalAmount, totalAmount), naturalCnt)
end

function TCombatant:GetGlobalInfoByIndex(anIndex, aMode)
	local modeData = self[enumCombatantData][aMode]
	if not modeData then 
		return
	end
	if anIndex == enumGlobalInfo.Determination then
		return modeData[DetermInd]
	elseif anIndex == enumGlobalInfo.Critical then
		local critCnt = 0
		local totalCnt = 0
		for _, spellData in ipairs( modeData ) do
			local critSpellData = DetailsList(spellData)[enumHitCritical]
			critCnt = critCnt + (critSpellData and TValueDetails.GetCount(critSpellData) or 0)
			if aMode == enumMode.Dps or aMode == enumMode.Def then
				totalCnt = totalCnt + spellData[enumHits]
			else
				totalCnt = totalCnt + spellData[enumCount]
			end
		end
		return TValueDetails:CreateNewObjectOneValue(GetPercentageAt(critCnt, totalCnt), critCnt)
	elseif anIndex == enumGlobalInfo.Physical then
		return m_physicalDamagePercent
	elseif anIndex == enumGlobalInfo.Elemental then 
		return m_elementalDamagePercent
	elseif anIndex == enumGlobalInfo.Holy then
		return m_holyDamagePercent
	elseif anIndex == enumGlobalInfo.Natural then
		return m_naturalDamagePercent
	end
end
--------------------------------------------------------------------------------
-- Get spell by index
--------------------------------------------------------------------------------
function TCombatant:GetSpellByIndex(anIndex, aMode)
	local modeData = self[enumCombatantData][aMode]
	if not modeData then 
		return
	end

	return modeData[anIndex]
end

function TCombatant:GetSpellCount(aMode)
	local modeData = self[enumCombatantData][aMode]
--self[enumCombatantData][aMode] содержит и буквенные ключи
	if not modeData then 
		return 0
	end
	
	return #modeData
end

function TCombatant:GetCombatantData(aMode)
	return self[enumCombatantData][aMode]
end

function TCombatant:HasData(aMode)
	local dataByModes = self[enumCombatantData]
	return dataByModes[enumMode.Dps] or dataByModes[enumMode.Def] or dataByModes[enumMode.Hps] or dataByModes[enumMode.IHps]
end

function TCombatant:GetAmount(aMode)
	local modeData = self[enumCombatantData][aMode]
	if not modeData then 
		return 0
	end
	-- for TFight Combatant
	if modeData.Amount then
		return modeData.Amount
	end
	local amount = 0
	-- for TFightPeriod Combatant
	for _, spellData in ipairs( modeData ) do
		amount = amount + spellData[enumAmount]
	end
	return amount
end

function TCombatant:GetBarrierAmount(aMode)
	local modeData = self[enumCombatantData][aMode]
	if not modeData then 
		return 0
	end
	local barrierAmount = 0
	local resistList
	for _, spellData in ipairs( modeData ) do
		resistList = ResistDetailsList(spellData)
		if resistList[enumHitBarrier] then
			barrierAmount = barrierAmount + TValueDetails.GetAmount(resistList[enumHitBarrier])
		end
	end
	return barrierAmount
end

--------------------------------------------------------------------------------
-- Update Global Info
--------------------------------------------------------------------------------
function TCombatant:CreateGlobalInfo(aMode)
	local combatantData = TCombatant.CreateCombatantData(self, aMode)
	if not combatantData[DetermInd] then
		combatantData[DetermInd] = TValueDetails:CreateNewObject()
	end
	return combatantData
end

function TCombatant:UpdateGlobalInfo(anInfoIndex, aMode, aDetermination)
	if anInfoIndex == enumGlobalInfo.Determination then
		local combatantData = TCombatant.CreateGlobalInfo(self, aMode)
		TValueDetails.RecalcDetails(combatantData[DetermInd], aDetermination)
	end
end

function TCombatant:MergeGlobalInfo(aMode, aCombatant)
	local newCombatantData = aCombatant[enumCombatantData][aMode]
	if not newCombatantData or not newCombatantData[DetermInd] then
		return
	end
	local combatantData = TCombatant.CreateGlobalInfo(self, aMode)
	TValueDetails.MergeDetails(combatantData[DetermInd], newCombatantData[DetermInd])
end


--------------------------------------------------------------------------------
-- Add a new spell to the list
--------------------------------------------------------------------------------
function TCombatant:AddNewSpell(aSpellInfo, aMode)
	local spellData
	if aMode == enumMode.Dps or aMode == enumMode.Def then
		spellData = TDamageSpellData:CreateNewObject()
	else
		spellData = THealSpellData:CreateNewObject()
	end

	InitSpellDataByInfo(spellData, aSpellInfo)
	
	table.insert(TCombatant.CreateCombatantData(self, aMode), spellData)
	
	return spellData
end

function TCombatant:AddCopySpell(aMode, aSpellData, aHitTime)
	local spellData = SimpleRecursiveCloneTable(aSpellData)
	spellData.FirstHitTime = aHitTime
	spellData.LastHitTime = aHitTime
	
	table.insert(TCombatant.CreateCombatantData(self, aMode), spellData)
	return spellData
end

function TCombatant:UpdateSpellDataByInfo(aSpellInfo, aSpellData, aMode)
	FillSpellDataFromParams(aSpellData, aSpellInfo)
end

--------------------------------------------------------------------------------
-- Compare spell by amount
--------------------------------------------------------------------------------
local function CompareSpells(A, B)
	if A[enumAmount] == B[enumAmount] then
		return A[enumName] < B[enumName] end
	return A[enumAmount] > B[enumAmount]
end
--------------------------------------------------------------------------------
-- Calculate the damage, DPS, HPS, according to the fight time
--------------------------------------------------------------------------------
function TCombatant:CalculateSpells(aFightTime, aMode)
	if not (aFightTime > 0) then aFightTime = 1 end
	local combatantData = self[enumCombatantData][aMode]
	if not combatantData then
		return
	end
	for _, spellData in ipairs( combatantData ) do
		CalculateSpellDetailsPercentage(spellData, aFightTime, TCombatant.GetAmount(self, aMode))
	end
	table.sort(combatantData, CompareSpells)
	
	TCombatant.CalculateDamageTypePercent(self, aMode)
end
--------------------------------------------------------------------------------
-- Update information of a combatant
--------------------------------------------------------------------------------
function TCombatant:UpdateCombatant(anID, aName, aClassColorIndex, anIsNear)
	if anID then self[enumCombatantID] = anID end
	if aName then self[enumCombatantName] = aName end
	TCombatant.SetClassColor(self, aClassColorIndex)
	TCombatant.SetIsNear(self, anIsNear)
end
--------------------------------------------------------------------------------
-- Update the Range attribute according to the avatar
--------------------------------------------------------------------------------
function TCombatant:UpdateRange()	
	if self[enumCombatantID] == MyAvatarID then
		TCombatant.SetRange(self, 0)
	else
		TCombatant.SetRange(self, GetDistanceToTarget(self[enumCombatantID]))
	end
end

function TCombatant:GetBuffLeghtInPeriod(aMode, aBuffInd)
	local combatantData = self[enumCombatantData][aMode]
	
	local cnt = 0
	local buffPercent = 0
	for _, spellData in ipairs(combatantData or {}) do
		buffPercent = buffPercent + GetBuffPercentByIndex(spellData, aBuffInd)
		cnt = cnt + 1
	end
	
	return buffPercent / math.max(cnt, 1)
end

function TCombatant:GetName()
	return self[enumCombatantName]
end

function TCombatant:GetID()
	return self[enumCombatantID]
end

function TCombatant:IsClose()
	return TCombatant.IsNear(self) and TCombatant.GetRange(self) <= Settings.CloseDist
end

function TCombatant:IsNear()
	return GetPackedBoolean(m_isNearMask, self[enumCombatantPacked])
end

function TCombatant:SetIsNear(aValue)
	self[enumCombatantPacked] = PackValue(m_isNearMask, BoolToNumber(aValue), self[enumCombatantPacked])
end

function TCombatant:IsAbsent()
	return GetPackedBoolean(m_isAbsentMask, self[enumCombatantPacked])
end

function TCombatant:SetAbsent(aValue)
	self[enumCombatantPacked] = PackValue(m_isAbsentMask, BoolToNumber(aValue), self[enumCombatantPacked])
end

function TCombatant:GetWasLethal(aMode)
	local needMode = aMode
	if aMode ~= enumMode.Dps then
		needMode = enumMode.Def
	end
	local combatantData = self[enumCombatantData][needMode]
	
	for _, spellData in ipairs(combatantData or {}) do
		if IsSpellDataLethal(spellData) then
			return true
		end
	end
	return false
end

function TCombatant:GetClassColor()
	return GetPackedValue(m_classColorIndexMask, self[enumCombatantPacked])
end

function TCombatant:SetClassColor(aValue)
	self[enumCombatantPacked] = PackValue(m_classColorIndexMask, aValue, self[enumCombatantPacked])
end

function TCombatant:GetRange()
	return GetPackedValue(m_rangeMask, self[enumCombatantPacked])
end

function TCombatant:SetRange(aValue)
	aValue = math.min(aValue, 255) --2^8
	aValue = math.max(aValue, 0)
	self[enumCombatantPacked] = PackValue(m_rangeMask, aValue, self[enumCombatantPacked])
end