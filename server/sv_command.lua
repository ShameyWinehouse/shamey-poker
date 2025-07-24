

-- RegisterCommand("poker", function(source, args, rawCommand)
    
--     math.randomseed(os.time())

--     local player1NetId = source
--     -- local player2NetId = args[1]

--     -- Create the Players
--     local player1 = Player:New({
--         netId = player1NetId
--     })

--     local player2 = Player:New({
--         -- TEMP, FIXME: setup as npc
--         netId = -1,
--         isNpc = true,
--     })
    
--     -- Create the Game
--     game = Game:New({
--         players = {
--             player1,
--             player2,
--         }
--     })

--     -- Init the game
--     game:init()

--     TriggerClientEvent("rainbow_poker:Client:StartGame", player1NetId, game)
--     -- TriggerClientEvent("rainbow_poker:StartGame", player2NetId, game)

--     TriggerClientEvent("rainbow_poker:Client:UpdatePokerTables", -1, locations)
    
-- end, false)


if Config.DebugCommands then

    RegisterServerEvent("rainbow_poker:Server:Command:pokerv", function(args)
        local _source = source

        math.randomseed(os.time())

        local argBoard = args[1]

        local board = Board:New({
            cardV = Card:New({
                royalty = string.sub(argBoard, 1, 1),
                suit = string.sub(argBoard, 2, 2),
                isRevealed = true,
            }),
            cardW = Card:New({
                royalty = string.sub(argBoard, 3, 3),
                suit = string.sub(argBoard, 4, 4),
                isRevealed = true,
            }),
            cardX = Card:New({
                royalty = string.sub(argBoard, 5, 5),
                suit = string.sub(argBoard, 6, 6),
                isRevealed = true,
            }),
            cardY = Card:New({
                royalty = string.sub(argBoard, 7, 7),
                suit = string.sub(argBoard, 8, 8),
                isRevealed = true,
            }),
            cardZ = Card:New({
                royalty = string.sub(argBoard, 9, 9),
                suit = string.sub(argBoard, 10, 10),
                isRevealed = true,
            }),
        })

        local playersArray = {}

        local argPlayer1Hole = args[2]
        local player1 = Player:New({
            netId = 1,
            cardA = Card:New({
                royalty = string.sub(argPlayer1Hole, 1, 1),
                suit = string.sub(argPlayer1Hole, 2, 2),
            }),
            cardB = Card:New({
                royalty = string.sub(argPlayer1Hole, 3, 3),
                suit = string.sub(argPlayer1Hole, 4, 4),
            }),
        })
        table.insert(playersArray, player1)

        local argPlayer2Hole = args[3]
        local player2 = Player:New({
            netId = 2,
            cardA = Card:New({
                royalty = string.sub(argPlayer2Hole, 1, 1),
                suit = string.sub(argPlayer2Hole, 2, 2),
            }),
            cardB = Card:New({
                royalty = string.sub(argPlayer2Hole, 3, 3),
                suit = string.sub(argPlayer2Hole, 4, 4),
            }),
        })
        table.insert(playersArray, player2)

        if args[4] then
            local argPlayer3Hole = args[4]
            local player3 = Player:New({
                netId = 3,
                cardA = Card:New({
                    royalty = string.sub(argPlayer3Hole, 1, 1),
                    suit = string.sub(argPlayer3Hole, 2, 2),
                }),
                cardB = Card:New({
                    royalty = string.sub(argPlayer3Hole, 3, 3),
                    suit = string.sub(argPlayer3Hole, 4, 4),
                }),
            })
            table.insert(playersArray, player3)
        end

        local winScenario = getWinScenarioFromSetOfPlayers(playersArray, board, ROUNDS.SHOWDOWN)

        if Config.DebugPrint then print("winScenario", winScenario) end

        -- writeDebugWinScenario(winScenario, _source)
    end)
    
end

if Config.DebugCommands then

    RegisterServerEvent("rainbow_poker:Server:Command:Debug:PokerDeck", function(args)
        local _source = source

        if Config.DebugPrint then print("Debug:PokerDeck") end

        math.randomseed(os.time())

        local deck = Deck:New({})
        deck:init()

        if Config.DebugPrint then print("Debug:PokerDeck - deck:", deck) end

        for i=1,10 do
		
            local card = deck:pullCardByKey(deck:getRandomCardKey())
            
            if Config.DebugPrint then print("Debug:PokerDeck - card"..i..":", card) end
        end

    end)
    
end

function writeDebugWinScenario(winScenario, _source)
    if not winScenario:getIsTrueTie() then
        TriggerClientEvent("rainbow_core:VisualDebugTool", _source or -1, {
            ["winningHand:"] = winScenario:getWinningHand():getString(),
            ["winningHand type:"] = winScenario:getWinningHand():getWinningHandType(),
            ["winning player ID:"] = winScenario:getWinningHand():getPlayerNetId(),
        })
    else
        TriggerClientEvent("rainbow_core:VisualDebugTool", _source or -1, {
            ["isTrueTie:"] = winScenario:getIsTrueTie(),
        })
    end
end