Global( "BuffCondition", {} )

local m_valuedText = common.CreateValuedText()
m_valuedText:SetFormat(userMods.ToWString('<header><r name="text_label"/></header>'))
local m_htmlWstr = userMods.ToWString("<html>")

local function removeHtmlFromWString(text)
	if text:IsContain(m_htmlWstr) then
		m_valuedText:SetVal("text_label", text)
		return m_valuedText:ToWString()
	end
	return text
end

function BuffCondition:Init(aSettings)
	self.avlCustomTree  = GetAVLWStrTree()
	for _, element in pairs(aSettings) do
		if element.name then
			self.avlCustomTree:add(element)
		end
	end
end

function BuffCondition:Check(aBuffInfo)
	aBuffInfo.name = removeHtmlFromWString(aBuffInfo.name)
	local searchRes = self.avlCustomTree:find(aBuffInfo)
	return searchRes~=nil, searchRes
end


local m_buffCondition = nil

function InitBuffConditionMgr(aBuffList)
	m_buffCondition = table.sclone(BuffCondition)
	m_buffCondition:Init(aBuffList)
end

function GetBuffCondition()
	return m_buffCondition
end
