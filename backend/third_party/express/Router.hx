package express;

import express.Middleware;
import haxe.extern.Rest;

@:jsRequire("express", "Router")
extern class Router extends Route {
  @:selfCall function new(?options : RouterOptions) : Void;
  function param(?name : String, callback : Request -> Response -> Next -> String -> Void) : Void;
  function path() : String;

  @:overload(function(callback : EitherMiddleware) : Router {})
  @:overload(function(router : Router) : Router {})
  @:overload(function(path : String, router : Router) : Router {})
  function use(path : String, callback : EitherMiddleware, callbacks : Rest<Middleware>) : Router;
}

typedef RouterOptions = {
  ?caseSensitive : Bool,
  ?mergeParams : Bool,
  ?strict : Bool
}
