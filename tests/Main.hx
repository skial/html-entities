package ;

import uhx.sys.HtmlEntity;

class Main {

    public static function main() {
        var raw:HtmlEntity = Aacute;
        var codepoints:Array<Int> = raw;
        trace( raw );
        trace( codepoints );
    }

}