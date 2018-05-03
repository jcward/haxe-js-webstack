package util;

import continuation.Continuation;
import continuation.utils.Generator;

typedef HTTPRequestHandler = /* function(error:{}, response:{}, body:String) */ {}->{}->String->Void;
typedef JSONRequestHandler = /* function(error:{}, data:{}) */ Dynamic->Dynamic->Void;

@:autoBuild(continuation.Continuation.cpsByMeta(":async"))
interface IUseAwait { }

class AsyncUtil
{
  public static function to_full_url(url:String):String
  {
    if (url.indexOf('http')==0) return url;
    if (url.indexOf('/')==0) {
      // Relative URLs to our frontend host
      throw 'config.domain_name';
      var domain_name = null;
      return (domain_name.indexOf('http')==0) ? domain_name+url : 'http://${domain_name}'+url;
    }
    throw "Don't know how to handle url: "+url;
    return null;
  }

  // full_url, requires http:// etc
  public static function http_request(url:String, cookie:String=null, handler:HTTPRequestHandler=null)
  {
    var reqLib:Dynamic = js.Node.require('request');
    var full_url = to_full_url(url);
    var options:Dynamic = { uri:full_url };
    // Optional cookie
    if(cookie!=null) {
      var j = reqLib.jar();
      j.setCookie(reqLib.cookie(cookie), full_url);
      options.jar = j;
    }
    reqLib(options, handler);
  }

  // full_url, requires http:// etc
  public static function http_request_post_json(url:String,
                                                data:{},
                                                cookie:String=null,
                                                handler:HTTPRequestHandler=null)
  {
    var reqLib:Dynamic = js.Node.require('request');
    var full_url = to_full_url(url);
    var options:Dynamic = {
      uri:full_url,
      method: 'POST',
      json: data
    }
    // Optional cookie
    if(cookie!=null) {
      var j = reqLib.jar();
      j.setCookie(reqLib.cookie(cookie), full_url);
      options.jar = j;
    }
    reqLib(options, handler);
  }

  public static function get_json(url:String, cookie:String=null, handler:JSONRequestHandler=null)
  {
    continuation.Continuation.cpsFunction(function do_get():Void
    {
      // Optional cookie
      var error, response, body = @await http_request(to_full_url(url), cookie);

      if (error!=null) handler(error, null);

      var rtn:Dynamic = null;
      var err:Dynamic = null;

      try { // Async Note: calling handler in try/catch clause was unreliable!
        rtn = haxe.Json.parse(body);
      } catch (e:Dynamic) {
        logger.Logger.error('Failed to parse JSON response');
        rtn = null;
        err = { error:'JSON response parsing failed' };
      }
      handler(err, rtn);

    });
    do_get(function() { });
  }

  public static function post_json(url:String,
                                   post_data:{},
                                   cookie:String = null,
                                   handler:JSONRequestHandler=null)
  {
    continuation.Continuation.cpsFunction(function do_post():Void
    {
      var error, response, data = @await http_request_post_json(to_full_url(url), post_data, cookie);
      handler(error, data);
    });
    do_post(function() { });
  }

  public static function error_testing(will_err:Bool,
                                       will_throw_sync:Bool,
                                       will_throw_async:Bool,
                                       //       Err msg, result
                                       callback:String->String->Void)
  {
    if (will_throw_sync) throw 'error_testing: synchronous exception';

    haxe.Timer.delay(function() {
      if (will_throw_async) throw 'error_testing: asynchronous exception';
      if (will_err) {
        callback("error_testing: error", null);
      } else {
        callback(null, "err_testing: success");
      }
    }, 100);
  }

  private static function header_obj_from_headers(http_headers:Array<HTTPHeaders>):HeaderDynamic
  {
    var headers:HeaderDynamic = {};

    if (http_headers==null) return headers;

    for (header in http_headers) switch header {
      case ContentType(val):
        headers['Content-Type'] = val;
      case BasicAuthorization(username,password):
        headers['Authorization'] = untyped __js__('"Basic " + new Buffer(username + ":" + password).toString("base64")');
      case BearerAuthorization(token):
        headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // full_url, requires http:// etc
  public static function http_custom(request:HTTPCustomRequest,
                                     handler:HTTPRequestHandler=null)
  {

    var url:String;
    var post_json:{} = null;
    var http_headers:Array<HTTPHeaders> = null;

    switch request {
      case HTTP_GET(u,h): url = u; http_headers = h;
      case HTTP_POST_JSON(u,p,h): url = u; post_json = p; http_headers = h;
    }

    var headers:HeaderDynamic = header_obj_from_headers(http_headers);

    if (post_json!=null) {
      headers['Content-Type'] = 'application/json';
    }

    var method = (post_json==null) ? 'GET' : 'POST';
    var reqLib:Dynamic = js.Node.require('request');
    var options:Dynamic = {
      uri:to_full_url(url),
      method: method,
      headers: headers
    }
    if (post_json!=null) options.json = post_json;

    //_logger.info(' - Making $method request,\n   headers: $headers,\n   post_json: $post_json');

    reqLib(options, handler);
  }

}


typedef HeaderDynamic = haxe.DynamicAccess<Dynamic>;

enum HTTPHeaders {
  ContentType(value:String);
  BasicAuthorization(username:String, password:String);
  BearerAuthorization(token:String);
  // SetCookie?
}

enum HTTPCustomRequest {
  HTTP_GET(url:String, ?headers:Array<HTTPHeaders>);
  HTTP_POST_JSON(url:String, post_json:{}, ?headers:Array<HTTPHeaders>);
}
