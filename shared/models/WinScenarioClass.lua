---@class WinScenario
WinScenario = {}

WinScenario.isTrueTie = false
WinScenario.winningHand = nil
WinScenario.tiedHands = {}
WinScenario.playersBestHands = {}

function WinScenario:getIsTrueTie()
	return self.isTrueTie
end

function WinScenario:setIsTrueTie(isTrueTie)
	self.isTrueTie = isTrueTie
end

function WinScenario:getWinningHand()
	return self.winningHand
end

function WinScenario:setWinningHand(winningHand)
	self.winningHand = winningHand
end

function WinScenario:getTiedHands()
	return self.tiedHands
end

function WinScenario:setTiedHands(tiedHands)
	self.tiedHands = tiedHands
end

function WinScenario:getPlayersBestHands()
	return self.playersBestHands
end

function WinScenario:setPlayersBestHands(playersBestHands)
	self.playersBestHands = playersBestHands
end



---@return WinScenario
function WinScenario:New(obj)
	local instance = setmetatable({}, {
        __index = self
    })
    instance.isTrueTie = obj.isTrueTie
	instance.playersBestHands = obj.playersBestHands
    return instance
end