--------------------------------------------------------------------------------
-- File: AoUMeterDecl.lua
-- Desc: Variable declartions file
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Enumerations
--------------------------------------------------------------------------------
Global( "enumHit", { Normal = 1, Critical = 2 } )
Global( "enumMiss", { Dodge = 1, Miss = 2, Power = 3, Insidiousness = 4, Valor = 5, Weakness = 6, Vulnerability = 7, Defense = 8 } )
--Global( "enumHitBlock", { Block = 1, Parry = 2, Barrier = 3, Resist = 4, Absorb = 5, RunesAbsorb = 6, MultAbsorb = 7, Mount = 8 } )
Global( "enumHitBlock", { Barrier = 1, Absorb = 2, RunesAbsorb = 3, MultAbsorb = 4, Mount = 5 } )
Global( "enumHealResist", { Resisted = 1, RuneResisted = 2, Absorbed = 3, Overload = 4 } )
Global( "enumGlobalInfo", { Determination = 1 } )
Global( "enumState", { Idle = 0, Attacked = 1, Killed = 2, Lost = 3 } )
Global( "enumMode", { Dps = 1, Hps = 2, Def = 3, IHps = 4 } )
Global( "enumFight", { Current = 1, Previous = 2, Total = 3, PrevPrevious = 4 } )
Global( "enumWidth", { Auto = 1, Normal = 2, Wide = 3 } )
--------------------------------------------------------------------------------
-- Constants (do not change)
--------------------------------------------------------------------------------
Global( "MAXSPELLS", 24 )                   -- Maximum number of spell to display in the spell list
Global( "DMGTYPES", 2 )                     -- Number of type of damage (see enumHit)
Global( "MISSTYPES", 8 )                    -- Number of type of damage (see enumMiss)
Global( "BLOCKDMGTYPES", 5 )                -- Number of block damage (see enumHitBlock & enumHealResist)
Global( "EXTRATYPES", 1 )                   -- Number of extra info (see enumGlobalInfo)
--------------------------------------------------------------------------------
-- Settings (-> See AoUMeterSettings.txt to make them 'public' for end-user)
--------------------------------------------------------------------------------
Global("Settings", {
		ModeDPS = true,					-- enable DPS mode
		ModeHPS = true,					-- enable HPS mode
		ModeDEF = true,					-- enable DEF mode
		ModeIHPS = false,				-- add
		KeepHistory = false,			-- keep history (not yet implemented)
		DefaultMode = enumMode.Dps,	    -- default mode when starts
		MaxCombatants = 28,	            -- Number of maximum combatants to display
		HeavyMode_MaxCombatant = 2,	    -- Below this value, the GUI is refreshed at every hit, else every second only
		MaxOffBattleTime = 3,           -- Off-time battle (in seconds) allows to retrieve data coming just after the end of the fight (the events seems to not arrive in the correct order)
		MainPanelWidth = enumWidth.Auto,    -- To determine the width of the main panel (with player list)
		DPSMeterMode = enumMode.Dps,
		MainPanelWideSize = 352,        -- Width of the main panel in wider mode (must be > 294)
		CloseDist = 86,        			-- Range to consider if a combatant is close to the avatar or not (85 metr for 9.1)
        FriendlyShot = false,           -- Should we take in account friendly shot in the DPS ?
		MagicPVPKoef = 0.62,			-- Magic pvp absorb koef //deprecated from 10.0.00.54 
		TimeLapsInterval = 10, 
		CollectDescription = true,
		SkipDmgAndHpsOnPet = false,		-- ignore dd out and hps out for pet
		SkipDmgYourselfIn = false,
	})
--------------------------------------------------------------------------------
-- Localization
--------------------------------------------------------------------------------
Global( "StrPet", "" )
Global( "StrDamagePool", "" )
Global( "StrFromBarrier", "" )
Global( "StrNone", "" )
Global( "StrSettingsDef", "" )
Global( "StrSettingsDps", "" )
Global( "StrSettingsHps", "" )
Global( "StrSettingsIhps", "" )
Global( "StrSave", "" )
Global( "StrAllTime", "" )
Global( "StrUpdateTimeLapse", "" )
Global( "StrSettings", "" )
Global( "StrWeakness", "" )
Global( "StrDefense", "" )
Global( "StrVulnerability", "" )
Global( "StrPower", "" )
Global( "StrInsidiousness", "" )
Global( "StrValor", "" )
Global( "StrSettingsDesc", "" )
Global( "StrUnknown", userMods.ToWString("?") )
Global( "StrMapModifier", "" )
Global( "StrExploit", "" )
Global( "StrSettingsIgnorePet", "" )
Global( "StrSettingsIgnoreYourself", "" )
Global( "StrCombatantCntText", "" )
Global( "StrTimeLapsInterval", "" )

Global( "Weakness", "" )
Global( "Vulnerability", "33" )
Global( "Power", "" )
Global( "Insidiousness", "" )
Global( "Valor", "" )
Global( "Defense", "")



Global( "TitleMode", {
		[enumMode.Dps] = "",
		[enumMode.Hps] = "",
		[enumMode.Def] = "",
		[enumMode.IHps] = ""
	})
Global( "TitleFight", {
		[enumFight.Previous] = "",
		[enumFight.Current] = "",
		[enumFight.Total] = "",
		[enumFight.PrevPrevious] = ""
	})
Global( "TitleDmgType", {
		[enumHit.Normal] = "",
		[enumHit.Critical] = "",
		--[enumHit.Glancing] = "",
		
	})
Global( "TitleMissType", {
		[enumMiss.Dodge] = "",
		[enumMiss.Miss] = "",
		[enumMiss.Weakness] = "", 
		[enumMiss.Defense] = "", 
		[enumMiss.Vulnerability] = "", 
		[enumMiss.Power] = "", 
		[enumMiss.Insidiousness] = "", 
		[enumMiss.Valor] = "", 
	})
Global( "TitleHitBlockType", {
		--[enumHitBlock.Block] = "",
		--[enumHitBlock.Parry] = "",
		[enumHitBlock.Barrier] = "",
		--[enumHitBlock.Resist] = "",
		[enumHitBlock.Absorb] = "",
		[enumHitBlock.RunesAbsorb] = "",
		[enumHitBlock.MultAbsorb] = "",
		[enumHitBlock.Mount] = "", 
		
	})
Global( "TitleHealResistType", {
		[enumHealResist.Resisted] = "",
		[enumHealResist.RuneResisted] = "",
		[enumHealResist.Absorbed] = "",
		[enumHealResist.Overload] = ""
	})
Global( "TitleGlobalInfoType", {
		[enumGlobalInfo.Determination ] = ""
	})
--------------------------------------------------------------------------------
-- Events
--------------------------------------------------------------------------------
Global("onGenEvent", {})
Global("onMyEvent", {})
Global("onMyEvent2", {})
Global("onReaction", {})
--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------
Global( "TotalColor", { r = 128/255; g = 128/255; b = 128/255; a = 1 } )
Global( "TotalColorInFight", { r = 128/255; g = 0/255; b = 0/255; a = 1 } )
Global("ClassColors", {
		["WARRIOR"]		= { r = 165/255; g = 138/255; b = 087/255; a = 1 },
		["PALADIN"]		= { r = 204/255; g = 255/255; b = 255/255; a = 1 },
		["MAGE"]		= { r = 047/255; g = 145/255; b = 255/255; a = 1 },
		["DRUID"]		= { r = 255/255; g = 128/255; b = 000/255; a = 1 },
		["PSIONIC"]		= { r = 255/255; g = 128/255; b = 255/255; a = 1 },
		["STALKER"]		= { r = 001/255; g = 188/255; b = 064/255; a = 1 },
		["PRIEST"]		= { r = 255/255; g = 227/255; b = 048/255; a = 1 },
		["NECROMANCER"]	= { r = 241/255; g = 043/255; b = 071/255; a = 1 },
		["BARD"]		= { r = 000/255; g = 255/255; b = 200/255; a = 1 },
		["ENGINEER"]    = { r = 135/255; g = 163/255; b = 177/255; a = 1 },
		["WARLOCK"]     = { r = 125/255; g = 101/255; b = 219/255; a = 1 },
		["UNKNOWN"]		= { r = 127/255; g = 127/255; b = 127/255; a = 1 },
	})
Global( "DamageTypeColors", {
		["ENUM_SubElement_PHYSICAL"]	= { r = 0.7; g = 0.5; b = 0.3; a = 1 },
		
		["ENUM_SubElement_FIRE"]		= { r = 0.2; g = 0.35; b = 1.0; a = 1 },
		["ENUM_SubElement_COLD"]		= { r = 0.2; g = 0.35; b = 1.0; a = 1 },
		["ENUM_SubElement_LIGHTNING"]	= { r = 0.2; g = 0.35; b = 1.0; a = 1 },
		
		["ENUM_SubElement_HOLY"]		= { r = 1.0; g = 1.0; b = 0.5; a = 1 },
		["ENUM_SubElement_SHADOW"]		= { r = 1.0; g = 1.0; b = 0.5; a = 1 },
		["ENUM_SubElement_ASTRAL"]		= { r = 1.0; g = 1.0; b = 0.5; a = 1 },
		
		["ENUM_SubElement_POISON"]		= { r = 0.3; g = 1.0; b = 0.3; a = 1 },
		["ENUM_SubElement_DISEASE"]	    = { r = 0.3; g = 1.0; b = 0.3; a = 1 },
		["ENUM_SubElement_ACID"]		= { r = 0.3; g = 1.0; b = 0.3; a = 1 },
	})
Global( "HitTypeColors", {
		[1] = { r = 1.0; g = 1.0; b = 1.0; a = 1 }, -- Normal
		[2] = { r = 1.0; g = 0.0; b = 0.0; a = 1 }, -- Critical
		[3] = { r = 0.5; g = 1.0; b = 0.5; a = 1 }, -- Glancing
		[4] = { r = 0.5; g = 0.5; b = 1.0; a = 1 }, -- Dodge
		[5] = { r = 1.0; g = 1.0; b = 0.5; a = 1 }, -- Miss
		[6] = { r = 1.0; g = 1.0; b = 0.0; a = 1 }, -- Block
		[7] = { r = 1.0; g = 1.0; b = 0.0; a = 1 }, -- Parry
		[8] = { r = 1.0; g = 1.0; b = 0.0; a = 1 }, -- Barrier
		[9] = { r = 1.0; g = 1.0; b = 0.0; a = 1 }, -- Resist
		[10] = { r = 1.0; g = 1.0; b = 0.0; a = 1 }, -- Absorb
	})
--------------------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------------------
Global("AoPanelDetected", false)
Global("DPSMeterGUI", {})


















