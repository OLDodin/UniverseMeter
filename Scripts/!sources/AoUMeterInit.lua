--------------------------------------------------------------------------------
-- File: AoUMeterInit.lua
-- Desc: Initialize the addon
--------------------------------------------------------------------------------

onMyEvent [ "EVENT_UNKNOWN_SLASH_COMMAND" ] = function( params )
	if userMods.FromWString(params.text) == "/plouf" then
		local talentInfo = avatar.GetBaseTalentInfo(1,3)
		LogInfo("TALENT")
		LogInfo("RANK")
		LogTable(talentInfo.ranks[0])
		local spell = spellLib.GetDescription( talentInfo.ranks[0].spellId )
		LogInfo("SPELL")
		LogTable(spell)


		--		for i, Combatant in DPSMeterGUI.DPSMeter.FightsList[DPSMeterGUI.ActiveFight].CombatantsList do
		--			LogTable(Combatant)
		--		end
	end
end

function Init()
	if avatar.IsExist() then
		onGenEvent["EVENT_AVATAR_CREATED"]()
	end

	RegisterEventHandlers(onGenEvent)
end

Init()