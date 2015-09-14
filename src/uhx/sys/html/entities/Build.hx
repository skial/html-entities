package uhx.sys.html.entities;

import haxe.Json;
import haxe.DynamicAccess;
import uhx.sys.seri.CodePoint;

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
	
	public static function template() {
		var template = '${Sys.getCwd()}/template/HtmlEntity.hx'.normalize();
		var json = '${Sys.getCwd()}/resources/entities.json'.normalize();
		
		if (template.exists() && json.exists()) {
			template = template.getContent();
			var data:DynamicAccess<JsonData> = Json.parse( json.getContent() );
			
			
			
		}
		
		// Something needs to be returned.
		return macro null;
	}
	
}