package ;

import uhx.sys.HtmlEntity;

class Main {

    public static function main() {
        var raw:HtmlEntity = Aacute;
        var codepoints:Array<Int> = Aacute;
        trace( raw );
        trace( codepoints );
        #if !(java || jvm) trace( HtmlEntity.getEntity(unifill.InternalEncoding.fromCodePoints(codepoints)) ); #end
        trace( HtmlEntity.has('quote') );
        trace( HtmlEntity.has('&csup;') );
        var value:String = "csup";
        codepoints = csup;
        trace( HtmlEntity.has( '&' + value + ';' ), value, '\u2AD0', unifill.InternalEncoding.fromCodePoints(codepoints) );
    }

}