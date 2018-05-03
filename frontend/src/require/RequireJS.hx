package require;

import haxe.extern.EitherType;

typedef ReqPackages = {
  name:String,
  route:String,
  ?min_route:String // typically just .min.js
}

typedef PackageName = String;
typedef URLString = String;
typedef RJSConfigOpts = {
  ?waitSeconds:Int,
  paths:DynamicObject<Array<URLString>>,
  ?shim:DynamicObject<EitherType<Array<PackageName>, { deps:Array<PackageName>, exports:PackageName }>>
}

@:native('require')
extern class RequireJS {
  public static function config(opts:RJSConfigOpts):Void;
}

class MyRequire
{
  public static var pkgs:Array<ReqPackages> = [
                                               {
                                               name:'riot',
                                               route:'riot/3.9.0/riot'
                                               }
                                               ];
  public static function config()
  {
    // Map comprehension
    // var paths = [ for (pkg in pkgs) pkg.name => [pkg.route] ];

    var paths:DynamicObject<Array<URLString>> = {};
    for (pkg in pkgs) paths[pkg.name] = [pkg.route];

    untyped __js__(' for (var name in {0}) console.log(name+" -- "+{0}[name]); ', paths);

    RequireJS.config({
      waitSeconds:30,
      paths: paths
    });
  }
}

abstract DynamicObject<T>(Dynamic<T>) from Dynamic<T> {

    public inline function new() {
        this = {};
    }

    @:arrayAccess
    public inline function set(key:String, value:T):Void {
        Reflect.setField(this, key, value);
    }

    @:arrayAccess
    public inline function get(key:String):Null<T> {
        #if js
        return untyped this[key];
        #else
        return Reflect.field(this, key);
        #end
    }

    public inline function exists(key:String):Bool {
        return Reflect.hasField(this, key);
    }

    public inline function remove(key:String):Bool {
        return Reflect.deleteField(this, key);
    }

    public inline function keys():Array<String> {
        return Reflect.fields(this);
    }
}
