package uhx.sys;

import uhx.sys.seri.CodePoint;
import unifill.CodePointIter;
import unifill.InternalEncoding;

/**
 * ...
 * @author Skial Bainn
 * Names and codepoint values built from https://html.spec.whatwg.org/multipage/entities.json
 */
@:forward(iterator) @:enum abstract HtmlEntity(Array<Int>) from Array<Int> to Array<Int> {
	
	@:from public static inline function fromCodePoint(codepoint:CodePoint):Array<Int> {
		return [codepoint.toInt()];
	}
	
	@:from public static inline function fromCodePoints(codepoints:Array<CodePoint>):Array<Int> {
		return [for (codepoint in codepoints) codepoint.toInt()];
	}
	
	@:from public static inline function fromString(value:String):Array<Int> {
		return Helper.fromHtml( value );
	}
	
	@:to public inline function toCodePoints():Array<CodePoint> {
		return [for (i in this) CodePoint.fromInt(i)];
	}
	
	@:to public inline function toString():String {
		return InternalEncoding.fromCodePoints( this );
	}
	
	public inline function toHtmlEntity():String {
		return Helper.toHtml( this );
	}
	
	/**
	 * The following values are built from the
	 * file `entities.json` found in the `resources` folder.
	 */
	
	$values
}

private class Helper {
	
	public static function fromHtml(value:String):Array<Int> {
		return switch(value) {
			$fromCases
			case _: [for (codepoint in new CodePointIter( value )) codepoint.toInt()];
		}
	}
	
	public static function toHtml(codepoints:Array<Int>):String {
		return switch (codepoints) {
			$toCases
			case _: InternalEncoding.fromCodePoints( codepoints );
		}
	}
	
}