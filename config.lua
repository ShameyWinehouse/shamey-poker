
Config = {}

Config.Debug = true
Config.DebugPrint = true
Config.DebugPrintUnsafe = false
Config.DebugCommands = false
Config.DebugOptions = {
    SkipStartGameOptions = false,
}

Config.Keys = {
    ActionCall = "INPUT_FRONTEND_RB", -- E
    ActionRaise = "INPUT_CONTEXT_X", -- R
    ActionCheck = "INPUT_FRONTEND_RS", -- X
    ActionFold = "INPUT_CONTEXT_B", -- F
    SubactionCycleAmount = "INPUT_FRONTEND_UP", -- UP
    StartGame = "INPUT_CONTEXT_A", -- SPACE
    JoinGame = "INPUT_CONTEXT_X", -- R
    BeginGame = "INPUT_CREATOR_ACCEPT", -- ENTER
    CancelGame = "INPUT_FRONTEND_RS", -- X
    LeaveGame = "INPUT_FRONTEND_DOWN", -- DOWN
}

Config.Locations = {
    ["Smithfields"] = {
        Table = {
            Coords = vector3(-304.53515625, 801.1351928710938, 117.97854614257812)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(-303.7159118652344, 801.9509887695312, 118.48006439209, 495.00006103516),
            },
            [2] = {
                Coords = vector4(-303.3963623046875, 800.8367919921875, 118.48006439209, 435.0),
            },
            [3] = {
                Coords = vector4(-304.22540283203, 799.99670410156, 118.48006439209, 374.99998474121),
            },
            [4] = {
                Coords = vector4(-305.36395263672, 800.29479980469, 118.48006439209, 315.00004577637),
            },
            [5] = {
                Coords = vector4(-305.68051147461, 801.43267822266, 118.48006439209, 254.99998474121),
            },
            [6] = {
                Coords = vector4(-304.85144042969, 802.27276611328, 118.48006439209, 193.3058052063),
            },
        }
    },
    ["ValentineStorage"] = {
        Table = {
            Coords = vector3(-233.16720581054688, 759.6881103515625, 116.8306884765625)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(-231.78, 759.86, 117.25, 88.92),
            },
            [2] = {
                Coords = vector4(-232.57, 758.6, 117.25, 32.92),
            },
            [3] = {
                Coords = vector4(-234.02, 758.94, 117.22, 311.92),
            },
            [4] = {
                Coords = vector4(-234.58, 760.28, 117.24, 252.92),
            },
            [5] = {
                Coords = vector4(-233.61, 761.15, 117.22, 198.92),
            },
            [6] = {
                vector4(-232.36, 760.97, 117.24, 148.92),
            },
        }
    },
    ["Armadillo"] = {
        Table = {
            Coords = vector3(-3619.4072265625, -2610.88037109375, -11.71362113952636)
        },
        MaxPlayers = 5,
        Chairs = {
            [1] = {
                Coords = vector4(-3618.25, -2611.19, -11.24, 81.44),
            },
            [2] = {
                Coords = vector4(-3619.37, -2612.11, -11.23, 357.36),
            },
            [3] = {
                Coords = vector4(-3620.66, -2611.15, -11.23, 277.27),
            },
            [4] = {
                Coords = vector4(-3620.06, -2609.65, -11.23, 204.4),
            },
            [5] = {
                Coords = vector4(-3618.65, -2609.95, -11.23, 149.14),
            },
        }
    },
    ["Blackwater"] = {
        Table = {
            Coords = vector3(-813.2147827148438, -1316.54736328125, 42.67874908447265)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(-813.21484375, -1315.3173828125, 43.178806304932, 180.0),
            },
            [2] = {
                Coords = vector4(-812.14965820312, -1315.9323730469, 43.178745269775, 479.99996948242),
            },
            [3] = {
                Coords = vector4(-812.14978027344, -1317.1624755859, 43.178791046143, 420.00004577637),
            },
            [4] = {
                Coords = vector4(-813.21478271484, -1317.77734375, 43.178730010986, 359.99998474121),
            },
            [5] = {
                Coords = vector4(-814.27996826172, -1317.1623535156, 43.178760528564, 299.99995422363),
            },
            [6] = {
                Coords = vector4(-814.28009033203, -1315.9324951172, 43.178672790527, 240.00002670288),
            },
        }
    },
    ["Bastille"] = {
        Table = {
            Coords = vector3(2630.739990234375, -1226.25048828125, 52.3793716430664)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(2629.7143554688, -1226.8499755859, 52.879585266113, 299.99995422363),
            },
            [2] = {
                Coords = vector4(2629.7067871094, -1225.6606445312, 52.879585266113, 240.00002670288),
            },
            [3] = {
                Coords = vector4(2630.7260742188, -1225.0499267578, 52.879585266113, 539.76260375977),
            },
            [4] = {
                Coords = vector4(2631.767578125, -1225.6502685547, 52.879753112793, 479.99996948242),
            },
            [5] = {
                Coords = vector4(2631.7666015625, -1226.8171386719, 52.879753112793, 420.00004577637),
            },
            [6] = {
                Coords = vector4(2630.7465820312, -1227.4375, 52.879585266113, 359.99998474121),
            },
        }
    },
    ["Colter"] = {
        Table = {
            Coords = vector3(-1348.92, 2440.14, 309.19)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(-1349.11, 2438.9, 307.9, 345.0),
            },
            [2] = {
                Coords = vector4(-1349.95, 2439.72, 307.9, 285.0),
            },
            [3] = {
                Coords = vector4(-1349.65, 2440.87, 307.9, 225.0),
            },
            [4] = {
                Coords = vector4(-1348.52, 2441.18, 307.9, 165.0),
            },
            [5] = {
                Coords = vector4(-1347.67, 2440.35, 307.9, 105.0),
            },
            [6] = {
                Coords = vector4(-1347.97, 2439.21, 307.9, 45.0),
            },
        }
    },
    ["Emerald"] = {
        Table = {
            Coords = vector3(1450.4486083984375, 378.16632080078125, 88.83031463623047)
        },
        MaxPlayers = 4,
        Chairs = {
            [1] = {
                Coords = vector4(1449.1217041016, 378.19815063477, 89.338119506836, 255.91299438477),
            },
            [2] = {
                Coords = vector4(1449.8660888672, 378.98043823242, 89.343681335449, 203.84995079041),
            },
            [3] = {
                Coords = vector4(1450.8999023438, 379.05187988281, 89.343414306641, 523.28308105469),
            },
            [4] = {
                Coords = vector4(1451.6976318359, 378.34112548828, 89.348678588867, 474.08618164062),
            },
        }
    },
    ["KorriganL"] = {
        Table = {
            Coords = vector3(2874.1787109375, -1404.4053955078125, 42.45375061035156)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(2873.31, -1403.71, 42.9, 231.86),
            },
            [2] = {
                Coords = vector4(2874.39, -1403.31, 42.89, 168.36),
            },
            [3] = {
                Coords = vector4(2875.31, -1404.03, 42.89, 110.36),
            },
            [4] = {
                Coords = vector4(2874.98, -1405.09, 42.9, 50.86),
            },
            [5] = {
                Coords = vector4(2873.99, -1405.49, 42.9, 349.86),
            },
            [6] = {
                Coords = vector4(2873.14, -1404.78, 42.91, 287.86),
            },
        }
    },
    ["KorriganC"] = {
        Table = {
            Coords = vector3(2870.537353515625, -1403.39306640625, 42.48088073730469)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(2869.67, -1402.67, 42.93, 231.86),
            },
            [2] = {
                Coords = vector4(2870.75, -1402.27, 42.92, 168.36),
            },
            [3] = {
                Coords = vector4(2871.58, -1402.97, 42.91, 110.36),
            },
            [4] = {
                Coords = vector4(2871.4, -1404.08, 42.92, 50.86),
            },
            [5] = {
                Coords = vector4(2870.36, -1404.46, 42.91, 349.86),
            },
            [6] = {
                Coords = vector4(2869.48, -1403.78, 42.92, 292.36),
            },
        }
    },
    ["KorriganR"] = {
        Table = {
            Coords = vector3(2872.223388671875, -1406.71630859375, 42.45403671264648)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(2871.42, -1406.03, 42.9, 229.36),
            },
            [2] = {
                Coords = vector4(2872.43, -1405.64, 42.9, 168.36),
            },
            [3] = {
                Coords = vector4(2873.25, -1406.32, 42.9, 110.36),
            },
            [4] = {
                Coords = vector4(2873.06, -1407.4, 42.89, 50.86),
            },
            [5] = {
                Coords = vector4(2872.04, -1407.9, 42.89, 349.86),
            },
            [6] = {
                Coords = vector4(2872.04, -1407.9, 42.89, 349.86),
            },
        }
    },
    ["Limpany"] = {
        Table = {
            Coords = vector3(-363.32, -117.83, 51.99)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(-362.22, -118.33, 50.75, 77.12),
            },
            [2] = {
                Coords = vector4(-363.05, -119.23, 50.75, 17.12),
            },
            [3] = {
                Coords = vector4(-364.25, -118.96, 50.75, 317.12),
            },
            [4] = {
                Coords = vector4(-364.62, -117.78, 50.75, 257.12),
            },
            [5] = {
                Coords = vector4(-363.78, -116.88, 50.75, 197.12),
            },
            [6] = {
                Coords = vector4(-362.59, -117.16, 50.75, 137.12),
            },
        }
    },
    ["Rhodes"] = {
        Table = {
            Coords = vector3(1436.75, -1370.54, 84.71)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(1435.87, -1369.64, 84.71, 215.2),
            },
            [2] = {
                Coords = vector4(1437.01, -1369.53, 84.71, 155.2),
            },
            [3] = {
                Coords = vector4(1437.68, -1370.48, 84.71, 95.2),
            },
            [4] = {
                Coords = vector4(1437.22, -1371.5, 84.71, 35.2),
            },
            [5] = {
                Coords = vector4(1436.07, -1371.64, 84.71, 335.2),
            },
            [6] = {
                Coords = vector4(1435.4, -1370.69, 84.71, 275.2),
            },
        }
    },
    ["Strawberry"] = {
        Table = {
            Coords = vector3(-1779.7, -369.39, 160.74)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(-1780.25, -370.27, 159.44, 313.15),
            },
            [2] = {
                Coords = vector4(-1780.55, -369.38, 159.44, 258.9),
            },
            [3] = {
                Coords = vector4(-1780.12, -368.69, 159.44, 202.46),
            },
            [4] = {
                Coords = vector4(-1779.17, -368.76, 159.44, 152.04),
            },
            [5] = {
                Coords = vector4(-1778.63, -369.65, 159.44, 73.86),
            },
            [6] = {
                Coords = vector4(-1779.35, -370.41, 159.44, 13.76),
            },
        }
    },
    ["Tumbleweed"] = {
        Table = {
            Coords = vector3(-5510.39453125, -2913.763671875, 0.63532996177673)
        },
        MaxPlayers = 6,
        Chairs = {
            [1] = {
                Coords = vector4(-5509.8168945312, -2912.76171875, 1.1376080513, 521.35214233398),
            },
            [2] = {
                Coords = vector4(-5509.076171875, -2913.7365722656, 1.1376080513, 462.59912109375),
            },
            [3] = {
                Coords = vector4(-5509.7485351562, -2914.8395996094, 1.1376080513, 397.97984313965),
            },
            [4] = {
                Coords = vector4(-5510.9624023438, -2914.7702636719, 1.1376080513, 342.36683654785),
            },
            [5] = {
                Coords = vector4(-5511.638671875, -2913.7788085938, 1.1376080513, 286.14791870117),
            },
            [6] = {
                Coords = vector4(-5511.0307617188, -2912.7585449219, 1.1376080513, 212.57964706421),
            },
        }
    },
}

Config.TableDistance = 2.6

Config.TurnTimeoutInSeconds = 2 * 60
Config.TurnTimeoutWarningInSeconds = 20

Config.Audio = {
    ChipDrop = "poker_chip_drop_1.ogg",
    ChipTap = "poker_chip_tap_1.ogg",
    CardsDeal = "poker_cards_deal5.ogg",
    Win = "treasure.ogg",
    Lose = "brass_fail.ogg",
    TurnTimerWarn = "tick_tock.ogg",
    CardFlip1 = "card_flip1.ogg",
    CardFlip2 = "card_flip2.ogg",
    CardFlip3 = "card_flip3.ogg",
}
Config.AudioVolume = 0.1

Config.Animations = {
    HoldCards = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "hold_cards_idle_a",
            isIdle = true,
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "look_medium_board_02",
            isIdle = true,
        },
    },
    --------
    NoCards = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "no_cards_idle_a",
            isIdle = true,
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "no_cards_idle_e",
            isIdle = true,
        },
    },
    --------
    Bet = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "bet_stack_a",
            Length = 2300,
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "bet_stack_b",
            Length = 2000,
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "bet_stack_c",
            Length = 1900,
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "bet_stack_d",
            Length = 2000,
        },
    },
    Check = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "check_a",
            Length = 1700,
        },
    },
    Fold = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "fold",
            Length = 1200,
        },
    },
    AllIn = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "take_pot_a",
        },
    },
    --------
    DealFlop = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "flop",
        },
    },
    DealTurn = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "turn_hold_cards",
            Length = 7000,
        },
    },
    DealRiver = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "river_hold_cards",
            Length = 7000,
        },
    },
    --------
    Reveal = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "reveal",
            Length = 4000,
        },
    },
    Roseanne = { -- Win
        {
            Dict = "mini_games@poker_mg@base",
            Name = "take_pot_a",
            Length = 7000,
        },
    },
    Win = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "express_win_a",
        },
    },
    Loss = {
        {
            Dict = "mini_games@poker_mg@base",
            Name = "express_loss_a",
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "express_loss_b",
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "express_loss_c",
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "express_loss_d",
        },
        {
            Dict = "mini_games@poker_mg@base",
            Name = "express_loss_e",
        },
    },
}

Config.Webhook = "https://discord.com/api/webhooks/..."