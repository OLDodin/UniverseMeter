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

function InitBuffConditionMgr(aBuffList)
	m_buffCondition = table.sclone(BuffCondition)
	m_buffCondition:Init(aBuffList)
end

function GetBuffCondition()
	return m_buffCondition
end
