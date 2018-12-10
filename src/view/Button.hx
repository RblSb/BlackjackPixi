package view;

import pixi.core.display.Container;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
import pixi.core.text.TextStyle;
import pixi.core.textures.Texture;
import pixi.core.utils.Utils.TextureCache;

enum abstract ButtonColor(String) {
	var Blue = "blue";
	var Green = "green";
	var Red = "red";
	var Yellow = "yellow";
}

enum abstract ButtonState(String) {
	var Disabled = "disabled";
	var Glow = "glow";
	var Over = "over";
	var PressDisabled = "press_disabled";
	var Press = "press";
	var Release = "release";
}

class Button extends Container {
	public var disabled(default, set) = false;

	var state:ButtonState = Release;
	var color:ButtonColor;
	var bg:Sprite;
	var text:Text;

	public function new(color:ButtonColor, text:Text) {
		super();
		this.color = color;
		bg = new Sprite(getTexture());
		addChild(bg);
		this.text = text;
		text.x = width / 2 - text.width / 2;
		text.y = height / 2 - text.height / 2;
		addChild(text);
		buttonMode = true;
		interactive = true;

		pointerdown = function(e) {
			state = Press;
			if (disabled) state = PressDisabled;
			update();
		}

		pointerup = function(e) {
			state = Over;
			if (disabled) state = Disabled;
			update();
		}

		pointerover = function(e) {
			state = Over;
			if (disabled) state = Disabled;
			update();
		}

		pointerout = function(e) {
			state = Release;
			if (disabled) state = Disabled;
			update();
		}
	}

	function set_disabled(b:Bool):Bool {
		if (disabled == b) return b;
		disabled = b;
		if (b) disable();
		else enable();
		return b;
	}

	function update():Void {
		text.alpha = disabled ? 0.5 : 1;
		bg.texture = getTexture();
	}

	function enable():Void {
		state = Release;
		update();
	}

	function disable():Void {
		state = Disabled;
		update();
	}

	function getTexture():Texture {
		return TextureCache[cast 'btn_${color}_$state'];
	}
}
