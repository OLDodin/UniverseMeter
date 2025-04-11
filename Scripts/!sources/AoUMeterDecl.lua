--------------------------------------------------------------------------------
-- Enumerations
--------------------------------------------------------------------------------
Global( "enumHit", { Normal = 1, Critical = 2, Glancing = 3 } )
Global( "enumMiss", { Dodge = 1, Miss = 2 } )
Global( "enumHitBlock", { Block = 1, Parry = 2, Barrier = 3, Resist = 4, Absorb = 5, RunesAbsorb = 6, MultAbsorb = 7, Mount = 8 } )
Global( "enumHealResist", { Resisted = 1, RuneResisted = 2, Absorbed = 3, Overload = 4 } )
Global( "enumBuff", { Valor = 1, Weakness = 2, Vulnerability = 3, Defense = 4 } )
Global( "enumGlobalInfo", { Determination = 1 } )
Global( "enumState", { Idle = 0, Attacked = 1, Killed = 2, Lost = 3 } )
Global( "enumMode", { Dps = 1, Hps = 2, Def = 3, IHps = 4 } )
Global( "enumFight", { Current = 0, Total = 1, History = 3 } )

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------
Global( "MAXSPELLS", 50)
Global( "DPSHPSTYPES", 0)
Global( "DEFTYPES", 0)
Global( "DMGTYPES", GetTableSize(enumHit))
Global( "MISSTYPES", GetTableSize(enumMiss))
Global( "BLOCKDMGTYPES", GetTableSize(enumHitBlock))
Global( "BUFFTYPES", GetTableSize(enumBuff))            	    
Global( "EXTRATYPES", GetTableSize(enumGlobalInfo))
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
Global("Settings", {
		ModeDPS = true,					-- enable DPS mode
		ModeHPS = true,					-- enable HPS mode
		ModeDEF = true,					-- enable DEF mode
		ModeIHPS = false,				-- enable IHPS mode
		DefaultMode = enumMode.Dps,	    -- default mode when starts
		MaxCombatants = 30,	            -- Number of maximum combatants to display
		FastUpdateInterval = 0.2,
		HeavyMode_MaxCombatant = 2,	    -- Below this value, the GUI is refreshed at every FastUpdateInterval, else every second only
		MaxOffBattleTime = 3,           -- Off-time battle (in seconds) allows to retrieve data coming just after the end of the fight (the events seems to not arrive in the correct order)
		CloseDist = 150,        		-- Range to consider if a combatant is close to the avatar or not 
		SkipDmgAndHpsOnPet = false,		-- ignore dd out and hps out for pet
		SkipDmgYourselfIn = false,
		StartHided = false,
		CollectTotalTimelapse = false,		-- memory consumption optimization
		ShowPositionOnBtn = false,			-- show active mode position on btn
		ScaleFonts = false,
		UseAlternativeRage = false,			-- update player rage value every FastUpdateInterval
		MemoryUsageLimit = common.GetClientArch() == CLIENT_ARCH_WIN64 and 300*1024 or 50*1024,	
		HistoryTotalLimit = 3,
		HistoryCurrentLimit = 10,
	})
--------------------------------------------------------------------------------
-- Localization
--------------------------------------------------------------------------------
Global( "StrPet", "" )
Global( "StrDamagePool", "" )
Global( "StrFromBarrier", "" )
Global( "StrNone", "" )
Global( "StrAllTime", "" )
Global( "StrWeakness", "" )
Global( "StrDefense", "" )
Global( "StrVulnerability", "" )
Global( "StrInsidiousness", "" )
Global( "StrValor", "" )
Global( "StrUnknown", userMods.ToWString("?") )
Global( "StrArrow", userMods.ToWString(" -> ") )
Global( "StrMapModifier", "" )
Global( "StrExploit", "" )
Global( "StrFall", "" )
Global ( "StrMainBtn", userMods.ToWString("D") )
Global ( "StrSpace", userMods.ToWString(" ") )



Global( "TitleMode", {})
Global( "TitleFight", {})
Global( "TitleDmgType", {})
Global( "TitleBuffType", {})
Global( "TitleMissType", {})
Global( "TitleHitBlockType", {})
Global( "TitleHealResistType", {})
Global( "TitleGlobalInfoType", {})
Global( "TitleCustomDpsBuffType", {})
Global( "TitleCustomDefBuffType", {})
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
Global("ClassColorsIndex", {
		["WARRIOR"]		= 1,
		["PALADIN"]		= 2,
		["MAGE"]		= 3,
		["DRUID"]		= 4,
		["PSIONIC"]		= 5,
		["STALKER"]		= 6,
		["PRIEST"]		= 7,
		["NECROMANCER"]	= 8,
		["BARD"]		= 9,
		["ENGINEER"]    = 10,
		["WARLOCK"]     = 11,
		["UNKNOWN"]		= 12,
	})
Global("ClassColors", {
		[1]		= { r = 165/255; g = 138/255; b = 087/255; a = 1 },
		[2]		= { r = 204/255; g = 255/255; b = 255/255; a = 1 },
		[3]		= { r = 047/255; g = 145/255; b = 255/255; a = 1 },
		[4]		= { r = 255/255; g = 128/255; b = 000/255; a = 1 },
		[5]		= { r = 255/255; g = 128/255; b = 255/255; a = 1 },
		[6]		= { r = 001/255; g = 188/255; b = 064/255; a = 1 },
		[7]		= { r = 255/255; g = 227/255; b = 048/255; a = 1 },
		[8]		= { r = 241/255; g = 043/255; b = 071/255; a = 1 },
		[9]		= { r = 000/255; g = 255/255; b = 200/255; a = 1 },
		[10]    = { r = 135/255; g = 163/255; b = 177/255; a = 1 },
		[11]    = { r = 125/255; g = 101/255; b = 219/255; a = 1 },
		[12]	= { r = 127/255; g = 127/255; b = 127/255; a = 1 },
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
		[3] = { r = 0.5; g = 1.0; b = 0.5; a = 1 }, 
		[4] = { r = 0.5; g = 0.5; b = 1.0; a = 1 }, 
		[5] = { r = 1.0; g = 1.0; b = 0.5; a = 1 }, 
	})
	
for i = 6, 50, 5 do
	HitTypeColors[i] = { r = 1.0; g = 1.0; b = 0.0; a = 1 }
	HitTypeColors[i+1] = { r = 0.5; g = 1.0; b = 0.5; a = 1 } 
	HitTypeColors[i+2] = { r = 1.0; g = 1.0; b = 0.5; a = 1 } 
	HitTypeColors[i+3] = { r = 0.5; g = 0.5; b = 1.0; a = 1 } 
	HitTypeColors[i+4] = { r = 1.0; g = 1.0; b = 0.0; a = 1 }
end
--------------------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------------------
Global("AoPanelDetected", false)
Global("DPSMeterGUI", {})

Global( "BuffCheckList", {})
Global( "CurrentBuffsState", {})

Global( "CurrentScoreOnMainBtn", 0)

Global( "ENUM_SubElement_Strings", {
		["ENUM_SubElement_PHYSICAL"]	= "ENUM_SubElement_PHYSICAL",
		
		["ENUM_SubElement_FIRE"]		= "ENUM_SubElement_FIRE",
		["ENUM_SubElement_COLD"]		= "ENUM_SubElement_COLD",
		["ENUM_SubElement_LIGHTNING"]	= "ENUM_SubElement_LIGHTNING",
		
		["ENUM_SubElement_HOLY"]		= "ENUM_SubElement_HOLY",
		["ENUM_SubElement_SHADOW"]		= "ENUM_SubElement_SHADOW",
		["ENUM_SubElement_ASTRAL"]		= "ENUM_SubElement_ASTRAL",
		
		["ENUM_SubElement_POISON"]		= "ENUM_SubElement_POISON",
		["ENUM_SubElement_DISEASE"]	    = "ENUM_SubElement_DISEASE",
		["ENUM_SubElement_ACID"]		= "ENUM_SubElement_ACID",
	})