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
			LastTickPlayersDetermination = {},
			
			BuffInfoCache = {},
			SpellDescCache = {},
			AbilityInfoCache = {},
			MapModifierInfoCache = {},
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
	--table.insert(self.GlobalFightPeriodsArr, newFightPeriod)
	
	ResizeListByMaxSize(self.GlobalFightPeriodsArr, 3, true)
	return newFightPeriod
end

function TUMeter:GetLastFightPeriod()
	--return self.GlobalFightPeriodsArr[table.getn(self.GlobalFightPeriodsArr)]
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
end

function TUMeter:CollectPlayersRage()
	if not Settings.UseAlternativeRage then
		return
	end
	self.LastTickPlayersDetermination = {}
	
	local unitList = avatar.GetUnitList()
	table.insert(unitList, avatar.GetId())
	for _, objID in ipairs(unitList) do
		 if object.IsExist(objID) and object.IsUnit(objID) and unit.IsPlayer(objID) then
			self.LastTickPlayersDetermination[objID] = unit.GetRage(objID)
		 end
	end
end

function TUMeter:GetFightCombatant(anID)
	if not anID then return end
	local combatant = self:GetLastFightPeriod():GetCombatant(anID)
	if not combatant then
		local masterID = unit.GetFollowerMaster(anID)
		combatant = self:GetLastFightPeriod():GetCombatant(masterID)
	end
	return combatant
end

function TUMeter:GetInfoFromCache(anID, aCache, aGetInfoFunc)
	if anID == nil then
		return nil
	end
	for _, info in pairs(aCache) do
		if info.meterInfoID:IsEqual(anID) then
			return info
		end
	end

	local info = aGetInfoFunc(anID)
	if info then
		info.meterInfoID = anID
		table.insert(aCache, info)
	end
	return info
end

function TUMeter:GetInfoFromParams(aParams)
	return self:GetInfoFromCache(aParams.buffId, self.BuffInfoCache, object.GetBuffInfo)
	or self:GetInfoFromCache(aParams.spellId, self.SpellDescCache, spellLib.GetDescription)
	or self:GetInfoFromCache(aParams.abilityId, self.AbilityInfoCache, avatar.GetAbilityInfo)
	or self:GetInfoFromCache(aParams.mapModifierId, self.MapModifierInfoCache, cartographer.GetMapModifierInfo)
	or nil
end

--------------------------------------------------------------------------------
-- Get information of a spell
--------------------------------------------------------------------------------
function TUMeter:GetSpellInfoFromParams(aParams)
	local spellInfo = {}
	spellInfo.Name = nil
	local someInfo = self:GetInfoFromParams(aParams)
	if someInfo and not someInfo.name:IsEmpty() then
		spellInfo.Name = someInfo.name
	end
	if spellInfo.Name == nil then
		spellInfo.Name =
		aParams.ability and not aParams.ability:IsEmpty() and aParams.ability
		or aParams.isExploit and StrExploit
		or aParams.isFall and StrFall
		or aParams.sourceName and not aParams.sourceName:IsEmpty() and aParams.sourceName
		or StrUnknown
	end		

	spellInfo.Desc = someInfo and someInfo.description or nil

	local typeElemForId = ""
	if aParams.damageSource == "DamageSource_DAMAGEPOOL" then
		spellInfo.Suffix = StrDamagePool
		typeElemForId = "p"
	elseif aParams.damageSource == "DamageSource_BARRIER" then
		spellInfo.Suffix = StrFromBarrier
		typeElemForId = "b"
	else
		spellInfo.Suffix = nil
	end
	
	local sourceId = aParams.source or aParams.healerId or nil
	if IsExistUnit(sourceId) then
		spellInfo.IsPet =  unit.IsPet(sourceId)
		if Settings.UseAlternativeRage then
			spellInfo.Determination = self.LastTickPlayersDetermination[sourceId] or unit.GetRage(sourceId)
		else
			spellInfo.Determination = unit.GetRage(sourceId)
		end
		if spellInfo.IsPet then
			spellInfo.PetName = object.GetName(sourceId)
		end
	else
		spellInfo.IsPet = false
		spellInfo.Determination = nil
	end

	spellInfo.sysSubElement = aParams.sysSubElement
	spellInfo.strIdentifier = (spellInfo.IsPet and "1" or "0") .. typeElemForId

	
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
	   
	if aParams.targetTags then 
		for i, combatTag in pairs( aParams.targetTags ) do
			local info = combatTag:GetInfo()
			if info.isHelpful then 
				if CompareWStr(info.name, StrDefense) then
					spellInfo.Defense = true
				end
			else
				if CompareWStr(info.name, StrVulnerability) then
					spellInfo.Vulnerability = true
				end
			end
		end
	end
	if aParams.sourceTags then 
		for i, combatTag in pairs( aParams.sourceTags ) do
			local info = combatTag:GetInfo()
			if info.isHelpful then
				if CompareWStr(info.name, StrValor) then
					spellInfo.Valor = true
				end
			else
				if CompareWStr(info.name, StrWeakness) then
					spellInfo.Weakness = true
				end
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
		if combatant.ID and object.IsExist(combatant.ID) and combatant:IsClose() and object.IsInCombat(combatant.ID) then
			return true
		end
	end

	return false
end


function TUMeter:CollectData(aMode, aCombatant, aParams)
	local spellInfo = self:GetSpellInfoFromParams(aParams)
	self:UpdateFightData(aMode, aCombatant, spellInfo)
	return true
end

--------------------------------------------------------------------------------
-- Collect damage dealed data by someone in the party
--------------------------------------------------------------------------------
function TUMeter:CollectDamageDealedData(aParams)
	if aParams.source == aParams.target then return end
	
	-- look for the type of the source
	local currFightCombatant = self:GetFightCombatant(aParams.source)
	-- If the source is not part of the group or the target is an ally
	if not currFightCombatant then return end

	if Settings.SkipDmgAndHpsOnPet and IsExistPet(aParams.target) then return end

	-- If we're not collecting data, means we are not currently in fight, then start a new one
	if not self.bCollectData and currFightCombatant:IsClose() and (self:ShouldCollectData() or aParams.lethal) then
		self:Start()
	end

	-- if collecting dps data
	return self:CollectData(enumMode.Dps, currFightCombatant, aParams)
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

	return self:CollectData(enumMode.Def, currFightCombatant, aParams)
end

--------------------------------------------------------------------------------
-- Collect heal data from event EVENT_HEALING_RECEIVED
--------------------------------------------------------------------------------
function TUMeter:CollectHealData(aParams)
	--[[if aParams.isFall then
		return
	end
]]
	-- Check that the healer is part of the group
	local currFightCombatant = self:GetFightCombatant(aParams.healerId)

	-- if this happen, most probably it's a bloodlust but the heal is coming from the target...
	if not currFightCombatant then
		currFightCombatant = self:GetFightCombatant(aParams.unitId)
	end

	if not currFightCombatant then return end
	
	if Settings.SkipDmgAndHpsOnPet and IsExistPet(aParams.unitId) then return end

	if not self.bCollectData and currFightCombatant:IsClose() and self:ShouldCollectData() then
		self:Start()
	end

	return self:CollectData(enumMode.Hps, currFightCombatant, aParams)
end

function TUMeter:CollectHealDataIN(aParams)
	--[[if aParams.isFall then
		return
	end
]]
	-- Check that the healer is part of the group
	local currFightCombatant = self:GetFightCombatant(aParams.unitId)

	if not currFightCombatant then return end

	if not self.bCollectData and currFightCombatant:IsClose() and self:ShouldCollectData() then
		self:Start()
	end

	return self:CollectData(enumMode.IHps, currFightCombatant, aParams)
end
--------------------------------------------------------------------------------
-- Update the data in the given mode
--------------------------------------------------------------------------------
function TUMeter:UpdateFightData(aMode, aCombatant, aSpellInfo)
	aCombatant:CreateCombatantData(aMode)
	aCombatant.Data[aMode].Amount = aCombatant.Data[aMode].Amount + aSpellInfo.amount
	
	if aSpellInfo.Determination ~= nil then
		aCombatant:UpdateGlobalInfo(aSpellInfo.Determination, aMode)
	end
	
	local spellData = aCombatant:GetSpellByIdentifier(aMode, aSpellInfo.strIdentifier, aSpellInfo.sysSubElement, aSpellInfo.Name)
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
			if prevPeriod:HasData() then
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
	ResizeListByMaxSize(self.HistoryTotalFights, 3, false)
	self.Fight.Total = nil
end

function TUMeter:PushFightFromCurrentToHistory()
	self:PushFightToHistory(self.Fight.Current, self.HistoryCurrentFights)
	ResizeListByMaxSize(self.HistoryCurrentFights, 10, false)
	self.Fight.Current = nil
end

function TUMeter:PushFightToHistory(aFight, aHistory)
	if not aFight then
		return
	end

	if aFight:HasData() then
		aHistory:insert_first(aFight)
	end
end