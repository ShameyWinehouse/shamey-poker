

-- ROYAL FLUSH: Same suit, and specifically a 10, Jack, Queen, King, & Ace
function determineIfHandIsRoyalFlush(hand)

    -- if Config.DebugPrint then print("determineIfHandIsRoyalFlush", hand) end

	local handCards = hand:getCards()

	-- Check the suit condition
	local isAllSameSuit = checkHandAllSameSuit(handCards)

	if not isAllSameSuit then
		return false
	end

	-- Check the specific card condition
	local hasA10 = hand:hasACardWithRoyalty("T")
	local hasAJack = hand:hasACardWithRoyalty("J")
	local hasAQueen = hand:hasACardWithRoyalty("Q")
	local hasAKing = hand:hasACardWithRoyalty("K")
	local hasAAce = hand:hasACardWithRoyalty("A")

	if not hasA10 or not hasAJack or not hasAQueen or not hasAKing or not hasAAce then
		return false
	end

    if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS ROYAL FLUSH °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
    hand:setWinningHandType(WINNING_HAND_TYPES.ROYAL_FLUSH)

	return true
end

-- STRAIGHT FLUSH: Same suit, and royalties are in sequential order
function determineIfHandIsStraightFlush(hand)

    -- if Config.DebugPrint then print("determineIfHandIsStraightFlush", hand) end

    hand:sort()
	local handCards = hand:getCards()

	-- Check the suit condition
	local isAllSameSuit = checkHandAllSameSuit(handCards)

	if not isAllSameSuit then
		return false
	end

	-- Check that all cards (could be arranged) in a sequential order
    if checkHandInSequentialOrder(handCards) then
        if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS STRAIGHT FLUSH °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
        hand:setWinningHandType(WINNING_HAND_TYPES.STRAIGHT_FLUSH)
        return true
    end

	return false
end

-- FOUR OF A KIND: A quadruplet of the same royalty (e.g. all four Aces from the deck)
function determineIfHandIsFourOfAKind(hand)

    -- if Config.DebugPrint then print("determineIfHandIsFourOfAKind", hand) end

	-- Check the suit condition
    local duplicateRoyalties = hand:findDuplicateRoyalties()
    -- if Config.DebugPrint then print("64 - duplicateRoyalties", duplicateRoyalties) end

    if duplicateRoyalties then
        for k,v in pairs(duplicateRoyalties) do
            -- if Config.DebugPrint then print("68 - for k,v in pairs(duplicateRoyalties)", duplicateRoyalties) end
            if v == 4 then
                if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS FOUR OF A KIND °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
                hand:setWinningHandType(WINNING_HAND_TYPES.FOUR_OF_A_KIND)
                return true
            end
        end
    end

	return false
end

-- FULL HOUSE: One pair of the same royalty, and also a triplet of (another) royalty (e.g. an 8 and 8; and then a King, King, & King)
function determineIfHandIsFullHouse(hand)

    -- if Config.DebugPrint then print("determineIfHandIsFullHouse", hand) end

	-- Check the suit condition
    local hasAPairOfSameRoyalty = false
    local hasATripletOfSameRoyalty = false
    local duplicateRoyalties = hand:findDuplicateRoyalties()
    if duplicateRoyalties then
        for k,v in pairs(duplicateRoyalties) do
            if v == 2 then
                hasAPairOfSameRoyalty = true
            elseif v == 3 then
                hasATripletOfSameRoyalty = true
            end
        end
    end

    if hasAPairOfSameRoyalty and hasATripletOfSameRoyalty then
        if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS FULL HOUSE °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
        hand:setWinningHandType(WINNING_HAND_TYPES.FULL_HOUSE)
        return true
    else
        return false
    end

end

-- FLUSH: Five cards of the same SUIT -- but royalty doesn't matter (e.g. a 2, 7, 10, Jack, & Queen, but all are spades)
function determineIfHandIsFlush(hand)

    -- if Config.DebugPrint then print("determineIfHandIsFlush", hand) end

    local handCards = hand:getCards()

	-- Check the suit condition
    if checkHandAllSameSuit(handCards) then
        if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS FLUSH °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
        hand:setWinningHandType(WINNING_HAND_TYPES.FLUSH)
        return true
    end

    return false

end

-- STRAIGHT: Five cards with their royalty in sequential order -- but suit doesn't matter (e.g. a 3, 4, 5, 6, & 7)
function determineIfHandIsStraight(hand)

    -- if Config.DebugPrint then print("determineIfHandIsStraight", hand) end

    hand:sort()
    local handCards = hand:getCards()

	-- Check that all cards (could be arranged) in a sequential order
    if checkHandInSequentialOrder(handCards) then
        if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS STRAIGHT °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
        hand:setWinningHandType(WINNING_HAND_TYPES.STRAIGHT)
        return true
    end

    return false

end

-- THREE OF A KIND: A triplet of the same royalty (e.g. three 4's)
function determineIfHandIsThreeOfAKind(hand)

    -- if Config.DebugPrint then print("determineIfHandIsThreeOfAKind", hand) end

	-- Check the suit condition
    local duplicateRoyalties = hand:findDuplicateRoyalties()
    if duplicateRoyalties then
        for k,v in pairs(duplicateRoyalties) do
            if v == 3 then
                if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS THREE OF A KIND °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
                hand:setWinningHandType(WINNING_HAND_TYPES.THREE_OF_A_KIND)
                return true
            end
        end
    end

	return false
end

-- TWO PAIRS: Two pairs of cards, each pair with matching royalty (e.g. two 5's and two 9's)
function determineIfHandIsTwoPairs(hand)

    -- if Config.DebugPrint then print("determineIfHandIsTwoPairs", hand) end

	-- Check the suit condition
    local numberOfPairs = 0
    local duplicateRoyalties = hand:findDuplicateRoyalties()
    if duplicateRoyalties then
        for k,v in pairs(duplicateRoyalties) do
            if v == 2 then
                numberOfPairs = numberOfPairs + 1
            end
        end
    end

    if numberOfPairs == 2 then
        if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS TWO PAIRS °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
        hand:setWinningHandType(WINNING_HAND_TYPES.TWO_PAIRS)
        return true
    end

    return false

end

-- ONE PAIR: Two cards have the same royalty (e.g. two 2's)
function determineIfHandIsOnePair(hand)

    -- if Config.DebugPrint then print("determineIfHandIsOnePair", hand) end

	-- Check the suit condition
    local duplicateRoyalties = hand:findDuplicateRoyalties()
    if duplicateRoyalties then
        for k,v in pairs(duplicateRoyalties) do
            if v == 2 then
                if Config.DebugPrint then print("°❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･° IS ONE PAIR °❀⋆.ೃ࿔*:･°❀⋆.ೃ࿔*:･°", hand:getString()) end
                hand:setWinningHandType(WINNING_HAND_TYPES.ONE_PAIR)
                return true
            end
        end
    end

    return false

end

-- For HIGH CARD
function decideBetterHandForHighCard(handI, handII)

    -- if Config.DebugPrint then print("decideBetterHandForHighCard", handI, handII) end

    handI:sort()
    handII:sort()

    for i=1,5 do
		
        local handICard = handI:getCards()[i]
        local handICardRoyaltyIndex = findRoyaltyIndex(handICard:getRoyalty())

        local handIICard = handII:getCards()[i]
        local handIICardRoyaltyIndex = findRoyaltyIndex(handIICard:getRoyalty())
        
        if handICardRoyaltyIndex > handIICardRoyaltyIndex then
            handI:setWinningHandType(WINNING_HAND_TYPES.HIGH_CARD)
            return handI
        elseif handICardRoyaltyIndex < handIICardRoyaltyIndex then
            handII:setWinningHandType(WINNING_HAND_TYPES.HIGH_CARD)
            return handII
        end
	end

    -- True tie
    return true
end


-- This is for winning cases.
-- It usually returns the hand (out of the 2 parameters) that is "better".
-- In the case of a tie between the 2, it will instead return TRUE.
function decideBetterHandOverall(handI, handII)

    if Config.DebugPrint then print("decideBetterHandOverall", handI:getString(), handII:getString()) end

    handI:sort()
    handII:sort()

    -- Wait(1) -- Break for anti-hitch

    -- Royal Flush
    if determineIfHandIsRoyalFlush(handI) and not determineIfHandIsRoyalFlush(handII) then
        return handI
    elseif not determineIfHandIsRoyalFlush(handI) and determineIfHandIsRoyalFlush(handII) then
        return handII
    -- Straight Flush
    elseif determineIfHandIsStraightFlush(handI) and not determineIfHandIsStraightFlush(handII) then
        return handI
    elseif not determineIfHandIsStraightFlush(handI) and determineIfHandIsStraightFlush(handII) then
        return handII
    elseif determineIfHandIsStraightFlush(handI) and determineIfHandIsStraightFlush(handII) then
        return breakTieOfStraightFlushes(handI, handII)
    -- Four of a Kind
    elseif determineIfHandIsFourOfAKind(handI) and not determineIfHandIsFourOfAKind(handII) then
        return handI
    elseif not determineIfHandIsFourOfAKind(handI) and determineIfHandIsFourOfAKind(handII) then
        return handII
    elseif determineIfHandIsFourOfAKind(handI) and determineIfHandIsFourOfAKind(handII) then
        return breakTieOfFourOfAKinds(handI, handII)
    -- Full House
    elseif determineIfHandIsFullHouse(handI) and not determineIfHandIsFullHouse(handII) then
        return handI
    elseif not determineIfHandIsFullHouse(handI) and determineIfHandIsFullHouse(handII) then
        return handII
    elseif determineIfHandIsFullHouse(handI) and determineIfHandIsFullHouse(handII) then
        return breakTieOfFullHouses(handI, handII)
    -- Flush
    elseif determineIfHandIsFlush(handI) and not determineIfHandIsFlush(handII) then
        return handI
    elseif not determineIfHandIsFlush(handI) and determineIfHandIsFlush(handII) then
        return handII
    elseif determineIfHandIsFlush(handI) and determineIfHandIsFlush(handII) then
        return breakTieOfFlushes(handI, handII)
    -- Straight
    elseif determineIfHandIsStraight(handI) and not determineIfHandIsStraight(handII) then
        return handI
    elseif not determineIfHandIsStraight(handI) and determineIfHandIsStraight(handII) then
        return handII
    elseif determineIfHandIsStraight(handI) and determineIfHandIsStraight(handII) then
        return breakTieOfStraights(handI, handII)
    -- Three of a Kind
    elseif determineIfHandIsThreeOfAKind(handI) and not determineIfHandIsThreeOfAKind(handII) then
        return handI
    elseif not determineIfHandIsThreeOfAKind(handI) and determineIfHandIsThreeOfAKind(handII) then
        return handII
    elseif determineIfHandIsThreeOfAKind(handI) and determineIfHandIsThreeOfAKind(handII) then
        return breakTieOfThreeOfAKinds(handI, handII)
    -- Two Pairs
    elseif determineIfHandIsTwoPairs(handI) and not determineIfHandIsTwoPairs(handII) then
        return handI
    elseif not determineIfHandIsTwoPairs(handI) and determineIfHandIsTwoPairs(handII) then
        return handII
    elseif determineIfHandIsTwoPairs(handI) and determineIfHandIsTwoPairs(handII) then
        return breakTieOfTwoTwoPairs(handI, handII)
    -- One Pair
    elseif determineIfHandIsOnePair(handI) and not determineIfHandIsOnePair(handII) then
        return handI
    elseif not determineIfHandIsOnePair(handI) and determineIfHandIsOnePair(handII) then
        return handII
    elseif determineIfHandIsOnePair(handI) and determineIfHandIsOnePair(handII) then
        return breakTieOfTwoOnePairs(handI, handII)

    -- High Card
    elseif decideBetterHandForHighCard(handI, handII) == handI then
        return handI
    elseif decideBetterHandForHighCard(handI, handII) == handII then
        return handII
    else
        return true
    end
end

--------

-- Determine the winner from a showdown (i.e. fully-revealed board).
-- If no true tie, then an array of 1 is returned with the winning hand.
-- If there is a true tie, then an array of all the tied hands is returned.
-- (Note that just because there's a tie doesn't mean all remaining/non-folded players are tied.)
function getWinScenarioFromSetOfPlayers(players, board, round)

    if Config.DebugPrint then print("getWinScenarioFromSetOfPlayers()") end

    -- Get the winning hand out of all

    local eachPlayersBestHand = {}

    -- Loop through each player
    for k,player in pairs(players) do

        if Config.DebugPrint then print("getWinScenarioFromSetOfPlayers()  -------  PLAYER #"..k, player) end

        Wait(5) -- Break for anti-hitch

        if not player:getHasFolded() then

            -- Find THIS player's best hand

            local thisPlayersBestHand

            -- Check A card with all of Board's four-card combos
            local boardsFourCardCombos = board:retrieveAllFourCardCombos(false)
            for k,v in pairs(boardsFourCardCombos) do
                local hand = Hand:New({
                    cards = {
                        player:getCardA(),
                        v[1],
                        v[2],
                        v[3],
                        v[4],
                    },
                    playerNetId = player:getNetId(),
                })
                -- Check for case of first iteration
                if thisPlayersBestHand then
                    local betterHand = decideBetterHandOverall(thisPlayersBestHand, hand)
                    if betterHand == hand then
                        thisPlayersBestHand = hand
                    end
                else
                    thisPlayersBestHand = hand
                end
            end

            if thisPlayersBestHand then
                if Config.DebugPrint then print("--------------------------") end
                if Config.DebugPrint then print("--best hand after A:", thisPlayersBestHand:getString()) end
            end


            -- Check B card with all of Board's four-card combos
            for k,v in pairs(boardsFourCardCombos) do
                local hand = Hand:New({
                    cards = {
                        player:getCardB(),
                        v[1],
                        v[2],
                        v[3],
                        v[4],
                    },
                    playerNetId = player:getNetId(),
                })
                -- Check for case of first iteration
                if thisPlayersBestHand then
                    local betterHand = decideBetterHandOverall(thisPlayersBestHand, hand)
                    if betterHand == hand then
                        thisPlayersBestHand = hand
                    end
                else
                    thisPlayersBestHand = hand
                end
            end

            if thisPlayersBestHand then
                if Config.DebugPrint then print("--------------------------") end
                if Config.DebugPrint then print("--best hand after B:", thisPlayersBestHand:getString()) end
            end


            -- Check A & B cards with all of Board's three-card combos
            local boardsThreeCardCombos = board:retrieveAllThreeCardCombos(false)
            for k,v in pairs(boardsThreeCardCombos) do
                local hand = Hand:New({
                    cards = {
                        player:getCardA(),
                        player:getCardB(),
                        v[1],
                        v[2],
                        v[3],
                    },
                    playerNetId = player:getNetId(),
                })
                -- Check for case of first iteration
                if thisPlayersBestHand then
                    local betterHand = decideBetterHandOverall(thisPlayersBestHand, hand)
                    if betterHand == hand then
                        thisPlayersBestHand = hand
                    end
                else
                    thisPlayersBestHand = hand
                end
            end

            if Config.DebugPrint then print("--------------------------") end
            if Config.DebugPrint then print("--best hand after A&B:", thisPlayersBestHand:getString()) end


            -- Only if there's 5 revealed cards on the board (River/Showdown)
            if round == ROUNDS.RIVER or round == ROUNDS.SHOWDOWN then
                -- Check no-hole (just board cards)
                local hand = Hand:New({
                    cards = board:retrieveAllFiveCards(),
                    playerNetId = player:getNetId(),
                })
                local betterHand = decideBetterHandOverall(thisPlayersBestHand, hand)
                if betterHand == hand then
                    thisPlayersBestHand = hand
                end
            end


            if Config.DebugPrint then print("--------------------------") end
            if Config.DebugPrint then print("--------------------------") end
            if Config.DebugPrint then print("getWinScenarioFromSetOfPlayers() - PLAYER #"..k.." - thisPlayersBestHand:", thisPlayersBestHand:getString()) end
            if Config.DebugPrint then print("--------------------------") end
            if Config.DebugPrint then print("--------------------------") end

            eachPlayersBestHand[thisPlayersBestHand:getPlayerNetId()] = thisPlayersBestHand
        end
    end

    Wait(5) -- Break for anti-hitch

    -- Now find the best winning hand (and its player)
    -- We will look for any true-ties with it NEXT
    local absoluteBestWinningHand
    
    -- Loop thru each player's best hand
    for k,playerBestWinningHand in pairs(eachPlayersBestHand) do

        -- If this is NOT the first iteration (i.e. `absoluteBestWinningHand` has been set before)
        if absoluteBestWinningHand then

            local betterHand = decideBetterHandOverall(playerBestWinningHand, absoluteBestWinningHand)

            -- If `betterHand` is better than the previously-known `absoluteBestWinningHand`
            if betterHand == playerBestWinningHand then
                absoluteBestWinningHand = playerBestWinningHand
            end
        else
            -- This is the first iteration of the loop, so this first hand is the best (so far)
            absoluteBestWinningHand = playerBestWinningHand
        end
    end

    if Config.DebugPrint then print("--------------------------") end
    if Config.DebugPrint then print("getWinScenarioFromSetOfPlayers() - absoluteBestWinningHand:", absoluteBestWinningHand) end
    if Config.DebugPrint then print("--------------------------") end


    -- We now have the final, correct `absoluteBestWinningHand`. But are there any TRUE-TIED Hands?

    -- TRUE-TIES
    local doesTrueTieExist = false
    local trueTieWinningHands = {}

    -- Loop thru each player's best hand
    for k,playerBestWinningHand in pairs(eachPlayersBestHand) do

        if playerBestWinningHand ~= absoluteBestWinningHand then

            local betterHand = decideBetterHandOverall(playerBestWinningHand, absoluteBestWinningHand)

            -- If `betterHand` is "true", this means THIS comparison is a TRUE-TIE (i.e. neither hand is better than the other)
            if betterHand == true then
                
                doesTrueTieExist = true

                -- Add this player's hand to `trueTieWinningHands` array
                table.insert(trueTieWinningHands, playerBestWinningHand)

                -- Add the `absoluteBestWinningHand` to `trueTieWinningHands` array if it hasn't been yet
                if not indexOf(trueTieWinningHands, absoluteBestWinningHand) then
                    table.insert(trueTieWinningHands, absoluteBestWinningHand)
                end

                if Config.DebugPrint then print("TIE SITUATION!!!!!!!!!") end
            end

        end
    end

    
    -- Create the WinScenario for returning
    local winScenario = WinScenario:New({
        isTrueTie = doesTrueTieExist,
        playersBestHands = eachPlayersBestHand,
    })

    if doesTrueTieExist then
        winScenario:setTiedHands(trueTieWinningHands)
    else
        winScenario:setWinningHand(absoluteBestWinningHand)
    end

    return winScenario

end

--------

function checkHandAllSameSuit(handCards)
    -- if Config.DebugPrint then print("checkHandAllSameSuit", handCards) end
    local isAllSameSuit = false
	if not handCards[1]:compareIsSameSuit(handCards[2]) or not handCards[2]:compareIsSameSuit(handCards[3]) or not handCards[3]:compareIsSameSuit(handCards[4]) or not handCards[4]:compareIsSameSuit(handCards[5]) then
		isAllSameSuit = false
	else
		isAllSameSuit = true
	end
    return isAllSameSuit
end

function checkHandInSequentialOrder(handCards)
    -- if Config.DebugPrint then print("checkHandInSequentialOrder", handCards) end
    if findRoyaltyIndex(handCards[1]:getRoyalty()) - 1 == findRoyaltyIndex(handCards[2]:getRoyalty()) and
        findRoyaltyIndex(handCards[2]:getRoyalty()) - 1 == findRoyaltyIndex(handCards[3]:getRoyalty()) and
        findRoyaltyIndex(handCards[3]:getRoyalty()) - 1 == findRoyaltyIndex(handCards[4]:getRoyalty()) and
        findRoyaltyIndex(handCards[4]:getRoyalty()) - 1 == findRoyaltyIndex(handCards[5]:getRoyalty())
            then
                if Config.DebugPrint then print("checkHandInSequentialOrder --- ✓⃝ ദ്ദി(˵ •̀ ᴗ - ˵ ) ✧ --- YES ITS SEQUENTIAL ", handCards) end
                return true
	end

    return false
end

--------
function findRoyaltyIndex(royalty)
    return indexOf(ROYALTIES, royalty)
end