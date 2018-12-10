package view;

import model.Card;
import model.Dealer;
import motion.Actuate;
import pixi.core.display.Container;
import pixi.core.math.Point;
import pixi.core.text.Text;
import pixi.core.text.TextStyle;
import pixi.core.utils.Utils.TextureCache;
import signals.Signal;

class DealerView extends Container {
	var gameView:GameView;
	var dealer:Dealer;
	var hand:Array<CardView> = [];

	public final onCardDrawComplete = new Signal();

	public function new(gameView:GameView, dealer:Dealer) {
		super();
		this.gameView = gameView;
		this.dealer = dealer;
		for (card in dealer.hand) {
			addCard(card);
		}
		dealer.onOpenCard.add(onOpenCard);
		dealer.onCardDraw.add(onCardDraw);
	}

	function addCard(card:Card):Void {
		var cardView = new CardView(card);
		cardView.x = (cardView.width + 5) * hand.length;
		hand.push(cardView);
		addChild(cardView);
	}

	public function newRound():Void {
		while (hand.length > 0) {
			var oldCard = hand.pop();
			removeChild(oldCard);
			var card = parent.addChild(oldCard);
			var scale = gameView.gameScale;
			card.x = x + oldCard.x * scale;
			card.scale = new Point(scale, scale);
			Actuate.tween(card, 1, {y: card.y + card.height, alpha: 0}).onComplete(function() {
				parent.removeChild(card);
			});
		}
		for (card in dealer.hand) {
			addCard(card);
		}
	}

	public function isOpenHand():Bool {
		if (dealer.hand.length == 0) return false;
		for (card in dealer.hand) {
			if (!card.isOpen) return false;
		}
		return true;
	}

	function onOpenCard():Void {
		for (card in hand)
			card.show();
	}

	public function cardsWidth(num:Int):Float {
		var w = TextureCache[cast Res.back].width;
		return (w + 5) * num;
	}

	public function getWidth():Float {
		return cardsWidth(hand.length) * scale.x;
	}

	public function getHeight():Float {
		if (hand.length == 0) return 0;
		return hand[0].height * scale.y;
	}

	function onCardDraw():Void {
		var card = dealer.hand[dealer.hand.length - 1];
		addCard(card);
		var cardView = hand[hand.length - 1];
		var oldX = cardView.x;
		var oldY = cardView.y;
		var scale = gameView.gameScale;
		cardView.x = (gameView.deckCords(this).x - cardView.height / 2) / scale;
		cardView.y = (gameView.deckCords(this).y + cardView.width / 4) / scale;
		cardView.rotation = -Math.PI / 2;
		Actuate.tween(cardView, 1, {x: oldX, y: oldY, rotation: 0}).onComplete(function() {
			gameView.updateDealerPoints();
			onCardDrawComplete.dispatch();
		});
		var width = cardsWidth(hand.length) * scale;
		gameView.onCardDraw(this, width);
	}
}
