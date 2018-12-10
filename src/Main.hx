package;

import controller.GameController;
import js.Browser.document;
import js.Browser.window;
import pixi.core.Application;
import pixi.loaders.Loader;
import view.GameView;

class Main {
	static function main() {
		final loader = new Loader();
		loader.add("/res.json").load(onLoad);
	}

	static function onLoad():Void {
		final app = new Application({
			width: window.innerWidth,
			height: window.innerHeight,
			transparent: false,
			autoStart: true,
			antialias: false,
			backgroundColor: 0x007030,
			resizeTo: window
		});
		document.body.appendChild(app.view);

		var game = new model.Game();
		var gameView = new GameView(app, game);
		var gameController = new GameController(game, gameView);
		app.stage.addChild(gameView);
	}
}
