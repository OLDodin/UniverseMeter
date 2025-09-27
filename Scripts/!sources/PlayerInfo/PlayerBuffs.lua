Global( "PlayerBuffs", {} )
local cachedGetBuffInfo = object.GetBuffInfo
local cachedGetBuffDynamicInfo = object.GetBuffDynamicInfo
local cachedGetBuffs = object.GetBuffs
local cachedGetBuffsInfo = object.GetBuffsInfo
local cachedIsValidBuff = object.IsValidBuff

function PlayerBuffs:Init(anID)
	self.playerID = anID
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
		self:UnRegisterEvent(self.playerID)
		return true
	end
	return false
end

function PlayerBuffs:UpdateValueIfNeeded()

end

function PlayerBuffs:CallAddListenerIfNeeded(aBuffID, aBuffName, aListener, aCondition)
	if aListener and aBuffName and not self.ignoreBuffsID[aBuffID] then
		local searchResult, findedObj = aCondition:Check( { name = aBuffName } )
		if searchResult then
			self.passedBuffsID[aBuffID] = findedObj
			aListener.listenerAddBuff(self.playerID, findedObj)
		else
			self.ignoreBuffsID[aBuffID] = true
		end
	end
end

function PlayerBuffs:GetReadAllEventFunc()
	return function(aParams)
		local unitBuffs = cachedGetBuffs(aParams.unitId, true)
		if next(unitBuffs) then
			for buffID, buffInfo in pairs(cachedGetBuffsInfo(unitBuffs) or {}) do
				self:CallAddListenerIfNeeded(buffID, buffInfo.name, self.base.guiListener, GetBuffCondition())
			end
		end
	end
end

function PlayerBuffs:GetAddEventFunc()
	return function(aParams)
		if not aParams.isNeedVisualize then
			return
		end
		self:CallAddListenerIfNeeded(aParams.buffId, aParams.buffName, self.base.guiListener, GetBuffCondition())
	end
end

function PlayerBuffs:GetDelEventFunc()
	return function(aParams)
		local passedInfo = self.passedBuffsID[aParams.buffId]
		if self.base.guiListener and passedInfo then
			self.base.guiListener.listenerRemoveBuff(self.playerID, passedInfo)
		end
		self.passedBuffsID[aParams.buffId] = nil
		self.ignoreBuffsID[aParams.buffId] = nil
	end
end

function PlayerBuffs:GetChangedEventFunc()
	return function(aBuffID)
		local passedInfo = self.passedBuffsID[aBuffID]
		if self.base.guiListener and passedInfo and cachedIsValidBuff(aBuffID) then
			self.base.guiListener.listenerChangeBuff(self.playerID, cachedGetBuffDynamicInfo(aBuffID), passedInfo)
		end
	end
end

function PlayerBuffs:RegisterEvent(anID)
	common.EnablePersonalEvent('EVENT_OBJECT_BUFF_ADDED', anID)
	common.EnablePersonalEvent('EVENT_OBJECT_BUFF_REMOVED', anID)
end

function PlayerBuffs:UnRegisterEvent(anID)
	common.DisablePersonalEvent('EVENT_OBJECT_BUFF_ADDED', anID)
	common.DisablePersonalEvent('EVENT_OBJECT_BUFF_REMOVED', anID)
end