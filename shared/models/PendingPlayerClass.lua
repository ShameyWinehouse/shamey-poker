---@class PendingPlayer
PendingPlayer = {}

PendingPlayer.netId = 0
PendingPlayer.name = ""
PendingPlayer.order = 1

function PendingPlayer:getNetId()
	return self.netId
end

function PendingPlayer:setNetId(netId)
	self.netId = netId
end

function PendingPlayer:getName()
	return self.name
end

function PendingPlayer:setName(name)
	self.name = name
end

function PendingPlayer:getOrder()
	return self.order
end

function PendingPlayer:setOrder(order)
	self.order = order
end

--------



---@return PendingPlayer
function PendingPlayer:New(obj)
	local instance = setmetatable({}, {
        __index = self
    })
    -- instance.elm = obj.elm
    return instance
end