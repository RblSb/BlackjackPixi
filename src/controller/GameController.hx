package controller;

import model.Game;
import view.GameView;

class GameController {
	final game:Game;
	final gameView:GameView;

	public function new(game:Game, gameView:GameView) {
		this.game = game;
		this.gameView = gameView;
		attachListeners();
	}

	function attachListeners():Void {
		game.player.onCardDraw.add(gameView.deckView.onCardDraw);
		game.dealer.onCardDraw.add(gameView.deckView.onCardDraw);

		game.onBet.add(gameView.onBet);
		game.onNewRound.add(gameView.onNewRound);
		game.onRoundEnd.add(gameView.onRoundEnd);
		game.onGameOver.add(gameView.onGameOver);
		game.deck.onRefill.add(gameView.onRefill);

		gameView.dealerView.onCardDrawComplete.add(() -> {
			game.dealer.update();
		});

		game.player.onCardDraw.add(gameView.playerView.onCardDraw);

		gameView.onBetDone.add(bet -> {
			game.player.setBet(bet);
			game.newRound();
		});

		gameView.onHit.add(() -> {
			if (game.getState() != PlayerTurn) return;
			game.player.drawCard();
		});

		gameView.onStand.add(() -> {
			if (game.getState() != PlayerTurn) return;
			game.endTurn();
		});

		gameView.onDouble.add(() -> {
			if (game.getState() != PlayerTurn) return;
			game.player.doubleBet();
		});

		gameView.onReplay.add(state -> {
			if (state == Refill) {
				game.newRound();
			} else {
				game.endTurn();
			}
		});
	}
}
