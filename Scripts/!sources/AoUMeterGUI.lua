--------------------------------------------------------------------------------
-- File: AoUMeterGUI.lua
-- Desc: Graphical user interface
--------------------------------------------------------------------------------

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
			TotalPanel = widget:GetChildByName("TotalInfoPanel"), -- Panel to display the total
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
			PlayerNameText = widget:GetChildByName("SpellPlayerNameTextViewName").Widget,

			GlobalInfoHeaderPanel = widget:GetChildByName("GlobalInfoHeaderPanel"),
			GlobalInfoHeaderNameText = widget.Widget:GetChildChecked("GlobalInfoHeaderTextViewName", true),
			GlobalInfoHeaderStatsText = widget.Widget:GetChildChecked("GlobalInfoHeaderTextViewStats", true),
			GlobalInfoList = {},     -- Panel extra info list

			SpellHeaderPanel = widget:GetChildByName("SpellHeaderPanel"), -- Header panel
			SpellHeaderNameText = widget.Widget:GetChildChecked("SpellHeaderTextViewName", true),
			SpellHeaderStatsText = widget.Widget:GetChildChecked("SpellHeaderTextViewStats", true),
			SpellList = {},         -- Panel spell list

			SpellDetailsHeaderPanel = widget:GetChildByName("SpellDetailHeaderPanel"),
			SpellDetailsHeaderNameText = widget.Widget:GetChildChecked("SpellDetailHeaderTextViewName", true),
			SpellDetailsHeaderStatsText = widget.Widget:GetChildChecked("SpellDetailHeaderTextViewStats", true),  
			SpellInfoList = {},     -- Panel spell info list (normal, critical, glancing)
			SpellMissList = {},     -- Panel miss list
			SpellBlockList = {},    -- Panel block list
			
			SpellScrollList = widget.Widget:GetChildChecked("ScrollableContainerV", true),
			TimeLapsePanel = widget:GetChildByName("ScrollDPSPanel"),
			TimeLapseScroll = widget:GetChildByName("ScrollDPSPanel"):GetChildByName("ScrollableContainerH"),
			DpsTemplateBtnDesc = widget:GetChildByName("ScrollDPSPanel"):GetChildByName("ElementPanel"):GetDesc(),
			AllTimeBtn = widget:GetChildByName("AllTimeBtn").Widget,
			UpdateTimeLapseBtn = widget:GetChildByName("UpdateTimeLapseBtn").Widget,
			SpellCurrTimeText = widget.Widget:GetChildChecked("SpellCurrTimeTextView", true),
			DescText = widget.Widget:GetChildChecked("DescTextView", true),
		}, { __index = widget })
end
--------------------------------------------------------------------------------
-- Type TMainPanelGUI
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
			DescCheckBoxText = widget:GetChildByName("DescCheckBoxText").Widget,
			SkipPetCheckBoxText = widget:GetChildByName("SkipPetCheckBoxText").Widget,
			SkipYourselfCheckBoxText = widget:GetChildByName("SkipYourselfCheckBoxText").Widget,
			CombatantCntText = widget:GetChildByName("CombatantCntText").Widget,
			TimeLapsIntervalText = widget:GetChildByName("TimeLapsIntervalText").Widget,
			
			DefCheckBox = widget:GetChildByName("DefCheckBox").Widget,
			DpsCheckBox = widget:GetChildByName("DpsCheckBox").Widget,
			HpsCheckBox = widget:GetChildByName("HpsCheckBox").Widget,
			IhpsCheckBox = widget:GetChildByName("IhpsCheckBox").Widget,
			DescCheckBox = widget:GetChildByName("DescCheckBox").Widget,
			SkipPetCheckBox = widget:GetChildByName("SkipPetCheckBox").Widget,
			SkipYourselfCheckBox = widget:GetChildByName("SkipYourselfCheckBox").Widget,
			MaxCombatantTextEdit = widget:GetChildByName("SettingsMaxCombatant").Widget,
			TimeLapsIntervalEdit = widget:GetChildByName("TimeLapsIntervalEdit").Widget,
			
			HeaderText = widget:GetChildByName("HeaderText").Widget,
			
			SaveBtn = widget:GetChildByName("SaveBtn").Widget,
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
			Name = widget:GetChildByName("TotalInfoTextViewName").Widget,
			Value = widget:GetChildByName("PlayerInfoTextViewStats").Widget
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
			Name = widget:GetChildByName("PlayerInfoTextViewName").Widget,
			Value = widget:GetChildByName("PlayerInfoTextViewStats").Widget,
			Percent = widget:GetChildByName("PlayerInfoTextViewPercentage").Widget,
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
			Name = widget:GetChildByName("SpellTextViewName").Widget,
			Damage = widget:GetChildByName("SpellTextViewStats").Widget,
			Percent = widget:GetChildByName("SpellTextViewPercentage").Widget,
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
			Name = widget:GetChildByName("SpellDetailTextViewName").Widget,
			Count = widget:GetChildByName("SpellDetailTextViewCount").Widget,
			Damage = widget:GetChildByName("SpellDetailTextViewStats").Widget,
			Percent = widget:GetChildByName("SpellDetailTextViewPercentage").Widget,
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

			ActiveFight = dpsMeter.Fight.Current,   -- Active fight
			ActiveMode = enumMode.Dps,          -- Active mode
			SelectedCombatant = nil,            -- Selected combatant
			SelectedCombatantInfo = nil,         -- Selected combatant info (id, persistentId, name)
			timelapseIndex = nil,

			ShowHideBtn = nil,      -- "D" button to show/hide the addon
			MainPanel = nil,        -- Main panel with player list
			DetailsPanel = nil,     -- Details panel with spell list / details
			SettingsPanel = nil,

			InitialSize = {},       -- Keep trace of original sizes and location of widgets
			MainPanelWidth = 294,   -- MainPanel width, must be >= 294
			BarWidth = 230,         -- Bar width, adjusted automatically
		}, { __index = self })
end
--------------------------------------------------------------------------------
function TUMeterGUI:GetActiveFight()
	return self.DPSMeter.FightsList[self.ActiveFight]
end
--------------------------------------------------------------------------------
function TUMeterGUI:GetActiveFightData()
	return self.DPSMeter.FightsList[self.ActiveFight].Data[self.ActiveMode]
end

function TUMeterGUI:GetActiveTimeLapse()
	return self.DPSMeter.FightsTimelapseList[self.ActiveFight]
end
--------------------------------------------------------------------------------
function TUMeterGUI:GetActiveTimeLapseData(anIndex)
	return self.DPSMeter.FightsTimelapseList[self.ActiveFight][anIndex].Data[self.ActiveMode]
end
--------------------------------------------------------------------------------
function TUMeterGUI:GetCurrentCombatant()
	if self.SelectedCombatant then return self.SelectedCombatant end
end
--------------------------------------------------------------------------------
function TUMeterGUI:SetSelectedCombatant(member)
	self.SelectedCombatant = nil
	self.SelectedCombatantInfo = member
end
--------------------------------------------------------------------------------
function TUMeterGUI:SetAvatarSelectedCombatant()
	self.SelectedCombatant = nil
	self.timelapseIndex = nil
	self.SelectedCombatantInfo = {}
	self.SelectedCombatantInfo.id = avatar.GetId()
	self.SelectedCombatantInfo.name = object.GetName(avatar.GetId())
end
--==============================================================================
--================= PLAYER LIST ================================================
--==============================================================================

--------------------------------------------------------------------------------
-- Hide player panel in the player list
--------------------------------------------------------------------------------
function TUMeterGUI:HideAllPlayerPanel()
	self.MainPanel.TotalPanel:Hide()
	for i = 1, Settings.MaxCombatants do
		self.MainPanel.PlayerList[i]:Hide()
	end
end

--------------------------------------------------------------------------------
-- Update the panel "Total" in the player list
--------------------------------------------------------------------------------
function TUMeterGUI:DisplayTotal()
	local totalPanel = self.MainPanel.TotalPanel
	totalPanel:Show()

	local minute, second = 0, 0
	local fightTime = self:GetActiveFight().Timer:GetElapsedTime()
	if fightTime > 0 then
		minute, second = GetMinSec(fightTime)
	end

	totalPanel.Bar:SetWidth(self.BarWidth)
	totalPanel.Bar:SetColor(self.DPSMeter.bCollectData and TotalColorInFight or TotalColor)

	-- Total(0:00)
	local total = "Total ("  .. minute .. ":" .. userMods.FromWString(common.FormatInt(second , "%02d")) .. ")"
	totalPanel.Name:SetVal("Name", userMods.ToWString(total))
	totalPanel.Value:SetVal("DamageDone", common.FormatFloat(self:GetActiveFightData().Amount, "%f3K5"))
	totalPanel.Value:SetVal("DPS", common.FormatFloat(self:GetActiveFightData().AmountPerSec, "%f3K5"))
end
--------------------------------------------------------------------------------
-- Update values for a combatant in the player list
--------------------------------------------------------------------------------
function TUMeterGUI:DisplayPlayer(playerIndex)
	local combatant = self:GetActiveFight():GetCombatantByIndex(playerIndex)
	local playerPanel = self.MainPanel.PlayerList[playerIndex]
	if not combatant or not playerPanel then return end

	playerPanel:Show()

	playerPanel.Bar:SetWidth(self.BarWidth * (combatant.Data[self.ActiveMode].LeaderPercentage / 100))
	playerPanel.Bar:SetColor(ClassColors[combatant.Class] or ClassColors["UNKNOWN"])

	playerPanel.Name:SetVal("Index", common.FormatInt(playerIndex , "%d"))
	playerPanel.Name:SetVal("Name", combatant.Name)
	playerPanel.Value:SetVal("DamageDone", common.FormatFloat(combatant.Data[self.ActiveMode].Amount, "%f3K5"))
	playerPanel.Value:SetVal("DPS", common.FormatFloat(combatant.Data[self.ActiveMode].AmountPerSec, "%f3K5"))
	playerPanel.Percent:SetVal("Percentage", common.FormatInt(combatant.Data[self.ActiveMode].Percentage, "%d"))
end
--------------------------------------------------------------------------------
-- Update the whole player list
--------------------------------------------------------------------------------
function TUMeterGUI:UpdatePlayerList()
	local currentFight = self:GetActiveFight()
	if not self.MainPanel.Widget:IsVisible() or not currentFight then return end
	currentFight:RecalculateCombatantsData(self.ActiveMode) -- Important

	local combatantCount = math.min(currentFight:GetCombatantCount(), Settings.MaxCombatants)

	self:HideAllPlayerPanel()
	self.MainPanel:SetHeight(47 + (combatantCount + 1) * 24)

	self:DisplayTotal()
	for playerIndex = 1, combatantCount do
		self:DisplayPlayer(playerIndex)
	end
end

--==============================================================================
--================= SPELL PANEL - Spell list ===================================
--==============================================================================

--------------------------------------------------------------------------------
-- Update a extra info line in the spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:DisplayGlobalInfo(GlobalInfoIndex)
	if not self.SelectedCombatant then return end

	local GlobalInfoData = self.SelectedCombatant:GetGlobalInfoByIndex(GlobalInfoIndex, self.ActiveMode)
	local GlobalInfoPanel = self.DetailsPanel.GlobalInfoList[GlobalInfoIndex]

	if GlobalInfoData and GlobalInfoData.Count > 0 then
		GlobalInfoPanel:Show()

		GlobalInfoPanel.Bar:SetColor(HitTypeColors[GlobalInfoData.ID])
		GlobalInfoPanel.Bar:SetWidth(356 * (GlobalInfoData.Percentage / 100))

		GlobalInfoPanel.Name:SetVal("Name", TitleGlobalInfoType[GlobalInfoData.ID])
		GlobalInfoPanel.Count:SetVal("Count", common.FormatInt(GlobalInfoData.Count , "%d"))
		GlobalInfoPanel.Damage:SetVal("Min", common.FormatFloat(GlobalInfoData.Min , "%f3K5"))
		GlobalInfoPanel.Damage:SetVal("Avg", common.FormatFloat(GlobalInfoData.Avg , "%f3K5"))
		GlobalInfoPanel.Damage:SetVal("Max", common.FormatFloat(GlobalInfoData.Max , "%f3K5"))
		GlobalInfoPanel.Percent:SetVal("Percentage", common.FormatInt(GlobalInfoData.Percentage , "%d"))
	end
end
--------------------------------------------------------------------------------
-- Update a spell line in the spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:DisplaySpell(spellIndex)
	if not self.SelectedCombatant then return end

	local spellData = self.SelectedCombatant:GetSpellByIndex(spellIndex, self.ActiveMode)
	local spellPanel = self.DetailsPanel.SpellList[spellIndex]

	if spellData and spellPanel then
		self.DetailsPanel.SpellList[spellIndex]:Show()
		
		--LogInfo(spellData.Element)
		
		spellPanel.Bar:SetColor(DamageTypeColors[spellData.Element] or { r = 1.0; g = 1.0; b = 1.0; a = 1 } )
		spellPanel.Bar:SetWidth(356 * (spellData.Percentage / 100))

		spellPanel.Name:SetVal("Index", common.FormatInt(spellIndex , "%d"))
		spellPanel.Name:SetVal("Prefix", spellData.Prefix)
		spellPanel.Name:SetVal("PetName", spellData.PetName)
		spellPanel.Name:SetVal("Name", spellData.Name)
		spellPanel.Name:SetVal("Suffix", spellData.Suffix)
		--spellPanel.Widget:SetBackgroundTexture(spellData.TextureId)
		spellPanel.Damage:SetVal("DamageDone", common.FormatFloat(spellData.Amount , "%f3K5"))
		spellPanel.Damage:SetVal("DPS", common.FormatFloat(spellData.AmountPerSec , "%f3K5"))
		spellPanel.Damage:SetVal("DamageBlock", common.FormatFloat(spellData.ResistPercentage , "%g"))
		spellPanel.Percent:SetVal("Percentage", common.FormatInt(spellData.Percentage , "%d"))
	end
end
--------------------------------------------------------------------------------
-- Fill the spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:UpdateSpellList()
	local detailsPanel = self.DetailsPanel
	if not detailsPanel:IsVisible() or not self:GetActiveFight() then return end

	detailsPanel:HideAllChild()
	--detailsPanel:ShowAllChild()
	for spellIndex = 1, MAXSPELLS do
		self.DetailsPanel.SpellList[spellIndex]:Hide()
	end

	
	detailsPanel.CloseButton:Show()

	if self.SelectedCombatant then
		if self.timelapseIndex then
			self.SelectedCombatant:CalculateSpell(self:GetActiveTimeLapse()[self.timelapseIndex].Timer:GetElapsedTime(), self.ActiveMode)
		else
			self.SelectedCombatant:CalculateSpell(self:GetActiveFight().Timer:GetElapsedTime(), self.ActiveMode)
		end
		--self:CreateTimeLapse()
		detailsPanel.PlayerNameText:SetVal("Name", self.SelectedCombatant.Name)
		detailsPanel.PlayerNameText:Show(true)

		if self.SelectedCombatant.Data[self.ActiveMode].Amount > 0 then
			detailsPanel.SpellHeaderPanel:Show()
			detailsPanel.GlobalInfoHeaderPanel:Show()
		end
		for GlobalInfoIndex = 1, EXTRATYPES do
			self:DisplayGlobalInfo(GlobalInfoIndex)
		end
		for spellIndex = 1, MAXSPELLS do
			self:DisplaySpell(spellIndex)
		end
		
		detailsPanel.SpellScrollList:Show(true)
		detailsPanel.TimeLapsePanel:Show()
		detailsPanel.AllTimeBtn:Show(true)
		detailsPanel.UpdateTimeLapseBtn:Show(true)
		detailsPanel.SpellCurrTimeText:Show(true)
		
	end
	
	--detailsPanel:ShowAllChild()
end

function TUMeterGUI:CreateTimeLapse()
	local timeLapse = self:GetActiveTimeLapse()
	
	self.DetailsPanel.TimeLapseScroll.Widget:RemoveItems()
	local maxAmount = 1
	for i = 1, GetTableSize(timeLapse) do 
		local selectedCombatant = timeLapse[i]:GetCombatant(self.SelectedCombatantInfo)
		if not selectedCombatant then
			self:SetAvatarSelectedCombatant()
			selectedCombatant = self:GetActiveFight():GetCombatant(self.SelectedCombatantInfo)
		end
		timeLapse[i].selectedCombatant = selectedCombatant
		maxAmount = math.max(selectedCombatant.Data[self.ActiveMode].Amount, maxAmount)
	end
	for i = 1, GetTableSize(timeLapse) do 
		local wtName = "DpsBtn" .. i
		local dpsElement = TWidget:CreateNewObjectByDesc(wtName, self.DetailsPanel.DpsTemplateBtnDesc, self.DetailsPanel.TimeLapsePanel)
		dpsElement:Show()
		local dpsBtn = dpsElement:GetChildByName("DpsTemplateBtn")
		local dpsBtnTxt = dpsElement:GetChildByName("TimeTextView")
		
		local btnHeight = math.max((timeLapse[i].selectedCombatant.Data[self.ActiveMode].Amount / maxAmount)*75, 6)
		dpsBtn:SetHeight(btnHeight)
		dpsBtnTxt.Widget:SetVal("Time", userMods.ToWString(GetTimeString(i*Settings.TimeLapsInterval)))
		self.DetailsPanel.TimeLapseScroll.Widget:PushBack(dpsElement.Widget)
	end
end

function TUMeterGUI:SwitchToTimeLapseElement(anIndex)
	self.SelectedCombatant = nil
	self.timelapseIndex = anIndex
	self:UpdateValues()
end

function TUMeterGUI:StartNewFight()
	self.DetailsPanel.TimeLapseScroll.Widget:RemoveItems()
	self.timelapseIndex = nil
	self.SelectedCombatant = nil
end

function TUMeterGUI:SwitchToAll()
	self.SelectedCombatant = nil
	self.timelapseIndex = nil
	self:UpdateValues()
end

--------------------------------------------------------------------------------
-- Update values in both player list & spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:UpdateValues()
	if not avatar.IsExist() then return end
	if self.SelectedCombatant and self.timelapseIndex then
		if not self:GetActiveTimeLapse()[self.timelapseIndex] then
			self.DetailsPanel.TimeLapseScroll.Widget:RemoveItems()
			self.timelapseIndex = nil
			self.SelectedCombatant = nil
		end
	end
	if not self.SelectedCombatant and self.SelectedCombatantInfo and self:GetActiveFight()then
		if self.timelapseIndex then
			local timeLapse = self:GetActiveTimeLapse()
			self.DetailsPanel.SpellCurrTimeText:SetVal("Time", userMods.ToWString(GetTimeString(self.timelapseIndex*Settings.TimeLapsInterval)))
			self.SelectedCombatant = timeLapse[self.timelapseIndex].selectedCombatant
		else
			self.DetailsPanel.SpellCurrTimeText:SetVal("Time", GetTextLocalized("StrAllTime"))
			self.SelectedCombatant = self:GetActiveFight():GetCombatant(self.SelectedCombatantInfo)
			if not self.SelectedCombatant then
				self:SetAvatarSelectedCombatant()
				self.SelectedCombatant = self:GetActiveFight():GetCombatant(self.SelectedCombatantInfo)
			end
		end
	end
	self:UpdatePlayerList()
	self:UpdateSpellList()
	
end

--==============================================================================
--================= SPELL PANEL - details list + details resist list ===========
--==============================================================================

--------------------------------------------------------------------------------
-- Display a spell details line in the spell info panel
--------------------------------------------------------------------------------
function TUMeterGUI:DisplaySpellDetails(spellInfoData, spellInfoPanel, title)
	if spellInfoData and spellInfoData.Count > 0 then
		spellInfoPanel:Show()

		spellInfoPanel.Bar:SetColor(HitTypeColors[spellInfoData.ID])
		spellInfoPanel.Bar:SetWidth(356 * (math.abs(spellInfoData.Percentage) / 100))

		spellInfoPanel.Name:SetVal("Name", title[spellInfoData.ID])
		spellInfoPanel.Count:SetVal("Count", common.FormatInt(spellInfoData.Count , "%d"))
		spellInfoPanel.Damage:SetVal("Min", common.FormatFloat(spellInfoData.Min , "%f3K5"))
		spellInfoPanel.Damage:SetVal("Avg", common.FormatFloat(spellInfoData.Avg , "%f3K5"))
		spellInfoPanel.Damage:SetVal("Max", common.FormatFloat(spellInfoData.Max , "%f3K5"))
		spellInfoPanel.Percent:SetVal("Percentage", common.FormatInt(spellInfoData.Percentage , "%d"))
	end
end
--------------------------------------------------------------------------------
-- Fill the spell panel
--------------------------------------------------------------------------------
function TUMeterGUI:UpdateSpellDetailsList(spellIndex)
	if (self.SelectedCombatant) then
		local index
		local spellData = self.SelectedCombatant:GetSpellByIndex(spellIndex, self.ActiveMode)

		if spellData then
			if spellData.Desc then
				self.DetailsPanel.DescText:SetVal("Desc", common.ExtractWStringFromValuedText(spellData.Desc))
				self.DetailsPanel.DescText:Show(true)
			else
				self.DetailsPanel.DescText:Show(false)
			end
			
			index = 1
			for dmgtype in SortSpellDetailsByCount(spellData.DetailsList) do
				self:DisplaySpellDetails(spellData.DetailsList[dmgtype], self.DetailsPanel.SpellInfoList[index], TitleDmgType)
				index = index + 1
			end

			index = 1
			for misstype in SortSpellDetailsByCount(spellData.MissList) do
				self:DisplaySpellDetails(spellData.MissList[misstype], self.DetailsPanel.SpellMissList[index], TitleMissType)
				index = index + 1
			end

			index = 1
			for blockdmgtype in SortSpellDetailsByAmount(spellData.ResistDetailsList) do
				local originList = spellData.ResistDetailsList[blockdmgtype]
				local list = originList
				if self.ActiveMode == enumMode.Dps or self.ActiveMode == enumMode.Def then
					list = DeepCopyObject(originList)
					list.Percentage = -1 * originList.Percentage 
					list.Min = -1 * originList.Max
					list.Avg = -1 * originList.Avg
					list.Max = -1 * originList.Min
				end
				self:DisplaySpellDetails(
				list, 
				self.DetailsPanel.SpellBlockList[index], 
				(self.ActiveMode == enumMode.Hps or self.ActiveMode == enumMode.IHps) and TitleHealResistType or TitleHitBlockType)
				index = index + 1
			end

			index = 1
			--            for GlobalInfotype in SortSpellDetailsByAmount(spellData.GlobalInfoList) do
			--                self:DisplaySpellDetails(spellData.GlobalInfoList[GlobalInfotype], self.DetailsPanel.SpellExtraList[index], TitleGlobalInfoType)
			--                index = index + 1
			--            end
		end
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
	for i = 1, BLOCKDMGTYPES do
		self.DetailsPanel.SpellBlockList[i]:Hide()
	end
	self.DetailsPanel.DescText:Show(false)
	--    for i = 1, EXTRATYPES do
	--        self.DetailsPanel.SpellExtraList[i]:Hide()
	--    end
end

--==============================================================================
--================= Event implementation =======================================
--==============================================================================

--------------------------------------------------------------------------------
-- Swap to the next fight
--------------------------------------------------------------------------------
function TUMeterGUI:SwapFight()
	local rotateFight = {
		[self.DPSMeter.Fight.Total] = self.DPSMeter.Fight.Current,
		[self.DPSMeter.Fight.Current] = self.DPSMeter.Fight.Previous,
		[self.DPSMeter.Fight.Previous] = self.DPSMeter.Fight.PrevPrevious,
		[self.DPSMeter.Fight.PrevPrevious] = self.DPSMeter.Fight.Total
	}
	self.ActiveFight = rotateFight[self.ActiveFight]
	self.SelectedCombatant = nil -- invalidate the current combatant
	self.timelapseIndex = nil

	-- DPSMeter.Fight.x indices can change during the execution
	local title = {
		[self.DPSMeter.Fight.Previous] = TitleFight[enumFight.Previous],
		[self.DPSMeter.Fight.Current] = TitleFight[enumFight.Current],
		[self.DPSMeter.Fight.Total] = TitleFight[enumFight.Total],
		[self.DPSMeter.Fight.PrevPrevious] = TitleFight[enumFight.PrevPrevious]
	}

	-- Update the fight in the fight panel (at the top of the player list)
	self.MainPanel.FightText:SetVal("Name", title[self.ActiveFight])

	-- Update the fight in the title of the spell panel
	self.DetailsPanel.PlayerNameText:SetVal("Fight", title[self.ActiveFight])
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
	self.SelectedCombatant = nil -- invalidate the current combatant

	-- Update the mode in the fight panel (at the top of the player list)
	self.MainPanel.ModeText:SetVal("Name", TitleMode[self.ActiveMode])

	-- Update the mode in the title of the spell panel
	self.DetailsPanel.PlayerNameText:SetVal("Mode", TitleMode[self.ActiveMode])

	-- Update the mode in the header of the spell panel
	self.DetailsPanel.SpellHeaderStatsText:SetVal("DPS", TitleMode[self.ActiveMode])
	self:CreateTimeLapse()
	self:UpdateValues()
end

--------------------------------------------------------------------------------
-- Swap to the next mode
--------------------------------------------------------------------------------
function TUMeterGUI:Reset(fullReset)
	self.DPSMeter:ResetAllFights(fullReset)
	self.ActiveFight = self.DPSMeter.Fight.Current
	self:SetAvatarSelectedCombatant()
	self:UpdateValues()
end

--==============================================================================
--================= INIT =======================================================
--==============================================================================
function TUMeterGUI:Init()
	-- The Data
	self.DPSMeter = TUMeter:CreateNewObject()

	-- Default mode
	self.ActiveMode = Settings.DefaultMode
	self.ActiveFight = self.DPSMeter.Fight.Current

	-- The "D" button to show or hide the main panels
	self.ShowHideBtn = TWidget:CreateNewObject("ShowHideBtn")
	self.ShowHideBtn:DragNDrop(true, true)

	-- Main panel with player list
	self.MainPanel = TMainPanelGUI:CreateNewObject("MainPanel")
	self.MainPanel:DragNDrop(true, true, false)

	-- Retrieve initial sizes of the main panel and its children in order to tweak the width
	local posX, posY
	self.InitialSize["MainPanelWidth"] = self.MainPanel:GetWidth()
	self.InitialSize["FightBtnWidth"] = self.MainPanel.FightBtn:GetWidth()
	self.InitialSize["ModeBtnWidth"] = self.MainPanel.ModeBtn:GetWidth()
	posX, posY = self.MainPanel.FightBtn:GetPosition()
	self.InitialSize["FightBtnPosX"] = posX
	
	self.SettingsPanel = TSettingsPanelGUI:CreateNewObject("SettingsPanel")
	self.SettingsPanel:DragNDrop(true, true)
	self.SettingsPanel.DefCheckBoxText:SetVal("Name", StrSettingsDef)
	self.SettingsPanel.DpsCheckBoxText:SetVal("Name", StrSettingsDps)
	self.SettingsPanel.HpsCheckBoxText:SetVal("Name", StrSettingsHps)
	self.SettingsPanel.IhpsCheckBoxText:SetVal("Name", StrSettingsIhps)
	self.SettingsPanel.DescCheckBoxText:SetVal("Name", StrSettingsDesc)
	self.SettingsPanel.SkipPetCheckBoxText:SetVal("Name", StrSettingsIgnorePet)
	self.SettingsPanel.SkipYourselfCheckBoxText:SetVal("Name", StrSettingsIgnoreYourself)
	self.SettingsPanel.CombatantCntText:SetVal("Name", StrCombatantCntText)
	self.SettingsPanel.TimeLapsIntervalText:SetVal("Name", StrTimeLapsInterval)
	self.SettingsPanel.SaveBtn:SetVal("button_label", StrSave)
	self.SettingsPanel.HeaderText:SetVal("Name", StrSettings)
	
	self.SettingsPanel.MaxCombatantTextEdit:SetText(common.FormatInt(Settings.MaxCombatants, "%d"))
	self.SettingsPanel.TimeLapsIntervalEdit:SetText(common.FormatInt(Settings.TimeLapsInterval, "%d"))
	
	SetCheckedForCheckBox(self.SettingsPanel.DpsCheckBox, Settings.ModeDPS)
	SetCheckedForCheckBox(self.SettingsPanel.HpsCheckBox, Settings.ModeHPS)
	SetCheckedForCheckBox(self.SettingsPanel.DefCheckBox, Settings.ModeDEF)
	SetCheckedForCheckBox(self.SettingsPanel.IhpsCheckBox, Settings.ModeIHPS)
	SetCheckedForCheckBox(self.SettingsPanel.DescCheckBox, Settings.CollectDescription)
	SetCheckedForCheckBox(self.SettingsPanel.SkipPetCheckBox, Settings.SkipDmgAndHpsOnPet)
	SetCheckedForCheckBox(self.SettingsPanel.SkipYourselfCheckBox, Settings.SkipDmgYourselfIn)

	-- Secondary panel with spell list / details
	self.DetailsPanel = TDetailsPanelGUI:CreateNewObject("SpellInfoPanel")
	self.DetailsPanel:DragNDrop(true, true)

	-------------------------------------------------------------------------------
	-- Widget description
	-------------------------------------------------------------------------------
	local totalPanelDesc = self.MainPanel.TotalPanel:GetDesc()
	local playerPanelDesc = self.MainPanel:GetChildByName("PlayerInfoPanel"):GetDesc()
	local spellPanelDesc = self.DetailsPanel:GetChildByName("SpellPanel"):GetDesc()
	local spellInfoPanelDesc = self.DetailsPanel:GetChildByName("SpellDetailPanel"):GetDesc()

	-------------------------------------------------------------------------------
	-- Main Panel
	-------------------------------------------------------------------------------

	-- Total panel
	self.MainPanel.TotalPanel:Destroy()
	self.MainPanel.TotalPanel = TTotalPanelGUI:CreateNewObjectByDesc("TotalPanel", totalPanelDesc, self.MainPanel)
	self.MainPanel.TotalPanel:SetPosition(20, 47)
	self.InitialSize["TotalPanelWidth"] = self.MainPanel.TotalPanel:GetWidth()

	-- Player list
	self.MainPanel:GetChildByName("PlayerInfoPanel"):Destroy()
	for playerIndex = 1, Settings.MaxCombatants do
		local wtName = "PlayerPanel" .. playerIndex
		self.MainPanel.PlayerList[playerIndex] = TPlayerPanelGUI:CreateNewObjectByDesc(wtName, playerPanelDesc, self.MainPanel)
		self.MainPanel.PlayerList[playerIndex]:SetPosition(20, 47 + playerIndex * 24)
	end

	-------------------------------------------------------------------------------
	-- Spell Panel
	-------------------------------------------------------------------------------

	self.DetailsPanel.AllTimeBtn:SetVal("button_label", StrAllTime)
	self.DetailsPanel.UpdateTimeLapseBtn:SetVal("button_label", StrUpdateTimeLapse)
	
	local origY = 155

	-- GlobalInfoHeader
	local GlobalInfoHeaderOffset = origY
	self.DetailsPanel.GlobalInfoHeaderPanel:SetPosition(22, GlobalInfoHeaderOffset)

	-- GlobalInfo list
	local GlobalInfoOffset = GlobalInfoHeaderOffset + 18
	for extraIndex = 1, EXTRATYPES do
		local wtName = "GlobalInfoPanel" .. extraIndex
		self.DetailsPanel.GlobalInfoList[extraIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.GlobalInfoList[extraIndex]:SetPosition(22, GlobalInfoOffset + (extraIndex-1) * 18)
	end

	-- SpellHeader
	local spellHeaderOffset = GlobalInfoOffset + EXTRATYPES * 18 + 7
	self.DetailsPanel.SpellHeaderPanel:SetPosition(22, spellHeaderOffset)

	-- Spell list
	self.DetailsPanel:GetChildByName("SpellPanel"):Destroy()
	local spellListOffset = spellHeaderOffset + 18
	for spellIndex = 1, MAXSPELLS do
		local wtName = "SpellPanel" .. spellIndex
		self.DetailsPanel.SpellList[spellIndex] = TSpellPanelGUI:CreateNewObjectByDesc(wtName, spellPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellList[spellIndex]:SetPosition(22, spellListOffset + (spellIndex-1) * 18)
		
		self.DetailsPanel.SpellScrollList:PushBack(self.DetailsPanel.SpellList[spellIndex].Widget)
	end

	-- SpellDetailsHeader
	local spellDetailsHeaderOffset = 428--spellListOffset + MAXSPELLS * 18 + 7
	if Settings.CollectDescription then
		spellDetailsHeaderOffset = 451
	end
	self.DetailsPanel.SpellDetailsHeaderPanel:SetPosition(22, spellDetailsHeaderOffset)

	-- Spell info
	self.DetailsPanel:GetChildByName("SpellDetailPanel"):Destroy()
	local damageOffset = spellDetailsHeaderOffset + 18
	for infoIndex = 1, DMGTYPES do
		local wtName = "SpellInfoPanel" .. infoIndex
		self.DetailsPanel.SpellInfoList[infoIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellInfoList[infoIndex]:SetPosition(22, damageOffset + (infoIndex-1) * 18)
	end

	-- Spell miss
	local missOffset = damageOffset + DMGTYPES * 18 + 5
	for missIndex = 1, MISSTYPES do
		local wtName = "SpellMissPanel" .. missIndex
		self.DetailsPanel.SpellMissList[missIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellMissList[missIndex]:SetPosition(22, missOffset + (missIndex-1) * 18)
	end

	-- Spell block
	local blockDamageOffset = missOffset + MISSTYPES * 18 + 5
	for blockIndex = 1, BLOCKDMGTYPES do
		local wtName = "SpellBlckPanel" .. blockIndex
		self.DetailsPanel.SpellBlockList[blockIndex] = TSpellDetailsPanelGUI:CreateNewObjectByDesc(wtName, spellInfoPanelDesc, self.DetailsPanel)
		self.DetailsPanel.SpellBlockList[blockIndex]:SetPosition(22, blockDamageOffset + (blockIndex-1) * 18)
	end

	if Settings.CollectDescription then
		self.DetailsPanel:SetHeight(909)
		local Placement = self.DetailsPanel.SpellScrollList:GetPlacementPlain()
		Placement.highPosY = 451
		self.DetailsPanel.SpellScrollList:SetPlacementPlain( Placement )
	end
end
