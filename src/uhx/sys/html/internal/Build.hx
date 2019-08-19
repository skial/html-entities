package uhx.sys.html.internal;

import haxe.Utf8;
import haxe.Json;
import haxe.Template;
import haxe.ds.ArraySort;
import haxe.DynamicAccess;

using Lambda;
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

@:nullSafety(Strict) class Build {
	
	private static var keywords = ['in' => 'In'];
	
	public static function extract() {
		var cwd = Sys.getCwd();
		var template = '$cwd/template/Abstract.hx'.normalize();
		var javaProperties = '$cwd/template/JavaTpl.properties'.normalize();
		var javaTpl = '$cwd/template/JavaAbstract.hx'.normalize();
		var json = '$cwd/resources/entities.json'.normalize();
		
		if (template.exists() && json.exists()) {
			var data:DynamicAccess<JsonData> = Json.parse( json.getContent() );
			var names = [for (key in data.keys()) key.substring(1, key.length - 1)];

			ArraySort.sort( names, alphaSort );

			var fields:Array<TemplateCtx> = [for (name in names) {
				var value = '&${name};';
				var info = data.get(value);
				if (keywords.exists(name)) name = keywords.get(name);

				// There appears to be an issue printing `info.characters` in eval mode.
				{
					ident: name,
					value: value,
					codepoints: info.codepoints,
					characters: info.characters,
				};
			}];

			// Generate the Haxe abstract type.
			var abs = template.getContent();
			var tpl = new Template(abs);
			var out = tpl.execute({fields:fields, typeName:'HtmlEntity'});
			// Generate the Java properties file.
			var abs = javaProperties.getContent();
			var tpl = new Template(abs);
			var javaProps = tpl.execute({
				fields:fields
					.map( f -> {ident:f.ident, value:f.value, characters:f.characters, codepoints:f.codepoints.join(',')}), 
				typeName:'HtmlEntity'
			});
			var abs = javaTpl.getContent();
			var tpl = new Template(abs);
			var javaAbs = tpl.execute({fields:fields, typeName:'HtmlEntity'});

			if (DryRun) {
				trace( out );
				trace( javaAbs );
				trace( javaProps );
			} else if (Save) {
				var output = '$cwd/src/uhx/sys/html/std/HtmlEntity.hx'.normalize();
				var javaout = '$cwd/src/uhx/sys/html/java/HtmlEntity.hx'.normalize();
				var javaprops = '$cwd/src/uhx/sys/html/java/HtmlEntity.properties'.normalize();
				output.saveContent( out );
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