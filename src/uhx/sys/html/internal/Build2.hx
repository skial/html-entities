package uhx.sys.html.internal;

import haxe.macro.Context;
import haxe.Json;
import haxe.Template;
import haxe.ds.ArraySort;
import haxe.DynamicAccess;

using Lambda;
using hash.Mph;
using StringTools;
using sys.io.File;
using haxe.io.Path;
using sys.FileSystem;

enum abstract Defines(String) {
    public var DryRun = 'dryrun';
    public var Save = 'save';

    @:to public inline function defined():Bool {
        return haxe.macro.Context.defined(this);
    }
}

typedef JsonData = {
    var codepoints:Array<Int>;
    var characters:String;
}

typedef TemplateCtx = JsonData & {
    var ident:String;
    var value:String;
}

class Build2 {
    
    private static var keywords = ['in' => 'In'];
    private static var printer = new haxe.macro.Printer();
    public static function main() extract();
    public static function extract() {
        var cwd = Sys.getCwd();
        var json = '$cwd/resources/entities.json'.normalize();
        
        if (json.exists()) {
            var data:DynamicAccess<JsonData> = Json.parse( json.getContent() );
            var names:Array<String> = [];
            var map:Map<String, Array<Int>> = [];
            var reverse:Map<String, String> = [];
            var size = 0;

            for (key => value in data) {
                var _key = key.substring(1, key.length - 1);
                names.push( _key );
                map.set( _key, value.codepoints );

                var _char = unifill.InternalEncoding.fromCodePoints(value.codepoints);

                if (!reverse.exists(_char)) {
                    reverse.set( _char, _key );

                } else {
                    var value = reverse.get(_char);
                    if (_key.length < value.length) {
                        reverse.set( _char, _key );
                    }

                }

                size++;
            }

            /**
                Sorts an array: 
                    `["Zcy", "Aff", "Bbb", "Abcdef"]`

                and returns:
                    `["Aff", "Abcdef", "Bbb", "Zcy"]`

            **/
            ArraySort.sort( names, alphaSort );

            /**
                Store the starting index of the first alphabetical character as there is 2k+ entities.
            **/
            var startingPoints:{ chars:Array<String>, indexes:Array<Int> } = { chars:[], indexes:[] };
            for (index in 0...names.length) {
                var name = names[index];
                var char = name.charAt(0);

                if (startingPoints.chars.indexOf(char) == -1) {
                    var code = char.charCodeAt(0);
                    startingPoints.chars.push(char);
                    startingPoints.indexes.push(index);

                }

            }

            if (startingPoints.chars.length != startingPoints.indexes.length) {
                Context.fatalError('startingPoints chars and index are not equal lengths. Generation Failure.', Context.currentPos());
            }

            var mph = new hash.Mph();
            var table = mph.build(map, hash.Mph.HashString, size);
            trace( reverse );

            // The reverse table size doesnt equal table size, as 
            // there are multiple entities to a set of codepoints.
            var reverseTable = mph.build(reverse, hash.Mph.HashString);

            var tmp = macro class HtmlEntityImpl {
                private static var mph:hash.Mph = new hash.Mph();
                private static var knownNames:Array<String> = [$a{names.map( s -> macro $v{s} )}];
                private static var knownStartingCharacters:Array<String> = [$a{startingPoints.chars.map( s -> macro $v{s} )}];
                private static var knownStartingIndexes:Array<Int> = [$a{startingPoints.indexes.map( i -> macro $v{i} )}];
                private static var table:hash.Mph.Table<Int, Array<Int>> = $e{ table.asExpr() };
                private static var reverse:hash.Mph.Table<Int, Int> = $e{ reverseTable.asExpr(s -> macro $v{names.indexOf(s)}) };

                // Checks if `value` is a valid html entity name.
                public static function has(value:String):Bool {
                    var _value = value;
                    
                    if (value.startsWith('&')) _value = _value.substring(1);
                    if (value.endsWith(';')) _value = _value.substring(0, _value.length-1);
                    
                    var char = _value.charAt(0);
                    var charIndex = knownStartingCharacters.indexOf(char);
                    if (charIndex == -1) return false;

                    var startIndex = knownStartingIndexes[charIndex];
                    var hasValue = knownNames.indexOf(_value, startIndex) != -1;

                    return hasValue;
                }

                // Get an array of codepoints for a valid html entity.
                public static function getCodePoints(name:String):Null<Array<Int>> {
                    var result = try {
                        mph.get(table, name, hash.Mph.HashString);

                    } catch (e:Any) {
                        null;

                    }

                    return result;
                }

                // Get an html entity for a valid character.
                public static function getEntity(character:String):Null<HtmlEntity> {
                    var result = try {
                        knownNames[mph.get(reverse, character, hash.Mph.HashString)];

                    } catch (e:Any) {
                        null;

                    }

                    return cast result;
                }
            }

            /**
                Handle java/jvm specific files.
            **/
            var javaProperties = '$cwd/template/JavaTpl.properties'.normalize();
            var javaTpl = '$cwd/template/JavaAbstract.hx'.normalize();
            var fields:Array<TemplateCtx> = [for (name in names) {
                var value = name;
                var info = data.get('&$value;');
                if (keywords.exists(name)) name = keywords.get(name);

                // There appears to be an issue printing `info.characters` in eval mode.
                {
                    ident: name,
                    value: value,
                    codepoints: info.codepoints,
                    characters: info.characters,
                };
            }];

            if (DryRun) {
                trace( printer.printTypeDefinition(tmp) );
                /**
                    Run Java/JVM templates.
                **/
                var abs = javaProperties.getContent();
                var tpl = new Template(abs);
                var javaProps = tpl.execute({
                    fields:fields
                        .map( f -> {ident:f.ident, value:f.value, characters:f.characters, codepoints:f.codepoints.join(',')}), 
                    typeName:'HtmlEntity',
                    entities: [for (key => value in reverse) {key:key, value:value}],
                });
                var abs = javaTpl.getContent();
                var tpl = new Template(abs);
                var javaAbs = tpl.execute({fields:fields, typeName:'HtmlEntity'});

            } else if (Save) {
                var buffer = new StringBuf();
                buffer.add( "package uhx.sys.html.std;" );
                buffer.add( '\n' );
                buffer.add( '/**
    ------
    DO NOT EDIT THIS FILE
    ------
    This file has be auto-generated.
    Names and codepoint values built from https://html.spec.whatwg.org/multipage/entities.json
**/' );
                buffer.add( '\n' );
                buffer.add( 'using StringTools;' );
                buffer.add( '\n' );
                buffer.add( 'enum abstract HtmlEntity(String) {\n' );
                buffer.add( '\t@:to public inline function toString():String return \'&$$this;\';\n' );
                buffer.add( '\tpublic static inline function all():Array<String> return @:privateAccess HtmlEntityImpl.knownNames;\n' );
                buffer.add( '\tpublic static inline function has(value:String):Bool return HtmlEntityImpl.has(value);\n' );
                buffer.add( '\tpublic static inline function getCodePoints(value:String):Null<Array<Int>> return HtmlEntityImpl.getCodePoints(value);\n' );
                buffer.add( '\tpublic static inline function getEntity(value:String):Null<HtmlEntity> return HtmlEntityImpl.getEntity(value);\n' );
                buffer.add( '\t@:to public inline function asCodePoints():Array<Int> {\n' );
                buffer.add( '\t\tvar r = HtmlEntityImpl.getCodePoints(this);\n' );
                buffer.add( '\t\treturn r != null ? r : [];\n' );
                buffer.add( '\t}\n' );
                for (name in names) {
                    var id = name;
                    if (keywords.exists(name)) id = keywords.get(name);
                    buffer.add( '\tpublic var $id = "$name";\n' );
                }
                buffer.add( '}\n' );
                buffer.add( '\n' );
                buffer.add( printer.printTypeDefinition(tmp) );

                var output = '$cwd/src/uhx/sys/html/std/HtmlEntity.hx'.normalize();
                output.saveContent( buffer.toString() );

                /**
                    Run Java/JVM templates.
                **/
                var abs = javaProperties.getContent();
                var tpl = new Template(abs);
                var javaProps = tpl.execute({
                    fields:fields
                        .map( f -> {ident:f.ident, value:f.value, characters:f.characters, codepoints:f.codepoints.join(',')}), 
                    typeName:'HtmlEntity',
                    entities: [for (key => value in reverse) {key:key, value:value}],
                });
                var abs = javaTpl.getContent();
                var tpl = new Template(abs);
                var javaAbs = tpl.execute({fields:fields, typeName:'HtmlEntity'});
                var javaout = '$cwd/src/uhx/sys/html/java/HtmlEntity.hx'.normalize();
                var javaprops = '$cwd/src/uhx/sys/html/java/HtmlEntity.properties'.normalize();

                javaout.saveContent( javaAbs );
                javaprops.saveContent( javaProps );
            }
            
        }

    }

    private static function alphaSort(a:String, b:String) {
        var aCode = a.charCodeAt(0);
        var bCode = b.charCodeAt(0);
        
        if (aCode >= 'a'.code && aCode <= 'z'.code) {
            aCode -= 32;
        } else if (aCode >= 'A'.code && aCode <= 'Z'.code) {
            aCode += 32;
        }
        if (bCode >= 'a'.code && bCode <= 'z'.code) {
            bCode -= 32;
        } else if (bCode >= 'A'.code && bCode <= 'Z'.code) {
            bCode += 32;
        }

        return if (aCode == bCode) {
            if (a.length > b.length) {
                1;

            } else if (a.length < b.length) {
                -1;

            } else if (a.length > 1 && b.length > 1) {
                var _a = totalValue(a);
                var _b = totalValue(b);

                if (_a == _b) {
                    0;
                } else if (_a > _b) {
                    1;
                } else {
                    -1;
                }
                
            } else {
                0;

            }

        } else if (aCode > bCode) {
            1;

        } else {
            -1;

        }

    }

    private static function totalValue(value:String):Int {
        return value
            .split('')
            .map( s -> s.charCodeAt(0) )
            .map( i -> if (i >= 'a'.code && i <= 'z'.code) {
                i-= 32;
            } else if (i >= 'A'.code && i <= 'Z'.code) {
                i+= 32;
            } else {
                i;
            } )
            .fold( (v, c)-> c+=v, 0 );
    }
    
}