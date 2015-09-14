package uhx.sys.html.entities;

import uhx.sys.Ioe;

/**
 * ...
 * @author Skial Bainn
 */
@:cmd
class LibRunner extends Ioe {
	
	public static function main() {
		var command = new LibRunner( Sys.args() );
	}

	public function new(args:Array<String>) {
		
	}
	
}