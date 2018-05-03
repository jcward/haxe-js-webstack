package express;

import haxe.extern.EitherType;
import haxe.extern.Rest;

extern class Request extends js.node.http.IncomingMessage {
  var app : Express;
  var baseUrl : String;

  var body : Dynamic; // Note: requires body-parser middleware
  var cookies : Dynamic; // Note: requires cookie-parser middleware

  var fresh : Bool;
  var hostname : String;
  var ip : String;
  var ips : Array<String>;
  var originalUrl : String;
  var params : Dynamic;
  var path : String;
  var protocol : String; // TODO needs abstract
  var query : {};
  var route : String;
  var secure : Bool;

  //var signedCookies : {}; // TODO requires middleware

  var stale : Bool;
  var subdomains : Array<String>;
  var xhr : Bool;

  @:overload(function(types : Array<String>) : String {})
  function accepts(type : String) : String;

  function acceptsCharsets(charset : String, charsets : Rest<String>) : String;
  function acceptsEncodings(encoding : String, encodings : Rest<String>) : String;
  function acceptsLanguages(languageg : String, languages : Rest<String>) : String;

  function get(field : String) : String;
  @:overload(function(types : Array<String>) : EitherType<String, Bool> {})
  function is(type : String) : EitherType<String, Bool>;
  function param(name : String, ?defaultValue : String) : String;
}
