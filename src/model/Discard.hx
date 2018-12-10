package model;

class Discard {
	public var cards:Array<Card> = [];

	public function new() {}

	public inline function push(card:Card) {
		cards.push(card);
	}

	public inline function pop():Card {
		return cards.pop();
	}
}
