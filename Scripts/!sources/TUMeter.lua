local cachedGetBuffTooltipInfo = object.GetBuffTooltipInfo
local cachedGetDescription = spellLib.GetDescription
local cachedGetAbilityInfo = avatar.GetAbilityInfo
local cachedGetMapModifierInfo = cartographer.GetMapModifierInfo
local cachedIsPet = unit.IsPet
local cachedGetRage = unit.GetRage
local cachedGetName = object.GetName

--------------------------------------------------------------------------------
-- Type TUMeter
Global("TUMeter", {})
--------------------------------------------------------------------------------


function TUMeter:CreateNewObject()
	local obj = setmetatable({
			bCollectData = false,		-- If we must collect data or not (are we in fight or not)
			bRaidRebuilded = false,
			bHasChangesOnTick = false,
			Fight = { Total = nil, Current = nil},	
			OffBattleTime = 0,          -- Off-time battle allows to retrieve data coming just after the end of the fight (the events seems to not arrive in the correct order)
			GlobalFightPeriodsArr = TList(),
			GlobalFightPeriodsCnt = 1,
			HistoryTotalFights = TList(),
			HistoryCurrentFights = TList(),
			CurrentPlayersDetermination = {}, 
			LastTickPlayersDetermination = { timestamp = 0 },
			LastLastTickPlayersDetermination = { timestamp = 0 },
			CheckMemoryCnt = 0,
			bHistoryIncresed = false,
			
			EmptyPeriod =  TFightPeriod:CreateNewObject(-1)
		}, { __index = self })
	local newFightPeriod = obj:AddNewFightPeriod()
	return obj
end
--------------------------------------------------------------------------------
-- Begin a new fight
--------------------------------------------------------------------------------
function TUMeter:AddNewFightPeriod()
	self.GlobalFightPeriodsCnt = self.GlobalFightPeriodsCnt + 1
	local newFightPeriod = TFightPeriod:CreateNewObject(self.GlobalFightPeriodsCnt)
	self.GlobalFightPeriodsArr:insert_last(newFightPeriod)
	
	ResizeListByMaxSize(self.GlobalFightPeriodsArr, 3, true)
	return newFightPeriod
end

function TUMeter:GetLastFightPeriod()
	return TList:unpackFromList(self.GlobalFightPeriodsArr.last)
end

--------------------------------------------------------------------------------
-- Remove combatant by name
--------------------------------------------------------------------------------
function TUMeter:RemoveCombatant(aMember)
	self.bHasChangesOnTick = true
	self:GetLastFightPeriod():RemoveCombatant(aMember.id, aMember.name)
end
--------------------------------------------------------------------------------
-- Add or Update combatant
--------------------------------------------------------------------------------
function TUMeter:UpdateOrAddCombatant(aMember)
	self.bHasChangesOnTick = true
	local combatant = self:GetLastFightPeriod():UpdateOrAddCombatant(aMember.id, aMember.name, CalculateClassIndex(aMember.className), CalculateState(aMember))
	combatant:UpdateRange()
end
--------------------------------------------------------------------------------
-- Regen (add or update) combatant list
--------------------------------------------------------------------------------
function TUMeter:RegenCombatantList()
	local partyMembersInfoList = GetPartyMembers()
	for i, member in pairs( partyMembersInfoList ) do
		self:UpdateOrAddCombatant(member)
	end
end
--------------------------------------------------------------------------------
-- Update the position of all members
--------------------------------------------------------------------------------
function TUMeter:UpdateCombatantPos()
	local currentFight = self:GetLastFightPeriod()
	for i, member in pairs(GetPartyMembers()) do
		if member.id then
			local combatant = currentFight:GetCombatant(member.id, member.name)
			if combatant then
				combatant:UpdateRange()
			end
		end
	end
end

function TUMeter:FastTick()
	local lastPeriod = self:GetLastFightPeriod()
	self.Fight.Current:UpdateOnlyDisplayData(lastPeriod)
	self.Fight.Total:UpdateOnlyDisplayData(lastPeriod)
end

function TUMeter:SecondTick()
	local lastPeriod = self:GetLastFightPeriod()
	if self.bRaidRebuilded then
		lastPeriod:RaidRebuilded()
		self:RegenCombatantList()
		self.bRaidRebuilded = false
		self.bHasChangesOnTick = true
	end
	
	if self.bCollectData then
		if not self.bHasChangesOnTick then
			--memory optimize
			self.Fight.Current:AddFightPeriodAndApply(self.EmptyPeriod)
			self.Fight.Total:AddFightPeriodAndApply(self.EmptyPeriod, not Settings.CollectTotalTimelapse)
		else
			self.Fight.Current:AddFightPeriodAndApply(lastPeriod)
			self.Fight.Total:AddFightPeriodAndApply(lastPeriod, not Settings.CollectTotalTimelapse)
		end
	else
		self.Fight.Current:UpdateCombatantFromFightPeriod(lastPeriod)
		self.Fight.Total:UpdateCombatantFromFightPeriod(lastPeriod)
	end
	
	local newFightPeriod = self:AddNewFightPeriod()
	newFightPeriod:CleanCopyCombantants(lastPeriod)
	
	self.bHasChangesOnTick = false
	
	self:CheckMemoryPanic()
end

function TUMeter:UpdateUnitRage(anID, aValue)
	self.CurrentPlayersDetermination[anID] = aValue
end

function TUMeter:CollectUnitsRage()
	self.LastLastTickPlayersDetermination = self.LastTickPlayersDetermination
	
	self.LastTickPlayersDetermination = self.CurrentPlayersDetermination
	self.LastTickPlayersDetermination.timestamp = common.GetLocalDateTimeMs()
	
	self.CurrentPlayersDetermination = {}
end

function TUMeter:GetUnitRage(anID)
	if not anID then
		return nil
	end
	local determinationArr = self.LastTickPlayersDetermination
	if common.GetLocalDateTimeMs() - self.LastTickPlayersDetermination.timestamp < 50 then
		determinationArr = self.LastLastTickPlayersDetermination
	end
	
	if not determinationArr[anID] then
		determinationArr[anID] = IsExistUnit(anID) and cachedGetRage(anID) or nil
	end
	
	return determinationArr[anID]
end

function TUMeter:GetFightCombatant(anID)
	if not anID then return end
	local combatant = self:GetLastFightPeriod():GetCombatant(anID)
	if combatant then
		return combatant, false
	else
		local masterID = unit.GetFollowerMaster(anID)
		combatant = self:GetLastFightPeriod():GetCombatant(masterID)
		return combatant, true
	end
end

function TUMeter:GetInfoFromID(anID)
	local typeOfID = apitype(anID)
	if typeOfID == "SpellId" then
		return cachedGetDescription(anID)
	elseif typeOfID == "AbilityId" then
		return cachedGetAbilityInfo(anID)
	elseif typeOfID == "BuffId" then
		return cachedGetBuffTooltipInfo(anID)
	elseif typeOfID == "MapModifierId" then
		return cachedGetMapModifierInfo(anID)
	else
		return
	end
end

-- например, для парных боссов приходит урон и для 2го, но уже только с указанием sourceName targetName
local function BuildBySourceName(aSrcName, aTargetName)
	local spellName = aSrcName and not aSrcName:IsEmpty() and aSrcName or StrUnknown
	if aTargetName then
		spellName = spellName..StrArrow..aTargetName
	end
	return spellName
end

--------------------------------------------------------------------------------
-- Get information of a spell
--------------------------------------------------------------------------------
function TUMeter:GetSpellInfoFromParams(aParams, anIsPet)
	local spellInfo = {}
	
	spellInfo.infoID = aParams.buffId or aParams.spellId or aParams.abilityId or aParams.mapModifierId

	if aParams.damageSource == "DamageSource_DAMAGEPOOL" then
		spellInfo.Name = StrDamagePool
		spellInfo.fromBarrier = true
	elseif aParams.damageSource == "DamageSource_BARRIER" then
		spellInfo.Name = StrFromBarrier
		spellInfo.fromBarrier = true
	else
		spellInfo.Name = aParams.ability
		
		if spellInfo.Name == nil or spellInfo.Name:IsEmpty() then
			local someInfo = self:GetInfoFromID(spellInfo.infoID)
			if someInfo and someInfo.name and not someInfo.name:IsEmpty() then
				spellInfo.Name = someInfo.name
			else
				spellInfo.Name =
				aParams.isExploit and StrExploit
				or aParams.isFall and StrFall
				or BuildBySourceName(aParams.sourceName, aParams.targetName)
				or StrUnknown
			end
		end
	end
	
	spellInfo.IsPet = anIsPet
	spellInfo.PetName = anIsPet and aParams.sourceName or nil
	
	spellInfo.Determination = self:GetUnitRage(aParams.source or aParams.healerId)
	
	spellInfo.sysSubElement = aParams.sysSubElement
	
	--dd event
	spellInfo.amount = aParams.amount or aParams.heal
	spellInfo.isMiss = aParams.isMiss
	spellInfo.isDodge = aParams.isDodge
	spellInfo.isCritical = aParams.isCritical
	spellInfo.isGlancing = aParams.isGlancing
	spellInfo.shieldBlock = aParams.shieldBlock
	spellInfo.parry = aParams.parry
	spellInfo.barrier = aParams.barrier
	spellInfo.resist = aParams.resist
	spellInfo.absorb = aParams.absorb
	spellInfo.runesAbsorb = aParams.runesAbsorb
	spellInfo.toMount = aParams.toMount
	spellInfo.multipliersAbsorb = aParams.multipliersAbsorb
	spellInfo.lethal = aParams.lethal
	--heal event
	spellInfo.heal = aParams.heal
	spellInfo.resisted = aParams.resisted
	spellInfo.runeResisted = aParams.runeResisted
	spellInfo.absorbed = aParams.absorbed
	spellInfo.overload = aParams.overload
	spellInfo.lethality = aParams.lethality
	
	spellInfo.Vulnerability = false
	spellInfo.Weakness = false
	spellInfo.Valor = false
	spellInfo.Defense = false

	spellInfo.sourceID = aParams.source or aParams.healerId
	spellInfo.targetID = aParams.target or aParams.unitId
   
	for _, combatTag in pairs( aParams.targetTags or {} ) do
		local info = combatTag:GetInfo()
		if info.isHelpful then 
			if info.name == StrDefense then
				spellInfo.Defense = true
			end
		else
			if info.name == StrVulnerability then
				spellInfo.Vulnerability = true
			end
		end
	end

	for _, combatTag in pairs( aParams.sourceTags or {} ) do
		local info = combatTag:GetInfo()
		if info.isHelpful then
			if info.name == StrValor then
				spellInfo.Valor = true
			end
		else
			if info.name == StrWeakness then
				spellInfo.Weakness = true
			end
		end
	end

	return spellInfo
end
--------------------------------------------------------------------------------
-- Should we collect data the fight
--	Condition: the avatar is in combat
--------------------------------------------------------------------------------
function TUMeter:ShouldCollectData()
	if object.IsInCombat(avatar.GetId()) then
		return true
	end

	-- Should parse all other fighters ?
	for i, combatant in pairs(self:GetLastFightPeriod().CombatantsList) do
		if combatant.ID and object.IsExist(combatant.ID) and combatant:IsClose() and (object.IsInCombat(combatant.ID) or PlayerPetInCombat(combatant.ID)) then			
			return true
		end
	end

	return false
end

function TUMeter:CollectData(aMode, aCombatant, anIsPet, aParams)
	local spellInfo = self:GetSpellInfoFromParams(aParams, anIsPet)
	self:UpdateFightData(aMode, aCombatant, spellInfo)
	return true
end

--------------------------------------------------------------------------------
-- Collect damage dealed data by someone in the party
--------------------------------------------------------------------------------
function TUMeter:CollectDamageDealedData(aParams)
	if aParams.source == aParams.target then return end
	
	-- look for the type of the source
	local currFightCombatant, isPet = self:GetFightCombatant(aParams.source)
	-- If the source is not part of the group or the target is an ally
	if not currFightCombatant then return end

	if Settings.SkipDmgAndHpsOnPet and IsExistPet(aParams.target) then return end

	-- If we're not collecting data, means we are not currently in fight, then start a new one
	if not self.bCollectData and currFightCombatant:IsClose() and (self:ShouldCollectData() or aParams.lethal) then
		self:Start()
	end

	-- if collecting dps data
	return self:CollectData(enumMode.Dps, currFightCombatant, isPet, aParams)
end
--------------------------------------------------------------------------------
-- Collect damage received data by someone in the party
--------------------------------------------------------------------------------
function TUMeter:CollectDamageReceivedData(aParams)
	if Settings.SkipDmgYourselfIn and aParams.source == aParams.target then return end

	-- look for the type of the target
	local currFightCombatant = self:GetFightCombatant(aParams.target)

	if not currFightCombatant then return end

	if not self.bCollectData and currFightCombatant:IsClose() and (self:ShouldCollectData() or aParams.lethal) then
		self:Start()
	end

	return self:CollectData(enumMode.Def, currFightCombatant, aParams.source and unit.GetFollowerMaster(aParams.source) ~= nil or false, aParams)
end

--------------------------------------------------------------------------------
-- Collect heal data from event EVENT_HEALING_RECEIVED
--------------------------------------------------------------------------------
function TUMeter:CollectHealData(aParams)
	-- Check that the healer is part of the group
	local currFightCombatant, isPet = self:GetFightCombatant(aParams.healerId)

	-- if this happen, most probably it's a bloodlust but the heal is coming from the target...
	if not currFightCombatant then
		currFightCombatant, isPet = self:GetFightCombatant(aParams.unitId)
	end

	if not currFightCombatant then return end
	
	if Settings.SkipDmgAndHpsOnPet and IsExistPet(aParams.unitId) then return end

	if not self.bCollectData and currFightCombatant:IsClose() and self:ShouldCollectData() then
		self:Start()
	end

	return self:CollectData(enumMode.Hps, currFightCombatant, isPet, aParams)
end

function TUMeter:CollectHealDataIN(aParams)
	-- Check that the healer is part of the group
	local currFightCombatant = self:GetFightCombatant(aParams.unitId)

	if not currFightCombatant then return end

	if not self.bCollectData and currFightCombatant:IsClose() and self:ShouldCollectData() then
		self:Start()
	end

	return self:CollectData(enumMode.IHps, currFightCombatant, aParams.healerId and unit.GetFollowerMaster(aParams.healerId) ~= nil or false, aParams)
end
--------------------------------------------------------------------------------
-- Update the data in the given mode
--------------------------------------------------------------------------------
function TUMeter:UpdateFightData(aMode, aCombatant, aSpellInfo)
	aCombatant:IncreaseCombatantAmount(aSpellInfo.amount, aMode)

	if aSpellInfo.Determination ~= nil then
		aCombatant:UpdateGlobalInfo(enumGlobalInfo.Determination, aMode, aSpellInfo.Determination)
	end
	
	local spellData = aCombatant:GetSpellByIdentifier(aMode, aSpellInfo.IsPet, aSpellInfo.sysSubElement, aSpellInfo.Name)
	if not spellData then
		spellData = aCombatant:AddNewSpell(aSpellInfo, aMode)
	end

	aCombatant:UpdateSpellDataByInfo(aSpellInfo, spellData, aMode)
	
	self.bHasChangesOnTick = true
end
--------------------------------------------------------------------------------
-- Update the data in the given mode
--------------------------------------------------------------------------------
function TUMeter:CollectMissedDataOnStartFight(anObjID)
	local currFightCombatant = self:GetFightCombatant(anObjID)
	if not currFightCombatant then return end

	if not self.bCollectData and currFightCombatant:IsClose() and self:ShouldCollectData() then
		local periodsArrSize = self.GlobalFightPeriodsArr.length
		if periodsArrSize > 1 then
			local prevPeriod = TList:unpackFromList(self.GlobalFightPeriodsArr:prev(self.GlobalFightPeriodsArr.last))
			local currPeriod = self:GetLastFightPeriod()
			if prevPeriod:HasData() or currPeriod:HasData() then
				self:Start()
			end
		end
	end
end
--------------------------------------------------------------------------------
-- Start combat
--------------------------------------------------------------------------------
function TUMeter:Start()
	self:PushFightFromCurrentToHistory()

	self.Fight.Current = TFight:CreateNewObject()
	
	self:RegenCombatantList()

	self.Fight.Current:StartFight()
	self.Fight.Total:StartFight()

	self.bCollectData = true
	self:ResetOffBattleTime()
		
	--for catch kill or dmg before start fight event
	local periodsArrSize = self.GlobalFightPeriodsArr.length
	if periodsArrSize > 1 then
		local prevPeriod = TList:unpackFromList(self.GlobalFightPeriodsArr:prev(self.GlobalFightPeriodsArr.last))
		if prevPeriod:HasData() then
			self.Fight.Current:AddFightPeriodAndApply(prevPeriod)
			self.Fight.Total:AddFightPeriodAndApply(prevPeriod, not Settings.CollectTotalTimelapse)
		end
	end
end
--------------------------------------------------------------------------------
-- Stop combat
--------------------------------------------------------------------------------
function TUMeter:Stop()
	self.bCollectData = false
	self.Fight.Current:StopFight()
	self.Fight.Total:StopFight()
end

function TUMeter:ResetOffBattleTime()
	self.OffBattleTime = 0
end
--------------------------------------------------------------------------------
-- Update the off-time battle and return the new value
--------------------------------------------------------------------------------
function TUMeter:UpdateOffBattleTime()
	self.OffBattleTime = self.OffBattleTime + 1
	return self.OffBattleTime
end
--------------------------------------------------------------------------------
-- Reset all fights
--------------------------------------------------------------------------------
function TUMeter:ResetAllFights()
	self:PushFightFromTotalToHistory()
	self:PushFightFromCurrentToHistory()

	self.Fight.Total = TFight:CreateNewObject()
	self.Fight.Current = TFight:CreateNewObject()
	
	self.bRaidRebuilded = true
	self.bCollectData = false
end

function TUMeter:PushFightFromTotalToHistory()
	self:PushFightToHistory(self.Fight.Total, self.HistoryTotalFights)
	ResizeListByMaxSize(self.HistoryTotalFights, Settings.HistoryTotalLimit, false)
	self.Fight.Total = nil
	self.bHistoryIncresed = true
end

function TUMeter:PushFightFromCurrentToHistory()
	self:PushFightToHistory(self.Fight.Current, self.HistoryCurrentFights)
	ResizeListByMaxSize(self.HistoryCurrentFights, Settings.HistoryCurrentLimit, false)
	self.Fight.Current = nil
	self.bHistoryIncresed = true
end

function TUMeter:PushFightToHistory(aFight, aHistory)
	if not aFight then
		return
	end

	if aFight:HasData() then
		aHistory:insert_first(aFight)
	end
end

function TUMeter:CheckMemoryPanic()
	self.CheckMemoryCnt = self.CheckMemoryCnt + 1
	if self.CheckMemoryCnt < 180 then
		return
	end
	self.CheckMemoryCnt = 0
	if self.bHistoryIncresed and gcinfo() > Settings.MemoryUsageLimit then
		--LogInfo("clear on CheckMemoryPanic ", tostring(gcinfo()).."kb", " time = ", GetTimestamp())
		--при превышении лимита по памяти стираем из каждой истории, но хотя бы 1 оставляем
		local newHistorySize = math.max(self.HistoryCurrentFights.length - 2, 1)
		ResizeListByMaxSize(self.HistoryCurrentFights, newHistorySize, false)
		newHistorySize = math.max(self.HistoryTotalFights.length - 1, 1)
		ResizeListByMaxSize(self.HistoryTotalFights, newHistorySize, false)
		--collectgarbage()
		self.bHistoryIncresed = false
		--LogInfo("after clear memory usage ", tostring(gcinfo()).."kb", " time = ", GetTimestamp())
	end
end