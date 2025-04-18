Global( "PlayerBuffs", {} )
local cachedGetBuffInfo = object.GetBuffInfo
local cachedGetBuffs = object.GetBuffs
local cachedGetBuffsInfo = object.GetBuffsInfo

function PlayerBuffs:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.ignoreBuffsID = {}
	self.passedBuffsID = {}

	self.readAllEventFunc = self:GetReadAllEventFunc()
	self.delEventFunc = self:GetDelEventFunc()
	self.addEventFunc = self:GetAddEventFunc()
	self.changeEventFunc = self:GetChangedEventFunc()

	self.base = table.sclone(PlayerBase)
	self.base:Init()

	self:RegisterEvent(anID)
end

function PlayerBuffs:ClearLastValues()
	self.ignoreBuffsID = {}
	self.passedBuffsID = {}
end

function PlayerBuffs:SubscribeGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeGui(self.playerID, aLitener, self.readAllEventFunc)
end

function PlayerBuffs:UnsubscribeGui()
	self.base:UnsubscribeGui()
end

function PlayerBuffs:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerBuffs:UpdateValueIfNeeded()

end

function PlayerBuffs:CallListenerIfNeeded(aBuffID, aListener, aCondition, aBuffInfo)
	if aListener and not self.ignoreBuffsID[aBuffID] then
		local buffInfo = aBuffInfo or cachedGetBuffInfo(aBuffID)
		if buffInfo and buffInfo.name then
			local searchResult, findedObj = aCondition:Check(buffInfo)
			if searchResult then
				self.passedBuffsID[aBuffID] = findedObj
				aListener.listenerChangeBuff(buffInfo, self.playerID, findedObj)
			else
				self.ignoreBuffsID[aBuffID] = true
			end
		end
	end
end

function PlayerBuffs:GetReadAllEventFunc()
	return function(aParams)
		local unitBuffs = cachedGetBuffs(aParams.unitId, true)
		if next(unitBuffs) then
			for buffID, buffInfo in pairs(cachedGetBuffsInfo(unitBuffs) or {}) do
				self:CallListenerIfNeeded(buffID, self.base.guiListener, GetBuffCondition(), buffInfo)
			end
		end
	end
end

function PlayerBuffs:GetAddEventFunc()
	return function(aParams)
		self:CallListenerIfNeeded(aParams.buffId, self.base.guiListener, GetBuffCondition())
	end
end

function PlayerBuffs:GetDelEventFunc()
	return function(aParams)
		if self.base.guiListener then
			if self.passedBuffsID[aParams.buffId] then
				self.base.guiListener.listenerRemoveBuff(aParams.buffId, self.playerID, self.passedBuffsID[aParams.buffId])
			end
		end
		self.passedBuffsID[aParams.buffId] = nil
		self.ignoreBuffsID[aParams.buffId] = nil
	end
end

function PlayerBuffs:GetChangedEventFunc()
	return function(aParams)
		
	end
end

function PlayerBuffs:RegisterEvent(anID)
	self.unitParams.objectId = anID

	common.RegisterEventHandler(self.addEventFunc, 'EVENT_OBJECT_BUFF_ADDED', self.unitParams)
	common.RegisterEventHandler(self.delEventFunc, 'EVENT_OBJECT_BUFF_REMOVED', self.unitParams)
end

function PlayerBuffs:UnRegisterEvent()
	common.UnRegisterEventHandler(self.addEventFunc, 'EVENT_OBJECT_BUFF_ADDED', self.unitParams)
	common.UnRegisterEventHandler(self.delEventFunc, 'EVENT_OBJECT_BUFF_REMOVED', self.unitParams)
end