--------------------------------------------------------------------------------
-- File: AoUMeterEvents.lua
-- Desc: All events managed by AoUMeter
--------------------------------------------------------------------------------

--==============================================================================
--=========================== EVENTS - Addon manager ===========================
--==============================================================================

--------------------------------------------------------------------------------
onGenEvent["SCRIPT_ADDON_INFO_REQUEST"] = function(params)
	if params.target == common.GetAddonName() then
		userMods.SendEvent("SCRIPT_ADDON_INFO_RESPONSE", {
				sender = params.target,
				desc = userMods.FromWString(GetTextLocalized("Description")),
				showDNDButton = true,
				showHideButton = true,
				showSettingsButton = true,
			})
	end
end
--------------------------------------------------------------------------------
onGenEvent["SCRIPT_ADDON_MEM_REQUEST"] = function(params)
	if params.target == common.GetAddonName() then
		userMods.SendEvent("SCRIPT_ADDON_MEM_RESPONSE", { sender = params.target, memUsage = gcinfo() })
	end
end
--------------------------------------------------------------------------------
onMyEvent["SCRIPT_SHOW_SETTINGS"] = function(params)
	if not DPSMeterGUI.MainPanel:IsVisible() then
		onReaction["ShowHideBtnReaction"]()
	end
end
--------------------------------------------------------------------------------
onMyEvent["SCRIPT_TOGGLE_VISIBILITY"] = function(params)
	if params.target == common.GetAddonName() then
		if params.state then
			DPSMeterGUI.MainPanel:Show()
			if not AoPanelDetected then
				DPSMeterGUI.ShowHideBtn:Show()
			end
		else
			DPSMeterGUI.MainPanel:Hide()
			DPSMeterGUI.ShowHideBtn:Hide()
		end
	end
end
--------------------------------------------------------------------------------
onMyEvent["SCRIPT_TOGGLE_DND"] = function(params)
	if params.target == common.GetAddonName() then
		DPSMeterGUI.ShowHideBtn:DragNDrop(params.state)
	end
end

--==============================================================================
--================== AoPanelMod Compatibility ==================================
--==============================================================================

--------------------------------------------------------------------------------
-- Register AoUMeter
--------------------------------------------------------------------------------
onGenEvent["AOPANEL_START"] = function(params)
	local SetVal = { val =  userMods.ToWString("D") } 
	local params = { header =  SetVal , ptype =  "button" , size = 30 } 
	userMods.SendEvent("AOPANEL_SEND_ADDON", { name = "AoUMeter" , sysName = "AoUMeter" , param = params } )
	AoPanelDetected = true
	if DPSMeterGUI then DPSMeterGUI.ShowHideBtn:Hide() end
end

onMyEvent["AOPANEL_BUTTON_LEFT_CLICK"] = function(params)
	if params.sender == "AoUMeter" then
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
	DPSMeterGUI:HideAllSpellDetailsPanel()

	if reaction.active then
		DPSMeterGUI.DetailsPanel.SpellDetailsHeaderPanel:Show()
		DPSMeterGUI:UpdateSpellDetailsList(GetSpellPanelIndex(reaction))
	else
		DPSMeterGUI.DetailsPanel.SpellDetailsHeaderPanel:Hide()
	end
end
--------------------------------------------------------------------------------
-- occurred when the player press the reset button
--------------------------------------------------------------------------------
onReaction["ResetBtnReaction"] = function(reaction)
	DPSMeterGUI:Reset(true)
end

onReaction["OnConfigRaidChange"] = function(reaction)
	if DPSMeterGUI.SettingsPanel:IsVisible() then
		DPSMeterGUI.SettingsPanel:Hide()
	else
		DPSMeterGUI.SettingsPanel:Show()
	end
end

onReaction["CloseSettingsPanelBtnReaction"] = function(reaction)
	DPSMeterGUI.SettingsPanel:Hide()
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
	savedData.collectDescription = GetCheckedForCheckBox(DPSMeterGUI.SettingsPanel.DescCheckBox)
	
	userMods.SetGlobalConfigSection( "UniverseMeterSettings", savedData )
	common.StateUnloadManagedAddon("UserAddon/UniverseMeter")
	common.StateLoadManagedAddon("UserAddon/UniverseMeter")
	
	DPSMeterGUI.SettingsPanel:Hide()
end

--------------------------------------------------------------------------------
-- occurred when the player press the close button in the main panel
--------------------------------------------------------------------------------
onReaction["CloseMainPanelBtnReaction"] = function(reaction)
	DPSMeterGUI.MainPanel:Hide()
	DPSMeterGUI.DetailsPanel:Hide()
end
--------------------------------------------------------------------------------
-- occurred when the player click a player in the player list
--------------------------------------------------------------------------------
onReaction["PlayerInfoButtonDown"] = function(reaction) 
	local playerIndex = GetPlayerPanelIndex(reaction)
	if playerIndex then
		local activeFight = DPSMeterGUI:GetActiveFight()
		local playerInfo = activeFight:GetCombatantInfoByIndex(playerIndex)
		if playerInfo then
			DPSMeterGUI:SetSelectedCombatant(playerInfo)
			DPSMeterGUI.DetailsPanel:Show()
			DPSMeterGUI:UpdateValues()
			DPSMeterGUI:CreateTimeLapse()
		end
	end
end

onReaction["AllTimePressed"] = function(reaction)
	DPSMeterGUI:SwitchToAll()
end

onReaction["UpdateTimeLapsePressed"] = function(reaction)
	DPSMeterGUI:CreateTimeLapse()
end

onReaction["DpsTimeLapsePressed"] = function(reaction)
	local wdgName = reaction.widget:GetParent():GetName()
	wdgName = string.gsub(wdgName, "DpsBtn", "")
	DPSMeterGUI:SwitchToTimeLapseElement(tonumber(wdgName))
end

--------------------------------------------------------------------------------
-- occurred when the player press the close button of the spell panel
--------------------------------------------------------------------------------
onReaction["CloseSpellInfoPanelBtnReaction"] = function(reaction)
	DPSMeterGUI.DetailsPanel:Hide()
end
--------------------------------------------------------------------------------
-- occurred when the player click on the fight dropdown button in the main panel
--------------------------------------------------------------------------------
onReaction["GetFightBtnReaction"] = function(reaction)
	DPSMeterGUI:SwapFight()
end
--------------------------------------------------------------------------------
-- occurred when the player click on the mode dropdown button in the main panel
--------------------------------------------------------------------------------
onReaction["GetModeBtnReaction"] = function(reaction)
	DPSMeterGUI:SwapMode()
end
--------------------------------------------------------------------------------
-- occurred when the player click on the "D" button in order to show or hide the main panel
--------------------------------------------------------------------------------
onReaction["ShowHideBtnReaction"] = function(reaction)
	if DnD:IsDragging() then return end
	if DPSMeterGUI.MainPanel:IsVisible() then
		DPSMeterGUI.MainPanel:Hide()
		DPSMeterGUI.DetailsPanel:Hide()
	else
		DPSMeterGUI.MainPanel:Show()
		DPSMeterGUI:UpdateValues()
	end
end

--==============================================================================
--=========================== EVENTS ===========================================
--==============================================================================
local mustRegenList = false
local timerToRefresh = 0
local timerToResetCache = 0
--------------------------------------------------------------------------------
-- Event: Group & raid / Appeared & Disappeared
--------------------------------------------------------------------------------
onMyEvent["EVENT_GROUP_APPEARED"] = function()
	DPSMeterGUI.DPSMeter:CopyFightFromCurrenToPrev()
	DPSMeterGUI:Reset()
	metricReset()
end

onMyEvent["EVENT_RAID_APPEARED"] = onMyEvent["EVENT_GROUP_APPEARED"]
onMyEvent["EVENT_RAID_DISAPPEARED"] = onMyEvent["EVENT_GROUP_APPEARED"]
onMyEvent["EVENT_GROUP_DISAPPEARED"] = onMyEvent["EVENT_GROUP_APPEARED"]
--------------------------------------------------------------------------------
-- Event: Member removed
--------------------------------------------------------------------------------
onMyEvent["EVENT_GROUP_MEMBER_REMOVED"] = function(params)
	DPSMeterGUI.DPSMeter:RemoveCombatant(params)
	if DPSMeterGUI.SelectedCombatantInfo and IsThisStringValue(DPSMeterGUI.SelectedCombatantInfo.name, params.name) then
		DPSMeterGUI:SetAvatarSelectedCombatant()
	end
		
	DPSMeterGUI:UpdateValues()
	metricReset()
end

onMyEvent["EVENT_RAID_MEMBER_REMOVED"] = onMyEvent["EVENT_GROUP_MEMBER_REMOVED"]
--------------------------------------------------------------------------------
-- Event: Update list
--------------------------------------------------------------------------------
onMyEvent["EVENT_GROUP_CHANGED"] = function()
	mustRegenList = true -- set the order to regen combatant list on next EVENT_SECOND_TIMER (this avoid too much updates in the same second => less lags)
end

onMyEvent["EVENT_RAID_CHANGED"] = onMyEvent["EVENT_GROUP_CHANGED"]
onMyEvent["EVENT_RAID_MEMBER_ADDED"] = onMyEvent["EVENT_GROUP_CHANGED"]
onMyEvent["EVENT_GROUP_MEMBER_ADDED"] = onMyEvent["EVENT_GROUP_CHANGED"]
onMyEvent["EVENT_GROUP_MEMBER_CHANGED"] = onMyEvent["EVENT_GROUP_CHANGED"]
onMyEvent["EVENT_RAID_MEMBER_CHANGED"] = onMyEvent["EVENT_GROUP_CHANGED"]

--------------------------------------------------------------------------------
-- Event: EVENT_SECOND_TIMER
--------------------------------------------------------------------------------
onMyEvent["EVENT_SECOND_TIMER"] = function(params)
	if timerToRefresh == 0 then
		if mustRegenList then
			DPSMeterGUI.DPSMeter:RegenCombatantList()
			metricReset()
		else
			DPSMeterGUI.DPSMeter:UpdateCombatantPos()
		end
	end

	if DPSMeterGUI.DPSMeter.bCollectData then
		if DPSMeterGUI.DPSMeter:ShouldCollectData() then
			DPSMeterGUI.DPSMeter:UpdateFightsTime()
		elseif DPSMeterGUI.DPSMeter:UpdateOffBattleTime() > Settings.MaxOffBattleTime then
			DPSMeterGUI.DPSMeter:Stop()
		end

		DPSMeterGUI:UpdateValues()
	elseif mustRegenList then
		DPSMeterGUI:UpdateValues()
	end

	if mustRegenList and timerToRefresh == 0 then
		mustRegenList = false
	end

	timerToRefresh = timerToRefresh < 3 and timerToRefresh + 1 or 0 -- so that the regen is done only once per 3 seconds
	
	timerToResetCache = timerToResetCache + 1
	if timerToResetCache > 60 then --раз в 1минуту сбрасываем кеш, чтобы сильно не разрастался
		ResetCache()
		timerToResetCache = 0
	end
end
--------------------------------------------------------------------------------
-- Event: EVENT_UNIT_DAMAGE_RECEIVED
--------------------------------------------------------------------------------
function RetrieveDDEvent(params)
	if not params then return end
	if params.isFall then return end
	if not Settings.ModeDPS then return end
	local collectedDps
	
	if Settings.ModeDPS then
		params.DDOut = true
		collectedDps = DPSMeterGUI.DPSMeter:CollectDamageDealedData(params)
		--[[for i=1, 50 do
			DPSMeterGUI.DPSMeter:CollectDamageDealedData(params)
		end]]
	end
	
	if collectedDps
		and DPSMeterGUI:GetActiveFight():GetCombatantCount() <= Settings.HeavyMode_MaxCombatant then
		DPSMeterGUI:UpdateValues()
	end
end

function RetrieveDDEventIN(params)
	if not params then return end
	if not Settings.ModeDEF then return end
	--if params.isFall then return end
	local collectedDef

	if Settings.ModeDEF then
		params.DDIn = true
		collectedDef = DPSMeterGUI.DPSMeter:CollectDamageReceivedData(params)
	end
	
	
end
--------------------------------------------------------------------------------
-- Event: EVENT_HEALING_RECEIVED
--------------------------------------------------------------------------------
function RetrieveHealEvent(params)
	if not params then return end
	if not Settings.ModeHPS then return end
	DPSMeterGUI.DPSMeter:CollectHealData(params)
end 

function RetrieveHealEventIN(params)
	if not params then return end
	if not Settings.ModeIHPS then return end
	DPSMeterGUI.DPSMeter:CollectHealDataIN(params)
end 
--------------------------------------------------------------------------------
-- Event: EVENT_AVATAR_CREATED
--------------------------------------------------------------------------------
onGenEvent["EVENT_AVATAR_CREATED"] = function(params)
	GlobalReset()
end


function GlobalReset()
	-- Since AO 2.0.03, localization must be applied here
	localization = GetGameLocalization()
	if not common.GetAddonRelatedTextGroup(localization) then
		localization = "eng"
	end

	onGenEvent["SCRIPT_ADDON_INFO_REQUEST"]({ target = common.GetAddonName() })
	
	local savedData = userMods.GetGlobalConfigSection("UniverseMeterSettings")
	if savedData then
		Settings.ModeDPS  = savedData.dps
		Settings.ModeHPS  = savedData.hps
		Settings.ModeDEF  = savedData.def
		Settings.ModeIHPS = savedData.ihps
		Settings.CollectDescription = savedData.collectDescription
	end

	StrSettingsDef = GetTextLocalized("SettingsDef")
	StrSettingsDps = GetTextLocalized("SettingsDps")
	StrSettingsHps = GetTextLocalized("SettingsHps")
	StrSettingsIhps = GetTextLocalized("SettingsIhps")
	StrSave = GetTextLocalized("SettingsSave")
	StrSettings = GetTextLocalized("StrSettings")
	StrAllTime = GetTextLocalized("StrAllTime")
	StrUpdateTimeLapse = GetTextLocalized("StrUpdateTimeLapse")
	StrSettingsDesc = GetTextLocalized("SettingsDesc")
	
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
	StrVulnerability = GetTextLocalized("Vulnerability")
	StrPower = GetTextLocalized("Power")
	StrInsidiousness = GetTextLocalized("Insidiousness")
	StrValor = GetTextLocalized("Valor")


	TitleMode[enumMode.Dps] = GetTextLocalized("DPS")
	TitleMode[enumMode.Hps] = GetTextLocalized("HPS")
	TitleMode[enumMode.IHps] = "IHPS"--GetTextLocalized("IHPS")
	TitleMode[enumMode.Def] = GetTextLocalized("DEF")
	
	

	TitleFight[enumFight.Previous] = GetTextLocalized("Previous")
	TitleFight[enumFight.Current] = GetTextLocalized("Current")
	TitleFight[enumFight.Total] = GetTextLocalized("Overall")
	TitleFight[enumFight.PrevPrevious] = GetTextLocalized("PrevPrevious")

	TitleDmgType[enumHit.Normal] = GetTextLocalized("Normal")
	TitleDmgType[enumHit.Critical] = GetTextLocalized("Critical")
--	TitleDmgType[enumHit.Glancing] = GetTextLocalized("Glancing")

	TitleMissType[enumMiss.Weakness] = GetTextLocalized("Weakness")
	TitleMissType[enumMiss.Vulnerability] = GetTextLocalized("Vulnerability")
	TitleMissType[enumMiss.Power] = GetTextLocalized("Power")
	TitleMissType[enumMiss.Valor] = GetTextLocalized("Valor")
	TitleMissType[enumMiss.Insidiousness] = GetTextLocalized("Insidiousness")
	TitleMissType[enumMiss.Dodge] = GetTextLocalized("Dodge")
	TitleMissType[enumMiss.Miss] = GetTextLocalized("Miss")

	--TitleHitBlockType[enumHitBlock.Block] = GetTextLocalized("Blocked")
	--TitleHitBlockType[enumHitBlock.Parry] = GetTextLocalized("Parry")
	TitleHitBlockType[enumHitBlock.Barrier] = GetTextLocalized("Barrier")
	--TitleHitBlockType[enumHitBlock.Resist] = GetTextLocalized("Resisted")
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

	DPSMeterGUI.DetailsPanel.SpellDetailsHeaderNameText:SetVal("Name", GetTextLocalized("Type"))
	DPSMeterGUI.DetailsPanel.SpellDetailsHeaderStatsText:SetVal("Min", GetTextLocalized("Min"))
	DPSMeterGUI.DetailsPanel.SpellDetailsHeaderStatsText:SetVal("Avg", GetTextLocalized("Avg"))
	DPSMeterGUI.DetailsPanel.SpellDetailsHeaderStatsText:SetVal("Max", GetTextLocalized("Max"))
	
	DPSMeterGUI.DetailsPanel.SpellCurrTimeText:SetVal("Name", GetTextLocalized("Showed"))
	DPSMeterGUI.DetailsPanel.SpellCurrTimeText:SetVal("Time", GetTextLocalized("StrAllTime"))
	DPSMeterGUI.DetailsPanel.DescText:SetVal("Desc", userMods.ToWString(" "))

	-- If wider main panel, then extend the width...
	if Settings.MainPanelWidth == enumWidth.Auto and localization == "rus" or Settings.MainPanelWidth == enumWidth.Wide then
		local newWidth = Settings.MainPanelWideSize

		if newWidth > DPSMeterGUI.MainPanelWidth then
			local deltaWidth = newWidth - DPSMeterGUI.MainPanelWidth
			DPSMeterGUI.BarWidth = DPSMeterGUI.BarWidth + deltaWidth
			local delta13 = math.floor(deltaWidth * 1/3)
			local delta23 = math.floor(deltaWidth * 2/3)

			DPSMeterGUI.MainPanel:SetWidth(DPSMeterGUI.InitialSize["MainPanelWidth"] + deltaWidth)
			DPSMeterGUI.MainPanel.FightBtn:SetWidth(DPSMeterGUI.InitialSize["FightBtnWidth"] + delta23)
			DPSMeterGUI.MainPanel.ModeBtn:SetWidth(DPSMeterGUI.InitialSize["ModeBtnWidth"] + delta13)
			DPSMeterGUI.MainPanel.FightBtn:SetPosition(DPSMeterGUI.InitialSize["FightBtnPosX"] + delta13, nil)
			DPSMeterGUI.MainPanel.TotalPanel:SetWidth(DPSMeterGUI.InitialSize["TotalPanelWidth"] + deltaWidth)

			for playerIndex = 1, Settings.MaxCombatants do
				DPSMeterGUI.MainPanel.PlayerList[playerIndex]:SetWidth(DPSMeterGUI.InitialSize["TotalPanelWidth"] + deltaWidth)
			end
		end
	end

	-- Update the mode in the fight panel (at the top of the player list)
	DPSMeterGUI.MainPanel.ModeText:SetVal("Name", TitleMode[DPSMeterGUI.ActiveMode])

	-- Update the mode in the title of the spell panel
	DPSMeterGUI.DetailsPanel.PlayerNameText:SetVal("Mode", TitleMode[DPSMeterGUI.ActiveMode])

	-- Update the mode in the header of the spell panel
	DPSMeterGUI.DetailsPanel.SpellHeaderStatsText:SetVal("DPS", TitleMode[DPSMeterGUI.ActiveMode])

	DPSMeterGUI:Reset()
	
	-- DPSMeterGUI.DPSMeter.Fight.x indices can change during the execution
	local title = {
		[DPSMeterGUI.DPSMeter.Fight.Previous] = TitleFight[enumFight.Previous],
		[DPSMeterGUI.DPSMeter.Fight.Current] = TitleFight[enumFight.Current],
		[DPSMeterGUI.DPSMeter.Fight.Total] = TitleFight[enumFight.Total],
		[DPSMeterGUI.DPSMeter.Fight.PrevPrevious] = TitleFight[enumFight.PrevPrevious],
	}

	-- Update the fight in the fight panel (at the top of the player list)
	DPSMeterGUI.MainPanel.FightText:SetVal("Name", title[DPSMeterGUI.ActiveFight])

	-- Update the fight in the title of the spell panel
	DPSMeterGUI.DetailsPanel.PlayerNameText:SetVal("Fight", title[DPSMeterGUI.ActiveFight])

	if AoPanelDetected then DPSMeterGUI.ShowHideBtn:Hide() end

	-- Register now the other events & reactions
	metricReset()
	RegisterEventHandlers(onMyEvent)
	RegisterReactionHandlers(onReaction)
end


local paramsBlockDD = {}
local paramsBlockDDIN = {}
local paramsBlockHeal = {}
local paramsBlockHealIN = {}
local paramsBlockID = {}
local eventRegistredDDAndHealUnits = {}

function metricReset()
	if #paramsBlockDD > 0 then
		common.UnRegisterEvent("EVENT_HEALING_RECEIVED")
		common.UnRegisterEvent("EVENT_UNIT_DAMAGE_RECEIVED")
		common.UnRegisterEvent("EVENT_UNIT_FOLLOWERS_LIST_CHANGED")
		eventRegistredDDAndHealUnits = {}
	end
	paramsBlockDD = {}
	paramsBlockHeal = {}
	paramsBlockDDIN = {}
	paramsBlockHealIN = {}
	paramsBlockID = {}
	
	if isRaid() then 
		local members = raid.GetMembers()
		if members then
			for index, groupBlock in pairs(members) do
				for index2, groupInfo in pairs(groupBlock) do 
					addToHandlerR(groupInfo.id)
				end
			end
		end
	elseif isGroup() then
		local members = group.GetMembers()
		if members then
			for index, groupInfo in pairs(members) do
				addToHandlerR(groupInfo.id)
			end
		end
	else
		addToHandlerR(avatar.GetId() )
	end
	

	RegisterEventHandlersNew("EVENT_HEALING_RECEIVED", RetrieveHealEvent , paramsBlockHeal)
	RegisterEventHandlersNew("EVENT_HEALING_RECEIVED", RetrieveHealEventIN , paramsBlockHealIN)
	RegisterEventHandlersNew("EVENT_UNIT_DAMAGE_RECEIVED", RetrieveDDEvent , paramsBlockDD)
	RegisterEventHandlersNew("EVENT_UNIT_DAMAGE_RECEIVED", RetrieveDDEventIN , paramsBlockDDIN)
	RegisterEventHandlersNew("EVENT_UNIT_FOLLOWERS_LIST_CHANGED", ReloadPet, paramsBlockID)
end

function ReloadPet(params)
	if not params then return end
	metricReset()
end

function addToHandlerR(_unitId)
	if not _unitId then return end
	paramsBlockID[#paramsBlockID + 1] = {id = _unitId}
	paramsBlockDDIN[#paramsBlockDDIN+1] =  {target = _unitId}
	paramsBlockHealIN[#paramsBlockHealIN+1] =  {unitId = _unitId}

	addToHandler(_unitId)
	
	local followers = unit.GetFollowers( _unitId )
	if not followers then return end
	for _, followerId in pairs( followers ) do
		addToHandler(followerId)
	end

end

function addToHandler(_unitId)
	if eventRegistredDDAndHealUnits[_unitId] then return end
	--наймы на островах одновременно члены группы и петы
	eventRegistredDDAndHealUnits[_unitId] = true

	paramsBlockDD[#paramsBlockDD+1] =  {source = _unitId}
	paramsBlockHeal[#paramsBlockHeal+1] =  {healerId = _unitId}	
end

function RegisterEventHandlersNew(event, handler, params )
	if params then 
		for i,params1 in ipairs(params) do 
			common.RegisterEventHandler(handler, event, params1)
		end
	else 
		common.RegisterEventHandler(handler, event)
	end
end


function isRaid()
	if raid.IsExist and avatar.IsExist then
		if avatar.IsExist() then return raid.IsExist() end
	end
	return false
end

function isGroup()
	if group.IsCreatureInGroup and avatar.IsExist and avatar.GetId then
		if avatar.IsExist() then return group.IsCreatureInGroup(avatar.GetId()) end
	end
	if group.IsExist then return group.IsExist() end
	return false
end

function message(text, color, fontSize)
	local chat=stateMainForm:GetChildUnchecked("ChatLog", false)
	if not chat then
		chat=stateMainForm:GetChildUnchecked("Chat", true)
	else
		chat=chat:GetChildUnchecked("Container", true)
	end
	if not chat then return end

	text=common.GetAddonName()..": "..(toString(text) or "nil")
	chat:PushFrontValuedText(toValuedText(text, nil, nil, 16, nil, nil, "AllodsSystem"))
end

function toString(text)
	if not text then return nil end
	if common.IsWString(text) then
		text=userMods.FromWString(text)
	end
	return tostring(text)
end

function toValuedText(text, color, align, fontSize, shadow, outline, fontName)
	local valuedText=common.CreateValuedText()
	text=toWString(text)
	if not valuedText or not text then return nil end
	valuedText:SetFormat(toWString(formatText(text, align, fontSize, shadow, outline, fontName)))
	if color then
		valuedText:SetClassVal( "color", color )
	else
		valuedText:SetClassVal( "color", "LogColorYellow" )
	end
	return valuedText
end

function toWString(text)
	if not text then return nil end
	if not common.IsWString(text) then
		text=userMods.ToWString(tostring(text))
	end
	return text
end

function formatText(text, align, fontSize, shadow, outline, fontName)
	return "<body fontname='"..(toString(fontName) or "AllodsWest").."' alignx = '"..(toString(align) or "left").."' fontsize='"..(toString(fontSize) or "14").."' shadow='"..(toString(shadow) or "1").."' outline='"..(toString(outline) or "0").."'><rs class='color'>"..(toString(text) or "").."</rs></body>"
end