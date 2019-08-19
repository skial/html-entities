package uhx.sys;

typedef HtmlEntity = #if !java
    uhx.sys.html.std.HtmlEntity
#else
    uhx.sys.html.java.HtmlEntity
#end;