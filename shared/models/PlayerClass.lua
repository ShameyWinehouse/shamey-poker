---@class Player
Player = {}

Player.netId = 0
Player.name = ""
Player.order = 1
Player.cardA = nil
Player.cardB = nil
Player.isNpc = false

Player.actionInitial = nil
Player.actionFlop = nil
Player.actionTurn = nil
Player.actionRiver = nil

Player.lastBetAmount = 0
Player.amountBetInRound = 0
Player.totalAmountBetInGame = 0

Player.hasFolded = false


function Player:getNetId()
	return self.netId
end

function Player:setNetId(netId)
	self.netId = netId
end

function Player:getName()
	return self.name
end

function Player:setName(name)
	self.name = name
end

function Player:getOrder()
	return self.order
end

function Player:setOrder(order)
	self.order = order
end

function Player:getCardA()
	return self.cardA
end

function Player:setCardA(cardA)
	self.cardA = cardA
end

function Player:getCardB()
	return self.cardB
end

function Player:setCardB(cardB)
	self.cardB = cardB
end

function Player:getIsNpc()
	return self.isNpc
end

function Player:setIsNpc(isNpc)
	self.isNpc = isNpc
end

function Player:getActionInitial()
	return self.actionInitial
end

function Player:setActionInitial(actionInitial)
	self.actionInitial = actionInitial
end

function Player:getActionFlop()
	return self.actionFlop
end

function Player:setActionFlop(actionFlop)
	self.actionFlop = actionFlop
end

function Player:getActionTurn()
	return self.actionTurn
end

function Player:setActionTurn(actionTurn)
	self.actionTurn = actionTurn
end

function Player:getActionRiver()
	return self.actionRiver
end

function Player:setActionRiver(actionRiver)
	self.actionRiver = actionRiver
end

function Player:getLastBetAmount()
	return self.lastBetAmount
end

function Player:setLastBetAmount(lastBetAmount)
	self.lastBetAmount = lastBetAmount
end

function Player:getAmountBetInRound()
	return self.amountBetInRound
end

function Player:setAmountBetInRound(amountBetInRound)
	self.amountBetInRound = amountBetInRound
end

function Player:getTotalAmountBetInGame()
	return self.totalAmountBetInGame
end

function Player:setTotalAmountBetInGame(totalAmountBetInGame)
	self.totalAmountBetInGame = totalAmountBetInGame
end

function Player:getHasFolded()
	return self.hasFolded
end

function Player:setHasFolded(hasFolded)
	self.hasFolded = hasFolded
end


--------

function Player:findActionThisRound(round)

	if Config.DebugPrint then print("Player:findActionThisRound(round) - round:", round) end


	if round == ROUNDS.INITIAL then
		return self:getActionInitial()
	elseif round == ROUNDS.FLOP then
		return self:getActionFlop()
	elseif round == ROUNDS.TURN then
		return self:getActionTurn()
	elseif round == ROUNDS.RIVER then
		return self:getActionRiver()
	end

end


---@return Player
function Player:New(obj)
	local instance = setmetatable({}, {
        __index = self
    })
    instance.netId = obj.netId
	instance.cardA = obj.cardA
	instance.cardB = obj.cardB
	instance.name = obj.name
	instance.order = obj.order
	instance.totalAmountBetInGame = obj.totalAmountBetInGame
    return instance
end