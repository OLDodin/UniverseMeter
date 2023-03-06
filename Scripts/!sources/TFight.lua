--------------------------------------------------------------------------------
-- Type TTimer
Global("TTimer", {})
--------------------------------------------------------------------------------
function TTimer:CreateNewObject()
	return setmetatable({
			Counter = 0,		-- The counter incremeted each seconds
			IsStarted = false,	-- To know if the timer can be incremented
			LastHitTime = 0		-- The time of the last hit to remove the time after this hit		
		}, { __index = self })
end
--------------------------------------------------------------------------------
-- Reset the timer
--------------------------------------------------------------------------------
function TTimer:ResetTimer()
	self.Counter = 0
end
--------------------------------------------------------------------------------
-- Increment the timer
--------------------------------------------------------------------------------
function TTimer:IncrementTimer()
	if self.IsStarted then
		self.Counter = self.Counter + 1
	end
end
--------------------------------------------------------------------------------
-- Start the timer
--------------------------------------------------------------------------------
function TTimer:StartTimer()
	self.IsStarted = true
end
--------------------------------------------------------------------------------
-- Reset the timer
--------------------------------------------------------------------------------
function TTimer:StopTimer()
	self.IsStarted = false
	self.Counter = self.LastHitTime
end
--------------------------------------------------------------------------------
-- Set hit to save the last action time
--------------------------------------------------------------------------------
function TTimer:SetLastHit()
	self.LastHitTime = self.Counter
end
--------------------------------------------------------------------------------
-- Get elapsed time (return a value >= 1)
--------------------------------------------------------------------------------
function TTimer:GetElapsedTime()
	return self.Counter
end

--------------------------------------------------------------------------------
-- Type TFightData
Global("TFightData", {})
--------------------------------------------------------------------------------
function TFightData:CreateNewObject()
	return setmetatable({
			Amount = 0,			-- Total amount in the fight
			AmountPerSec = 0	-- Amount per second
		}, { __index = self })
end
--------------------------------------------------------------------------------
-- Type TFightPeriod
Global("TFightPeriod", {})
--------------------------------------------------------------------------------
function TFightPeriod:CreateNewObject(ID)
	return setmetatable({
			ID = ID,							-- ID of the fight
			CombatantsList = {},	-- List of combatants
		}, { __index = self })
end

function TFightPeriod:CleanCopyCombantants(aFight)
	for _, combatant in pairs(aFight.CombatantsList) do
		table.insert(self.CombatantsList, combatant:MakeCleanCopy())
	end
end
--------------------------------------------------------------------------------
-- Add a new combatant
--------------------------------------------------------------------------------
function TFightPeriod:UpdateOrAddCombatant(anID, aName, aClassColorIndex, anIsNear)
	local combatant = self:GetCombatant(anID, aName)
	if combatant then
		combatant:UpdateCombatant(anID, aName, aClassColorIndex, anIsNear)
	else
		combatant = TCombatant:CreateNewObject(anID, aName, aClassColorIndex, anIsNear)
		table.insert(self.CombatantsList, combatant)
		
		if GetTableSize(self.CombatantsList) > Settings.MaxCombatants then
			local absentCombatant, index = self:GetAbsentCombatant()
			if index then
				table.remove(self.CombatantsList, index)
			end
		end
	end
	return combatant
end

--------------------------------------------------------------------------------
-- Remove a combatant
--------------------------------------------------------------------------------
function TFightPeriod:RemoveCombatant(anID, aName)
	local combatant, index = self:GetCombatant(anID, aName)

	if index then
		combatant.Absent = true
	end
end

function TFightPeriod:GetAbsentCombatant()
	for i, combatant in pairs(self.CombatantsList) do
		if combatant.Absent then
			return combatant, i 
		end
	end

	return nil
end
--------------------------------------------------------------------------------
-- Get a combatant
--------------------------------------------------------------------------------
function TFightPeriod:GetCombatant(anID, aName)
	if anID then
		for i, combatant in pairs( self.CombatantsList ) do
			if combatant.ID == anID then
				return combatant, i 
			end
		end
	end
	--если перезаходил и унего сменился id ищем по имени
	if aName then
		for i, combatant in pairs( self.CombatantsList ) do
			if CompareWStr(combatant.Name, aName) then
				return combatant, i
			end
		end
	end

	return nil
end
--------------------------------------------------------------------------------
-- Get combatant by index
--------------------------------------------------------------------------------
function TFightPeriod:GetCombatantByIndex(anIndex)
	return self.CombatantsList[anIndex]
end
--------------------------------------------------------------------------------
-- Get combatant info (id, name) by index
--------------------------------------------------------------------------------
function TFightPeriod:GetCombatantInfoByIndex(anIndex)
	local combatant = self.CombatantsList[anIndex]
	if combatant then
		local toReturn = {}
		toReturn.id = combatant.ID
		toReturn.name = combatant.Name
		return toReturn
	end
	return nil
end
--------------------------------------------------------------------------------
-- Get combatant count
--------------------------------------------------------------------------------
function TFightPeriod:GetCombatantCount()
	return table.getn(self.CombatantsList) or 0
end

function TFightPeriod:RaidRebuilded()
	self.CombatantsList = {}
end

function TFightPeriod:HasData()
	for _, combatant in pairs(self.CombatantsList) do
		if combatant.Data[enumMode.Dps] or combatant.Data[enumMode.Hps] 
		or combatant.Data[enumMode.Def] or combatant.Data[enumMode.IHps] then
			return true
		end
	end
	return false
end



--------------------------------------------------------------------------------
-- Type TFight
Global("TFight", {})
Global("TFightCnt", 1)
setmetatable(TFight ,{__index = TFightPeriod}) 
--------------------------------------------------------------------------------
function TFight:CreateNewObject()
	local newObj = TFightPeriod:CreateNewObject(TFightCnt)
	TFightCnt = TFightCnt + 1
	newObj.FightPeriods = {}
	newObj.Timer = TTimer:CreateNewObject()	-- Timer of the fight
	newObj.Data = {							-- Data (Dps, Hps, Def)
				[enumMode.Dps]	= TFightData:CreateNewObject(),
				[enumMode.Hps]	= TFightData:CreateNewObject(),
				[enumMode.Def]	= TFightData:CreateNewObject(),
				[enumMode.IHps]	= TFightData:CreateNewObject()
			}
	return setmetatable(newObj, { __index = self })
end

function TFight:UpdateCombatantByCombatant(aCombatant)
	local combatant = self:UpdateOrAddCombatant(aCombatant.ID, aCombatant.Name, aCombatant:GetClassColor(), aCombatant:GetIsNear())
	combatant.Absent = aCombatant.Absent
	return combatant
end

function TFight:UpdateCombatantFromFightPeriod(aFightPeriod)
	for _, combatantFromPeriod in pairs(aFightPeriod.CombatantsList) do
		self:UpdateCombatantByCombatant(combatantFromPeriod)
	end
end

function TFight:UpdateOnlyDisplayData(aFightPeriod)
	for _, combatantFromPeriod in pairs(aFightPeriod.CombatantsList) do
		local combatant = self:UpdateCombatantByCombatant(combatantFromPeriod)
		
		for _, mode in pairs(enumMode) do 
			if combatantFromPeriod.Data[mode] then
				combatant:CreateCombatantData(mode)
				if combatant.Data[mode].LastAmount == nil then
					combatant.Data[mode].LastAmount = 0
				end
				combatant.Data[mode].Amount = combatant.Data[mode].LastAmount + combatantFromPeriod.Data[mode].Amount
			end		
		end
	end
end

function TFight:AddFightPeriodAndApply(aFightPeriod, aCalculateSpellData)
	if not aCalculateSpellData then
		table.insert(self.FightPeriods, aFightPeriod)
	end
	self:IncrementFightTime()
	for _, combatantFromPeriod in pairs(aFightPeriod.CombatantsList) do
		local combatant = self:UpdateCombatantByCombatant(combatantFromPeriod)
		
		for _, mode in pairs(enumMode) do 
			if combatantFromPeriod.Data[mode] then
				combatant:CreateCombatantData(mode)
				if combatant.Data[mode].LastAmount == nil then
					combatant.Data[mode].LastAmount = 0
				end
				combatant.Data[mode].Amount = combatant.Data[mode].LastAmount + combatantFromPeriod.Data[mode].Amount
				combatant.Data[mode].LastAmount = combatant.Data[mode].Amount
				
				if combatantFromPeriod.Data[mode].Amount ~= 0 then
					self.Timer:SetLastHit()
				end
			end		
		end
		if aCalculateSpellData then
			combatant.LastFightPeriodID = aFightPeriod.ID
			self:CalculateSpellData(combatant, combatantFromPeriod, aFightPeriod.ID)
		end
	end
end

function TFight:CalculateSpellData(aCombatant, aCombatantFromPeriod, aFightPeriodID)
	if aCombatantFromPeriod then
		for _, mode in pairs(enumMode) do 					
			aCombatant:MergeGlobalInfo(mode, aCombatantFromPeriod)
			if aCombatantFromPeriod.Data[mode] then
				for _, spellDataFromPeriod in pairs(aCombatantFromPeriod.Data[mode].SpellsList) do
					local spellData = aCombatant:GetSpellByIdentifier(spellDataFromPeriod.Identifier, mode, spellDataFromPeriod.Element)
					if not spellData then
						spellData = aCombatant:AddCopySpell(mode, spellDataFromPeriod, aFightPeriodID)
					else
						spellData:AddValuesFromSpellData(spellDataFromPeriod, aFightPeriodID)
					end
				end
			end
		end
	end
end

function TFight:PrepareShowDetails(aCombatantInfo)
	local combatant = self:GetCombatant(aCombatantInfo.id, aCombatantInfo.name)
	if combatant.LastFightPeriodID == nil then
		combatant.LastFightPeriodID = 0
	end
	for _, fightPeriod in ipairs(self.FightPeriods) do
		if fightPeriod.ID > combatant.LastFightPeriodID then
			local combatantFromPeriod = fightPeriod:GetCombatant(aCombatantInfo.id, aCombatantInfo.name)
			combatant.LastFightPeriodID = fightPeriod.ID
			self:CalculateSpellData(combatant, combatantFromPeriod, fightPeriod.ID)
		end
	end
end
--------------------------------------------------------------------------------
-- Increment the fight time of the fight and the inner fight time for all combatant
--------------------------------------------------------------------------------
function TFight:IncrementFightTime()
	self.Timer:IncrementTimer()
end
--------------------------------------------------------------------------------
-- Start the fight
--------------------------------------------------------------------------------
function TFight:StartFight()
	self.Timer:StartTimer()
end
--------------------------------------------------------------------------------
-- Stop the fight
--------------------------------------------------------------------------------
function TFight:StopFight()
	self.Timer:StopTimer()
end
--------------------------------------------------------------------------------
-- Compare combatant by damage amount
--------------------------------------------------------------------------------
local function CompareCombatantsBySortValue2(A, B)
	if A.SortValue == B.SortValue then
		return common.CompareWString(A.Name, B.Name) == -1 end
	return A.SortValue > B.SortValue
end
--------------------------------------------------------------------------------
-- Sort combatant by SortValue. This value is update in TFightPeriod:RecalculateCombatantsData(Mode)
-- It can be damage amount, heal amout, ...
--------------------------------------------------------------------------------
function TFight:SortCombatantsBySortValue(aMode)
	table.sort(self.CombatantsList, CompareCombatantsBySortValue2)
	local imbaCombatant = self.CombatantsList[1]
	if imbaCombatant then
		local leaderAmount = imbaCombatant:GetAmount(aMode)
		for i, combatant in pairs( self.CombatantsList ) do
			if combatant.Data[aMode] then
				combatant.Data[aMode].LeaderPercentage = GetPercentageAt(combatant.Data[aMode].Amount, leaderAmount)
			end
		end
	end
end
--------------------------------------------------------------------------------
-- Recalculate combatant data according to the inner fight time
--------------------------------------------------------------------------------
function TFight:RecalculateCombatantsData(aMode)
	local fightTime = self.Timer:GetElapsedTime()
	if not (fightTime > 0) then fightTime = 1 end
	-- Calculate the total amount
	self.Data[aMode].Amount = 0
	for _, combatant in pairs( self.CombatantsList ) do
		self.Data[aMode].Amount = self.Data[aMode].Amount + combatant:GetAmount(aMode)
		combatant.SortValue = combatant:GetAmount(aMode)
	end
	-- Calculate the total amount per second
	self.Data[aMode].AmountPerSec = self.Data[aMode].Amount / fightTime
	-- For each combatant, calculate DPS and damage amount
	for _, combatant in pairs( self.CombatantsList ) do
		if combatant.Data[aMode] then
			combatant.Data[aMode].AmountPerSec = combatant.Data[aMode].Amount / fightTime
			combatant.Data[aMode].Percentage = GetPercentageAt(combatant.Data[aMode].Amount, self.Data[aMode].Amount)
		end
	end

	self:SortCombatantsBySortValue(aMode)
end