Global( "PlayerBuffs", {} )
local cachedGetBuffInfo = object.GetBuffInfo

function PlayerBuffs:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.ignoreBuffsID = {}
	self.passedBuffsID = {}
	self.updateCnt = 0

	self.readAllEventFunc = self:GetReadAllEventFunc()
	self.delEventFunc = self:GetDelEventFunc()
	self.addEventFunc = self:GetAddEventFunc()
	self.changeEventFunc = self:GetChangedEventFunc()

	self.base = CloneTable(PlayerBase)
	self.base:Init()

	self:RegisterEvent(anID)
end

function PlayerBuffs:ClearLastValues()
	self.updateCnt = 0
	self.ignoreBuffsID = {}
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
	self.updateCnt = self.updateCnt + 1
	if self.updateCnt == 600 then
		self:ClearLastValues()
	end
end

function PlayerBuffs:CallListenerIfNeeded(aBuffID, aListener, aCondition, anIgnoreBuffsList)
	if aListener and not anIgnoreBuffsList[aBuffID] then
		local buffInfo = aBuffID and cachedGetBuffInfo(aBuffID)
		if buffInfo and buffInfo.name then
			local searchResult, findedObj = aCondition:Check(buffInfo)
			if searchResult then
				self.passedBuffsID[aBuffID] = findedObj
				aListener.listenerChangeBuff(buffInfo, self.playerID, findedObj)
			else
				anIgnoreBuffsList[aBuffID] = true
			end
		end
	end
end

function PlayerBuffs:GetReadAllEventFunc()
	return function(aParams)
		local unitBuffs = object.GetBuffsWithProperties(aParams.unitId, true, true)
		for i, buffID in pairs(unitBuffs) do
			self:CallListenerIfNeeded(buffID, self.base.guiListener, GetBuffCondition(), self.ignoreBuffsID)
		end
		unitBuffs = object.GetBuffsWithProperties(aParams.unitId, false, true)
		for i, buffID in pairs(unitBuffs) do
			self:CallListenerIfNeeded(buffID, self.base.guiListener, GetBuffCondition(), self.ignoreBuffsID)
		end
	end
end

function PlayerBuffs:GetAddEventFunc()
	return function(aParams)
		self:CallListenerIfNeeded(aParams.buffId, self.base.guiListener, GetBuffCondition(), self.ignoreBuffsID)
	end
end

function PlayerBuffs:GetDelEventFunc()
	return function(aParams)
		if self.base.guiListener then
			if self.passedBuffsID[aParams.buffId] then
				self.base.guiListener.listenerRemoveBuff(aParams.buffId, self.playerID, self.passedBuffsID[aParams.buffId])
			end
			self.passedBuffsID[aParams.buffId] = nil
		end
	end
end

function PlayerBuffs:GetChangedEventFunc()
	return function(aParams)
		self:CallListenerIfNeeded(aParams, self.base.guiListener, GetBuffCondition(), self.ignoreBuffsID)
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