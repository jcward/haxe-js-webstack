package express;

import haxe.extern.EitherType;
import js.node.fs.Stats;

typedef StaticOptions = {
  ?dotfiles : DotFile,
  ?etag : Bool,
  ?extensions : EitherType<Bool, Array<String>>,
  ?index : EitherType<Bool, EitherType<String, Array<String>>>,
  ?lastModified : Bool,
  ?maxAge : EitherType<String, Float>,
  ?redirect : Bool,
  ?setHeaders : Response -> String -> Stats -> Void
}

@:enum
abstract DotFile(String) to String {
  var allow = "allow";
  var deny = "deny";
  var ignore = "ignore";
}