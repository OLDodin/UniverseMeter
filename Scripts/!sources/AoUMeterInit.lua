--------------------------------------------------------------------------------
-- File: AoUMeterInit.lua
-- Desc: Initialize the addon
--------------------------------------------------------------------------------

onMyEvent [ "EVENT_UNKNOWN_SLASH_COMMAND" ] = function( params )
	if userMods.FromWString(params.text) == "/umreset" then
		DPSMeterGUI.ShowHideBtn:SetPosition(100, 10)
	end
end

local function FillBuffCheckList()
	local buffCheckList = {}
	local index = 1
	for i = 1, 3 do
		table.insert(buffCheckList, {name = GetTextLocalized("HpsBuff"..i), ind = index, forSrc = true, forHps = true})
		index = index + 1
	end
	for i = 1, 3 do
		table.insert(buffCheckList, {name = GetTextLocalized("DpsHpsBuff"..i), ind = index, forSrc = true, forHps = true, forDps = true})
		index = index + 1
	end
	for i = 1, 2 do
		table.insert(buffCheckList, {name = GetTextLocalized("DpsBuff"..i), ind = index, forSrc = true, forDps = true})
		index = index + 1
	end
	ServerBuffIndex.Valor = index - 1
	for i = 3, 3 do
		table.insert(buffCheckList, {name = GetTextLocalized("DpsBuff"..i), ind = index, forTarget = true, forDps = true})
		index = index + 1
	end
	ServerBuffIndex.Vulnerability = index - 1
	
	DPSHPSTYPES = 9
	DEFTYPES = 27
	for i = 1, 1 do
		table.insert(buffCheckList, {name = GetTextLocalized("IHpsBuff"..i), ind = index, forTarget = true, forHps = true})
		index = index + 1
	end
	for i = 1, 25 do
		table.insert(buffCheckList, {name = GetTextLocalized("DefBuff"..i), ind = index, forTarget = true, forDps = true})
		index = index + 1
	end
	ServerBuffIndex.Defense = index - 1
	for i = 26, 26 do
		table.insert(buffCheckList, {name = GetTextLocalized("DefBuff"..i), ind = index, forSrc = true, forDps = true})
		index = index + 1
	end
	ServerBuffIndex.Weakness = index - 1
	
	for i = 1, DPSHPSTYPES do
		TitleCustomDpsBuffType[i] = buffCheckList[i].name
	end
	for i = 1, DEFTYPES do
		TitleCustomDefBuffType[i] = buffCheckList[DPSHPSTYPES + i].name
	end
	
	for i = 1, index-1 do
		CurrentBuffsState[i] = {}
		CurrentBuffsStateByTime[i] = {}
	end
	
	return buffCheckList
end

local function Init()
	StrAllTime = GetTextLocalized("StrAllTime")
	StrTypePet = GetTextLocalized("TypePet")
	StrTypeAbility = GetTextLocalized("TypeAbility")
	StrTypeSpell = GetTextLocalized("TypeSpell")
	StrTypeMap = GetTextLocalized("TypeMap")
	StrTypeBuff = GetTextLocalized("TypeBuff")

	StrDamagePool = GetTextLocalized("DamagePool")
	StrFromBarrier = GetTextLocalized("FromBarrier")

	StrNone = common.GetEmptyWString()
	StrWeakness = GetTextLocalized("Weakness")
	StrDefense = GetTextLocalized("Defense")
	StrVulnerability = GetTextLocalized("Vulnerability")
	StrInsidiousness = GetTextLocalized("Insidiousness")
	StrValor = GetTextLocalized("Valor")
	StrMapModifier = GetTextLocalized("MapModifier")
	StrExploit = GetTextLocalized("Exploit")
	StrFall = GetTextLocalized("Fall")
	
	StrHpsBuffHeader = GetTextLocalized("HpsBuffHeaderText")
	StrAntiHpsBuffHeader = GetTextLocalized("AntiHpsBuffHeaderText")
	StrResistHpsBuffHeader = GetTextLocalized("ResistHpsHeaderText")
	StrIncreaseDefBuffHeader = GetTextLocalized("DpsBuffHeaderText2")
	StrDecreaseDefBuffHeader = GetTextLocalized("DefBuffHeaderText2")
	StrResistDefBuffHeader = GetTextLocalized("ResistDpsHeaderText2")
	StrIncreaseDpsBuffHeader = GetTextLocalized("DpsBuffHeaderText")
	StrDecreaseDpsBuffHeader = GetTextLocalized("DefBuffHeaderText")
	StrResistDpsBuffHeader = GetTextLocalized("ResistDpsHeaderText")


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
	
	local textureGroup = common.GetAddonRelatedTextureGroup("common")
	UnknownTex = textureGroup:GetTexture("Unknown")
	DeadTex = textureGroup:GetTexture("Dead")
	KillTex = textureGroup:GetTexture("Kill")
	DeadKillTex = textureGroup:GetTexture("DeadKill")

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
	
	InitBuffConditionMgr(FillBuffCheckList())
end

--можно и до аватара
Init()

if (avatar.IsExist()) then
	GlobalInit()
else
	common.RegisterEventHandler(GlobalInit, "EVENT_AVATAR_CREATED")
end