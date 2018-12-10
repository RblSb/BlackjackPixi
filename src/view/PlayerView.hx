package view;

import model.Card;
import model.Player;
import motion.Actuate;
import pixi.core.display.Container;
import pixi.core.math.Point;
import pixi.core.text.Text;
import pixi.core.text.TextStyle;
import pixi.core.utils.Utils.TextureCache;

class PlayerView extends Container {
	var gameView:GameView;
	var player:Player;
	var hand:Array<CardView> = [];

	public var points = 0;
	public var money:Text;
	public var bet:Text;

	var style = new TextStyle({
		fontFamily: 'Arial',
		fontSize: 36,
		fontStyle: 'italic',
		fontWeight: 'normal',
		fill: ['#fffff0', '#ffff44'],
		stroke: '#303020',
		strokeThickness: 4,
		dropShadow: true,
		dropShadowColor: '#000000',
		dropShadowAlpha: 0.75,
		dropShadowBlur: 0,
		dropShadowAngle: Math.PI / 6,
		dropShadowDistance: 6,
		lineJoin: "round"
	});

	public function new(gameView:GameView, player:Player) {
		super();
		this.gameView = gameView;
		this.player = player;

		bet = new Text('Bet: ${player.bet}$$', style);
		money = new Text('Bank: ${player.money}$$', style);

		newRound();
		money.x = width - money.width;
		addChild(bet);
		addChild(money);
	}

	function addCard(card:Card):Void {
		var cardView = new CardView(card);
		cardView.x = (cardView.width + 5) * hand.length;
		hand.push(cardView);
		addChild(cardView);
		points = player.handCount(player.hand);
	}

	public function update():Void {
		money.text = 'Bank: ${player.money}$$';
		bet.text = 'Bet: ${player.bet}$$';
	}

	public function newRound():Void {
		while (hand.length > 0) {
			var oldCard = hand.pop();
			removeChild(oldCard);
			var card = parent.addChild(oldCard);
			var scale = gameView.gameScale;
			card.y = y + oldCard.y * scale;
			card.x = x + oldCard.x * scale;
			card.scale = new Point(scale, scale);
			Actuate.tween(card, 1, {y: card.y - card.height, alpha: 0}).onComplete(function() {
				parent.removeChild(card);
			});
		}
		for (card in player.hand) {
			addCard(card);
		}
	}

	public function cardsWidth(num:Int):Float {
		var w = TextureCache[cast Res.back].width;
		return (w + 5) * num;
	}

	public function onCardDraw():Void {
		var card = player.hand[player.hand.length - 1];
		addCard(card);
		var cardView = hand[hand.length - 1];
		var oldX = cardView.x;
		var oldY = cardView.y;
		var scale = gameView.gameScale;
		cardView.x = (gameView.deckCords(this).x - cardView.height / 2) / scale;
		cardView.y = (gameView.deckCords(this).y + cardView.width / 4) / scale;
		cardView.rotation = -Math.PI / 2;
		Actuate.tween(cardView, 1, {x: oldX, y: oldY, rotation: 0});

		var width = cardsWidth(hand.length) * scale;
		gameView.onCardDraw(this, width);
	}
}
