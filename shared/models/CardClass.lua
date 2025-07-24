---@class Card
Card = {}

Card.id = 0
Card.suit = nil
Card.royalty = nil
Card.isRevealed = false
Card.stringified = ""

function Card:getId()
	return self.id
end

function Card:setId(id)
	self.id = id
end

function Card:getSuit()
	return self.suit
end

function Card:setSuit(suit)
	self.suit = suit
end

function Card:getRoyalty()
	return self.royalty
end

function Card:setRoyalty(royalty)
	self.royalty = royalty
end

function Card:getIsRevealed()
	return self.isRevealed
end

function Card:setIsRevealed(isRevealed)
	self.isRevealed = isRevealed
end

function Card:getString()

	self:formString()

	return Card.stringified
end

function Card:setString(str)
	Card.stringified = str
end

---------

function Card:formString()
	if self then
		local str = ""
		str = str .. self:getRoyalty()
		str = str .. self:getSuit()
		self:setString(str)
	end
end

function Card:compareIsSameSuit(comparingCard)
	return self.suit == comparingCard.suit
end

function Card:compareIsSameRoyalty(comparingCard)
	return self.royalty == comparingCard.royalty
end



---@return Card
function Card:New(obj)
    local instance = setmetatable({}, {
        __index = self
    })
	instance.royalty = obj.royalty
	instance.suit = obj.suit
	instance.isRevealed = obj.isRevealed
    return instance
end