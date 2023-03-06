Global( "PlayerBase", {} )

Global( "g_regCnt", {})

function PlayerBase:Init()
	self.refCnt = 0
	self.guiListener = nil
end

function PlayerBase:SubscribeGui(anID, aLitener, aEventFunc)
	if not self.guiListener then
		self.refCnt = self.refCnt + 1
	end
	self.guiListener = aLitener

	local params = {}
	params.unitId = anID
	aEventFunc(params)
end

function PlayerBase:UnsubscribeGui()
	if self.guiListener then
		self.refCnt = self.refCnt - 1
	end
	self.guiListener = nil
end

function PlayerBase:CanDestroy()
	if self.refCnt == 0 then
		return true
	end
	return false
end