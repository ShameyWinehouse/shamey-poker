<script>

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// class Page {
//   constructor(url, altText, index) {
//     this.url = url;
//     this.altText = altText;
//     this.index = index;
//   }
// }

export default {
  data() {
    return {
      viewPokerGame: false,
      game: undefined,
      thisPlayer: undefined,
      winScenario: undefined,
    }
  },
  mounted() {
    let self = this;
    window.addEventListener('message', this.onMessage);
    window.addEventListener('keyup', function (e) {
      if (e.key == "Escape") {
        self.fireEvent('closeAll')
      }
    });
  },
  destroyed() {
    window.removeEventListener('message')
    window.removeEventListener('keyup')
  },
  methods: {
    async onMessage(event) {
      if (event.data.type === 'start') {
        this.viewPokerGame = true;
        this.game = event.data.game;
        this.thisPlayer = event.data.thisPlayer;

        this.winScenario = undefined;

        // console.log('view - this.game', this.game);
      }
      if (event.data.type === 'update') {

        // Check for change of round, in which case do some drama
        if (this.game.step == 'INITIAL' && event.data.game.step == 'FLOP') {
          await sleep(1000);
          this.fireEvent('playCardFlip');
          this.game.board.cardV.isRevealed = true;
          await sleep(1100);
          this.fireEvent('playCardFlip');
          this.game.board.cardW.isRevealed = true;
          await sleep(1200);
          this.fireEvent('playCardFlip');
          this.game.board.cardX.isRevealed = true;
        }

        if (this.game.step == 'FLOP' && event.data.game.step == 'TURN') {
          await sleep(1000);
          this.fireEvent('playCardFlip');
          this.game.board.cardY.isRevealed = true;
        }

        if (this.game.step == 'TURN' && event.data.game.step == 'RIVER') {
          await sleep(1000);
          this.fireEvent('playCardFlip');
          this.game.board.cardZ.isRevealed = true;
        }

        this.game = event.data.game;
        this.thisPlayer = event.data.thisPlayer;
        // console.log('update - this.game', this.game);
      }
      if (event.data.type === 'win') {
        this.winScenario = event.data.winScenario;
        if(this.winScenario.thisPlayersWinningHand){
          this.winScenario.thisPlayersWinningHand.winningHandType = this.winScenario.thisPlayersWinningHand.winningHandType.toString().replace(/_/g, ' ');
        }
        // console.log('win - winScenario', this.winScenario); // FIXMEEEEEEEEEEEEE*****
      }
      if (event.data.type === 'close') {
        this.viewPokerGame = false;
        this.game = undefined;
        this.thisPlayer = undefined;
        this.winScenario = undefined;
      }

    },
    fireEvent(eve, opts = {}) {
      fetch(`https://${GetParentResourceName()}/` + eve, {
        method: 'POST',
        body: JSON.stringify(opts)
      })
    },
    translateCardToPng(isRevealed, royalty, suit){
      if (isRevealed) {

        let fullSuit
        switch (suit) {
          case 's':
            fullSuit = 'spades'
            break
          case 'c':
            fullSuit = 'clubs'
            break
          case 'd':
            fullSuit = 'diamonds'
            break
          case 'h':
            fullSuit = 'hearts'
            break
        }

        return '/ui/dist/img/card/'+fullSuit+'_'+royalty.toLowerCase()+'.png'
      }
      return '/ui/dist/img/card/back.png'
    },
    getThisRoundsActionFromPlayer(player){
      // console.log('getThisRoundsActionFromPlayer', player.actionFlop, this.game.step)
      if (player.hasFolded) {
        return 'Folded';
      }
      if (player.order == this.game.currentTurn){
        return 'Deciding';
      }
      switch (this.game.step) {
        case 'INITIAL':
          return player.actionInitial ?? 'Waiting'
        case 'FLOP':
          return player.actionFlop ?? 'Waiting'
        case 'TURN':
          return player.actionTurn ?? 'Waiting'
        case 'RIVER':
          return player.actionRiver ?? 'Waiting'
        default:
          return ''
      }
    },
  },
};

</script>

<template>
  <header>
  </header>

  <main>

    <!-- POKER -->

    <div class="wrapper" v-if="viewPokerGame && game && game.step!='pending'">

      <div class="poker-box">

        <div id="board-box" class="d-flex justify-center">
          <v-container class="w-auto px-10 py-3 mt-5">

            <v-row>
              <v-col>
                <!-- <h1>BOARD CARDS</h1> -->
                <div id="board-cards" class="d-flex">
                  <div id="board-card-V" class="card board-card">
                    <v-img :src="this.translateCardToPng(this.game.board.cardV.isRevealed, this.game.board.cardV.royalty, this.game.board.cardV.suit)" width="64" />
                  </div>
                  <div id="board-card-W" class="card board-card">
                    <v-img :src="this.translateCardToPng(this.game.board.cardW.isRevealed, this.game.board.cardW.royalty, this.game.board.cardW.suit)" width="64" />
                  </div>
                  <div id="board-card-X" class="card board-card">
                    <v-img :src="this.translateCardToPng(this.game.board.cardX.isRevealed, this.game.board.cardX.royalty, this.game.board.cardX.suit)" width="64" />
                  </div>
                  <div id="board-card-Y" class="card board-card">
                    <v-img :src="this.translateCardToPng(this.game.board.cardY.isRevealed, this.game.board.cardY.royalty, this.game.board.cardY.suit)" width="64" />
                  </div>
                  <div id="board-card-Z" class="card board-card">
                    <v-img :src="this.translateCardToPng(this.game.board.cardZ.isRevealed, this.game.board.cardZ.royalty, this.game.board.cardZ.suit)" width="64" />
                  </div>
                </div>
              </v-col>
            </v-row>

          </v-container>
        </div>

        <div id="hole-box-container" class="position-absolute bottom-0 w-100">
          <div id="hole-box" class="d-flex justify-center">
            <v-container class="ma-5 w-auto px-10 py-3">
              <v-row>
                <v-col>
                  <!-- <h1>HOLE CARDS</h1> -->
                  <div id="hole-cards" class="d-flex">
                    <div id="hole-card-A" class="card hole-card">
                      <v-img :src="this.translateCardToPng(true, thisPlayer.cardA.royalty, thisPlayer.cardA.suit)" width="64" />
                    </div>
                    <div id="hole-card-B" class="card hole-card">
                      <v-img :src="this.translateCardToPng(true, thisPlayer.cardB.royalty, thisPlayer.cardB.suit)" width="64" />
                    </div>
                  </div>
                </v-col>
              </v-row>
            </v-container>
          </div>
        </div>

        <div id="players-box">
          <v-sheet class="ml-5 pb-5" style="background-color:rgba(0, 0, 0, 0.4);" width="600" rounded>
            <v-container class="mx-0 mb-0 w-auto px-10 py-3">
              <v-row>
                <v-col cols="12">

                  <v-container class="pa-0">
                    <v-row v-for="player in this.game.players" class="player mb-1">
                      <v-col cols="12" class="pa-0">
                        <v-container class="pb-0">
                          <div v-if="this.game.step == 'SHOWDOWN'">
                            <v-row class="player-cards">
                              <v-col cols="12" class="pa-0">
                                <div class="d-flex pl-3">
                                  <div class="card player-card">
                                    <v-img :src="this.translateCardToPng(player.cardA.isRevealed, player.cardA.royalty, player.cardA.suit)" width="32" />
                                  </div>
                                  <div class="card player-card">
                                    <v-img :src="this.translateCardToPng(player.cardB.isRevealed, player.cardB.royalty, player.cardB.suit)" width="32" />
                                  </div>
                                </div>
                              </v-col>
                            </v-row>
                          </div>
                          <!-- <v-sheet> -->
                            <v-row class="player-data ma-0 pa-0">
                              <v-col cols="4" class="player-data-item pl-0 pb-1"><span class="text-lime player-name">{{ player.name }}</span></v-col>
                              <v-col cols="3" class="player-data-item pb-0"><span>{{ getThisRoundsActionFromPlayer(player) }}</span></v-col>
                              <v-col cols="2" class="player-data-item pb-0"><span class="text-amber-lighten-3">${{ player.amountBetInRound }}</span></v-col>
                              <v-col cols="2" class="player-data-item pb-0"><span class="text-amber">${{ player.totalAmountBetInGame }}</span></v-col>
                              <v-col cols="1" class="player-data-item pb-0">
                                <div>
                                  <v-icon v-if="player.order == this.game.currentTurn" icon="mdi-arrow-left-bold-circle" size="x-small" class="text-light-blue pb-3 opacity-90"></v-icon>
                                </div>
                              </v-col>
                            </v-row>
                          <!-- </v-sheet> -->
                        </v-container>
                      </v-col>
                    </v-row>

                    <v-row class="total-pot-row mt-10">
                      <v-col cols="4">
                        Going Bet:
                      </v-col>
                      <v-col cols="8">
                        <span class="text-amber-lighten-3">${{ this.game.currentGoingBet }}</span>
                      </v-col>
                    </v-row>

                    <v-row class="total-pot-row mt-1">
                      <v-col cols="4">
                        Pot:
                      </v-col>
                      <v-col cols="8">
                        <span class="text-amber">${{ this.game.bettingPool }}</span>
                      </v-col>
                    </v-row>
                    
                  </v-container>

                </v-col>
              </v-row>
            </v-container>
          </v-sheet>
        </div>

      </div>

      <!-- WIN SCENARIOS! -->
      <div class="win-box-container" v-if="this.winScenario">

        <div id="win-box" class="d-flex justify-center">
          <v-container class="win-box-vcontainer w-auto pa-10">

            <v-row class="px-5">
              <v-col>

                <!-- LOSER -->
                <div v-if="!this.winScenario.thisPlayersWinningHand" class="text-center">
                  <h3 class="win-title text-red-accent-3">LOST</h3>
                  <div class="win-message">You lost this time.</div>
                </div>

                <!-- NON-TIES - WINNER -->
                <div v-if="this.winScenario.isTrueTie == false && this.winScenario.thisPlayersWinningHand" class="text-center">
                  <h3 class="win-title text-green-accent-3">WINNER!</h3>
                  <div class="win-message">You are the sole winner of this game with a hand of:</div>
                  <div class="win-message">{{ this.winScenario.thisPlayersWinningHand.winningHandType }}</div>
                  <div class="win-message">You win the entire pool of <span class="text-amber">${{ this.game.bettingPool }}</span>!</div>
                </div>

                <!-- TIES - WINNER -->
                <div v-if="this.winScenario.isTrueTie == true && this.winScenario.thisPlayersWinningHand" class="text-center">
                  <h3 class="win-title text-green-lighten-2">TIED WINNER!</h3>
                  <div class="win-message">You are one of {{ this.winScenario.tiedHands.length }} winners of this game with a hand of:</div>
                  <div class="win-message">{{ this.winScenario.thisPlayersWinningHand.winningHandType  }}</div>
                  <div class="win-message">You win 1/{{ this.winScenario.tiedHands.length }} of the pool: <span class="text-amber">${{ this.game.bettingPool / this.winScenario.tiedHands.length }}</span>!</div>
                </div>

              </v-col>
            </v-row>

          </v-container>
        </div>
      </div>



    </div>

  </main>
</template>

<style scoped>

</style>
