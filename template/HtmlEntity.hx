package uhx.sys;

import uhx.sys.seri.CodePoint;
import unifill.CodePointIter;
import unifill.InternalEncoding;

/**
 * ...
 * @author Skial Bainn
 * Names and codepoint values built from https://html.spec.whatwg.org/multipage/entities.json
 */
@:forward @:enum abstract HtmlEntity(String) from String to String {
	
	public inline function toHtmlEntity():String {
		return '&$this;';
	}
	
	/**
	 * The following values are built from the
	 * file `entities.json` found in the `resources` folder.
	 */
	
	$values
}