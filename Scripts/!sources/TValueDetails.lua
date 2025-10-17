local Count = enumInfo.Count
local Amount = enumInfo.Amount
local Min = enumInfo.Min
local Max = enumInfo.Max

-- Type TValueDetails
Global("TValueDetails", {})
--------------------------------------------------------------------------------
function TValueDetails:CreateNewObject()
	return {}
end

function TValueDetails:CreateNewObjectOneValue(aValue, aCnt)
	return 
	{
		[Count] = aCnt,
		[Amount] = aValue * aCnt,
		[Min] = aValue,
		[Max] = aValue
	}
end

function TValueDetails:RecalcDetails(aValue)
	local cnt = TValueDetails.GetCount(self) + 1
	self[Amount] = TValueDetails.GetAmount(self) + aValue

	if cnt > 1 then
		self[Count] = cnt
		if cnt == 2 then
			self[Min] = math.huge
			self[Max] = -math.huge
		end
		self[Min] = math.min(self[Min], aValue)	
		self[Max] = math.max(self[Max], aValue)
	end
end

function TValueDetails:MergeDetails(aSpellDataDetails)
	if TValueDetails.GetCount(aSpellDataDetails) == 0 then
		return
	end
	
	self[Count] = TValueDetails.GetCount(self) + TValueDetails.GetCount(aSpellDataDetails)
	self[Amount] = TValueDetails.GetAmount(self) + TValueDetails.GetAmount(aSpellDataDetails)
	
	if not self[Min] then
		self[Min] = math.huge
		self[Max] = -math.huge
	end

	self[Min] = math.min(self[Min], TValueDetails.GetMin(aSpellDataDetails))
	self[Max] = math.max(self[Max], TValueDetails.GetMax(aSpellDataDetails))
end

function TValueDetails:GetAvg()
	if TValueDetails.GetCount(self) == 0 then
		return 0
	end
	return TValueDetails.GetAmount(self) / TValueDetails.GetCount(self)
end

function TValueDetails:GetAmount()
	if not self[Amount] then
		return 0
	end
	return self[Amount]
end

function TValueDetails:GetCount()
	if not self[Count] then
		if self[Amount] then
			return 1
		else
			return 0
		end
	end
	return self[Count]
end

function TValueDetails:GetMin()
	if TValueDetails.GetCount(self) > 1 then
		return self[Min]
	end
	return TValueDetails.GetAmount(self)
end

function TValueDetails:GetMax()
	if TValueDetails.GetCount(self) > 1 then
		return self[Max]
	end
	return TValueDetails.GetAmount(self)
end