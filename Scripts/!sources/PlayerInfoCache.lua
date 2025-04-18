local cachedIsValidBuff = object.IsValidBuff
local m_players = {}

local function CreatePlayerSubInfo(anID, aSubClass)
	local playerSubClassInfo = table.sclone(aSubClass)
	playerSubClassInfo:Init(anID)

	return playerSubClassInfo
end

function FabricMakePlayerInfo(anID, aListener)
	if not IsExistUnit(anID) then
		return
	end
	local player = m_players[anID] or {}
		
	if not player.buffs then
		player.buffs = CreatePlayerSubInfo(anID, PlayerBuffs)
	end
	player.buffs:SubscribeGui(aListener)

	m_players[anID] = player
end

function FabricClearAll()
	UnsubscribeListeners()
	FabricDestroyUnused()
end


function UnsubscribeListeners(anID)
	for playerID, player in pairs(m_players) do
		if not anID or playerID == anID then
			for _, playerInfo in pairs(player) do
				playerInfo:UnsubscribeGui()
			end
		end
	end
end

function FabricDestroyUnused()
	for playerID, player in pairs(m_players) do
		local playerObjAlive = false
		
		for playerInfoIndex, playerInfo in pairs(player) do
			if playerInfo:TryDestroy() then
				player[playerInfoIndex] = nil
			else
				playerObjAlive = true
			end
		end
		
		if not playerObjAlive then 
			m_players[playerID] = nil
		end
	end
end

function UpdateFabric()
	for playerID, player in pairs(m_players) do
		if IsExistUnit(playerID) then
			for _, playerInfo in pairs(player) do
				playerInfo:UpdateValueIfNeeded()
			end
		end
	end
end

function BuffsChanged(aParams)
	for objId, buffs in pairs( aParams.objects ) do
		local playerInfo = m_players[objId]
		if playerInfo then
			for buffID, _ in pairs( buffs ) do
				if not cachedIsValidBuff(buffID) then
					playerInfo.buffs.delEventFunc( { buffId = buffID } )
				end
			end
		end
	end 
end

function OnEventSecondZatichka()
	-- затычка №1 - бывает что не приходит событие что юнит исчез, проверяем актуальность персонажей 
	local unitList = avatar.GetUnitList()
	table.insert(unitList, avatar.GetId())

	for playerID, _ in pairs(m_players) do
		local reallyExist = false
		
		for _, objID in pairs(unitList) do
			if objID == playerID then
				reallyExist = true
				break
			end
		end
		if not reallyExist then
			UnsubscribeListeners(playerID)
		end
	end
end