package internal;

import haxe.Json;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

#if macro
import sys.io.File;
#end

class AssetsBuilder {
	@:persistent static final matchChars = ~/[^0-9A-z_]/g;
	@:persistent static final startsWithNumber = ~/^[0-9]/g;

	macro public static function buildRes():Array<Field> {
		final fields = Context.getBuildFields();
		if (fields.length != 0) return fields;
		final path = Context.definedValue("res");
		if (path == null) return [];
		final pos = Context.currentPos();
		final json = Json.parse(File.getContent(path));
		final frames:Iterable<Dynamic> = Reflect.fields(json.frames);
		for (filename in frames) {
			var name = matchChars.replace(filename, "_").toLowerCase();
			if (startsWithNumber.match(name)) name = '_$name';
			fields.push({
				name: name,
				access: [APublic, AStatic, AInline],
				kind: FVar(macro:String, macro $v{filename}),
				pos: pos
			});
		}
		return fields;
	}

	macro public static function buildAudio():Array<Field> {
		final fields = Context.getBuildFields();
		if (fields.length != 0) return fields;
		final path = Context.definedValue("audiores");
		if (path == null) return [];
		final pos = Context.currentPos();
		final json = Json.parse(File.getContent(path));
		final names:Array<String> = Reflect.fields(json.spritemap);
		for (file in names) {
			var name = matchChars.replace(file, "_").toLowerCase();
			if (startsWithNumber.match(name)) name = '_$name';
			fields.push({
				name: name,
				access: [APublic, AStatic],
				kind: FVar(macro:String, macro $v{file}),
				pos: pos
			});
		}
		return fields;
	}
}
