---@class Board
Board = {}

-- FLOP CARDS: 	V, W, X
-- TURN CARD: 	Y
-- RIVER CARD: 	Z

Board.cardV = nil
Board.cardW = nil
Board.cardX = nil
Board.cardY = nil
Board.cardZ = nil
Board.stringified = ""

function Board:getCardV()
	return self.cardV
end

function Board:setCardV(cardV)
	self.cardV = cardV
end

function Board:getCardW()
	return self.cardW
end

function Board:setCardW(cardW)
	self.cardW = cardW
end

function Board:getCardX()
	return self.cardX
end

function Board:setCardX(cardX)
	self.cardX = cardX
end

function Board:getCardY()
	return self.cardY
end

function Board:setCardY(cardY)
	self.cardY = cardY
end

function Board:getCardZ()
	return self.cardZ
end

function Board:setCardZ(cardZ)
	self.cardZ = cardZ
end

function Board:getString()

	self:formString()

	return Board.stringified
end

function Board:setString(str)
	Board.stringified = str
end

--------

function Board:formString()
	if self then
		local str = ""
		str = str .. self:getCardV():getString()
		str = str .. self:getCardW():getString()
		str = str .. self:getCardX():getString()
		str = str .. self:getCardY():getString()
		str = str .. self:getCardZ():getString()
		self:setString(str)
	end
end

function Board:retrieveAllFiveCards()
	return {
		self:getCardV(), self:getCardW(), self:getCardX(), self:getCardY(), self:getCardZ(),
	}
end

function Board:retrieveAllThreeCardCombos(overrideUnrevealed)
	-- There should be TEN three-card combos

	local combos = {
		{ self:getCardV(), self:getCardW(), self:getCardX(), },
		{ self:getCardV(), self:getCardW(), self:getCardY(), },
		{ self:getCardV(), self:getCardW(), self:getCardZ(), },
		{ self:getCardV(), self:getCardX(), self:getCardY(), },
		{ self:getCardV(), self:getCardX(), self:getCardZ(), },
		{ self:getCardV(), self:getCardY(), self:getCardZ(), },

		{ self:getCardW(), self:getCardX(), self:getCardY(), },
		{ self:getCardW(), self:getCardX(), self:getCardZ(), },
		{ self:getCardW(), self:getCardY(), self:getCardZ(), },

		{ self:getCardX(), self:getCardY(), self:getCardZ(), },
	}

	if overrideUnrevealed then
		return combos
	end

	local revealedCombos = {}
	for k,v in pairs(combos) do
		local allCardsRevealedInThisCombo = true
		for k2,v2 in pairs(v) do
			if not v2:getIsRevealed() then
				allCardsRevealedInThisCombo = false
			end
		end
		if allCardsRevealedInThisCombo then
			table.insert(revealedCombos, v)
		end
	end

	return revealedCombos
end

function Board:retrieveAllFourCardCombos(overrideUnrevealed)
	-- There should be FIVE four-card combos

	local combos = {
		{ self:getCardV(), self:getCardW(), self:getCardX(), self:getCardY(), },
		{ self:getCardV(), self:getCardW(), self:getCardX(), self:getCardZ(), },
		{ self:getCardV(), self:getCardW(), self:getCardY(), self:getCardZ(), },
		{ self:getCardV(), self:getCardX(), self:getCardY(), self:getCardZ(), },

		{ self:getCardW(), self:getCardX(), self:getCardY(), self:getCardZ(), },
	}

	if overrideUnrevealed then
		return combos
	end

	local revealedCombos = {}
	for k,v in pairs(combos) do
		local allCardsRevealedInThisCombo = true
		for k2,v2 in pairs(v) do
			if not v2:getIsRevealed() then
				allCardsRevealedInThisCombo = false
			end
		end
		if allCardsRevealedInThisCombo then
			table.insert(revealedCombos, v)
		end
	end

	return revealedCombos
end


---@return Board
function Board:New(obj)
	local instance = setmetatable({}, {
        __index = self
    })
	instance.cardV = obj.cardV
	instance.cardW = obj.cardW
	instance.cardX = obj.cardX
	instance.cardY = obj.cardY
	instance.cardZ = obj.cardZ
    return instance
end