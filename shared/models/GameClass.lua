---@class Game
Game = {}

ACTIONS = {
    ["CALL"] = "CALL",
    ["CHECK"] = "CHECK",
    ["RAISE"] = "RAISE",
    ["FOLD"] = "FOLD",
}

ROUNDS = {
    ["PENDING"] = "PENDING",
    ["INITIAL"] = "INITIAL",
    ["FLOP"] = "FLOP",
    ["TURN"] = "TURN",
    ["RIVER"] = "RIVER",
    ["SHOWDOWN"] = "SHOWDOWN",
    ["DONE"] = "DONE",
}


Game.locationIndex = 0
Game.deck = nil
Game.players = {}
Game.board = nil
Game.step = ROUNDS.PENDING -- pending, initial, flop, turn, river, showdown
Game.isSubround = false
Game.currentTurn = 1
Game.ante = 0
Game.bettingPool = 0
Game.currentGoingBet = 0
Game.roundsHighestBet = 0

Game.turnTimer = nil
Game.turnTimerWarned = false


function Game:getLocationIndex()
	return self.locationIndex
end

function Game:setLocationIndex(locationIndex)
	self.locationIndex = locationIndex
end

function Game:getDeck()
	return self.deck
end

function Game:setDeck(deck)
	self.deck = deck
end

function Game:getPlayers()
	return self.players
end

function Game:setPlayers(players)
	self.players = players
end

function Game:getBoard()
	return self.board
end

function Game:setBoard(board)
	self.board = board
end

function Game:getStep()
	return self.step
end

function Game:setStep(step)
	self.step = step

    if self.step == ROUNDS.FLOP then
        self.board:getCardV():setIsRevealed(true)
        self.board:getCardW():setIsRevealed(true)
        self.board:getCardX():setIsRevealed(true)
    elseif self.step == ROUNDS.TURN then
        self.board:getCardY():setIsRevealed(true)
    elseif self.step == ROUNDS.RIVER then
        self.board:getCardZ():setIsRevealed(true)
    elseif self.step == ROUNDS.SHOWDOWN then

        self.board:getCardV():setIsRevealed(true)
        self.board:getCardW():setIsRevealed(true)
        self.board:getCardX():setIsRevealed(true)
        self.board:getCardY():setIsRevealed(true)
        self.board:getCardZ():setIsRevealed(true)

        -- Showdown means showing all the players' cards to everyone else
        for k,player in pairs(self.players) do
            player:getCardA():setIsRevealed(true)
            player:getCardB():setIsRevealed(true)
        end
    end
end

function Game:getIsSubround()
	return self.isSubround
end

function Game:setIsSubround(isSubround)
	self.isSubround = isSubround
end

function Game:getCurrentTurn()
	return self.currentTurn
end

function Game:setCurrentTurn(currentTurn)
	self.currentTurn = currentTurn
end

function Game:getAnte()
	return self.ante
end

function Game:setAnte(ante)
	self.ante = ante
end

function Game:getBettingPool()
	return self.bettingPool
end

function Game:setBettingPool(bettingPool)
	self.bettingPool = bettingPool
end

function Game:getCurrentGoingBet()
	return self.currentGoingBet
end

function Game:setCurrentGoingBet(currentGoingBet)
	self.currentGoingBet = currentGoingBet
end

function Game:getRoundsHighestBet()
	return self.roundsHighestBet
end

function Game:setRoundsHighestBet(roundsHighestBet)
	self.roundsHighestBet = roundsHighestBet
end

--------

function Game:addPlayer(player)

    player:setOrder(#self.players+1)

	table.insert(self.players, player)
end

--------

function Game:init()

    -- Create & init the deck
    self.deck = Deck:New()
    if Config.DebugPrint then print("164>Game:init()- self.deck:", self.deck) end
    self.deck:init()

    -- Create & init the board
    -- Pull the board's five cards
    local cardV = self.deck:pullCardByKey(self.deck:getRandomCardKey())
    local cardW = self.deck:pullCardByKey(self.deck:getRandomCardKey())
    local cardX = self.deck:pullCardByKey(self.deck:getRandomCardKey())
    local cardY = self.deck:pullCardByKey(self.deck:getRandomCardKey())
    local cardZ = self.deck:pullCardByKey(self.deck:getRandomCardKey())
    self.board = Board:New({
        cardV = cardV,
        cardW = cardW,
        cardX = cardX,
        cardY = cardY,
        cardZ = cardZ,
    })

    -- Set up all players' hole cards
    for k,v in pairs(self.players) do
        local cardA = self.deck:pullCardByKey(self.deck:getRandomCardKey())
        cardA:setIsRevealed(false)
        local cardB = self.deck:pullCardByKey(self.deck:getRandomCardKey())
        cardB:setIsRevealed(false)
        v:setCardA(cardA)
        v:setCardB(cardB)
    end

end

function Game:moveToNextRound()

    if Config.DebugPrint then print("Game:moveToNextRound()") end

    if not self.step or self.step == ROUNDS.PENDING then
        self:setStep(ROUNDS.INITIAL)
    elseif self.step == ROUNDS.INITIAL then
        self:setStep(ROUNDS.FLOP)
    elseif self.step == ROUNDS.FLOP then
        self:setStep(ROUNDS.TURN)
    elseif self.step == ROUNDS.TURN then
        self:setStep(ROUNDS.RIVER)
    elseif self.step == ROUNDS.RIVER then
        self:setStep(ROUNDS.SHOWDOWN)
    end

    if Config.DebugPrint then print("->>  Game:moveToNextRound() -- moved to the step:", self.step) end

    -- Reset round-based player bet amounts
    for k,player in pairs(self.players) do
        player:setLastBetAmount(0)
        player:setAmountBetInRound(0)
    end

    -- Reset the turn back to 1 (unless the player with the order of 1 has folded)
    self.currentTurn = self:findFirstNonFoldedPlayerOrder()

    self.isSubround = false

    -- Reset the current bet
    self.currentGoingBet = 0
    self.roundsHighestBet = 0

    if self:getStep() ~= ROUNDS.SHOWDOWN then
        -- Kick off the turn timer
        self:startTurnTimer(self:findPlayerOfCurrentTurn())
    end
end

function Game:advanceTurn()
    if Config.DebugPrint then print("Game:advanceTurn()", self.currentTurn, #self.players) end

    self:stopTurnTimer()

    if self:isEndOfRound() then

        -- Everyone has gone; any subrounds are done; it's time to move to the next round
        if Config.DebugPrint then print("Game:advanceTurn() - isEndOfRound; returning false") end
        return false

    else
        -- Subround case
        if self:getIsSubround() then

            if Config.DebugPrint then print("Game:advanceTurn() - isSubround") end

            -- Find the next "order" of outstanding players, excluding players who have folded
            self.currentTurn = self:findFollowingOutstandingPlayerOrder(self.currentTurn)

            if Config.DebugPrint then print("Game:advanceTurn() - SUBround - self.currentTurn", self.currentTurn) end

            -- Kick off the turn timer for the player of the now-current turn
            self:startTurnTimer(self:findPlayerOfCurrentTurn())

            return true

        else

            -- Normal, non-subround case

            -- Find the next "order", excluding players who have folded
            self.currentTurn = self:findNextNonFoldedPlayerOrder()

            if Config.DebugPrint then print("Game:advanceTurn() - self.currentTurn", self.currentTurn) end

            -- Kick off the turn timer for the player of the now-current turn
            self:startTurnTimer(self:findPlayerOfCurrentTurn())

            return true
        end
    end
end


--------

function Game:isEndOfRound()

    if Config.DebugPrint then print("Game:isEndOfRound() starting") end
    if Config.DebugPrint then print(">259 - Game:isEndOfRound() - self:getCurrentTurn():", self:getCurrentTurn()) end
    if Config.DebugPrint then print(">260 - Game:isEndOfRound() - self:findLastNonFoldedPlayerOrder():", self:findLastNonFoldedPlayerOrder()) end

    -- If we're coming back from a subround
    if self:getIsSubround() then

        -- A subround can't be over if there's still a player who hasn't bet the current going bet
        if self:haveAnyPlayersNotBetTheHighestBet() then
            return false
        else
            return true
        end

    else
        -- Not a subround (yet), so this is still a normal round

        -- Check if this is the last non-folded player (note: not just the last player)
        if self:getCurrentTurn() >= self:findLastNonFoldedPlayerOrder() then

            if Config.DebugPrint then print("Game:isEndOfRound() - this is last non-folded player") end

            -- This might be the end of the round, but we need to consider the Overridden-Check case

            -- If anybody bet at all this round (e.g. not everyoned Checked) and also not everyone has bet the current going bet
            if self:getRoundsHighestBet() > 0 and self:haveAnyPlayersNotBetTheHighestBet() then

                -- We're not done yet; we need a subround (since once someone bets, everyone has to bet that round)

                if Config.DebugPrint then print("Game:isEndOfRound() - THIS IS A SUBROUND NOW - setting subround true - currentGoingBet > 0 and playersNotBetHighestBet") end

                self:setIsSubround(true)
                return false

            else
                return true
            end

        end

        return false
    end
    
end

function Game:isOustandingPlayer(player)
    return player:getHasFolded() == false and (player:getAmountBetInRound() ~= self.roundsHighestBet)
end

function Game:haveAnyPlayersNotBetTheHighestBet()

    for k,v in pairs(self.players) do
        if self:isOustandingPlayer(v) then
            return true
        end
    end

    return false
end

function Game:findLastNonFoldedPlayerOrder()
    if Config.DebugPrint then print("Game:find*LAST*NonFoldedPlayerOrder() - self:getPlayers()", self:getPlayers()) end

    local lastOrder = #self:getPlayers()

    if Config.DebugPrint then print("Game:find*LAST*NonFoldedPlayerOrder() - lastOrder", lastOrder) end

    local lastOrderPlayer = self:findPlayerByOrder(lastOrder)
    if lastOrderPlayer then

        if self:findPlayerByOrder(lastOrder):getHasFolded() == false then
            return lastOrder
        end

    end

    return self:findPrecedingNonFoldedPlayerOrder(lastOrder)
    
end

-- NOTE: *FIRST*, not next.
function Game:findFirstNonFoldedPlayerOrder()
    if Config.DebugPrint then print("Game:find*First*NonFoldedPlayerOrder()") end

    local firstOrderPlayer = self:findPlayerByOrder(1)
    if firstOrderPlayer then
        if firstOrderPlayer:getHasFolded() == false then
            return 1
        end
    end

    return self:findFollowingNonFoldedPlayerOrder(1)
    
end

function Game:findNextNonFoldedPlayerOrder()
    if Config.DebugPrint then print("Game:findNextNonFoldedPlayerOrder()") end

    return self:findFollowingNonFoldedPlayerOrder(self.currentTurn)
    
end

function Game:findFollowingNonFoldedPlayerOrder(originalTurn)
    if Config.DebugPrint then print("Game:findFollowingNonFoldedPlayerOrder()", originalTurn) end


    local turnToCheck = originalTurn

    local hasFoundNonFoldedPlayer = false
    while hasFoundNonFoldedPlayer == false do

        -- Ideally, it should be as simple as the next numeric turn
        turnToCheck = turnToCheck + 1

        -- Check if `turnToCheck` > numPlayers (e.g. last player)
        if turnToCheck > #self:getPlayers() then
            -- Reset to 1
            turnToCheck = 1
        end


        -- Abort if `turnToCheck` == originalTurn (prevents infinite loop)
        if turnToCheck == originalTurn then
            return false
        end


        -- Find the player with this "order"
        local playerOfTurnToCheck = self:findPlayerByOrder(turnToCheck)

        -- Make sure the player has not folded yet
        if playerOfTurnToCheck and playerOfTurnToCheck:getHasFolded() == false then
            if Config.DebugPrint then print("Game:findFollowingNonFoldedPlayerOrder() - playerOfTurnToCheck", playerOfTurnToCheck) end
            hasFoundNonFoldedPlayer = true
            return playerOfTurnToCheck:getOrder()
        end
    end

    return false

end

function Game:findPrecedingNonFoldedPlayerOrder(originalTurn)
    if Config.DebugPrint then print("Game:findPrecedingNonFoldedPlayerOrder()", originalTurn) end


    local turnToCheck = originalTurn

    local hasFoundNonFoldedPlayer = false
    while hasFoundNonFoldedPlayer == false do

        -- Ideally, it should be as simple as the previous numeric turn
        turnToCheck = turnToCheck - 1

        -- Check if `turnToCheck` > numPlayers (e.g. last player)
        if turnToCheck == 1 then
            -- Reset to last order
            turnToCheck = #self:getPlayers()
        end


        -- Abort if `turnToCheck` == originalTurn (prevents infinite loop)
        if turnToCheck == originalTurn then
            return false
        end


        -- Find the player with this "order"
        local playerOfTurnToCheck = self:findPlayerByOrder(turnToCheck)

        -- Make sure the player has not folded yet
        if playerOfTurnToCheck and playerOfTurnToCheck:getHasFolded() == false then
            if Config.DebugPrint then print("Game:findPrecedingNonFoldedPlayerOrder() - playerOfTurnToCheck", playerOfTurnToCheck) end
            hasFoundNonFoldedPlayer = true
            return playerOfTurnToCheck:getOrder()
        end
    end

    return false

end

-- NOTE: *FIRST*, not next.
function Game:findFirstOutstandingPlayerOrder()
    if Config.DebugPrint then print("Game:find*First*OutstandingPlayerOrder()") end

    local playerWithOrder1 = self:findPlayerByOrder(1)
    if Config.DebugPrint then print("408 - Game:find*First*OutstandingPlayerOrder() - playerWithOrder1:", playerWithOrder1) end
    if playerWithOrder1 then
        if self:isOustandingPlayer(playerWithOrder1) then
            return 1
        end
    end

    return self:findFollowingOutstandingPlayerOrder(1)
    
end

function Game:findFollowingOutstandingPlayerOrder(originalTurn)
    if Config.DebugPrint then print("Game:findFollowingOutstandingPlayerOrder() - originalTurn:", originalTurn) end


    local turnToCheck = originalTurn

    local hasFoundOutstandingPlayer = false
    while hasFoundOutstandingPlayer == false do

        -- Ideally, it should be as simple as the next numeric turn
        turnToCheck = turnToCheck + 1

        if Config.DebugPrint then print(">429 - Game:findFollowingOutstandingPlayerOrder() - turnToCheck:", turnToCheck) end

        -- Check if `turnToCheck` > numPlayers (e.g. last player)
        if turnToCheck > #self:getPlayers() then
            -- Reset to 1
            turnToCheck = 1
            if Config.DebugPrint then print(">435 - Game:findFollowingOutstandingPlayerOrder() - turnToCheck reset to 1") end

        end


        -- Abort if `turnToCheck` == originalTurn (prevents infinite loop)
        if turnToCheck == originalTurn then
            if Config.DebugPrint then print(">435 - Game:findFollowingOutstandingPlayerOrder() - aborting") end

            return false
        end


        -- Find the player with this "order"
        local playerOfTurnToCheck = self:findPlayerByOrder(turnToCheck)
        if Config.DebugPrint then print(">450 - Game:findFollowingOutstandingPlayerOrder() - playerOfTurnToCheck", playerOfTurnToCheck) end

        if not playerOfTurnToCheck then
            return false
        end

        -- Make sure the player has not folded yet AND that they've Checked this round
        if self:isOustandingPlayer(playerOfTurnToCheck) then
            if Config.DebugPrint then print(">455 - Game:findFollowingOutstandingPlayerOrder() - playerOfTurnToCheck", playerOfTurnToCheck) end
            hasFoundOutstandingPlayer = true
            return playerOfTurnToCheck:getOrder()
        end
    end

end

--------

function Game:startTurnTimer(currentTurnPlayer)
    if Config.DebugPrint then print("Game:startTurnTimer", currentTurnPlayer) end
    self.turnTimerWarned = false
	self.turnTimer = os.time() + Config.TurnTimeoutInSeconds
    -- if Config.DebugPrint then print("Game:startTurnTimer - self.turnTimer ", self.turnTimer ) end

    Citizen.CreateThread(function()
        while self.turnTimer do
            Wait(2000)

            -- Check if we should warn
            if self.turnTimer and not self.turnTimerWarned and (self.turnTimer - os.time()) < Config.TurnTimeoutWarningInSeconds then
                self.turnTimerWarned = true
                TriggerClientEvent("rainbow_poker:Client:WarnTurnTimer", currentTurnPlayer:getNetId())
            end

            -- Check if time's up!
            -- print('tick', os.time())
            if self.turnTimer and os.time() > self.turnTimer then

                -- Force the player to fold for this game
                fold(currentTurnPlayer:getNetId())

                if Config.DebugPrint then print("Game:startTurnTimer - forcing fold", currentTurnPlayer:getNetId()) end

                -- Reset and stop timer
                self:stopTurnTimer()
                break
            end
        end
    end)
end

function Game:stopTurnTimer()
    self.turnTimer = nil
    self.turnTimerWarned = false
end

--------

function Game:onPlayerDidActionCheck(_source)

	if Config.DebugPrint then print("Game:onPlayerDidActionCheck", _source) end

    -- Find the player
    local player = self:findPlayerByNetId(_source)

    local action = ACTIONS.CHECK

    if self.step == ROUNDS.INITIAL then
        player:setActionInitial(action)
    elseif self.step == ROUNDS.FLOP then
        player:setActionFlop(action)
    elseif self.step == ROUNDS.TURN then
        player:setActionTurn(action)
    elseif self.step == ROUNDS.RIVER then
        player:setActionRiver(action)
    end

end

function Game:onPlayerDidActionRaise(_source, amountToRaise)

	if Config.DebugPrint then print("Game:onPlayerDidActionRaise - _source, amountToRaise:", _source, amountToRaise) end

    -- Find the player
    local player = self:findPlayerByNetId(_source)

    if Config.DebugPrint then print("Game:onPlayerDidActionRaise - player", player) end


    local action = ACTIONS.RAISE

    if self.step == ROUNDS.INITIAL then
        player:setActionInitial(action)
    elseif self.step == ROUNDS.FLOP then
        player:setActionFlop(action)
    elseif self.step == ROUNDS.TURN then
        player:setActionTurn(action)
    elseif self.step == ROUNDS.RIVER then
        player:setActionRiver(action)
    end

    local betAmountInThisTurn = self.currentGoingBet + amountToRaise

    if Config.DebugPrint then print(">590 Game:onPlayerDidActionRaise - player:getAmountBetInRound():", player:getAmountBetInRound()) end
    if Config.DebugPrint then print(">591 Game:onPlayerDidActionRaise - self.currentGoingBet:", self.currentGoingBet) end

    player:setLastBetAmount(betAmountInThisTurn)
    player:setAmountBetInRound(player:getAmountBetInRound() + betAmountInThisTurn)
    player:setTotalAmountBetInGame(player:getTotalAmountBetInGame() + betAmountInThisTurn)

    self.bettingPool = self.bettingPool + betAmountInThisTurn


    -- Raises affect the state of the current round
    self.currentGoingBet = betAmountInThisTurn
    self.roundsHighestBet = player:getAmountBetInRound()
    

    if Config.DebugPrint then print(">597 Game:onPlayerDidActionRaise - player:getAmountBetInRound():", player:getAmountBetInRound()) end
    if Config.DebugPrint then print(">598 Game:onPlayerDidActionRaise - self.currentGoingBet:", self.currentGoingBet) end
end

function Game:onPlayerDidActionCall(_source)

	if Config.DebugPrint then print("Game:onPlayerDidActionCall", _source) end

    -- Find the player
    local player = self:findPlayerByNetId(_source)

    if Config.DebugPrint then print("Game:onPlayerDidActionCall - player", player) end


    local action = ACTIONS.CALL

    if self.step == ROUNDS.INITIAL then
        player:setActionInitial(action)
    elseif self.step == ROUNDS.FLOP then
        player:setActionFlop(action)
    elseif self.step == ROUNDS.TURN then
        player:setActionTurn(action)
    elseif self.step == ROUNDS.RIVER then
        player:setActionRiver(action)
    end

    if Config.DebugPrint then print("Game:onPlayerDidActionCall - player:getAmountBetInRound():", player:getAmountBetInRound()) end
    if Config.DebugPrint then print("Game:onPlayerDidActionCall - self.currentGoingBet:", self.currentGoingBet) end

    local amount = self:getRoundsHighestBet() - player:getAmountBetInRound()

    player:setLastBetAmount(amount)
    player:setAmountBetInRound(player:getAmountBetInRound() + amount)
    player:setTotalAmountBetInGame(player:getTotalAmountBetInGame() + amount)
    self.bettingPool = self.bettingPool + amount
end

function Game:onPlayerDidActionFold(_source)

	if Config.DebugPrint then print("Game:onPlayerDidActionFold", _source) end

    -- Find the player
    local player = self:findPlayerByNetId(_source)

    if Config.DebugPrint then print("Game:onPlayerDidActionFold - player", player) end


    local action = ACTIONS.FOLD

    if self.step == ROUNDS.INITIAL then
        player:setActionInitial(action)
    elseif self.step == ROUNDS.FLOP then
        player:setActionFlop(action)
    elseif self.step == ROUNDS.TURN then
        player:setActionTurn(action)
    elseif self.step == ROUNDS.RIVER then
        player:setActionRiver(action)
    end

    player:setHasFolded(true)

    if Config.DebugPrint then print("Game:onPlayerDidActionFold - player", player) end

end

--------

function Game:findPlayerByOrder(targetOrder)
    for k,v in pairs(self.players) do
        if v:getOrder() == targetOrder then
            return v
        end
    end
    return false
end

function Game:findPlayerOfCurrentTurn()
    return self:findPlayerByOrder(self.currentTurn)
end

function Game:findPlayerByNetId(netId)
    for k,v in pairs(self.players) do
        if v:getNetId() == netId then
            return v
        end
    end
    return false
end


---@return Game
function Game:New(obj)
    local instance = setmetatable({}, {
        __index = self
    })
    instance.locationIndex = obj.locationIndex
    instance.players = obj.players
    instance.ante = obj.ante
    instance.bettingPool = obj.bettingPool

    instance.deck = nil
    instance.step = ROUNDS.PENDING
    instance.isSubround = false
    instance.currentTurn = 1
    instance.currentGoingBet = 0
    instance.roundsHighestBet = 0
    instance.turnTimer = nil
    instance.turnTimerWarned = false
    return instance
end