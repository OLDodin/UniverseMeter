local m_mustUpdateGUI = true
local m_buffListener = {}

--==============================================================================
--================== AoPanelMod Compatibility ==================================
--==============================================================================

--------------------------------------------------------------------------------
-- Register AoUMeter
--------------------------------------------------------------------------------
onGenEvent["AOPANEL_START"] = function(params)
	local SetVal = { val =  userMods.ToWString("D") } 
	local params = { header =  SetVal , ptype =  "button" , size = 30 } 
	userMods.SendEvent("AOPANEL_SEND_ADDON", { name = "UniverseMeter" , sysName = "UniverseMeter" , param = params } )
	AoPanelDetected = true
	if DPSMeterGUI then DPSMeterGUI.ShowHideBtn:DnDHide() end
end

onMyEvent["AOPANEL_BUTTON_LEFT_CLICK"] = function(params)
	if params.sender == "UniverseMeter" then
		onReaction["ShowHideBtnReaction"]()
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
	collectgarbage()
	LogMemoryUsage()
	
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

onReaction["DefCheckBoxPressed"] = function(reaction)
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
	
	local parsedCombantants = common.GetIntFromWString(DPSMeterGUI.SettingsPanel.MaxCombatantTextEdit:GetText())
	if not parsedCombantants then
		parsedCombantants = Settings.MaxCombatants 
	end
	
	savedData.maxCombatants = parsedCombantants
	
	userMods.SetGlobalConfigSection( "UniverseMeterSettings", savedData )
	common.StateUnloadManagedAddon("UserAddon/UniverseMeter")
	common.StateLoadManagedAddon("UserAddon/UniverseMeter")
	
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
	for _, objID in pairs(aParams.despawned) do
		if objID then
			UnsubscribeListeners(objID)
		end
	end
	FabricDestroyUnused()
	for _, objID in pairs(aParams.spawned) do
		FabricMakePlayerInfo(objID, m_buffListener)
	end
end

onMyEvent["EVENT_OBJECT_BUFFS_ELEMENT_CHANGED"] = function(aParams)
	BuffsChanged(aParams)
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

--------------------------------------------------------------------------------
-- Event: EVENT_SECOND_TIMER
--------------------------------------------------------------------------------
onMyEvent["EVENT_SECOND_TIMER"] = function(params)
	OnEventSecondZatichka()
	UpdateFabric()
	
	DPSMeterGUI.DPSMeter:SecondTick()
	DPSMeterGUI.DPSMeter:UpdateCombatantPos()

	
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
local m_eventRegistred = false

function ReRegisterEvents()
	if m_eventRegistred then
		common.UnRegisterEvent("EVENT_HEALING_RECEIVED")
		common.UnRegisterEvent("EVENT_UNIT_DAMAGE_RECEIVED")
		common.UnRegisterEvent("EVENT_UNIT_FOLLOWERS_LIST_CHANGED")
	end

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
	
	m_eventRegistred = true
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
	if not common.GetAddonRelatedTextGroup(localization) then
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
		if savedData.maxCombatants then
			Settings.MaxCombatants = savedData.maxCombatants
		end
	end

	StrAllTime = GetTextLocalized("StrAllTime")
	
	
	FillBuffCheckList()
	InitBuffConditionMgr()
	
	
	m_buffListener.listenerChangeBuff = PlayerChangeBuff
	m_buffListener.listenerRemoveBuff = PlayerRemoveBuff
	
	local unitList = avatar.GetUnitList()
	table.insert(unitList, avatar.GetId())
	for _, unitID in ipairs(unitList) do
		FabricMakePlayerInfo(unitID, m_buffListener)
	end
	
	-- Create the DPSMeter here
	DPSMeterGUI = TUMeterGUI:CreateNewObject(TUMeter:CreateNewObject())
	DPSMeterGUI:Init()

	-- Initialize localizations
	StrPet = userMods.FromWString(GetTextLocalized("Pet"))
	StrDamagePool = userMods.FromWString(GetTextLocalized("DamagePool"))
	StrFromBarrier = userMods.FromWString(GetTextLocalized("FromBarrier"))
	
	StrDamagePool = userMods.ToWString(" (" .. StrDamagePool .. ")")
	StrFromBarrier = userMods.ToWString(" (" .. StrFromBarrier .. ")")
	StrNone = userMods.ToWString("")
	StrPet = userMods.ToWString(StrPet .. "-")
	StrWeakness = GetTextLocalized("Weakness")
	StrDefense = GetTextLocalized("Defense")
	StrVulnerability = GetTextLocalized("Vulnerability")
	StrInsidiousness = GetTextLocalized("Insidiousness")
	StrValor = GetTextLocalized("Valor")
	StrMapModifier = GetTextLocalized("MapModifier")
	StrExploit = GetTextLocalized("Exploit")
	StrFall = GetTextLocalized("Fall")
	


	TitleMode[enumMode.Dps] = GetTextLocalized("DPS")
	TitleMode[enumMode.Hps] = GetTextLocalized("HPS")
	TitleMode[enumMode.IHps] = GetTextLocalized("IHPS")
	TitleMode[enumMode.Def] = GetTextLocalized("DEF")
	
	

	TitleFight[enumFight.Current] = GetTextLocalized("Current")
	TitleFight[enumFight.Total] = GetTextLocalized("Overall")
	TitleFight[enumFight.History] = GetTextLocalized("History")
	

	TitleDmgType[enumHit.Normal] = GetTextLocalized("Normal")
	TitleDmgType[enumHit.Critical] = GetTextLocalized("Critical")
	TitleDmgType[enumHit.Glancing] = GetTextLocalized("Glancing")

	TitleBuffType[enumBuff.Weakness] = GetTextLocalized("Weakness")
	TitleBuffType[enumBuff.Defense] = GetTextLocalized("Defense")
	TitleBuffType[enumBuff.Vulnerability] = GetTextLocalized("Vulnerability")
	TitleBuffType[enumBuff.Valor] = GetTextLocalized("Valor")
		
	TitleMissType[enumMiss.Dodge] = GetTextLocalized("Dodge")
	TitleMissType[enumMiss.Miss] = GetTextLocalized("Miss")

	TitleHitBlockType[enumHitBlock.Block] = GetTextLocalized("Blocked")
	TitleHitBlockType[enumHitBlock.Parry] = GetTextLocalized("Parry")
	TitleHitBlockType[enumHitBlock.Barrier] = GetTextLocalized("Barrier")
	TitleHitBlockType[enumHitBlock.Resist] = GetTextLocalized("Resisted")
	TitleHitBlockType[enumHitBlock.Absorb] = GetTextLocalized("Absorbed")
	TitleHitBlockType[enumHitBlock.RunesAbsorb] = GetTextLocalized("Rune")
	TitleHitBlockType[enumHitBlock.MultAbsorb] = GetTextLocalized("Multiplier")
	TitleHitBlockType[enumHitBlock.Mount] = GetTextLocalized("Mount")
	

	TitleHealResistType[enumHealResist.Resisted] = GetTextLocalized("Resisted")
	TitleHealResistType[enumHealResist.RuneResisted] = GetTextLocalized("Rune")
	TitleHealResistType[enumHealResist.Absorbed] = GetTextLocalized("Absorbed")
	TitleHealResistType[enumHealResist.Overload] = GetTextLocalized("Overload")

	TitleGlobalInfoType[enumGlobalInfo.Determination] = GetTextLocalized("Determination")

	DPSMeterGUI.DetailsPanel.GlobalInfoHeaderNameText:SetVal("Name", GetTextLocalized("GlobalInfo"))
	DPSMeterGUI.DetailsPanel.GlobalInfoHeaderStatsText:SetVal("Min", GetTextLocalized("Min"))
	DPSMeterGUI.DetailsPanel.GlobalInfoHeaderStatsText:SetVal("Avg", GetTextLocalized("Avg"))
	DPSMeterGUI.DetailsPanel.GlobalInfoHeaderStatsText:SetVal("Max", GetTextLocalized("Max"))

	DPSMeterGUI.DetailsPanel.SpellHeaderNameText:SetVal("Name", GetTextLocalized("Ability"))
	DPSMeterGUI.DetailsPanel.SpellHeaderStatsText:SetVal("DamageDone", GetTextLocalized("Dmg"))
	DPSMeterGUI.DetailsPanel.SpellHeaderStatsText:SetVal("Absorbed", GetTextLocalized("Abs"))
	DPSMeterGUI.DetailsPanel.SpellHeaderStatsText:SetVal("CPS", GetTextLocalized("CPS"))

	DPSMeterGUI.DetailsPanel.SpellDetailsHeaderNameText:SetVal("Name", GetTextLocalized("Type"))
	DPSMeterGUI.DetailsPanel.SpellDetailsHeaderStatsText:SetVal("Min", GetTextLocalized("Min"))
	DPSMeterGUI.DetailsPanel.SpellDetailsHeaderStatsText:SetVal("Avg", GetTextLocalized("Avg"))
	DPSMeterGUI.DetailsPanel.SpellDetailsHeaderStatsText:SetVal("Max", GetTextLocalized("Max"))
	
	DPSMeterGUI.DetailsPanel.SpellCurrTimeText:SetVal("Name", GetTextLocalized("Showed"))
	DPSMeterGUI.DetailsPanel.SpellCurrTimeText:SetVal("Time", StrAllTime)
	DPSMeterGUI.DetailsPanel.DescText:SetVal("Desc", userMods.ToWString(" "))



	-- Update the mode in the fight panel (at the top of the player list)
	DPSMeterGUI.MainPanel.ModeText:SetVal("Name", TitleMode[DPSMeterGUI.ActiveMode])

	-- Update the mode in the title of the spell panel
	DPSMeterGUI.DetailsPanel.PlayerNameText:SetVal("Mode", TitleMode[DPSMeterGUI.ActiveMode])

	-- Update the mode in the header of the spell panel
	DPSMeterGUI.DetailsPanel.SpellHeaderStatsText:SetVal("DPS", TitleMode[DPSMeterGUI.ActiveMode])

	DPSMeterGUI:Reset()
	
	-- Update the fight in the fight panel (at the top of the player list)
	DPSMeterGUI.MainPanel.FightText:SetVal("Name", TitleFight[DPSMeterGUI.ActiveFightMode])

	-- Update the fight in the title of the spell panel
	DPSMeterGUI.DetailsPanel.PlayerNameText:SetVal("Fight", TitleFight[DPSMeterGUI.ActiveFightMode])

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

function PlayerChangeBuff(aBuffInfo, aPlayerID, aFindedObj)
	CurrentBuffsState[aFindedObj.ind][aPlayerID] = aFindedObj
end

function PlayerRemoveBuff(aBuffInfo, aPlayerID, aFindedObj)
	CurrentBuffsState[aFindedObj.ind][aPlayerID] = nil
end

function FillBuffCheckList()
	local index = 1
	for i = 1, 1 do
		table.insert(BuffCheckList, {name = GetTextLocalized("IHpsBuff"..i), ind = index, forTarget = true, forHps = true})
		index = index + 1
	end
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
	DPSHPSTYPES = 8
	DEFTYPES = 24
	for i = 1, DEFTYPES do
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
	end
end