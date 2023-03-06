-- Type TValueDetails
Global("TValueDetails", {})
--------------------------------------------------------------------------------
function TValueDetails:CreateNewObject()
	return setmetatable({
			Count = 0,			-- Count how many input
			Amount = 0,			-- Total amount cumulated
			Min = -1,			-- Minimum input
			Max = -1,			-- Maximum input
		}, { __index = self })
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
--------------------------------------------------------------------------------
-- Reset
--------------------------------------------------------------------------------
function TValueDetails:Reset()
	self.Count = 0
	self.Percentage = nil
	self.Amount = 0
	self.Min = -1
	self.Max = -1
end

local function CreateAndRecalcDetails(anObj, aListFunc, anIndex, anAmount)
	local list = aListFunc(anObj)
	if not list[anIndex] then
		list[anIndex] = TValueDetails:CreateNewObject()
	end
	list[anIndex]:RecalcDetails(anAmount)
end

local function CreateAndMergeDetails(anObj, aListToFunc, aListFrom, anIndex)
	if not aListFrom or not aListFrom[anIndex] then
		return
	end
	local listTo = aListToFunc(anObj)
	if not listTo[anIndex] then
		listTo[anIndex] = TValueDetails:CreateNewObject()
	end
	
	listTo[anIndex]:MergeDetails(aListFrom[anIndex])
end
--------------------------------------------------------------------------------
-- Type TDamageSpellData
Global("TDamageSpellData", {})
--------------------------------------------------------------------------------
function TDamageSpellData:CreateNewObject()
	return setmetatable({
			Count = 0,					-- Count how many spell input
			Hits = 0,					-- Count how many efficient spell input
			Amount = 0,					-- Total damage amount
		}, { __index = self })
end
--------------------------------------------------------------------------------
-- Update the data by adding a new value
--------------------------------------------------------------------------------
function TDamageSpellData:ReceiveValuesFromParams(aParams)
	self.Count = self.Count + 1;
	self.Amount = self.Amount + aParams.amount;


	if aParams.isMiss then CreateAndRecalcDetails(self, self.GetMissList, enumMiss.Miss, aParams.amount) end

	if aParams.isDodge then CreateAndRecalcDetails(self, self.GetMissList, enumMiss.Dodge, aParams.amount) end

	if not aParams.isMiss and not aParams.isDodge then
		self.Hits = self.Hits + 1;

		if aParams.isCritical then CreateAndRecalcDetails(self, self.GetDetailsList, enumHit.Critical, aParams.amount) end

		if aParams.isGlancing then CreateAndRecalcDetails(self, self.GetDetailsList, enumHit.Glancing, aParams.amount) end

		if not aParams.isCritical and not aParams.isGlancing then CreateAndRecalcDetails(self, self.GetDetailsList, enumHit.Normal, aParams.amount) end
	end
	
	
	if aParams.shieldBlock > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHitBlock.Block, aParams.shieldBlock) end

	if aParams.parry > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHitBlock.Parry, aParams.parry) end

	if aParams.barrier > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHitBlock.Barrier, aParams.barrier) end

	if aParams.resist > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHitBlock.Resist, aParams.resist) end

	if aParams.absorb > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHitBlock.Absorb, aParams.absorb) end

	if aParams.runesAbsorb and aParams.runesAbsorb > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHitBlock.RunesAbsorb, aParams.runesAbsorb) end

	if aParams.toMount > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHitBlock.Mount, aParams.toMount) end

	if aParams.multipliersAbsorb ~= 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHitBlock.MultAbsorb, aParams.multipliersAbsorb) end
	
	if aParams.Vulnerability then 
		CreateAndRecalcDetails(self, self.GetBuffList, enumBuff.Vulnerability, aParams.amount)
	end
	if aParams.Weakness then 
		CreateAndRecalcDetails(self, self.GetBuffList, enumBuff.Weakness, aParams.amount)
	end
	if aParams.Defense then 
		CreateAndRecalcDetails(self, self.GetBuffList, enumBuff.Defense, aParams.amount)
	end
	if aParams.Valor then 
		CreateAndRecalcDetails(self, self.GetBuffList, enumBuff.Valor, aParams.amount)
	end
	
	for i, value in ipairs(CurrentBuffsState) do
		local srcBuff = value[aParams.sourceID]
		local targetBuff = value[aParams.targetID]
		if srcBuff and srcBuff.forDps and srcBuff.forSrc then
			CreateAndRecalcDetails(self, self.GetCustomBuffList, srcBuff.ind, aParams.amount)
		end
		if targetBuff and targetBuff.forDps and targetBuff.forTarget then
			CreateAndRecalcDetails(self, self.GetCustomBuffList, targetBuff.ind, aParams.amount)
		end
	end
end

function TDamageSpellData:AddValuesFromSpellData(aSpellData, aLastHitTime)
	self.Count = self.Count + aSpellData.Count;
	self.Amount = self.Amount + aSpellData.Amount;
	self.Hits = self.Hits + aSpellData.Hits;

	CreateAndMergeDetails(self, self.GetMissList, aSpellData.MissList, enumMiss.Miss)
	CreateAndMergeDetails(self, self.GetMissList, aSpellData.MissList, enumMiss.Dodge)
	
	CreateAndMergeDetails(self, self.GetBuffList, aSpellData.BuffList, enumBuff.Vulnerability)
	CreateAndMergeDetails(self, self.GetBuffList, aSpellData.BuffList, enumBuff.Weakness)
	CreateAndMergeDetails(self, self.GetBuffList, aSpellData.BuffList, enumBuff.Defense)
	CreateAndMergeDetails(self, self.GetBuffList, aSpellData.BuffList, enumBuff.Valor)

	CreateAndMergeDetails(self, self.GetDetailsList, aSpellData.DetailsList, enumHit.Critical)
	CreateAndMergeDetails(self, self.GetDetailsList, aSpellData.DetailsList, enumHit.Glancing)
	CreateAndMergeDetails(self, self.GetDetailsList, aSpellData.DetailsList, enumHit.Normal)
	
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHitBlock.Block)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHitBlock.Parry)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHitBlock.Barrier)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHitBlock.Resist)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHitBlock.Absorb)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHitBlock.RunesAbsorb)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHitBlock.Mount)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHitBlock.MultAbsorb)
	
	for i, value in ipairs(CurrentBuffsState) do
		CreateAndMergeDetails(self, self.GetCustomBuffList, aSpellData.CustomBuffList, i)
	end

	self.LastHitTime = aLastHitTime
end

function TDamageSpellData:GetCustomBuffList()
	if not self.CustomBuffList then
		self.CustomBuffList = {}
	end
	return self.CustomBuffList
end

function TDamageSpellData:GetBuffList()
	if not self.BuffList then
		self.BuffList = {}
	end
	return self.BuffList
end

function TDamageSpellData:GetMissList()
	if not self.MissList then
		self.MissList = {}
	end
	return self.MissList
end

function TDamageSpellData:GetDetailsList()
	if not self.DetailsList then
		self.DetailsList = {}
	end
	return self.DetailsList
end

function TDamageSpellData:GetResistDetailsList()
	if not self.ResistDetailsList then
		self.ResistDetailsList = {}
	end
	return self.ResistDetailsList
end

function TDamageSpellData:GetAverageCntPerSecond()
	if self.LastHitTime == nil or self.FirstHitTime == nil then 
		return self.Count
	end
	if self.LastHitTime - self.FirstHitTime == 0 then 
		return self.Count
	end
	return self.Count / (self.LastHitTime - self.FirstHitTime)
end
--------------------------------------------------------------------------------
-- Get the total blocked damage acount
--------------------------------------------------------------------------------
function TDamageSpellData:GetResistAmount()
	local res = 0
	if self.ResistDetailsList then
		for _, blockDmgDetail in pairs( self.ResistDetailsList ) do
			if blockDmgDetail.Amount > 0 then
				res = res + blockDmgDetail.Amount
			end 
		end
	end
	return res
end
--------------------------------------------------------------------------------
-- Recalculate the pourcentage for each type of damage
--------------------------------------------------------------------------------
function TDamageSpellData:CalculateSpellDetailsPercentage()
	if self.DetailsList then
		for _, damageDetail in pairs( self.DetailsList ) do
			damageDetail.Percentage = GetPercentageAt(damageDetail.Count, self.Hits)
		end
	end

	if self.MissList then
		for _, missDetail in pairs( self.MissList ) do
			missDetail.Percentage = GetPercentageAt(missDetail.Count, self.Count)
		end
	end
	
	if self.BuffList then
		for _, buffDetail in pairs( self.BuffList ) do
			buffDetail.Percentage = GetPercentageAt(buffDetail.Count, self.Count)
		end
	end

	if self.CustomBuffList then
		for _, buffDetail in pairs( self.CustomBuffList ) do
			buffDetail.Percentage = GetPercentageAt(buffDetail.Count, self.Count)
		end
	end
	
	if self.ResistDetailsList then
		local allDamage = self.Amount + self:GetResistAmount()
		for _, blockDmgDetail in pairs( self.ResistDetailsList ) do
			blockDmgDetail.Percentage = GetPercentageAt(blockDmgDetail.Amount, allDamage)
		end
	end
end
--------------------------------------------------------------------------------
-- Type THealSpellData
Global("THealSpellData", {})
--------------------------------------------------------------------------------
function THealSpellData:CreateNewObject()
	return setmetatable({
			Count = 0,					-- Count how many spell inpu			
			Amount = 0,					-- Total heal amount
		}, { __index = self })
end
--------------------------------------------------------------------------------
-- Update the data by adding a new value
--------------------------------------------------------------------------------
function THealSpellData:ReceiveValuesFromParams(aParams)
	self.Count = self.Count + 1;
	self.Amount = self.Amount + aParams.heal;


	if aParams.isCritical then CreateAndRecalcDetails(self, self.GetDetailsList, enumHit.Critical, aParams.heal) end

	if aParams.isGlancing then CreateAndRecalcDetails(self, self.GetDetailsList, enumHit.Glancing, aParams.heal) end

	if not aParams.isCritical and not aParams.isGlancing then CreateAndRecalcDetails(self, self.GetDetailsList, enumHit.Normal, aParams.heal) end


	if aParams.resisted > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHealResist.Resisted, aParams.resisted) end

	if aParams.runeResisted and aParams.runeResisted > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHealResist.RuneResisted, aParams.runeResisted) end

	if aParams.absorbed > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHealResist.Absorbed, aParams.absorbed) end

	if aParams.overload and aParams.overload > 0 then CreateAndRecalcDetails(self, self.GetResistDetailsList, enumHealResist.Overload, aParams.overload) end
	
	-- The amount of the wounds
	--if aParams.lethality > 0 then CreateAndRecalcDetails(self.GlobalInfoList, enumGlobalInfo.Lethality, aParams.lethality) end
	
	for i, value in ipairs(CurrentBuffsState) do
		local srcBuff = value[aParams.sourceID]
		local targetBuff = value[aParams.targetID]
		if srcBuff and srcBuff.forHps and srcBuff.forSrc then
			CreateAndRecalcDetails(self, self.GetCustomBuffList, srcBuff.ind, aParams.heal)
		end
		if targetBuff and targetBuff.forHps and targetBuff.forTarget then
			CreateAndRecalcDetails(self, self.GetCustomBuffList, targetBuff.ind, aParams.heal)
		end
	end
end

function THealSpellData:AddValuesFromSpellData(aSpellData, aLastHitTime)
	self.Count = self.Count + aSpellData.Count;
	self.Amount = self.Amount + aSpellData.Amount;

	CreateAndMergeDetails(self, self.GetDetailsList, aSpellData.DetailsList, enumHit.Critical)
	CreateAndMergeDetails(self, self.GetDetailsList, aSpellData.DetailsList, enumHit.Glancing)
	CreateAndMergeDetails(self, self.GetDetailsList, aSpellData.DetailsList, enumHit.Normal)
	
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHealResist.Resisted)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHealResist.RuneResisted)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHealResist.Absorbed)
	CreateAndMergeDetails(self, self.GetResistDetailsList, aSpellData.ResistDetailsList, enumHealResist.Overload)
	
	for i, value in ipairs(CurrentBuffsState) do
		CreateAndMergeDetails(self, self.GetCustomBuffList, aSpellData.CustomBuffList, i)
	end

	self.LastHitTime = aLastHitTime
end

function THealSpellData:GetDetailsList()
	if not self.DetailsList then
		self.DetailsList = {}
	end
	return self.DetailsList
end

function THealSpellData:GetResistDetailsList()
	if not self.ResistDetailsList then
		self.ResistDetailsList = {}
	end
	return self.ResistDetailsList
end

function THealSpellData:GetCustomBuffList()
	if not self.CustomBuffList then
		self.CustomBuffList = {}
	end
	return self.CustomBuffList
end


function THealSpellData:GetAverageCntPerSecond()
	if self.LastHitTime == nil or self.FirstHitTime == nil then 
		return self.Count
	end
	if self.LastHitTime - self.FirstHitTime == 0 then 
		return self.Count
	end
	return (self.LastHitTime - self.FirstHitTime) / self.Count
end
--------------------------------------------------------------------------------
-- Get the total resisted heal acount
--------------------------------------------------------------------------------
function THealSpellData:GetResistAmount()
	local res = 0
	if self.ResistDetailsList then
		for _, resistHealDetail in pairs( self.ResistDetailsList ) do
			res = res + resistHealDetail.Amount
		end
	end
	return res
end
--------------------------------------------------------------------------------
-- Recalculate the pourcentage for each type of heal
--------------------------------------------------------------------------------
function THealSpellData:CalculateSpellDetailsPercentage()
	if self.DetailsList then
		for _, healDetail in pairs( self.DetailsList ) do
			healDetail.Percentage = GetPercentageAt(healDetail.Count, self.Count)
		end
	end
	if self.ResistDetailsList then
		local allHeal = self.Amount + self:GetResistAmount();
		for _, resistHealDetail in pairs( self.ResistDetailsList ) do
			resistHealDetail.Percentage = GetPercentageAt(resistHealDetail.Amount, allHeal)
		end
	end
	if self.CustomBuffList then
		for _, buffDetail in pairs( self.CustomBuffList ) do
			buffDetail.Percentage = GetPercentageAt(buffDetail.Count, self.Count)
		end
	end
end