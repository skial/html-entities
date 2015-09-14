package uhx.sys.html.entities;

import haxe.Json;
import haxe.DynamicAccess;
import uhx.sys.seri.CodePoint;

using StringTools;
using sys.io.File;
using haxe.io.Path;
using sys.FileSystem;

typedef JsonData = {
	var codepoints:Array<CodePoint>;
	var characters:String;
}

/**
 * ...
 * @author Skial Bainn
 */
class Build {
	
	@:access(uhx.sys.seri.Build) public static function template() {
		var template = '${Sys.getCwd()}/template/HtmlEntity.hx'.normalize();
		var json = '${Sys.getCwd()}/resources/entities.json'.normalize();
		
		if (template.exists() && json.exists()) {
			template = template.getContent();
			var data:DynamicAccess<JsonData> = Json.parse( json.getContent() );
			var names = uhx.sys.seri.Build.alphaSort( [for (key in data.keys()) key.substring(1, key.length - 1)], true );
			var fields = [for (name in names) {
				trace( '&$name;' );
				var pair = data.get( '&$name;' );
				'var $name = ' + pair.codepoints + ';';
			}];
			
			template = template.replace( "$values", fields.join('\n\t') );
			
			var output = '${Sys.getCwd()}/src/uhx/sys/HtmlEntity.hx'.normalize();
			output.saveContent( template );
		}
		
		// Something needs to be returned.
		return macro null;
	}
	
}