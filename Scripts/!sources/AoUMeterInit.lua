--------------------------------------------------------------------------------
-- File: AoUMeterInit.lua
-- Desc: Initialize the addon
--------------------------------------------------------------------------------

onMyEvent [ "EVENT_UNKNOWN_SLASH_COMMAND" ] = function( params )
	if userMods.FromWString(params.text) == "/umreset" then
		DPSMeterGUI.ShowHideBtn:SetPosition(100, 10)
	end
end

function Init()
	if avatar.IsExist() then
		onGenEvent["EVENT_AVATAR_CREATED"]()
	end

	RegisterEventHandlers(onGenEvent)
end

Init()