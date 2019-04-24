# html-entities

An abstract enum providing all known Html Entities for
autocompletion, returning an array of codepoints, built from
the [whatwg `entities.json`][l1] file.

## Installation

`lix install gh:skial/html-entities`

## Example

```Haxe
package ;

import uhx.sys.HtmlEntity;

class Main {

    public static function main() {
        var raw:HtmlEntity = Aacute;
        var codepoints:Array<Int> = raw;
        trace( raw );   // &Aacute;
        trace( codepoints );    // [193]
    }

}
```
	
## API

#### [`HtmlEntity`][l2]

`HtmlEntity` provides an enum listing all the HTML entity names from [`entities.json`][l4].
The _single_ difference is the entity `&in;`, which is referenced as `In`. 
This is because `in` is a Haxe keyword. 

All other entity names are available in the their original case.

[l1]: https://html.spec.whatwg.org/multipage/entities.json
[l2]: https://github.com/skial/html-entities/blob/master/src/uhx/sys/HtmlEntity.hx
[l4]: https://github.com/skial/html-entities/blob/master/resources/entities.json