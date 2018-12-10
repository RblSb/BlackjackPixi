package view;

import js.Browser.document;
import model.Deck;
import motion.Actuate;
import pixi.core.Application;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;

class DeckView extends Container {
	var deck:Deck;
	var cards:Array<CardView> = [];

	public function new(deck:Deck) {
		super();
		this.deck = deck;
		init();
	}

	function init():Void {
		var offX = 0.0;
		for (card in deck.cards) {
			var cardView = new CardView(card);
			cards.push(cardView);
			cardView.x = offX;
			addChild(cardView);
			offX -= 0.5;
		}
		if (cards.length == 0) return;
		var w = cards[0].width;
		var h = cards[0].height;
		pivot.set(w / 2, h / 2);
		rotation = Math.PI / 2;
	}

	public function onCardDraw():Void {
		removeChild(cards.pop());
	}

	public function onDeckRefill():Void {
		var oldLen = cards.length;
		init();
		for (i in 0...cards.length - oldLen) {
			var card = cards[i];
			var oldX = card.x;
			card.x = -9000;
			Actuate.tween(card, 1, {x: oldX}).delay(i / 10);
		}
	}

	public function deckCords():Point {
		return position;
	}
}
