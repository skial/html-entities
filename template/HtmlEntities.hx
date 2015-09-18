package uhx.sys;

import haxe.ds.StringMap;
import uhx.sys.HtmlEntity;

/**
 * ...
 * @author Skial Bainn
 */
class HtmlEntities {

	public static var names:Array<HtmlEntity> = [
		$names
	];
	
	public static var values:Array<Array<Int>> = [
		$values
	];
	
	public static var entityMap:StringMap<Array<Int>> = [
		$entityMap
	];
	
	public static var codepointMap:StringMap<Array<HtmlEntity>> = [
		$codepointMap
	];
	
}