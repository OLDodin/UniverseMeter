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

function CloneTable( t )
	if type( t ) ~= "table" then return t end
	local c = {}
	for i, v in pairs( t ) do c[ i ] = CloneTable( v ) end
	return c
end

function IsExistUnit(id)
    return id and object.IsExist(id) and object.IsUnit(id)
end

function IsExistPet(id)
    return id and object.IsExist(id) and unit.IsPet(id)
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
function CompareWStr(aValue1, aValue2)
	return common.CompareWString(aValue1, aValue2) == 0
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
	local partyMembersInfoList = {}
	
	if raid.IsExist() then
		local raidGroups = raid.GetMembers()
		for i, group in pairs(raidGroups) do
			for _, member in pairs(group) do
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
	return common.GetMsFromDateTime(common.GetLocalDateTime())
end

function LogMemoryUsage()
	LogToChat("memory usage "..tostring(gcinfo()).."kb" )
end

------------------------------------------------------------------
------ Loging To Chat
------------------------------------------------------------------
local wtChat = nil
local chatRows = 0 --- for clear buffer after show messages
local valuedText = common.CreateValuedText()
local formatVT = "<html fontname='AllodsSystem' shadow='1'><rs class='color'><r name='addon'/><r name='text'/></rs></html>"
valuedText:SetFormat(userMods.ToWString(formatVT))

wtGetNumParents = function(w, parents)
	if parents > 0 and w.GetParent then
		local pr = w:GetParent()
		if pr then
			return wtGetNumParents(pr, parents-1)
		end
	end
	return w
end

function GetSysChatContainer()
	local parents = 2
	local w = stateMainForm:GetChildUnchecked("Chat", false)
	if not w then
		w = stateMainForm:GetChildUnchecked("Chat", true)
	else
		w = w:GetChildUnchecked("Chat", true)
	end
	if not w then ---- 2.0.06.13 [26.05.2011] 
		w = stateMainForm:GetChildUnchecked("ChatLog", false)
		w = w:GetChildUnchecked("Container", true)
		if w then parents = 3 end
	end
	
	return w, wtGetNumParents(w, parents)
end

function LogToChatVT(valuedText, name, toWW)
	name = name or common.GetAddonName()


	if not wtChat then wtChat = GetSysChatContainer() end
	if wtChat and wtChat.PushFrontValuedText then
		chatRows =  chatRows + 1
		valuedText:SetVal( "addon", userMods.ToWString(name..": ") )
		wtChat:PushFrontValuedText( valuedText )
	end
end

function LogToChat(message, color, toWW)
	valuedText = common.CreateValuedText()
	valuedText:SetFormat(userMods.ToWString(formatVT))
	valuedText:ClearValues() 
	valuedText:SetClassVal( "color", color or "LogColorYellow" )
	if not common.IsWString( message ) then	message = userMods.ToWString(message) end
	valuedText:SetVal( "text", message )
	LogToChatVT(valuedText, common.GetAddonName(), toWW)

end

--------------------------------------------------------------------------------
-- Timers functions
--------------------------------------------------------------------------------
local m_timer = nil

function OnTimer(aParams)
	if not aParams.effectType == ET_FADE then
		return
	end
	if not m_timer then
		return
	end
	if not aParams.wtOwner:IsEqual(m_timer.widget) then
		return
	end

	m_timer.widget:PlayFadeEffect( 1.0, 1.0, m_timer.speed*1000, EA_MONOTONOUS_INCREASE )
	m_timer.callback()
end

function StartTimer(aCallback, aSpeed)
	if m_timer then 
		m_timer.widget:DestroyWidget()
	end
	local timerWidget = mainForm:GetChildUnchecked("Timer", false)
	if not aCallback or not timerWidget then 
		return nil 
	end
	m_timer = {}
	m_timer.callback = aCallback
	m_timer.widget = timerWidget
	m_timer.speed = tonumber(aSpeed) or 1

	common.RegisterEventHandler(OnTimer, "EVENT_EFFECT_FINISHED")
    timerWidget:PlayFadeEffect(1.0, 1.0, m_timer.speed*1000, EA_MONOTONOUS_INCREASE)
	return true
end