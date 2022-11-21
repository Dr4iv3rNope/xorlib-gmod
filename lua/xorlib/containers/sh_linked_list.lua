local LINKED_LIST = {}
LINKED_LIST.__index = LINKED_LIST

function LINKED_LIST:PushFront(value)
	local firstNode = self.First

	local node = {
		Value = value,
		Next = firstNode,
		Prev = nil
	}

	if firstNode then
		firstNode.Prev = node
	else
		self.Last = node
	end

	self.First = node
	self.Count = self.Count + 1

	return node
end

function LINKED_LIST:PushBack(value)
	local lastNode = self.Last

	local node = {
		Value = value,
		Next = nil,
		Prev = lastNode
	}

	if lastNode then
		lastNode.Next = node
	else
		self.First = node
	end

	self.Last = node
	self.Count = self.Count + 1

	return node
end

function LINKED_LIST:Insert(pos, value)
	if pos == 1 then
		return self:PushFront(value)
	end

	local posNode = self:At(pos)
	local nextNode = posNode.Next
	local prevNode = posNode.Prev

	local node = {
		Value = value,
		Next = posNode.Next,
		Prev = posNode.Prev
	}

	if nextNode then
		nextNode.Prev = node
	else
		-- make this node last
		self.Last = node
	end

	if prevNode then
		prevNode.Next = node
	else
		-- make this node first
		self.First = node
	end

	self.Count = self.Count + 1

	return node
end

function LINKED_LIST:Delete(node)
	local nextNode = node.Next
	local prevNode = node.Prev

	if nextNode then
		nextNode.Prev = prevNode
	else
		self.Last = prevNode
	end

	if prevNode then
		prevNode.Next = nextNode
	else
		self.First = nextNode
	end

	self.Count = self.Count - 1

	return node
end

function LINKED_LIST:DeleteByValue(value)
	for node in self:Iterate() do
		if node.Value == value then
			self:Delete(node)
		end
	end
end

function LINKED_LIST:Remove(pos)
	local node = self:At(pos)
	if not node then return end

	return self:Delete(node)
end

function LINKED_LIST:PopFront()
	local first = self.First
	if not first then return end

	self.First = first.Next

	return first.Value
end

function LINKED_LIST:PopBack()
	local last = self.Last
	if not last then return end

	self.Last = last.Prev
	return last
end

function LINKED_LIST:At(index)
	if index <= 1 then
		return self.First
	elseif index >= self.Count then
		return self.Last
	end

	return x.AdvanceNode(self.First, index - 1)
end

function LINKED_LIST:Iterate()
	local node = self.First

	return function()
		local curNode = node

		if curNode then
			node = node.Next

			return curNode
		end
	end
end

function LINKED_LIST:IterateReverse()
	local node = self.Last

	return function()
		local curNode = node

		if curNode then
			node = node.Prev

			return curNode
		end
	end
end

function x.AdvanceNode(node, count)
	while node and count > 0 do
		node = node.Next
		count = count - 1
	end

	return node
end

function x.LinkedList()
	return setmetatable({
		Count = 0,
		First = nil,
		Last = nil
	}, LINKED_LIST)
end

function x.LinkedListFromSequential(tbl)
	local list = x.LinkedList()

	for i = 1, #tbl do
		list:PushBack(tbl[i])
	end

	return list
end
