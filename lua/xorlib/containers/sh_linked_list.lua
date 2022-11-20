local LINKED_LIST = {}
LINKED_LIST.__index = LINKED_LIST

function LINKED_LIST:PushFront(value)
	local firstNode = self.first

	local node = {
		value = value,
		next = firstNode,
		prev = nil
	}

	if firstNode then
		firstNode.prev = node
	else
		self.last = node
	end

	self.first = node
	self.count = self.count + 1

	return node
end

function LINKED_LIST:PushBack(value)
	local lastNode = self.last

	local node = {
		value = value,
		next = nil,
		prev = lastNode
	}

	if lastNode then
		lastNode.next = node
	else
		self.first = node
	end

	self.last = node
	self.count = self.count + 1

	return node
end

function LINKED_LIST:Insert(pos, value)
	if pos == 1 then
		return self:PushFront(value)
	end

	local posNode = self:at(pos)
	local nextNode = posNode.next
	local prevNode = posNode.prev

	local node = {
		value = value,
		next = posNode.next,
		prev = posNode.prev
	}

	if nextNode then
		nextNode.prev = node
	else
		-- make this node last
		self.last = node
	end

	if prevNode then
		prevNode.next = node
	else
		-- make this node first
		self.first = node
	end

	self.count = self.count + 1

	return node
end

function LINKED_LIST:Delete(node)
	local nextNode = node.next
	local prevNode = node.prev

	if nextNode then
		nextNode.prev = prevNode
	else
		self.last = prevNode
	end

	if prevNode then
		prevNode.next = nextNode
	else
		self.first = nextNode
	end

	self.count = self.count - 1

	return node
end

function LINKED_LIST:DeleteByValue(value)
	for node in self:iterate() do
		if node.value == value then
			self:delete(node)
		end
	end
end

function LINKED_LIST:Remove(pos)
	local node = self:at(pos)
	if not node then return end

	return self:delete(node)
end

function LINKED_LIST:PopFront()
	local first = self.first
	if not first then return end

	self.first = first.next

	return first.value
end

function LINKED_LIST:PopBack()
	local last = self.last
	if not last then return end

	self.last = last.prev
	return last
end

function LINKED_LIST:At(index)
	if index <= 1 then
		return self.first
	elseif index >= self.count then
		return self.last
	end

	return x.AdvanceNode(self.first, index - 1)
end

function LINKED_LIST:Iterate()
	local node = self.first

	return function()
		local curNode = node

		if curNode then
			node = node.next

			return curNode
		end
	end
end

function LINKED_LIST:IterateReverse()
	local node = self.last

	return function()
		local curNode = node

		if curNode then
			node = node.prev

			return curNode
		end
	end
end

function x.AdvanceNode(node, count)
	while node and count > 0 do
		node = node.next
		count = count - 1
	end

	return node
end

function x.LinkedList()
	return setmetatable({
		count = 0,
		first = nil,
		last = nil
	}, LINKED_LIST)
end

function x.LinkedListFromSequential(tbl)
	local list = x.LinkedList()

	for i = 1, #tbl do
		list:PushBack(tbl[i])
	end

	return list
end
