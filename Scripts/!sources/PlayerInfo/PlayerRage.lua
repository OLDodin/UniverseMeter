Global( "PlayerRage", {} )

local cachedGetRage = unit.GetRage
local cachedRegisterEventHandler = common.RegisterEventHandler
local cachedUnRegisterEventHandler = common.UnRegisterEventHandler

function PlayerRage:Init(anID)
	self.playerID = anID
	self.unitParams = {}
	self.rage = 0
	self.lastRage = -1
	
	self.eventFunc = self:GetEventFunc()
	
	self.base = table.sclone(PlayerBase)
	self.base:Init()
	
	self:RegisterEvent(anID)
end

function PlayerRage:ClearLastValues()
	self.lastRage = -1
end

function PlayerRage:SubscribeGui(aLitener)
	self:ClearLastValues()
	self.base:SubscribeGui(self.playerID, aLitener, self.eventFunc)
end

function PlayerRage:UnsubscribeGui()
	self.base:UnsubscribeGui()
end

function PlayerRage:TryDestroy()
	if self.base:CanDestroy() then
		self:UnRegisterEvent()
		return true
	end
	return false
end

function PlayerRage:UpdateValueIfNeeded()
end

function PlayerRage:UpdateValueIfNeededInternal()
	self.lastRage = self.rage
	if self.base.guiListener then
		self.base.guiListener.listenerRage(self.playerID, self.rage)
	end
end

function PlayerRage:GetEventFunc()
	return function(aParams)
		if not IsExistUnit(aParams.unitId) then
			return
		end
		self.rage = cachedGetRage(aParams.unitId)
		self:UpdateValueIfNeededInternal()
	end
end

function PlayerRage:RegisterEvent(anID)
--	self.unitParams.unitId = anID
--	cachedRegisterEventHandler(self.eventFunc, "EVENT_UNIT_RAGE_CHANGED", self.unitParams)
end

function PlayerRage:UnRegisterEvent()
--	cachedUnRegisterEventHandler(self.eventFunc, "EVENT_UNIT_RAGE_CHANGED", self.unitParams)
end