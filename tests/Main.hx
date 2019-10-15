package ;

import uhx.sys.HtmlEntity;

class Main {

    public static function main() {
        var raw:HtmlEntity = Aacute;
        var codepoints:Array<Int> = Aacute;
        trace( raw );
        trace( codepoints );
        trace( HtmlEntity.getEntity(unifill.InternalEncoding.fromCodePoints(codepoints)) );
        trace( HtmlEntity.has('quote') );
        trace( HtmlEntity.has('&csup;') );
        var value:String = "csup";
        codepoints = csup;  // Remember this is actually `HtmlEntity.csup`.
        trace( HtmlEntity.has( '&' + value + ';' ), value, '\u2AD0', unifill.InternalEncoding.fromCodePoints(codepoints) );
    }

}