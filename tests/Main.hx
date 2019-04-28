package ;

import uhx.sys.HtmlEntity;

class Main {

    public static function main() {
        var raw:HtmlEntity = Aacute;
        var codepoints:Array<Int> = Aacute;
        trace( raw );
        trace( codepoints );
        trace( HtmlEntity.exists('quote') );
        trace( HtmlEntity.exists('&csup;') );
        var value:String = "csup";
        codepoints = csup;
        trace( HtmlEntity.exists( '&' + value + ';' ), value, '\u2AD0', unifill.InternalEncoding.fromCodePoints(codepoints) );
    }

}