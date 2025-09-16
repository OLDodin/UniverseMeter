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
onGenEvent["AOPANEL_START"] = function(params)
	local SetVal = { val = StrMainBtn } 
	local params = { header =  SetVal , ptype =  "button" , size =  Settings.ShowPositionOnBtn and 50 or 30 } 
	userMods.SendEvent("AOPANEL_SEND_ADDON", { name = "UniverseMeter" , sysName = "UniverseMeter" , param = params } )
	AoPanelDetected = true
	m_isBtnInAOPanelNow = true
	DPSMeterGUI.ShowHideBtn:DnDHide()
	CurrentScoreOnMainBtn = 0
end

onGenEvent["EVENT_ADDON_LOAD_STATE_CHANGED"] = function(params)
	if params.state == ADDON_STATE_NOT_LOADED and string.find(params.name, "AOPanel") then
		DPSMeterGUI.ShowHideBtn:DnDShow()
		m_isBtnInAOPanelNow = false
	end
end

onGenEvent["EVENT_INTERFACE_TOGGLE"] = function(params)
	if params.toggleTarget == ENUM_InterfaceToggle_Target_All then
		if not m_isBtnInAOPanelNow then
			if params.hide then
				DPSMeterGUI.ShowHideBtn:DnDHide()
			else
				DPSMeterGUI.ShowHideBtn:DnDShow()
			end
		end
		if params.hide then
			m_mainPanelWasVisible = DPSMeterGUI.MainPanel:IsVisible()
			m_detailPanelWasVisible = DPSMeterGUI.DetailsPanel:IsVisible()
		end
		if params.hide then			
			DPSMeterGUI.MainPanel:DnDHide()
			DPSMeterGUI.DetailsPanel:DnDHide()
		else
			if m_mainPanelWasVisible then
				DPSMeterGUI.MainPanel:DnDShow()
			end
			if m_detailPanelWasVisible then
				DPSMeterGUI.DetailsPanel:DnDShow()
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
		DPSMeterGUI:SetSelectedSpellIndex(GetSpellPanelIndex(reaction))		
	else
		DPSMeterGUI:SetSelectedSpellIndex(nil)
	end
	DPSMeterGUI:UpdateValues()
end
--------------------------------------------------------------------------------
-- occurred when the player press the reset button
--------------------------------------------------------------------------------
onReaction["ResetBtnReaction"] = function(reaction)
	DPSMeterGUI:Reset(true)
	m_mustUpdateGUI = true
end

onReaction["OnConfigPressed"] = function(reaction)
	if DPSMeterGUI.SettingsPanel:IsVisible() then
		DPSMeterGUI.SettingsPanel:DnDHide()
	else
		DPSMeterGUI.SettingsPanel:DnDShow()
	end
end

onReaction["OnHistoryPressed"] = function(reaction)
	if DPSMeterGUI.HistoryPanel:IsVisible() then
		DPSMeterGUI.HistoryPanel:DnDHide()
	else
		DPSMeterGUI:UpdateHistory()
		DPSMeterGUI.HistoryPanel:DnDShow()
	end
end

onReaction["CloseHistoryPanelBtnReaction"] = function(reaction)
	DPSMeterGUI.HistoryPanel:DnDHide()
end

onReaction["CloseSettingsPanelBtnReaction"] = function(reaction)
	DPSMeterGUI.SettingsPanel:DnDHide()
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
	savedData.skipDmgAndHpsOnPet = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.SkipPetCheckBox)
	savedData.skipDmgYourselfIn = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.SkipYourselfCheckBox)
	savedData.startHided = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.StartHidedCheckBox)
	savedData.сollectTotalTimelapse = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.TotalTimelapseCheckBox)
	savedData.showPositionOnBtn = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.ShowScoreCheckBox)
	savedData.scaleFonts = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.ScaleFontsCheckBox)
	
	local parsedCombantants = DPSMeterGUI.SettingsPanel.MaxCombatantTextEdit:GetText():ToInt()
	if not parsedCombantants then
		parsedCombantants = Settings.MaxCombatants 
	end
	
	savedData.maxCombatants = parsedCombantants
	
	userMods.SetGlobalConfigSection( "UniverseMeterSettings", savedData )
	common.StateReloadManagedAddon(common.GetAddonSysName())
	
	DPSMeterGUI.SettingsPanel:DnDHide()
end

--------------------------------------------------------------------------------
-- occurred when the player press the close button in the main panel
--------------------------------------------------------------------------------
onReaction["CloseMainPanelBtnReaction"] = function(reaction)
	DPSMeterGUI.MainPanel:DnDHide()
	DPSMeterGUI.DetailsPanel:DnDHide()
	DPSMeterGUI:DetailsClosed()
end
--------------------------------------------------------------------------------
-- occurred when the player click a player in the player list
--------------------------------------------------------------------------------
onReaction["PlayerInfoButtonDown"] = function(reaction) 
	local playerIndex = GetPlayerPanelIndex(reaction)
	if playerIndex then
		DPSMeterGUI:PrepareShowDetails(playerIndex)
		DPSMeterGUI.DetailsPanel:DnDShow()
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
end

--------------------------------------------------------------------------------
-- occurred when the player press the close button of the spell panel
--------------------------------------------------------------------------------
onReaction["CloseSpellInfoPanelBtnReaction"] = function(reaction)
	DPSMeterGUI.DetailsPanel:DnDHide()
	DPSMeterGUI:DetailsClosed()
end
--------------------------------------------------------------------------------
-- occurred when the player click on the fight dropdown button in the main panel
--------------------------------------------------------------------------------
onReaction["GetFightBtnReaction"] = function(reaction)
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
		DPSMeterGUI.MainPanel:DnDHide()
		DPSMeterGUI.DetailsPanel:DnDHide()
		DPSMeterGUI:DetailsClosed()
	else
		DPSMeterGUI.MainPanel:DnDShow()
		DPSMeterGUI:UpdateValues()
	end
end

--==============================================================================
--=========================== EVENTS ===========================================
--==============================================================================

onMyEvent["EVENT_UNITS_CHANGED"] = function(aParams)
	for _, objID in ipairs(aParams.despawned) do
		if objID then
			UnsubscribeListeners(objID)
			
			for i, buffState in ipairs(CurrentBuffsState) do
				buffState[objID] = nil
			end
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

onMyEvent["EVENT_OBJECT_BUFF_CHANGED"] = function(aParams)
	BuffChanged(aParams)
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

	DPSMeterGUI:UpdateScoreOnMainBtn()
	
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
	DPSMeterGUI.DPSMeter:CollectUnitsRage()
end
--------------------------------------------------------------------------------
-- Event: EVENT_UNIT_DAMAGE_RECEIVED
--------------------------------------------------------------------------------
function DpsEventReceived(aParams)
	if not Settings.ModeDPS then return end
	DPSMeterGUI.DPSMeter:CollectDamageDealedData(aParams)
end

function DefEventReceived(aParams)
	if not Settings.ModeDEF then return end

	DPSMeterGUI.DPSMeter:CollectDamageReceivedData(aParams)
end
--------------------------------------------------------------------------------
-- Event: EVENT_HEALING_RECEIVED
--------------------------------------------------------------------------------
function HpsEventReceived(aParams)
	if not Settings.ModeHPS then return end
	DPSMeterGUI.DPSMeter:CollectHealData(aParams)
end 

function IHpsEventReceived(aParams)
	if not Settings.ModeIHPS then return end
	DPSMeterGUI.DPSMeter:CollectHealDataIN(aParams)
end 

function ReloadPet(aParams)
	ReRegisterEvents()
end

--------------------------------------------------------------------------------
-- Event: EVENT_AVATAR_CREATED
--------------------------------------------------------------------------------
onGenEvent["EVENT_AVATAR_CREATED"] = function(params)
	GlobalReset()
end






local m_paramsListForDps = {}
local m_paramsListForDef = {}
local m_paramsListForHps = {}
local m_paramsListForIHps = {}
local m_paramsListForPets = {}

function ReRegisterEvents()
	UnRegisterEventHandlersNew("EVENT_HEALING_RECEIVED", HpsEventReceived, m_paramsListForHps)
	UnRegisterEventHandlersNew("EVENT_HEALING_RECEIVED", IHpsEventReceived, m_paramsListForIHps)
	UnRegisterEventHandlersNew("EVENT_UNIT_DAMAGE_RECEIVED", DpsEventReceived, m_paramsListForDps)
	UnRegisterEventHandlersNew("EVENT_UNIT_DAMAGE_RECEIVED", DefEventReceived , m_paramsListForDef)
	UnRegisterEventHandlersNew("EVENT_UNIT_FOLLOWERS_LIST_CHANGED", ReloadPet, m_paramsListForPets)


	local unitList = GetPartyMembers()
	BuildEventParamsForDef(unitList)
	BuildEventParamsForIHps(unitList)
	BuildEventParamsForPetChanged(unitList)
	--наймы на островах одновременно члены группы и петы
	local unitListWithPets = GetListWithPets(unitList)
	BuildEventParamsForDps(unitListWithPets)
	BuildEventParamsForHps(unitListWithPets)

	RegisterEventHandlersNew("EVENT_HEALING_RECEIVED", HpsEventReceived, m_paramsListForHps)
	RegisterEventHandlersNew("EVENT_HEALING_RECEIVED", IHpsEventReceived, m_paramsListForIHps)
	RegisterEventHandlersNew("EVENT_UNIT_DAMAGE_RECEIVED", DpsEventReceived, m_paramsListForDps)
	RegisterEventHandlersNew("EVENT_UNIT_DAMAGE_RECEIVED", DefEventReceived , m_paramsListForDef)
	RegisterEventHandlersNew("EVENT_UNIT_FOLLOWERS_LIST_CHANGED", ReloadPet, m_paramsListForPets)
end

function GetListWithPets(anUnitList)
	local unitListWithPets = {}
	for _, member in pairs(anUnitList) do
		if member.id then
			unitListWithPets[member.id] = true
			local followers = unit.GetFollowers(member.id)
			if followers then
				for _, followerID in pairs(followers) do
					unitListWithPets[followerID] = true
				end
			end
		end
	end
	return unitListWithPets
end

function BuildEventParamsForDps(anUnitList)
	m_paramsListForDps = {}
	for unitID, _ in pairs(anUnitList) do	
		table.insert(m_paramsListForDps, {source = unitID})
	end
end

function BuildEventParamsForHps(anUnitList)
	m_paramsListForHps = {}
	for unitID, _ in pairs(anUnitList) do	
		table.insert(m_paramsListForHps, {healerId = unitID})
	end
end

function BuildEventParamsForDef(anUnitList)
	m_paramsListForDef = {}
	for _, member in pairs(anUnitList) do
		if member.id then
			table.insert(m_paramsListForDef, {target = member.id})
		end
	end
end

function BuildEventParamsForIHps(anUnitList)
	m_paramsListForIHps = {}
	for _, member in pairs(anUnitList) do
		if member.id then
			table.insert(m_paramsListForIHps, {unitId = member.id})
		end
	end
end

function BuildEventParamsForPetChanged(anUnitList)
	m_paramsListForPets = {}
	for _, member in pairs(anUnitList) do
		if member.id then
			table.insert(m_paramsListForPets, {id = member.id})
		end
	end
end

function UnRegisterEventHandlersNew(anEvent, aHandler, aParamList)
	if aParamList then 
		for _, params in ipairs(aParamList) do 
			common.UnRegisterEventHandler(aHandler, anEvent, params)
		end
	else 
		common.UnRegisterEventHandler(aHandler, anEvent)
	end
end

function RegisterEventHandlersNew(anEvent, aHandler, aParamList)
	if aParamList then 
		for _, params in ipairs(aParamList) do 
			common.RegisterEventHandler(aHandler, anEvent, params)
		end
	else 
		common.RegisterEventHandler(aHandler, anEvent)
	end
end


function GlobalReset()
	localization = GetGameLocalization()
	if not common.GetAddonRelatedTextGroup(localization, true) then
		localization = "eng"
	end
	
	local savedData = userMods.GetGlobalConfigSection("UniverseMeterSettings")
	if savedData then
		Settings.ModeDPS  = savedData.dps
		Settings.ModeHPS  = savedData.hps
		Settings.ModeDEF  = savedData.def
		Settings.ModeIHPS = savedData.ihps
		Settings.SkipDmgAndHpsOnPet = savedData.skipDmgAndHpsOnPet
		Settings.SkipDmgYourselfIn = savedData.skipDmgYourselfIn
		Settings.StartHided = savedData.startHided
		Settings.CollectTotalTimelapse = savedData.сollectTotalTimelapse
		Settings.ShowPositionOnBtn = savedData.showPositionOnBtn
		Settings.ScaleFonts = savedData.scaleFonts
		if savedData.maxCombatants then
			Settings.MaxCombatants = savedData.maxCombatants
		end
	end

	StrAllTime = GetTextLocalized("StrAllTime")
	
	FillBuffCheckList()
	InitBuffConditionMgr()
	
	-- Create the DPSMeter here
	DPSMeterGUI = TUMeterGUI:CreateNewObject(TUMeter:CreateNewObject())
	DPSMeterGUI:Init()
	
	
	m_buffListener.listenerAddBuff = PlayerAddBuff
	m_buffListener.listenerRemoveBuff = PlayerRemoveBuff
	m_buffListener.listenerChangeBuff = PlayerChangeBuff
	m_buffListener.listenerRage = PlayerRageChanged
	
	local unitList = avatar.GetUnitList()
	table.insert(unitList, avatar.GetId())
	for _, unitID in ipairs(unitList) do
		FabricMakePlayerInfo(unitID, m_buffListener)
	end

	if AoPanelDetected then DPSMeterGUI.ShowHideBtn:DnDHide() end
	
	if Settings.StartHided then
		DPSMeterGUI.MainPanel:DnDHide()
	end

	-- Register now the other events & reactions
	ReRegisterEvents()
	RegisterEventHandlers(onMyEvent)
	RegisterReactionHandlers(onReaction)

	
	
	StartTimer(FastUpdate, Settings.FastUpdateInterval)
end

function PlayerAddBuff(aBuffDynamicInfo, aPlayerID, aFindedObj)
	CurrentBuffsState[aFindedObj.ind][aPlayerID] = aFindedObj
	CurrentBuffsStateByTime[aFindedObj.ind][aPlayerID] = {
		info = aFindedObj, 
		buffFinishedTime_h = aBuffDynamicInfo.remainingMs + common.GetLocalDateTimeMs(), 
		removeAfterDeath = false
		}
end

function PlayerRemoveBuff(aBuffID, aPlayerID, aFindedObj)
	CurrentBuffsState[aFindedObj.ind][aPlayerID] = nil
	
	if not object.IsExist(aPlayerID) or object.IsDead(aPlayerID) then
		local buffState = CurrentBuffsStateByTime[aFindedObj.ind][aPlayerID]
		if buffState then
			buffState.removeAfterDeath = true
			buffState.removeTime = common.GetLocalDateTimeMs()
		end
	end
end

function PlayerChangeBuff(aPlayerID, aBuffDynamicInfo, aFindedObj)
	CurrentBuffsStateByTime[aFindedObj.ind][aPlayerID] = {
		info = aFindedObj, 
		buffFinishedTime_h = aBuffDynamicInfo.remainingMs + common.GetLocalDateTimeMs(), 
		removeAfterDeath = false
		}
end



function PlayerRageChanged(aPlayerID, aRage)
	DPSMeterGUI.DPSMeter:UpdateUnitRage(aPlayerID, aRage)
end

function FillBuffCheckList()
	local index = 1
	for i = 1, 3 do
		table.insert(BuffCheckList, {name = GetTextLocalized("HpsBuff"..i), ind = index, forSrc = true, forHps = true})
		index = index + 1
	end
	for i = 1, 3 do
		table.insert(BuffCheckList, {name = GetTextLocalized("DpsHpsBuff"..i), ind = index, forSrc = true, forHps = true, forDps = true})
		index = index + 1
	end
	for i = 1, 1 do
		table.insert(BuffCheckList, {name = GetTextLocalized("DpsBuff"..i), ind = index, forSrc = true, forDps = true})
		index = index + 1
	end
	DPSHPSTYPES = 7
	DEFTYPES = 25
	for i = 1, 1 do
		table.insert(BuffCheckList, {name = GetTextLocalized("IHpsBuff"..i), ind = index, forTarget = true, forHps = true})
		index = index + 1
	end
	for i = 1, 24 do
		table.insert(BuffCheckList, {name = GetTextLocalized("DefBuff"..i), ind = index, forTarget = true, forDps = true})
		index = index + 1
	end
	
	
	for i = 1, DPSHPSTYPES do
		TitleCustomDpsBuffType[i] = BuffCheckList[i].name
	end
	for i = 1, DEFTYPES do
		TitleCustomDefBuffType[i] = BuffCheckList[DPSHPSTYPES + i].name
	end
	
	for i = 1, index-1 do
		CurrentBuffsState[i] = {}
		CurrentBuffsStateByTime[i] = {}
	end
end