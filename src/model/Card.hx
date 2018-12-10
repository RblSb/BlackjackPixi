package model;

enum abstract CardSuit(Int) from Int {
	var Pika = 0;
	var Hearts = 1;
	var Clover = 2;
	var Diam = 3;
}

enum abstract CardType(Int) from Int to Int {
	var Ace = 0;
	var Two = 1;
	var Three = 2;
	var Four = 3;
	var Five = 4;
	var Six = 5;
	var Seven = 6;
	var Eight = 7;
	var Nine = 8;
	var Ten = 9;
	var Jack = 10;
	var Queen = 11;
	var King = 12;
}

class Card {
	static var counts = [11, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10];

	public var isOpen:Bool;
	public var suit(default, null):CardSuit;
	public var type(default, null):CardType;
	public var count(get, never):Int;

	inline function get_count():Int
		return counts[type];

	public function new(suit:CardSuit, type:CardType, isOpen = false) {
		this.suit = suit;
		this.type = type;
		this.isOpen = isOpen;
	}
}
