VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)

local locations = {}

local pendingGames = {}
local activeGames = {}




-- Initial set up of locations
Citizen.CreateThread(function()
    for k,v in pairs(Config.Locations) do
        local location = Location:New({
            id = k,
            state = LOCATION_STATES.EMPTY,
            tableCoords = v.Table.Coords,
            maxPlayers = v.MaxPlayers,
        })
        table.insert(locations, location)
    end
end)








--------

RegisterServerEvent("rainbow_poker:Server:RequestCharacterName", function()
	local _source = source

    local Character = VORPcore.getUser(_source).getUsedCharacter
    TriggerClientEvent("rainbow_poker:Client:ReturnRequestCharacterName", _source, Character.firstname)
end)



RegisterServerEvent("rainbow_poker:Server:RequestUpdatePokerTables", function()
	local _source = source

    TriggerClientEvent("rainbow_poker:Client:UpdatePokerTables", _source, locations)

end)



RegisterServerEvent("rainbow_poker:Server:StartNewPendingGame", function(player1sChosenName, anteAmount, tableLocationIndex)
	local _source = source

    if Config.DebugPrint then print("StartNewPendingGame", player1sChosenName, anteAmount, tableLocationIndex) end

    -- Make sure this location is still in state EMPTY (i.e. no one else has started a game at the same time)
    if locations[tableLocationIndex]:getState() ~= LOCATION_STATES.EMPTY then
        return
    end

    -- Make sure this player isn't already in a pending poker game
    if findPendingGameByPlayerNetId(_source) ~= false then
        VORPcore.NotifyRightTip(_source, "You are still in a pending poker game.", 20 * 1000)
        return
    end

    -- Make sure this player isn't already in an active poker game
    if findActiveGameByPlayerNetId(_source) ~= false then
        VORPcore.NotifyRightTip(_source, "You are still in an active poker game.", 20 * 1000)
        return
    end

    player1sChosenName = truncateString(player1sChosenName, 10)

    math.randomseed(os.time())

    local player1NetId = _source

    -- Create the PendingPlayer object
    local pendingPlayer1 = Player:New({
        netId = player1NetId,
        name = player1sChosenName,
        order = 1,
    })
    
    -- Create the PendingGame
    local newPendingGame = PendingGame:New({
        initiatorNetId = _source,
        players = {
            pendingPlayer1,
        },
        ante = anteAmount,
    })

    locations[tableLocationIndex]:setPendingGame(newPendingGame)
    locations[tableLocationIndex]:setState(LOCATION_STATES.PENDING_GAME)

    if Config.DebugPrint then print("StartNewGame - newPendingGame", newPendingGame) end

    -- Make the player sit at the chair of their order
    TriggerClientEvent("rainbow_poker:Client:ReturnStartNewPendingGame", _source, tableLocationIndex, pendingPlayer1)

    TriggerClientEvent("rainbow_poker:Client:UpdatePokerTables", -1, locations)

    logPendingGameToDiscord(tableLocationIndex, newPendingGame, pendingPlayer1)
end)

RegisterServerEvent("rainbow_poker:Server:JoinGame", function(playersChosenName, tableLocationIndex)
	local _source = source

    if Config.DebugPrint then print("JoinGame", playersChosenName, tableLocationIndex) end

    local pendingGame = locations[tableLocationIndex]:getPendingGame()


    -- Check if the game is already maxed out
    if #pendingGame:getPlayers() >= locations[tableLocationIndex]:getMaxPlayers() then
        VORPcore.NotifyRightTip(_source, "This poker game is full.", 20 * 1000)
        return
    end

    -- Make sure this player isn't already in a pending poker game
    if findPendingGameByPlayerNetId(_source) ~= false then
        VORPcore.NotifyRightTip(_source, "You are still in a pending poker game.", 20 * 1000)
        return
    end

    -- Make sure this player isn't already in an active poker game
    if findActiveGameByPlayerNetId(_source) ~= false then
        VORPcore.NotifyRightTip(_source, "You are still in an active poker game.", 20 * 1000)
        return
    end


    playersChosenName = truncateString(playersChosenName, 12)

    local playerNetId = _source

    -- Create the PendingPlayer object
    local pendingPlayer = Player:New({
        netId = playerNetId,
        name = playersChosenName,
        order = #pendingGame:getPlayers()+1,
    })

    -- Add player & init their hole cards
    pendingGame:addPlayer(pendingPlayer)

    -- Make the player sit at the chair of their order
    TriggerClientEvent("rainbow_poker:Client:ReturnJoinGame", _source, tableLocationIndex, pendingPlayer)

    TriggerClientEvent("rainbow_poker:Client:UpdatePokerTables", -1, locations)

    logJoinToDiscord(tableLocationIndex, pendingGame, pendingPlayer)
end)

RegisterServerEvent("rainbow_poker:Server:FinalizePendingGameAndBegin", function(tableLocationIndex)
	local _source = source

    if Config.DebugPrint then print("FinalizePendingGameAndBegin", tableLocationIndex) end

    local pendingGame = locations[tableLocationIndex]:getPendingGame()

    -- Check there's 1+ players, and not >12
    if #pendingGame:getPlayers() < 2 then
        VORPcore.NotifyRightTip(_source, "You need at least 1 other player to join your poker game.", 6 * 1000)
        return
    elseif #pendingGame:getPlayers() > 12 then
        VORPcore.NotifyRightTip(_source, "You cannot have more than 12 players in your poker game.", 6 * 1000)
        return
    end

    -- Make sure all the pending players have enough money
    for k,v in pairs(pendingGame:getPlayers()) do
        if not hasMoney(v:getNetId(), pendingGame:getAnte()) then
            -- Cancel the game
            TriggerEvent("rainbow_poker:Server:CancelPendingGame", tableLocationIndex)
            VORPcore.NotifyRightTip(v:getNetId(), "You don't have the ante money.", 6 * 1000)
            return
        end
    end

    -- Add players to active game
    local activeGamePlayers = {}
    for k,v in pairs(pendingGame:getPlayers()) do

        -- Take the antes from pocket money
        if takeMoney(v:getNetId(), pendingGame:getAnte()) then
            
            table.insert(activeGamePlayers, Player:New({
                netId = v:getNetId(),
                name = v:getName(),
                order = v:getOrder(),
                totalAmountBetInGame = pendingGame:getAnte(),
            }))
        else
            -- Cancel the game
            TriggerEvent("rainbow_poker:Server:CancelPendingGame", tableLocationIndex)
            return
        end
    end

    local newActiveGame = Game:New({
        locationIndex = tableLocationIndex,
        players = activeGamePlayers,
        ante = pendingGame:getAnte(),
        bettingPool = pendingGame:getAnte() * #pendingGame:getPlayers(),
    })

    -- Init the game
    newActiveGame:init()
    newActiveGame:moveToNextRound()

    activeGames[tableLocationIndex] = newActiveGame

    locations[tableLocationIndex]:setPendingGame(nil)
    locations[tableLocationIndex]:setState(LOCATION_STATES.GAME_IN_PROGRESS)

    TriggerClientEvent("rainbow_poker:Client:UpdatePokerTables", -1, locations)

    -- To all of the game's players
    for k,player in pairs(newActiveGame:getPlayers()) do
        TriggerClientEvent("rainbow_poker:Client:StartGame", player:getNetId(), newActiveGame, player:getOrder())
    end

    Wait(1000)
    -- newActiveGame:startTurnTimer(newActiveGame:findPlayerByNetId(_source))

end)

RegisterServerEvent("rainbow_poker:Server:CancelPendingGame", function(tableLocationIndex)
	local _source = source

    if Config.DebugPrint then print("CancelPendingGame", tableLocationIndex) end

    for k,v in pairs(locations[tableLocationIndex]:getPendingGame():getPlayers()) do
        TriggerClientEvent("rainbow_poker:Client:CancelPendingGame", v:getNetId(), tableLocationIndex)
        VORPcore.NotifyRightTip(v:getNetId(), "The pending poker game has been canceled.", 6 * 1000)
    end

    locations[tableLocationIndex]:setPendingGame(nil)
    locations[tableLocationIndex]:setState(LOCATION_STATES.EMPTY)

    TriggerClientEvent("rainbow_poker:Client:UpdatePokerTables", -1, locations)

    logPendingGameCancelToDiscord(tableLocationIndex, _source)

end)


RegisterServerEvent("rainbow_poker:Server:PlayerActionCheck", function(tableLocationIndex)
	local _source = source

    if Config.DebugPrint then print("rainbow_poker:Server:PlayerActionCheck", _source, tableLocationIndex) end

    local game = findActiveGameByPlayerNetId(_source)

    game:stopTurnTimer()

    game:onPlayerDidActionCheck(_source)

    if not game:advanceTurn() then
        checkForWinCondition(game)
    end

    TriggerUpdate(game)
end)

RegisterServerEvent("rainbow_poker:Server:PlayerActionRaise", function(amountToRaise)
	local _source = source

    if Config.DebugPrint then print("rainbow_poker:Server:PlayerActionRaise - _source, amountToRaise:", _source, amountToRaise) end

    local game = findActiveGameByPlayerNetId(_source)

    game:stopTurnTimer()

    if not takeMoney(_source, amountToRaise) then
        -- They didn't have the money to bet; force a fold
        VORPcore.NotifyRightTip(_source, "You are forced to fold.", 20 * 1000)
        fold(_source)
        return
    end

    game:onPlayerDidActionRaise(_source, amountToRaise)

    if not game:advanceTurn() then
        checkForWinCondition(game)
    end

    TriggerUpdate(game)
end)

RegisterServerEvent("rainbow_poker:Server:PlayerActionCall", function()
	local _source = source

    if Config.DebugPrint then print("rainbow_poker:Server:PlayerActionCall", _source) end

    local game = findActiveGameByPlayerNetId(_source)

    game:stopTurnTimer()

    local player = game:findPlayerByNetId(_source)
    local amount = game:getRoundsHighestBet() - player:getAmountBetInRound()

    if not takeMoney(_source, amount) then
        -- They didn't have the money to bet; force a fold
        VORPcore.NotifyRightTip(_source, "You are forced to fold.", 20 * 1000)
        fold(_source)
        return
    end

    game:onPlayerDidActionCall(_source)

    if not game:advanceTurn() then
        checkForWinCondition(game)
    end

    TriggerUpdate(game)
end)

RegisterServerEvent("rainbow_poker:Server:PlayerActionFold", function()
	local _source = source

    if Config.DebugPrint then print("rainbow_poker:Server:PlayerActionFold", _source) end

    fold(_source)
end)

RegisterServerEvent("rainbow_poker:Server:PlayerLeave", function()
	local _source = source

    if Config.DebugPrint then print("rainbow_poker:Server:PlayerLeave", _source) end

    -- Double-check that the player has already folded
    local game = findActiveGameByPlayerNetId(_source)
    local player = game:findPlayerByNetId(_source)
    if Config.DebugPrint then print("rainbow_poker:Server:PlayerLeave - player", player) end
    if game:getStep() ~= ROUNDS.SHOWDOWN and player:getHasFolded() == false then
        print("WARNING: Player trying to leave game pre-showdown when they haven't folded yet.", _source)
        return
    end

    -- Close out of the game on the client side (it's just visual)
    TriggerClientEvent("rainbow_poker:Client:ReturnPlayerLeave", _source)

end)


function checkForWinCondition(game)
    
    if Config.DebugPrint then print("checkForWinCondition()") end

    local isWinCondition = false

    -- See if we're entering the Showdown round
    if game:getStep() == ROUNDS.RIVER then
        if Config.DebugPrint then print("checkForWinCondition() - true - due to River") end
        isWinCondition = true
        game:moveToNextRound()
    end

    -- See if everyone has folded except for 1
    local numPlayersFolded = 0
    for k,player in pairs(game:getPlayers()) do
        if player:getHasFolded() then
            numPlayersFolded = numPlayersFolded + 1
        end
    end
    if numPlayersFolded >= #game:getPlayers()-1 then
        if Config.DebugPrint then print("checkForWinCondition() - true - due to folds") end
        isWinCondition = true
    end


    if isWinCondition then

        game:stopTurnTimer()

        local winScenario = getWinScenarioFromSetOfPlayers(game:getPlayers(), game:getBoard(), game:getStep())
        if Config.DebugPrint then print("checkForWinCondition() - WIN - winScenario:", winScenario) end
        -- if Config.Debug then writeDebugWinScenario(winScenario) end

        -- Give the pot money
        if not winScenario:getIsTrueTie() then
            -- Not a tie
            giveMoney(winScenario:getWinningHand():getPlayerNetId(), game:getBettingPool())
        else
            -- Tie
            local splitAmount = game:getBettingPool() / #winScenario:getTiedHands()
            for k,tiedHand in pairs(winScenario:getTiedHands()) do
                giveMoney(tiedHand:getPlayerNetId(), splitAmount)
            end
        end

        -- Alert the win to all players of this poker game
        for k,player in pairs(game:getPlayers()) do
            TriggerClientEvent("rainbow_poker:Client:AlertWin", player:getNetId(), winScenario)
        end

        -- Send the cleanup signals after 30 seconds
        Citizen.SetTimeout(30 * 1000, function()
            endAndCleanupGame(game)
        end)

        -- Log to Discord
        logFinishedGameToDiscord(game, winScenario)

    else
        -- No win condition yet; move on to next round
        game:moveToNextRound()
    end

end

function endAndCleanupGame(game)
    local locationIndex = game:getLocationIndex()

    if Config.DebugPrint then print("endAndCleanupGame - locationIndex:", locationIndex) end

    for k,player in pairs(game:getPlayers()) do
        TriggerClientEvent("rainbow_poker:Client:CleanupFinishedGame", player:getNetId())
    end

    -- Reset the location
    locations[locationIndex]:setState(LOCATION_STATES.EMPTY)

    if Config.DebugPrint then print("endAndCleanupGame - about to remove game - activeGames:", activeGames) end
    -- table.remove(activeGames, locationIndex)
    activeGames[locationIndex] = nil
    if Config.DebugPrint then print("endAndCleanupGame - removed game - activeGames:", activeGames) end

    game = nil

    TriggerClientEvent("rainbow_poker:Client:UpdatePokerTables", -1, locations)
end

function fold(targetNetId)
    local game = findActiveGameByPlayerNetId(targetNetId)

    game:stopTurnTimer()

    game:onPlayerDidActionFold(targetNetId)

    -- Check if there's only 1 non-folded player left
    local numNotFolded = 0
    for k,player in pairs(game:getPlayers()) do
        if not player:getHasFolded() then
            numNotFolded = numNotFolded + 1
        end
    end

    if numNotFolded > 1 then

        if not game:advanceTurn() then
            checkForWinCondition(game)
        end

        TriggerUpdate(game)
    else
        -- Last person standing!
        game:setStep(ROUNDS.SHOWDOWN)
        checkForWinCondition(game)
        TriggerUpdate(game)
    end
end

function hasMoney(targetNetId, amount)
    local Character = VORPcore.getUser(targetNetId).getUsedCharacter
    local money = Character.money

    amount = tonumber(amount)

    -- Check that they have the schmoney
    if tonumber(money) < tonumber(amount) then
        return false
    end

    return true
end

function takeMoney(targetNetId, amount)
    local Character = VORPcore.getUser(targetNetId).getUsedCharacter
    local money = Character.money

    amount = tonumber(amount)

    -- Check that they have the schmoney
    if money < amount then
        VORPcore.NotifyRightTip(targetNetId, string.format("You don't have $%.2f!", amount), 20 * 1000)
        return false
    end

    Character.removeCurrency(0, amount)

    VORPcore.NotifyRightTip(targetNetId, string.format("You have bet $%.2f.", amount), 6 * 1000)

    return true
end

function giveMoney(targetNetId, amount)

    amount = tonumber(amount)

    local Character = VORPcore.getUser(targetNetId).getUsedCharacter
    Character.addCurrency(0, amount)

    VORPcore.NotifyRightTip(targetNetId, string.format("You have won $%.2f.", amount), 6 * 1000)

    return true
end

function truncateString(str, max)
    if string.len(str) > max then
        return string.sub(str, 1, max) .. "…"
    else
        return str
    end
end



--------

-- Trigger updates to all the clients of the players of this game of poker.
function TriggerUpdate(game)

    -- Loop thru all this game's players
    for k,player in pairs(game:getPlayers()) do
        TriggerClientEvent("rainbow_poker:Client:TriggerUpdate", player:getNetId(), game)
    end
end


-------- DISCORD --------

function logFinishedGameToDiscord(game, winScenario)

    local str = ""

    local locationName = locations[game:getLocationIndex()]:getId()

    str = str .. string.format("**Location:** %s\n", locationName)
    str = str .. string.format("**Board Cards:** `%s`\n", game:getBoard():getString())
    str = str .. string.format("**Ante:** %s\n", game:getAnte())
    str = str .. string.format("**Final Betting Pool:** $%s\n", game:getBettingPool())

    str = str .. "--------\n"

    for k,player in pairs(game:getPlayers()) do

        local Character = VORPcore.getUser(player:getNetId()).getUsedCharacter
        local CharIdentifier = Character.charIdentifier
        local fullName = string.format("%s %s", Character.firstname, Character.lastname)

        str = str .. "🧑 __PLAYER__:\n"
        str = str .. string.format("**Name:** %s *(CharId: %s; NetId: %d)*\n", fullName, CharIdentifier, player:getNetId())
        str = str .. string.format("**Poker Nickname:** %s\n", player:getName())
        str = str .. string.format("**Game Seat Order:** %s\n", player:getOrder())
        str = str .. string.format("**Hole Cards:** `%s%s`\n", player:getCardA():getString(), player:getCardB():getString())
        str = str .. string.format("**Total Amount Bet in Game:** $%d\n", player:getTotalAmountBetInGame())

        str = str .. "--------\n"
    end

    if winScenario then
        str = str .. "--------\n"
        str = str .. "--------\n"

        if winScenario:getIsTrueTie() then
            -- TIE
            local tiedHands = winScenario:getTiedHands()
            for k,tiedHand in pairs(tiedHands) do
                str = str .. string.format("**🎉🧑‍🤝‍🧑 Tied Hand %d:**\n", k)
                str = str .. string.format("Cards: `%s`\n", tiedHand:getString())
                str = str .. string.format("Hand Type: %s\n", tiedHand:getWinningHandType())
                str = str .. string.format("Player NetId: %s\n", tiedHand:getPlayerNetId())
            end
        else
            -- NON-TIE
            local winningHand = winScenario:getWinningHand()
            str = str .. "**🎉 Sole Winning Hand:**\n"
            str = str .. string.format("Cards: `%s`\n", winningHand:getString())
            str = str .. string.format("Hand Type: %s\n", winningHand:getWinningHandType())
            str = str .. string.format("Player NetId: %s\n", winningHand:getPlayerNetId())
        end

        str = str .. "--------\n"
    end


    VORPcore.AddWebhook("♦️ Poker - Finished", Config.Webhook, str)

end

function logPendingGameToDiscord(tableLocationIndex, newPendingGame, pendingPlayer1)

    local Character = VORPcore.getUser(pendingPlayer1:getNetId()).getUsedCharacter
    local CharIdentifier = Character.charIdentifier
    local fullName = string.format("%s %s", Character.firstname, Character.lastname)

    local str = ""

    local locationName = locations[tableLocationIndex]:getId()

    str = str .. string.format("**Location:** %s\n", locationName)
    str = str .. string.format("**Ante:** $%s\n", newPendingGame:getAnte())
    str = str .. string.format("**Initiator:** %s *(CharId: %s; NetId: %d)*\n", fullName, CharIdentifier, pendingPlayer1:getNetId())

    VORPcore.AddWebhook("♥️ Poker - New Pending Game Started", Config.Webhook, str)

end

function logJoinToDiscord(tableLocationIndex, pendingGame, pendingPlayer)

    local Character = VORPcore.getUser(pendingPlayer:getNetId()).getUsedCharacter
    local CharIdentifier = Character.charIdentifier
    local fullName = string.format("%s %s", Character.firstname, Character.lastname)

    local str = ""

    local locationName = locations[tableLocationIndex]:getId()

    str = str .. string.format("**Location:** %s\n", locationName)
    str = str .. string.format("**Player:** %s *(CharId: %s; NetId: %d)*\n", fullName, CharIdentifier, pendingPlayer:getNetId())

    VORPcore.AddWebhook("♣️ Poker - Player Joined Pending Game", Config.Webhook, str)

end

function logPendingGameCancelToDiscord(tableLocationIndex, playerNetId)

    local Character = VORPcore.getUser(playerNetId).getUsedCharacter
    local CharIdentifier = Character.charIdentifier
    local fullName = string.format("%s %s", Character.firstname, Character.lastname)

    local str = ""

    local locationName = locations[tableLocationIndex]:getId()

    str = str .. string.format("**Location:** %s\n", locationName)
    str = str .. string.format("**Canceling Player:** %s *(CharId: %s; NetId: %d)*\n", fullName, CharIdentifier, playerNetId)

    VORPcore.AddWebhook("❌ Poker - Pending Game Canceled", Config.Webhook, str)

end



--------

function findActiveGameByPlayerNetId(playerNetId)
    for k,v in pairs(activeGames) do
        for k2,v2 in pairs(v:getPlayers()) do
            if v2:getNetId() == playerNetId then
                return v
            end
        end
    end
    return false
end

function findPendingGameByPlayerNetId(playerNetId)
    for k,v in pairs(pendingGames) do
        for k2,v2 in pairs(v:getPlayers()) do
            if v2:getNetId() == playerNetId then
                return v
            end
        end
    end
    return false
end

--------

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() == resourceName then

        locations = {}
        pendingGames = {}
        activeGames = {}

    end

end)