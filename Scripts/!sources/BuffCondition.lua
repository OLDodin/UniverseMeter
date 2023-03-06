Global( "BuffCondition", {} )


function BuffCondition:Init(aSettings)
	self.avlCustomTree  = GetAVLWStrTree()
	for _, element in pairs(aSettings) do
		if element.name then
			self.avlCustomTree:add(element)
		end
	end
end

function BuffCondition:Check(aBuffInfo)
	local searchRes = self.avlCustomTree:find(aBuffInfo)
	return searchRes~=nil, searchRes
end


local m_buffCondition = nil

function InitBuffConditionMgr()
	m_buffCondition = CloneTable(BuffCondition)
	m_buffCondition:Init(BuffCheckList)
end

function GetBuffCondition()
	return m_buffCondition
end
