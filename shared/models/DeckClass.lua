---@class Deck
Deck = {}


SUITS = { "c", "d", "h", "s" } -- clubs, diamonds, hearts, spades
ROYALTIES = { "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K", "A" }


Deck.cardsIn = {}


function Deck:getCardsIn()
	return self.cardsIn
end

function Deck:setCardsIn(cardsIn)
	self.cardsIn = cardsIn
end

-- Pull a card (remove it from the array and return it)
function Deck:pullCardByKey(cardKey)
    -- if Config.DebugPrint then print("Deck:pullCardByKey - self.cardsIn", self.cardsIn) end
    -- if Config.DebugPrint then print("Deck:pullCardByKey - cardKey", cardKey) end
    local pulledCard = self.cardsIn[cardKey]
    table.remove(self.cardsIn, cardKey)
    -- if Config.DebugPrint then print("Deck:pullCardByKey - self.cardsIn after remove", self.cardsIn) end
    -- if Config.DebugPrint then print("Deck:pullCardByKey - pulledCard", pulledCard) end
    return pulledCard
end

-- Get the table key of a random card in the deck
function Deck:getRandomCardKey()

    -- Get all the cards' indexes/keys
    local keyset = {}
    for k in pairs(self.cardsIn) do
        table.insert(keyset, k)
    end

    local randomCardKey = keyset[math.random(#keyset)]

    return randomCardKey
end

-- Setup the initial deck with all 52 cards
function Deck:init()

    -- if Config.DebugPrint then print("Deck:init - STARTING - self.cardsIn", self.cardsIn) end
    
    self.cardsIn = {}

    local newCardId = 1
    for k,v in pairs(SUITS) do
        for k2,v2 in pairs(ROYALTIES) do
            -- if Config.DebugPrint then print("Deck:init - v, v2", v, v2) end
            local card = Card:New({
                id = newCardId,
                suit = v,
                royalty = v2,
            })
            table.insert(self.cardsIn, card)
            newCardId = newCardId + 1
        end
    end

    -- if Config.DebugPrint then print("Deck:init - done - #cardsIn", #self.cardsIn) end
    -- if Config.DebugPrint then print("Deck:init - done - cardsIn", self.cardsIn) end

end



---@return Deck
function Deck:New(obj)
    local instance = setmetatable({}, {
        __index = self
    })
    return instance
end
  