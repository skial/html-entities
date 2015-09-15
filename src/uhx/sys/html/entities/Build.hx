package uhx.sys.html.entities;

import haxe.Json;
import haxe.DynamicAccess;
import uhx.sys.seri.CodePoint;
import uhx.sys.seri.Build.characters;
import uhx.sys.seri.Build.maxCharacters;
import uhx.sys.seri.Build.pretty;
import uhx.sys.seri.Build.quoted;
import uhx.sys.seri.Build.alphaSort;

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
		var htmlentity = '${Sys.getCwd()}/template/HtmlEntity.hx'.normalize();
		var htmlentities = '${Sys.getCwd()}/template/HtmlEntities.hx'.normalize();
		var json = '${Sys.getCwd()}/resources/entities.json'.normalize();
		
		if (htmlentity.exists() && htmlentities.exists() && json.exists()) {
			htmlentity = htmlentity.getContent();
			htmlentities = htmlentities.getContent();
			var data:DynamicAccess<JsonData> = Json.parse( json.getContent() );
			var names = alphaSort( [for (key in data.keys()) key.substring(1, key.length - 1)], true );
			var fields = [for (name in names) {
				var pair = data.get( '&$name;' );
				'var $name = ' + pair.codepoints + ';';
			}];
			
			var toCases = [for (name in names) {
				'case ' + data.get( '&$name;' ).codepoints + ': "&$name;";';
			}];
			
			var fromCases = [for (name in names) {
				'case "&$name;": ' + data.get( '&$name;' ).codepoints + ';';
			}];
			
			htmlentity = htmlentity.replace( "$values", fields.join('\n\t') );
			htmlentity = htmlentity.replace( "$toCases", toCases.join('\n\t\t\t') );
			htmlentity = htmlentity.replace( "$fromCases", fromCases.join('\n\t\t\t') );
			
			characters = 0;
			htmlentities = htmlentities.replace( "$names", names.map( quoted ).map( pretty ).join(', ').replace('\n\t\t,', ',\n\t\t') );
			
			characters = 0;
			htmlentities = htmlentities.replace( "$values", [for (name in names) data.get('&$name;').codepoints.toString()].map( pretty ).join(', ').replace('\n\t\t,', ',\n\t\t') );
			
			var output = '${Sys.getCwd()}/src/uhx/sys/HtmlEntity.hx'.normalize();
			output.saveContent( htmlentity );
			
			output = '${Sys.getCwd()}/src/uhx/sys/HtmlEntities.hx'.normalize();
			output.saveContent( htmlentities );
		}
		
		// Something needs to be returned.
		return macro null;
	}
	
}