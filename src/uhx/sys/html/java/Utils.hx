package uhx.sys.html.java;

#if (macro || eval)
import haxe.macro.Expr;
import haxe.macro.Context;
#end

class Utils {

    public static macro function propertiesLoader():Expr {
        Context.addResource(
            'HtmlEntity.properties', 
            sys.io.File.getBytes(Context.resolvePath('uhx/sys/html/java/HtmlEntity.properties'))
        );
        return macro haxe.Resource.getString('HtmlEntity.properties');
    }

}