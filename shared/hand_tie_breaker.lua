


-- STRAIGHT FLUSH: Same suit, and royalties are in sequential order
-- 1. The higher highest-card wins
function breakTieOfStraightFlushes(handI, handII)

    if Config.DebugPrint then print("breakTieOfStraightFlushes", handI:getString(), handII:getString()) end


    -- STEP 1

    local handIHighestRoyaltyIndex = findRoyaltyIndex(handI:getHandsHighestRoyalty())
    local handIIHighestRoyaltyIndex = findRoyaltyIndex(handII:getHandsHighestRoyalty())

    if handIHighestRoyaltyIndex > handIIHighestRoyaltyIndex then
        return handI
    elseif handIHighestRoyaltyIndex < handIIHighestRoyaltyIndex then
        return handII
    end


	return false
end

-- FOUR OF A KIND: A quadruplet of the same royalty (e.g. all four Aces from the deck)
-- 1. The higher quadruplet wins (QQQQ v. 9999)
-- (Note: It should be impossible for two players to both have QQQQ and QQQQ.)
function breakTieOfFourOfAKinds(handI, handII)

    if Config.DebugPrint then print("breakTieOfFourOfAKinds", handI:getString(), handII:getString()) end


	-- STEP 1

    local handIBestQuadrupletsRoyalty
    local handIIBestQuadrupletsRoyalty

    -- Get handI's quadruplet
	for k,v in pairs(handI:findDuplicateRoyalties()) do
        if v == 4 then
            handIBestQuadrupletsRoyalty = k
            break
        end
    end

    -- Get handII's quadruplet
	for k,v in pairs(handII:findDuplicateRoyalties()) do
        if v == 4 then
            handIIBestQuadrupletsRoyalty = k
            break
        end
    end

    if findRoyaltyIndex(handIBestQuadrupletsRoyalty) > findRoyaltyIndex(handIIBestQuadrupletsRoyalty) then
        return handI
    elseif findRoyaltyIndex(handIBestQuadrupletsRoyalty) < findRoyaltyIndex(handIIBestQuadrupletsRoyalty) then
        return handII
    end


	return false
end


-- FULL HOUSE: One pair of the same royalty, and also a triplet of (another) royalty (e.g. an 8 and 8; and then a King, King, & King)
-- 1. The higher triple wins (QQQ v. 999)
-- 2. If both players have the *same triple*, then the higher *PAIR* wins.
-- 3. If both players have the same triple *AND* the same pair, then __chop the pot__.
function breakTieOfFullHouses(handI, handII)

    if Config.DebugPrint then print("breakTieOfFullHouses", handI:getString(), handII:getString()) end


	-- STEP 1

    local handIBestTripletsRoyalty
    local handIIBestTripletsRoyalty

    -- Get handI's triplet
	for k,v in pairs(handI:findDuplicateRoyalties()) do
        if v == 3 then
            handIBestTripletsRoyalty = k
            break
        end
    end

    -- Get handII's triplet
	for k,v in pairs(handII:findDuplicateRoyalties()) do
        if v == 3 then
            handIIBestTripletsRoyalty = k
            break
        end
    end

    if findRoyaltyIndex(handIBestTripletsRoyalty) > findRoyaltyIndex(handIIBestTripletsRoyalty) then
        return handI
    elseif findRoyaltyIndex(handIBestTripletsRoyalty) < findRoyaltyIndex(handIIBestTripletsRoyalty) then
        return handII
    end


    -- ...
    -- STEP 2

    -- The 4th card is one of the pair
    local handIFourthCard = handI:getCards()[4]
    local handIPairsRoyaltyIndex = findRoyaltyIndex(handIFourthCard:getRoyalty())

    local handIIFourthCard = handII:getCards()[4]
    local handIIPairsRoyaltyIndex = findRoyaltyIndex(handIIFourthCard:getRoyalty())

    if handIPairsRoyaltyIndex > handIIPairsRoyaltyIndex then
        return handI
    elseif handIPairsRoyaltyIndex < handIIPairsRoyaltyIndex then
        return handII
    end


    -- ...
    -- STEP 3

    if handIPairsRoyaltyIndex == handIIPairsRoyaltyIndex then
        return true
    end
    

	return false
end


-- FLUSH: Five cards of the same SUIT -- but royalty doesn't matter (e.g. a 2, 7, 10, Jack, & Queen, but all are spades)
-- 1. Higher highest-card wins.
-- 2. If both share the same highest card, then the next highest card is counted
-- 2b. And so on until a winner is decided
function breakTieOfFlushes(handI, handII)

    if Config.DebugPrint then print("breakTieOfFlushes", handI:getString(), handII:getString()) end


	-- STEP 1

    for i=1,5 do
		
        local handICard = handI:getCards()[i]
        local handICardRoyaltyIndex = findRoyaltyIndex(handICard:getRoyalty())

        local handIICard = handII:getCards()[i]
        local handIICardRoyaltyIndex = findRoyaltyIndex(handIICard:getRoyalty())
        
        if handICardRoyaltyIndex > handIICardRoyaltyIndex then
            return handI
        elseif handICardRoyaltyIndex < handIICardRoyaltyIndex then
            return handII
        end
	end


    -- It must be a true tie (all exact same royalties)
    return true

end


-- STRAIGHT: Five cards with their royalty in sequential order -- but suit doesn't matter (e.g. a 3, 4, 5, 6, & 7)
function breakTieOfStraights(handI, handII)

    if Config.DebugPrint then print("breakTieOfStraights", handI:getString(), handII:getString()) end


	-- STEP 1

    for i=1,5 do
		
        local handICard = handI:getCards()[i]
        local handICardRoyaltyIndex = findRoyaltyIndex(handICard:getRoyalty())

        local handIICard = handII:getCards()[i]
        local handIICardRoyaltyIndex = findRoyaltyIndex(handIICard:getRoyalty())
        
        if handICardRoyaltyIndex > handIICardRoyaltyIndex then
            return handI
        elseif handICardRoyaltyIndex < handIICardRoyaltyIndex then
            return handII
        end
	end

    
    -- It must be a true tie (all exact same royalties)
    return true

end

-- THREE OF A KIND: A triplet of the same royalty (e.g. three 4's)
-- 1. The higher triplet wins (QQQ v. 999)
-- (Note: It should be impossible for two players to both have QQQ and QQQ.)
function breakTieOfThreeOfAKinds(handI, handII)

    if Config.DebugPrint then print("breakTieOfThreeOfAKinds", handI:getString(), handII:getString()) end


	-- STEP 1

    local handIBestTripletsRoyalty
    local handIIBestTripletsRoyalty

    -- Get handI's triplets
	for k,v in pairs(handI:findDuplicateRoyalties()) do
        if v == 3 then
            handIBestTripletsRoyalty = k
            break
        end
    end

    -- Get handII's triplets
	for k,v in pairs(handII:findDuplicateRoyalties()) do
        if v == 3 then
            handIIBestTripletsRoyalty = k
            break
        end
    end

    if findRoyaltyIndex(handIBestTripletsRoyalty) > findRoyaltyIndex(handIIBestTripletsRoyalty) then
        return handI
    elseif findRoyaltyIndex(handIBestTripletsRoyalty) < findRoyaltyIndex(handIIBestTripletsRoyalty) then
        return handII
    end

    
    -- It must be a true tie (all exact same royalties)
    return true

end

-- TWO PAIRS: Two pairs of cards, each pair with matching royalty (e.g. two 5's and two 9's)
-- 1. The higher pair wins (QQTT v. 9977).
-- 2. If both have the same-royalty pairs (QQTT v. QQTT), then go with the highest "kicker".
function breakTieOfTwoTwoPairs(handI, handII)

    if Config.DebugPrint then print("breakTieOfTwoPairs", handI:getString(), handII:getString()) end


    -- STEP 1

    local handIDuplicateRoyalties = handI:findDuplicateRoyalties()

    local handIPairIRoyalty
    local handIPairIIRoyalty

    local i = 1
    for k,v in pairs(handIDuplicateRoyalties) do
        if i == 1 then
            handIPairIRoyalty = k
        else
            -- They are unordered, so make sure Pair I is actually the higher pair
            if findRoyaltyIndex(k) > findRoyaltyIndex(handIPairIRoyalty) then
                handIPairIIRoyalty = handIPairIRoyalty
                handIPairIRoyalty = k
            else
                handIPairIIRoyalty = k
            end
        end
        i = i + 1
    end


    local handIIDuplicateRoyalties = handII:findDuplicateRoyalties()

    local handIIPairIRoyalty
    local handIIPairIIRoyalty

    i = 1
    for k,v in pairs(handIIDuplicateRoyalties) do
        if i == 1 then
            handIIPairIRoyalty = k
        else
            -- They are unordered, so make sure Pair I is actually the higher pair
            if findRoyaltyIndex(k) > findRoyaltyIndex(handIIPairIRoyalty) then
                handIIPairIIRoyalty = handIIPairIRoyalty
                handIIPairIRoyalty = k
            else
                handIIPairIIRoyalty = k
            end
        end
        i = i + 1
    end


    if Config.DebugPrint then print(">277 breakTieOfTwoPairs - handIPairIRoyalty, handIPairIIRoyalty", handIPairIRoyalty, handIPairIIRoyalty) end
    if Config.DebugPrint then print(">278 breakTieOfTwoPairs - handIIPairIRoyalty, handIIPairIIRoyalty", handIIPairIRoyalty, handIIPairIIRoyalty) end


    -- Compare the first pair
    if findRoyaltyIndex(handIPairIRoyalty) > findRoyaltyIndex(handIIPairIRoyalty) then
        return handI
    elseif findRoyaltyIndex(handIPairIRoyalty) < findRoyaltyIndex(handIIPairIRoyalty) then
        return handII
    end

    -- Compare the second pair
    if findRoyaltyIndex(handIPairIIRoyalty) > findRoyaltyIndex(handIIPairIIRoyalty) then
        return handI
    elseif findRoyaltyIndex(handIPairIIRoyalty) < findRoyaltyIndex(handIIPairIIRoyalty) then
        return handII
    end



	-- STEP 2: KICKER

    for i=1,5 do
		
        local handICard = handI:getCards()[i]
        local handICardRoyaltyIndex = findRoyaltyIndex(handICard:getRoyalty())

        local handIICard = handII:getCards()[i]
        local handIICardRoyaltyIndex = findRoyaltyIndex(handIICard:getRoyalty())
        
        if handICardRoyaltyIndex > handIICardRoyaltyIndex then
            return handI
        elseif handICardRoyaltyIndex < handIICardRoyaltyIndex then
            return handII
        end
	end

    
    -- It must be a true tie (all exact same royalties)
    return true

end

-- ONE PAIR
-- 1. The higher pair wins (QQ v. 99).
-- 2. If both have the same-royalty pairs (QQ v. QQ), then go with the highest "kicker" (QQT v. QQ8).
-- 3. If all players have the same pair *AND* the same kickers (QQT82 v. QQT82), then __chop the pot__.
function breakTieOfTwoOnePairs(handI, handII)

    if Config.DebugPrint then print("breakTieOfTwoOfAKinds", handI:getString(), handII:getString()) end


    -- STEP 1
    local handIBestPairsRoyalty
    local handIIBestPairsRoyalty

    -- Get handI's pair
	for k,v in pairs(handI:findDuplicateRoyalties()) do
        if v == 2 then
            handIBestPairsRoyalty = k
            break
        end
    end

    -- Get handII's pair
	for k,v in pairs(handII:findDuplicateRoyalties()) do
        if v == 2 then
            handIIBestPairsRoyalty = k
            break
        end
    end

    if findRoyaltyIndex(handIBestPairsRoyalty) > findRoyaltyIndex(handIIBestPairsRoyalty) then
        return handI
    elseif findRoyaltyIndex(handIBestPairsRoyalty) < findRoyaltyIndex(handIIBestPairsRoyalty) then
        return handII
    end



	-- STEP 2: KICKER

    for i=1,5 do
		
        local handICard = handI:getCards()[i]
        local handICardRoyaltyIndex = findRoyaltyIndex(handICard:getRoyalty())

        local handIICard = handII:getCards()[i]
        local handIICardRoyaltyIndex = findRoyaltyIndex(handIICard:getRoyalty())
        
        if handICardRoyaltyIndex > handIICardRoyaltyIndex then
            return handI
        elseif handICardRoyaltyIndex < handIICardRoyaltyIndex then
            return handII
        end
	end

    
    -- It must be a true tie (all exact same royalties)
    return true

end