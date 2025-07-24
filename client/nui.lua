UI = {}




function UI:StartGame(game)

    if Config.DebugPrintUnsafe then print("UI:StartGame - game", game) end
    
    math.randomseed(GetGameTimer())

    SendNUIMessage({
        type = "start",
        game = game,
        thisPlayer = findThisPlayerFromGameTable(game),
    })
	SetNuiFocus(false, false)
    isInGame = true
end

function UI:UpdateGame(game)

    if Config.DebugPrintUnsafe then print("UI:UpdateGame - game", game) end
    
    math.randomseed(GetGameTimer())

    SendNUIMessage({
        type = "update",
        game = game,
        thisPlayer = findThisPlayerFromGameTable(game),
    })
    
end

function UI:AlertWinScenario(winScenario)

    if Config.DebugPrint then print("UI:AlertWinScenario - winScenario", winScenario) end
    
    math.randomseed(GetGameTimer())

    if winScenario.isTrueTie then
        for k,v in pairs(winScenario.tiedHands) do
            if v.playerNetId == GetPlayerServerId(PlayerId()) then
                winScenario["thisPlayersWinningHand"] = v
                break
            end
        end
    else
        if winScenario.winningHand.playerNetId == GetPlayerServerId(PlayerId()) then
            winScenario["thisPlayersWinningHand"] = winScenario.winningHand
        end
    end

    -- Play audio for win or lose
    if winScenario["thisPlayersWinningHand"] then
        TriggerEvent("rainbow_core:PlayAudioFile", Config.Audio.Win, Config.AudioVolume)
    else
        TriggerEvent("rainbow_core:PlayAudioFile", Config.Audio.Lose, Config.AudioVolume)
    end

    SendNUIMessage({
        type = "win",
        winScenario = winScenario,
    })

    -- Play animations for win or lose
    if winScenario["thisPlayersWinningHand"] then
        PlayAnimation("Win")
        PlayAnimation("Roseanne")
    else
        PlayAnimation("Loss")
    end
    
end

function UI:CloseAll()
    SendNUIMessage({
        type = "close",
    })
    SetNuiFocus(false, false)
    isInGame = false
end

RegisterNUICallback("playCardFlip", function(args, cb)
	-- if Config.DebugPrint then print("closeAll") end
    local rand = math.random(1,3)
    local audioName = Config.Audio["CardFlip"..rand]
	TriggerEvent("rainbow_core:PlayAudioFile", audioName, Config.AudioVolume)
	cb("ok")
end)

RegisterNUICallback("closeAll", function(args, cb)
	if Config.DebugPrint then print("closeAll") end
	UI:CloseAll()
	cb("ok")
end)