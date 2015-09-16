# html-entities

An abstract enum providing all known Html Entities for
autocompletion, returning an array of codepoints, built from
the [whatwg `entities.json`][l1] file.

## Dependencies

To use `html-entities`, you will need to install the following libraries.

1. [klas] - `haxelib git klas https://github.com/skial/klas master src`
2. [cmd] - `haxelib git cmd https://github.com/skial/cmd master src`
3. [unifill] - `haxelib install unifill`
4. [seri] - `haxelib git seri https://github.com/skial/seri master src`

## Installation

1. html-entities - `haxelib git html-entities https://github.com/skial/html-entities master src`
	
Once you have installed `html-entities`, in your project `.hxml` file, add `-lib html-entities`.
	
## Usage

You have two files to work with, `uhx.sys.HtmlEntity` and `uhx.sys.HtmlEntities`.

`HtmlEntity` provides an enum listing all the HTML entity names. The _single_
difference you will find is the entity `&in;` is referenced as `In`, because `in` is
a Haxe keyword. All other entity names are available in the same case.

`HtmlEntities` has four static variables:
	
1. `HtmlEntities.names`: This is an `Array<String>` of all the HTML entity names.
2. `HtmlEntities.values`: This is an `Array<Array<Int>>` of all the HTML entity codepoints.
3. `HtmlEntities.entityMap`: This provides a `StringMap<Array<Int>>` for easier access to an
entities codepoints.
4. `HtmlEntities.codepointMap`: This provides a `Map<Array<Int>, Array<String>>` which
accepts an Array of codepoints as the `key` and returns all the entity names that share
the same codepoints.

`HtmlEntities.names` and `HtmlEntities.values` are equal length, with each value having the
same Array `index` with the oposite Array.

[l1]: https://html.spec.whatwg.org/multipage/entities.json
[klas]: https://github.com/skial/klas
[cmd]: https://github.com/skial/cmd
[seri]: https://github.com/skial/seri
[unifill]: https://github.com/mandel59/unifill