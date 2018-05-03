package util;

import js.Promise;
import haxe.Http;
import haxe.Json;

class HTTPUtil
{
  public static function load_json(url:String,
                                   ?callback:Dynamic->Void):Promise<Dynamic>
  {
    var promise = new Promise(function(resolve,reject) {
      var req = new Http(url);

      req.onData = function (data) {
        var obj:Dynamic = null;

        try {
          obj = Json.parse(data);
          resolve(obj);
        } catch(e:Dynamic) {
          reject(e);
        }

        if (callback!=null) callback(obj);
      }
      req.onError = function(data) {
        reject(data);
        if (callback!=null) callback(null);
      }

      req.request();
    });
    return promise;
  }

  public static function post_json(url:String,
                                   json:{},
                                   callback:Dynamic->Void):Promise<Dynamic>
  {
    var promise = new Promise(function(resolve,reject) {
      var req = new Http(url);

      req.onData = function (data) {
        var obj:Dynamic = null;

        try {
          obj = Json.parse(data);
          resolve(obj);
        } catch(e:Dynamic) {
          reject(e);
        }

        if (callback!=null) callback(obj);
      }
      req.onError = function(data) {
        reject(data);
        if (callback!=null) callback(null);
      }

      req.addHeader('Content-Type','application/json;charset=UTF-8');
      req.setPostData(haxe.Json.stringify(json)).request(true);
    });
    return promise;
  }
}
