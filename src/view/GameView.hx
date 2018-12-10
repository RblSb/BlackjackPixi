package view;

import js.Browser.window;
import model.Game.RoundState;
import model.Game;
import motion.Actuate;
import pixi.core.Application;
import pixi.core.display.Container;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
import pixi.core.text.TextStyle;
import pixi.core.textures.Texture;
import pixi.core.utils.Utils.TextureCache;
import signals.Signal1;
import signals.Signal;

class GameView extends Container {
	var app:Application;
	var game:Game;

	public final playerView:PlayerView;
	public final dealerView:DealerView;
	public final deckView:DeckView;
	public final onReplay = new Signal1<RoundState>();
	public final onBetDone = new Signal1<Int>();
	public final onHit = new Signal();
	public final onStand = new Signal();
	public final onDouble = new Signal();
	public var gameScale = 0.75;

	var bg:Sprite;
	var playerHeight:Float;
	var minPlayerWidth:Float;

	var playerPoints:Text;
	var dealerPoints:Text;
	var textStyle = new TextStyle({
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
		dropShadowAngle: Math.PI / 6,
		dropShadowDistance: 6,
		lineJoin: "round"
	});
	var betButtons:Array<Button> = [];
	var draw:Button;
	var end:Button;
	var double:Button;
	var replay:Button;
	var roundText:Text;

	public function new(app:Application, game:Game) {
		super();
		this.app = app;
		this.game = game;
		app.ticker.add(onUpdate);
		window.addEventListener("resize", e -> {
			app.resizeTo = window;
			onResize();
		});

		initBG();
		var scale = new Point(gameScale, gameScale);

		deckView = new DeckView(game.deck);
		deckView.scale = scale;
		deckView.x = width - deckView.width;
		deckView.y = height / 2;
		addChild(deckView);

		dealerView = new DealerView(this, game.dealer);
		dealerView.scale = scale;
		dealerView.x = (width - dealerView.width) / 2;
		dealerView.y = 0;
		addChild(dealerView);

		playerView = new PlayerView(this, game.player);
		playerView.scale = scale;
		playerHeight = TextureCache[cast Res.back].height * gameScale;
		minPlayerWidth = playerView.cardsWidth(2) * gameScale;
		playerView.x = (width - minPlayerWidth) / 2;
		playerView.y = height - playerHeight;
		addChild(playerView);

		addPoints();
		if (game.getState() == Bet) addBetButtons();
		else addButtons();
	}

	function initBG():Void {
		var canvas = js.Browser.document.createCanvasElement();
		canvas.width = Std.int(app.renderer.width);
		canvas.height = Std.int(app.renderer.height);
		var ctx = canvas.getContext("2d");
		var w = canvas.width * 2;
		var h = canvas.height * 2;
		var grd = ctx.createRadialGradient(w / 4, h / 2, 0, w / 4, h / 2, w / 3);
		grd.addColorStop(0, "#00d150");
		grd.addColorStop(1, "#007030");
		ctx.fillStyle = grd;
		ctx.translate(0, 0);
		ctx.scale(1, 0.5);
		ctx.fillRect(0, 0, w, h);

		removeChild(bg);
		bg = new Sprite(Texture.from(canvas));
		addChildAt(bg, 0);
	}

	function addPoints():Void {
		var bet = playerView.bet;
		bet.scale = new Point(gameScale, gameScale);
		bet.x = width / 2 - minPlayerWidth / 2 - bet.width / 2;
		bet.y = playerView.y - bet.height;
		addChild(playerView.bet);
		var money = playerView.money;
		money.scale = new Point(gameScale, gameScale);
		money.x = width / 2 + minPlayerWidth / 2 - money.width / 2;
		money.y = playerView.y - money.height;
		addChild(playerView.money);
		var offY = Math.max(bet.height, money.height);

		var points = game.handCount(game.player.hand);
		playerPoints = new Text("00", textStyle);
		playerPoints.x = (width - playerPoints.width) / 2;
		playerPoints.y = playerView.y - playerPoints.height;
		playerPoints.text = "";
		addChild(playerPoints);

		dealerPoints = new Text("", textStyle);
		addChild(dealerPoints);
	}

	function addBetButtons():Void {
		var bets = [20, 50, 100];
		var colors:Array<Button.ButtonColor> = [Green, Yellow, Red];
		var offY = 0.0;
		for (i in 0...bets.length) {
			var bet = bets[i];
			var text = new Text('Bet: $bet$$', textStyle);
			var btn = new Button(colors[i], text);
			btn.y = (height - btn.height) / 2 + offY - btn.height;
			offY += btn.height;
			betButtons.push(btn);
			addChild(btn);
			if (game.player.money < bet) {
				btn.disabled = true;
				continue;
			}
			btn.pointertap = function(e) {
				if (game.getState() != Bet) return;
				hideBetButtons();
				addButtons();
				onBetDone.dispatch(bet);
			};
		}

		if (game.player.money < bets[0]) {
			onRoundEnd(NoMoney);
		}
	}

	function hideBetButtons():Void {
		while (betButtons.length > 0)
			removeChild(betButtons.pop());
	}

	function addButtons():Void {
		var text = new Text("Hit", textStyle);
		draw = new Button(Yellow, text);
		draw.pointertap = function(e) {
			onHit.dispatch();
		};
		draw.y = (height - draw.height) / 2 - draw.height;
		addChild(draw);

		var text = new Text("Stand", textStyle);
		end = new Button(Blue, text);
		end.pointertap = function(e) {
			onStand.dispatch();
		};
		end.y = draw.y + draw.height;
		addChild(end);

		var text = new Text("Double", textStyle);
		double = new Button(Red, text);
		double.pointertap = function(e) {
			onDouble.dispatch();
		};
		double.y = end.y + end.height;
		addChild(double);
	}

	function hideButtons():Void {
		removeChild(draw);
		removeChild(end);
		removeChild(double);
	}

	public function onBet():Void {
		hideButtons();
		addBetButtons();
	}

	public function onNewRound():Void {
		playerView.newRound();
		dealerView.newRound();
		dealerPoints.text = "";
	}

	public function onCardDraw(view:Container, viewWidth:Float):Void {
		Actuate.tween(view, 1, {x: (width - viewWidth) / 2});
	}

	public function deckCords(view:Container):Point {
		return new Point(deckView.x - view.x, deckView.y - view.y);
	}

	public function onRoundEnd(state:RoundState):Void {
		var text = switch (state) {
			case Win: "You win!";
			case Lose: "You lose!";
			case Draw: "Draw!";
			case Refill: "Deck shuffled!";
			case NoMoney: "Game Over";
		}
		var style = textStyle.clone();
		style.fontSize = 50;
		style.align = "center";

		roundText = new Text(text, style);
		if (state != NoMoney) {
			roundText.interactive = true;
			roundText.buttonMode = true;
		}
		roundText.pointertap = function(e) {
			replayBtn(state);
		};
		roundText.x = (width - roundText.width) / 2;
		roundText.y = (height - roundText.height) / 2;
		addChild(roundText);

		updateDealerPoints();
		if (state == NoMoney) return;

		var text = new Text("Replay", style);
		replay = new Button(Green, text);
		replay.pointertap = function(e) {
			replayBtn(state);
		};
		replay.x = replay.width;
		replay.y = (height - replay.height) / 2;
		addChild(replay);
	}

	function replayBtn(state:RoundState):Void {
		if (state == NoMoney) return;
		removeChild(replay);
		removeChild(roundText);
		onReplay.dispatch(state);
	}

	public function updateDealerPoints():Void {
		if (!dealerView.isOpenHand()) return;
		var points = game.handCount(game.dealer.hand);
		dealerPoints.text = '$points';
		dealerPoints.x = (width - dealerPoints.width) / 2;
		dealerPoints.y = dealerView.y + dealerView.getHeight();
	}

	public function onRefill():Void {
		onRoundEnd(Refill);
		deckView.onDeckRefill();
	}

	public function onGameOver():Void {
		onRoundEnd(NoMoney);
	}

	public function onUpdate(e:Float) {
		if (draw != null) {
			var off = game.getState() == PlayerTurn ? false : true;
			draw.disabled = off;
			end.disabled = off;
			if (!game.player.canDouble) double.disabled = true;
			else double.disabled = off;
		}

		if (playerView.points > 0) {
			playerPoints.text = '${playerView.points}';
		}
		playerView.update();
	}

	public function onResize():Void {
		// initBG();
		final ratio = height / width;
		width = app.renderer.width;
		height = width * ratio;
	}
}
