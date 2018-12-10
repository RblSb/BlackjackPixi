package model;

import signals.Signal1;
import signals.Signal;

enum GameState {
	Bet;
	PlayerTurn;
	DealerTurn;
	RoundOver;
	GameOver;
}

enum abstract RoundState(Int) {
	var Win;
	var Lose;
	var Draw;
	var Refill;
	var NoMoney;
}

class Game {
	public final onBet = new Signal();
	public final onNewRound = new Signal();
	public final onRoundEnd = new Signal1<RoundState>();
	public final onGameOver = new Signal();
	public final player:Player;
	public final dealer:Dealer;
	public final deck:Deck;
	public final discard:Discard;

	var state:GameState;

	public function new() {
		deck = new Deck(this);
		deck.init();
		discard = new Discard();
		player = new Player(this);
		dealer = new Dealer(this);
		state = Bet;
	}

	public function newRound():Void {
		while (player.hand.length > 0) {
			discard.push(player.hand.pop());
		}
		while (dealer.hand.length > 0) {
			discard.push(dealer.hand.pop());
		}

		if (deck.length < 10) {
			deck.shuffleDiscard();
			return;
		}

		player.newRound();
		onNewRound.dispatch();

		for (i in 0...2)
			player.addCard(deck.pop());
		for (i in 0...2)
			dealer.addCard(deck.pop());
		state = PlayerTurn;
	}

	public inline function getState():GameState {
		return state;
	}

	public function clearDiscard():Array<Card> {
		var cards = discard.cards;
		discard.cards = [];
		return cards;
	}

	public function isEmptyDeck():Bool {
		return deck.length == 0;
	}

	function isGameOver():Bool {
		if (player.hasNoMoney()) {
			state = GameOver;
			onGameOver.dispatch();
			return true;
		}
		return false;
	}

	// public function checkDealerHand(hand:Array<Card>):Void {
	// 	var count = handCount(hand);
	// 	if (count > 21) playerWin();
	// }

	public function checkPlayerHand(hand:Array<Card>):Void {
		var count = handCount(hand);
		if (count > 21) playerLose();
	}

	public function handCount(hand:Array<Card>):Int {
		var count = 0;
		for (card in hand) {
			if (card.type == Ace) count += 1;
			else count += card.count;
		}
		if (count >= 21) return count;
		for (card in hand) {
			if (card.type != Ace) continue;
			count += 10;
			if (count > 21) return count - 10;
		}
		return count;
	}

	public function drawCard():Card {
		return deck.pop();
	}

	function playerWin():Void {
		player.win();
		onRoundEnd.dispatch(Win);
		state = RoundOver;
	}

	function playerLose():Void {
		player.lose();
		if (isGameOver()) return;
		onRoundEnd.dispatch(Lose);
		state = RoundOver;
	}

	function gameDraw():Void {
		player.draw();
		onRoundEnd.dispatch(Draw);
		state = RoundOver;
	}

	public function endTurn():Void {
		switch (state) {
			case Bet:
				state = PlayerTurn;
			case PlayerTurn:
				state = DealerTurn;
				dealer.update();
			case DealerTurn:
				state = RoundOver;
				scoring();
			case RoundOver:
				if (isGameOver()) return;
				state = Bet;
				onBet.dispatch();
			case GameOver:
		}
	}

	function scoring():Void {
		var playerScore = handCount(player.hand);
		var dealerScore = handCount(dealer.hand);
		if (playerScore > dealerScore || dealerScore > 21) playerWin();
		else if (dealerScore > playerScore) playerLose();
		else gameDraw();
	}
}
