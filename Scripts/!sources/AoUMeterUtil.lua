--------------------------------------------------------------------------------
-- File: AoUMeterUtil.lua
-- Desc: some useful functions, constants and enums
--------------------------------------------------------------------------------

local cachedIsExist = object.IsExist
local cachedIsUnit = object.IsUnit
local cachedIsPet = unit.IsPet
local cachedIsPlayer = unit.IsPlayer
local cachedGetDistance = object.GetDistance

--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------
-- Get minutes & seconds from an int
function GetMinSec (sec)
	local lmin = math.floor(sec / 60)
	return lmin, sec - lmin * 60
end
--------------------------------------------------------------------------------
-- Make a deep copy of an object (http://oentend.blogspot.com/2009/08/lua.html)
function DeepCopyObject( object )
	--[[local lookup_table = {}

	local function _copy( object )
		if type( object ) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end

		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs( object ) do
			new_table[ _copy( index ) ] = _copy( value )
		end

		return setmetatable( new_table, _copy( getmetatable( object ) ) )
	end

	return _copy( object )
	]]
	return table.clone(object)
end

function SimpleRecursiveCloneTable( t )
	if type( t ) ~= "table" then return t end
	local c = {}
	for i, v in pairs( t ) do c[ i ] = SimpleRecursiveCloneTable( v ) end
	return c
end

function IsExistUnit(anObjID)
    return anObjID and cachedIsExist(anObjID) and cachedIsUnit(anObjID)
end

function IsExistPet(anObjID)
    return anObjID and cachedIsExist(anObjID) and cachedIsPet(anObjID)
end

function IsExistPlayer(anObjID)
	return anObjID and cachedIsExist(anObjID) and cachedIsUnit(anObjID) and cachedIsPlayer(anObjID)
end

function IsPetData(aSpellData)
	return aSpellData.PetName ~= nil
end

--------------------------------------------------------------------------------
-- Get pourcentage from ratio Value / ValueAt
function GetPercentageAt( Value, ValueAt )
	return ( ValueAt ~= 0 and Value / ValueAt or 0 ) * 100
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Compare the name of 2 spells in order to sort them
--------------------------------------------------------------------------------
local function CompareSpellDetails(A, B)
	return A.cnt > B.cnt
end
--------------------------------------------------------------------------------
-- Sort spell details by Count
--------------------------------------------------------------------------------
function SortSpellDetailsByCount(aDetailsList)
	local a = {}
	local Type, DamageDetails

	for Type, DamageDetails in pairs(aDetailsList) do
		local info = {}
		info.type = Type
		info.cnt = DamageDetails.Count
		table.insert(a, info)
	end

	table.sort(a, CompareSpellDetails)

	local i = 0					-- iterator variable
	local iter = function ()	-- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i].type
		end
	end
	return iter
end
--------------------------------------------------------------------------------
-- Sort spell details by Amount
--------------------------------------------------------------------------------
function SortSpellDetailsByAmount(aDetailsList)
	local a = {}
	local Type, DamageDetails

	for Type, DamageDetails in pairs(aDetailsList) do
		local info = {}
		info.type = Type
		info.cnt = math.abs(DamageDetails.Amount)
		table.insert(a, info)
	end

	table.sort(a, CompareSpellDetails)

	local i = 0					-- iterator variable
	local iter = function ()	-- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i].type
		end
	end
	return iter
end
--------------------------------------------------------------------------------
-- Compute the range between 2 positions
--------------------------------------------------------------------------------
function GetDistanceToTarget(anID)
	local res = anID and cachedIsExist(anID) and cachedGetDistance(anID) or nil
	if not res then 
		return 9999
	end
	res = math.ceil(res)

	return res
end

--------------------------------------------------------------------------------
-- Get member list
--------------------------------------------------------------------------------
function GetPartyMembers()
	local partyMembersInfoList = {}
	
	if raid.IsExist() then
		local raidGroups = raid.GetMembers()
		for i, group in ipairs(raidGroups) do
			for _, member in ipairs(group) do
				table.insert(partyMembersInfoList, member)
			end
		end
	elseif group.IsExist() then
		partyMembersInfoList = group.GetMembers()
	end
	if not partyMembersInfoList then
		partyMembersInfoList = {}
	end
	if GetTableSize(partyMembersInfoList) == 0 then
		local member = {}
		member.id = avatar.GetId()
		member.name = object.GetName(member.id)
		member.className = avatar.GetClass()
		
		table.insert(partyMembersInfoList, member)
	end
	
	return partyMembersInfoList
end

function PlayerPetInCombat(anPlayerID)
	for _, followerID in pairs(unit.GetFollowers(anPlayerID) or {}) do
		if object.IsInCombat(followerID) then
			return true
		end
	end
	return false
end

function round(aTime)
	if not aTime then return nil end
	return math.floor(aTime+0.5)
end

function CompareColor(aColor1, aColor2)
	if not aColor1 or not aColor2 then
		return false
	end
	if aColor1.r ~= aColor2.r or aColor1.g ~= aColor2.g or aColor1.b ~= aColor2.b or aColor1.a ~= aColor2.a then
		return false
	end
	return true
end

function GetTimeString(aSeconds)
	local minutesStr
	local secondsStr
	local minutes = math.floor(aSeconds/60)
	local seconds = aSeconds - minutes*60
	
	if minutes < 10 then minutesStr = "0"..tostring(minutes) else minutesStr = tostring(minutes) end
	if seconds < 10 then secondsStr = "0"..tostring(seconds) else secondsStr = tostring(seconds) end
	
	return minutesStr..":"..secondsStr
end

function CalculateState(aMember)
	return (aMember.id == avatar.GetId() or aMember.state and (aMember.state == GROUP_MEMBER_STATE_NEAR or aMember.state == GROUP_MEMBER_STATE_MERC or aMember.state == RAID_MEMBER_STATE_NEAR)) and true or false
end

function CalculateClassIndex(aClassName)
	if not aClassName then
		aClassName = "UNKNOWN"
	end
	local classColorIndex = ClassColorsIndex[aClassName]
	if classColorIndex == nil then
		return ClassColorsIndex["UNKNOWN"]
	end
	return classColorIndex
end

function ResizeListByMaxSize(aList, aSize, aFromFirst)
	while (aList.length > aSize) do
		if aFromFirst then
			aList:remove_first()
		else
			aList:pop()
		end
	end
end

function GetTimestamp()
	return common.GetLocalDateTimeMs()
end

function LogMemoryUsage()
	LogToChat("1 memory usage "..tostring(gcinfo()).."kb" )
end

--------------------------------------------------------------------------------
-- Timers functions
--------------------------------------------------------------------------------
local m_timer = nil

function OnTimer(aParams)
	if aParams.effectType ~= ET_FADE then
		return
	end
	if not m_timer then
		return
	end
	if aParams.wtOwner ~= m_timer.widget then
		return
	end

	m_timer.callback()
end

function StartTimer(aCallback, aSpeed)
	if m_timer then 
		return
	end
	local timerWidget = mainForm:GetChildUnchecked("Timer", false)
	if not aCallback or not timerWidget then 
		return nil 
	end
	m_timer = {}
	m_timer.callback = aCallback
	m_timer.widget = timerWidget
	m_timer.speed = tonumber(aSpeed) or 1

	common.RegisterEventHandler(OnTimer, "EVENT_EFFECT_SEQUENCE_STEP")
	timerWidget:PlayFadeEffectSequence({ { 1.0, 1.0, m_timer.speed*1000, EA_MONOTONOUS_INCREASE }, cycled = true, sendStepEvent = true })

	return true
end