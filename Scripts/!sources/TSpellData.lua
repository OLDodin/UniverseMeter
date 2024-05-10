-- Type TValueDetails
Global("TValueDetails", {})
--------------------------------------------------------------------------------
function TValueDetails:CreateNewObject()
	return 
	{
		Count = 0,			-- Count how many input
		Amount = 0,			-- Total amount cumulated
		Min = -1,			-- Minimum input
		Max = -1			-- Maximum input
	}
end
--------------------------------------------------------------------------------
-- Recalc min, max, avg by adding a new value
--------------------------------------------------------------------------------
function TValueDetails:RecalcDetails(aValue)
	-- Increment the counter
	self.Count = self.Count + 1
	-- Increase the total damage amount
	self.Amount = self.Amount + aValue
	-- Update the min
	if (aValue < self.Min) or (self.Min == -1) then self.Min = aValue; end
	-- Update the max
	if (aValue > self.Max) or (self.Max == -1) then self.Max = aValue; end
end

function TValueDetails:MergeDetails(aSpellDataDetails)
	if aSpellDataDetails.Count == 0 then
		return
	end
	-- Increment the counter
	self.Count = self.Count + aSpellDataDetails.Count
	-- Increase the total damage amount
	self.Amount = self.Amount + aSpellDataDetails.Amount
	-- Update the min
	if (aSpellDataDetails.Min < self.Min) or (self.Min == -1) then self.Min = aSpellDataDetails.Min; end
	-- Update the max
	if (aSpellDataDetails.Max > self.Max) or (self.Max == -1) then self.Max = aSpellDataDetails.Max; end
end

function TValueDetails:GetAvg()
	if self.Count == 0 then
		return -1
	end
	return math.ceil(self.Amount / self.Count)
end


local m_enumMissMult = 1
local m_enumHitMult = 10
local m_enumHealResist = 100
local m_enumHitBlockMult = 100
local m_enumBuffMult = 1000
local m_customBuffMult = 10000


local function CreateAndRecalcDetails(anObj, aList, anIndex, anAmount)
	if not aList[anIndex] then
		aList[anIndex] = TValueDetails.CreateNewObject()
	end
	TValueDetails.RecalcDetails(aList[anIndex], anAmount)
end

local function CreateAndMergeDetails(anObj, aListTo, aListFrom, anIndex)
	if not aListFrom or not aListFrom[anIndex] then
		return
	end
	if not aListTo[anIndex] then
		aListTo[anIndex] = TValueDetails:CreateNewObject()
	end
	
	TValueDetails.MergeDetails(aListTo[anIndex], aListFrom[anIndex])
end

local function GetFunctionOwnerForSpellData(aSpellData)
	if aSpellData.Hits ~= nil then
		return TDamageSpellData
	else
		return THealSpellData
	end
end

function FillSpellDataFromParams(aSpellData, aParams)
	return GetFunctionOwnerForSpellData(aSpellData).ReceiveValuesFromParams(aSpellData, aParams)
end

function AddValuesFromSpellData(aSpellDataTo, aSpellDataFrom, aLastHitTime)
	return GetFunctionOwnerForSpellData(aSpellDataTo).AddValuesFromSpellData(aSpellDataTo, aSpellDataFrom, aLastHitTime)
end

function GetAverageCntPerSecond(aSpellData)
	if aSpellData.LastHitTime == nil or aSpellData.FirstHitTime == nil then 
		return aSpellData.Count
	end
	if aSpellData.LastHitTime - aSpellData.FirstHitTime == 0 then 
		return aSpellData.Count
	end
	return aSpellData.Count / (aSpellData.LastHitTime - aSpellData.FirstHitTime)
end

function GetResistAmount(aSpellData)
	return GetFunctionOwnerForSpellData(aSpellData).GetResistAmount(aSpellData)
end


function CalculateSpellDetailsPercentage(aSpellData)
	return GetFunctionOwnerForSpellData(aSpellData).CalculateSpellDetailsPercentage(aSpellData)
end

local function MakeList(aList, anEnum, aMult)
	local res = {}
	for _, i in pairs(anEnum) do
		res[i] = aList[i*aMult]
	end
	return res
end

function CustomBuffList(aSpellData)
	local res = {}
	for i, _ in ipairs(CurrentBuffsState) do
		res[i] = aSpellData[i*m_customBuffMult]
	end
	return res
end

function BuffList(aSpellData)
	return MakeList(aSpellData, enumBuff, m_enumBuffMult)
end

function MissList(aSpellData)
	return MakeList(aSpellData, enumMiss, m_enumMissMult)
end

function DetailsList(aSpellData)
	return MakeList(aSpellData, enumHit, m_enumHitMult)
end

function ResistDetailsList(aSpellData)
	if aSpellData.Hits ~= nil then
		return MakeList(aSpellData, enumHitBlock, m_enumHitBlockMult)
	else
		return MakeList(aSpellData, enumHealResist, m_enumHealResist)
	end
end

function IsPetData(aSpellData)
	return aSpellData.PetName ~= nil
end
	



--------------------------------------------------------------------------------
-- Type TDamageSpellData
Global("TDamageSpellData", {})
--------------------------------------------------------------------------------
function TDamageSpellData:CreateNewObject()
	return {
			Count = 0,					-- Count how many spell input
			Hits = 0,					-- Count how many efficient spell input
			Amount = 0					-- Total damage amount
		}
end
--------------------------------------------------------------------------------
-- Update the data by adding a new value
--------------------------------------------------------------------------------
function TDamageSpellData:ReceiveValuesFromParams(aParams)
	self.Count = self.Count + 1;
	self.Amount = self.Amount + aParams.amount;


	if aParams.isMiss then CreateAndRecalcDetails(self, self, enumMiss.Miss*m_enumMissMult, aParams.amount) end

	if aParams.isDodge then CreateAndRecalcDetails(self, self, enumMiss.Dodge*m_enumMissMult, aParams.amount) end

	if not aParams.isMiss and not aParams.isDodge then
		self.Hits = self.Hits + 1;

		if aParams.isCritical then CreateAndRecalcDetails(self, self, enumHit.Critical*m_enumHitMult, aParams.amount) end

		if aParams.isGlancing then CreateAndRecalcDetails(self, self, enumHit.Glancing*m_enumHitMult, aParams.amount) end

		if not aParams.isCritical and not aParams.isGlancing then CreateAndRecalcDetails(self, self, enumHit.Normal*m_enumHitMult, aParams.amount) end
	end
	
	
	if aParams.shieldBlock > 0 then CreateAndRecalcDetails(self, self, enumHitBlock.Block*m_enumHitBlockMult, aParams.shieldBlock) end

	if aParams.parry > 0 then CreateAndRecalcDetails(self, self, enumHitBlock.Parry*m_enumHitBlockMult, aParams.parry) end

	if aParams.barrier > 0 then CreateAndRecalcDetails(self, self, enumHitBlock.Barrier*m_enumHitBlockMult, aParams.barrier) end

	if aParams.resist > 0 then CreateAndRecalcDetails(self, self, enumHitBlock.Resist*m_enumHitBlockMult, aParams.resist) end

	if aParams.absorb > 0 then CreateAndRecalcDetails(self, self, enumHitBlock.Absorb*m_enumHitBlockMult, aParams.absorb) end

	if aParams.runesAbsorb and aParams.runesAbsorb > 0 then CreateAndRecalcDetails(self, self, enumHitBlock.RunesAbsorb*m_enumHitBlockMult, aParams.runesAbsorb) end

	if aParams.toMount > 0 then CreateAndRecalcDetails(self, self, enumHitBlock.Mount*m_enumHitBlockMult, aParams.toMount) end

	if aParams.multipliersAbsorb ~= 0 then CreateAndRecalcDetails(self, self, enumHitBlock.MultAbsorb*m_enumHitBlockMult, aParams.multipliersAbsorb) end
	
	if aParams.Vulnerability then 
		CreateAndRecalcDetails(self, self, enumBuff.Vulnerability*m_enumBuffMult, aParams.amount)
	end
	if aParams.Weakness then 
		CreateAndRecalcDetails(self, self, enumBuff.Weakness*m_enumBuffMult, aParams.amount)
	end
	if aParams.Defense then 
		CreateAndRecalcDetails(self, self, enumBuff.Defense*m_enumBuffMult, aParams.amount)
	end
	if aParams.Valor then 
		CreateAndRecalcDetails(self, self, enumBuff.Valor*m_enumBuffMult, aParams.amount)
	end
	
	for i, value in ipairs(CurrentBuffsState) do
		local srcBuff = value[aParams.sourceID]
		local targetBuff = value[aParams.targetID]
		if srcBuff and srcBuff.forDps and srcBuff.forSrc then
			CreateAndRecalcDetails(self, self, srcBuff.ind*m_customBuffMult, aParams.amount)
		end
		if targetBuff and targetBuff.forDps and targetBuff.forTarget then
			CreateAndRecalcDetails(self, self, targetBuff.ind*m_customBuffMult, aParams.amount)
		end
	end
end

function TDamageSpellData:AddValuesFromSpellData(aSpellData, aLastHitTime)
	self.Count = self.Count + aSpellData.Count;
	self.Amount = self.Amount + aSpellData.Amount;
	self.Hits = self.Hits + aSpellData.Hits;

	CreateAndMergeDetails(self, self, aSpellData, enumMiss.Miss*m_enumMissMult)
	CreateAndMergeDetails(self, self, aSpellData, enumMiss.Dodge*m_enumMissMult)
	
	CreateAndMergeDetails(self, self, aSpellData, enumBuff.Vulnerability*m_enumBuffMult)
	CreateAndMergeDetails(self, self, aSpellData, enumBuff.Weakness*m_enumBuffMult)
	CreateAndMergeDetails(self, self, aSpellData, enumBuff.Defense*m_enumBuffMult)
	CreateAndMergeDetails(self, self, aSpellData, enumBuff.Valor*m_enumBuffMult)

	CreateAndMergeDetails(self, self, aSpellData, enumHit.Critical*m_enumHitMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHit.Glancing*m_enumHitMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHit.Normal*m_enumHitMult)
	
	CreateAndMergeDetails(self, self, aSpellData, enumHitBlock.Block*m_enumHitBlockMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHitBlock.Parry*m_enumHitBlockMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHitBlock.Barrier*m_enumHitBlockMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHitBlock.Resist*m_enumHitBlockMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHitBlock.Absorb*m_enumHitBlockMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHitBlock.RunesAbsorb*m_enumHitBlockMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHitBlock.Mount*m_enumHitBlockMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHitBlock.MultAbsorb*m_enumHitBlockMult)
	
	for i, _ in ipairs(CurrentBuffsState) do
		CreateAndMergeDetails(self, self, aSpellData, i*m_customBuffMult)
	end

	self.LastHitTime = aLastHitTime
	
end

--------------------------------------------------------------------------------
-- Get the total blocked damage acount
--------------------------------------------------------------------------------
function TDamageSpellData:GetResistAmount()
	local res = 0
	for _, blockDmgDetail in pairs( ResistDetailsList(self) ) do
		if blockDmgDetail.Amount > 0 then
			res = res + blockDmgDetail.Amount
		end 
	end
	return res
end
--------------------------------------------------------------------------------
-- Recalculate the pourcentage for each type of damage
--------------------------------------------------------------------------------
function TDamageSpellData:CalculateSpellDetailsPercentage()
	for _, damageDetail in pairs( DetailsList(self) ) do
		damageDetail.Percentage = GetPercentageAt(damageDetail.Count, self.Hits)
	end

	for _, missDetail in pairs( MissList(self) ) do
		missDetail.Percentage = GetPercentageAt(missDetail.Count, self.Count)
	end


	for _, buffDetail in pairs( BuffList(self) ) do
		buffDetail.Percentage = GetPercentageAt(buffDetail.Count, self.Count)
	end


	for _, buffDetail in pairs( CustomBuffList(self) ) do
		buffDetail.Percentage = GetPercentageAt(buffDetail.Count, self.Count)
	end


	local allDamage = self.Amount + TDamageSpellData.GetResistAmount(self)
	for _, blockDmgDetail in pairs( ResistDetailsList(self) ) do
		blockDmgDetail.Percentage = GetPercentageAt(blockDmgDetail.Amount, allDamage)
	end
end
--------------------------------------------------------------------------------
-- Type THealSpellData
Global("THealSpellData", {})
--------------------------------------------------------------------------------
function THealSpellData:CreateNewObject()
	return {
			Count = 0,					-- Count how many spell inpu			
			Amount = 0					-- Total heal amount
		}
end
--------------------------------------------------------------------------------
-- Update the data by adding a new value
--------------------------------------------------------------------------------
function THealSpellData:ReceiveValuesFromParams(aParams)
	self.Count = self.Count + 1;
	self.Amount = self.Amount + aParams.heal;


	if aParams.isCritical then CreateAndRecalcDetails(self, self, enumHit.Critical*m_enumHitMult, aParams.heal) end

	if aParams.isGlancing then CreateAndRecalcDetails(self, self, enumHit.Glancing*m_enumHitMult, aParams.heal) end

	if not aParams.isCritical and not aParams.isGlancing then CreateAndRecalcDetails(self, self, enumHit.Normal*m_enumHitMult, aParams.heal) end


	if aParams.resisted > 0 then CreateAndRecalcDetails(self, self, enumHealResist.Resisted*m_enumHealResist, aParams.resisted) end

	if aParams.runeResisted and aParams.runeResisted > 0 then CreateAndRecalcDetails(self, self, enumHealResist.RuneResisted*m_enumHealResist, aParams.runeResisted) end

	if aParams.absorbed > 0 then CreateAndRecalcDetails(self, self, enumHealResist.Absorbed*m_enumHealResist, aParams.absorbed) end

	if aParams.overload and aParams.overload > 0 then CreateAndRecalcDetails(self, self, enumHealResist.Overload*m_enumHealResist, aParams.overload) end
	
	-- The amount of the wounds
	--if aParams.lethality > 0 then CreateAndRecalcDetails(self.GlobalInfoList, enumGlobalInfo.Lethality, aParams.lethality) end
	
	for i, value in ipairs(CurrentBuffsState) do
		local srcBuff = value[aParams.sourceID]
		local targetBuff = value[aParams.targetID]
		if srcBuff and srcBuff.forHps and srcBuff.forSrc then
			CreateAndRecalcDetails(self, self, srcBuff.ind*m_customBuffMult, aParams.heal)
		end
		if targetBuff and targetBuff.forHps and targetBuff.forTarget then
			CreateAndRecalcDetails(self, self, targetBuff.ind*m_customBuffMult, aParams.heal)
		end
	end
end

function THealSpellData:AddValuesFromSpellData(aSpellData, aLastHitTime)
	self.Count = self.Count + aSpellData.Count;
	self.Amount = self.Amount + aSpellData.Amount;

	CreateAndMergeDetails(self, self, aSpellData, enumHit.Critical*m_enumHitMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHit.Glancing*m_enumHitMult)
	CreateAndMergeDetails(self, self, aSpellData, enumHit.Normal*m_enumHitMult)
	
	CreateAndMergeDetails(self, self, aSpellData, enumHealResist.Resisted*m_enumHealResist)
	CreateAndMergeDetails(self, self, aSpellData, enumHealResist.RuneResisted*m_enumHealResist)
	CreateAndMergeDetails(self, self, aSpellData, enumHealResist.Absorbed*m_enumHealResist)
	CreateAndMergeDetails(self, self, aSpellData, enumHealResist.Overload*m_enumHealResist)
	
	for i, value in ipairs(CurrentBuffsState) do
		CreateAndMergeDetails(self, self, aSpellData, i*m_customBuffMult)
	end

	self.LastHitTime = aLastHitTime
end

--------------------------------------------------------------------------------
-- Get the total resisted heal acount
--------------------------------------------------------------------------------
function THealSpellData:GetResistAmount()
	local res = 0
	for _, resistHealDetail in pairs( ResistDetailsList(self) ) do
		res = res + resistHealDetail.Amount
	end
	return res
end
--------------------------------------------------------------------------------
-- Recalculate the pourcentage for each type of heal
--------------------------------------------------------------------------------
function THealSpellData:CalculateSpellDetailsPercentage()
	for _, healDetail in pairs( DetailsList(self) ) do
		healDetail.Percentage = GetPercentageAt(healDetail.Count, self.Count)
	end

	local allHeal = self.Amount + THealSpellData.GetResistAmount(self)
	for _, resistHealDetail in pairs( ResistDetailsList(self) ) do
		resistHealDetail.Percentage = GetPercentageAt(resistHealDetail.Amount, allHeal)
	end

	for _, buffDetail in pairs( CustomBuffList(self) ) do
		buffDetail.Percentage = GetPercentageAt(buffDetail.Count, self.Count)
	end
end