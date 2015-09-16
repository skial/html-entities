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
	var codepoints:Array<Int>;
	var characters:String;
}

/**
 * ...
 * @author Skial Bainn
 */
class Build {
	
	private static var keywordsFix = ['in' => 'In'];
	private static var keywordsUnfix = ['In' => 'in'];
	private static var types = ['Int', 'Map', 'Lambda'];
	
	private static function fix(value:String):String {
		return if (keywordsFix.exists( value )) {
			keywordsFix.get( value );
			
		} else if (types.indexOf( value ) > -1) {
			'HtmlEntity.$value';
			
		} else {
			value;
			
		}
	}
	
	private static function unfix(value:String):String {
		return if (keywordsUnfix.exists( value )) {
			keywordsUnfix.get( value );
			
		} else if (value.startsWith( 'HtmlEntity.' )) {
			value.substring(11);
			
		} else {
			value;
			
		}
	}
	
	public static function template() {
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
				var id = keywordsFix.exists( name ) ? keywordsFix.get( name ) : name;
				'public var $id = "$name";';
			}];
			
			var valueMap = new Map<String, Array<String>>();
			for (name in names) {
				var info = data.get( '&$name;' );
				
				if (!valueMap.exists( info.codepoints.map( Std.string ).join(',') )) {
					valueMap.set( info.codepoints.map( Std.string ).join(','), [fix(name)] );
					
				} else {
					var ids = valueMap.get( info.codepoints.map( Std.string ).join(',') );
					ids.push( fix(name) );
					valueMap.set( info.codepoints.map( Std.string ).join(','), ids );
					
				}
				
			}
			
			var entityMap = [for (name in names) {
				'"$name" => ' + data.get( '&$name;' ).codepoints;
			}];
			
			var codepointMap = [for (key in valueMap.keys()) {
				'[$key] => ' + valueMap.get( key );
			}];
			
			htmlentity = htmlentity.replace( "$values", fields.join('\n\t') );
			
			characters = 0;
			htmlentities = htmlentities.replace( "$names", names.map( fix ).map( pretty ).join(', ').replace('\n\t\t,', ',\n\t\t') );
			
			characters = 0;
			htmlentities = htmlentities.replace( "$values", [for (name in names) data.get('&$name;').codepoints.toString()].map( pretty ).join(', ').replace('\n\t\t,', ',\n\t\t') );
			
			characters = 0;
			htmlentities = htmlentities.replace( "$entityMap", entityMap.map( pretty ).join(', ').replace('\n\t\t,', ',\n\t\t') );
			
			characters = 0;
			htmlentities = htmlentities.replace( "$codepointMap", codepointMap.map( pretty ).join(', ').replace('\n\t\t,', ',\n\t\t') );
			
			var output = '${Sys.getCwd()}/src/uhx/sys/HtmlEntity.hx'.normalize();
			output.saveContent( htmlentity );
			
			output = '${Sys.getCwd()}/src/uhx/sys/HtmlEntities.hx'.normalize();
			output.saveContent( htmlentities );
		}
		
		// Something needs to be returned.
		return macro null;
	}
	
}