VORPcore = {}
TriggerEvent("getCore", function(core)
    VORPcore = core
end)
VORPutils = {}
TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)
RainbowCore = exports["rainbow-core"]:initiate()

local PromptGroupInGame
local PromptGroupInGameLeave
local PromptGroupTable
local PromptGroupFinalize
local PromptCall
local PromptRaise
local PromptCheck
local PromptFold
local PromptCycleAmount
local PromptStart
local PromptJoin
local PromptBegin
local PromptCancel
local PromptLeave

local characterName = false

isInGame = false
game = nil

local locations = {}
local isNearTable = false
local nearTableLocationIndex

local turnRaiseAmount = 1
local turnBaseRaiseAmount = 1
local isPlayerOccupied = false
local hasLeft = false


if Config.DebugCommands then
    -- Run through winning cases without actually playing the game yourself.
    -- Example:
    -- /pokerv KcKdQs8d2h AhJc As8h
    -- (Showdown only)
    RegisterCommand("pokerv", function(source, args, rawCommand)

        TriggerServerEvent("rainbow_poker:Server:Command:pokerv", args)
        
    end, false)

    -- Test creating of decks
    RegisterCommand("debug:pokerDeck", function(source, args, rawCommand)

        TriggerServerEvent("rainbow_poker:Server:Command:Debug:PokerDeck", args)
        
    end, false)
end


-------- THREADS

-- Performance
Citizen.CreateThread(function()

	Citizen.Wait(1000)

	while true do

		local playerPedId = PlayerPedId()
		if playerPedId then
			isPlayerOccupied = not RainbowCore.CanPedStartInteraction(playerPedId)
		end

		Wait(200)
	end
end)

-- Check if near table
CreateThread(function()

    TriggerServerEvent("rainbow_poker:Server:RequestUpdatePokerTables")

    while true do
        local sleep = 1000

        if not isInGame and not isPlayerOccupied then
            local playerPedId = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPedId)

            local isCurrentlyNearTable = false
            for k,location in pairs(locations) do
                if #(playerCoords - location.tableCoords) < Config.TableDistance then
                    sleep = 250
                    isCurrentlyNearTable = true
                    nearTableLocationIndex = k
                end
            end
            isNearTable = isCurrentlyNearTable
        end

        Wait(sleep)
    end

end)

-- Join game prompts
CreateThread(function()

    PromptGroupTable = VORPutils.Prompts:SetupPromptGroup()
    PromptStart = PromptGroupTable:RegisterPrompt("Start Game", GetHashKey(Config.Keys.StartGame), 1, 1, true, "hold", {timedeventhash = "MEDIUM_TIMED_EVENT"})
    PromptJoin = PromptGroupTable:RegisterPrompt("Join Game", GetHashKey(Config.Keys.JoinGame), 1, 1, true, "hold", {timedeventhash = "MEDIUM_TIMED_EVENT"})

    while true do

        local sleep = 1000

        PromptJoin:TogglePrompt(false)
        PromptStart:TogglePrompt(false)

        if not isInGame and isNearTable and nearTableLocationIndex and not isPlayerOccupied then

            if characterName == false then
                characterName = ""
                TriggerServerEvent("rainbow_poker:Server:RequestCharacterName")
            end

            local location = locations[nearTableLocationIndex]

            if location.state ~= LOCATION_STATES.GAME_IN_PROGRESS then
                
                sleep = 1

                -- Join
                if location.state == LOCATION_STATES.PENDING_GAME and location.pendingGame.initiatorNetId ~= GetPlayerServerId(PlayerId()) then
                    local hasPlayerAlreadyJoined = false
                    for k,v in pairs(location.pendingGame.players) do
                        if v.netId == GetPlayerServerId(PlayerId()) then
                            hasPlayerAlreadyJoined = true
                        end
                    end

                    if not hasPlayerAlreadyJoined then

                        PromptJoin:TogglePrompt(true)

                        if location.pendingGame and location.pendingGame.ante then
                            PromptSetText(PromptJoin.Prompt, CreateVarString(10, "LITERAL_STRING", "Join Game  |  Ante Bet: ~o~$"..location.pendingGame.ante.." ", "Title"))
                        end
                    end

                -- Start
                elseif location.state == LOCATION_STATES.EMPTY then
                    PromptStart:TogglePrompt(true)
                end

                PromptGroupTable:ShowGroup("Poker Table")

                -- START
                if PromptStart:HasCompleted() then
                
                    local playersChosenName
                    if Config.DebugOptions.SkipStartGameOptions then
                        playersChosenName = "foo"
                    else
                        local playersChosenNameInput = {
                            type = "enableinput", -- don't touch
                            inputType = "input", -- input type
                            button = "Confirm", -- button name
                            placeholder = "", -- placeholder name
                            style = "block", -- don't touch
                            attributes = {
                                inputHeader = "YOUR NAME", -- header
                                type = "text", -- inputype text, number,date,textarea ETC
                                pattern = "[A-Za-z]+", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
                                title = "Letters only (no spaces or quotes)", -- if input doesnt match show this message
                                style = "border-radius: 10px; background-color: ; border:none;", -- style 
                                value = characterName,
                            }
                        }
                        playersChosenName = exports.vorp_inputs:advancedInput(playersChosenNameInput)
                    end

                    if not playersChosenName or playersChosenName=="" then
                        VORPcore.NotifyRightTip("You must enter a name.", 6 * 1000)
                    elseif string.len(playersChosenName) < 3 then
                        VORPcore.NotifyRightTip("Your name must be at least 3 letters long.", 6 * 1000)
                    else
                        Wait(100)

                        local anteAmount
                        if Config.DebugOptions.SkipStartGameOptions then
                            anteAmount = 5
                        else
                            local anteAmountInput = {
                                type = "enableinput", -- don't touch
                                inputType = "input", -- input type
                                button = "Confirm", -- button name
                                placeholder = "5", -- placeholder name
                                style = "block", -- don't touch
                                attributes = {
                                    inputHeader = "ANTE (INITIAL BET) AMOUNT", -- header
                                    type = "text", -- inputype text, number,date,textarea ETC
                                    pattern = "[0-9]+", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
                                    title = "Numbers only", -- if input doesnt match show this message
                                    style = "border-radius: 10px; background-color: ; border:none;"-- style 
                                }
                            }
                            anteAmount = exports.vorp_inputs:advancedInput(anteAmountInput)
                        end

                        if not anteAmount or anteAmount=="" then
                            VORPcore.NotifyRightTip("You must enter an ante amount.", 6 * 1000)
                        elseif tonumber(anteAmount) < 1 then
                            VORPcore.NotifyRightTip("The ante amount must be at least $1.", 6 * 1000)
                        else
                            TriggerServerEvent("rainbow_poker:Server:StartNewPendingGame", playersChosenName, anteAmount, nearTableLocationIndex)
                        end
                    end

                    Wait(3 * 1000)

                end

                -- JOIN
                if PromptJoin:HasCompleted() then
                    local playersChosenNameInput = {
                        type = "enableinput", -- don't touch
                        inputType = "input", -- input type
                        button = "Confirm", -- button name
                        placeholder = "", -- placeholder name
                        style = "block", -- don't touch
                        attributes = {
                            inputHeader = "YOUR NAME", -- header
                            type = "text", -- inputype text, number,date,textarea ETC
                            pattern = "[A-Za-z]+", --  only numbers "[0-9]" | for letters only "[A-Za-z]+" 
                            title = "Letters only", -- if input doesnt match show this message
                            style = "border-radius: 10px; background-color: ; border:none;",-- style 
                            value = characterName,
                        }
                    }
                    local playersChosenName = exports.vorp_inputs:advancedInput(playersChosenNameInput)

                    TriggerServerEvent("rainbow_poker:Server:JoinGame", playersChosenName, nearTableLocationIndex)

                    Wait(3 * 1000)
                end
            end
        end

        Wait(sleep)
    end

end)

-- Begin game prompt
CreateThread(function()

    PromptGroupFinalize = VORPutils.Prompts:SetupPromptGroup()
    PromptBegin = PromptGroupFinalize:RegisterPrompt("Begin Game", GetHashKey(Config.Keys.BeginGame), 1, 1, true, "hold", {timedeventhash = "MEDIUM_TIMED_EVENT"})
    PromptCancel = PromptGroupFinalize:RegisterPrompt("Cancel Game", GetHashKey(Config.Keys.CancelGame), 1, 1, true, "hold", {timedeventhash = "MEDIUM_TIMED_EVENT"})

    while true do

        local sleep = 1000

        if not isInGame and isNearTable and nearTableLocationIndex and locations[nearTableLocationIndex] and not isPlayerOccupied then
            sleep = 1

            local location = locations[nearTableLocationIndex]

            if location.state == LOCATION_STATES.PENDING_GAME and location.pendingGame.initiatorNetId == GetPlayerServerId(PlayerId()) then

                PromptSetText(PromptBegin.Prompt, CreateVarString(10, "LITERAL_STRING", "Begin Game  |  Players: ~o~" .. #location.pendingGame.players .. " ", "Title"))

                PromptSetPriority(PromptBegin.Prompt, 3)

                PromptGroupFinalize:ShowGroup("Poker Table")

                -- print('showing')

                -- BEGIN (FINALIZED)
                if PromptBegin:HasCompleted() then
                    TriggerServerEvent("rainbow_poker:Server:FinalizePendingGameAndBegin", nearTableLocationIndex)
                end

                -- CANCEL
                if PromptCancel:HasCompleted() then
                    TriggerServerEvent("rainbow_poker:Server:CancelPendingGame", nearTableLocationIndex)
                end

            end
        end

        Wait(sleep)

    end

end)


-- In-game prompts
CreateThread(function()

    PromptGroupInGame = VORPutils.Prompts:SetupPromptGroup()
    PromptCall = PromptGroupInGame:RegisterPrompt("Call (Match)", GetHashKey(Config.Keys.ActionCall), 1, 1, true, "click", {})
    PromptRaise = PromptGroupInGame:RegisterPrompt("Raise $1", GetHashKey(Config.Keys.ActionRaise), 1, 1, true, "click", {})
    PromptCheck = PromptGroupInGame:RegisterPrompt("Check", GetHashKey(Config.Keys.ActionCheck), 1, 1, true, "click", {})
    PromptFold = PromptGroupInGame:RegisterPrompt("Fold", GetHashKey(Config.Keys.ActionFold), 1, 1, true, "hold", {timedeventhash = "MEDIUM_TIMED_EVENT"})
    PromptCycleAmount = PromptGroupInGame:RegisterPrompt("Change Amount", GetHashKey(Config.Keys.SubactionCycleAmount), 1, 1, true, "click", {})
    
    PromptGroupInGameLeave = VORPutils.Prompts:SetupPromptGroup()
    PromptLeave = PromptGroupInGameLeave:RegisterPrompt("Leave", GetHashKey(Config.Keys.LeaveGame), 1, 1, true, "hold", {timedeventhash = "MEDIUM_TIMED_EVENT"})

    while true do

        local sleep = 1000

        if isInGame and game and game.step ~= ROUNDS.PENDING and game.step ~= ROUNDS.SHOWDOWN then
            sleep = 0


            -- Block inputs
            DisableAllControlActions(0)
            EnableControlAction(0, GetHashKey(Config.Keys.ActionCall))
            EnableControlAction(0, GetHashKey(Config.Keys.ActionRaise))
            EnableControlAction(0, GetHashKey(Config.Keys.ActionCheck))
            EnableControlAction(0, GetHashKey(Config.Keys.ActionFold))
            EnableControlAction(0, GetHashKey(Config.Keys.SubactionCycleAmount))
            EnableControlAction(0, GetHashKey(Config.Keys.LeaveGame))
            EnableControlAction(0, 0x4BC9DABB, true) -- Enable push-to-talk
			EnableControlAction(0, 0xF3830D8E, true) -- Enable J for jugular
            -- Re-enable mouse
            EnableControlAction(0, `INPUT_LOOK_UD`, true) -- INPUT_LOOK_UD
            EnableControlAction(0, `INPUT_LOOK_LR`, true) -- INPUT_LOOK_LR
            -- For Admin Menu:
            EnableControlAction(0, `INPUT_CREATOR_RT`, true) -- PAGE DOWN


            -- Check if it's their turn
            local thisPlayer = findThisPlayerFromGameTable(game)

            -- print('thisPlayer', thisPlayer)
            -- print('game', game)
            -- print('game.currentTurn == thisPlayer.order', game["currentTurn"], thisPlayer["order"])

            if game["currentTurn"] == thisPlayer["order"] then


                if not thisPlayer.hasFolded then

                    PromptSetText(PromptRaise.Prompt, CreateVarString(10, "LITERAL_STRING", string.format("Raise by $%d | (~o~$%d~s~)", turnRaiseAmount, game.currentGoingBet + turnRaiseAmount), "Title"))
                    PromptSetText(PromptCall.Prompt, CreateVarString(10, "LITERAL_STRING", string.format("Call | (~o~$%d~s~)", (game.roundsHighestBet - thisPlayer.amountBetInRound)), "Title"))

                    -- Conditionally show Call or Check depending on this round's betting circumstances
                    if game.roundsHighestBet and game.roundsHighestBet > 0 then
                        PromptCheck:TogglePrompt(false)
                        PromptSetEnabled(PromptCheck.Prompt, false)
                        PromptCall:TogglePrompt(true)
                        PromptSetEnabled(PromptCall.Prompt, true)
                    else
                        PromptCheck:TogglePrompt(true)
                        PromptSetEnabled(PromptCheck.Prompt, true)
                        PromptCall:TogglePrompt(false)
                        PromptSetEnabled(PromptCall.Prompt, false)
                    end


                    PromptGroupInGame:ShowGroup("Poker Game")


                    if PromptCall:HasCompleted() then
                        if Config.DebugPrint then print("PromptCall") end

                        TriggerServerEvent("rainbow_poker:Server:PlayerActionCall")
                        TriggerEvent("rainbow_core:PlayAudioFile", Config.Audio.ChipDrop, Config.AudioVolume)

                        PlayAnimation("Bet")
                    end

                    if PromptRaise:HasCompleted() then
                        if Config.DebugPrint then print("PromptRaise") end

                        TriggerServerEvent("rainbow_poker:Server:PlayerActionRaise", turnRaiseAmount)
                        TriggerEvent("rainbow_core:PlayAudioFile", Config.Audio.ChipDrop, Config.AudioVolume)

                        PlayAnimation("Bet")
                    end

                    if PromptCheck:HasCompleted() then
                        if Config.DebugPrint then print("PromptCheck") end

                        TriggerServerEvent("rainbow_poker:Server:PlayerActionCheck")

                        PlayAnimation("Check")
                    end

                    if PromptFold:HasCompleted() then
                        if Config.DebugPrint then print("PromptFold") end

                        TriggerServerEvent("rainbow_poker:Server:PlayerActionFold")

                        PlayAnimation("Fold")
                        PlayAnimation("NoCards")
                    end

                    if PromptCycleAmount:HasCompleted() then
                        if Config.DebugPrint then print("PromptCycleAmount") end

                        if turnRaiseAmount == turnBaseRaiseAmount then
                            turnRaiseAmount = turnBaseRaiseAmount * 2
                        elseif turnRaiseAmount == turnBaseRaiseAmount * 2 then
                            turnRaiseAmount = turnBaseRaiseAmount * 4
                        elseif turnRaiseAmount == turnBaseRaiseAmount * 4 then
                            turnRaiseAmount = turnBaseRaiseAmount * 8
                        elseif turnRaiseAmount == turnBaseRaiseAmount * 8 then
                            turnRaiseAmount = turnBaseRaiseAmount
                        end

                        TriggerEvent("rainbow_core:PlayAudioFile", Config.Audio.ChipTap, Config.AudioVolume)
                    end
                
                end
            
            else
                -- It's not their turn

                if thisPlayer.hasFolded then

                    -- Player has folded

                    -- Enable the "Leave" prompt
                    PromptSetEnabled(PromptLeave.Prompt, true)
                    PromptLeave:TogglePrompt(true)

                    PromptGroupInGameLeave:ShowGroup("Poker Game")

                    if PromptLeave:HasCompleted() then
                        if Config.DebugPrint then print("PromptLeave") end

                        TriggerServerEvent("rainbow_poker:Server:PlayerLeave")

                        Wait(1000)
                    end
                end

            end

        elseif isInGame and game and game.step == ROUNDS.SHOWDOWN then

            sleep = 0

            -- Enable the "Leave" prompt
            PromptSetEnabled(PromptLeave.Prompt, true)
            PromptLeave:TogglePrompt(true)

            PromptGroupInGameLeave:ShowGroup("Poker Game")

            if PromptLeave:HasCompleted() then
                if Config.DebugPrint then print("PromptLeave") end

                TriggerServerEvent("rainbow_poker:Server:PlayerLeave")

                Wait(1000)
            end

        end

        Wait(sleep)
        
    end
end)


-- Check for deaths (or other "occupying" things)
CreateThread(function()

    while true do

        local sleep = 1000

        if isInGame and game and isPlayerOccupied then
            
            if Config.DebugPrint then print("became occupied mid-game") end

            -- Fold first
            TriggerServerEvent("rainbow_poker:Server:PlayerActionFold")
            turnRaiseAmount = 1

            Wait(200)

            -- Now leave
            TriggerServerEvent("rainbow_poker:Server:PlayerLeave")

            sleep = 10 * 1000

        end

        Wait(sleep)
    end

end)


-------- EVENTS


RegisterNetEvent("rainbow_poker:Client:ReturnRequestCharacterName")
AddEventHandler("rainbow_poker:Client:ReturnRequestCharacterName", function(_name)

	if Config.DebugPrint then print("rainbow_poker:Client:ReturnRequestCharacterName", _name) end

    characterName = _name
end)

RegisterNetEvent("rainbow_poker:Client:ReturnJoinGame")
AddEventHandler("rainbow_poker:Client:ReturnJoinGame", function(locationIndex, player)
    
    if Config.DebugPrint then print("rainbow_poker:Client:ReturnJoinGame", locationIndex, player) end

    local locationId = locations[locationIndex].id

    startChairScenario(locationId, player.order)
end)

RegisterNetEvent("rainbow_poker:Client:ReturnStartNewPendingGame")
AddEventHandler("rainbow_poker:Client:ReturnStartNewPendingGame", function(locationIndex, player)
    
    if Config.DebugPrint then print("rainbow_poker:Client:ReturnStartNewPendingGame", locationIndex, player) end

    local locationId = locations[locationIndex].id

    startChairScenario(locationId, player.order)
end)

RegisterNetEvent("rainbow_poker:Client:CancelPendingGame")
AddEventHandler("rainbow_poker:Client:CancelPendingGame", function(locationIndex)

	if Config.DebugPrint then print("rainbow_poker:Client:CancelPendingGame", locationIndex) end
	
    clearPedTaskAndUnfreeze(true)
   
end)

RegisterNetEvent("rainbow_poker:Client:StartGame")
AddEventHandler("rainbow_poker:Client:StartGame", function(_game, playerSeatOrder)

	if Config.DebugPrint then print("rainbow_poker:Client:StartGame", _game, playerSeatOrder) end
	
    UI:StartGame(_game)

    game = _game
    isInGame = true

    local locationId = locations[nearTableLocationIndex].id
    startChairScenario(locationId, playerSeatOrder)

    TriggerEvent("rainbow_core:PlayAudioFile", Config.Audio.CardsDeal, Config.AudioVolume)
   
    PlayAnimation("HoldCards")
end)

RegisterNetEvent("rainbow_poker:Client:UpdatePokerTables")
AddEventHandler("rainbow_poker:Client:UpdatePokerTables", function(_locations)

	if Config.DebugPrint then print("rainbow_poker:Client:UpdatePokerTables", _locations) end
	
    locations = _locations
   
end)

RegisterNetEvent("rainbow_poker:Client:TriggerUpdate")
AddEventHandler("rainbow_poker:Client:TriggerUpdate", function(_game)

	if Config.DebugPrintUnsafe then print("rainbow_poker:Client:TriggerUpdate", _game) end
	
    UI:UpdateGame(_game)

    game = _game

    if _game.currentGoingBet and _game.currentGoingBet > 1 then
        turnBaseRaiseAmount = _game.currentGoingBet
    else
        turnBaseRaiseAmount = 1
    end
    turnRaiseAmount = turnBaseRaiseAmount
   
end)

RegisterNetEvent("rainbow_poker:Client:ReturnPlayerLeave")
AddEventHandler("rainbow_poker:Client:ReturnPlayerLeave", function(locationIndex, player)
    
    if Config.DebugPrint then print("rainbow_poker:Client:ReturnPlayerLeave") end

    hasLeft = true
    UI:CloseAll()
    clearPedTaskAndUnfreeze(true)

end)

RegisterNetEvent("rainbow_poker:Client:WarnTurnTimer")
AddEventHandler("rainbow_poker:Client:WarnTurnTimer", function(locationIndex, player)
    
    if Config.DebugPrint then print("rainbow_poker:Client:WarnTurnTimer") end

    local timeRemaining = Config.TurnTimeoutWarningInSeconds

    VORPcore.NotifyRightTip(string.format("WARNING: Take action now. Less than %d seconds remaining.", timeRemaining), 6 * 1000)

    TriggerEvent("rainbow_core:PlayAudioFile", Config.Audio.TurnTimerWarn, Config.AudioVolume)
end)

RegisterNetEvent("rainbow_poker:Client:AlertWin")
AddEventHandler("rainbow_poker:Client:AlertWin", function(_winScenario)
    
    if Config.DebugPrint then print("rainbow_poker:Client:AlertWin") end

    -- Don't alert if they left the poker game
    if hasLeft == false then
        UI:AlertWinScenario(_winScenario)
    end

end)

RegisterNetEvent("rainbow_poker:Client:CleanupFinishedGame")
AddEventHandler("rainbow_poker:Client:CleanupFinishedGame", function()
    
    if Config.DebugPrint then print("rainbow_poker:Client:CleanupFinishedGame") end

    UI:CloseAll()

    if hasLeft == false then
        clearPedTaskAndUnfreeze(true)
    end

    game = nil
    isInGame = false
    hasLeft = false

    
end)




-------- FUNCTIONS

function PlayAnimation(animationId)

    if hasLeft then
        return
    end

    math.randomseed(GetGameTimer())

    local animationArray = Config.Animations[animationId]
    local randomAnimationIndex = math.random(1, #animationArray)
    local animation = animationArray[randomAnimationIndex]

    if Config.DebugPrint then print("PlayAnimation - animation", animation) end

    RequestAnimDict(animation.Dict)
    while not HasAnimDictLoaded(animation.Dict) do
        Wait(100)
    end

    local playerPedId = PlayerPedId()

    local length = 0
    if animation.isIdle then
        length = -1
    elseif animation.Length then
        length = animation.Length
    else
        length = 4000
    end

    local blendIn = 8.0
    local blendOut = 1.0
    if animation.isIdle then
        blendIn = 1.0
        blendOut = 1.0
    end

    -- if Config.DebugPrint then print("PlayAnimation - length", length) end

    FreezeEntityPosition(playerPedId, true)

    -- if Config.DebugPrint then print("PlayAnimation - TaskPlayAnim") end
    TaskPlayAnim(playerPedId, animation.Dict, animation.Name, blendIn, blendOut, length, 25, 1.0, true, 0, false, 0, false)

    if length and length > 0 then
        -- if Config.DebugPrint then print("PlayAnimation - waiting") end
        Wait(length)
        PlayBestIdleAnimation()
    end
end

function PlayBestIdleAnimation()
    if Config.DebugPrint then print("PlayBestIdleAnimation") end

    local player
    for k,v in pairs(game.players) do
        if v.netId == GetPlayerServerId(PlayerId()) then
            player = v
            break
        end
    end

    if game.step == ROUNDS.SHOWDOWN or (player and player.hasFolded) then
        PlayAnimation("NoCards")
    else
        PlayAnimation("HoldCards")
    end

end

function startChairScenario(locationId, chairNumber)

    if Config.DebugPrint then print("startChairScenario", locationId, chairNumber) end


    -- Get the location's config
    local configTable = Config.Locations[locationId]

    local chairVector = configTable.Chairs[chairNumber].Coords

    if Config.DebugPrint then print("startChairScenario - chairVector", chairVector) end

    ClearPedTasksImmediately(PlayerPedId())

	FreezeEntityPosition(PlayerPedId(), true)

    TaskStartScenarioAtPosition(PlayerPedId(), GetHashKey("GENERIC_SEAT_CHAIR_TABLE_SCENARIO"), chairVector.x, chairVector.y, chairVector.z, chairVector.w, -1, false, true)
    
end

function findThisPlayerFromGameTable(_game)
    for k,playerTable in pairs(_game.players) do
        if playerTable.netId == GetPlayerServerId(PlayerId()) then
            return playerTable
        end
    end
end

function clearPedTaskAndUnfreeze(isSmooth)
    local playerPedId = PlayerPedId()
    FreezeEntityPosition(playerPedId, false)
    -- if isSmooth then
    --     ClearPedTasks(playerPedId)
    -- else
        ClearPedTasksImmediately(playerPedId)
    -- end
end

--------

AddEventHandler("onResourceStop", function(resourceName)
	if GetCurrentResourceName() == resourceName then

        isInGame = false
        game = nil
        isNearTable = false
        nearTableLocationIndex = nil
        locations = {}
        hasLeft = false

        clearPedTaskAndUnfreeze(false)
        
    end

end)