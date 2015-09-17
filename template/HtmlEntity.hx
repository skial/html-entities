package uhx.sys;

/**
 * ...
 * @author Skial Bainn
 * Names and codepoint values built from https://html.spec.whatwg.org/multipage/entities.json
 */
@:forward @:enum abstract HtmlEntity(String) from String to String {
	
	public inline function encode(?useNames:Bool = false):String {
		return if (useNames && HtmlEntities.entityMap.exists( this )) { 
			'&$this;';
			
		} else {
			[for (codepoint in HtmlEntities.entityMap.get( this )) StringTools.hex(codepoint)]
				.map( function(s) return '&#x$s;').join('');
			
		}
	}
	
	$values
}