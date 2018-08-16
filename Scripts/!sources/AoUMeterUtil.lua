--------------------------------------------------------------------------------
-- File: AoUMeterUtil.lua
-- Desc: some useful functions, constants and enums
--------------------------------------------------------------------------------

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
	local lookup_table = {}

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
end

function IsExistUnit(id)
    return id and object.IsExist(id) and object.IsUnit(id)
end

function IsPlayerOrPet(id)
    return id and object.IsExist(id) and (unit.IsPlayer(id) or unit.IsPet(id))
end
--------------------------------------------------------------------------------
-- Get pourcentage from ratio Value / ValueAt
function GetPercentageAt( Value, ValueAt )
	return math.floor( ( ValueAt ~= 0 and Value / ValueAt or 0 ) * 100 )
end
--------------------------------------------------------------------------------
function IsThisStringValue(value1, value2)
	if common.IsWString(value1) and common.IsWString(value2) then
		return common.CompareWString(value1, value2) == 0
	else
		return type(value1) == "string" and value1 == value2
	end
end
--------------------------------------------------------------------------------
-- Compare the name of 2 spells in order to sort them
--------------------------------------------------------------------------------
local function CompareSpellDetails(A, B)
	return A.cnt > B.cnt
end
--------------------------------------------------------------------------------
-- Sort spell details by Count
--------------------------------------------------------------------------------
function SortSpellDetailsByCount(DetailsList)
	local a = {}
	local Type, DamageDetails

	for Type, DamageDetails in pairs(DetailsList) do
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
function SortSpellDetailsByAmount(DetailsList)
	local a = {}
	local Type, DamageDetails

	for Type, DamageDetails in pairs(DetailsList) do
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
function sqr(x)
	return x * x;
end
function PosRange(a, b)	
	if (b == nil or a == nil) then
		return 9999;
	end

	return math.sqrt( sqr(b.posX - a.posX)  + sqr(b.posY - a.posY) + sqr(b.posZ - a.posZ));
end
--------------------------------------------------------------------------------
-- Get member list
--------------------------------------------------------------------------------
function GetPartyMembers()
	local PartyMembersInfoList = {}
	if not raid.IsExist() then
		PartyMembersInfoList = group.GetMembers() or {}
	else
		PartyMembersInfoList = {}
		local RaidGroups = raid.GetMembers()
		local ind = 0
		for i, Group in pairs(RaidGroups) do
			for i, member in pairs(Group) do
				PartyMembersInfoList[ind] = member
				ind = ind + 1
			end
		end
	end
	return PartyMembersInfoList
end

function DelayExecute( delay, func, params )
	local i = 0
	local callbackFunc = nil

	callbackFunc = function( )
		local i = i + 1
		if i == delay then
			common.UnRegisterEventHandler( callbackFunc, "EVENT_SECOND_TIMER" )
			func( params )
		end
	end
	common.RegisterEventHandler( callbackFunc, "EVENT_SECOND_TIMER" )
end

function round(aTime)
	if not aTime then return nil end
	return math.floor(aTime+0.5)
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