local cachedGetBuffTooltipInfo = object.GetBuffTooltipInfo
local cachedGetDescription = spellLib.GetDescription
local cachedGetAbilityInfo = avatar.GetAbilityInfo
local cachedGetMapModifierInfo = cartographer.GetMapModifierInfo
local cachedGetRage = unit.GetRage
local cachedGetName = object.GetName
local cachedIsExist = object.IsExist
local cachedGetFollowerMaster = unit.GetFollowerMaster
local cachedGetLocalDateTimeMs = common.GetLocalDateTimeMs
local cachedIsInCombat = object.IsInCombat

--------------------------------------------------------------------------------
-- Type TUMeter
Global("TUMeter", {})
--------------------------------------------------------------------------------


function TUMeter:CreateNewObject()
	local obj = setmetatable({
			bCollectData = false,		-- If we must collect data or not (are we in fight or not)
			bHasChangesOnTick = false,
			Fight = { Total = nil, Current = nil},	
			OffBattleTime = 0,          -- Off-time battle allows to retrieve data coming just after the end of the fight (the events seems to not arrive in the correct order)
			GlobalFightPeriodsArr = TList(),
			GlobalFightPeriodsCnt = 1,
			HistoryTotalFights = TList(),
			HistoryCurrentFights = TList(),
			CurrentPlayersDetermination = {}, 
			LastPlayersDetermination = {},
			CheckMemoryCnt = 0,
			ClearCacheCnt = 0,
			bHistoryIncresed = false,
			bHistoryChanged = false,
			
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
	TCombatant.UpdateRange(combatant)
end
--------------------------------------------------------------------------------
-- Regen (add or update) combatant list
--------------------------------------------------------------------------------
function TUMeter:RegenCombatantList()
	local partyMembersInfoList = GetPartyMembers(true)
	for i, member in pairs( partyMembersInfoList ) do
		self:UpdateOrAddCombatant(member)
	end
end
--------------------------------------------------------------------------------
-- Update the position of all members
--------------------------------------------------------------------------------
function TUMeter:UpdateCombatantPos()
	local currentFight = self:GetLastFightPeriod()
	for i, member in pairs(GetPartyMembers(false)) do
		if member.id then
			local combatant = currentFight:GetCombatant(member.id)
			if combatant then
				TCombatant.UpdateRange(combatant)
			end
		end
	end
end

function TUMeter:FastTick()
	local lastPeriod = self:GetLastFightPeriod()
	self.Fight.Current:UpdateOnlyDisplayData(lastPeriod)
	self.Fight.Total:UpdateOnlyDisplayData(lastPeriod)
end

function TUMeter:SecondTick(aByRaidRebuilded)
	local lastPeriod = self:GetLastFightPeriod()

	if self.bCollectData then
		if not self.bHasChangesOnTick then
			--memory optimize
			self.Fight.Current:AddFightPeriodAndApply(self.EmptyPeriod)
			self.Fight.Total:AddFightPeriodAndApply(self.EmptyPeriod)
		else
			self.Fight.Current:AddFightPeriodAndApply(lastPeriod)
			self.Fight.Total:AddFightPeriodAndApply(lastPeriod)
		end
	else
		self.Fight.Current:UpdateCombatantFromFightPeriod(lastPeriod)
		self.Fight.Total:UpdateCombatantFromFightPeriod(lastPeriod)
	end
	
	local newFightPeriod = self:AddNewFightPeriod()
	if aByRaidRebuilded then
		self:RegenCombatantList()
	else
		newFightPeriod:CleanCopyCombantants(lastPeriod)
	end
	
	self.bHasChangesOnTick = false
	
	self:CheckClearCache()
	self:CheckMemoryPanic()
end

function TUMeter:UpdateUnitRage(anID, aValue)
	self.LastPlayersDetermination[anID] = self.CurrentPlayersDetermination[anID]
	self.CurrentPlayersDetermination[anID] = { value = aValue, timestamp = cachedGetLocalDateTimeMs() }
end

function TUMeter:GetUnitRage(anID)
	if not anID then
		return 0
	end

	local currTime = cachedGetLocalDateTimeMs()
	local determinationObj = self.CurrentPlayersDetermination[anID]
	local lastDeterminationObj = nil
	if determinationObj and currTime - determinationObj.timestamp < 60 then
		lastDeterminationObj = self.LastPlayersDetermination[anID]
		if lastDeterminationObj and currTime - lastDeterminationObj.timestamp < 1100 then
			determinationObj = self.LastPlayersDetermination[anID]
		end
	end

	if not determinationObj then
		local currDetermination = IsExistUnit(anID) and cachedGetRage(anID) or 0
		self.CurrentPlayersDetermination[anID] = { value = currDetermination, timestamp = currTime }
		return currDetermination
	end
	
	return determinationObj.value
end

function TUMeter:RagePlayerDespawned(anID)
	self.LastPlayersDetermination[anID] = nil
	self.CurrentPlayersDetermination[anID] = nil
end


function TUMeter:GetFightCombatant(anID)
	if not anID then return end
	local combatant = self:GetLastFightPeriod():GetCombatant(anID)
	if combatant then
		return combatant, false
	else
		local masterID = cachedGetFollowerMaster(anID)
		combatant = self:GetLastFightPeriod():GetCombatant(masterID)
		return combatant, true
	end
end


local function GetInfoFromCache(anID, aCache, aGetInfoFunc)
	if anID == nil then
		return nil
	end
	for _, info in ipairs(aCache) do
		if info.meterInfoID:IsEqual(anID) then
			return info
		end
	end

	local info = aGetInfoFunc(anID)
	local storeInfo = {}
	if info then
		storeInfo.meterInfoID = anID
		storeInfo.name = info.name
		storeInfo.description = info.description
		storeInfo.texture = info.texture or info.image
		
		table.insert(aCache, storeInfo)
	end
	return storeInfo
end

function TUMeter:GetTextureFromID(anID)
	local someInfo = self:GetInfoFromID(anID)
	if not someInfo then
		return nil
	end
	if not someInfo.texture and not someInfo.textureSearched then
		local typeOfID = apitype(anID)
		--BuffId AbilityId MapModifierId уже запрашивались в GetInfoFromCache
		if typeOfID == "SpellId" then
			someInfo.texture = spellLib.GetIcon( anID )
			someInfo.textureSearched = true
		else
			someInfo.textureSearched = true
		end
	end
	return someInfo.texture
end

function TUMeter:GetDescriptionFromID(anID)
	local someInfo = self:GetInfoFromID(anID)
	if not someInfo then
		return StrUnknown
	end
	if someInfo.description then
		if not someInfo.cachedDesc then
			if apitype( someInfo.description ) == "ValuedText" then
				someInfo.cachedDesc = someInfo.description:ToWString()
			else
				someInfo.cachedDesc = someInfo.description
			end
		end
		return someInfo.cachedDesc
	end
	return StrUnknown
end

function TUMeter:GetInfoFromID(anID)
	local typeOfID = apitype(anID)
	if typeOfID == "BuffId" then
		return GetInfoFromCache(anID, self.BuffInfoCache, cachedGetBuffTooltipInfo)
	elseif typeOfID == "AbilityId" then
		return GetInfoFromCache(anID, self.AbilityInfoCache, cachedGetAbilityInfo)
	elseif typeOfID == "SpellId" then
		return GetInfoFromCache(anID, self.SpellDescCache, cachedGetDescription)
	elseif typeOfID == "MapModifierId" then
		return GetInfoFromCache(anID, self.MapModifierInfoCache, cachedGetMapModifierInfo)
	else
		return nil
	end
end
--так быстрее чем в GetInfoFromID
function TUMeter:GetInfoFromParams(aParams)
	return GetInfoFromCache(aParams.buffId, self.BuffInfoCache, cachedGetBuffTooltipInfo)
	or GetInfoFromCache(aParams.spellId, self.SpellDescCache, cachedGetDescription)
	or GetInfoFromCache(aParams.abilityId, self.AbilityInfoCache, cachedGetAbilityInfo)
	or GetInfoFromCache(aParams.mapModifierId, self.MapModifierInfoCache, cachedGetMapModifierInfo)
	or nil
end

-- например, для парных боссов приходит урон и для 2го, но уже только с указанием sourceName targetName
-- или урон от вихрей на "ведьмин яр хаос" - урон без имени и ид нанёсшего будет как "?->имя игрока"
local function BuildBySourceName(aSrcName, aTargetName)
	local spellName = aSrcName and not aSrcName:IsEmpty() and aSrcName or StrUnknown
	if aTargetName then
		spellName = spellName..StrArrow..aTargetName
	end
	return spellName
end

local function BuildHealBySourceName(aSrcID, aTargetID)
	local spellName = aSrcID and cachedIsExist(aSrcID) and cachedGetName(aSrcID) or StrUnknown
	local targetName = aTargetID and cachedIsExist(aTargetID) and cachedGetName(aTargetID) or StrUnknown

	if targetName then
		spellName = spellName..StrArrow..targetName
	end
	return spellName
end

--------------------------------------------------------------------------------
-- Get information of a spell
--------------------------------------------------------------------------------
function TUMeter:GetSpellInfoFromParamsDD(aParams, anIsPet, aMode)
	local spellInfo = {}
	
	spellInfo.infoID = aParams.buffId or aParams.spellId or aParams.abilityId or aParams.mapModifierId

	if aParams.damageSource == "DamageSource_DAMAGEPOOL" then
		spellInfo.name = StrDamagePool
		spellInfo.fromBarrier = true
	elseif aParams.damageSource == "DamageSource_BARRIER" then
		spellInfo.name = StrFromBarrier
		spellInfo.fromBarrier = true
	else
		spellInfo.name = aParams.ability
		
		if spellInfo.name == nil or spellInfo.name:IsEmpty() then
			local someInfo = self:GetInfoFromParams(aParams)
			if someInfo and someInfo.name and not someInfo.name:IsEmpty() then
				spellInfo.name = someInfo.name
			else
				spellInfo.name =
				aParams.isExploit and StrExploit
				or aParams.isFall and StrFall
				or BuildBySourceName(aParams.sourceName, aParams.targetName)
				or StrUnknown
			end
		end
	end
	
	spellInfo.isPet = anIsPet
	spellInfo.petName = anIsPet and aParams.sourceName or nil
	
	spellInfo.determination = self:GetUnitRage(aParams.source)
	spellInfo.sysSubElement = enumSubElementIndex[aParams.sysSubElement]


	spellInfo.amount = aParams.amount
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
	
	spellInfo.sourceID = aParams.source
	spellInfo.targetID = aParams.target
   
	for _, combatTag in pairs( aParams.targetTags or {} ) do
		local info = combatTag:GetInfo()
		if info.isHelpful then 
			if info.name == StrDefense then
				spellInfo.defense = true
			end
		else
			if info.name == StrVulnerability then
				spellInfo.vulnerability = true
			end
		end
	end

	for _, combatTag in pairs( aParams.sourceTags or {} ) do
		local info = combatTag:GetInfo()
		if info.isHelpful then
			if info.name == StrValor then
				spellInfo.valor = true
			end
		else
			if info.name == StrWeakness then
				spellInfo.weakness = true
			end
		end
	end

	return spellInfo
end

function TUMeter:GetSpellInfoFromParamsHPS(aParams, anIsPet)
	local spellInfo = {}
	
	spellInfo.infoID = aParams.buffId or aParams.spellId or aParams.abilityId

	local someInfo = self:GetInfoFromParams(aParams)
	if someInfo and someInfo.name and not someInfo.name:IsEmpty() then
		spellInfo.name = someInfo.name
	else
		spellInfo.name =
		aParams.isFall and StrFall
		or BuildHealBySourceName(aParams.healerId, aParams.unitId)
		or StrUnknown
	end

	spellInfo.isPet = anIsPet
	if anIsPet and IsExistUnit(aParams.healerId) then
		spellInfo.petName = cachedGetName(aParams.healerId) or nil
	end
	
	spellInfo.determination = self:GetUnitRage(aParams.healerId)

	spellInfo.sysSubElement = enumSubElementIndex["ENUM_SubElement_HOLY"]

	spellInfo.amount = aParams.heal
	spellInfo.isCritical = aParams.isCritical
	spellInfo.isGlancing = aParams.isGlancing
	spellInfo.resisted = aParams.resisted
	spellInfo.runeResisted = aParams.runeResisted
	spellInfo.absorbed = aParams.absorbed
	spellInfo.overload = aParams.overload
	
	spellInfo.sourceID = aParams.healerId
	spellInfo.targetID = aParams.unitId

	return spellInfo
end
--------------------------------------------------------------------------------
-- Should we collect data the fight
--	Condition: the avatar is in combat
--------------------------------------------------------------------------------
function TUMeter:ShouldCollectData()
	if cachedIsInCombat(MyAvatarID) then
		return true
	end

	local combID
	for _, combatant in ipairs(self:GetLastFightPeriod().CombatantsList) do
		combID = TCombatant.GetID(combatant)
		if combID and cachedIsExist(combID) and TCombatant.IsClose(combatant) and (cachedIsInCombat(combID) or PlayerPetInCombat(combID)) then			
			return true
		end
	end

	return false
end

function TUMeter:CollectData(aMode, aCombatant, anIsPet, aParams)
	local spellInfo
	if aMode == enumMode.Dps or aMode == enumMode.Def then
		spellInfo = self:GetSpellInfoFromParamsDD(aParams, anIsPet)
	else
		spellInfo = self:GetSpellInfoFromParamsHPS(aParams, anIsPet)
	end
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
	if not self.bCollectData and TCombatant.IsClose(currFightCombatant) and (self:ShouldCollectData() or aParams.lethal) then
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

	if not self.bCollectData and TCombatant.IsClose(currFightCombatant) and (self:ShouldCollectData() or aParams.lethal) then
		self:Start()
	end

	return self:CollectData(enumMode.Def, currFightCombatant, aParams.source and cachedGetFollowerMaster(aParams.source) ~= nil or false, aParams)
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

	if not self.bCollectData and TCombatant.IsClose(currFightCombatant) and self:ShouldCollectData() then
		self:Start()
	end

	return self:CollectData(enumMode.Hps, currFightCombatant, isPet, aParams)
end

function TUMeter:CollectHealDataIN(aParams)
	-- Check that the healer is part of the group
	local currFightCombatant = self:GetFightCombatant(aParams.unitId)

	if not currFightCombatant then return end

	if not self.bCollectData and TCombatant.IsClose(currFightCombatant) and self:ShouldCollectData() then
		self:Start()
	end

	return self:CollectData(enumMode.IHps, currFightCombatant, aParams.healerId and cachedGetFollowerMaster(aParams.healerId) ~= nil or false, aParams)
end
--------------------------------------------------------------------------------
-- Update the data in the given mode
--------------------------------------------------------------------------------
function TUMeter:UpdateFightData(aMode, aCombatant, aSpellInfo)
	TCombatant.UpdateGlobalInfo(aCombatant, enumGlobalInfo.Determination, aMode, aSpellInfo.determination)
	
	local spellData = TCombatant.GetSpellByIdentifier(aCombatant, aMode, aSpellInfo.isPet, aSpellInfo.sysSubElement, aSpellInfo.name)
	if not spellData then
		spellData = TCombatant.AddNewSpell(aCombatant, aSpellInfo, aMode)
	end

	TCombatant.UpdateSpellDataByInfo(aCombatant, aSpellInfo, spellData, aMode)
	
	self.bHasChangesOnTick = true
end
--------------------------------------------------------------------------------
-- Update the data in the given mode
--------------------------------------------------------------------------------
function TUMeter:CollectMissedDataOnStartFight(anObjID)
	local currFightCombatant = self:GetFightCombatant(anObjID)
	if not currFightCombatant then return end

	if not self.bCollectData and TCombatant.IsClose(currFightCombatant) and self:ShouldCollectData() then
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
		--если я не в пати, а в прошлой секунде данные по группе/рейду, то не используем их
		if not raid.IsExist() and not group.IsExist() and prevPeriod:GetCombatantCount() > 1 then
			return
		end
		if prevPeriod:HasData() then
			self.Fight.Current:AddFightPeriodAndApply(prevPeriod)
			self.Fight.Total:AddFightPeriodAndApply(prevPeriod)
		end
	end
end
--------------------------------------------------------------------------------
-- Stop combat
--------------------------------------------------------------------------------
function TUMeter:Stop()
	if self.bCollectData then
		self.Fight.Current:StopFight()
		self.Fight.Total:StopFight()
	end
	self.bCollectData = false
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
	if self.Fight.Total then
		--переносим данные текущего TFightPeriod
		self:SecondTick(true)
	else
		-- инициализация
		self:RegenCombatantList()
	end
	
	self:Stop()
	
	self:PushFightFromTotalToHistory()
	self:PushFightFromCurrentToHistory()

	self.Fight.Total = TFight:CreateNewObject()
	self.Fight.Current = TFight:CreateNewObject()
end

function TUMeter:PushFightFromTotalToHistory()
	self:PushFightToHistory(self.Fight.Total, self.HistoryTotalFights)
	ResizeListByMaxSize(self.HistoryTotalFights, Settings.HistoryTotalLimit, false)
	self.Fight.Total = nil
	self.bHistoryIncresed = true
	self.bHistoryChanged = true
end

function TUMeter:PushFightFromCurrentToHistory()
	self:PushFightToHistory(self.Fight.Current, self.HistoryCurrentFights)
	ResizeListByMaxSize(self.HistoryCurrentFights, Settings.HistoryCurrentLimit, false)
	self.Fight.Current = nil
	self.bHistoryIncresed = true
	self.bHistoryChanged = true
end

function TUMeter:PushFightToHistory(aFight, aHistory)
	if not aFight then
		return
	end

	if aFight:HasData() then
		aHistory:insert_first(aFight)
	end
end

function TUMeter:CheckClearCache()
	self.ClearCacheCnt = self.ClearCacheCnt + 1
	if self.ClearCacheCnt < 300 then
		return
	end
	self.ClearCacheCnt = 0
	
	self.BuffInfoCache = {}
	self.SpellDescCache = {}
	self.AbilityInfoCache = {}
	self.MapModifierInfoCache = {}
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