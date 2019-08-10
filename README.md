# html-entities

An abstract enum providing all known Html Entities for
autocompletion, returning an array of codepoints, built from
the [whatwg `entities.json`][l1] file.

## Installation

`lix install gh:skial/html-entities`

## Example

```Haxe
import uhx.sys.HtmlEntity;

class Main {

    public static function main() {
        var raw:HtmlEntity = Aacute;
        var codepoints:Array<Int> = Aacute;
        trace( raw );   // &Aacute;
        trace( codepoints );    // [193]
        trace( HtmlEntity.exists('quote') );    // false
        trace( HtmlEntity.exists('&csup;') );   // true
        var value:String = "csup";
        codepoints = csup;
        trace( 
            HtmlEntity.exists( '&' + value + ';' ), // true
            value, // csup
            '\u2AD0', // ⫐
            unifill.InternalEncoding.fromCodePoints(codepoints) // ⫐
        );
    }

}
```
	
## API

#### [`HtmlEntity`][l2]

`HtmlEntity` provides an enum listing all the HTML entity names from [`entities.json`][l4].
The _single_ difference is the entity `&in;`, which is referenced as `In`. 
This is because `in` is a Haxe keyword. 

All other entity names are available in the their original case.

## Rebuilding

Run `haxe build.template.hxml` with `-D dryrun` to test everything compiles without overwriting anything. Then `-D save` to save the output.

[l1]: https://html.spec.whatwg.org/multipage/entities.json
[l2]: https://github.com/skial/html-entities/blob/master/src/uhx/sys/HtmlEntity.hx
[l4]: https://github.com/skial/html-entities/blob/master/resources/entities.json