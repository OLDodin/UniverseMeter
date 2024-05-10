--Doubly-linked lists in Lua.
--Written by Cosmin Apreutesei. Public Domain.

Global("TList", {})
TList.__index = TList

setmetatable(TList, { __call = function()
  return setmetatable({ length = 0 }, TList)
end })

function TList:packForList(t)
	return { value = t }
end

function TList:unpackFromList(t)
	return t.value
end

function TList:insert_last_internal(t)
  if self.last then
    self.last._next = t
    t._prev = self.last
    self.last = t
  else
    -- this is the first node
    self.first = t
    self.last = t
  end
	
  self.length = self.length + 1
end

function TList:insert_last(t)
  self:insert_last_internal(self:packForList(t))
end

function TList:insert_first_internal(t)
  if self.first then
    self.first._prev = t
    t._next = self.first
    self.first = t
  else
    self.first = t
    self.last = t
  end
  
  self.length = self.length + 1
end

function TList:insert_first(t)
  self:insert_first_internal(self:packForList(t))
end

function TList:pop()
  if not self.last then return end
  local ret = self.last
  
  if ret._prev then
    ret._prev._next = nil
    self.last = ret._prev
    ret._prev = nil
  else
    -- this was the only node
    self.first = nil
    self.last = nil
  end
  
  self.length = self.length - 1
  return ret
end

function TList:remove_first()
  if not self.first then return end
  local ret = self.first
  
  if ret._next then
    ret._next._prev = nil
    self.first = ret._next
    ret._next = nil
  else
    self.first = nil
    self.last = nil
  end
  
  self.length = self.length - 1
  return ret
end

function TList:prev(aLast)
	if aLast then
		return aLast._prev
	else
		return self.last
	end
end

function TList:next(aLast)
	if aLast then
		return aLast._next
	else
		return self.first
	end
end

function TList:getByNum(aNum)
	if aNum > self.length then
		return
	end
	local res
	for i = 1, aNum do
		res = self:next(res)
	end
	return self:unpackFromList(res)
end

local function iterate(self, current)
  if not current then
    current = self.first
  elseif current then
    current = current._next
  end
  
  return current
end

function TList:iterate()
  return iterate, self, nil
end

--utils

function TList:copy()
	local list = TList()
	for item in self:iterate() do
		list:insert_last_internal(item)
	end
	return list
end

