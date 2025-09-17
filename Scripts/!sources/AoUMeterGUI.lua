--------------------------------------------------------------------------------
-- File: AoUMeterGUI.lua
-- Desc: Graphical user interface
--------------------------------------------------------------------------------

local cachedFromWString = userMods.FromWString
local cachedToWString = userMods.ToWString
local cachedFormatFloat = common.FormatFloat
local cachedFormatInt = common.FormatInt

--------------------------------------------------------------------------------
-- Type TMainPanelGUI
Global("TMainPanelGUI", {})
--------------------------------------------------------------------------------
function TMainPanelGUI:CreateNewObject(name)
	local widget = TWidget:CreateNewObject(name)
	return setmetatable({
			FightBtn = widget:GetChildByName("FightPanel"),
			FightText = widget:GetChildByName("FightPanel"):GetChildByName("FightNameTextView").Widget, -- Button to switch the active fight
			ModeBtn = widget:GetChildByName("ModePanel"),
			ModeText = widget:GetChildByName("ModePanel"):GetChildByName("ModeNameTextView").Widget, -- Button to switch the active mode       
			TotalPanel = nil, -- Panel to display the total
			PlayerList = {}, -- Panel player list
		}, { __index = widget })
end

--------------------------------------------------------------------------------
-- Type TMainPanelGUI
Global("TDetailsPanelGUI", {})
--------------------------------------------------------------------------------
function TDetailsPanelGUI:CreateNewObject(name)
	local widget = TWidget:CreateNewObject(name)
	return setmetatable({
			CloseButton = widget:GetChildByName("CloseBtn"), -- Close button
			FightBtn = widget:GetChildByName("FightPanel"),
			FightText = widget:GetChildByName("FightPanel"):GetChildByName("FightNameTextView").Widget, -- Button to switch the active fight
			ModeBtn = widget:GetChildByName("ModePanel"),
			ModeText = widget:GetChildByName("ModePanel"):GetChildByName("ModeNameTextView").Widget, -- Button to switch the active mode      
			
			PlayerNameText = widget:GetChildByName("SpellPlayerNameTextViewName").Widget,
			
			ResistHeaderText = widget:GetChildByName("ResistHeaderTextView"),
			DpsBuffHeaderText = widget:GetChildByName("DpsBuffHeaderTextView"),
			DefBuffHeaderText = widget:GetChildByName("DefBuffHeaderTextView"),
	
			GlobalInfoHeaderPanel = widget:GetChildByName("GlobalInfoHeaderPanel"),
			GlobalInfoHeaderNameText = widget:GetChildByName("GlobalInfoHeaderPanel"):GetChildByName("GlobalInfoHeaderTextViewName"),
			GlobalInfoHeaderStatsMinText = widget:GetChildByName("GlobalInfoHeaderPanel"):GetChildByName("GlobalInfoHeaderTextViewStatsMin"),
			GlobalInfoHeaderStatsSeparator1Text = widget:GetChildByName("GlobalInfoHeaderPanel"):GetChildByName("GlobalInfoHeaderTextViewStatsSeparator1"),
			GlobalInfoHeaderStatsAvgText = widget:GetChildByName("GlobalInfoHeaderPanel"):GetChildByName("GlobalInfoHeaderTextViewStatsAvg"),
			GlobalInfoHeaderStatsSeparator2Text = widget:GetChildByName("GlobalInfoHeaderPanel"):GetChildByName("GlobalInfoHeaderTextViewStatsSeparator2"),
			GlobalInfoHeaderStatsMaxText = widget:GetChildByName("GlobalInfoHeaderPanel"):GetChildByName("GlobalInfoHeaderTextViewStatsMax"),
			GlobalInfoList = {},     -- Panel extra info list

			SpellHeaderPanel = widget:GetChildByName("SpellHeaderPanel"), -- Header panel
			--SpellHeaderIndexText = SpellHeaderPanel:GetChildChecked("SpellHeaderTextViewIndex", false),
			SpellHeaderTypeText = widget:GetChildByName("SpellHeaderPanel"):GetChildByName("SpellHeaderTextViewType"),
			SpellHeaderNameText = widget:GetChildByName("SpellHeaderPanel"):GetChildByName("SpellHeaderTextViewName"),
			SpellHeaderStatsText = widget:GetChildByName("SpellHeaderPanel"):GetChildByName("SpellHeaderTextViewStats"),
			SpellHeaderDmgBlockText = widget:GetChildByName("SpellHeaderPanel"):GetChildByName("SpellHeaderTextViewDmgBlock"),
			SpellHeaderCPSText = widget:GetChildByName("SpellHeaderPanel"):GetChildByName("SpellHeaderTextViewCPS"),
			--SpellHeaderPercentageTextView = SpellHeaderPanel:GetChildChecked("SpellHeaderTextViewPercentage", false),
			SpellList = {},         -- Panel spell list

			SpellDetailsHeaderPanel = widget:GetChildByName("SpellDetailHeaderPanel"),
			SpellDetailsHeaderNameText = widget:GetChildByName("SpellDetailHeaderPanel"):GetChildByName("SpellDetailHeaderTextViewName"),
			SpellDetailsHeaderStatsMinText = widget:GetChildByName("SpellDetailHeaderPanel"):GetChildByName("SpellDetailHeaderTextViewStatsMin"),
			SpellDetailsHeaderStatsSeparator1Text = widget:GetChildByName("SpellDetailHeaderPanel"):GetChildByName("SpellDetailHeaderTextViewStatsSeparator1"),
			SpellDetailsHeaderStatsAvgText = widget:GetChildByName("SpellDetailHeaderPanel"):GetChildByName("SpellDetailHeaderTextViewStatsAvg"),
			SpellDetailsHeaderStatsSeparator2Text = widget:GetChildByName("SpellDetailHeaderPanel"):GetChildByName("SpellDetailHeaderTextViewStatsSeparator2"),
			SpellDetailsHeaderStatsMaxText = widget:GetChildByName("SpellDetailHeaderPanel"):GetChildByName("SpellDetailHeaderTextViewStatsMax"),
			SpellInfoList = {},     -- Panel spell info list (normal, critical, glancing)
			SpellMissList = {},     -- Panel miss list
			SpellDpsBuffList = {},     -- Panel buff list
			SpellDefBuffList = {},     -- Panel buff list
			SpellBlockList = {},    -- Panel block list
			SpellCustomDpsBuffList = {},     -- Panel custom buff list
			SpellCustomDefBuffList = {},     -- Panel custom buff list
			
			SpellScrollList = widget.Widget:GetChildChecked("ScrollableContainerV"),
			TimeLapsePanel = widget:GetChildByName("ScrollDPSPanel"),
			TimeLapseScroll = widget:GetChildByName("ScrollDPSPanel"):GetChildByName("ScrollableContainerH"),
			BarrierTemplateBtn = GetDescFromResource("BarrierTemplateBtn"),
			DpsTemplateBtnDesc = GetDescFromResource("DpsTemplateBtn"),
			DpsTemplateTxtDesc = GetDescFromResource("TimeTextView"),		
			DpsTemplateLineDesc = GetDescFromResource("LinePanel"),	
			BigPanel = widget:GetChildByName("ScrollDPSPanel"):GetChildByName("BigPanel"),
			AllTimeBtn = widget:GetChildByName("AllTimeBtn"),
			UpdateTimeLapseBtn = widget:GetChildByName("UpdateTimeLapseBtn"),
			SpellCurrTimeText = widget:GetChildByName("SpellCurrTimeTextView"),
			DescText = widget:GetChildByName("DescTextView"),
			
			SpellGlobalBarWidth = 456, 
			SpellBarWidth = 434, 
			SpellDetailBarWidth = 370, 
			DetailsPanelHeight = 480,
		}, { __index = widget })
end
--------------------------------------------------------------------------------
Global("TSettingsPanelGUI", {})
--------------------------------------------------------------------------------
function TSettingsPanelGUI:CreateNewObject(name)
	local widget = TWidget:CreateNewObject(name)
	return setmetatable({
			CloseButton = widget:GetChildByName("CloseBtn"), -- Close button
			DefCheckBoxText = widget:GetChildByName("DefCheckBoxText").Widget,
			DpsCheckBoxText = widget:GetChildByName("DpsCheckBoxText").Widget,
			HpsCheckBoxText = widget:GetChildByName("HpsCheckBoxText").Widget,
			IhpsCheckBoxText = widget:GetChildByName("IhpsCheckBoxText").Widget,
			SkipPetCheckBoxText = widget:GetChildByName("SkipPetCheckBoxText").Widget,
			StartHidedCheckBoxText = widget:GetChildByName("StartHidedCheckBoxText").Widget,
			SkipYourselfCheckBoxText = widget:GetChildByName("SkipYourselfCheckBoxText").Widget,
			CombatantCntText = widget:GetChildByName("CombatantCntText").Widget,
			TotalTimelapseCheckBoxText = widget:GetChildByName("TotalTimelapseCheckBoxText").Widget,
			ShowScoreCheckBoxText = widget:GetChildByName("ShowScoreCheckBoxText").Widget,
			ScaleFontsCheckBoxText = widget:GetChildByName("ScaleFontsCheckBoxText").Widget,
			
			DefCheckBox = widget:GetChildByName("DefCheckBox").Widget,
			DpsCheckBox = widget:GetChildByName("DpsCheckBox").Widget,
			HpsCheckBox = widget:GetChildByName("HpsCheckBox").Widget,
			IhpsCheckBox = widget:GetChildByName("IhpsCheckBox").Widget,
			SkipPetCheckBox = widget:GetChildByName("SkipPetCheckBox").Widget,
			StartHidedCheckBox = widget:GetChildByName("StartHidedCheckBox").Widget,
			SkipYourselfCheckBox = widget:GetChildByName("SkipYourselfCheckBox").Widget,
			MaxCombatantTextEdit = widget:GetChildByName("SettingsMaxCombatant").Widget,
			TotalTimelapseCheckBox = widget:GetChildByName("TotalTimelapseCheckBox").Widget,
			ShowScoreCheckBox = widget:GetChildByName("ShowScoreCheckBox").Widget,
			ScaleFontsCheckBox = widget:GetChildByName("ScaleFontsCheckBox").Widget,
			
			HeaderText = widget:GetChildByName("HeaderText").Widget,
			
			SaveBtn = widget:GetChildByName("SaveBtn").Widget,
		}, { __index = widget })
end
--------------------------------------------------------------------------------
Global("THistoryPanelGUI", {})
--------------------------------------------------------------------------------
function THistoryPanelGUI:CreateNewObject(name)
	local widget = TWidget:CreateNewObject(name)
	return setmetatable({
			CloseButton = widget:GetChildByName("CloseBtn"), -- Close button
			CurrentScrollList = widget:GetChildByName("ScrollCurrentPanel"):GetChildByName("ScrollableContainerV"),
			TotalScrollList = widget:GetChildByName("ScrollTotalPanel"):GetChildByName("ScrollableContainerV"),
			HeaderText = widget:GetChildByName("HeaderText"),
			HeaderCurrentText = widget:GetChildByName("ScrollCurrentPanel"):GetChildByName("HeaderCurrentText"),
			HeaderTotalText = widget:GetChildByName("ScrollTotalPanel"):GetChildByName("HeaderTotalText"),
			HistoryBtnDesc = GetDescFromResource("HistoryBtn")
		}, { __index = widget })
end
--------------------------------------------------------------------------------
-- Type TTotalPanelGUI
Global("TTotalPanelGUI", {})
--------------------------------------------------------------------------------
function TTotalPanelGUI:CreateNewObjectByDesc(name, desc, owner)
	local widget = TWidget:CreateNewObjectByDesc(name, desc, owner)
	return setmetatable({
			Bar = widget:GetChildByName("PlayerInfoBar"),
			Name = widget:GetChildByName("TotalInfoTextViewName"),
			Value = widget:GetChildByName("PlayerInfoTextViewStats")
		}, { __index = widget })
end
--------------------------------------------------------------------------------
-- Type TPlayerPanelGUI
Global("TPlayerPanelGUI", {})
--------------------------------------------------------------------------------
function TPlayerPanelGUI:CreateNewObjectByDesc(name, desc, owner)
	local widget = TWidget:CreateNewObjectByDesc(name, desc, owner)
	return setmetatable({
			Bar = widget:GetChildByName("PlayerInfoBar"),
			Name = widget:GetChildByName("PlayerInfoTextViewName"),
			Value = widget:GetChildByName("PlayerInfoTextViewStats"),
			Percent = widget:GetChildByName("PlayerInfoTextViewPercentage"),
		}, { __index = widget })
end
--------------------------------------------------------------------------------
-- Type TSpellPanelGUI
Global("TSpellPanelGUI", {})
--------------------------------------------------------------------------------
function TSpellPanelGUI:CreateNewObjectByDesc(name, desc, owner)
	local widget = TWidget:CreateNewObjectByDesc(name, desc, owner)
	return setmetatable({
			Bar = widget:GetChildByName("SpellBar"),
			Index = widget:GetChildByName("SpellTextViewIndex"),
			Type = widget:GetChildByName("SpellTextViewType"),
			Name = widget:GetChildByName("SpellTextViewName"),
			Damage = widget:GetChildByName("SpellTextViewStats"),
			CPS = widget:GetChildByName("SpellTextViewCPS"),
			DmgBlock = widget:GetChildByName("SpellTextViewDmgBlock"),
			Percent = widget:GetChildByName("SpellTextViewPercentage"),
			DeadImg = widget:GetChildByName("DeadImg"),
		}, { __index = widget })
end
--------------------------------------------------------------------------------
-- Type TSpellDetailsPanelGUI
Global("TSpellDetailsPanelGUI", {})
--------------------------------------------------------------------------------
function TSpellDetailsPanelGUI:CreateNewObjectByDesc(name, desc, owner)
	local widget = TWidget:CreateNewObjectByDesc(name, desc, owner)
	return setmetatable({
			Bar = widget:GetChildByName("SpellDetailBar"),
			Name = widget:GetChildByName("SpellDetailTextViewName"),
			Count = widget:GetChildByName("SpellDetailTextViewCount"),
			DamageMin = widget:GetChildByName("SpellDetailTextViewStatsMin"),
			DamageSeparator1 = widget:GetChildByName("SpellDetailTextViewStatsSeparator1"),
			DamageAvg = widget:GetChildByName("SpellDetailTextViewStatsAvg"),
			DamageSeparator2 = widget:GetChildByName("SpellDetailTextViewStatsSeparator2"),
			DamageMax = widget:GetChildByName("SpellDetailTextViewStatsMax"),
			Percent = widget:GetChildByName("SpellDetailTextViewPercentage"),
		}, { __index = widget })
end

--------------------------------------------------------------------------------
-- Type TUMeter
Global("TUMeterGUI", {})
--------------------------------------------------------------------------------
function TUMeterGUI:CreateNewObject(dpsMeter)
	return setmetatable({
			DPSMeter = dpsMeter,   -- the data object
			AoPanelDetected = false, -- true if AoPanel is also installed

			ActiveFightMode = enumFight.Current,
			ActiveMode = enumMode.Dps,          -- Active mode
			ActiveFightDetailMode = enumFight.Current,
			ActiveDetailMode = enumMode.Dps,          -- Active mode
			DetailModeCurrentFight = nil,
			DetailModeTotalFight = nil,
			SelectedCombatant = nil,            -- Selected combatant
			SelectedCombatantInfo = nil,         -- Selected combatant info (id, persistentId, name)
			TimelapseIndex = nil,
			SelectedSpellIndex = nil,
			ActiveHistoryTotalList = nil,
			ActiveHistoryCurrentList = nil,
			ActiveHistoryFight = nil,

			ShowHideBtn = nil,      -- "D" button to show/hide the addon
			MainPanel = nil,        -- Main panel with player list
			DetailsPanel = nil,     -- Details panel with spell list / details
			SettingsPanel = nil,
			HistoryPanel = nil,
			

			BarWidth = 260,         -- Bar width, adjusted automatically
		}, { __index = self })
end
--------------------------------------------------------------------------------
function TUMeterGUI:GetActiveFight()
	local rotateFight = {
		[enumFight.Current] = self.DPSMeter.Fight.Current,
		[enumFight.Total] = self.DPSMeter.Fight.Total,
		[enumFight.History] = self.ActiveHistoryFight
	}
	return rotateFight[self.ActiveFightMode]
end

function TUMeterGUI:GetActiveDetailFight()
	local rotateFight = {
		[enumFight.Current] = self.DetailModeCurrentFight,
		[enumFight.Total] = self.DetailModeTotalFight,
		[enumFight.History] = self.ActiveHistoryFight
	}
	return rotateFight[self.ActiveFightDetailMode]
end
--------------------------------------------------------------------------------
function TUMeterGUI:GetActiveFightData()
	return self:GetActiveFight().Data[self.ActiveMode]
end

function TUMeterGUI:GetActiveTimeLapse()
	return self:GetActiveFight().FightPeriods
end

function TUMeterGUI:GetActiveDetailTimeLapse()
	return self:GetActiveDetailFight().FightPeriods
end
--------------------------------------------------------------------------------
function TUMeterGUI:PrepareShowDetails(aPlayerIndex)
	local playerInfo = self:GetActiveFight():GetCombatantInfoByIndex(aPlayerIndex)
	if not playerInfo then
		return
	end
	self:ResetSelectedCombatant()
	self.SelectedCombatantInfo = playerInfo
	self.SelectedCombatant = self:GetActiveFight():GetCombatantByIndex(aPlayerIndex)
	self.ActiveFightDetailMode = self.ActiveFightMode
	self.ActiveDetailMode = self.ActiveMode
	
	self.DetailModeCurrentFight = self.DPSMeter.Fight.Current
	self.DetailModeTotalFight = self.DPSMeter.Fight.Total
	
	self.DetailsPanel.FightText:SetVal("Name", TitleFight[self.ActiveFightDetailMode])
	self.DetailsPanel.ModeText:SetVal("Name", TitleMode[self.ActiveDetailMode])
	self.DetailsPanel.PlayerNameText:SetVal("Mode", TitleMode[self.ActiveDetailMode])
	self.DetailsPanel.PlayerNameText:SetVal("Fight", TitleFight[self.ActiveFightDetailMode])
	self.DetailsPanel.SpellCurrTimeText:SetVal("Time", StrAllTime)
	
	self.DetailsPanel.SpellScrollList:SetContainerOffset(0)
	self.DetailsPanel.SpellScrollList:ForceReposition()
	
	self:GetActiveFight():PrepareShowDetails(self.SelectedCombatantInfo)
	
	self:CreateTimeLapse()
end

function TUMeterGUI:DetailsClosed()
	self.DetailsPanel.TimeLapseScroll.Widget:RemoveItems()
	self.DetailsPanel.BigPanel:DestroyAllChild()
	self.DetailModeCurrentFight = nil
	self.DetailModeTotalFight = nil
end

function TUMeterGUI:UpdateSelectedCombatant()
	self.SelectedCombatant = self:GetActiveDetailFight():GetCombatant(self.SelectedCombatantInfo.id, self.SelectedCombatantInfo.name)
	-- при переключении временного отрезка или режима там еще или уже нет этого участника
	-- SelectedCombatantInfo - сохраняется для возврата к данным при обратном переключени
	if not self.SelectedCombatant then
		self:ResetSelectedCombatant()
	end
end

function TUMeterGUI:ResetSelectedCombatant()
	self.SelectedCombatant = nil
	self.TimelapseIndex = nil
	self.SelectedSpellIndex = nil
end

function TUMeterGUI:GetCurrentCombatant()
	if self.TimelapseIndex then
		return self:GetActiveDetailTimeLapse()[self.TimelapseIndex].selectedCombatant
	end
	return self.SelectedCombatant
end
--==============================================================================
--================= PLAYER LIST ================================================
--==============================================================================

--------------------------------------------------------------------------------
-- Hide player panel in the player list
--------------------------------------------------------------------------------
function TUMeterGUI:HideAllPlayerPanel(aFrom)
	for i = aFrom, Settings.MaxCombatants do
		self.MainPanel.PlayerList[i]:Hide()
	end
end

--------------------------------------------------------------------------------
-- Update the panel "Total" in the player list
--------------------------------------------------------------------------------
function TUMeterGUI:DisplayTotal()
	local totalPanel = self.MainPanel.TotalPanel

	local minute, second = 0, 0
	local fightTime = self:GetActiveFight().Timer:GetElapsedTime()
	if fightTime >= 0 then
		minute, second = GetMinSec(fightTime)
	end

	totalPanel.Bar:SetColor(self.DPSMeter.bCollectData and TotalColorInFight or TotalColor)

	totalPanel.Name:SetVal("Minute", cachedFormatInt(minute, "%d"))
	totalPanel.Name:SetVal("Second", cachedFormatInt(second , "%02d"))
	local activeFightData = self:GetActiveFightData()
	totalPanel.Value:SetVal("DamageDone", cachedFormatFloat(activeFightData.Amount, "%f3K5"))
	totalPanel.Value:SetVal("DPS", cachedFormatFloat(activeFightData.AmountPerSec, "%f3K5"))
end
--------------------------------------------------------------------------------
-- Update values for a combatant in the player list
--------------------------------------------------------------------------------
function TUMeterGUI:DisplayPlayer(playerIndex)
	local combatant = self:GetActiveFight():GetCombatantByIndex(playerIndex)
	local playerPanel = self.MainPanel.PlayerList[playerIndex]
	if not combatant or not playerPanel then return end

	playerPanel:Show()
	
	playerPanel.Bar:SetColor(ClassColors[combatant:GetClassColor()] or ClassColors[ClassColorsIndex["UNKNOWN"]])
	playerPanel.Name:SetVal("Index", cachedFormatInt(playerIndex , "%d"))
	playerPanel.Name:SetVal("Name", combatant.Name)
	
	local combatantActiveData = combatant.Data[self.ActiveMode]
	if combatantActiveData then
		playerPanel.Bar:SetWidth(math.max(self.BarWidth * (combatantActiveData.LeaderPercentage / 100), 1))
		playerPanel.Value:SetVal("DamageDone", cachedFormatFloat(combatantActiveData.Amount, "%f3K5"))
		playerPanel.Value:SetVal("DPS", cachedFormatFloat(combatantActiveData.AmountPerSec, "%f3K5"))
		playerPanel.Percent:SetVal("Percentage", cachedFormatInt(combatantActiveData.Percentage, "%d"))
	else
		playerPanel.Bar:SetWidth(math.max(0, 1))
		playerPanel.Value:SetVal("DamageDone", cachedFormatFloat(0, "%f3K5"))
		playerPanel.Value:SetVal("DPS", cachedFormatFloat(0, "%f3K5"))
		playerPanel.Percent:SetVal("Percentage", cachedFormatInt(0, "%d"))
	end
end
--------------------------------------------------------------------------------
-- Update the whole player list
--------------------------------------------------------------------------------
function TUMeterGUI:UpdatePlayerList()
	local currentFight = self:GetActiveFight()
	if not self.MainPanel.Widget:IsVisible() or not currentFight then return end
	currentFight:RecalculateCombatantsData(self.ActiveMode) -- Important

	local combatantCount = math.min(currentFight:GetCombatantCount(), Settings.MaxCombatants)

	self.MainPanel:SetHeight(47 + (combatantCount + 1) * 24)

	self:DisplayTotal()
	for playerIndex = 1, combatantCount do
		self:DisplayPlayer(playerIndex)
	end
	
	self:HideAllPlayerPanel(combatantCount+1)
end

function TUMeterGUI:UpdateScoreOnMainBtn()
	local currentFight = self:GetActiveFight()
	if not Settings.ShowPositionOnBtn or not currentFight then return end
	currentFight:RecalculateCombatantsData(self.ActiveMode)

	local combatantCount = math.min(currentFight:GetCombatantCount(), Settings.MaxCombatants)
	
	for playerIndex = 1, combatantCount do
		local combatant = currentFight:GetCombatantByIndex(playerIndex)
		local myID = avatar.GetId()
		if combatant and combatant.ID == myID then
			if CurrentScoreOnMainBtn ~= playerIndex then
				if AoPanelDetected then
					local SetVal = { val = StrMainBtn..StrSpace..cachedFormatInt(playerIndex , "%d") }
					userMods.SendEvent( "AOPANEL_UPDATE_ADDON", { sysName = "UniverseMeter", header = SetVal } )
				end
				self.ShowHideBtn:SetVal( 'button_label', cachedFormatInt(playerIndex , "%d") )
				CurrentScoreOnMainBtn = playerIndex
			end
		end
	end
end

--==============================================================================
--================= SPELL PANEL - Spell list ===================================
--==============================================================================

--------------------------------------------------------------------------------
-- Update a extra info line in the spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:DisplayGlobalInfo(aGlobalInfoIndex)
	local globalInfoData
	local selectedCombatant = self:GetCurrentCombatant()
	if selectedCombatant then
		globalInfoData = selectedCombatant:GetGlobalInfoByIndex(aGlobalInfoIndex, self.ActiveDetailMode)
	end
	local globalInfoPanel = self.DetailsPanel.GlobalInfoList[aGlobalInfoIndex]

	if globalInfoData --[[and globalInfoData.Count > 0]] then
		globalInfoPanel:Show()

		globalInfoPanel.Bar:SetColor(GlobalInfoTypeColors[aGlobalInfoIndex])
		globalInfoPanel.Bar:SetWidth(math.max(self.DetailsPanel.SpellGlobalBarWidth * (globalInfoData.Percentage / 100), 1))

		globalInfoPanel.Name:SetVal("Name", TitleGlobalInfoType[aGlobalInfoIndex])
		globalInfoPanel.Count:SetVal("Count", cachedFormatInt(globalInfoData.Count , "%d"))
		globalInfoPanel.DamageMin:SetVal("Min", cachedFormatFloat(globalInfoData.Min , "%f3K5"))
		globalInfoPanel.DamageAvg:SetVal("Avg", cachedFormatFloat(TValueDetails.GetAvg(globalInfoData) , "%f3K5"))
		globalInfoPanel.DamageMax:SetVal("Max", cachedFormatFloat(globalInfoData.Max , "%f3K5"))
		globalInfoPanel.Percent:SetVal("Percentage", cachedFormatInt(globalInfoData.Percentage , "%d"))
	else
		globalInfoPanel:Hide()
	end
end
--------------------------------------------------------------------------------
-- Update a spell line in the spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:GetTypeHeader(aSpellData)
	if IsPetData(aSpellData) then
		return StrTypePet
	end
	
	local typeOfID = apitype(aSpellData.InfoID)
	if typeOfID == "SpellId" then
		return StrTypeAbility --StrTypeSpell  на текущий момент почти все умения почему-то - Spell
	elseif typeOfID == "AbilityId" then
		return StrTypeAbility
	elseif typeOfID == "BuffId" then
		return StrTypeBuff
	elseif typeOfID == "MapModifierId" then
		return StrTypeMap
	else
		return StrUnknown
	end
end

function TUMeterGUI:DisplaySpells()
	local selectedCombatant = self:GetCurrentCombatant()
	if selectedCombatant then
		local displaySpellCnt = selectedCombatant:GetSpellCount(self.ActiveDetailMode)
		local spellPanelsCnt = table.nkeys(self.DetailsPanel.SpellList)
		if spellPanelsCnt < displaySpellCnt then
			for i = spellPanelsCnt + 1, displaySpellCnt do
				self:CreateNewSpellPanel()
			end
		end
		for spellIndex, _ in ipairs(self.DetailsPanel.SpellList) do
			self:DisplaySpell(spellIndex, selectedCombatant)
		end
	else
		for _, spellPanel in ipairs(self.DetailsPanel.SpellList) do
			spellPanel:Hide()
		end
	end
end

function TUMeterGUI:DisplaySpell(aSpellIndex, aCombatant)
	local spellData = aCombatant:GetSpellByIndex(aSpellIndex, self.ActiveDetailMode)
	local spellPanel = self.DetailsPanel.SpellList[aSpellIndex]
	if spellData then
		spellPanel:Show()
		
		spellPanel.Bar:SetColor(DamageTypeColors[spellData.Element] or { r = 1.0; g = 1.0; b = 1.0; a = 1 } )
		spellPanel.Bar:SetWidth(math.max(self.DetailsPanel.SpellBarWidth * (spellData.Percentage / 100), 1))

		spellPanel.Index:SetVal("Index", cachedFormatInt(aSpellIndex , "%d"))
		spellPanel.Type:SetVal("Type",  self:GetTypeHeader(spellData))
		spellPanel.Name:SetVal("PetName", spellData.PetName and spellData.PetName or StrNone)
		spellPanel.Name:SetVal("Name", spellData.Name)
		
		spellPanel.Damage:SetVal("DamageDone", cachedFormatFloat(spellData.Amount , "%f3K5"))
		spellPanel.Damage:SetVal("DPS", cachedFormatFloat(spellData.AmountPerSec , "%f3K5"))
		spellPanel.CPS:SetVal("CPS", cachedFormatFloat(GetAverageCntPerSecond(spellData) , "%.1f"))
		spellPanel.DmgBlock:SetVal("DamageBlock", cachedFormatFloat(spellData.ResistPercentage , "%g"))
		spellPanel.Percent:SetVal("Percentage", cachedFormatInt(spellData.Percentage , "%d"))
		
		if spellData.WasDead then
			spellPanel.DeadImg:Show()
		else
			spellPanel.DeadImg:Hide()
		end
	else
		spellPanel:Hide()
	end
end
--------------------------------------------------------------------------------
-- Fill the spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:UpdateSpellList()
	local detailsPanel = self.DetailsPanel
	if not detailsPanel:IsVisible() or not self:GetActiveDetailFight() then return end
	
	self:GetActiveDetailFight():PrepareShowDetails(self.SelectedCombatantInfo)

	local selectedCombatant = self:GetCurrentCombatant()
	if selectedCombatant then
		if self.TimelapseIndex then
		--Settings.TimeLapsInterval
			selectedCombatant:CalculateSpell(1, self.ActiveDetailMode)
		else
			selectedCombatant:CalculateSpell(self:GetActiveDetailFight().Timer:GetElapsedTime(), self.ActiveDetailMode)
		end
		
		detailsPanel.PlayerNameText:SetVal("Name", selectedCombatant.Name)
	end
	for GlobalInfoIndex = 1, EXTRATYPES do
		self:DisplayGlobalInfo(GlobalInfoIndex)
	end
	
	self:DisplaySpells()
	
	self:UpdateSpellDetailsList(self.SelectedSpellIndex)
end

function TUMeterGUI:CreateTimeLapse()
	local timeLapse = self:GetActiveDetailTimeLapse()
	local fightTime = GetTableSize(timeLapse)
	self.DetailsPanel.TimeLapseScroll.Widget:RemoveItems()
	local maxAmount = 1
	for i = 1, fightTime do 
		local selectedCombatant = timeLapse[i]:GetCombatant(self.SelectedCombatantInfo.id, self.SelectedCombatantInfo.name)
		local amount = 0
		if selectedCombatant then
			amount = selectedCombatant:GetAmount(self.ActiveDetailMode)
		end
		timeLapse[i].selectedCombatant = selectedCombatant
		maxAmount = math.max(amount, maxAmount)
	end
	local btnWidth = 5
	self.DetailsPanel.BigPanel:DestroyAllChild()
	self.DetailsPanel.BigPanel:SetWidth(btnWidth*fightTime+50)
	self.DetailsPanel.BigPanel:Show()
	
	local maxBtnHeight = 230
	local minBtnHeight = 6
	
	for i = 1, fightTime do 
		local amount = 0
		local timeLapseCombatant = timeLapse[i].selectedCombatant
		local wtName = "DpsBtn" .. i
		
		if timeLapseCombatant then
			amount = timeLapseCombatant:GetAmount(self.ActiveDetailMode)
			
			if amount > 0 then
				local dpsBtn = TWidget:CreateNewObjectByDesc(wtName, self.DetailsPanel.DpsTemplateBtnDesc, self.DetailsPanel.BigPanel)	
				dpsBtn:SetPosition(btnWidth*(i-1))

				local wasDead = timeLapseCombatant:GetWasDead()
				local wasKill = timeLapseCombatant:GetWasKill()
				if wasDead and wasKill then	
					dpsBtn.Widget:SetVariant(3)
				elseif wasKill then
					dpsBtn.Widget:SetVariant(2)
				elseif wasDead then
					dpsBtn.Widget:SetVariant(1)
				end
				if self.ActiveDetailMode == enumMode.Def then
					local barrierAmount = timeLapseCombatant:GetBarrierAmount(enumMode.Def)
					if barrierAmount > 0 then
						local wtBarrierName = "BarrierBtn" .. i
						local barrierBtn = TWidget:CreateNewObjectByDesc(wtBarrierName, self.DetailsPanel.BarrierTemplateBtn, self.DetailsPanel.BigPanel)	
						barrierBtn:SetPosition(btnWidth*(i-1))
						barrierBtn:SetHeight(math.max(math.min(barrierAmount/maxAmount, 1.0)*maxBtnHeight, minBtnHeight+6))
						barrierBtn:SetWidth(btnWidth)
					end
				end
		
				--local btnHeight = math.max((amount / maxAmount)*maxBtnHeight, minBtnHeight)
				
				local btnHeight = (amount / maxAmount)*maxBtnHeight + minBtnHeight
				
				dpsBtn:SetWidth(btnWidth)
				dpsBtn:SetHeight(btnHeight)
			end
		end
		--Settings.TimeLapsInterval
		if math.fmod(i, 10) == 0 or i == 1 then
			local dpsLineIndicator = TWidget:CreateNewObjectByDesc(wtName, self.DetailsPanel.DpsTemplateLineDesc, self.DetailsPanel.BigPanel)
			dpsLineIndicator:SetPosition(btnWidth*(i-1)+btnWidth/2)
			local dpsBtnTxt = TWidget:CreateNewObjectByDesc(wtName, self.DetailsPanel.DpsTemplateTxtDesc, self.DetailsPanel.BigPanel)
			dpsBtnTxt:SetPosition(btnWidth*(i-1) - 12)
			dpsBtnTxt.Widget:SetVal("Time", cachedToWString(GetTimeString(i*1)))
		end
	end
	self.DetailsPanel.TimeLapseScroll.Widget:PushBack(self.DetailsPanel.BigPanel.Widget)
end

function TUMeterGUI:SetSelectedSpellIndex(anIndex)
	self.SelectedSpellIndex = anIndex
	if anIndex then
		self.DetailsPanel.DescText:Show()
	end
end

function TUMeterGUI:SwitchToTimeLapseElement(anIndex)
	self.TimelapseIndex = anIndex
	--Settings.TimeLapsInterval
	
	self.DetailsPanel.SpellScrollList:SetContainerOffset(0)
	self.DetailsPanel.SpellScrollList:ForceReposition()
	
	self.DetailsPanel.SpellCurrTimeText:SetVal("Time", cachedToWString(GetTimeString(self.TimelapseIndex*1)))
	
	self:UpdateValues()
end

function TUMeterGUI:SwitchToAll()
	self:ResetSelectedCombatant()
	self:UpdateSelectedCombatant()
	
	self.DetailsPanel.SpellScrollList:SetContainerOffset(0)
	self.DetailsPanel.SpellScrollList:ForceReposition()
	
	self.DetailsPanel.SpellCurrTimeText:SetVal("Time", StrAllTime)
	self:UpdateValues()
end

--------------------------------------------------------------------------------
-- Update values in both player list & spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:UpdateValues()
	self:UpdatePlayerList()
	self:UpdateSpellList()
	
	
	if not self.DetailsPanel:IsVisible() and not self.HistoryPanel:IsVisible() and self.ActiveFightMode ~= enumFight.History then
		--free memory
		self:CloseHistory()
	end
end

--==============================================================================
--================= SPELL PANEL - details list + details resist list ===========
--==============================================================================

--------------------------------------------------------------------------------
-- Display a spell details line in the spell info panel
--------------------------------------------------------------------------------
function TUMeterGUI:DisplaySpellDetails(anIndex, aSpellInfoData, aSpellInfoPanel, aTitle)
	if aSpellInfoData then
		aSpellInfoPanel:Show()

		aSpellInfoPanel.Bar:SetColor(HitTypeColors[anIndex])
		aSpellInfoPanel.Bar:SetWidth(math.max(self.DetailsPanel.SpellDetailBarWidth * (math.abs(aSpellInfoData.Percentage) / 100), 1))

		aSpellInfoPanel.Name:SetVal("Name", aTitle[anIndex])
		aSpellInfoPanel.Count:SetVal("Count", cachedFormatInt(aSpellInfoData.Count , "%d"))

		aSpellInfoPanel.DamageMin:SetVal("Min", cachedFormatFloat(aSpellInfoData.Min , "%f3K5"))
		--aSpellInfoPanel.DamageMin:SetVal("Min", cachedToWString("-9999K"))
		aSpellInfoPanel.DamageAvg:SetVal("Avg", cachedFormatFloat(TValueDetails.GetAvg(aSpellInfoData) , "%f3K5"))
		--aSpellInfoPanel.DamageAvg:SetVal("Avg", cachedToWString("-9999K"))
		aSpellInfoPanel.DamageMax:SetVal("Max", cachedFormatFloat(aSpellInfoData.Max , "%f3K5"))
		--aSpellInfoPanel.DamageMax:SetVal("Max", cachedToWString("-9999K"))
		aSpellInfoPanel.Percent:SetVal("Percentage", cachedFormatInt(aSpellInfoData.Percentage , "%d"))
	else
		if aTitle[anIndex] then
			aSpellInfoPanel:Show()
			aSpellInfoPanel.Bar:SetColor(HitTypeColors[anIndex])
			aSpellInfoPanel.Bar:SetWidth(1)
			aSpellInfoPanel.Name:SetVal("Name", aTitle[anIndex])
			aSpellInfoPanel.Count:SetVal("Count", cachedFormatInt(0 , "%d"))
			
			aSpellInfoPanel.DamageMin:SetVal("Min", StrUnknown)
			aSpellInfoPanel.DamageAvg:SetVal("Avg", StrUnknown)
			aSpellInfoPanel.DamageMax:SetVal("Max", StrUnknown)
			aSpellInfoPanel.Percent:SetVal("Percentage", StrUnknown)
		else
			aSpellInfoPanel:Hide()
		end
	end
end

function TUMeterGUI:DisplayGroupDetails(aSpellDataList, aSpellDataMaxSize, aPanelsList, aTitleList, aStartPosY)
	local index = 1
	local showedPanelsCnt = 1
	local spellDetailBarHeight = 16
	if aSpellDataList then
		for showType in SortSpellDetailsByCount(aSpellDataList) do
			self:DisplaySpellDetails(showType, aSpellDataList[showType], aPanelsList[index], aTitleList)
			aPanelsList[index]:SetPosition(nil, aStartPosY + spellDetailBarHeight*showedPanelsCnt)
			index = index + 1
			showedPanelsCnt = showedPanelsCnt + 1
		end		
	end
	for i = 1, aSpellDataMaxSize do
		if not aSpellDataList or not aSpellDataList[i] then
			aPanelsList[index]:Hide()
			index = index + 1
		end
	end
	return showedPanelsCnt - 1
end
--------------------------------------------------------------------------------
-- Fill the spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:UpdateSpellDetailsList(spellIndex)
	local selectedCombatant = self:GetCurrentCombatant()
	if spellIndex == nil or not selectedCombatant then
		self:HideAllSpellDetailsPanel()
		return
	end
	local index
	local spellData = selectedCombatant:GetSpellByIndex(spellIndex, self.ActiveDetailMode)

	if spellData then
		local someInfo = self.DPSMeter:GetInfoFromID(spellData.InfoID)
		if someInfo and someInfo.description then
			if not someInfo.cachedDesc then
				if apitype( someInfo.description ) == "ValuedText" then
					someInfo.cachedDesc = someInfo.description:ToWString()
				else
					someInfo.cachedDesc = someInfo.description
				end
			end
			self.DetailsPanel.DescText:SetVal("Desc", someInfo.cachedDesc)
		else
			self.DetailsPanel.DescText:SetVal("Desc", StrUnknown)
		end
		
		if self.ActiveDetailMode == enumMode.Hps or self.ActiveDetailMode == enumMode.IHps then
			self.DetailsPanel.DpsBuffHeaderText:SetVal("Desc", GetTextLocalized("HpsBuffHeaderText"))
			self.DetailsPanel.DefBuffHeaderText:SetVal("Desc", GetTextLocalized("AntiHpsBuffHeaderText"))
			self.DetailsPanel.ResistHeaderText:SetVal("Desc", GetTextLocalized("ResistHpsHeaderText"))
		elseif self.ActiveDetailMode == enumMode.Def then
			self.DetailsPanel.DpsBuffHeaderText:SetVal("Desc", GetTextLocalized("DpsBuffHeaderText2"))
			self.DetailsPanel.DefBuffHeaderText:SetVal("Desc", GetTextLocalized("DefBuffHeaderText2"))
			self.DetailsPanel.ResistHeaderText:SetVal("Desc", GetTextLocalized("ResistDpsHeaderText2"))
		else
			self.DetailsPanel.DpsBuffHeaderText:SetVal("Desc", GetTextLocalized("DpsBuffHeaderText"))
			self.DetailsPanel.DefBuffHeaderText:SetVal("Desc", GetTextLocalized("DefBuffHeaderText"))
			self.DetailsPanel.ResistHeaderText:SetVal("Desc", GetTextLocalized("ResistDpsHeaderText"))
		end
		
		self.DetailsPanel.DpsBuffHeaderText:Show()
		self.DetailsPanel.DefBuffHeaderText:Show()
		self.DetailsPanel.ResistHeaderText:Show()
		
		local spellDetailsOffsetX = 867
		local spellDetailsOffsetY = 55
		local spellDetailBarHeight = 16
		local showedPanelsCnt = 0
			
		showedPanelsCnt = showedPanelsCnt + self:DisplayGroupDetails(DetailsList(spellData), DMGTYPES, self.DetailsPanel.SpellInfoList, TitleDmgType, spellDetailsOffsetY)
		local dmgTypesCnt = showedPanelsCnt
		spellDetailsOffsetY = spellDetailsOffsetY + 5
		
		local showedPanelsCntBefore = showedPanelsCnt
		self.DetailsPanel.ResistHeaderText:SetPosition(spellDetailsOffsetX, spellDetailsOffsetY + (showedPanelsCnt+1)*spellDetailBarHeight)
		spellDetailsOffsetY = spellDetailsOffsetY + 20

		showedPanelsCnt = showedPanelsCnt + self:DisplayGroupDetails(MissList(spellData), MISSTYPES, self.DetailsPanel.SpellMissList, TitleMissType, spellDetailsOffsetY + showedPanelsCnt*spellDetailBarHeight)
		local resistTitle = (self.ActiveDetailMode == enumMode.Hps or self.ActiveDetailMode == enumMode.IHps) and TitleHealResistType or TitleHitBlockType
		showedPanelsCnt = showedPanelsCnt + self:DisplayGroupDetails(ResistDetailsList(spellData), BLOCKDMGTYPES, self.DetailsPanel.SpellBlockList, resistTitle, spellDetailsOffsetY + showedPanelsCnt*spellDetailBarHeight)
	
		if showedPanelsCntBefore == showedPanelsCnt then
			self.DetailsPanel.ResistHeaderText:Hide()
			spellDetailsOffsetY = spellDetailsOffsetY - 20
		end
	
		spellDetailsOffsetY = spellDetailsOffsetY + 5
		showedPanelsCntBefore = showedPanelsCnt
		self.DetailsPanel.DpsBuffHeaderText:SetPosition(spellDetailsOffsetX, spellDetailsOffsetY + (showedPanelsCnt+1)*spellDetailBarHeight)
		spellDetailsOffsetY = spellDetailsOffsetY + 20
		
		local dpsBuffList = {}
		--without defence and Weakness
		local servBuffList = BuffList(spellData)
		dpsBuffList[1] = servBuffList[enumBuff.Valor]
		dpsBuffList[2] = servBuffList[enumBuff.Vulnerability]

		showedPanelsCnt = showedPanelsCnt + self:DisplayGroupDetails(dpsBuffList, 2, self.DetailsPanel.SpellDpsBuffList, TitleBuffType, spellDetailsOffsetY + showedPanelsCnt*spellDetailBarHeight)
		
		--spellDetailsOffsetY = spellDetailsOffsetY + 5
		local customDpsBuffList = {}
		local list = CustomBuffList(spellData)
		for i = 1, DPSHPSTYPES do
			customDpsBuffList[i] = list[i]
		end
		showedPanelsCnt = showedPanelsCnt + self:DisplayGroupDetails(customDpsBuffList, DPSHPSTYPES, self.DetailsPanel.SpellCustomDpsBuffList, TitleCustomDpsBuffType, spellDetailsOffsetY + showedPanelsCnt*spellDetailBarHeight)
		
		if showedPanelsCntBefore == showedPanelsCnt then
			self.DetailsPanel.DpsBuffHeaderText:Hide()
			spellDetailsOffsetY = spellDetailsOffsetY - 20
		end
		
		spellDetailsOffsetY = spellDetailsOffsetY + 5
		showedPanelsCntBefore = showedPanelsCnt
		self.DetailsPanel.DefBuffHeaderText:SetPosition(spellDetailsOffsetX, spellDetailsOffsetY + (showedPanelsCnt+1)*spellDetailBarHeight)
		spellDetailsOffsetY = spellDetailsOffsetY + 20
		
		--defence and Weakness
		local defBuffList = {}
		defBuffList[1] = servBuffList[enumBuff.Weakness]
		defBuffList[2] = servBuffList[enumBuff.Defense]
		local TitleDefBuffType = {}
		TitleDefBuffType[1] = TitleBuffType[enumBuff.Weakness]
		TitleDefBuffType[2] = TitleBuffType[enumBuff.Defense]
		showedPanelsCnt = showedPanelsCnt + self:DisplayGroupDetails(defBuffList, 2, self.DetailsPanel.SpellDefBuffList, TitleDefBuffType, spellDetailsOffsetY + showedPanelsCnt*spellDetailBarHeight)
		
		--spellDetailsOffsetY = spellDetailsOffsetY + 5
		local customDefBuffList = {}
		for i = 1, DEFTYPES do
			customDefBuffList[i] = list[DPSHPSTYPES + i]
		end
		showedPanelsCnt = showedPanelsCnt + self:DisplayGroupDetails(customDefBuffList, DEFTYPES, self.DetailsPanel.SpellCustomDefBuffList, TitleCustomDefBuffType, spellDetailsOffsetY + showedPanelsCnt*spellDetailBarHeight)
		
		if showedPanelsCntBefore == showedPanelsCnt then
			self.DetailsPanel.DefBuffHeaderText:Hide()
			spellDetailsOffsetY = spellDetailsOffsetY - 20
		end

		self.DetailsPanel:SetHeight(math.max(self.DetailsPanel.DetailsPanelHeight, (showedPanelsCnt+1)*spellDetailBarHeight+160))
	end
end
--------------------------------------------------------------------------------
-- Hide all spell info line
--------------------------------------------------------------------------------
function TUMeterGUI:HideAllSpellDetailsPanel()
	for i = 1, DMGTYPES do
		self.DetailsPanel.SpellInfoList[i]:Hide()
	end
	for i = 1, MISSTYPES do
		self.DetailsPanel.SpellMissList[i]:Hide()
	end
	for i = 1, 2 do
		self.DetailsPanel.SpellDpsBuffList[i]:Hide()
	end
	for i = 1, 2 do
		self.DetailsPanel.SpellDefBuffList[i]:Hide()
	end
	for i = 1, DEFTYPES do
		self.DetailsPanel.SpellCustomDefBuffList[i]:Hide()
	end
	for i = 1, DPSHPSTYPES do
		self.DetailsPanel.SpellCustomDpsBuffList[i]:Hide()
	end
	
	for i = 1, BLOCKDMGTYPES do
		self.DetailsPanel.SpellBlockList[i]:Hide()
	end
	self.DetailsPanel.DescText:Hide()
	
	self.DetailsPanel.DpsBuffHeaderText:Hide()
	self.DetailsPanel.DefBuffHeaderText:Hide()
	self.DetailsPanel.ResistHeaderText:Hide()
end

--==============================================================================
--================= Event implementation =======================================
--==============================================================================

--------------------------------------------------------------------------------
-- Swap to the next fight
--------------------------------------------------------------------------------
function TUMeterGUI:SwapFight()
	self.ActiveFightMode = math.fmod(self.ActiveFightMode + 1, 2)

	self.MainPanel.FightText:SetVal("Name", TitleFight[self.ActiveFightMode])

	self:UpdateValues()
end

function TUMeterGUI:SwapFightDetailsPanel()
	if self.ActiveFightDetailMode == enumFight.History then
		return
	end
	self.ActiveFightDetailMode = math.fmod(self.ActiveFightDetailMode + 1, 2)
	self:ResetSelectedCombatant()
	self:UpdateSelectedCombatant()
	
	self.DetailsPanel.FightText:SetVal("Name", TitleFight[self.ActiveFightDetailMode])
	self.DetailsPanel.PlayerNameText:SetVal("Fight", TitleFight[self.ActiveFightDetailMode])
	self.DetailsPanel.SpellCurrTimeText:SetVal("Time", StrAllTime)
	
	self.DetailsPanel.SpellScrollList:SetContainerOffset(0)
	self.DetailsPanel.SpellScrollList:ForceReposition()
	
	self:GetActiveDetailFight():PrepareShowDetails(self.SelectedCombatantInfo)
	self:CreateTimeLapse()
	self:UpdateValues()
end

--------------------------------------------------------------------------------
-- Swap to the next mode
--------------------------------------------------------------------------------
function TUMeterGUI:SwapMode()
	local rotateMode = {
		[enumMode.Dps] = Settings.ModeHPS and enumMode.Hps or Settings.ModeDEF and enumMode.Def or Settings.ModeIHPS and enumMode.IHps or enumMode.Dps,
		[enumMode.Hps] = Settings.ModeDEF and enumMode.Def or Settings.ModeIHPS and enumMode.IHps or Settings.ModeDPS and enumMode.Dps or enumMode.Hps,
		[enumMode.Def] = Settings.ModeIHPS and enumMode.IHps or Settings.ModeDPS and enumMode.Dps or Settings.ModeHPS and enumMode.Hps or enumMode.Def,
		[enumMode.IHps]= Settings.ModeDPS and enumMode.Dps or Settings.ModeHPS and enumMode.Hps or Settings.ModeDEF and enumMode.Def or enumMode.IHps
	}
	self.ActiveMode = rotateMode[self.ActiveMode]

	-- Update the mode in the fight panel (at the top of the player list)
	self.MainPanel.ModeText:SetVal("Name", TitleMode[self.ActiveMode])
	self:UpdateValues()
end

function TUMeterGUI:SwapDetailsMode()
	local rotateMode = {
		[enumMode.Dps] = Settings.ModeHPS and enumMode.Hps or Settings.ModeDEF and enumMode.Def or Settings.ModeIHPS and enumMode.IHps or enumMode.Dps,
		[enumMode.Hps] = Settings.ModeDEF and enumMode.Def or Settings.ModeIHPS and enumMode.IHps or Settings.ModeDPS and enumMode.Dps or enumMode.Hps,
		[enumMode.Def] = Settings.ModeIHPS and enumMode.IHps or Settings.ModeDPS and enumMode.Dps or Settings.ModeHPS and enumMode.Hps or enumMode.Def,
		[enumMode.IHps]= Settings.ModeDPS and enumMode.Dps or Settings.ModeHPS and enumMode.Hps or Settings.ModeDEF and enumMode.Def or enumMode.IHps
	}
	self.ActiveDetailMode = rotateMode[self.ActiveDetailMode]
	-- Update the mode in the fight panel (at the top of the player list)
	self.DetailsPanel.ModeText:SetVal("Name", TitleMode[self.ActiveDetailMode])

	-- Update the mode in the title of the spell panel
	self.DetailsPanel.PlayerNameText:SetVal("Mode", TitleMode[self.ActiveDetailMode])
	
	self.DetailsPanel.SpellScrollList:SetContainerOffset(0)
	self.DetailsPanel.SpellScrollList:ForceReposition()

	-- Update the mode in the header of the spell panel
	self.DetailsPanel.SpellHeaderStatsText:SetVal("DPS", TitleMode[self.ActiveDetailMode])
	self:CreateTimeLapse()
	self:UpdateValues()
end
--------------------------------------------------------------------------------
-- Swap to the next mode
--------------------------------------------------------------------------------
function TUMeterGUI:Reset(fullReset)
	self.DPSMeter:ResetAllFights(fullReset)
	self.ActiveFightMode = enumFight.Current
	self.MainPanel.FightText:SetVal("Name", TitleFight[self.ActiveFightMode])
	self.DetailsPanel.SpellScrollList:SetContainerOffset(0)
	self.DetailsPanel.SpellScrollList:ForceReposition()
	self:UpdateValues()
end

function TUMeterGUI:FillHistoryScroll(aList, aBtnSysName, aBtnShowName, aScrollList)
	local cnt = 1
	aScrollList:ClearScrollList()
	for historyElement in aList:iterate() do
		local wtName = aBtnSysName..tostring(cnt)
		local btnWdg = TWidget:CreateNewObjectByDesc(wtName, self.HistoryPanel.HistoryBtnDesc, self.HistoryPanel)
		local nameStr = cachedFromWString(aBtnShowName).." -"..tostring(cnt)
		btnWdg:SetVal("button_label", cachedToWString(nameStr))
		btnWdg:Show()
		aScrollList.Widget:PushBack(btnWdg.Widget)
		cnt = cnt + 1
	end
end

function TUMeterGUI:UpdateHistory()
	self.ActiveHistoryTotalList = self.DPSMeter.HistoryTotalFights:copy()
	self.ActiveHistoryCurrentList = self.DPSMeter.HistoryCurrentFights:copy()
	
	self:FillHistoryScroll(self.ActiveHistoryTotalList, "HistoryTotalBtn", TitleFight[enumFight.Total], self.HistoryPanel.TotalScrollList)
	self:FillHistoryScroll(self.ActiveHistoryCurrentList, "HistoryCurrentBtn", TitleFight[enumFight.Current], self.HistoryPanel.CurrentScrollList)
end

function TUMeterGUI:CloseHistory()
	self.ActiveHistoryTotalList = nil
	self.ActiveHistoryCurrentList = nil
	self.ActiveHistoryFight = nil
end

function TUMeterGUI:HistorySelected(aList, anIndex)
	self.ActiveHistoryFight = aList:getByNum(anIndex)
	self.ActiveFightMode = enumFight.History
	self.MainPanel.FightText:SetVal("Name", TitleFight[self.ActiveFightMode])
	self.DetailsPanel:DnDHide()
	self:DetailsClosed()
end

function TUMeterGUI:HistoryTotalSelected(anIndex)
	self:HistorySelected(self.ActiveHistoryTotalList, anIndex)
end

function TUMeterGUI:HistoryCurrentSelected(anIndex)
	self:HistorySelected(self.ActiveHistoryCurrentList, anIndex)
end

function ScaleFontSpellDetailsPanelGUI(aSpellDetailsPanel)
	if Settings.ScaleFonts then
		aSpellDetailsPanel.Name:SetTextAttributes("Name", nil, 13)
		aSpellDetailsPanel.Count:SetTextAttributes("Count", nil, 13)
		aSpellDetailsPanel.DamageMin:SetTextAttributes("Min", nil, 13)
		aSpellDetailsPanel.DamageAvg:SetTextAttributes("Avg", nil, 13)
		aSpellDetailsPanel.DamageMax:SetTextAttributes("Max", nil, 13)
		aSpellDetailsPanel.Percent:SetTextAttributes("Percentage", nil, 13)
	end
end

--==============================================================================
--================= INIT =======================================================
--==============================================================================
function TUMeterGUI:CreateNewSpellPanel()
	local spellIndex = GetTableSize(self.DetailsPanel.SpellList) + 1
	local wtName = "SpellPanel" .. spellIndex
	local newSpellPanel = TSpellPanelGUI:CreateNewObjectByDesc(wtName, GetDescFromResource("SpellPanel"), self.DetailsPanel)
	newSpellPanel:SetWidth(self.DetailsPanel.SpellBarWidth)
	self.DetailsPanel.SpellScrollList:PushBack(newSpellPanel.Widget)
	
	if Settings.ScaleFonts then
		newSpellPanel.Index:SetTextAttributes("Index", nil, 14)
		newSpellPanel.Type:SetTextAttributes("Type", nil, 14)
		newSpellPanel.Name:SetTextAttributes("PetName", nil, 14)
		newSpellPanel.Name:SetTextAttributes("Name", nil, 14)
		newSpellPanel.Damage:SetTextAttributes("DamageDone", nil, 14)
		newSpellPanel.Damage:SetTextAttributes("DPS", nil, 14)
		newSpellPanel.CPS:SetTextAttributes("CPS", nil, 14)
		newSpellPanel.DmgBlock:SetTextAttributes("DamageBlock", nil, 14)
		newSpellPanel.Percent:SetTextAttributes("Percentage", nil, 14)
	else
		newSpellPanel.Index:SetPosition(nil, 1)
		newSpellPanel.Type:SetPosition(nil, 1)
		newSpellPanel.Name:SetPosition(nil, 1)
		newSpellPanel.Damage:SetPosition(nil, 1)
		newSpellPanel.CPS:SetPosition(nil, 1)
		newSpellPanel.DmgBlock:SetPosition(nil, 1)
		newSpellPanel.Percent:SetPosition(nil, 1)
	end
	
	self.DetailsPanel.SpellList[spellIndex] = newSpellPanel
end

function TUMeterGUI:Init()
	-- Initialize localizations
	StrTypePet = GetTextLocalized("TypePet")
	StrTypeAbility = GetTextLocalized("TypeAbility")
	StrTypeSpell = GetTextLocalized("TypeSpell")
	StrTypeMap = GetTextLocalized("TypeMap")
	StrTypeBuff = GetTextLocalized("TypeBuff")
	
	StrDamagePool = GetTextLocalized("DamagePool")
	StrFromBarrier = GetTextLocalized("FromBarrier")
	
	StrNone = userMods.ToWString("")
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
	TitleHealResistType[enumHealResist.RuneResisted] = GetTextLocalized("HealRuneResisted")
	TitleHealResistType[enumHealResist.Absorbed] = GetTextLocalized("Absorbed")
	TitleHealResistType[enumHealResist.Overload] = GetTextLocalized("Overload")

	TitleGlobalInfoType[enumGlobalInfo.Determination] = GetTextLocalized("Determination")
	TitleGlobalInfoType[enumGlobalInfo.Critical] = GetTextLocalized("Critical")
	TitleGlobalInfoType[enumGlobalInfo.Physical] = GetTextLocalized("Physical")
	TitleGlobalInfoType[enumGlobalInfo.Elemental] = GetTextLocalized("Elemental")
	TitleGlobalInfoType[enumGlobalInfo.Holy] = GetTextLocalized("Holy")
	TitleGlobalInfoType[enumGlobalInfo.Natural] = GetTextLocalized("Natural")
	
	-- Default mode
	self.ActiveMode = Settings.DefaultMode
	self.ActiveFightMode = enumFight.Current

	-- The "D" button to show or hide the main panels
	self.ShowHideBtn = TWidget:CreateNewObject("ShowHideBtn")
	self.ShowHideBtn:DragNDrop(true, true)

	-- Main panel with player list
	self.MainPanel = TMainPanelGUI:CreateNewObject("MainPanel")
	self.MainPanel:DragNDrop(true, true, false)

	
	self.SettingsPanel = TSettingsPanelGUI:CreateNewObject("SettingsPanel")
	self.SettingsPanel:DragNDrop(true, true)
	self.SettingsPanel.DefCheckBoxText:SetVal("Name", GetTextLocalized("SettingsDef"))
	self.SettingsPanel.DpsCheckBoxText:SetVal("Name", GetTextLocalized("SettingsDps"))
	self.SettingsPanel.HpsCheckBoxText:SetVal("Name", GetTextLocalized("SettingsHps"))
	self.SettingsPanel.IhpsCheckBoxText:SetVal("Name", GetTextLocalized("SettingsIhps"))
	self.SettingsPanel.TotalTimelapseCheckBoxText:SetVal("Name", GetTextLocalized("TotalTimelapseCheckBoxText"))
	self.SettingsPanel.ShowScoreCheckBoxText:SetVal("Name", GetTextLocalized("ShowScoreCheckBoxText"))
	self.SettingsPanel.ScaleFontsCheckBoxText:SetVal("Name", GetTextLocalized("ScaleFontsCheckBoxText"))
	
	self.SettingsPanel.SkipPetCheckBoxText:SetVal("Name", GetTextLocalized("StrSettingsIgnorePet"))
	self.SettingsPanel.StartHidedCheckBoxText:SetVal("Name", GetTextLocalized("StrSettingsStartHided"))
	self.SettingsPanel.SkipYourselfCheckBoxText:SetVal("Name", GetTextLocalized("StrSettingsIgnoreYourself"))
	self.SettingsPanel.CombatantCntText:SetVal("Name", GetTextLocalized("StrCombatantCntText"))
	self.SettingsPanel.SaveBtn:SetVal("button_label", GetTextLocalized("SettingsSave"))
	self.SettingsPanel.HeaderText:SetVal("Name", GetTextLocalized("StrSettings"))
	self.SettingsPanel.MaxCombatantTextEdit:SetText(cachedFormatInt(Settings.MaxCombatants, "%d"))
	
	SetCheckedForCheckBox(self.SettingsPanel.DpsCheckBox, Settings.ModeDPS)
	SetCheckedForCheckBox(self.SettingsPanel.HpsCheckBox, Settings.ModeHPS)
	SetCheckedForCheckBox(self.SettingsPanel.DefCheckBox, Settings.ModeDEF)
	SetCheckedForCheckBox(self.SettingsPanel.IhpsCheckBox, Settings.ModeIHPS)
	SetCheckedForCheckBox(self.SettingsPanel.SkipPetCheckBox, Settings.SkipDmgAndHpsOnPet)
	SetCheckedForCheckBox(self.SettingsPanel.SkipYourselfCheckBox, Settings.SkipDmgYourselfIn)
	SetCheckedForCheckBox(self.SettingsPanel.StartHidedCheckBox, Settings.StartHided)
	SetCheckedForCheckBox(self.SettingsPanel.TotalTimelapseCheckBox, Settings.CollectTotalTimelapse)
	SetCheckedForCheckBox(self.SettingsPanel.ShowScoreCheckBox, Settings.ShowPositionOnBtn)
	SetCheckedForCheckBox(self.SettingsPanel.ScaleFontsCheckBox, Settings.ScaleFonts)
		
	
	self.HistoryPanel = THistoryPanelGUI:CreateNewObject("HistoryPanel")
	self.HistoryPanel:DragNDrop(true, true)
	self.HistoryPanel.HeaderCurrentText:SetVal("Name", GetTextLocalized("HeaderCurrent"))
	self.HistoryPanel.HeaderTotalText:SetVal("Name", GetTextLocalized("HeaderTotal"))
	self.HistoryPanel.HeaderText:SetVal("Name", GetTextLocalized("History"))
	self.HistoryPanel.CurrentScrollList:SetPosition(nil, 30)
	self.HistoryPanel.TotalScrollList:SetPosition(nil, 30)
			
	

	-- Secondary panel with spell list / details
	self.DetailsPanel = TDetailsPanelGUI:CreateNewObject("SpellInfoPanel")
	self.DetailsPanel:DragNDrop(true, true)

	-------------------------------------------------------------------------------
	-- Widget description
	-------------------------------------------------------------------------------
	local totalPanelDesc = GetDescFromResource("TotalInfoPanel")
	local playerPanelDesc = GetDescFromResource("PlayerInfoPanel")
	local spellInfoPanelDesc = GetDescFromResource("SpellDetailPanel")

	-------------------------------------------------------------------------------
	-- Main Panel
	-------------------------------------------------------------------------------
	if Settings.ScaleFonts then
		self.BarWidth = 295
		self.MainPanel:SetWidth(370)
	else
		self.MainPanel:SetWidth(330)
	end
	
	-- Total panel
	self.MainPanel.TotalPanel = TTotalPanelGUI:CreateNewObjectByDesc("TotalPanel", totalPanelDesc, self.MainPanel)
	self.MainPanel.TotalPanel:SetPosition(20, 47)
	self.MainPanel.TotalPanel:Show()
	self.MainPanel.TotalPanel.Bar:SetWidth(self.BarWidth)
	self.MainPanel.TotalPanel:SetWidth(self.BarWidth + 26)
	if Settings.ScaleFonts then
		self.MainPanel.TotalPanel.Name:SetTextAttributes("Minute", nil, 16)
		self.MainPanel.TotalPanel.Name:SetTextAttributes("Second", nil, 16)
		self.MainPanel.TotalPanel.Value:SetTextAttributes("DamageDone", nil, 16)
		self.MainPanel.TotalPanel.Value:SetTextAttributes("DPS", nil, 16)
		self.MainPanel.TotalPanel.Value:SetPosition(175)
	end

	-- Player list
	for playerIndex = 1, Settings.MaxCombatants do
		local wtName = "PlayerPanel" .. playerIndex
		self.MainPanel.PlayerList[playerIndex] = TPlayerPanelGUI:CreateNewObjectByDesc(wtName, playerPanelDesc, self.MainPanel)
		self.MainPanel.PlayerList[playerIndex]:SetPosition(20, 47 + playerIndex * 24)
		self.MainPanel.PlayerList[playerIndex]:SetWidth(self.BarWidth + 26)
		if Settings.ScaleFonts then
			self.MainPanel.PlayerList[playerIndex].Name:SetTextAttributes("Index", nil, 16)
			self.MainPanel.PlayerList[playerIndex].Name:SetTextAttributes("Name", nil, 16)
			self.MainPanel.PlayerList[playerIndex].Percent:SetTextAttributes("Percentage", nil, 16)
			self.MainPanel.PlayerList[playerIndex].Value:SetTextAttributes("DamageDone", nil, 16)
			self.MainPanel.PlayerList[playerIndex].Value:SetTextAttributes("DPS", nil, 16)
			self.MainPanel.PlayerList[playerIndex].Value:SetPosition(175)
		end
	end

	
	
	-------------------------------------------------------------------------------
	-- Spell Panel
	-------------------------------------------------------------------------------

	self.DetailsPanel.AllTimeBtn:SetVal("button_label", StrAllTime)
	self.DetailsPanel.UpdateTimeLapseBtn:SetVal("button_label", GetTextLocalized("StrUpdateTimeLapse"))
	
	
	local spellOffsetX = 407

	self.DetailsPanel.PlayerNameText:Show(true)
	self.DetailsPanel.SpellScrollList:Show(true)
	self.DetailsPanel.TimeLapsePanel:Show()
	self.DetailsPanel.AllTimeBtn:Show()
	self.DetailsPanel.UpdateTimeLapseBtn:Show()
	self.DetailsPanel.SpellCurrTimeText:Show()
	self.DetailsPanel.SpellDetailsHeaderPanel:Show()	
	self.DetailsPanel.CloseButton:Show()
		
	-- GlobalInfoHeader
	local globalInfoHeaderOffset = 55
	self.DetailsPanel.GlobalInfoHeaderPanel:SetWidth(self.DetailsPanel.SpellGlobalBarWidth)
	self.DetailsPanel.GlobalInfoHeaderPanel:SetPosition(spellOffsetX, globalInfoHeaderOffset)
	self.DetailsPanel.GlobalInfoHeaderPanel:Show()

	-- GlobalInfo list
	local GlobalInfoOffset = globalInfoHeaderOffset + 18
	for extraIndex = 1, EXTRATYPES do
		local wtName = "GlobalInfoPanel" .. extraIndex
		self.DetailsPanel.GlobalInfoList[extraIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.GlobalInfoList[extraIndex]:SetWidth(self.DetailsPanel.SpellGlobalBarWidth)
		self.DetailsPanel.GlobalInfoList[extraIndex]:SetPosition(spellOffsetX, GlobalInfoOffset + (extraIndex-1) * 18)
		ScaleFontSpellDetailsPanelGUI(self.DetailsPanel.GlobalInfoList[extraIndex])
	end

	-- SpellHeader
	local spellHeaderOffset = GlobalInfoOffset + EXTRATYPES * 18 + 7
	self.DetailsPanel.SpellHeaderPanel:SetPosition(spellOffsetX, spellHeaderOffset)
	self.DetailsPanel.SpellHeaderPanel:SetWidth(self.DetailsPanel.SpellBarWidth)
	self.DetailsPanel.SpellHeaderPanel:Show()

	-- Spell list
	local spellListOffset = spellHeaderOffset + 18
	
	local spellScrollListPos = self.DetailsPanel.SpellScrollList:GetPlacementPlain()
	spellScrollListPos.posX = spellOffsetX - 4
	spellScrollListPos.posY = spellListOffset
	spellScrollListPos.sizeY = 250
	spellScrollListPos.sizeX = self.DetailsPanel.SpellBarWidth + 26
	spellScrollListPos.alignX = WIDGET_ALIGN_LOW
	spellScrollListPos.alignY = WIDGET_ALIGN_LOW
	self.DetailsPanel.SpellScrollList:SetPlacementPlain(spellScrollListPos)
	
	
	for spellIndex = 1, INITSPELLSCNT do
		self:CreateNewSpellPanel()
	end
	
	-- SpellDetailsHeader
	local spellDetailsOffsetY = 55
	local spellDetailsOffsetX = 867
	local spellDetailBarHeight = 16

	self.DetailsPanel.SpellDetailsHeaderPanel:SetPosition(spellDetailsOffsetX, spellDetailsOffsetY)
	spellDetailsOffsetY = spellDetailsOffsetY + 20
	self.DetailsPanel.ResistHeaderText:SetPosition(spellDetailsOffsetX, spellDetailsOffsetY)
	spellDetailsOffsetY = spellDetailsOffsetY + 20
	self.DetailsPanel.DpsBuffHeaderText:SetPosition(spellDetailsOffsetX, spellDetailsOffsetY)
	spellDetailsOffsetY = spellDetailsOffsetY + 20
	self.DetailsPanel.DefBuffHeaderText:SetPosition(spellDetailsOffsetX, spellDetailsOffsetY)	
		
	self.DetailsPanel.DpsBuffHeaderText:SetVal("Desc", GetTextLocalized("DpsBuffHeaderText"))
	self.DetailsPanel.DefBuffHeaderText:SetVal("Desc", GetTextLocalized("DefBuffHeaderText"))
	self.DetailsPanel.ResistHeaderText:SetVal("Desc", GetTextLocalized("ResistDpsHeaderText"))
	

	-- Spell info
	local damageOffset = spellDetailsOffsetY + spellDetailBarHeight
	for infoIndex = 1, DMGTYPES do
		local wtName = "SpellInfoPanel" .. infoIndex
		self.DetailsPanel.SpellInfoList[infoIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellInfoList[infoIndex]:SetPosition(spellDetailsOffsetX, damageOffset + (infoIndex-1) * spellDetailBarHeight)
		ScaleFontSpellDetailsPanelGUI(self.DetailsPanel.SpellInfoList[infoIndex])
	end

	-- Spell miss
	local missOffset = damageOffset + DMGTYPES * spellDetailBarHeight + 5
	for missIndex = 1, MISSTYPES do
		local wtName = "SpellMissPanel" .. missIndex
		self.DetailsPanel.SpellMissList[missIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellMissList[missIndex]:SetPosition(spellDetailsOffsetX, missOffset + (missIndex-1) * spellDetailBarHeight)
		ScaleFontSpellDetailsPanelGUI(self.DetailsPanel.SpellMissList[missIndex])
	end
	
	-- Spell block
	local blockDamageOffset = missOffset + MISSTYPES * spellDetailBarHeight + 5
	for blockIndex = 1, BLOCKDMGTYPES do
		local wtName = "SpellBlckPanel" .. blockIndex
		self.DetailsPanel.SpellBlockList[blockIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellBlockList[blockIndex]:SetPosition(spellDetailsOffsetX, blockDamageOffset + (blockIndex-1) * spellDetailBarHeight)
		ScaleFontSpellDetailsPanelGUI(self.DetailsPanel.SpellBlockList[blockIndex])
	end
	
	--Spell buff
	local buffOffset = blockDamageOffset + BLOCKDMGTYPES * spellDetailBarHeight + 5
	for buffIndex = 1, 2 do
		local wtName = "SpellDpsBuffPanel" .. buffIndex
		self.DetailsPanel.SpellDpsBuffList[buffIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellDpsBuffList[buffIndex]:SetPosition(spellDetailsOffsetX, buffOffset + (buffIndex-1) * spellDetailBarHeight)
		ScaleFontSpellDetailsPanelGUI(self.DetailsPanel.SpellDpsBuffList[buffIndex])
	end
	for buffIndex = 1, 2 do
		local wtName = "SpellDefBuffPanel1" .. buffIndex
		self.DetailsPanel.SpellDefBuffList[buffIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellDefBuffList[buffIndex]:SetPosition(spellDetailsOffsetX, buffOffset + (2 + buffIndex - 1) * spellDetailBarHeight)
		ScaleFontSpellDetailsPanelGUI(self.DetailsPanel.SpellDefBuffList[buffIndex])
	end
	
	--Spell custom buff
	local customBuffOffset = buffOffset + BUFFTYPES * spellDetailBarHeight + 5
	for buffIndex = 1, DPSHPSTYPES do
		local wtName = "SpellCustomDpsBuffPanel" .. buffIndex
		self.DetailsPanel.SpellCustomDpsBuffList[buffIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellCustomDpsBuffList[buffIndex]:SetPosition(spellDetailsOffsetX, customBuffOffset + (buffIndex-1) * spellDetailBarHeight)
		ScaleFontSpellDetailsPanelGUI(self.DetailsPanel.SpellCustomDpsBuffList[buffIndex])
	end
	customBuffOffset = buffOffset + DPSHPSTYPES * spellDetailBarHeight + 5
	for buffIndex = 1, DEFTYPES do
		local wtName = "SpellCustomDefBuffPanel" .. buffIndex
		self.DetailsPanel.SpellCustomDefBuffList[buffIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellCustomDefBuffList[buffIndex]:SetPosition(spellDetailsOffsetX, customBuffOffset + (buffIndex-1) * spellDetailBarHeight)
		ScaleFontSpellDetailsPanelGUI(self.DetailsPanel.SpellCustomDefBuffList[buffIndex])
	end

	
	self.DetailsPanel.AllTimeBtn:SetPosition(20, 350)
	self.DetailsPanel.UpdateTimeLapseBtn:SetPosition(110, 350)
	
	self.DetailsPanel.ModeBtn:SetPosition(480, 28)
	self.DetailsPanel.FightBtn:SetPosition(550, 28)
	
	
	
	

	self.DetailsPanel.GlobalInfoHeaderNameText:SetVal("Name", GetTextLocalized("GlobalInfo"))
	self.DetailsPanel.GlobalInfoHeaderStatsMinText:SetVal("Min", GetTextLocalized("Min"))
	self.DetailsPanel.GlobalInfoHeaderStatsAvgText:SetVal("Avg", GetTextLocalized("Avg"))
	self.DetailsPanel.GlobalInfoHeaderStatsMaxText:SetVal("Max", GetTextLocalized("Max"))

	self.DetailsPanel.SpellHeaderTypeText:SetVal("Type", GetTextLocalized("Type"))
	self.DetailsPanel.SpellHeaderNameText:SetVal("Name", GetTextLocalized("Ability"))
	self.DetailsPanel.SpellHeaderStatsText:SetVal("DamageDone", GetTextLocalized("Dmg"))
	self.DetailsPanel.SpellHeaderDmgBlockText:SetVal("Absorbed", GetTextLocalized("Abs"))
	self.DetailsPanel.SpellHeaderCPSText:SetVal("CPS", GetTextLocalized("CPS"))

	self.DetailsPanel.SpellDetailsHeaderNameText:SetVal("Name", GetTextLocalized("Type"))
	self.DetailsPanel.SpellDetailsHeaderStatsMinText:SetVal("Min", GetTextLocalized("Min"))
	self.DetailsPanel.SpellDetailsHeaderStatsAvgText:SetVal("Avg", GetTextLocalized("Avg"))
	self.DetailsPanel.SpellDetailsHeaderStatsMaxText:SetVal("Max", GetTextLocalized("Max"))
	
	self.DetailsPanel.SpellCurrTimeText:SetVal("Name", GetTextLocalized("Showed"))
	self.DetailsPanel.SpellCurrTimeText:SetVal("Time", StrAllTime)
	self.DetailsPanel.DescText:SetVal("Desc", userMods.ToWString(" "))



	-- Update the mode in the fight panel (at the top of the player list)
	self.MainPanel.ModeText:SetVal("Name", TitleMode[self.ActiveMode])

	-- Update the mode in the title of the spell panel
	self.DetailsPanel.PlayerNameText:SetVal("Mode", TitleMode[self.ActiveMode])

	-- Update the mode in the header of the spell panel
	self.DetailsPanel.SpellHeaderStatsText:SetVal("DPS", TitleMode[self.ActiveMode])

	self:Reset()
	
	-- Update the fight in the fight panel (at the top of the player list)
	self.MainPanel.FightText:SetVal("Name", TitleFight[self.ActiveFightMode])

	-- Update the fight in the title of the spell panel
	self.DetailsPanel.PlayerNameText:SetVal("Fight", TitleFight[self.ActiveFightMode])
end
