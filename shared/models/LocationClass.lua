---@class Location
Location = {}

LOCATION_STATES = {
    ["EMPTY"] = "EMPTY",
    ["PENDING_GAME"] = "PENDING_GAME",
    ["GAME_IN_PROGRESS"] = "GAME_IN_PROGRESS",
}

Location.id = ""
Location.state = LOCATION_STATES.EMPTY
Location.tableCoords = nil
Location.pendingGame = nil
Location.maxPlayers = 0

function Location:getId()
	return self.id
end

function Location:setId(id)
	self.id = id
end

function Location:getState()
	return self.state
end

function Location:setState(state)
	self.state = state
end

function Location:getTableCoords()
	return self.tableCoords
end

function Location:setTableCoords(tableCoords)
	self.tableCoords = tableCoords
end

function Location:getPendingGame()
	return self.pendingGame
end

function Location:setPendingGame(pendingGame)
	self.pendingGame = pendingGame
end

function Location:getMaxPlayers()
	return self.maxPlayers
end

function Location:setMaxPlayers(maxPlayers)
	self.maxPlayers = maxPlayers
end



---@return Location
function Location:New(obj)
	local instance = setmetatable({}, {
        __index = self
    })
    instance.id = obj.id
	instance.state = obj.state
	instance.tableCoords = obj.tableCoords
	instance.maxPlayers = obj.maxPlayers
    return instance
end