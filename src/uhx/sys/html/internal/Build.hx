package uhx.sys.html.internal;

import haxe.Json;
import haxe.Template;
import haxe.ds.ArraySort;
import haxe.DynamicAccess;
import uhx.sys.seri.CodePoint;
import uhx.sys.seri.builder.Extract;

using StringTools;
using sys.io.File;
using haxe.io.Path;
using sys.FileSystem;

enum abstract Defines(String) {
	public var DryRun = 'dryrun';
	public var Save = 'save';

	@:to public inline function defined():Bool {
		return haxe.macro.Context.defined(this);
	}
}

typedef JsonData = {
	var codepoints:Array<Int>;
	var characters:String;
}

typedef TemplateCtx = JsonData & {
	var ident:String;
	var value:String;
}

@:nullSafety(Strict) class Build {
	
	private static var keywords = ['in' => 'In'];
	private static var types = ['Int', 'Map', 'Lambda'];
	
	private static function fix(value:String):String {
		return if (keywords.exists( value )) {
			keywords.get( value );
			
		} else if (types.indexOf( value ) > -1) {
			'HtmlEntity.$value';
			
		} else {
			value;
			
		}
	}
	
	public static function extract() {
		var cwd = Sys.getCwd();
		var template = '$cwd/template/Abstract.hx'.normalize();
		var json = '$cwd/resources/entities.json'.normalize();
		
		if (template.exists() && json.exists()) {
			var data:DynamicAccess<JsonData> = Json.parse( json.getContent() );
			var names = [for (key in data.keys()) key.substring(1, key.length - 1)];

			ArraySort.sort( names, @:privateAccess Extract.alphaSort );

			var fields:Array<TemplateCtx> = [for (name in names) {
				var value = '&${name};';
				var info = data.get(value);
				if (keywords.exists(name)) name = keywords.get(name);

				// There appears to be an issue printing `info.characters` in eval mode.
				{
					ident: name,
					value: value,
					codepoints: info.codepoints,
					characters: info.characters,
				};
			}];

			var abs = template.getContent();
			var tpl = new Template(abs);
			var out = tpl.execute({fields:fields, typeName:'HtmlEntity'});

			if (DryRun) {
				trace( out );
			} else if (Save) {
				var output = '$cwd/src/uhx/sys/HtmlEntity.hx'.normalize();
				output.saveContent( out );

			}
			
		}

	}
	
}