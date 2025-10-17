local cachedGetLocalDateTimeMs = common.GetLocalDateTimeMs

local m_paramsListForDps = {}
local m_paramsListForDef = {}
local m_paramsListForHps = {}
local m_paramsListForIHps = {}
local m_paramsListForPets = {}

local m_mustUpdateGUI = true
local m_buffListener = {}
local m_isBtnInAOPanelNow = false
local m_mainPanelWasVisible = false
local m_detailPanelWasVisible = false
--==============================================================================
--================== AoPanelMod Compatibility ==================================
--==============================================================================

--------------------------------------------------------------------------------
-- Register UniverseMeter
--------------------------------------------------------------------------------
onMyEvent["AOPANEL_START"] = function(params)
	local SetVal = { val = StrMainBtn }
	if Settings.ShowPositionOnBtn then
		SetVal = { val = StrMainBtn..StrSpace..tostring(CurrentScoreOnMainBtn or 1) }
	end
	local params = { header =  SetVal , ptype =  "button" , size =  Settings.ShowPositionOnBtn and 50 or 30 } 
	userMods.SendEvent("AOPANEL_SEND_ADDON", { name = "UniverseMeter" , sysName = "UniverseMeter" , param = params } )
	AoPanelDetected = true
	m_isBtnInAOPanelNow = true
	DPSMeterGUI.ShowHideBtn:Hide()
end

onMyEvent["EVENT_ADDON_LOAD_STATE_CHANGED"] = function(params)
	if params.state == ADDON_STATE_NOT_LOADED and string.find(params.name, "AOPanel") then
		DPSMeterGUI.ShowHideBtn:Show()
		m_isBtnInAOPanelNow = false
	end
end

onMyEvent["EVENT_INTERFACE_TOGGLE"] = function(params)
	if params.toggleTarget == ENUM_InterfaceToggle_Target_All then
		if not m_isBtnInAOPanelNow then
			if params.hide then
				DPSMeterGUI.ShowHideBtn:Hide()
			else
				DPSMeterGUI.ShowHideBtn:Show()
			end
		end
		if params.hide then
			m_mainPanelWasVisible = DPSMeterGUI.MainPanel:IsVisible()
			m_detailPanelWasVisible = DPSMeterGUI.DetailsPanel:IsVisible()
		end
		if params.hide then			
			DPSMeterGUI.MainPanel:Hide()
			DPSMeterGUI.DetailsPanel:Hide()
		else
			if m_mainPanelWasVisible then
				DPSMeterGUI.MainPanel:Show()
			end
			if m_detailPanelWasVisible then
				DPSMeterGUI.DetailsPanel:Show()
			end
		end
	end
end

onMyEvent["AOPANEL_BUTTON_LEFT_CLICK"] = function(params)
	if params.sender == common.GetAddonName() then
		onReaction["ShowHideBtnReaction"]()
		--collectgarbage()
		--LogMemoryUsage()
	end
end

--==============================================================================
--=========================== REACTIONS ========================================
--==============================================================================

--------------------------------------------------------------------------------
-- Get the index of a spell in the spell panel
--------------------------------------------------------------------------------
function GetSpellPanelIndex(reaction)
	return tonumber(string.sub(reaction.sender, 11)) or -1
end
--------------------------------------------------------------------------------
-- Get the index of a spell in the spell panel
--------------------------------------------------------------------------------
function GetPlayerPanelIndex(reaction)
	local wtParent = reaction.widget:GetParent()
	return wtParent and tonumber(string.sub(wtParent:GetName(), 12)) or -1
end

local function CheckBoxSwitch(aParams)
	local currentVariant = aParams.widget:GetVariant()
	if currentVariant == 0 then
		aParams.widget:SetVariant(1)
	else
		aParams.widget:SetVariant(0)
	end
end

function SetCheckedForCheckBox(aWdg, aChecked)
	local currentVariant = aWdg:GetVariant()
	if aChecked then
		if currentVariant == 0 then
			aWdg:SetVariant(1)
		end
	else
		if currentVariant == 1 then
			aWdg:SetVariant(0)
		end
	end
end

local function GetCheckedForCheckBox(aWdg)
	return aWdg:GetVariant() == 1
end
--------------------------------------------------------------------------------
-- occurred when the player point a spell in the spell panel
--------------------------------------------------------------------------------
onReaction["SpellPanelOnPointing"] = function (reaction)
	if reaction.active then
		local spellInd = GetSpellPanelIndex(reaction)
		DPSMeterGUI:SetSelectedSpellIndex(spellInd)
		DPSMeterGUI:UpdateSpellDetailsList(spellInd)		
	else
		DPSMeterGUI:SetSelectedSpellIndex(nil)
		DPSMeterGUI:UpdateSpellDetailsList(nil)
	end
end
--------------------------------------------------------------------------------
-- occurred when the player press the reset button
--------------------------------------------------------------------------------
onReaction["ResetBtnReaction"] = function(reaction)
	DPSMeterGUI.HistoryPanel:Hide()
	DPSMeterGUI.SettingsPanel:Hide()
	DPSMeterGUI:Reset(true)
	m_mustUpdateGUI = true
end

onReaction["OnConfigPressed"] = function(reaction)
	if DPSMeterGUI.SettingsPanel:IsVisible() then
		DPSMeterGUI.SettingsPanel:Hide()
	else
		DPSMeterGUI.SettingsPanel:Show()
		DPSMeterGUI.HistoryPanel:Hide()
	end
end

onReaction["OnHistoryPressed"] = function(reaction)
	if DPSMeterGUI.HistoryPanel:IsVisible() then
		DPSMeterGUI.HistoryPanel:Hide()
	else
		DPSMeterGUI:UpdateHistory()
		DPSMeterGUI.HistoryPanel:Show()
		DPSMeterGUI.SettingsPanel:Hide()
	end
end

onReaction["SettingsCheckBoxPressed"] = function(reaction)
	CheckBoxSwitch(reaction)
end

onReaction["SavePressed"] = function(reaction)
	local savedData = {}
	savedData.def = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.DefCheckBox)
	savedData.dps = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.DpsCheckBox)
	savedData.hps = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.HpsCheckBox)
	savedData.ihps = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.IhpsCheckBox)
	
	if not savedData.dps and not savedData.def and not savedData.hps and not savedData.ihps then
		savedData.dps = true
	end
	
	savedData.skipDmgAndHpsOnPet = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.SkipPetCheckBox)
	savedData.skipDmgYourselfIn = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.SkipYourselfCheckBox)
	savedData.startHided = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.StartHidedCheckBox)
	savedData.showPositionOnBtn = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.ShowScoreCheckBox)
	savedData.scaleFonts = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.ScaleFontsCheckBox)
	
	local parsedCombantants = DPSMeterGUI.SettingsPanel.MaxCombatantTextEdit:GetText():ToInt()
	if not parsedCombantants then
		parsedCombantants = Settings.MaxCombatants 
	end
	
	savedData.maxCombatants = parsedCombantants
	
	userMods.SetGlobalConfigSection( "UniverseMeterSettings", savedData )
	common.StateReloadManagedAddon(common.GetAddonSysName())
	
	DPSMeterGUI.SettingsPanel:Hide()
end

--------------------------------------------------------------------------------
-- occurred when the player press the close button in the main panel
--------------------------------------------------------------------------------
onReaction["CloseMainPanelBtnReaction"] = function(reaction)
	onReaction["ShowHideBtnReaction"]()
end
--------------------------------------------------------------------------------
-- occurred when the player click a player in the player list
--------------------------------------------------------------------------------
onReaction["PlayerInfoButtonDown"] = function(reaction) 
	local playerIndex = GetPlayerPanelIndex(reaction)
	if playerIndex then
		DPSMeterGUI:PrepareShowDetails(playerIndex)
		DPSMeterGUI.DetailsPanel:Show()
		DPSMeterGUI:UpdateValues()
	end
end

onReaction["AllTimePressed"] = function(reaction)
	DPSMeterGUI:SwitchToAll()
end

onReaction["UpdateTimeLapsePressed"] = function(reaction)
	DPSMeterGUI:CreateTimeLapse()
end

onReaction["DpsTimeLapsePressed"] = function(reaction)
	local wdgName = reaction.widget:GetName()
	wdgName = string.gsub(wdgName, "DpsBtn", "")
	DPSMeterGUI:SwitchToTimeLapseElement(tonumber(wdgName))
end

onReaction["historyElementClicked"] = function(reaction)
	local wdgName = reaction.widget:GetName()
	if string.find(wdgName, "HistoryCurrentBtn") then
		local wdgNum = string.gsub(wdgName, "HistoryCurrentBtn", "")
		DPSMeterGUI:HistoryCurrentSelected(tonumber(wdgNum))
	elseif string.find(wdgName, "HistoryTotalBtn") then
		local wdgNum = string.gsub(wdgName, "HistoryTotalBtn", "")
		DPSMeterGUI:HistoryTotalSelected(tonumber(wdgNum))
	end
	DPSMeterGUI:UpdateValues()
	DPSMeterGUI.HistoryPanel:Hide()
end

--------------------------------------------------------------------------------
-- occurred when the player press the close button of the spell panel
--------------------------------------------------------------------------------
onReaction["CloseSpellInfoPanelBtnReaction"] = function(reaction)
	DPSMeterGUI.DetailsPanel:Hide()
	DPSMeterGUI:DetailsClosed()
end
--------------------------------------------------------------------------------
-- occurred when the player click on the fight dropdown button in the main panel
--------------------------------------------------------------------------------
onReaction["GetFightBtnReaction"] = function(reaction)
	DPSMeterGUI.HistoryPanel:Hide()
	DPSMeterGUI.SettingsPanel:Hide()
	local wtParent = reaction.widget:GetParent()
	if wtParent:IsEqual(DPSMeterGUI.MainPanel.FightBtn.Widget) then
		DPSMeterGUI:SwapFight()
	elseif wtParent:IsEqual(DPSMeterGUI.DetailsPanel.FightBtn.Widget) then
		DPSMeterGUI:SwapFightDetailsPanel()
	end	
end
--------------------------------------------------------------------------------
-- occurred when the player click on the mode dropdown button in the main panel
--------------------------------------------------------------------------------
onReaction["GetModeBtnReaction"] = function(reaction)
	DPSMeterGUI.HistoryPanel:Hide()
	DPSMeterGUI.SettingsPanel:Hide()
	local wtParent = reaction.widget:GetParent()
	if wtParent:IsEqual(DPSMeterGUI.MainPanel.ModeBtn.Widget) then
		DPSMeterGUI:SwapMode()
	elseif wtParent:IsEqual(DPSMeterGUI.DetailsPanel.ModeBtn.Widget) then
		DPSMeterGUI:SwapDetailsMode()
	end	
end
--------------------------------------------------------------------------------
-- occurred when the player click on the "D" button in order to show or hide the main panel
--------------------------------------------------------------------------------
onReaction["ShowHideBtnReaction"] = function(reaction)
	if DnD:IsDragging() then return end
	if DPSMeterGUI.MainPanel:IsVisible() then
		DPSMeterGUI.HistoryPanel:Hide()
		DPSMeterGUI.SettingsPanel:Hide()
		DPSMeterGUI.MainPanel:Hide()
		DPSMeterGUI.DetailsPanel:Hide()
		DPSMeterGUI:DetailsClosed()
	else
		DPSMeterGUI.MainPanel:Show()
		DPSMeterGUI:UpdateValues()
	end
end

onReaction["OnMinusBtnPointing"] = function(reaction)
	DPSMeterGUI:MinusPlusBtnPointing(reaction)
end

onReaction["MinusPressed"] = function(reaction)
	DPSMeterGUI:MinusPressed()
end

onReaction["OnPlusBtnPointing"] = onReaction["OnMinusBtnPointing"]

onReaction["PlusPressed"] = function(reaction)
	DPSMeterGUI:PlusPressed()
end

--==============================================================================
--=========================== EVENTS ===========================================
--==============================================================================

onMyEvent["EVENT_UNITS_CHANGED"] = function(aParams)
	for _, objID in ipairs(aParams.despawned) do
		if objID then
			UnsubscribeListeners(objID)
			
			DPSMeterGUI.DPSMeter:RagePlayerDespawned(objID)
			
			UpdateBuffsStateByDespawn(objID)
		end
	end
	FabricDestroyUnused()
	for _, objID in ipairs(aParams.spawned) do
		FabricMakePlayerInfo(objID, m_buffListener)
	end
end

onMyEvent["EVENT_OBJECT_BUFF_ADDED"] = function(aParams)
	BuffAdded(aParams)
end

onMyEvent["EVENT_OBJECT_BUFF_REMOVED"] = function(aParams)
	BuffRemoved(aParams)
end

onMyEvent["EVENT_UNIT_RAGE_CHANGED"] = function(aParams)
	RageChanged(aParams)
end

--------------------------------------------------------------------------------
-- Event: Group & raid / Appeared & Disappeared
--------------------------------------------------------------------------------
onMyEvent["EVENT_GROUP_APPEARED"] = function()
	DPSMeterGUI:Reset()
	ReRegisterEvents()
	
	m_mustUpdateGUI = true
end

onMyEvent["EVENT_RAID_APPEARED"] = onMyEvent["EVENT_GROUP_APPEARED"]
onMyEvent["EVENT_RAID_DISAPPEARED"] = onMyEvent["EVENT_GROUP_APPEARED"]
onMyEvent["EVENT_GROUP_DISAPPEARED"] = onMyEvent["EVENT_GROUP_APPEARED"]
onMyEvent["EVENT_GROUP_CONVERTED"] = onMyEvent["EVENT_GROUP_APPEARED"]
--------------------------------------------------------------------------------
-- Event: Member removed
--------------------------------------------------------------------------------
onMyEvent["EVENT_GROUP_MEMBER_REMOVED"] = function(params)
	DPSMeterGUI.DPSMeter:RemoveCombatant(params)
		
	ReRegisterEvents()
	
	m_mustUpdateGUI = true
end

onMyEvent["EVENT_RAID_MEMBER_REMOVED"] = onMyEvent["EVENT_GROUP_MEMBER_REMOVED"]
--------------------------------------------------------------------------------
-- Event: Update list
--------------------------------------------------------------------------------
onMyEvent["EVENT_GROUP_MEMBER_ADDED"] = function()
	DPSMeterGUI.DPSMeter:RegenCombatantList()
	ReRegisterEvents()
	
	m_mustUpdateGUI = true
end

onMyEvent["EVENT_RAID_MEMBER_ADDED"] = onMyEvent["EVENT_GROUP_MEMBER_ADDED"]
onMyEvent["EVENT_GROUP_MEMBER_CHANGED"] = onMyEvent["EVENT_GROUP_MEMBER_ADDED"]
onMyEvent["EVENT_RAID_MEMBER_CHANGED"] = onMyEvent["EVENT_GROUP_MEMBER_ADDED"]
onMyEvent["EVENT_RAID_CHANGED"] = onMyEvent["EVENT_GROUP_MEMBER_ADDED"]

onMyEvent["EVENT_OBJECT_COMBAT_STATUS_CHANGED"] = function(aParams)
	if aParams.inCombat and not DPSMeterGUI.DPSMeter.bCollectData then
		DPSMeterGUI.DPSMeter:CollectMissedDataOnStartFight(aParams.objectId)
	end
end

--------------------------------------------------------------------------------
-- Event: EVENT_SECOND_TIMER
--------------------------------------------------------------------------------
onMyEvent["EVENT_SECOND_TIMER"] = function(aParams)
	OnEventSecondZatichka()
	UpdateBuffsStateByTime()
	
	DPSMeterGUI.DPSMeter:SecondTick()
	DPSMeterGUI.DPSMeter:UpdateCombatantPos()

	if DPSMeterGUI.DPSMeter.bHistoryChanged then
		DPSMeterGUI:UpdateHistory(true)
		DPSMeterGUI.DPSMeter.bHistoryChanged = false
	end
	
	if DPSMeterGUI.DPSMeter.bCollectData then
		if DPSMeterGUI.DPSMeter:ShouldCollectData() then
			DPSMeterGUI.DPSMeter:ResetOffBattleTime()
		else
			local offBattleTime = DPSMeterGUI.DPSMeter:UpdateOffBattleTime()
			local maxOffBattleTime = Settings.MaxOffBattleTime
			if offBattleTime > maxOffBattleTime then
				DPSMeterGUI.DPSMeter:Stop()
			end
		end
		DPSMeterGUI:UpdateValues()
	elseif m_mustUpdateGUI then
		DPSMeterGUI:UpdateValues()
	end
	
	m_mustUpdateGUI = false
end

function FastUpdate()
	if DPSMeterGUI.DPSMeter.bCollectData and DPSMeterGUI:GetActiveFight():GetCombatantCount() <= Settings.HeavyMode_MaxCombatant then
		DPSMeterGUI.DPSMeter:FastTick()
		DPSMeterGUI:UpdateValues()
	end
end
--------------------------------------------------------------------------------
-- Event: EVENT_UNIT_DAMAGE_RECEIVED
--------------------------------------------------------------------------------
function DpsEventReceived(aParams)
	DPSMeterGUI.DPSMeter:CollectDamageDealedData(aParams)
end

function DefEventReceived(aParams)
	DPSMeterGUI.DPSMeter:CollectDamageReceivedData(aParams)
end
--------------------------------------------------------------------------------
-- Event: EVENT_HEALING_RECEIVED
--------------------------------------------------------------------------------
function HpsEventReceived(aParams)
	DPSMeterGUI.DPSMeter:CollectHealData(aParams)
end 

function IHpsEventReceived(aParams)
	DPSMeterGUI.DPSMeter:CollectHealDataIN(aParams)
end 


onMyEvent["EVENT_UNIT_FOLLOWERS_LIST_CHANGED"] = function(aParams)
	if m_paramsListForPets[aParams.id] then
		ReloadPet(aParams)
	end
end

function PlayerAddBuff(aPlayerID, aFindedObj)
	CurrentBuffsState[aFindedObj.ind][aPlayerID] = {
		info = aFindedObj, 
		removeTime = 0,
		removeAfterDeath = false
		}
end

function PlayerRemoveBuff(aPlayerID, aFindedObj)
	local buffState = CurrentBuffsState[aFindedObj.ind][aPlayerID]
	if buffState then
		buffState.removeTime = cachedGetLocalDateTimeMs()
		buffState.removeAfterDeath = not object.IsExist(aPlayerID) or object.IsDead(aPlayerID)
	end
end

function UpdateBuffsStateByDespawn(anObjID)
	local currTime = cachedGetLocalDateTimeMs()
	local buffState
	for _, buffStates in ipairs(CurrentBuffsState) do
		buffState = buffStates[anObjID]
		if buffState then
			if buffState.removeTime == 0 then
				buffState.removeTime = currTime
			end
			buffState.removeAfterDeath = true
		end
	end
end

function UpdateBuffsStateByTime()
	local currTime = cachedGetLocalDateTimeMs()
	for i, value in ipairs(CurrentBuffsState) do
		for playerID, buffState in pairs(value) do
			if buffState.removeTime > 0 and currTime - buffState.removeTime > Settings.WaitBuffAfterDeathTime then
				CurrentBuffsState[i][playerID] = nil
			end
		end
	end
end

function PlayerRageChanged(aPlayerID, aRage)
	DPSMeterGUI.DPSMeter:UpdateUnitRage(aPlayerID, aRage)
end




function ReloadPet(aParams)
	local unitList = GetPartyMembers(false)
	
	local unitListWithPets = GetListWithPets(unitList)
	local deleteParams = nil
	local newParams = nil
	
	if Settings.ModeDPS then 
		local paramsListForDps = BuildEventParamsForDps(unitListWithPets)
		deleteParams, newParams = CompareArrays(m_paramsListForDps, paramsListForDps)
		UnRegisterEventHandlerWithParams("EVENT_UNIT_DAMAGE_RECEIVED", DpsEventReceived, deleteParams)
		RegisterEventHandlerWithParams("EVENT_UNIT_DAMAGE_RECEIVED", DpsEventReceived, newParams)
		
		m_paramsListForDps = paramsListForDps
	end
	
	if Settings.ModeHPS then
		local paramsListForHps = BuildEventParamsForHps(unitListWithPets)
		deleteParams, newParams = CompareArrays(m_paramsListForHps, paramsListForHps)
		UnRegisterEventHandlerWithParams("EVENT_HEALING_RECEIVED", HpsEventReceived, deleteParams)
		RegisterEventHandlerWithParams("EVENT_HEALING_RECEIVED", HpsEventReceived, newParams)

		m_paramsListForHps = paramsListForHps
	end
end

function ReRegisterEvents()
	local unitList = GetPartyMembers(false)
	local deleteParams = nil
	local newParams = nil
	
	m_paramsListForPets = BuildEventParamsForPetChanged(unitList)
	
	local unitListWithPets = GetListWithPets(unitList)
		
	if Settings.ModeDEF then 
		local paramsListForDef = BuildEventParamsForDef(unitList)
		deleteParams, newParams = CompareArrays(m_paramsListForDef, paramsListForDef)
		UnRegisterEventHandlerWithParams("EVENT_UNIT_DAMAGE_RECEIVED", DefEventReceived, deleteParams)
		RegisterEventHandlerWithParams("EVENT_UNIT_DAMAGE_RECEIVED", DefEventReceived, newParams)
		m_paramsListForDef = paramsListForDef
	end
	if Settings.ModeIHPS then 
		local paramsListForIHps = BuildEventParamsForIHps(unitList)
		deleteParams, newParams = CompareArrays(m_paramsListForIHps, paramsListForIHps)
		UnRegisterEventHandlerWithParams("EVENT_HEALING_RECEIVED", IHpsEventReceived, deleteParams)
		RegisterEventHandlerWithParams("EVENT_HEALING_RECEIVED", IHpsEventReceived, newParams)
		m_paramsListForIHps = paramsListForIHps
	end
	if Settings.ModeDPS then 
		local paramsListForDps = BuildEventParamsForDps(unitListWithPets)
		deleteParams, newParams = CompareArrays(m_paramsListForDps, paramsListForDps)
		UnRegisterEventHandlerWithParams("EVENT_UNIT_DAMAGE_RECEIVED", DpsEventReceived, deleteParams)
		RegisterEventHandlerWithParams("EVENT_UNIT_DAMAGE_RECEIVED", DpsEventReceived, newParams)
		m_paramsListForDps = paramsListForDps
	end
	if Settings.ModeHPS then 
		local paramsListForHps = BuildEventParamsForHps(unitListWithPets)
		deleteParams, newParams = CompareArrays(m_paramsListForHps, paramsListForHps)
		UnRegisterEventHandlerWithParams("EVENT_HEALING_RECEIVED", HpsEventReceived, deleteParams)
		RegisterEventHandlerWithParams("EVENT_HEALING_RECEIVED", HpsEventReceived, newParams)
		m_paramsListForHps = paramsListForHps
	end
end

local function GetFilterID(aFilter)
	for _, v in pairs(aFilter) do
		return v
	end
end

local function IsFilterExist(anArr, aFilter)
	local searchFilterID = GetFilterID(aFilter)
	for _, filter in ipairs(anArr) do
		if searchFilterID == GetFilterID(filter) then
			return true
		end
	end
	return false
end

function CompareArrays(anArrOld, anArrNew)
	local deleted = {}
	for _, filter in ipairs(anArrOld) do
		if not IsFilterExist(anArrNew, filter) then
			table.insert(deleted, filter)
		end
	end
	
	local new = {}
	for _, filter in ipairs(anArrNew) do
		if not IsFilterExist(anArrOld, filter) then
			table.insert(new, filter)
		end
	end
	
	return deleted, new
end

function GetListWithPets(anUnitList)
--наймы на островах одновременно члены группы и петы
	local unitListWithPets = {}
	for _, member in ipairs(anUnitList) do
		if member.id then
			unitListWithPets[member.id] = true
			local followers = unit.GetFollowers(member.id)
			if followers then
				for _, followerID in ipairs(followers) do
					unitListWithPets[followerID] = true
				end
			end
		end
	end
	return unitListWithPets
end

function BuildEventParamsForDps(anUnitList)
	local paramsListForDps = {}
	for unitID, _ in pairs(anUnitList) do	
		table.insert(paramsListForDps, {source = unitID})
	end
	return paramsListForDps
end

function BuildEventParamsForHps(anUnitList)
	local paramsListForHps = {}
	for unitID, _ in pairs(anUnitList) do	
		table.insert(paramsListForHps, {healerId = unitID})
	end
	return paramsListForHps
end

function BuildEventParamsForDef(anUnitList)
	local paramsListForDef = {}
	for _, member in ipairs(anUnitList) do
		if member.id then
			table.insert(paramsListForDef, {target = member.id})
		end
	end
	return paramsListForDef
end

function BuildEventParamsForIHps(anUnitList)
	local paramsListForIHps = {}
	for _, member in ipairs(anUnitList) do
		if member.id then
			table.insert(paramsListForIHps, {unitId = member.id})
		end
	end
	return paramsListForIHps
end

function BuildEventParamsForPetChanged(anUnitList)
	local paramsListForPets = {}
	for _, member in ipairs(anUnitList) do
		if member.id then
			paramsListForPets[member.id] = true
		end
	end
	return paramsListForPets
end






function GlobalInit()
	InitMyAvatarInfo()
	DPSMeterGUI:Reset()
	
	if AoPanelDetected then 
		DPSMeterGUI.ShowHideBtn:Hide()
	end

	m_buffListener.listenerAddBuff = PlayerAddBuff
	m_buffListener.listenerRemoveBuff = PlayerRemoveBuff
	m_buffListener.listenerRage = PlayerRageChanged
	
	local unitList = avatar.GetUnitList()
	table.insert(unitList, MyAvatarID)
	for _, unitID in ipairs(unitList) do
		FabricMakePlayerInfo(unitID, m_buffListener)
	end

	-- Register now the other events & reactions
	RegisterEventHandlers(onMyEvent)
	RegisterReactionHandlers(onReaction)
	ReRegisterEvents()
	
	
	StartTimer(FastUpdate, Settings.FastUpdateInterval)
	
	onMyEvent["EVENT_SECOND_TIMER"]()
end