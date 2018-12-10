package model;

import signals.Signal;

class Player {
	static inline var BASE_BET = 20;

	public final onCardDraw = new Signal();

	public var money(default, null) = 1000;

	public var bet(default, null) = BASE_BET;

	public var hand(default, null):Array<Card> = [];
	public var canDouble(default, null):Bool;

	var game:Game;

	public function new(game:Game) {
		this.game = game;
	}

	public function setBet(num:Int):Void {
		bet = num;
	}

	public inline function hasNoMoney():Bool {
		return money < BASE_BET;
	}

	public function newRound():Void {
		money -= bet;
		canDouble = money >= bet;
	}

	public function addCard(card:Card):Void {
		card.isOpen = true;
		hand.push(card);
		onCardDraw.dispatch();
	}

	public function doubleBet():Void {
		if (!canDouble) return;
		money -= bet;
		bet = bet * 2;
		drawCard();
	}

	public function handCount(hand:Array<Card>):Int {
		return game.handCount(hand);
	}

	public function drawCard():Void {
		if (game.isEmptyDeck()) return;
		canDouble = false;
		var card = game.drawCard();
		card.isOpen = true;
		hand.push(card);

		onCardDraw.dispatch();

		game.checkPlayerHand(hand);
	}

	public function win():Void {
		money += bet * 2;
	}

	public function draw():Void {
		money += bet;
	}

	public function lose():Void {}
}
