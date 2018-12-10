package model;

import signals.Signal;

class Deck {
	public final onRefill = new Signal();

	var game:Game;

	public var cards:Array<Card>;

	public var length(get, never):Int;

	inline function get_length():Int {
		return cards.length;
	}

	public function new(game:Game) {
		this.game = game;
	}

	public function init():Void {
		cards = [
			for (id in 0...13)
				for (suit in 0...4)
					new Card(suit, id)
		];
		shuffle(cards);
	}

	public function shuffleDiscard():Void {
		var discard:Array<Card> = game.clearDiscard();
		shuffle(discard);
		for (card in discard) {
			card.isOpen = false;
			cards.unshift(card);
		}
		onRefill.dispatch();
	}

	public function pop():Card {
		return cards.pop();
	}

	function shuffle<T>(arr:Array<T>):Void {
		for (i in 0...arr.length) {
			var j = Std.random(arr.length);
			var a = arr[i];
			var b = arr[j];
			arr[i] = b;
			arr[j] = a;
		}
	}
}
