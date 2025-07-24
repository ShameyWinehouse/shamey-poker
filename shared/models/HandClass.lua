---@class Hand
Hand = {}

WINNING_HAND_TYPES = {
    ["ROYAL_FLUSH"] = "ROYAL_FLUSH",
    ["STRAIGHT_FLUSH"] = "STRAIGHT_FLUSH",
    ["FOUR_OF_A_KIND"] = "FOUR_OF_A_KIND",
    ["FULL_HOUSE"] = "FULL_HOUSE",
    ["FLUSH"] = "FLUSH",
    ["STRAIGHT"] = "STRAIGHT",
    ["THREE_OF_A_KIND"] = "THREE_OF_A_KIND",
    ["TWO_PAIRS"] = "TWO_PAIRS",
    ["ONE_PAIR"] = "ONE_PAIR",
    ["HIGH_CARD"] = "HIGH_CARD",
}

-- NOTE: Hands are theoretical

Hand.cards = {}
Hand.stringified = ""
Hand.playerNetId = 0
Hand.winningHandType = nil

function Hand:getCards()
	return self.cards
end

function Hand:setCards(cards)
	self.cards = cards

	self:sort()

	self:formString()
end

function Hand:getString()

	self:formString()

	return self.stringified
end

function Hand:setString(str)
	self.stringified = str
end

function Hand:getPlayerNetId()
	return self.playerNetId
end

function Hand:setPlayerNetId(playerNetId)
	self.playerNetId = playerNetId
end

function Hand:getWinningHandType()
	return self.winningHandType
end

function Hand:setWinningHandType(winningHandType)
	self.winningHandType = winningHandType
end


---------

function Hand:formString()
	if self and self.cards and #self.cards>0 then
		local str = ""
		for i=1,5 do
			str = str .. self.cards[i]:getRoyalty()
			str = str .. self.cards[i]:getSuit()
		end
		self:setString(str)
	end
end

function compareCardsInHandByRoyalty(a, b)
	return indexOf(ROYALTIES, a:getRoyalty()) > indexOf(ROYALTIES, b:getRoyalty())
end

-- Gets the highest-ranking royalty of the cards in the hand
function Hand:getHandsHighestRoyalty()
	local highestRoyaltyRank = 1
	
	for k,v in pairs(self.cards) do
		local royaltyRankOfCard = indexOf(ROYALTIES, v:getRoyalty())
		if royaltyRankOfCard > highestRoyaltyRank then
			highestRoyaltyRank = royaltyRankOfCard
		end
	end

	-- if Config.DebugPrint then print("Hand:getHandsHighestRoyalty - ", ROYALTIES[highestRoyaltyRank]) end

	return ROYALTIES[highestRoyaltyRank]
end

function Hand:sort()
	table.sort(self.cards, compareCardsInHandByRoyalty)
end

function Hand:hasACardWithRoyalty(royalty)
	local hasThisRoyalty = false
	for i=1,5 do
		if self.cards[i]:getRoyalty() == royalty then
			hasThisRoyalty = true
			break
		end
	end
	return hasThisRoyalty
end

function Hand:findDuplicateRoyalties()

	-- if Config.DebugPrint then print("Hand:findDuplicateRoyalties") end

	-- Create a table of each royalty in the hand and the number of times that royalty appears
	local royaltyCounts = {}
	for i=1,5 do
		local cardRoyalty = self.cards[i]:getRoyalty()
		if not royaltyCounts[cardRoyalty] then
			royaltyCounts[cardRoyalty] = 1
		else
			royaltyCounts[cardRoyalty] = royaltyCounts[cardRoyalty] + 1
		end
	end

	-- Keep only the royalties that appear 2+ times (pairs, triplets, quads, etc.)
	local dupedRoyalties = {}
	for k,v in pairs(royaltyCounts) do
		if v > 1 then
			dupedRoyalties[k] = v
		end
	end

	if tablelength(dupedRoyalties) > 0 then
		return dupedRoyalties
	else
		return false
	end
	
end




---@return Hand
function Hand:New(obj)
	local instance = setmetatable({}, {
        __index = self
    })
    instance.cards = obj.cards
	instance.playerNetId = obj.playerNetId

	self:formString()

    return instance
end