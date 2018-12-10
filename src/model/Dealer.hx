package model;

import signals.Signal;

class Dealer {
	var game:Game;

	public var hand(default, null):Array<Card> = [];

	public final onCardDraw = new Signal();
	public final onOpenCard = new Signal();

	public function new(game:Game) {
		this.game = game;
	}

	public function addCard(card:Card):Void {
		hand.push(card);
		onCardDraw.dispatch();
	}

	public function update():Void {
		if (game.getState() != DealerTurn) return;
		for (card in hand)
			card.isOpen = true;
		onOpenCard.dispatch();
		if (game.isEmptyDeck()) {
			game.endTurn();
			return;
		}
		if (game.handCount(hand) < 17) drawCard();
		else game.endTurn();
	}

	function drawCard():Void {
		var card = game.drawCard();
		card.isOpen = true;
		hand.push(card);

		onCardDraw.dispatch();
		// game.checkDealerHand(hand);
	}
}
