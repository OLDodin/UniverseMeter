local cachedGetLocalDateTimeMs = common.GetLocalDateTimeMs

local enumCount = enumSpellInfo.Count
local enumAmount = enumSpellInfo.Amount
local enumInfoID = enumSpellInfo.InfoID
local enumName = enumSpellInfo.Name
local enumPackedValue = enumSpellInfo.PackedValue
local enumHits = enumSpellInfo.Hits
local enumPetName = enumSpellInfo.PetName


local m_elementMask = { mask = 15, shift = 0 } --0b 1111
local m_lethalMask = { mask = 16, shift = 4 } --0b 0001 0000 b
local m_fromBarrierMask = { mask = 32, shift = 5 } --0b 0010 0000 b

local m_enumHitMult = 20 
local m_enumMissMult = m_enumHitMult + DMGTYPES
local m_enumHitBlockMult = m_enumMissMult + MISSTYPES
local m_enumHealResist = m_enumHitBlockMult
local m_customBuffMult = m_enumHitBlockMult + BLOCKDMGTYPES


local function CreateAndRecalcDetails(aList, anIndex, anAmount)
	if not aList[anIndex] then
		aList[anIndex] = TValueDetails:CreateNewObject()
	end
	TValueDetails.RecalcDetails(aList[anIndex], anAmount)
end

local function CreateBoolAndRecalcDetails(aList, anIndex, anAmount, aFlag)
	if not aFlag then
		return
	end
	CreateAndRecalcDetails(aList, anIndex, anAmount)
end

local function CreateNonZeroAndRecalcDetails(aList, anIndex, anAmount)
	if not anAmount or anAmount == 0 then
		return
	end
	CreateAndRecalcDetails(aList, anIndex, anAmount)
end

local function CreateAndMergeDetails(aListTo, aListFrom, anIndex)
	if not aListFrom or not aListFrom[anIndex] then
		return
	end
	if not aListTo[anIndex] then
		aListTo[anIndex] = TValueDetails:CreateNewObject()
	end
	
	TValueDetails.MergeDetails(aListTo[anIndex], aListFrom[anIndex])
end

local function GetFunctionOwnerForSpellData(aSpellData)
	if aSpellData[enumHits] ~= nil then
		return TDamageSpellData
	else
		return THealSpellData
	end
end

function GetBuffPercentByIndex(aSpellData, aBuffInd)
	local buffDetail = aSpellData[aBuffInd+m_customBuffMult]
	if not buffDetail then
		return 0
	end
	return GetAllDetailPercentage(aSpellData, buffDetail)
end

function IsSpellDataLethal(aSpellData)
	return GetPackedBoolean(m_lethalMask, aSpellData[enumPackedValue])
end

function IsSpellDataFromBarrier(aSpellData)
	return GetPackedBoolean(m_fromBarrierMask, aSpellData[enumPackedValue])
end

function GetSpellDataElement(aSpellData)
	if aSpellData[enumHits] ~= nil then
		return GetPackedValue(m_elementMask, aSpellData[enumPackedValue])
	else
		return enumDmgTypes.Holy
	end
end

function InitSpellDataByInfo(aSpellData, aSpellInfo)
	aSpellData[enumName] = aSpellInfo.name
	aSpellData[enumInfoID] = aSpellInfo.infoID
	
	local packed = 0
	
	if aSpellInfo.lethal then
		packed = PackValue(m_lethalMask, 1, packed)
	end
	packed = PackValue(m_fromBarrierMask, BoolToNumber(aSpellInfo.fromBarrier), packed)
	-- only dd event
	if aSpellData[enumHits] ~= nil then
		packed = PackValue(m_elementMask, aSpellInfo.sysSubElement, packed)
	end
	aSpellData[enumPackedValue] = GetStoreValue(packed)
	
	aSpellData[enumPetName] = aSpellInfo.petName
end

function FillSpellDataFromParams(aSpellData, aParams)
	return GetFunctionOwnerForSpellData(aSpellData).ReceiveValuesFromParams(aSpellData, aParams)
end

function AddValuesFromSpellData(aSpellDataTo, aSpellDataFrom, aLastHitTime)
	return GetFunctionOwnerForSpellData(aSpellDataTo).AddValuesFromSpellData(aSpellDataTo, aSpellDataFrom, aLastHitTime)
end

function GetAverageCntPerSecond(aSpellData)
	if aSpellData.LastHitTime == nil or aSpellData.FirstHitTime == nil then 
		return aSpellData[enumCount]
	end
	if aSpellData.LastHitTime - aSpellData.FirstHitTime == 0 then 
		return aSpellData[enumCount]
	end
	return aSpellData[enumCount] / (aSpellData.LastHitTime - aSpellData.FirstHitTime)
end

function GetResistAmount(aSpellData)
	return GetFunctionOwnerForSpellData(aSpellData).GetResistAmount(aSpellData)
end


function CalculateSpellDetailsPercentage(aSpellData, aFightTime, aCombatantAmount)
	local spellResistAmount = GetResistAmount(aSpellData)
	aSpellData.AmountPerSec = aSpellData[enumAmount] / aFightTime
	aSpellData.Percentage = GetPercentageAt(aSpellData[enumAmount], aCombatantAmount)
	aSpellData.ResistPercentage = GetPercentageAt(spellResistAmount, aSpellData[enumAmount] + spellResistAmount)
end

function GetDamageDetailPercentage(aSpellData, aSpellDetails)
	if aSpellData[enumHits] ~= nil then
		return TDamageSpellData.GetDamageDetailPercentage(aSpellData, aSpellDetails)
	else
		return THealSpellData.GetAllDetailPercentage(aSpellData, aSpellDetails)
	end 
end

function GetAllDetailPercentage(aSpellData, aSpellDetails)
	return GetFunctionOwnerForSpellData(aSpellData).GetAllDetailPercentage(aSpellData, aSpellDetails)
end

function GetResistDetailPercentage(aSpellData, aSpellDetails)
	return GetFunctionOwnerForSpellData(aSpellData).GetResistDetailPercentage(aSpellData, aSpellDetails)
end

local function MakeList(aList, anEnum, aMult)
	return table.move(aList, aMult+1, aMult+table.nkeys(anEnum), 1, {})
end

function CustomBuffList(aSpellData)
	local res = {}
	for i, _ in ipairs(CurrentBuffsState) do
		res[i] = aSpellData[i+m_customBuffMult]
	end
	return res
end

function MissList(aSpellData)
	return MakeList(aSpellData, enumMiss, m_enumMissMult)
end

function DetailsList(aSpellData)
	return MakeList(aSpellData, enumHit, m_enumHitMult)
end

function ResistDetailsList(aSpellData)
	if aSpellData[enumHits] ~= nil then
		return MakeList(aSpellData, enumHitBlock, m_enumHitBlockMult)
	else
		return MakeList(aSpellData, enumHealResist, m_enumHealResist)
	end
end

-- при смерти игрока событие об уроне получим уже после спадания баффов из-за смерти
-- то при летальном уроне учитываем баффы, спавшие после смерти плюс WaitBuffAfterDeathTime на запаздывания событий об уроне
local function AdditionalBuffCheckLethal(aParams, anObjID, aStatesArr, aCurrTime)
	local buffState = aStatesArr[anObjID]
	if buffState then
		if buffState.removeAfterDeath then
			if aCurrTime - buffState.removeTime <= Settings.WaitBuffAfterDeathTime  then
				return buffState.info
			end
		elseif buffState.removeTime == 0 then
			return buffState.info
		end
	end
	return nil
end



--------------------------------------------------------------------------------
-- Type TDamageSpellData
Global("TDamageSpellData", {})
--------------------------------------------------------------------------------
function TDamageSpellData:CreateNewObject()
	return {
			[enumCount] = 0,
			[enumAmount] = 0,
			[enumHits] = 0
		}
end
--------------------------------------------------------------------------------
-- Update the data by adding a new value
--------------------------------------------------------------------------------
function TDamageSpellData:ReceiveValuesFromParams(aParams)
	self[enumCount] = self[enumCount] + 1
	self[enumAmount] = self[enumAmount] + aParams.amount
	
	if aParams.lethal then
		self[enumPackedValue] = PackValue(m_lethalMask, 1, self[enumPackedValue] or 0)
	end
	
	CreateBoolAndRecalcDetails(self, enumMiss.Miss+m_enumMissMult, aParams.amount, aParams.isMiss)
	CreateBoolAndRecalcDetails(self, enumMiss.Dodge+m_enumMissMult, aParams.amount, aParams.isDodge)

	if not aParams.isMiss and not aParams.isDodge then
		self[enumHits] = self[enumHits] + 1

		CreateBoolAndRecalcDetails(self, enumHit.Critical+m_enumHitMult, aParams.amount, aParams.isCritical)
		CreateBoolAndRecalcDetails(self, enumHit.Glancing+m_enumHitMult, aParams.amount, aParams.isGlancing)
		if not aParams.isCritical and not aParams.isGlancing then 
			CreateAndRecalcDetails(self, enumHit.Normal+m_enumHitMult, aParams.amount) 
		end
	end
	
	CreateNonZeroAndRecalcDetails(self, enumHitBlock.Block+m_enumHitBlockMult, aParams.shieldBlock)
	CreateNonZeroAndRecalcDetails(self, enumHitBlock.Parry+m_enumHitBlockMult, aParams.parry)
	CreateNonZeroAndRecalcDetails(self, enumHitBlock.Barrier+m_enumHitBlockMult, aParams.barrier)
	CreateNonZeroAndRecalcDetails(self, enumHitBlock.Resist+m_enumHitBlockMult, aParams.resist)
	CreateNonZeroAndRecalcDetails(self, enumHitBlock.Absorb+m_enumHitBlockMult, aParams.absorb)
	CreateNonZeroAndRecalcDetails(self, enumHitBlock.RunesAbsorb+m_enumHitBlockMult, aParams.runesAbsorb)
	CreateNonZeroAndRecalcDetails(self, enumHitBlock.Mount+m_enumHitBlockMult, aParams.toMount)
	CreateNonZeroAndRecalcDetails(self, enumHitBlock.MultAbsorb+m_enumHitBlockMult, aParams.multipliersAbsorb)
	
	local currTime = cachedGetLocalDateTimeMs()
	local srcBuff
	local targetBuff
	for i, value in ipairs(CurrentBuffsState) do
		--для баффов, указываемых в событии об уроне, это серверное указание в приоритете
		if i == CustomBuffIndex.Valor then
			if aParams.valor or AdditionalBuffCheckLethal(aParams, aParams.sourceID, value, currTime) then
				CreateAndRecalcDetails(self, CustomBuffIndex.Valor+m_customBuffMult, aParams.amount)
			end
		elseif i == CustomBuffIndex.Vulnerability then
			if aParams.vulnerability or AdditionalBuffCheckLethal(aParams, aParams.targetID, value, currTime) then
				CreateAndRecalcDetails(self, CustomBuffIndex.Vulnerability+m_customBuffMult, aParams.amount)
			end
		elseif i == CustomBuffIndex.Defense then
			if aParams.defense or AdditionalBuffCheckLethal(aParams, aParams.targetID, value, currTime) then
				CreateAndRecalcDetails(self, CustomBuffIndex.Defense+m_customBuffMult, aParams.amount)
			end
		elseif i == CustomBuffIndex.Weakness then
			if aParams.weakness or AdditionalBuffCheckLethal(aParams, aParams.sourceID, value, currTime) then
				CreateAndRecalcDetails(self, CustomBuffIndex.Weakness+m_customBuffMult, aParams.amount)
			end
		else
			srcBuff = AdditionalBuffCheckLethal(aParams, aParams.sourceID, value, currTime)
			targetBuff = AdditionalBuffCheckLethal(aParams, aParams.targetID, value, currTime)
			
			if srcBuff and srcBuff.forDps and srcBuff.forSrc then
				CreateAndRecalcDetails(self, srcBuff.ind+m_customBuffMult, aParams.amount)
			end
			
			if targetBuff and targetBuff.forDps and targetBuff.forTarget then
				CreateAndRecalcDetails(self, targetBuff.ind+m_customBuffMult, aParams.amount)
			end
		end
	end
end

function TDamageSpellData:AddValuesFromSpellData(aSpellData, aLastHitTime)
	self[enumCount] = self[enumCount] + aSpellData[enumCount]
	self[enumAmount] = self[enumAmount] + aSpellData[enumAmount]
	self[enumHits] = self[enumHits] + aSpellData[enumHits]
	
	local packed = self[enumPackedValue] or 0
	if IsSpellDataLethal(self) or IsSpellDataLethal(aSpellData) then
		packed = PackValue(m_lethalMask, 1, packed)
	end
	self[enumPackedValue] = GetStoreValue(packed)


	CreateAndMergeDetails(self, aSpellData, enumMiss.Miss+m_enumMissMult)
	CreateAndMergeDetails(self, aSpellData, enumMiss.Dodge+m_enumMissMult)
	
	CreateAndMergeDetails(self, aSpellData, enumHit.Critical+m_enumHitMult)
	CreateAndMergeDetails(self, aSpellData, enumHit.Glancing+m_enumHitMult)
	CreateAndMergeDetails(self, aSpellData, enumHit.Normal+m_enumHitMult)
	
	CreateAndMergeDetails(self, aSpellData, enumHitBlock.Block+m_enumHitBlockMult)
	CreateAndMergeDetails(self, aSpellData, enumHitBlock.Parry+m_enumHitBlockMult)
	CreateAndMergeDetails(self, aSpellData, enumHitBlock.Barrier+m_enumHitBlockMult)
	CreateAndMergeDetails(self, aSpellData, enumHitBlock.Resist+m_enumHitBlockMult)
	CreateAndMergeDetails(self, aSpellData, enumHitBlock.Absorb+m_enumHitBlockMult)
	CreateAndMergeDetails(self, aSpellData, enumHitBlock.RunesAbsorb+m_enumHitBlockMult)
	CreateAndMergeDetails(self, aSpellData, enumHitBlock.Mount+m_enumHitBlockMult)
	CreateAndMergeDetails(self, aSpellData, enumHitBlock.MultAbsorb+m_enumHitBlockMult)
	
	for i, _ in ipairs(CurrentBuffsState) do
		CreateAndMergeDetails(self, aSpellData, i+m_customBuffMult)
	end

	self.LastHitTime = aLastHitTime
	
end

function TDamageSpellData:GetResistAmount()
	local res = 0
	for _, blockDmgDetail in pairs( ResistDetailsList(self) ) do
		if TValueDetails.GetAmount(blockDmgDetail) > 0 then
			res = res + TValueDetails.GetAmount(blockDmgDetail)
		end 
	end
	return res
end

function TDamageSpellData:GetDamageDetailPercentage(aSpellDetails)
	return GetPercentageAt(TValueDetails.GetCount(aSpellDetails), self[enumHits])
end

function TDamageSpellData:GetAllDetailPercentage(aSpellDetails)
	return GetPercentageAt(TValueDetails.GetCount(aSpellDetails), self[enumCount])
end

function TDamageSpellData:GetResistDetailPercentage(aSpellDetails)
	local allDamage = self[enumAmount] + TDamageSpellData.GetResistAmount(self)
	return GetPercentageAt(TValueDetails.GetAmount(aSpellDetails), allDamage)
end

--------------------------------------------------------------------------------
-- Type THealSpellData
Global("THealSpellData", {})
--------------------------------------------------------------------------------
function THealSpellData:CreateNewObject()
	return {
			[enumCount] = 0,
			[enumAmount] = 0
		}
end
--------------------------------------------------------------------------------
-- Update the data by adding a new value
--------------------------------------------------------------------------------
function THealSpellData:ReceiveValuesFromParams(aParams)
	self[enumCount] = self[enumCount] + 1
	self[enumAmount] = self[enumAmount] + aParams.amount

	CreateBoolAndRecalcDetails(self, enumHit.Critical+m_enumHitMult, aParams.amount, aParams.isCritical)
	CreateBoolAndRecalcDetails(self, enumHit.Glancing+m_enumHitMult, aParams.amount, aParams.isGlancing)

	if not aParams.isCritical and not aParams.isGlancing then 
		CreateAndRecalcDetails(self, enumHit.Normal+m_enumHitMult, aParams.amount) 
	end

	CreateNonZeroAndRecalcDetails(self, enumHealResist.Resisted+m_enumHealResist, aParams.resisted)
	CreateNonZeroAndRecalcDetails(self, enumHealResist.RuneResisted+m_enumHealResist, aParams.runeResisted)
	CreateNonZeroAndRecalcDetails(self, enumHealResist.Absorbed+m_enumHealResist, aParams.absorbed)
	CreateNonZeroAndRecalcDetails(self, enumHealResist.Overload+m_enumHealResist, aParams.overload)
	
	local currTime = cachedGetLocalDateTimeMs()
	local srcBuff
	local targetBuff
	for i, value in ipairs(CurrentBuffsState) do
		srcBuff = AdditionalBuffCheckLethal(aParams, aParams.sourceID, value, currTime)
		targetBuff = AdditionalBuffCheckLethal(aParams, aParams.targetID, value, currTime)
		if srcBuff and srcBuff.forHps and srcBuff.forSrc then
			CreateAndRecalcDetails(self, srcBuff.ind+m_customBuffMult, aParams.amount)
		end
		if targetBuff and targetBuff.forHps and targetBuff.forTarget then
			CreateAndRecalcDetails(self, targetBuff.ind+m_customBuffMult, aParams.amount)
		end
	end
end

function THealSpellData:AddValuesFromSpellData(aSpellData, aLastHitTime)
	self[enumCount] = self[enumCount] + aSpellData[enumCount]
	self[enumAmount] = self[enumAmount] + aSpellData[enumAmount]

	CreateAndMergeDetails(self, aSpellData, enumHit.Critical+m_enumHitMult)
	CreateAndMergeDetails(self, aSpellData, enumHit.Glancing+m_enumHitMult)
	CreateAndMergeDetails(self, aSpellData, enumHit.Normal+m_enumHitMult)
	
	CreateAndMergeDetails(self, aSpellData, enumHealResist.Resisted+m_enumHealResist)
	CreateAndMergeDetails(self, aSpellData, enumHealResist.RuneResisted+m_enumHealResist)
	CreateAndMergeDetails(self, aSpellData, enumHealResist.Absorbed+m_enumHealResist)
	CreateAndMergeDetails(self, aSpellData, enumHealResist.Overload+m_enumHealResist)
	
	for i, _ in ipairs(CurrentBuffsState) do
		CreateAndMergeDetails(self, aSpellData, i+m_customBuffMult)
	end

	self.LastHitTime = aLastHitTime
end

function THealSpellData:GetResistAmount()
	local res = 0
	for _, resistHealDetail in pairs( ResistDetailsList(self) ) do
		res = res + TValueDetails.GetAmount(resistHealDetail)
	end
	return res
end

function THealSpellData:GetAllDetailPercentage(aSpellDetails)
	return GetPercentageAt(TValueDetails.GetCount(aSpellDetails), self[enumCount])
end

function THealSpellData:GetResistDetailPercentage(aSpellDetails)
	local allHeal = self[enumAmount] + THealSpellData.GetResistAmount(self)
	return GetPercentageAt(TValueDetails.GetAmount(aSpellDetails), allHeal)
end