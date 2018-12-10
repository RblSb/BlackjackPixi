package view;

import model.Card;
import motion.Actuate;
import motion.easing.Linear;
import pixi.core.display.Container;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.core.utils.Utils.TextureCache;

class CardView extends Container {
	var sprite:Sprite;
	var card:Card;

	public function new(card:Card) {
		super();
		this.card = card;
		var path = getTexturePath(card);
		var img = TextureCache[cast path];
		var tex = card.isOpen ? img : TextureCache[cast Res.back];
		sprite = new Sprite(tex);
		addChild(sprite);
	}

	function getTexturePath(card:Card):String {
		var suit = switch (card.suit) {
			case Pika: "pika";
			case Hearts: "hearts";
			case Clover: "clover";
			case Diam: "diam";
		}
		var type = switch (card.type) {
			case Ace: 12;
			default: card.type - 1;
		}
		return '${suit}_$type';
	}

	function showCard():Void {
		var path = getTexturePath(card);
		var img = TextureCache[cast path];
		sprite.texture = img;
	}

	public function hide():Void {
		sprite.texture = TextureCache[cast Res.back];
	}

	public function show():Void {
		if (sprite.texture != TextureCache[cast Res.back]) return;
		var tintSpeed = 0x10101 * 5;
		var time = 0.3;
		Actuate.tween(sprite, time, {x: sprite.width / 2}).ease(Linear.easeNone).onUpdate(function() {
			if (sprite.tint - tintSpeed > 0) sprite.tint -= tintSpeed;
		});

		Actuate.tween(sprite.scale, time, {x: 0}).ease(Linear.easeNone).onComplete(function() {
			showCard();

			Actuate.tween(sprite, time, {x: 0}).ease(Linear.easeNone).onUpdate(function() {
				if (sprite.tint + tintSpeed < 0xFFFFFF) sprite.tint += tintSpeed;
			}).onComplete(function() {
				sprite.tint = 0xFFFFFF;
			});

			Actuate.tween(sprite.scale, time, {x: 1}).ease(Linear.easeNone);
		});
	}
}
