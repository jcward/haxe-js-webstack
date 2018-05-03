package riot;

#if !macro

import haxe.Constraints.Function;

import js.html.*;

@:native("window.riot")
extern class Riot {
  static var version:String;
  static var settings:Dynamic;
  static function observable(el:Dynamic):Dynamic;
  static function route():Dynamic;
  static var util:Dynamic;
  static function mixin(name:Dynamic, mixin:Dynamic):Dynamic;
  static function tag(name:Dynamic, html:Dynamic, css:Dynamic, attrs:Dynamic, fn:Dynamic):Dynamic;
  static function tag2(name:Dynamic, html:Dynamic, css:Dynamic, attrs:Dynamic, fn:Dynamic):Dynamic;
  static function mount(selector:Dynamic, ?tagName:Dynamic, ?opts:Dynamic):Array<Dynamic>;
  static function update():Dynamic;
  static var vdom:Array<Dynamic>;
  static function Tag(impl:Dynamic, conf:Dynamic, innerHTML:Dynamic):Dynamic;

  // When the compiler is included (riot+compiler.js)
  static function compile(tag:String, dont_load:Bool=false):String;

  public static inline function is<T>(tag:Dynamic, // usually RiotBase<T>
                                      cls_or_interface:Dynamic):Bool
  {
    if (tag==null || cls_or_interface==null) return false;

    // Riot tags are technically mixed in. We have spoofed the __interfaces__ and __super__
    // properties, so interfaces should still work via Std.is...
    if (Std.is(tag, cls_or_interface)) return true;

    // but exact class matching (e.g. Std.is(tag, SomeRiotClass)) fails in Std.is
    // in Std.is, so we try by matching class name...
    // if (Type.getClassName(Type.getClass(tag))==Type.getClassName(cls_or_interface)) return true;

    // Hmm, the above is STILL missing in some cases and depends on __class__
    // stuff working... So finally, if the class has a .TAG_NAME that matches
    // the tag.root.tagName, return true
    if (tag.root!=null && cls_or_interface.TAG_NAME!=null &&
        tag.root.tagName.toLowerCase()==cls_or_interface.TAG_NAME.toLowerCase()) return true;

    return false;
  }
}

@:enum abstract RiotEvent(String) {
  var Update = "update";
  var Updated = "updated";

  // standardized aliases
  var BeforeUpdate = "update";
  var AfterUpdate = "updated";
  var Mount = "mount";

  var BeforeMount = "before-mount";
  var AfterMount = "mount";
  var BeforeUnmount = "before-unmount";
  var AfterUnmount = "unmount";

  var Any = "*";
}

// This is a dummy class, just representing the notion that
// a Haxe Riot class cannot extend anything else.
@:native('Object') @:keepSub
extern class RiotBase<OptsType> implements RiotEnforcer
{
  var root:Element;
  var parent:Element;
  var opts:OptsType;
  var tags:Dynamic;

  function update(?expressions:Array<Dynamic>, ?tag:Dynamic):Void;
  function on(event:RiotEvent, callback:Function):Dynamic;
  function one(event:RiotEvent, callback:Function):Dynamic;
  function unmount():Void;
}

@:autoBuild(riot.Riot.RiotMacro.build())
interface RiotEnforcer { }

#else

import haxe.ds.StringMap;

import sys.io.File;
import sys.FileSystem;

import haxe.macro.*;
using haxe.macro.ExprTools;
using haxe.macro.TypeTools;
using util.ArrayUtil;

class RiotMacro
{
  // Enforce that extenders of RiotBase have a private constructor --
  // due to the "mixin" usage in Riot, the constructor cannot be called
  // in the standard way.
  private static var _known_tags = new StringMap<String>();
  public static function build()
  {
    var fields = haxe.macro.Context.getBuildFields();

    if (Context.definedValue('NORIOT')!=null) return fields;

    var cls = haxe.macro.Context.getLocalClass().get();
    // cls.meta.add(':keep', [], Context.currentPos());
    var is_base = cls.module.indexOf("RiotBase")>=0 || cls.module=='riot.Riot';
    var has_opts_fields = fields.select(function(f) return f.name=='opts_fields').length>0;

    var TAG_NAME:String = '';
    var has_tag_name_field = fields.select(function(f) {
			if (f.name=='TAG_NAME') {
        switch (f.kind) {
          case FVar(t,e): TAG_NAME = ExprTools.getValue(e);
          default: throw 'Expecting TAG_NAME as an FVar...';
        }
			}
			return (f.name=='TAG_NAME' && f.access.indexOf(AStatic)>=0);
		}).length>0;

    if (!is_base && !has_tag_name_field) {
      Context.error('Riot class ${ cls.module } is missing: var static TAG_NAME:String', Context.currentPos());
    } else {
      // TODO: ensure TAG_NAME's are all unique ?
    }

    if (!is_base && !has_opts_fields) {
      
      if (_known_tags.exists(TAG_NAME)) throw 'Duplicate TAG_NAME $TAG_NAME in ${cls.module} and ${ _known_tags.get(TAG_NAME) }';
      _known_tags.set(TAG_NAME, cls.module);
        
      // Store opts field names in a static array...
      var opts_type = cls.superClass.params[0].followWithAbstracts();
      var opts_fields:Array<String> = [];
      switch opts_type {
    		case TAnonymous(a):
          for (field in a.get().fields) opts_fields.push(field.name);
        default: throw 'Riot OptsType param of ${ cls.module } expected to be TAnonymous, found $opts_type';
      }

      var haxe_file = Context.getPosInfos(cls.pos).file;
      var html_file = StringTools.replace(haxe_file, ".hx", ".html");
      var html = sys.io.File.getBytes(html_file).toString();

      // TODO: proper parsing...
      var css = '';
      function splice_css() {
        var style_idx = html.indexOf('<style>');
        if (style_idx>=0) {
          var sc_idx = html.indexOf('</style>');
          css = css + html.substr(style_idx+8, sc_idx-style_idx-8)+"\n";
          var before = style_idx==0 ? '' : html.substr(0,style_idx);
          var after = html.substr(sc_idx+8);
          html = before+after;
        }
      }
      while (html.indexOf('<style>')>=0) splice_css();

      html = StringTools.trim(html);
      css = StringTools.trim(css);

      var html_expr:Expr = haxe.macro.MacroStringTools.formatString(html, cls.pos);
      var css_expr:Expr = haxe.macro.MacroStringTools.formatString(css, cls.pos);

      // A Terrible, Dark, non-cross-platform Magic:
      //  -- Context.eval would help some... :(
      var compiled = the_pretty_terrible_fragile_slow_magic(TAG_NAME, cls, haxe_file, html_expr, css_expr);

      // We need to, inside the tag2 callback, mixin THIS Haxe class...
      var idx = compiled.tag2.lastIndexOf('});');
      var cls_ref_name = StringTools.replace(cls.module, ".","_");
      compiled.tag2 = compiled.tag2.substr(0,idx) + '
            console.log("Tag load: "+${ cls_ref_name }.TAG_NAME);
            this.mixin(${ cls_ref_name });
            this.one("mount", function() {
              this._riot_constructor();
              this.update();
            });
        });';


      // - - - Inject fields - - -
      for (new_field in (macro class DummyClass {
        public static var opts_fields(default,never):Array<String> = $v{ opts_fields };

        // Set CSS (and CSS element ID) as static read-only fields
        private static var RIOT_CSS_ELEM_ID(default,never):String = $v{ "riot-"+StringTools.replace(cls.module, '.','-') };
        private static var RIOT_COMPILED_CSS(default,never):String = $v{ compiled.css };

        // Inject the riot.tag2 script here in a static initializer function
        public static var __tag_init:Bool = function() {
          trace('Tag init: '+TAG_NAME);
          // call riot.tag2 to initialize this tag
          untyped __js__($v{ compiled.tag2 });
          // Inject CSS (TODO: coutn loads / unloads, and unload CSS at some point?)
          util.DOMUtil.inject_css(RIOT_COMPILED_CSS, RIOT_CSS_ELEM_ID);
          return true;
        }();

        public function do_mount(root_element) {
          var elem = js.Browser.document.createElement(TAG_NAME);
          root_element.appendChild(elem);
          var m = Riot.mount(elem, TAG_NAME);
          if (m.length==0) throw 'Error, mounting $$TAG_NAME failed!';
        }
      }).fields) fields.push(new_field);

      var has_constructor = fields.select(function(f) return f.name=='new').length>0;
      var has_private_constructor = fields.select(function(f) {
        return (f.name=='new' && f.access.indexOf(APrivate)>=0);
      }).length>0;
   
      if (!has_constructor) {
        // Inject a default private constructor
        fields.push( (macro class DummyClass { private function new() {} }).fields[0] );
      } else if (!has_private_constructor) {
        Context.error('Riot class ${ cls.module } constructor must be private.', Context.currentPos());
      }

      // Rename constructor to _riot_constructor
      fields.select(function(f) return f.name=='new')[0].name = '_riot_constructor';

    }

    return fields;
  }


  // Step 1: Evaluate the html and css expressions, in the context of
  //         this current class, by running the haxe compiler against
  //         the current class as main. Context.eval would have helped.
  // Step 2: Run the riot compiler and sass compiler
  //
  // Return the results as strings
  private static function the_pretty_terrible_fragile_slow_magic(TAG_NAME, cls, haxe_file, html_expr:Expr, css_expr:Expr):{ tag2:String, css:String }
  {
    var compiled_tag2 = '';
    var compiled_css = '';

    // File.copy(haxe_file, haxe_file+'.save'); // backup .hx file
    var content = File.getContent(haxe_file);
    var orig_content = content;
    var code = '
      // must satisfy the IPage interface:
      public function do_mount(root_element:js.html.Element):Void {}

      // Run in node.js context, this writes HTML and CSS
      public static function main() {
        (untyped setTimeout)(function() {
          untyped __js__(\'
            var fs = require("fs");
            fs.writeFileSync({0}, {1});
            fs.writeFileSync({2}, {3});
          \', ".temp/html.tag", ${ html_expr.toString() }, ".temp/src.scss", ${ css_expr.toString() });
        }, 10);
      }
    ';
    //var code = fields.map(function(e) return e.toString()).join(' ');
    //trace(cls);
    content = ~/(public\s+|private\s+|static\s+)+var TAG_NAME/.replace(content, '${ code }; public static var TAG_NAME');
    File.saveContent(haxe_file, content);

    // Run haxe, then nodejs to output the html.tag and src.scss files
    for (cmd in ['mkdir -p .temp','rm -f .temp/*','haxe cp.hxml -D NORIOT -main ${ cls.module } -js .temp/run.js']) {
      Sys.command(cmd);
    }

    // Restore the original .hx file now...
    File.saveContent(haxe_file, orig_content);

    // run node to generate html.tag and src.scss, run node-sass and riot-cli compilers
    for (cmd in ['node .temp/run.js',
                 'node node_modules/node-sass/bin/node-sass .temp/src.scss .temp/css.css',
                 'node ./node_modules/riot-cli/lib/index.js .temp/html.tag']) {
      // trace(cmd);
      Sys.command(cmd);
    }

    // Now we have .temp/html.js (compiled tag) and .temp/css.css (compiled css)
    compiled_tag2 = File.getContent('.temp/html.js');
    compiled_css = File.getContent('.temp/css.css');

    if (compiled_tag2.indexOf("riot.tag2('"+TAG_NAME+"'")<0) {
      throw 'Error: expecting outer tag <'+TAG_NAME+'> in widget ${ cls.module } html';
    }
    return { tag2:compiled_tag2, css:compiled_css };
  }

}

#end
